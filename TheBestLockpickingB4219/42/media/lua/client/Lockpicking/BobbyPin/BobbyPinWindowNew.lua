require "ISUI/ISPanel"
require "TimedActions/ISBaseTimedAction"

BobbyPinWindowNew = ISPanel:derive("BobbyPinWindowNew")

-- Константы
local MODE_VEHICLE_DOOR = 0
local MODE_VEHICLE_ENGINE_KEY = 1
local MODE_BUILDING_DOOR = 2
local NUM_PINS = 6
local PIN_WIDTH = 30
local PIN_HEIGHT = 100
local PICK_WIDTH = 60
local PICK_HEIGHT = 33
local LOCK_WIDTH = 389
local LOCK_HEIGHT = 320
local GREEN_ZONE = 1
local YELLOW_ZONE = 5
local FALSE_ZONE_SIZE = 1  -- Размер зоны ложной фиксации (в пикселях)
local FALSE_ZONE_OFFSET = 14  -- Смещение ложной зоны ниже правильной (в пикселях)
local MIN_TENSION = 3
local MAX_TENSION = 48
local TOTAL_TENSION = 50 -- Общее требуемое натяжение для открытия замка
local MIN_RANGE = 3
local MAX_RANGE = 5
local BREAK_THRESHOLD = 5 -- Начальный порог превышения натяжения
local SHAKE_DELAY_MIN = 5  -- Минимальная задержка между "трясками" (в тиках)
local SHAKE_DELAY_MAX = 15 -- Максимальная задержка между "трясками" (в тиках)
local FALL_SPEED = 5 -- Скорость плавного опускания штифта (пикселей за тик)

-- Параметры для линейного конгруэнтного генератора (LCG)
local LCG_A = 1664525
local LCG_C = 1013904223
local LCG_M = 2^32 -- Модуль (2^32 для хорошей периодичности)

-- Генератор псевдослучайных чисел на основе keyId
local function createRNG(keyId)
    local seed = keyId
    return function(min, max)
        seed = (LCG_A * seed + LCG_C) % LCG_M
        local range = max - min + 1
        return min + (seed % range)
    end
end

-- Функция для перемешивания массива на основе keyId
local function shuffleWithSeed(array, keyId)
    local rng = createRNG(keyId)
    local n = #array
    for i = n, 2, -1 do
        local j = rng(1, i)
        array[i], array[j] = array[j], array[i]
    end
    return array
end

local function getForceUnlockChance(playerObj, fixedPins, currentTension, maxTension)
    local excessTension = math.max(0, currentTension - maxTension - BREAK_THRESHOLD)
    local baseChance = 0 -- Базовый шанс силового взлома теперь 0
    local lockpickingLevel = playerObj:getPerkLevel(Perks.Lockpicking)
    local strengthLevel = playerObj:getPerkLevel(Perks.Strength)
    local pinBonus = fixedPins * 2
    local tensionBonus = excessTension * 2 -- Увеличиваем шанс за превышение натяжения
    return math.max(0, math.min(20, baseChance + math.ceil(lockpickingLevel/4) + math.ceil(strengthLevel/2) + pinBonus/2 + tensionBonus/2)) -- Максимум 20%
end

local function getBreakLockChance(playerObj, fixedPins, currentTension, maxTension)
    local excessTension = math.max(0, currentTension - maxTension - BREAK_THRESHOLD)
    local baseChance = 30 -- Базовый шанс сломать замок
    local lockpickingLevel = playerObj:getPerkLevel(Perks.Lockpicking)
    local pinPenalty = fixedPins * 2
    local tensionBonus = excessTension * 2 -- Уменьшаем шанс за превышение натяжения
    return math.max(0, math.min(40, baseChance + lockpickingLevel - pinPenalty + tensionBonus)) -- Максимум 40%
end

local function getBreakPickChance(playerObj, fixedPins, currentTension, maxTension)
    local excessTension = math.max(0, currentTension - maxTension - BREAK_THRESHOLD)
    local baseChance = 50 -- Базовый шанс сломать отмычку
    local lockpickingLevel = playerObj:getPerkLevel(Perks.Lockpicking)
    local pinBonus = fixedPins * 2
    local tensionPenalty = excessTension * 2 -- Уменьшаем шанс за превышение натяжения
    return math.max(0, math.min(60, baseChance - lockpickingLevel + pinBonus - tensionPenalty)) -- Максимум 80%
end

function BobbyPinWindowNew:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.variableColor = {r=0.9, g=0.55, b=0.1, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.moveWithMouse = true
    o:setWantKeyEvents(true)

    -- Параметры игры
    o.numPins = NUM_PINS
    o.pins = {}
    o.pinSetHeights = {}
    o.pinCurrentHeights = {}
    o.falsePinHeights = {}
    o.sequence = {}
    o.tensionThresholds = {}
    o.tensionRanges = {}
    o.currentTension = 0
    o.currentSequenceIndex = 1
    o.hoveredPin = nil
    o.chanceBreakLock = 20
    o.lastTensionUpdate = 0
    o.tensionUpdateDelay = 100
    o.greenZone = GREEN_ZONE
    o.yellowZone = YELLOW_ZONE
    o.fakeZone = FALSE_ZONE_SIZE
    o.lastCheckedTension = 0

    -- Для трясущихся рук
    o.lastShakeTick = 0
    o.nextShakeDelay = 0

    -- Для полосы прогресса tension
    o.tensionBarX = 10
    o.tensionBarY = 50
    o.tensionBarWidth = width - 20
    o.tensionBarHeight = 10

    -- Для плавного опускания штифтов
    o.fallSpeeds = {}
    o.fallSoundPlayed = {}
    for i = 1, o.numPins do
        o.fallSpeeds[i] = 0
        o.fallSoundPlayed[i] = false
    end

    -- Новые переменные для блокировки pick
    o.isPickLocked = false
    o.lockedPickX = 0
    o.initialPickY = nil
	
	 -- Ссылка на окно руководства
    o.manualWindow = nil

    -- B42.17 defensive init (only change here)
    o.isEnd = false
    o.lastTick = nil
    o.deltaTime = 0

    -- Текстуры
    o.tex_PinGray = getTexture("media/textures/LockpickNew/pin_gray.png")
    o.tex_PinYellow = getTexture("media/textures/LockpickNew/pin_yellow.png")
    o.tex_PinGreen = getTexture("media/textures/LockpickNew/pin_green.png")
	o.tex_PinGrayTest = getTexture("media/textures/LockpickNew/pin_gray_test.png")
    o.tex_PinYellowTest = getTexture("media/textures/LockpickNew/pin_yellow_test.png")
    o.tex_PinGreenTest = getTexture("media/textures/LockpickNew/pin_green_test.png")
    o.tex_Pick = getTexture("media/textures/LockpickNew/pick.png")
    o.tex_Screwdriver_0 = getTexture("media/textures/LockpickNew/BetLock_Screwdriver_0.png")
    o.tex_Screwdriver_50 = getTexture("media/textures/LockpickNew/BetLock_Screwdriver_50.png")
    o.tex_Screwdriver_100 = getTexture("media/textures/LockpickNew/BetLock_Screwdriver_100.png")
    o.tex_LockBG = getTexture("media/textures/LockpickNew/lockBG.png")
    o.tex_Spring = getTexture("media/textures/LockpickNew/spring.png")
    o.tex_PinTop = getTexture("media/textures/LockpickNew/pin_top.png")
    o.tex_PinTopFake = getTexture("media/textures/LockpickNew/pin_top_fake.png")
    o.tex_PinTopFakeFixed = getTexture("media/textures/LockpickNew/pin_top_fake_fixed.png")
    o.tex_PinMid = getTexture("media/textures/LockpickNew/pin_mid.png")
    o.tex_PinBot = getTexture("media/textures/LockpickNew/pin_bot.png")
    o.tex_PinEmpty = getTexture("media/textures/LockpickNew/pin_empty.png")

    return o
end

function BobbyPinWindowNew:initializeLockParameters(keyId)
    local rng = createRNG(keyId)

    self.sequence = {}
    for i = 1, self.numPins do
        table.insert(self.sequence, i)
        self.pins[i] = {isSet = false, isFalseSet = false, soundPlayed = false}
        self.pinCurrentHeights[i] = 0
        self.falsePinHeights[i] = nil
    end
    self.sequence = shuffleWithSeed(self.sequence, keyId)

    -- Генерация уникальных правильных высот
    local usedHeights = {}
    for i = 1, self.numPins do
        local height
        repeat
            height = rng(20, 80)
        until not usedHeights[height]
        usedHeights[height] = true
        self.pinSetHeights[i] = height
    end

    -- Определяем уровень сложности замка
    --local lockpickLevel = self.lockpick_object:getModData().LockpickLevel or {num = 0}
    --local difficulty = lockpickLevel.num or 0
	local difficulty = self:getLockpickDifficulty()

    -- Задаём фиксированное количество ложных штифтов в зависимости от сложности
    local numFalsePins
    if difficulty == 0 or difficulty == 2 then
        numFalsePins = 0  -- Нет ложных штифтов
    elseif difficulty == 4 then
        numFalsePins = 1  -- Одна ложная фиксация
    elseif difficulty == 6 then
        numFalsePins = rng(1, 2)  -- 1 или 2 ложных штифта, зависит от сида
    elseif difficulty == 8 then
        numFalsePins = 2  -- Две ложных фиксации
    else
        numFalsePins = 0  -- По умолчанию нет ложных штифтов для других значений
    end

    -- Ограничиваем количество ложных штифтов максимальным числом штифтов
    numFalsePins = math.min(numFalsePins, self.numPins)

    -- Выбираем штифты для ложной фиксации
    local falsePinIndices = {}
    local availableIndices = {}
    for i = 1, self.numPins do table.insert(availableIndices, i) end
    for i = 1, numFalsePins do
        local idx = rng(1, #availableIndices)
        table.insert(falsePinIndices, availableIndices[idx])
        table.remove(availableIndices, idx)
    end

    -- Корректируем высоты для штифтов с ложной фиксацией (английских булавок)
    for _, pinIdx in ipairs(falsePinIndices) do
        local trueHeight = self.pinSetHeights[pinIdx]
        if trueHeight >= 20 and trueHeight <= 35 then
            -- Если высота в диапазоне 20–35, генерируем новую выше 35
            local newHeight
            repeat
                newHeight = rng(36, 80) -- Новый диапазон для английских булавок
            until not usedHeights[newHeight]
            -- Удаляем старую высоту и добавляем новую
            usedHeights[trueHeight] = nil
            usedHeights[newHeight] = true
            self.pinSetHeights[pinIdx] = newHeight
        end
    end

    -- Устанавливаем высоту ложной фиксации для выбранных штифтов
    for _, pinIdx in ipairs(falsePinIndices) do
        local trueHeight = self.pinSetHeights[pinIdx]
        local falseHeight = trueHeight - FALSE_ZONE_OFFSET - rng(0, FALSE_ZONE_SIZE)
        self.falsePinHeights[pinIdx] = math.max(0, falseHeight)
    end

    -- Остальной код для генерации натяжений
    local tensions = {}
    for i = 1, self.numPins do
        local tension
        repeat
            tension = rng(MIN_TENSION, MAX_TENSION)
        until not tensions[tension]
        table.insert(tensions, tension)
    end
    table.sort(tensions)
    for i = 1, self.numPins do
        local pinIndex = self.sequence[i]
        self.tensionThresholds[pinIndex] = tensions[i]
        self.tensionRanges[pinIndex] = rng(MIN_RANGE, MAX_RANGE)
    end

    local prevMaxTension = MIN_TENSION - 1
    for i = 1, self.numPins do
        local pinIndex = self.sequence[i]
        local baseTension = self.tensionThresholds[pinIndex]
        local range = self.tensionRanges[pinIndex]
        local minTension = math.max(MIN_TENSION, prevMaxTension + 1)
        local maxTension = math.min(MAX_TENSION, minTension + range - 1)
        if maxTension < minTension then
            maxTension = minTension
        end
        self.tensionThresholds[pinIndex] = math.ceil((minTension + maxTension) / 2)
        self.tensionRanges[pinIndex] = maxTension - minTension + 1
        prevMaxTension = maxTension
    end
end

function BobbyPinWindowNew:render()
    -- Отрисовка фона замка в нижней части окна
    self:drawTextureScaled(self.tex_LockBG, 0, self.height - 261, 389, 261, 1, 1, 1, 1)

    -- Отрисовка отвёртки слева от окна с перекрытием 10 пикселей
    local screwdriverTex
    if self.currentTension <= 18 then
        screwdriverTex = self.tex_Screwdriver_0
    elseif self.currentTension <= 47 then
        screwdriverTex = self.tex_Screwdriver_50
    else
        screwdriverTex = self.tex_Screwdriver_100
    end
    self:drawTextureScaled(screwdriverTex, -370, 264, 400, 56, 1, 1, 1, 1)

    self:drawRect(0, 0, self.width, self.height, 0, 0, 0, 1)
    -- Используем локализованный заголовок
    --self:drawText(getText("UI_Lockpicking_Window_Title"), 10, 10, 1, 1, 1, 1, UIFont.Small)
    -- Локализованный текст для напряжения с добавленным значением
    --self:drawText(getText("UI_Lockpicking_Tension") .. self.currentTension, 10, 30, 1, 1, 1, 1, UIFont.Small)
    self:drawText(getText("UI_Lockpicking_Tension") .. self.currentTension, 10, 30, 0, 0, 1, 1, UIFont.Small)
    
    -- Отображаем уровень сложности замка
    --local lockpickLevel = self.lockpick_object:getModData().LockpickLevel or {num = 0}
    --local difficulty = lockpickLevel.num or 0
	local difficulty = self.mode and self:getLockpickDifficulty() or 0
    --self:drawText(getText("UI_Lockpicking_Difficulty") .. difficulty, 80, 10, 1, 1, 1, 1, UIFont.Small)

    --old
    --local tensionPercent = self.currentTension / TOTAL_TENSION
    --self:drawRect(self.tensionBarX, self.tensionBarY, self.tensionBarWidth, self.tensionBarHeight, 0.2, 0.2, 0.2, 1)
    --self:drawRect(self.tensionBarX, self.tensionBarY, self.tensionBarWidth * tensionPercent, self.tensionBarHeight, 1, 0, 0, 1)
	
	-- === ПЛАВНЫЙ ГРАДИЕНТ  ===
    local tensionPercent = math.min(1, self.currentTension / TOTAL_TENSION)
    
    -- Фон полоски
    self:drawRect(self.tensionBarX, self.tensionBarY, self.tensionBarWidth, self.tensionBarHeight, 0.32, 0.32, 0.32, 1)
    
    local r, g, b = 1, 0.1, 0.1
    
    if self.currentSequenceIndex <= self.numPins then
        local currentPin = self.sequence[self.currentSequenceIndex]
        local baseTension = self.tensionThresholds[currentPin]
        local range = self.tensionRanges[currentPin]
        
        local minTension = math.max(MIN_TENSION, baseTension - math.floor(range / 2))
        local maxTension = math.min(MAX_TENSION, baseTension + math.floor(range / 2))
        
        -- === ПРОГРЕСС С МИНИМАЛЬНОЙ ЖЁЛТОЙ ЗОНОЙ И БЫСТРЫМ КРАСНЫМ ===
        local progress
        if self.currentTension < minTension then
            progress = (self.currentTension / minTension) * 0.48
        elseif self.currentTension <= maxTension then
            local t = (self.currentTension - minTension) / (maxTension - minTension + 0.001)
            progress = 0.48 + 0.07 * t          -- жёлтый теперь ОЧЕНЬ короткий
        else
            -- При первом же превышении maxTension — сразу сильно в красный
            local excess = (self.currentTension - maxTension) / 10   -- быстрее краснеет
            progress = 0.55 + 0.45 * math.min(1, excess)
        end
        
        -- Цвета (синий и красный максимально насыщенные)
        local deepBlue    = {r = 0.08, g = 0.38, b = 0.98}
        local lightBlue   = {r = 0.35, g = 0.78, b = 1.00}
        local briefYellow = {r = 1.00, g = 0.96, b = 0.20}
        local strongRed   = {r = 1.00, g = 0.05, b = 0.02}   -- чистый насыщенный красный
        
        if progress <= 0.48 then
            local t = progress / 0.48
            r = deepBlue.r    + (lightBlue.r   - deepBlue.r)   * t
            g = deepBlue.g    + (lightBlue.g   - deepBlue.g)   * t
            b = deepBlue.b    + (lightBlue.b   - deepBlue.b)   * t
        elseif progress <= 0.55 then
            local t = (progress - 0.48) / 0.07
            r = lightBlue.r   + (briefYellow.r - lightBlue.r)  * t
            g = lightBlue.g   + (briefYellow.g - lightBlue.g)  * t
            b = lightBlue.b   + (briefYellow.b - lightBlue.b)  * t
        else
            local t = (progress - 0.55) / 0.45
            r = briefYellow.r + (strongRed.r   - briefYellow.r) * t
            g = briefYellow.g + (strongRed.g   - briefYellow.g) * t
            b = briefYellow.b + (strongRed.b   - briefYellow.b) * t
        end
    else
        -- Все пины готовы — зелёный
        r, g, b = 0.15, 1.00, 0.35
    end
    
    -- Основная цветная полоска
    self:drawRect(self.tensionBarX, self.tensionBarY, 
                  self.tensionBarWidth * tensionPercent, 
                  self.tensionBarHeight, 1, r, g, b)
----------------------------------------------

    local yBase = self.height - 62
    -- Закомментировано: линия поверх штифтов
    -- self:drawRect(0, yBase - PIN_HEIGHT, self.width, 1, 1, 1, 1, 1)

    -- Получаем уровень навыка взлома игрока
    local playerLockpickingLevel = self.character:getPerkLevel(Perks.Lockpicking)

    if self.currentSequenceIndex <= self.numPins then
        local currentPin = self.sequence[self.currentSequenceIndex]
        local baseTension = self.tensionThresholds[currentPin]
        local range = self.tensionRanges[currentPin]
        local maxTension = math.min(MAX_TENSION, baseTension + math.floor(range / 2))
        local fixedPins = 0
        for i = 1, self.numPins do
            if self.pins[i].isSet then
                fixedPins = fixedPins + 1
            end
        end
        local breakPickChance = getBreakPickChance(self.character, fixedPins, self.currentTension, maxTension)
        local breakLockChance = getBreakLockChance(self.character, fixedPins, self.currentTension, maxTension)
        local forceChance = getForceUnlockChance(self.character, fixedPins, self.currentTension, maxTension)

        -- Проверяем уровень навыка и заменяем значения на "?", если нужно
        local displayBreakPick = playerLockpickingLevel < 3 and "?" or breakPickChance
        local displayBreakLock = playerLockpickingLevel < 3 and "?" or breakLockChance
        local displayForceUnlock = playerLockpickingLevel < 5 and "?" or forceChance

        -- Локализованные строки для шансов с добавленными значениями
        --self:drawText(getText("UI_Lockpicking_BreakPick") .. displayBreakPick .. "%", 180, 30, 1, 0, 0, 1, UIFont.Small)
        --self:drawText(getText("UI_Lockpicking_BreakLock") .. displayBreakLock .. "%", 80, 30, 1, 1, 0, 1, UIFont.Small)
        --self:drawText(getText("UI_Lockpicking_ForceUnlock") .. displayForceUnlock .. "%", 180, 10, 0, 1, 0, 1, UIFont.Small)
        self:drawText(getText("UI_Lockpicking_BreakPick") .. displayBreakPick .. "%", 120, 10, 1, 0, 0, 1, UIFont.Small)
        self:drawText(getText("UI_Lockpicking_BreakLock") .. displayBreakLock .. "%", 120, 30, 1, 1, 0, 1, UIFont.Small)
        self:drawText(getText("UI_Lockpicking_ForceUnlock") .. displayForceUnlock .. "%", 10, 10, 0, 1, 0, 1, UIFont.Small)
    end

    -- Проверка уровня навыка игрока против сложности замка
    local useEmptyPin = playerLockpickingLevel < difficulty

    -- Фиксированные позиции штифтов
    local pinPositions = {55, 104, 153, 202, 251, 300}  -- Центры штифтов (с шагом 49 пикселей, начиная с 55)
    for i = 1, self.numPins do
        local x = pinPositions[i]  -- Используем предопределённые центры
        local height = self.pins[i].isSet and self.pinSetHeights[i] or self.pinCurrentHeights[i]
        local tex = self:getPinTexture(i, height)
        local pinY = yBase - height
        local clippedPinY = math.max(pinY, 60)
        local clippedPinHeight = math.min(height - (clippedPinY - pinY), self.height - clippedPinY)
        if clippedPinHeight > 0 and clippedPinY < self.height then
            self:drawTextureScaled(tex, x - PIN_WIDTH/2, clippedPinY, PIN_WIDTH, clippedPinHeight, 1, 1, 1, 1)
        end
        self:drawRect(x - PIN_WIDTH/2, yBase - self.pinSetHeights[i] - self.greenZone, PIN_WIDTH, self.greenZone * 2, 0, 1, 0, 0.5)
        -- Закомментировано: линия, указывающая на высоту ложного штифта
        -- if self.falsePinHeights[i] then
        --     self:drawRect(x - PIN_WIDTH/2, yBase - self.falsePinHeights[i] - self.greenZone, PIN_WIDTH, self.greenZone * 2, 1, 0, 0, 0.5)
        -- end

        local pinTopHeight = 83
        local pinMidHeight = PIN_HEIGHT - self.pinSetHeights[i]
        local pinBotHeight = 8
        local pinTopY = yBase - height - pinBotHeight - pinMidHeight - pinTopHeight
        local springHeight = pinTopY - 60

        local clippedSpringY = 60
        local clippedSpringHeight = math.min(springHeight, self.height - clippedSpringY)
        if clippedSpringHeight > 0 then
            self:drawTextureScaled(self.tex_Spring, x - PIN_WIDTH/2, clippedSpringY, PIN_WIDTH, clippedSpringHeight, 1, 1, 1, 1)
        end

        if useEmptyPin then
            -- Если уровень игрока ниже сложности, используем pin_empty с фиксированной высотой 167
            local pinEmptyHeight = 167
            local pinEmptyY = yBase - height - pinEmptyHeight
            local clippedPinEmptyY = math.max(pinEmptyY, 60)
            local clippedPinEmptyHeight = math.min(pinEmptyHeight - (clippedPinEmptyY - pinEmptyY), self.height - clippedPinEmptyY)
            if clippedPinEmptyHeight > 0 and clippedPinEmptyY < self.height then
                self:drawTextureScaled(self.tex_PinEmpty, x - PIN_WIDTH/2, clippedPinEmptyY, PIN_WIDTH, clippedPinEmptyHeight, 1, 1, 1, 1)
            end
        else
            -- Обычная отрисовка штифтов из трёх частей
            local clippedPinTopY = math.max(pinTopY, 60)
            local clippedPinTopHeight = math.min(pinTopHeight - (clippedPinTopY - pinTopY), self.height - clippedPinTopY)
            if clippedPinTopHeight > 0 and clippedPinTopY < self.height then
                local pinTopTex
                if self.falsePinHeights[i] then
                    local baseTension = self.tensionThresholds[i]
                    local range = self.tensionRanges[i]
                    local minTension = math.max(MIN_TENSION, baseTension - math.floor(range / 2))
                    local maxTension = math.min(MAX_TENSION, baseTension + math.floor(range / 2))
                    if self.pins[i].isFalseSet and self.currentTension >= minTension then
                        pinTopTex = self.tex_PinTopFakeFixed
                    else
                        pinTopTex = self.tex_PinTopFake
                    end
                else
                    pinTopTex = self.tex_PinTop
                end
                self:drawTextureScaled(pinTopTex, x - PIN_WIDTH/2, clippedPinTopY, PIN_WIDTH, clippedPinTopHeight, 1, 1, 1, 1)
            end

            local pinMidY = yBase - height - pinBotHeight - pinMidHeight
            local clippedPinMidY = math.max(pinMidY, 60)
            local clippedPinMidHeight = math.min(pinMidHeight - (clippedPinMidY - pinMidY), self.height - clippedPinMidY)
            if clippedPinMidHeight > 0 and clippedPinMidY < self.height then
                self:drawTextureScaled(self.tex_PinMid, x - PIN_WIDTH/2, clippedPinMidY, PIN_WIDTH, clippedPinMidHeight, 1, 1, 1, 1)
            end

            local pinBotY = yBase - height - pinBotHeight
            local clippedPinBotY = math.max(pinBotY, 60)
            local clippedPinBotHeight = math.min(pinBotHeight - (clippedPinBotY - pinBotY), self.height - clippedPinBotY)
            if clippedPinBotHeight > 0 and clippedPinBotY < self.height then
                self:drawTextureScaled(self.tex_PinBot, x - PIN_WIDTH/2, clippedPinBotY, PIN_WIDTH, clippedPinBotHeight, 1, 1, 1, 1)
            end
        end

        local sequenceIndex = nil
        for j, pin in ipairs(self.sequence) do
            if pin == i then
                sequenceIndex = j
                break
            end
        end
        if sequenceIndex then
            local baseTension = self.tensionThresholds[i]
            local range = self.tensionRanges[i]
            local minTension = math.max(MIN_TENSION, baseTension - math.floor(range / 2))
            local maxTension = math.min(MAX_TENSION, baseTension + math.floor(range / 2))
            -- Локализованный формат для последовательности и диапазона (закомментировано в исходном коде)
            -- self:drawText(tostring(sequenceIndex) .. " (" .. minTension .. "-" .. maxTension .. ")", x - 10, yBase + 20, 1, 1, 1, 1, UIFont.Small)
        end
    end

    local pinX = self:getMouseX() or 0
    local pickY = self:getMouseY() or 0
    local maxPickY = yBase - PIN_HEIGHT
    pickY = math.max(pickY, maxPickY)

    if self.isPickLocked then
        pinX = self.lockedPickX
    end

    self:drawTextureScaled(self.tex_Pick, pinX - PICK_WIDTH, pickY, PICK_WIDTH, PICK_HEIGHT, 1, 1, 1, 1)
end

function BobbyPinWindowNew:getPinTexture(pinIndex, height)
    local diffTrue = math.abs(height - self.pinSetHeights[pinIndex])
    local hasFalsePin = self.falsePinHeights[pinIndex] ~= nil
    local diffFalse = hasFalsePin and math.abs(height - self.falsePinHeights[pinIndex]) or math.huge

    if diffTrue <= self.greenZone then
        return self.tex_PinGreen  -- Правильная зона
    elseif hasFalsePin and diffFalse <= self.greenZone then
        return self.tex_PinGreen  -- Ложная зона тоже зелёная
    elseif diffTrue <= self.greenZone + self.yellowZone then
        return self.tex_PinYellow
    else
        return self.tex_PinGray
    end
end

function BobbyPinWindowNew:checkPinStability()
    for i = 1, self.numPins do
        if self.pinCurrentHeights[i] > 0 and not self.pins[i].isSet then
            local baseTension = self.tensionThresholds[i]
            local range = self.tensionRanges[i]
            local minTension = math.max(MIN_TENSION, baseTension - math.floor(range / 2))
            if self.currentTension < minTension then
                if self.fallSpeeds[i] == 0 then
                    self.fallSpeeds[i] = FALL_SPEED
                    self.fallSoundPlayed[i] = false
                    self.pins[i].isFalseSet = false  -- Сбрасываем ложную фиксацию при падении
                    self.pins[i].soundPlayed = false
                end
            end
        end
    end

    local newSequenceIndex = 1
    for i = 1, self.numPins do
        local pinIndex = self.sequence[i]
        local baseTension = self.tensionThresholds[pinIndex]
        local range = self.tensionRanges[pinIndex]
        local minTension = math.max(MIN_TENSION, baseTension - math.floor(range / 2))
        if self.currentTension < minTension then
            if self.pins[pinIndex].isSet then
                self.pins[pinIndex].isSet = false
                self.fallSpeeds[pinIndex] = FALL_SPEED
                self.fallSoundPlayed[pinIndex] = false
            end
            if self.pins[pinIndex].isFalseSet then
                self.pins[pinIndex].isFalseSet = false
                self.pins[pinIndex].soundPlayed = false
                self.fallSpeeds[pinIndex] = FALL_SPEED
                self.fallSoundPlayed[pinIndex] = false
            end
        end
        if self.pins[pinIndex].isSet then
            newSequenceIndex = i + 1
        else
            break
        end
    end
    self.currentSequenceIndex = newSequenceIndex
end

function BobbyPinWindowNew:doBreakPick()
    local bobbyPin = self.character:getInventory():getFirstTypeRecurse("BobbyPin")
    local handmadeBobbyPin = self.character:getInventory():getFirstTypeRecurse("HandmadeBobbyPin")
    if bobbyPin then
        self.character:getInventory():Remove(bobbyPin)
    elseif handmadeBobbyPin then
        self.character:getInventory():Remove(handmadeBobbyPin)
    end
    
    -- Находим отвёртку в инвентаре и уменьшаем её состояние
    --local screwdriver = self.character:getInventory():getFirstTypeRecurse("Screwdriver")
    --if screwdriver then
    --    local damage = ZombRand(1, 8)
    --    local newCondition = math.max(0, screwdriver:getCondition() - damage)
    --    screwdriver:setCondition(newCondition)
    --end
    self:damageScrewdriver(1)
    self.character:playSoundLocal("bobby_fail")
    sendClientCommand(self.character, "BetLock", "addLockpickingXP", {amount = math.max(1, math.floor(self.addingXP / 10))})
    self.character:getXp():AddXPHaloText(Perks.Lockpicking, math.max(1, math.floor(self.addingXP / 10)))
    self:close()
end

function BobbyPinWindowNew:damageScrewdriver(damage)
    -- Ломаем инструмент, который сейчас в основной руке
    local itemInHand = self.character:getPrimaryHandItem()
    
    if itemInHand then
        -- Если damage не передан или <= 0 — рандом
        if not damage or damage <= 0 then
            damage = ZombRand(1, 8)
        end
        
        local newCondition = math.max(0, itemInHand:getCondition() - damage)
        itemInHand:setCondition(newCondition)
        
        -- Опционально: звук при повреждении
        -- self.character:playSoundLocal("BreakMetalItem")
    end
end

BobbyPinWindowNew.OnKeyKeepPressed = function(key)
    if BobbyPinWindowNew.instance == nil then return end
    
    local win = BobbyPinWindowNew.instance
    if key == Keyboard.KEY_ESCAPE then
        win:close()
    end
end

function BobbyPinWindowNew:onTick()
    local win = BobbyPinWindowNew.instance
    if win == nil or win.isEnd then return end

    local now = getTimeInMillis()
    win.deltaTime = now - (win.lastTick or now)
    win.lastTick = now

    if not win.lastCheckedTension then
        win.lastCheckedTension = win.currentTension
    end

    if now - win.lastTensionUpdate >= win.tensionUpdateDelay then
        local lockpickingLevel = win.character:getPerkLevel(Perks.Lockpicking)
        local tensionChange = 1
        if lockpickingLevel < 8 then
            if lockpickingLevel == 0 then tensionChange = ZombRand(1, 7)
            elseif lockpickingLevel == 1 then tensionChange = ZombRand(1, 7)
            elseif lockpickingLevel == 2 then tensionChange = ZombRand(1, 6)
            elseif lockpickingLevel == 3 then tensionChange = ZombRand(1, 6)
            elseif lockpickingLevel == 4 then tensionChange = ZombRand(1, 5)
            elseif lockpickingLevel == 5 then tensionChange = ZombRand(1, 4)
            elseif lockpickingLevel == 6 then tensionChange = ZombRand(1, 4)
            elseif lockpickingLevel == 7 then tensionChange = ZombRand(1, 3)
            end
        end

        if Keyboard.isKeyDown(Keyboard.KEY_A) then
            win.currentTension = math.max(0, win.currentTension - tensionChange)
            win.lastTensionUpdate = now
        elseif Keyboard.isKeyDown(Keyboard.KEY_D) then
            win.currentTension = math.min(TOTAL_TENSION, win.currentTension + tensionChange)
            win.lastTensionUpdate = now
        end
    end

    local lockpickingLevel = win.character:getPerkLevel(Perks.Lockpicking)
    local tensionFactor = win.currentTension / TOTAL_TENSION
    local shakeChance = (1 - (lockpickingLevel / 10)) * tensionFactor
    
    if win.nextShakeDelay == 0 then
        local delayFactor = 1 - shakeChance
        win.nextShakeDelay = math.floor(SHAKE_DELAY_MIN + (SHAKE_DELAY_MAX - SHAKE_DELAY_MIN) * delayFactor)
    end

    if now - win.lastShakeTick >= win.nextShakeDelay * 50 then
        if ZombRand(100) < shakeChance * 100 then
            local shakeDirection = ZombRand(2) == 0 and -1 or 1
            win.currentTension = math.max(0, math.min(TOTAL_TENSION, win.currentTension + shakeDirection))
        end
        win.lastShakeTick = now
        win.nextShakeDelay = 0
    end

    if win.currentSequenceIndex <= win.numPins and win.currentTension ~= win.lastCheckedTension then
        local currentPin = win.sequence[win.currentSequenceIndex]
        local baseTension = win.tensionThresholds[currentPin]
        local range = win.tensionRanges[currentPin]
        local maxTension = math.min(MAX_TENSION, baseTension + math.floor(range / 2))
        if win.currentTension >= maxTension + BREAK_THRESHOLD then
            local fixedPins = 0
            for i = 1, win.numPins do
                if win.pins[i].isSet then
                    fixedPins = fixedPins + 1
                end
            end
            local breakPickChance = getBreakPickChance(win.character, fixedPins, win.currentTension, maxTension)
            local breakLockChance = getBreakLockChance(win.character, fixedPins, win.currentTension, maxTension)
            local forceChance = getForceUnlockChance(win.character, fixedPins, win.currentTension, maxTension)

            local roll = ZombRand(100)
            if roll < breakPickChance then
                win:doBreakPick()
            elseif roll < breakPickChance + breakLockChance then
                win:doBreakLock()
                win:close()
            elseif roll < breakPickChance + breakLockChance + forceChance then
                win:doUnlock(true)
                win:close()
            end
            win.lastCheckedTension = win.currentTension
            return
        end
        win.lastCheckedTension = win.currentTension
    end

    local previousHoveredPin = win.hoveredPin
    win.hoveredPin = nil
    local pinPositions = {55, 104, 153, 202, 251, 300}  -- Центры штифтов
    for i = 1, win.numPins do
        local pinX = pinPositions[i]
        local mouseX = win:getMouseX()
        if mouseX and math.abs(mouseX - pinX) < PIN_WIDTH/2 then
            win.hoveredPin = i
            break
        end
    end

    if not win.javaObject then
        print("Error: win.javaObject is nil in onTick")
        return
    end

    if win.hoveredPin then
        local mouseY = win:getMouseY()
        if mouseY then
            local yBase = win.height - 62
            local maxPickY = yBase - PIN_HEIGHT
            mouseY = math.max(mouseY, maxPickY)

            local currentPinHeight = win.pins[win.hoveredPin].isSet and win.pinSetHeights[win.hoveredPin] or win.pinCurrentHeights[win.hoveredPin]
            local newHeight = yBase - mouseY

            if previousHoveredPin ~= win.hoveredPin then
                win.initialPickY = mouseY
                local startHeight = yBase - win.initialPickY
                if startHeight > currentPinHeight then
                    win.isPickLocked = true
                    win.lockedPickX = win:getMouseX() or 0
                else
                    win.isPickLocked = false
                end
            end

            local baseTension = win.tensionThresholds[win.hoveredPin]
            local range = win.tensionRanges[win.hoveredPin]
            local minTension = math.max(MIN_TENSION, baseTension - math.floor(range / 2))
            local maxTension = math.min(MAX_TENSION, baseTension + math.floor(range / 2))
            local diffTrue = math.abs(newHeight - win.pinSetHeights[win.hoveredPin])

            if win.pins[win.hoveredPin].isSet and win.currentTension >= minTension and win.currentTension <= maxTension then
                if diffTrue <= win.greenZone + 2 then
                    win.isPickLocked = true
                    win.lockedPickX = win:getMouseX() or 0
                end
            elseif win.isPickLocked and newHeight <= currentPinHeight then
                win.isPickLocked = false
            end

            if not win.isPickLocked then
                if win.currentTension < minTension then
                    win.pinCurrentHeights[win.hoveredPin] = math.max(0, math.min(newHeight, PIN_HEIGHT))
                    win.fallSpeeds[win.hoveredPin] = 0
                elseif win.currentTension >= minTension and win.currentTension <= maxTension then
                    if win.pins[win.hoveredPin].isFalseSet then
                        win.pinCurrentHeights[win.hoveredPin] = win.falsePinHeights[win.hoveredPin]
                    else
                        win.pinCurrentHeights[win.hoveredPin] = math.max(newHeight, win.pinCurrentHeights[win.hoveredPin])
                        win.fallSpeeds[win.hoveredPin] = 0
                    end
                end
            end
        end
    else
        win.isPickLocked = false
        win.initialPickY = nil
    end

    for i = 1, win.numPins do
        if win.fallSpeeds[i] > 0 then
            win.pinCurrentHeights[i] = win.pinCurrentHeights[i] - win.fallSpeeds[i]
            if win.pinCurrentHeights[i] <= 0 then
                win.pinCurrentHeights[i] = 0
                win.fallSpeeds[i] = 0
                if win.hoveredPin ~= i and not win.fallSoundPlayed[i] then
                    win.character:playSoundLocal("pin_fall")
                    win.fallSoundPlayed[i] = true
                end
            end
        end
    end

    if win.currentSequenceIndex <= win.numPins then
        local currentPin = win.sequence[win.currentSequenceIndex]
        if not win.pins[currentPin].isSet and win.pinCurrentHeights[currentPin] > 0 then
            local baseTension = win.tensionThresholds[currentPin]
            local range = win.tensionRanges[currentPin]
            local minTension = math.max(MIN_TENSION, baseTension - math.floor(range / 2))
            local maxTension = math.min(MAX_TENSION, baseTension + math.floor(range / 2))
            local diffTrue = math.abs(win.pinCurrentHeights[currentPin] - win.pinSetHeights[currentPin])
            local hasFalsePin = win.falsePinHeights[currentPin] ~= nil
            local diffFalse = hasFalsePin and math.abs(win.pinCurrentHeights[currentPin] - win.falsePinHeights[currentPin]) or math.huge

            if diffTrue <= win.greenZone and win.currentTension >= minTension and win.currentTension <= maxTension then
                win.pins[currentPin].isSet = true
                win.pins[currentPin].isFalseSet = false
                win.pins[currentPin].soundPlayed = false
                win.currentSequenceIndex = win.currentSequenceIndex + 1
                --win.character:getEmitter():playSound("pin_click")
                win.character:playSoundLocal("pin_click")
                win.isPickLocked = true
                win.lockedPickX = win:getMouseX() or 0
            elseif hasFalsePin and diffFalse <= win.fakeZone and win.currentTension >= minTension and win.currentTension <= maxTension then
                if not win.pins[currentPin].isFalseSet then
                    win.pins[currentPin].isFalseSet = true
                    win.pinCurrentHeights[currentPin] = win.falsePinHeights[currentPin]
                    if not win.pins[currentPin].soundPlayed then
                        --win.character:getEmitter():playSound("pin_click")
                        win.character:playSoundLocal("pin_click")
                        win.pins[currentPin].soundPlayed = true
                    end
                end
            end
        end
    end

    if win.currentSequenceIndex > win.numPins and win.currentTension == TOTAL_TENSION then
        win:doUnlock(false)
        win:close()
    end

    win:checkPinStability()
end

function BobbyPinWindowNew:initialise()
    print("=== INITIALISE START ===")
    print("addingXP BEFORE = " .. tostring(self.addingXP))
    
    if self.lockpick_object and self.lockpick_object:getModData().LockpickLevel then
        local lvl = self.lockpick_object:getModData().LockpickLevel
        print("LockpickLevel.num = " .. tostring(lvl.num))
        print("LockpickLevel.xp  = " .. tostring(lvl.xp))
    end
	--------------------- 
    if not (self.character:getInventory():getFirstTypeRecurse("BobbyPin") or self.character:getInventory():getFirstTypeRecurse("HandmadeBobbyPin")) then
        return
    end
    ISPanel.initialise(self)
    
    -- B42.17 safe keyId (only change here)
    local keyId = 0
    if self.mode == MODE_VEHICLE_DOOR or self.mode == MODE_VEHICLE_ENGINE_KEY then
        local veh = self.lockpick_object and self.lockpick_object:getVehicle()
        keyId = veh and veh:getKeyId() or 0
    else
        keyId = self.lockpick_object and self.lockpick_object:getKeyId() or 0
    end
    self:initializeLockParameters(keyId)
    
    self:create()
    BobbyPinWindowNew.instance = self
    self.character:getModData().isLockpicking = true
    ISTimedActionQueue.clear(self.character)
    ISTimedActionQueue.add(BobbyPinActionAnim:new(self.character, self.lockpick_object))
end

function BobbyPinWindowNew:create()
    self.cancel = ISButton:new(self:getWidth() - 110, 10, 100, 20, getText("UI_Cancel"), self, BobbyPinWindowNew.onOptionMouseDown)
    self.cancel.internal = "CANCEL"
    self.cancel:initialise()
    self.cancel:instantiate()
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.cancel)
	
    self.manual = ISButton:new(self:getWidth() - 110, 30, 100, 20, getText("UI_Manual_Btn"), self, BobbyPinWindowNew.onOptionMouseDown)
    self.manual.internal = "MANUAL"
    self.manual:initialise()
    self.manual:instantiate()
    self.manual.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.manual)
end

function BobbyPinWindowNew:close()
    self.character:getModData().zReBLStopFlag = 1
    self.character:getModData().isLockpicking = false
    ISTimedActionQueue.clear(self.character)
	
	-- Закрываем окно руководства, если оно открыто
    if self.manualWindow then
        self.manualWindow:close()
        self.manualWindow = nil  -- Очищаем ссылку
    end
	
    BobbyPinWindowNew.instance = nil
    ISPanel.close(self)
end

function BobbyPinWindowNew:onOptionMouseDown(button, x, y)
    if button.internal == "CANCEL" then
        self:close()
    elseif button.internal == "MANUAL" then
        local manualWindow = ManualWindow:new(self:getX() + self:getWidth() + 10, self:getY(), 300, 400)
        manualWindow:initialise()
        manualWindow:addToUIManager()
        self.manualWindow = manualWindow  -- Сохраняем ссылку на окно руководства
    end
end

function BobbyPinWindowNew:doLock()
    self.lockpick_object:setLockedByKey(true)
    self.lockpick_object:setLocked(true)
    if IsoDoor.getGarageDoorIndex(self.lockpick_object) ~= -1 then
        local doorPrev = IsoDoor.getGarageDoorPrev(self.lockpick_object)
        while doorPrev ~= nil do
            doorPrev:setLockedByKey(true)
            doorPrev:setLocked(true)
            doorPrev = IsoDoor.getGarageDoorPrev(doorPrev)
        end
        local doorNext = IsoDoor.getGarageDoorNext(self.lockpick_object)
        while doorNext ~= nil do
            doorNext:setLockedByKey(true)
            doorNext:setLocked(true)
            doorNext = IsoDoor.getGarageDoorNext(doorNext)
        end
    end
    sendClientCommand(self.character, "BetLock", "addLockpickingXP", {amount = self.addingXP})
    self.character:getXp():AddXPHaloText(Perks.Lockpicking, self.addingXP)
    self.character:playSoundLocal("bobby_success")
end

function BobbyPinWindowNew:doUnlock(isForceUnlock)
    print("=== DOUNLOCK START ===")
    print("self.addingXP = " .. tostring(self.addingXP))
    print("isForceUnlock = " .. tostring(isForceUnlock))
    if isForceUnlock then
        if self.mode == MODE_VEHICLE_DOOR then
            self.lockpick_object:getDoor():setLockBroken(true)
        elseif self.mode == MODE_VEHICLE_ENGINE_KEY then
            self.lockpick_object:setKeyId(-3)
        else
            self.lockpick_object:setKeyId(-3)
            if IsoDoor.getGarageDoorIndex(self.lockpick_object) ~= -1 then
                local doorPrev = IsoDoor.getGarageDoorPrev(self.lockpick_object)
                while doorPrev ~= nil do
                    doorPrev:setKeyId(-3)
                    doorPrev = IsoDoor.getGarageDoorPrev(doorPrev)
                end
                local doorNext = IsoDoor.getGarageDoorNext(self.lockpick_object)
                while doorNext ~= nil do
                    doorNext:setKeyId(-3)
                    doorNext = IsoDoor.getGarageDoorNext(doorNext)
                end
            end
        end

        if self.mode == MODE_VEHICLE_DOOR then
            local veh = self.lockpick_object and self.lockpick_object:getVehicle()
            if veh then
                sendClientCommand(self.character, 'screwdriver', 'vehicleDoor', { 
                    vehicle = veh:getId(), 
                    part = self.lockpick_object:getId() 
                })
            end
        elseif self.mode == MODE_VEHICLE_ENGINE_KEY then
            self.lockpick_object:tryStartEngine(true)
        else
            local originalKeyId = self.lockpick_object:getKeyId()
            self.lockpick_object:setLockedByKey(false)
            self.lockpick_object:setLocked(false)
            self.lockpick_object:setKeyId(-1)
            pcall(function() self.lockpick_object:setIsLocked(false) end)
            if IsoDoor.getGarageDoorIndex(self.lockpick_object) ~= -1 then
                local doorPrev = IsoDoor.getGarageDoorPrev(self.lockpick_object)
                while doorPrev ~= nil do
                    doorPrev:setLockedByKey(false)
                    doorPrev = IsoDoor.getGarageDoorPrev(doorPrev)
                end
                local doorNext = IsoDoor.getGarageDoorNext(self.lockpick_object)
                while doorNext ~= nil do
                    doorNext:setLockedByKey(false)
                    doorNext = IsoDoor.getGarageDoorNext(doorNext)
                end
            end
            sendClientCommand(self.character, 'BetLock', 'unlockBuildingDoor', {
                x = self.lockpick_object:getSquare():getX(),
                y = self.lockpick_object:getSquare():getY(),
                z = self.lockpick_object:getSquare():getZ(),
                keyId = originalKeyId
            })
            -- B42.19: setOpen(true) removed, bypasses animation and causes door state desync
        end
        
        self.character:playSoundLocal("lockpick_force_fail")
    else
        -- normal unlock (same safe pattern)
        if self.mode == MODE_VEHICLE_DOOR then
            local veh = self.lockpick_object and self.lockpick_object:getVehicle()
            if veh then
                sendClientCommand(self.character, 'screwdriver', 'vehicleDoor', { 
                    vehicle = veh:getId(), 
                    part = self.lockpick_object:getId() 
                })
            end
        elseif self.mode == MODE_VEHICLE_ENGINE_KEY then
            self.lockpick_object:tryStartEngine(true)
        else
            local originalKeyId = self.lockpick_object:getKeyId()
            self.lockpick_object:setLockedByKey(false)
            self.lockpick_object:setLocked(false)
            self.lockpick_object:setKeyId(-1)
            pcall(function() self.lockpick_object:setIsLocked(false) end)
            if IsoDoor.getGarageDoorIndex(self.lockpick_object) ~= -1 then
                local doorPrev = IsoDoor.getGarageDoorPrev(self.lockpick_object)
                while doorPrev ~= nil do
                    doorPrev:setLockedByKey(false)
                    doorPrev = IsoDoor.getGarageDoorPrev(doorPrev)
                end
                local doorNext = IsoDoor.getGarageDoorNext(self.lockpick_object)
                while doorNext ~= nil do
                    doorNext:setLockedByKey(false)
                    doorNext = IsoDoor.getGarageDoorNext(doorNext)
                end
            end
            sendClientCommand(self.character, 'BetLock', 'unlockBuildingDoor', {
                x = self.lockpick_object:getSquare():getX(),
                y = self.lockpick_object:getSquare():getY(),
                z = self.lockpick_object:getSquare():getZ(),
                keyId = originalKeyId
            })
            -- B42.19: setOpen(true) removed, bypasses animation and causes door state desync
        end
        self.character:playSoundLocal("bobby_success")
    end
    
    if isForceUnlock then
        self:damageScrewdriver()
    end
    local xpBefore = self.character:getXp():getXP(Perks.Lockpicking)
    sendClientCommand(self.character, "BetLock", "addLockpickingXP", {amount = self.addingXP})
    self.character:getXp():AddXPHaloText(Perks.Lockpicking, self.addingXP)
    local xpAfter = self.character:getXp():getXP(Perks.Lockpicking)
end

function BobbyPinWindowNew:doBreakLock()
    self:damageScrewdriver()
    self.character:playSoundLocal("lockpick_force_fail")
    sendClientCommand(self.character, "BetLock", "addLockpickingXP", {amount = math.max(1, math.floor(self.addingXP / 5))})
    self.character:getXp():AddXPHaloText(Perks.Lockpicking, math.max(1, math.floor(self.addingXP / 5)))
    self:close()
end

function BobbyPinWindowNew:getLockpickDifficulty()
    if self.mode == MODE_VEHICLE_DOOR or self.mode == MODE_VEHICLE_ENGINE_KEY then
        local veh = self.lockpick_object and self.lockpick_object:getVehicle()
        local data = veh and veh:getModData().LockpickLevel
        return data and data.num or 0
    else
        local data = self.lockpick_object and self.lockpick_object:getModData().LockpickLevel
        return data and data.num or 0
    end
end

function BobbyPinWindowNew:createVehicleDoor(playerObj, part)
    if part:getDoor():isLockBroken() then
        playerObj:Say(getText("IGUI_PlayerText_VehicleLockIsBroken"))
        return
    end
        
    local modal = BobbyPinWindowNew:new(Core:getInstance():getScreenWidth()/2 - LOCK_WIDTH/2, Core:getInstance():getScreenHeight()/2 - LOCK_HEIGHT/2, LOCK_WIDTH, LOCK_HEIGHT)
    modal.lockpick_object = part
    modal.mode = MODE_VEHICLE_DOOR
    modal.character = playerObj
    
    -- B42.17 nil-safety (only change here)
    local vehModData = part:getVehicle() and part:getVehicle():getModData() or {}
    modal.addingXP = (vehModData.LockpickLevel and vehModData.LockpickLevel.xp) or 5

    modal:initialise()
    modal:addToUIManager()
end

function BobbyPinWindowNew:createBuildingDoor(playerObj, door, goToOpen)
    if not door or not playerObj then return end

    local dx = door:getSquare():getX() - playerObj:getSquare():getX()
    local dy = door:getSquare():getY() - playerObj:getSquare():getY()
    local zGood = math.abs(door:getSquare():getZ() - playerObj:getSquare():getZ()) < 2
    local dist = math.sqrt(dx*dx + dy*dy)
    
    if not zGood or dist > 2 then return end

    if goToOpen and not door:isLocked() then
        playerObj:Say(getText("UI_door_is_unlocked"))
        return
    end

    if not goToOpen and door:isLocked() then
        playerObj:Say(getText("UI_door_is_locked"))
        return
    end

    if door:getKeyId() == -3 then
        playerObj:Say(getText("IGUI_PlayerText_VehicleLockIsBroken"))
        return
    end

    local modal = BobbyPinWindowNew:new(Core:getInstance():getScreenWidth()/2 - LOCK_WIDTH/2, Core:getInstance():getScreenHeight()/2 - LOCK_HEIGHT/2, LOCK_WIDTH, LOCK_HEIGHT)
    modal.lockpick_object = door
    modal.mode = MODE_BUILDING_DOOR
    modal.character = playerObj
    modal.goToOpen = goToOpen
    local modData = door:getModData()
    modal.addingXP = (modData.LockpickLevel and modData.LockpickLevel.xp) or 5

    if playerObj and door then
        playerObj:faceThisObject(door)
    end

    modal:initialise()
    modal:addToUIManager()
end

Events.OnKeyKeepPressed.Add(BobbyPinWindowNew.OnKeyKeepPressed)
Events.OnTick.Add(BobbyPinWindowNew.onTick)
