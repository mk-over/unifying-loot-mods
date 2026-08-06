HotwireWindow = ISPanel:derive("HotwireWindow")

local WINDOW_WIDTHS = {
    [4] = 270,  -- 4 провода
    [6] = 390,  -- 6 проводов
    [8] = 510   -- 8 проводов
}
local WINDOW_HEIGHT = 284
local pendingHotwireVehicleId = nil

-- Функция для перемешивания таблицы
local function shuffleTable(t)
    local n = #t
    for i = n, 2, -1 do
        local j = ZombRand(i) + 1
        t[i], t[j] = t[j], t[i]
    end
    return t
end

BetLock.Hotwire = BetLock.Hotwire or {}

--function BetLock.Hotwire.generateHotwireConfig(vehicle, difficultyLevel, numWires, useFourWires, windowWidth)
--    local modData = vehicle:getModData()
--    
--    if not modData.HotwireConfig then
--        print("=== GENERATING NEW HotwireConfig for vehicle " .. tostring(vehicle:getId()) .. " (KeyID: " .. tostring(vehicle:getKeyId()) .. ") ===")
--        
--        modData.HotwireConfig = {}
--        local wire_colors = {"red", "blue", "green", "yellow", "orange", "purple", "white", "black"}
--        
--        -- 1. Цвета + позиции (детерминировано)
--        local shuffled_colors = shuffleTable({unpack(wire_colors)})
--        local margin = 20
--        local availableWidth = windowWidth - 2 * margin
--        local wireSpacing = (numWires > 1) and (availableWidth / (numWires - 1)) or availableWidth
--        local positions = {}
--        for i = 0, numWires - 1 do
--            table.insert(positions, margin + i * wireSpacing)
--        end
--        shuffleTable(positions)
--        
--        local selectedWires = {}
--        local shuffledPositions = {}
--        for i = 1, numWires do
--            local color = shuffled_colors[i]
--            selectedWires[color] = positions[i]
--            shuffledPositions[color] = positions[i]
--        end
--        
--        modData.HotwireConfig.selectedWires = selectedWires
--        modData.HotwireConfig.shuffledPositions = shuffledPositions
--        
--        -- 2. Правильные провода — ТОЛЬКО из тех цветов, что реально в окне!
--        local availableColors = {}
--        for color in pairs(selectedWires) do
--            table.insert(availableColors, color)
--        end
--        local correctList = shuffleTable(availableColors)  -- ← ИСПРАВЛЕНИЕ ЗДЕСЬ
--        
--        if useFourWires then
--            modData.HotwireConfig.firstWire  = correctList[1]
--            modData.HotwireConfig.secondWire = correctList[2]
--            modData.HotwireConfig.thirdWire  = correctList[3]
--            modData.HotwireConfig.fourthWire = correctList[4]
--            print("Correct pairs (4 wires): " .. correctList[1] .. "-" .. correctList[2] .. " + " .. correctList[3] .. "-" .. correctList[4])
--        else
--            modData.HotwireConfig.firstWire  = correctList[1]
--            modData.HotwireConfig.secondWire = correctList[2]
--            print("Correct pair (2 wires): " .. correctList[1] .. "-" .. correctList[2])
--        end
--        
--        -- 3. События на ВСЕ неправильные провода (100%)
--        local allEvents = {
--            {name = "Headlights", command = "setHeadlightsOn", args = { vehicle = vehicle:getId(), on = true }},
--            {name = "Heater", command = "toggleHeater", args = { vehicle = vehicle:getId(), on = true, temp = 1.0 }},
--            {name = "Horn", command = "onHorn", args = { vehicle = vehicle:getId(), state = "start" }},
--            {name = "Flash", command = "setHeadlightsOn", args = { vehicle = vehicle:getId(), on = true }},
--            {name = "TurnOffHeadlights", command = "setHeadlightsOn", args = { vehicle = vehicle:getId(), on = false }},
--            {name = "TurnOffHeater", command = "toggleHeater", args = { vehicle = vehicle:getId(), on = false, temp = 0.0 }}
--        }
--        if vehicle:getPartById("lightbar") then
--            table.insert(allEvents, {name = "LightbarLights", command = "setLightbarLightsMode", args = { vehicle = vehicle:getId(), mode = 1 }})
--            table.insert(allEvents, {name = "LightbarSiren", command = "setLightbarSirenMode", args = { vehicle = vehicle:getId(), mode = 1 }})
--        end
--        if vehicle:getPartById("Radio") then
--            table.insert(allEvents, {name = "RadioOn", command = "dummy", args = { vehicle = vehicle:getId() }})
--            table.insert(allEvents, {name = "RadioOff", command = "dummy", args = { vehicle = vehicle:getId() }})
--        end
--        
--        shuffleTable(allEvents)
--        
--        local incorrectWires = {}
--        for color in pairs(selectedWires) do
--            local isCorrect = false
--            if useFourWires then
--                if color == modData.HotwireConfig.firstWire or color == modData.HotwireConfig.secondWire or
--                   color == modData.HotwireConfig.thirdWire or color == modData.HotwireConfig.fourthWire then
--                    isCorrect = true
--                end
--            else
--                if color == modData.HotwireConfig.firstWire or color == modData.HotwireConfig.secondWire then
--                    isCorrect = true
--                end
--            end
--            if not isCorrect then table.insert(incorrectWires, color) end
--        end
--        
--        local wireEvents = {}
--        for i, wire in ipairs(incorrectWires) do
--            local eventIndex = ((i-1) % #allEvents) + 1
--            wireEvents[wire] = allEvents[eventIndex]
--            print("Wire " .. wire .. " assigned event: " .. allEvents[eventIndex].name)
--        end
--        
--        modData.HotwireConfig.wireEvents = wireEvents
--        modData.HotwireConfig.numWires = numWires
--        modData.HotwireConfig.useFourWires = useFourWires
--    end
--    
--    return modData.HotwireConfig
--end
-- ============================================================

function HotwireWindow:setVisible(visible)
    self.javaObject:setVisible(visible)
end

function HotwireWindow:prerender()
    ISPanel.prerender(self)
end

function HotwireWindow:render()
    local titleText = self.useFourWires and getText("UI_Controls_Hotwire_Hard") or getText("UI_Controls_Hotwire")
    self:drawText(titleText, self.width/2 - (getTextManager():MeasureStringX(UIFont.Small, titleText) / 2), 10, 1,1,1,1, UIFont.Small)
    self:drawRectBorder(0, 30, self.width, WINDOW_HEIGHT-60, 1, 0.4, 0.4, 0.4)
    if self.character:getVehicle() == nil then
        self:close()
    end
end

function HotwireWindow:onOptionMouseDown(button, x, y)
    if button.internal == "CANCEL" then
        self:setVisible(false)
        self:removeFromUIManager()
        self:close()
    end
end

function HotwireWindow:wireConnected(first, second)
    if not self.connectedPairs then
        self.connectedPairs = {}
    end
    table.insert(self.connectedPairs, {first = first, second = second})
    print("Connected pair: " .. first .. "-" .. second)

    local vehicle = self.character:getVehicle()
    if not vehicle then
        print("No vehicle detected, closing hotwire window.")
        self:close()
        return
    end

    local triggeredEvents = {}
    local firstEvent = self.wireEvents[first]
    local secondEvent = self.wireEvents[second]

    local cancelEvents = false
    if firstEvent and secondEvent then
        if (firstEvent.name == "Headlights" and secondEvent.name == "TurnOffHeadlights") or
           (firstEvent.name == "TurnOffHeadlights" and secondEvent.name == "Headlights") or
           (firstEvent.name == "Heater" and secondEvent.name == "TurnOffHeater") or
           (firstEvent.name == "TurnOffHeater" and secondEvent.name == "Heater") then
            print("Opposite events detected, canceling: " .. firstEvent.name .. " and " .. secondEvent.name)
            cancelEvents = true
        end
    end

    local radioPair = false
    if firstEvent and secondEvent then
        if (firstEvent.name == "RadioOn" and secondEvent.name == "RadioOff") or
           (firstEvent.name == "RadioOff" and secondEvent.name == "RadioOn") then
            radioPair = true
            return
        end
    end

    local lightbarPair = false
    if firstEvent and secondEvent and not cancelEvents then
        if (firstEvent.name == "LightbarLights" and secondEvent.name == "LightbarSiren") or
           (firstEvent.name == "LightbarSiren" and secondEvent.name == "LightbarLights") then
            lightbarPair = true
            local mode1 = ZombRand(1, 4)
            local mode2 = ZombRand(1, 4)
            local firstArgs = { vehicle = vehicle:getId(), mode = mode1 }
            local secondArgs = { vehicle = vehicle:getId(), mode = mode2 }
            sendClientCommand(self.character, "vehicle", firstEvent.command, firstArgs)
            sendClientCommand(self.character, "vehicle", secondEvent.command, secondArgs)
            print("Triggering event for wire " .. first .. ": " .. firstEvent.name .. " (mode " .. mode1 .. ")")
            print("Triggering event for wire " .. second .. ": " .. secondEvent.name .. " (mode " .. mode2 .. ")")
            table.insert(triggeredEvents, firstEvent.name)
            table.insert(triggeredEvents, secondEvent.name)

            local timer = getGameTime():getModData()
            timer.lightbarTimer = timer.lightbarTimer or {}
            timer.lightbarTimer[vehicle:getId()] = { time = 2.0, vehicle = vehicle:getId(), both = true }
        end
    end

    if not cancelEvents and not lightbarPair and not radioPair then
        for _, wire in ipairs({first, second}) do
            if self.wireEvents[wire] then
                local event = self.wireEvents[wire]
                local eventArgs = {}
                for k, v in pairs(event.args) do
                    eventArgs[k] = v
                end

                if event.name == "Heater" then
                    local tempOptions = {-25, -15, -8, 0, 8, 15, 25}
                    eventArgs.temp = tempOptions[ZombRand(#tempOptions) + 1]
                    print("Triggering event for wire " .. wire .. ": " .. event.name .. " (temp " .. eventArgs.temp .. ")")
                elseif event.name == "TurnOffHeater" then
                    eventArgs.temp = 0
                    print("Triggering event for wire " .. wire .. ": " .. event.name .. " (temp " .. eventArgs.temp .. ")")
                elseif event.name == "LightbarLights" or event.name == "LightbarSiren" then
                    eventArgs.mode = ZombRand(1, 4)
                    print("Triggering event for wire " .. wire .. ": " .. event.name .. " (mode " .. eventArgs.mode .. ")")
                elseif event.name == "RadioOn" then
                    local radioPart = vehicle:getPartById("Radio")
                    if radioPart and radioPart:getDeviceData() then
                        local deviceData = radioPart:getDeviceData()
                        deviceData:setIsTurnedOn(true)
                        print("Triggering event for wire " .. wire .. ": " .. event.name .. " (channel " .. deviceData:getChannel() .. ")")
                    else
                        print("No radio found in vehicle " .. vehicle:getId())
                    end
                elseif event.name == "RadioOff" then
                    local radioPart = vehicle:getPartById("Radio")
                    if radioPart and radioPart:getDeviceData() then
                        local deviceData = radioPart:getDeviceData()
                        deviceData:setIsTurnedOn(false)
                        print("Triggering event for wire " .. wire .. ": " .. event.name .. " (channel " .. deviceData:getChannel() .. ")")
                    else
                        print("No radio found in vehicle " .. vehicle:getId())
                    end
                elseif event.name == "Horn" then
                    eventArgs.state = "start"
                    print("Triggering event for wire " .. wire .. ": " .. event.name .. " (continuous)")
                else
                    print("Triggering event for wire " .. wire .. ": " .. event.name)
                end

                if event.name ~= "RadioOn" and event.name ~= "RadioOff" then
                    sendClientCommand(self.character, "vehicle", event.command, eventArgs)
                end
                table.insert(triggeredEvents, event.name)

                if event.name == "Flash" then
                    local timer = getGameTime():getModData()
                    timer.flashTimer = timer.flashTimer or {}
                    timer.flashTimer[vehicle:getId()] = { totalTime = 3.0, interval = 0.5, time = 0.5, vehicle = vehicle:getId(), state = true }
                elseif event.name == "LightbarLights" or event.name == "LightbarSiren" then
                    local timer = getGameTime():getModData()
                    timer.lightbarTimer = timer.lightbarTimer or {}
                    timer.lightbarTimer[vehicle:getId()] = { time = 2.0, vehicle = vehicle:getId(), eventName = event.name }
                end
            end
        end
    end

    if #triggeredEvents == 0 and not radioPair then
        print("No events triggered for this pair")
    end

    -- Проверка для очень сложного режима (useFourWires)
    if self.useFourWires then
        local pair1Connected = false
        local pair2Connected = false
        for _, pair in ipairs(self.connectedPairs) do
            local pFirst = pair.first
            local pSecond = pair.second
            -- Проверяем первую правильную пару (firstWire-secondWire)
            if (pFirst == self.firstWire and pSecond == self.secondWire) or
               (pFirst == self.secondWire and pSecond == self.firstWire) then
                pair1Connected = true
            end
            -- Проверяем вторую правильную пару (thirdWire-fourthWire)
            if (pFirst == self.thirdWire and pSecond == self.fourthWire) or
               (pFirst == self.fourthWire and pSecond == self.thirdWire) then
                pair2Connected = true
            end
        end
        if pair1Connected and pair2Connected then
            print("Correct pairs matched: " .. self.firstWire .. "-" .. self.secondWire .. " and " .. self.thirdWire .. "-" .. self.fourthWire .. "! Hotwiring vehicle.")
            sendClientCommand(self.character, "BetLockHotwire", "hotwire", { vehicle = vehicle:getId() })
            self:close()
        end
    else
        -- Логика для обычного режима (2 провода)
        local wireColors = {"red", "blue", "green", "yellow", "orange", "purple", "white", "black"}
        if (first == self.firstWire and second == self.secondWire) or
           (first == self.secondWire and second == self.firstWire) then
            print("Correct pair matched for 2 wires! Hotwiring vehicle.")
            sendClientCommand(self.character, "BetLockHotwire", "hotwire", { vehicle = vehicle:getId() })
            self:close()
        end
    end
end

function HotwireWindow:wireDisconnected(first, second)
    if not self.connectedPairs then return end
    for i, pair in ipairs(self.connectedPairs) do
        if (pair.first == first and pair.second == second) or
           (pair.first == second and pair.second == first) then
            table.remove(self.connectedPairs, i)
            print("Disconnected pair: " .. first .. "-" .. second)
            
            local vehicle = self.character:getVehicle()
            if vehicle then
                if self.wireEvents[first] and self.wireEvents[first].name == "Horn" then
                    sendClientCommand(self.character, "vehicle", "onHorn", { vehicle = vehicle:getId(), state = "stop" })
                    print("Horn stopped for wire " .. first)
                elseif self.wireEvents[second] and self.wireEvents[second].name == "Horn" then
                    sendClientCommand(self.character, "vehicle", "onHorn", { vehicle = vehicle:getId(), state = "stop" })
                    print("Horn stopped for wire " .. second)
                end
            end
            break
        end
    end
end

function HotwireWindow:close()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound)
    end
    ISPanel.close(self)
end

function HotwireWindow:createWindow(playerObj)
    local vehicle = playerObj:getVehicle()
    if not vehicle then return end

    -- Проверка аккумулятора
    local batteryPart = vehicle:getPartById("Battery")
    if not batteryPart or not batteryPart:getInventoryItem() then
        playerObj:Say(getText("UI_NoElectricity"))
        print("Hotwire attempt failed: No battery found in vehicle " .. tostring(vehicle:getId()))
        return
    end
    
    -- Проверка заряда аккумулятора
    local batteryCharge = vehicle:getBatteryCharge()
    if batteryCharge <= 0 then
        playerObj:Say(getText("UI_NoElectricity"))
		print("Battery charge level: " .. tostring(batteryCharge) .. " in vehicle " .. tostring(vehicle:getId()))
        print("Hotwire attempt failed: Battery is dead in vehicle " .. tostring(vehicle:getId()))
        return
    end

    --if vehicle:getModData().HotwireLevel == nil then
    --    vehicle:getModData().HotwireLevel = BetLock.Utils.getHotwireLevelVehicle(vehicle)
    --end
    --local difficulty = vehicle:getModData().HotwireLevel
    --local difficultyLevel = difficulty.num
    --print("Difficulty Level: " .. difficultyLevel .. ", Num Wires: " .. (difficultyLevel <= 1 and 4 or (difficultyLevel <= 3 and 6 or 8)))
	--
    --local numWires
    --local useFourWires
    --if difficultyLevel == 2 then
    --    numWires = 4
    --    useFourWires = false
    --elseif difficultyLevel == 4 then
    --    numWires = 6
    --    useFourWires = false
    --elseif difficultyLevel == 6 then
    --    numWires = 8
    --    useFourWires = false
    --else
    --    numWires = 8
    --    useFourWires = true
    --end
	--
    --local modal = HotwireWindow:new(Core:getInstance():getScreenWidth()/2 - WINDOW_WIDTHS[numWires]/2 + 400, 
    --                               Core:getInstance():getScreenHeight()/2 - WINDOW_HEIGHT/2, 
    --                               WINDOW_WIDTHS[numWires], WINDOW_HEIGHT)
    --modal.character = playerObj
    --modal.useFourWires = useFourWires
	--
    ---- === ГЕНЕРАЦИЯ/ЗАГРУЗКА КОНФИГА ПО KEYID ===
    --local config = BetLock.Hotwire.generateHotwireConfig(vehicle, difficultyLevel, numWires, useFourWires, WINDOW_WIDTHS[numWires])
    --
    --modal.selectedWires = config.selectedWires
    --modal.shuffledPositions = config.shuffledPositions
    --modal.firstWire = config.firstWire
    --modal.secondWire = config.secondWire
    --if useFourWires then
    --    modal.thirdWire = config.thirdWire
    --    modal.fourthWire = config.fourthWire
    --end
    --modal.wireEvents = config.wireEvents
	--
    --modal:initialise(difficultyLevel, WINDOW_WIDTHS[numWires])
    --modal.sound = modal.character:playSoundLocal("VehicleHotwireStart")
    --modal:addToUIManager()
	if vehicle:getModData().HotwireLevel == nil then
        vehicle:getModData().HotwireLevel = BetLock.Utils.getHotwireLevelVehicle(vehicle)
    end
    local difficulty = vehicle:getModData().HotwireLevel
    local difficultyLevel = difficulty.num

    local numWires
    local useFourWires
    if difficultyLevel == 2 then
        numWires = 4; useFourWires = false
    elseif difficultyLevel == 4 then
        numWires = 6; useFourWires = false
    elseif difficultyLevel == 6 then
        numWires = 8; useFourWires = false
    else
        numWires = 8; useFourWires = true
    end

	-- Запрос конфига
    sendClientCommand(playerObj, "BetLockHotwire", "requestHotwireConfig", {
        vehicleId      = vehicle:getId(),
        difficultyLevel = difficultyLevel,
        numWires       = numWires,
        useFourWires   = useFourWires,
        windowWidth    = WINDOW_WIDTHS[numWires]
    })

    pendingHotwireVehicleId = vehicle:getId()
    print("[BetLock] Requested HotwireConfig & waiting for modData sync on vehicle " .. vehicle:getId())
end

function HotwireWindow:initialise(difficultyLevel, windowWidth)
    ISPanel.initialise(self)
    self.cancel = ISButton:new((self:getWidth() / 2) - 50, self:getHeight() - 25, 100, 20, getText("UI_Cancel"), self, HotwireWindow.onOptionMouseDown)
    self.cancel.internal = "CANCEL"
    self.cancel:initialise()
    self.cancel:instantiate()
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.cancel)
    BetLock.Wires.addWires(self, difficultyLevel, windowWidth)
end

function HotwireWindow:new(x, y, width, height)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.variableColor = {r=0.9, g=0.55, b=0.1, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.zOffsetSmallFont = 25
    o.moveWithMouse = true
    o.selectedWires = {}
    o.connectedPairs = {}
    o:setWantKeyEvents(true)
    return o
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function table.size(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

Events.OnTick.Add(function()
    local timer = getGameTime():getModData()
    
    if timer.flashTimer then
        for vehicleId, data in pairs(timer.flashTimer) do
            data.totalTime = data.totalTime - (getGameTime():getMultiplier() / 60)
            data.time = data.time - (getGameTime():getMultiplier() / 60)
            if data.time <= 0 then
                local player = getSpecificPlayer(0)
                if player then
                    data.state = not data.state
                    sendClientCommand(player, "vehicle", "setHeadlightsOn", { vehicle = data.vehicle, on = data.state })
                    sendClientCommand(player, "vehicle", "setStoplightsOn", { vehicle = data.vehicle, on = data.state })
                    print("Flash toggled headlights and stoplights to " .. tostring(data.state) .. " for vehicle " .. data.vehicle)
                    data.time = data.interval
                end
            end
            if data.totalTime <= 0 then
                local player = getSpecificPlayer(0)
                if player then
                    sendClientCommand(player, "vehicle", "setHeadlightsOn", { vehicle = data.vehicle, on = false })
                    sendClientCommand(player, "vehicle", "setStoplightsOn", { vehicle = data.vehicle, on = false })
                    print("Flash completed, headlights and stoplights off for vehicle " .. data.vehicle)
                end
                timer.flashTimer[vehicleId] = nil
            end
        end
    end
    
    if timer.lightbarTimer then
        for vehicleId, data in pairs(timer.lightbarTimer) do
            data.time = data.time - (getGameTime():getMultiplier() / 60)
            if data.time <= 0 then
                local player = getSpecificPlayer(0)
                if player then
                    if data.both then
                        sendClientCommand(player, "vehicle", "setLightbarLightsMode", { vehicle = data.vehicle, mode = 0 })
                        sendClientCommand(player, "vehicle", "setLightbarSirenMode", { vehicle = data.vehicle, mode = 0 })
                        print("Lightbar lights and siren stopped for vehicle " .. data.vehicle)
                    elseif data.eventName == "LightbarLights" then
                        sendClientCommand(player, "vehicle", "setLightbarLightsMode", { vehicle = data.vehicle, mode = 0 })
                        print("Lightbar lights stopped for vehicle " .. data.vehicle)
                    elseif data.eventName == "LightbarSiren" then
                        sendClientCommand(player, "vehicle", "setLightbarSirenMode", { vehicle = data.vehicle, mode = 0 })
                        print("Lightbar siren stopped for vehicle " .. data.vehicle)
                    end
                end
                timer.lightbarTimer[vehicleId] = nil
            end
        end
    end
end)

local function checkHotwireConfigSync()
    if not pendingHotwireVehicleId then return end

    local vehicle = getVehicleById(pendingHotwireVehicleId)
    if not vehicle then 
        print("[BetLock] Vehicle lost while waiting for config")
        pendingHotwireVehicleId = nil
        return 
    end

    local config = vehicle:getModData().HotwireConfig
    if config then
        print("[BetLock] HotwireConfig received via modData sync for vehicle " .. pendingHotwireVehicleId)

        local numWires = config.numWires or 8
        local difficultyLevel = config.difficultyLevel or 1

        local modal = HotwireWindow:new(
            Core:getInstance():getScreenWidth()/2 - WINDOW_WIDTHS[numWires]/2 + 400,
            Core:getInstance():getScreenHeight()/2 - WINDOW_HEIGHT/2,
            WINDOW_WIDTHS[numWires],
            WINDOW_HEIGHT
        )

        modal.character         = getPlayer()
        modal.useFourWires      = config.useFourWires
        modal.selectedWires     = config.selectedWires
        modal.shuffledPositions = config.shuffledPositions
        modal.firstWire         = config.firstWire
        modal.secondWire        = config.secondWire
        if modal.useFourWires then
            modal.thirdWire  = config.thirdWire
            modal.fourthWire = config.fourthWire
        end
        modal.wireEvents = config.wireEvents

        modal:initialise(difficultyLevel, WINDOW_WIDTHS[numWires])
        modal.sound = modal.character:playSoundLocal("VehicleHotwireStart")
        modal:addToUIManager()

        print("[BetLock] Hotwire window CREATED from modData sync!")
        pendingHotwireVehicleId = nil  -- Сбрасываем, чтобы не спамило
    end
end

Events.OnTick.Add(checkHotwireConfigSync)