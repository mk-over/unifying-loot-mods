if BetLock == nil then BetLock = {} end
if BetLock.UI == nil then BetLock.UI = {} end
local LockpickingManager = require "Lockpicking/LockpickingManager"
-- ПРОВЕРКА ПРОЧНОСТИ ПРЕДМЕТА
local function predicateNotBroken(item)
    return not item:isBroken()
end
local function isValidWindow(window)
    local spriteName = window:getSprite():getName()
    if not window then
        return false
    elseif window:IsOpen() then
        return false
    elseif window:isSmashed() or window:isDestroyed() then
        return false
    elseif spriteName and spriteName:find("walls") and window:isPermaLocked() then
        return false
    elseif window:isBarricaded() then
        return false
    else
        return true
    end
end
-- ВЗЛОМ ДВЕРИ ОТМЫЧКАМИ
function BetLock.UI.goToDoorBobbyPin(playerObj, door, goToOpen)
    local sq = door:getSquare()
    if door:getOppositeSquare():DistTo(playerObj:getSquare()) < door:getSquare():DistTo(playerObj:getSquare()) then
        sq = door:getOppositeSquare()
    end
   
    local inv = playerObj:getInventory()
    
    -- Находим инструменты
    local screwdriver = inv:getFirstTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken)
    local bobbyPin = inv:getFirstTypeRecurse("BobbyPin")
    if not bobbyPin then
        bobbyPin = inv:getFirstTypeRecurse("HandmadeBobbyPin")
    end

    -- Экипируем правильно
    if screwdriver then
        ISInventoryPaneContextMenu.equipWeapon(screwdriver, true, false, playerObj:getPlayerNum())  -- отвёртка в основную руку
    end
    if bobbyPin then
        ISInventoryPaneContextMenu.equipWeapon(bobbyPin, false, false, playerObj:getPlayerNum())   -- отмычка во вторую руку
    end
   
    ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sq))
    --ISTimedActionQueue.add(EmptyAction:new(playerObj, LockpickingManager.createBuildingDoor, nil, playerObj, door, goToOpen))
    LockpickingManager.createBuildingDoor(playerObj, door, goToOpen)
end
-- ВЗЛОМ ДВЕРИ МОНТИРОВКОЙ
function BetLock.UI.goToDoorCrowbar(playerObj, door)
    local sq = door:getSquare()
    if door:getOppositeSquare():DistTo(playerObj:getSquare()) < door:getSquare():DistTo(playerObj:getSquare()) then
        sq = door:getOppositeSquare()
    end
    local inv = playerObj:getInventory()
    local crowbar = inv:getFirstTagEvalRecurse(ItemTag.CROWBAR, predicateNotBroken)
    ISInventoryPaneContextMenu.equipWeapon(crowbar, true, true, playerObj:getPlayerNum())
    ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sq))
    ISTimedActionQueue.add(EmptyAction:new(playerObj, CrowbarWindow.createBuildingDoor, nil, playerObj, door))
end
-- ВЗЛОМ ОКНА МОНТИРОВКОЙ
function BetLock.UI.goToWindowCrowbar(playerObj, window)
    local sq = window:getSquare()
    if window:getOppositeSquare():DistTo(playerObj:getSquare()) < window:getSquare():DistTo(playerObj:getSquare()) then
        sq = window:getOppositeSquare()
    end
    local inv = playerObj:getInventory()
    local crowbar = inv:getFirstTagEvalRecurse(ItemTag.CROWBAR, predicateNotBroken)
    ISInventoryPaneContextMenu.equipWeapon(crowbar, true, true, playerObj:getPlayerNum())
    ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sq))
    ISTimedActionQueue.add(EmptyAction:new(playerObj, CrowbarWindow.createBuildingWindow, nil, playerObj, window))
end
-- ПРОВЕРКА СИГНАЛИЗАЦИИ
function BetLock.UI.checkBuildingAlarm(playerObj, sq1, sq2, obj)
    local sq = sq1
    if sq2:DistTo(playerObj:getSquare()) < sq1:DistTo(playerObj:getSquare()) then
        sq = sq2
    end
    ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sq))
    if playerObj:getPrimaryHandItem() then
        ISTimedActionQueue.add(ISUnequipAction:new(playerObj, playerObj:getPrimaryHandItem(), 50))
    end
    if playerObj:getSecondaryHandItem() and playerObj:getSecondaryHandItem() ~= playerObj:getPrimaryHandItem() then
        ISTimedActionQueue.add(ISUnequipAction:new(playerObj, playerObj:getSecondaryHandItem(), 50))
    end
    ISTimedActionQueue.add(CheckAlarmBuildingAction:new(playerObj, sq1, sq2, obj))
end
-- КОНТЕКСТНОЕ МЕНЮ
function BetLock.UI.contextMenuOptions(player, context, worldobjects)
    local playerObj = getSpecificPlayer(player)
    if not playerObj then
        print("Error: playerObj is nil")
        return
    end
    print("=== BetLock DEBUG START ===")
    print("BetLock: contextMenuOptions called for player " .. player)
    print("BetLock: worldobjects count = " .. #worldobjects)

    local playerSkill = playerObj:getPerkLevel(Perks.Lockpicking)
    local playerStrength = playerObj:getPerkLevel(Perks.Strength)
    --local endurance = playerObj:getStats():getEndurance()
    local endurance = playerObj:getStats():get(CharacterStat.ENDURANCE)
    -- Получаем клетку, на которую кликнули
    local clickedSquare = nil
    for _, obj in ipairs(worldobjects) do
        if obj and obj:getSquare() then
            clickedSquare = obj:getSquare()
            break
        end
    end
    if not clickedSquare then
        print("Error: clickedSquare is nil")
        return
    end
    -- Получаем соседние клетки в радиусе 1
    local adjacentSquares = {}
    for dx = -1, 1 do
        for dy = -1, 1 do
            local adjSquare = getCell():getGridSquare(clickedSquare:getX() + dx, clickedSquare:getY() + dy, clickedSquare:getZ())
            if adjSquare then
                table.insert(adjacentSquares, adjSquare)
            end
        end
    end
    -- Поиск двери и окна
    local selectedDoor = nil
    local selectedWindow = nil
    local doorsFound = {}
    -- Проверяем центральный квадрат
    local clickedObjects = clickedSquare:getObjects()
    if clickedObjects then
        for i = 0, clickedObjects:size() - 1 do
            local obj = clickedObjects:get(i)
            if obj then
                if (instanceof(obj, "IsoDoor") or (instanceof(obj, "IsoThumpable") and obj:isDoor())) and obj:getKeyId() ~= -1 then
                    selectedDoor = obj
                    table.insert(doorsFound, {obj = obj, square = clickedSquare})
                elseif instanceof(obj, "IsoWindow") and isValidWindow(obj) then
                    selectedWindow = obj
                end
            end
        end
    else
        print("Warning: clickedSquare:getObjects() returned nil")
    end
    -- Если дверь или окно не найдены в центральном квадрате, ищем ближайшие
    if not selectedDoor or not selectedWindow then
        local minDoorDist = math.huge
        local minWindowDist = math.huge
        for _, square in ipairs(adjacentSquares) do
            local squareObjects = square:getObjects()
            if squareObjects then
                for i = 0, squareObjects:size() - 1 do
                    local obj = squareObjects:get(i)
                    if obj then
                        local dist = square:DistTo(clickedSquare)
                        if (instanceof(obj, "IsoDoor") or (instanceof(obj, "IsoThumpable") and obj:isDoor())) and obj:getKeyId() ~= -1 then
                            table.insert(doorsFound, {obj = obj, square = square})
                            if not selectedDoor or dist < minDoorDist then
                                selectedDoor = obj
                                minDoorDist = dist
                            end
                        elseif instanceof(obj, "IsoWindow") and isValidWindow(obj) then
                            if not selectedWindow or dist < minWindowDist then
                                selectedWindow = obj
                                minWindowDist = dist
                            end
                        end
                    end
                end
            end
        end
    end
    -- Тестовая пометка квадратов через отладочный вывод
    for _, doorData in ipairs(doorsFound) do
        local square = doorData.square
        if square then
            local coords = square:getX() .. "," .. square:getY() .. "," .. square:getZ()
            if doorData.obj == selectedDoor then
                print("Selected door (Green) at: " .. coords)
            else
                print("Found door (Yellow) at: " .. coords)
            end
        end
    end

    print("BetLock: doorsFound count = " .. #doorsFound)
    print("BetLock: selectedDoor = " .. (selectedDoor and "YES" or "NO"))
    print("BetLock: selectedWindow = " .. (selectedWindow and "YES" or "NO"))

    -- Обработка выбранной двери
    if selectedDoor then
        print("BetLock: === ENTERED DOOR BLOCK ===")
        if selectedDoor:getModData().LockpickLevel == nil then
            selectedDoor:getModData().LockpickLevel = BetLock.Utils.getLockpickLevelBuildingObj(selectedDoor)
        end
   
        local doorName = selectedDoor:getName()
        local doorIdentifier = doorName or string.format("(%d, %d, %d)",
            selectedDoor:getSquare():getX(), selectedDoor:getSquare():getY(), selectedDoor:getSquare():getZ())
        --local lockpickingMenuOption = context:addOption(getText("UI_Lockpick_Door") .. " (" .. doorIdentifier .. ")")
        local lockpickingMenuOption = context:addOption(getText("UI_Lockpick_Door"))
        local subMenuLockpicking = context:getNew(context)
        context:addSubMenu(lockpickingMenuOption, subMenuLockpicking)
        if playerObj:getKnownRecipes():contains("Lockpicking") then
            local option = subMenuLockpicking:addOption(getText("UI_Lockpick_bobbypin"), playerObj, BetLock.UI.goToDoorBobbyPin, selectedDoor, true)
            option.toolTip = ISToolTip:new()
            option.toolTip:initialise()
            option.toolTip:setVisible(false)
            option.toolTip:setName(getText(selectedDoor:getModData().LockpickLevel.name))
            local color = playerSkill >= selectedDoor:getModData().LockpickLevel.num and " <RGB:1,1,1> " or " <RGB:0.9,0.5,0> "
            option.toolTip.description = color .. getText("Tooltip_vehicle_recommendedSkill", playerSkill .. "/" .. selectedDoor:getModData().LockpickLevel.num, "") .. " <LINE> "
            if not (playerObj:getInventory():getFirstTypeRecurse("BobbyPin") or playerObj:getInventory():getFirstTypeRecurse("HandmadeBobbyPin")) then
                color = " <RGB:0.9,0,0> "
                option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("BetLock.BobbyPin")) .. " <LINE> "
                option.notAvailable = true
                print("BetLock: BobbyPin (отмычка) found = NO")
            else
                print("BetLock: BobbyPin (отмычка) found = YES")
            end
            local inv = playerObj:getInventory()
            local screwdriver = inv:getFirstTagEvalRecurse(ItemTag.SCREWDRIVER, predicateNotBroken)
            if not screwdriver then
                color = " <RGB:0.9,0,0> "
                option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Screwdriver")) .. " <LINE> "
                option.notAvailable = true
                print("BetLock: Screwdriver (отвертка) found = NO")
            else
                print("BetLock: Screwdriver (отвертка) found = YES")
            end
            if selectedDoor:getKeyId() == -3 then
                color = " <RGB:0.9,0,0> "
                option.toolTip.description = option.toolTip.description .. color .. getText("IGUI_LockBroken") .. " <LINE> "
                option.notAvailable = true
            end
        end
        if not SandboxVars.TheBestLockpicking.DisableCrowbar then
        local option = subMenuLockpicking:addOption(getText("UI_Lockpick_crowbar"), playerObj, BetLock.UI.goToDoorCrowbar, selectedDoor)
        option.toolTip = ISToolTip:new()
        option.toolTip:initialise()
        option.toolTip:setVisible(false)
        option.toolTip:setName(getText(selectedDoor:getModData().LockpickLevel.name))
        local color = playerStrength >= selectedDoor:getModData().LockpickLevel.num and " <RGB:1,1,1> " or " <RGB:0.9,0.5,0> "
        option.toolTip.description = color .. getText("Tooltip_vehicle_recommendedSkill", playerStrength .. "/" .. selectedDoor:getModData().LockpickLevel.num, "") .. " <LINE> "
        local inv = playerObj:getInventory()
        local crowbarinv = inv:getFirstTagEvalRecurse(ItemTag.CROWBAR, predicateNotBroken)
        if not crowbarinv then
            color = " <RGB:0.9,0,0> "
            option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Crowbar")) .. " <LINE> "
            option.notAvailable = true
            print("BetLock: Crowbar (ломик) found = NO")
        else
            print("BetLock: Crowbar (ломик) found = YES")
        end
        if endurance <= 0.5 then
            color = " <RGB:0.9,0,0> "
            option.toolTip.description = option.toolTip.description .. color .. getText("UI_enduranceRequire") .. " <LINE> "
            option.notAvailable = true
        end
        end
        --if playerObj:getKnownRecipes():contains("Alarm check") and selectedDoor:isExteriorDoor(playerObj) then
        if playerObj:getKnownRecipes():contains("Alarm check") then
            subMenuLockpicking:addOption(getText("UI_BetLock_CheckAlarm"),
                playerObj, BetLock.UI.checkBuildingAlarm, selectedDoor:getSquare(), selectedDoor:getOppositeSquare(), selectedDoor)
        end
    end
    -- Обработка выбранного окна
    if selectedWindow then
        print("BetLock: === ENTERED WINDOW BLOCK ===")
        if selectedWindow:getModData().LockpickLevel == nil then
            selectedWindow:getModData().LockpickLevel = BetLock.Utils.getLockpickLevelBuildingObj(selectedWindow)
        end
       
        local windowIdentifier = string.format("(%d, %d, %d)",
            selectedWindow:getSquare():getX(), selectedWindow:getSquare():getY(), selectedWindow:getSquare():getZ())
        --local lockpickingMenuOption = context:addOption(getText("UI_Lockpick_Window") .. " (" .. windowIdentifier .. ")")
        local lockpickingMenuOption = context:addOption(getText("UI_Lockpick_Window"))
        local subMenuLockpicking = context:getNew(context)
        context:addSubMenu(lockpickingMenuOption, subMenuLockpicking)
        if not SandboxVars.TheBestLockpicking.DisableCrowbar then
        local option = subMenuLockpicking:addOption(getText("UI_Lockpick_crowbar"), playerObj, BetLock.UI.goToWindowCrowbar, selectedWindow)
        option.toolTip = ISToolTip:new()
        option.toolTip:initialise()
        option.toolTip:setVisible(false)
        option.toolTip:setName(getText(selectedWindow:getModData().LockpickLevel.name))
        local color = playerStrength >= selectedWindow:getModData().LockpickLevel.num and " <RGB:1,1,1> " or " <RGB:0.9,0.5,0> "
        option.toolTip.description = color .. getText("Tooltip_vehicle_recommendedSkill", playerStrength .. "/" .. selectedWindow:getModData().LockpickLevel.num, "") .. " <LINE> "
        option.toolTip.description = option.toolTip.description .. " <RGB:1,1,1> " .. getText("UI_chance_break_window") .. BetLock.Utils.getChanceBreakLock(playerSkill, selectedWindow:getModData().LockpickLevel.num) .. "%" .. " <LINE> "
       
        local inv = playerObj:getInventory()
        local crowbarinv = inv:getFirstTagEvalRecurse(ItemTag.CROWBAR, predicateNotBroken)
        if not crowbarinv then
            color = " <RGB:0.9,0,0> "
            option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Crowbar")) .. " <LINE> "
            option.notAvailable = true
            print("BetLock: Crowbar (ломик) found = NO")
        else
            print("BetLock: Crowbar (ломик) found = YES")
        end
       
        if endurance <= 0.5 then
            color = " <RGB:0.9,0,0> "
            option.toolTip.description = option.toolTip.description .. color .. getText("UI_enduranceRequire") .. " <LINE> "
            option.notAvailable = true
        end
        end
        if playerObj:getKnownRecipes():contains("Alarm check") then
            subMenuLockpicking:addOption(getText("UI_BetLock_CheckAlarm"),
                playerObj, BetLock.UI.checkBuildingAlarm, selectedWindow:getSquare(), selectedWindow:getOppositeSquare(), selectedWindow)
        end
    end
    print("=== BetLock DEBUG END ===")
end
Events.OnFillWorldObjectContextMenu.Add(BetLock.UI.contextMenuOptions)
