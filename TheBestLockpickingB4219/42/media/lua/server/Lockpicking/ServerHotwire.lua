local function shuffleTable(t)
    local n = #t
    for i = n, 2, -1 do
        local j = ZombRand(i) + 1
        t[i], t[j] = t[j], t[i]
    end
    return t
end

BetLock = BetLock or {}
BetLock.Hotwire = BetLock.Hotwire or {}

function BetLock.Hotwire.generateHotwireConfig(vehicle, difficultyLevel, numWires, useFourWires, windowWidth)
    local modData = vehicle:getModData()
    
    if not modData.HotwireConfig then
        print("=== [SERVER] GENERATING NEW HotwireConfig for vehicle " .. tostring(vehicle:getId()) .. " ===")
        
        modData.HotwireConfig = {}
        local wire_colors = {"red", "blue", "green", "yellow", "orange", "purple", "white", "black"}
        
        local shuffled_colors = shuffleTable({unpack(wire_colors)})
        local margin = 20
        local availableWidth = windowWidth - 2 * margin
        local wireSpacing = (numWires > 1) and (availableWidth / (numWires - 1)) or availableWidth
        local positions = {}
        for i = 0, numWires - 1 do
            table.insert(positions, margin + i * wireSpacing)
        end
        shuffleTable(positions)
        
        local selectedWires = {}
        for i = 1, numWires do
            local color = shuffled_colors[i]
            selectedWires[color] = positions[i]
        end
        
        modData.HotwireConfig.selectedWires = selectedWires
        modData.HotwireConfig.shuffledPositions = selectedWires  -- копия для совместимости
        
        -- Правильные провода
        local availableColors = {}
        for color in pairs(selectedWires) do table.insert(availableColors, color) end
        local correctList = shuffleTable(availableColors)
        
        if useFourWires then
            modData.HotwireConfig.firstWire  = correctList[1]
            modData.HotwireConfig.secondWire = correctList[2]
            modData.HotwireConfig.thirdWire  = correctList[3]
            modData.HotwireConfig.fourthWire = correctList[4]
        else
            modData.HotwireConfig.firstWire  = correctList[1]
            modData.HotwireConfig.secondWire = correctList[2]
        end
        
        -- Ивенты на неправильные провода
        local allEvents = {
            {name = "Headlights", command = "setHeadlightsOn", args = { vehicle = vehicle:getId(), on = true }},
            {name = "Heater", command = "toggleHeater", args = { vehicle = vehicle:getId(), on = true, temp = 1.0 }},
            {name = "Horn", command = "onHorn", args = { vehicle = vehicle:getId(), state = "start" }},
            {name = "Flash", command = "setHeadlightsOn", args = { vehicle = vehicle:getId(), on = true }},
            {name = "TurnOffHeadlights", command = "setHeadlightsOn", args = { vehicle = vehicle:getId(), on = false }},
            {name = "TurnOffHeater", command = "toggleHeater", args = { vehicle = vehicle:getId(), on = false, temp = 0.0 }}
        }
        if vehicle:getPartById("lightbar") then
            table.insert(allEvents, {name = "LightbarLights", command = "setLightbarLightsMode", args = { vehicle = vehicle:getId(), mode = 1 }})
            table.insert(allEvents, {name = "LightbarSiren", command = "setLightbarSirenMode", args = { vehicle = vehicle:getId(), mode = 1 }})
        end
        if vehicle:getPartById("Radio") then
            table.insert(allEvents, {name = "RadioOn", command = "dummy", args = { vehicle = vehicle:getId() }})
            table.insert(allEvents, {name = "RadioOff", command = "dummy", args = { vehicle = vehicle:getId() }})
        end
        shuffleTable(allEvents)
        
        local incorrectWires = {}
        for color in pairs(selectedWires) do
            local isCorrect = false
            if useFourWires then
                if color == modData.HotwireConfig.firstWire or color == modData.HotwireConfig.secondWire or
                   color == modData.HotwireConfig.thirdWire or color == modData.HotwireConfig.fourthWire then
                    isCorrect = true
                end
            else
                if color == modData.HotwireConfig.firstWire or color == modData.HotwireConfig.secondWire then
                    isCorrect = true
                end
            end
            if not isCorrect then table.insert(incorrectWires, color) end
        end
        
        local wireEvents = {}
        for i, wire in ipairs(incorrectWires) do
            local eventIndex = ((i-1) % #allEvents) + 1
            wireEvents[wire] = allEvents[eventIndex]
        end
        
        modData.HotwireConfig.wireEvents = wireEvents
        modData.HotwireConfig.numWires = numWires
        modData.HotwireConfig.useFourWires = useFourWires
		modData.HotwireConfig.difficultyLevel = difficultyLevel
		modData.HotwireConfig.windowWidth = windowWidth
    end
    
    return modData.HotwireConfig
end

-- ====================== ОБРАБОТКА КОМАНД ======================
local function hotwireCommands(module, command, player, args)
    if module ~= "BetLockHotwire" then return end

    if command == "hotwire" then
        local vehicle = getVehicleById(args.vehicle)
        if vehicle then vehicle:cheatHotwire(true, false) end

    elseif command == "unhotwire" then
        local vehicle = getVehicleById(args.vehicle)
        if vehicle then vehicle:cheatHotwire(false, false) end

    elseif command == "requestHotwireConfig" then
        if not args.vehicleId then return end
        local vehicle = getVehicleById(args.vehicleId)
        if not vehicle then return end

        local config = BetLock.Hotwire.generateHotwireConfig(
            vehicle,
            args.difficultyLevel,
            args.numWires,
            args.useFourWires,
            args.windowWidth
        )

        -- Синхронизируем modData всем клиентам
        vehicle:transmitModData()

        print("[BetLock] HotwireConfig generated & transmitted via modData for vehicle " .. args.vehicleId)
    end
end

Events.OnClientCommand.Add(hotwireCommands)