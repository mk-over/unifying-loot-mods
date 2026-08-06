if BetLock == nil then BetLock = {} end
BetLock.Wires = {}

local field_height = 224
local wire_colors = {"red", "blue", "green", "yellow", "orange", "purple", "white", "black"}

-- Функция для перемешивания таблицы
local function shuffleTable(t)
    local n = #t
    for i = n, 2, -1 do
        local j = ZombRand(i) + 1
        t[i], t[j] = t[j], t[i]
    end
    return t
end

-- Класс для больших проводов
BetLock_BigWire = ISWire:derive("BetLock_BigWire")
function BetLock_BigWire:new(color, x, parent)
    local texture = getTexture("media/textures/wire/wire_" .. color .. "_big.png")
    if not texture then
        print("Error: Texture not found for wire_" .. color .. "_big.png")
        texture = getTexture("media/ui/MissingTexture.png")
        if not texture then return nil end
    end
    local width = texture:getWidth()
    local height = texture:getHeight()
    local o = ISWire.new(self, x or parent.shuffledPositions[color], 0, width, height)
    o.color = color
    o.parent = parent
    o.texture = texture
    o.originalX = x or parent.shuffledPositions[color] -- Сохраняем исходную позицию
    return o
end

function BetLock_BigWire:onMouseDown(x, y)
    self.parent:removeChild(self)
    local upWire = BetLock_UpWire:new(self.color, self.originalX)
    local downWire = BetLock_DownWire:new(self.color, self.originalX, self.parent)
    if upWire and downWire then
        self.parent:addChild(upWire)
        self.parent:addChild(downWire)
    else
        print("Error: Failed to create UpWire or DownWire for color " .. self.color)
    end
    return true
end

-- Класс для верхней части провода
BetLock_UpWire = ISWire:derive("BetLock_UpWire")
function BetLock_UpWire:new(color, x)
    local texture = getTexture("media/textures/wire/wire_" .. color .. "_up.png")
    if not texture then
        print("Error: Texture not found for wire_" .. color .. "_up.png")
        texture = getTexture("media/ui/MissingTexture.png")
        if not texture then return nil end
    end
    local width = texture:getWidth()
    local height = texture:getHeight()
    local o = ISWire.new(self, x, 0, width, height)
    o.texture = texture
    o.originalX = x -- Сохраняем исходную позицию
    return o
end

-- Класс для нижней части провода
BetLock_DownWire = ISWire:derive("BetLock_DownWire")
function BetLock_DownWire:new(color, x, parent)
    local texture = getTexture("media/textures/wire/wire_" .. color .. ".png")
    if not texture then
        print("Error: Texture not found for wire_" .. color .. ".png")
        texture = getTexture("media/ui/MissingTexture.png")
        if not texture then return nil end
    end
    local width = texture:getWidth()
    local height = texture:getHeight()
    local o = ISWire.new(self, x, field_height - height, width, height)
    o.color = color
    o.parent = parent
    o.texture = texture
    o.selected_texture = getTexture("media/textures/wire/wire_" .. color .. "_select.png") or texture
    o.name = color -- Для совместимости с wireConnected/wireDisconnected
    o.originalX = x -- Сохраняем исходную позицию
    return o
end

function BetLock_DownWire:onMouseDown(x, y)
    if self.parent.selectedWire == nil then
        self.texture = self.selected_texture
        self.parent.selectedWire = self
    else
        if self.parent.selectedWire == self then
            self.texture = getTexture("media/textures/wire/wire_" .. self.color .. ".png") or self.texture
            self.parent.selectedWire = nil
        else
            local selected_color = self.parent.selectedWire.color
            local clicked_color = self.color
            if self.parent.selectedWires[selected_color] and self.parent.selectedWires[clicked_color] then
                local texture_name
                local texture = getTexture("media/textures/wire/wire_" .. selected_color .. "_" .. clicked_color .. ".png")
                if texture then
                    texture_name = "wire_" .. selected_color .. "_" .. clicked_color .. ".png"
                else
                    texture = getTexture("media/textures/wire/wire_" .. clicked_color .. "_" .. selected_color .. ".png")
                    if texture then
                        texture_name = "wire_" .. clicked_color .. "_" .. selected_color .. ".png"
                    else
                        texture_name = "wire_" .. selected_color .. "_" .. clicked_color .. ".png" -- Для лога ошибки
                    end
                end

                local comboWire = BetLock_CombinationWire:new(selected_color, clicked_color, self.originalX, self.parent, texture_name)
                if comboWire then
                    self.parent:addChild(comboWire)
                    self.parent:wireConnected(selected_color, clicked_color)
                    self.parent:removeChild(self.parent.selectedWire)
                    self.parent:removeChild(self)
                    self.parent.selectedWire = nil
                else
                    print("Error: Failed to create CombinationWire for " .. selected_color .. " and " .. clicked_color)
                end
            end
        end
    end
    return true
end

-- Класс для комбинированных проводов
BetLock_CombinationWire = ISWire:derive("BetLock_CombinationWire")
function BetLock_CombinationWire:new(color1, color2, x, parent, texture_name)
    local texture = getTexture("media/textures/wire/" .. texture_name)
    if not texture then
        print("Error: Texture not found for " .. texture_name)
        texture = getTexture("media/ui/MissingTexture.png")
        if not texture then
            print("Critical: No texture available for " .. texture_name .. ". Skipping creation.")
            return nil
        end
    end
    local width = texture:getWidth()
    local height = texture:getHeight()
    local o = ISWire.new(self, x, field_height - height, width, height)
    o.color1 = color1
    o.color2 = color2
    o.parent = parent
    o.texture = texture
    o.originalX = x -- Сохраняем исходную позицию комбинированного провода
    return o
end

function BetLock_CombinationWire:onMouseDown(x, y)
    self.parent:removeChild(self)
    local downWire1 = BetLock_DownWire:new(self.color1, self.parent.shuffledPositions[self.color1], self.parent)
    local downWire2 = BetLock_DownWire:new(self.color2, self.parent.shuffledPositions[self.color2], self.parent)
    if downWire1 and downWire2 then
        self.parent:addChild(downWire1)
        self.parent:addChild(downWire2)
        self.parent:wireDisconnected(self.color1, self.color2)
    else
        print("Error: Failed to create DownWire for " .. self.color1 .. " or " .. self.color2)
    end
    return true
end

-- Функция добавления проводов
function BetLock.Wires.addWires(parent, difficultyLevel, windowWidth)
    -- Теперь используем уже сгенерированный и сохранённый config
    local selectedWires = parent.selectedWires
    if not selectedWires then
        print("ERROR: HotwireConfig not loaded!")
        return
    end

    for color, pos in pairs(selectedWires) do
        local bigWire = BetLock_BigWire:new(color, pos, parent)
        if bigWire then
            parent:addChild(bigWire)
        end
    end

    parent.shuffledPositions = selectedWires
end