
local function crowbarCommands(module, command, _player, args)
    if module == "crowbar" and command == "vehicleDoor" then
        local vehicle = getVehicleById(args.vehicle)
        if not vehicle then return end

        local part = vehicle:getPartById(args.part)
        if not part then return end

        if not part:getDoor() then return end

        part:getDoor():setLocked(false)
        part:getDoor():setLockBroken(true)

        vehicle:transmitPartDoor(part)
	elseif module == "crowbar" and command == "applyDrain" then
        if not _player then 
		print("Player not found")
		return end
	    
        -- Снимаем стамину (сервер authoritative!)
        local stats = _player:getStats()
        local current = stats:get(CharacterStat.ENDURANCE)
		--stats:set(CharacterStat.ENDURANCE, endurance - (zReFIT_1 - zReLPFIT)/200)
        stats:set(CharacterStat.ENDURANCE, (math.max(0, current - (args.enduranceDrain or 0))))
	    
        -- Muscle strain на руки
        local bd = _player:getBodyDamage()
        local add = args.stiffnessAdd or 0
        if add > 0 then
            local parts = {
                BodyPartType.UpperArm_L,
                BodyPartType.UpperArm_R,
                BodyPartType.ForeArm_L,
                BodyPartType.ForeArm_R
            }
            for _, p in ipairs(parts) do
                local part = bd:getBodyPart(p)
                part:setStiffness(part:getStiffness() + add)
            end
        end
    end
end
Events.OnClientCommand.Add(crowbarCommands)

--local function hotwireCommands(module, command, _player, args)
--    if module ~= "BetLockHotwire" then return end
--
--    if command == "hotwire" then
--        local vehicle = getVehicleById(args.vehicle)
--        if not vehicle then return end
--        vehicle:cheatHotwire(true, false)
--    elseif command == "unhotwire" then
--        local vehicle = getVehicleById(args.vehicle)
--        if not vehicle then return end
--        vehicle:cheatHotwire(false, false)
--    end
--end
--Events.OnClientCommand.Add(hotwireCommands)

local function screwdriverCommands(module, command, _player, args)
    if module == "screwdriver" and command == "vehicleDoor" then
        local vehicle = getVehicleById(args.vehicle)
        if not vehicle then return end

        local part = vehicle:getPartById(args.part)
        if not part then return end

        if not part:getDoor() then return end

        part:getDoor():setLocked(false)

        vehicle:transmitPartDoor(part)
    end
end
Events.OnClientCommand.Add(screwdriverCommands)

local function betLockCommands(module, command, _player, args)
    if module ~= "BetLock" then return end

    if command == "unlockBuildingDoor" then
        local sq = getCell():getGridSquare(args.x, args.y, args.z)
        if not sq then
            return
        end
        local objects = sq:getObjects()
        if not objects then
            return
        end
        local found = false
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            if obj then
                local objKeyId = obj:getKeyId()
                if objKeyId ~= nil and tonumber(args.keyId) ~= nil and objKeyId == tonumber(args.keyId) then
                    found = true
                    obj:setLockedByKey(false)
                    -- Handle garage door chain
                    if IsoDoor.getGarageDoorIndex(obj) ~= -1 then
                        local doorPrev = IsoDoor.getGarageDoorPrev(obj)
                        while doorPrev ~= nil do
                            doorPrev:setLockedByKey(false)
                            doorPrev = IsoDoor.getGarageDoorPrev(doorPrev)
                        end
                        local doorNext = IsoDoor.getGarageDoorNext(obj)
                        while doorNext ~= nil do
                            doorNext:setLockedByKey(false)
                            doorNext = IsoDoor.getGarageDoorNext(doorNext)
                        end
                    end
                    if args.crowbar then
                        obj:setKeyId(-3)
                        obj:Damage(50)
                    end
                    break
                end
            end
        end
        if not found then
        end
    elseif command == "addLockpickingXP" then
        if _player then
            local perk = Perks.Lockpicking
            local amount = tonumber(args.amount) or 0
            print("[BetLock][SERVER] addLockpickingXP | player=" .. tostring(_player:getUsername()) .. " | amount=" .. tostring(amount) .. " | perk=" .. tostring(perk))
            if perk and amount > 0 then
                addXp(_player, perk, amount)
                print("[BetLock][SERVER] addXp called | new level=" .. tostring(_player:getPerkLevel(perk)))
                sendServerCommand(_player, "BetLock", "xpGranted", {amount = amount})
            else
                print("[BetLock][SERVER] addXp SKIPPED | perk nil=" .. tostring(perk == nil) .. " | amount valid=" .. tostring(amount > 0))
            end
        else
            print("[BetLock][SERVER] addLockpickingXP | _player is nil")
        end
    end
end
Events.OnClientCommand.Add(betLockCommands)
