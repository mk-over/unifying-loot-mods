if BetLock == nil then BetLock = {} end
if BetLock.UI == nil then BetLock.UI = {} end

local LockpickingManager = require "Lockpicking/LockpickingManager"

-- ПРОВЕРКА ПРОЧНОСТИ ПРЕДМЕТА, ВОЗВРАЩАЕТ "-" ЕСЛИ СЛОМАНО
local function predicateNotBroken(item)
    return not item:isBroken();
end

local function isBurglarProfession(playerObj)
    local desc = playerObj:getDescriptor()
    if desc then
        local prof = desc:getCharacterProfession()
        if prof then
            local ok, name = pcall(function() return prof:getName() end)
            if ok and name == "burglar" then return true end
        end
    end
    -- Hotwire unlock for high Mechanics + Electricity (non-Burglar)
    local mech = playerObj:getPerkLevel(Perks.Mechanics)
    local elec = playerObj:getPerkLevel(Perks.Electricity)
    return elec >= 1 and mech >= 2
end

-- Функция для снятия горячей проводки
function BetLock.UI.onUnHotwire(playerObj)
    ISTimedActionQueue.add(ISUnHotwire:new(playerObj));
end

-- ДОБАВЛЕНИЕ ОПЦИЙ В РАДИАЛЬНОЕ МЕНЮ (ВНЕ МАШИНЫ)
function BetLock.UI.addOutsideOptions(playerObj)
    --local endurance = playerObj:getStats():getEndurance()
	local endurance = playerObj:getStats():get(CharacterStat.ENDURANCE)
    local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
    if menu == nil then return end

    local vehicle = playerObj:getUseableVehicle()
    if vehicle == nil then return end

    local part = vehicle:getUseablePart(playerObj)
    if part and part:getDoor() then
        if part:getDoor():isLocked() then
            if vehicle:getModData().LockpickLevel == nil then
                vehicle:getModData().LockpickLevel = BetLock.Utils.getLockpickingLevelVehicle(vehicle)
            end

            -- ОПЦИЯ ВЗЛОМА МОНТИРОВКОЙ
            if not SandboxVars.TheBestLockpicking.DisableCrowbar then
                local inv = playerObj:getInventory()
                local crowbar = inv:getFirstTagEvalRecurse(ItemTag.CROWBAR, predicateNotBroken)
                if not crowbar then
                    menu:addSlice(getText("ContextMenu_Require", getItemNameFromFullType("Base.Crowbar")), getTexture("media/textures/BetLock_lockpick_Crowbar_Icon.png"))
                elseif endurance <= 0.5 then
                    menu:addSlice(getText("UI_enduranceRequireCar"), getTexture("media/textures/BetLock_lockpick_Crowbar_Icon.png"))
                else
                    local text = getText("UI_BetLock_LockpickDoorCrowBar") .. " \n(" .. getText(vehicle:getModData().LockpickLevel.name) .. ")" 
                    menu:addSlice(text, getTexture("media/textures/BetLock_lockpick_Crowbar_Icon.png"), BetLock.UI.startLockpickingVehicleDoorCrowbar, playerObj, part)
                end
            end

            -- ОПЦИЯ ВЗЛОМА ОТМЫЧКАМИ
            if playerObj:getKnownRecipes():contains("Lockpicking") then
                local inv = playerObj:getInventory()
                local screwdriver = inv:getFirstTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken)
                if not (playerObj:getInventory():getFirstTypeRecurse("BobbyPin") or playerObj:getInventory():getFirstTypeRecurse("HandmadeBobbyPin")) then
                    menu:addSlice(getText("ContextMenu_Require", getItemNameFromFullType("BetLock.BobbyPin")), getTexture("media/textures/BetLock_lockpick_Icon.png"))
                elseif not screwdriver then
                    menu:addSlice(getText("ContextMenu_Require", getItemNameFromFullType("Base.Screwdriver")), getTexture("media/textures/BetLock_lockpick_Icon.png"))
                else
                    if part:getDoor():isLockBroken() then
                        menu:addSlice(getText("IGUI_PlayerText_VehicleLockIsBroken"), getTexture("media/textures/BetLock_lockpick_Icon.png"))
                    else
                        local text = getText("UI_BetLock_LockpickDoorBobbyPin") .. " \n(" .. getText(vehicle:getModData().LockpickLevel.name) .. ")" 
                        menu:addSlice(text, getTexture("media/textures/BetLock_lockpick_Icon.png"), BetLock.UI.startLockpickingVehicleDoorBobbyPin, playerObj, part)
                    end
                end
            end
        end

        if part:getId() == "EngineDoor" and playerObj:getKnownRecipes():contains("Alarm check") then
            menu:addSlice(getText("UI_BetLock_CheckAlarm"), getTexture("media/textures/BetLock_alarmIcon.png"), BetLock.UI.alarmCheck, playerObj, vehicle, part)
        end
    end
end

-- СОХРАНЕНИЕ ДЕФОЛТНЫХ ФУНКЦИЙ РАДИАЛ-МЕНЮ
if BetLock.UI.defaultShowRadialMenu == nil then
    BetLock.UI.defaultShowRadialMenu = ISVehicleMenu.showRadialMenu
end

-- ПЕРЕОПРЕДЕЛЕНИЕ РАДИАЛЬНОГО МЕНЮ
function ISVehicleMenu.showRadialMenu(playerObj)
    local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
    
    -- Если меню уже открыто, закрываем его и выходим
    if menu:isReallyVisible() then
        if menu.joyfocus then
            setJoypadFocus(playerObj:getPlayerNum(), nil)
        end
        menu:undisplay()
        return
    end

    -- Вызываем оригинальную функцию для создания базового меню
    BetLock.UI.defaultShowRadialMenu(playerObj)
    
    -- Добавляем свои опции только если игрок не в машине
    if not playerObj:getVehicle() then
        BetLock.UI.addOutsideOptions(playerObj)
    else
        -- Обновляем меню для случая внутри машины
        BetLock.UI.updateShowRadialMenu(playerObj)
    end
end

-- ОБНОВЛЕНИЕ РАДИАЛЬНОГО МЕНЮ (ВНУТРИ МАШИНЫ)
function BetLock.UI.updateShowRadialMenu(playerObj)
    local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0
    if isPaused then return end
    
    local vehicle = playerObj:getVehicle()
    if vehicle and vehicle:isDriver(playerObj) then
        if vehicle:getModData().HotwireLevel == nil then
            vehicle:getModData().HotwireLevel = BetLock.Utils.getHotwireLevelVehicle(vehicle)
        end

        local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
        if not (SandboxVars.TheBestLockpicking and SandboxVars.TheBestLockpicking.DisableHotwire) then
            local hotwireText
            if isBurglarProfession(playerObj) then
                hotwireText = getText("ContextMenu_VehicleHotwire") .. " \n(" .. getText(vehicle:getModData().HotwireLevel.name) .. ")"
            else
                hotwireText = getText("ContextMenu_VehicleHotwire") .. " \n(Burglar or Skilled Char)"
            end
            menu:updateSlice(getText("ContextMenu_VehicleHotwire"), hotwireText)

            -- Добавление опции "Unhotwire"
            if not vehicle:isEngineStarted() and
               not vehicle:isEngineRunning() and
               not SandboxVars.VehicleEasyUse and
               not vehicle:isKeysInIgnition() and
               vehicle:isHotwired() then
                local canUnhotwire = (playerObj:getPerkLevel(Perks.Electricity) >= 1 and playerObj:getPerkLevel(Perks.Mechanics) >= 2)
                local desc = playerObj:getDescriptor()
                if desc then
                    local prof = desc:getCharacterProfession()
                    if prof then
                        local ok, name = pcall(function() return prof:getName() end)
                        if ok and name == "burglar" then
                            canUnhotwire = true
                        end
                    end
                end
                if canUnhotwire then
                    menu:addSlice(getText("ContextMenu_VehicleUnhotwire"), getTexture("media/ui/vehicles/vehicle_ignitionOFF.png"), BetLock.UI.onUnHotwire, playerObj)
                else
                    menu:addSlice(getText("ContextMenu_VehicleUnhotwireSkill"), getTexture("media/ui/vehicles/vehicle_ignitionOFF.png"), nil, playerObj)
                end
            end
        end
        -- Убираем явный вызов addToUIManager(), так как он уже вызывается в defaultShowRadialMenu
    end
end

-- ВЗЛОМ ЗАМКА ЗАЖИГАНИЯ (ПРОВОДА)
if BetLock.UI.defaultOnHotwire == nil then
    BetLock.UI.defaultOnHotwire = ISVehicleMenu.onHotwire
end
function ISVehicleMenu.onHotwire(playerObj)
    if SandboxVars.TheBestLockpicking and SandboxVars.TheBestLockpicking.DisableHotwire then
        if BetLock.UI.defaultOnHotwire then BetLock.UI.defaultOnHotwire(playerObj) end
        return
    end
    if not isBurglarProfession(playerObj) then return end
    HotwireWindow:createWindow(playerObj)
end

-- ВЗЛОМ ОТМЫЧКАМИ
function BetLock.UI.startLockpickingVehicleDoorBobbyPin(playerObj, part)
    local vehicle = part:getVehicle()
    local inv = playerObj:getInventory()
    local screwdriver = inv:getFirstTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken)
    local primaryhand = playerObj:getPrimaryHandItem()

    ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))
    if not (primaryhand and primaryhand:getType() == "Screwdriver") then
        ISInventoryPaneContextMenu.equipWeapon(screwdriver, true, false, playerObj:getPlayerNum())
    end
    --ISTimedActionQueue.add(EmptyAction:new(playerObj, LockpickingManager.createVehicleDoor, nil, playerObj, part))
	LockpickingManager.createVehicleDoor(playerObj, part)
end

-- ВЗЛОМ МОНТИРОВКОЙ
function BetLock.UI.startLockpickingVehicleDoorCrowbar(playerObj, part)
    local vehicle = part:getVehicle()
    local inv = playerObj:getInventory()
    local crowbar = inv:getFirstTagEvalRecurse(ItemTag.CROWBAR, predicateNotBroken)

    ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))
    if not playerObj:isItemInBothHands(crowbar) then
        ISInventoryPaneContextMenu.equipWeapon(crowbar, true, true, playerObj:getPlayerNum())
    end
    ISTimedActionQueue.add(EmptyAction:new(playerObj, CrowbarWindow.createVehicleDoor, nil, playerObj, part))
end 

-- ПРОВЕРКА СИГНАЛИЗАЦИИ
function BetLock.UI.alarmCheck(playerObj, vehicle, part)
    ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))
    if playerObj:getPrimaryHandItem() then
        ISTimedActionQueue.add(ISUnequipAction:new(playerObj, playerObj:getPrimaryHandItem(), 50));
    end
    if playerObj:getSecondaryHandItem() and playerObj:getSecondaryHandItem() ~= playerObj:getPrimaryHandItem() then
        ISTimedActionQueue.add(ISUnequipAction:new(playerObj, playerObj:getSecondaryHandItem(), 50));
    end
    if not part:getDoor():isLocked() then
        ISTimedActionQueue.add(CheckAlarmVehicleAction:new(playerObj, vehicle));
    else
        playerObj:facePosition(vehicle:getX(), vehicle:getY())
        playerObj:getEmitter():playSound("DoorIsLocked")
    end
end
