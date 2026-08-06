--[[
    QoL Fixed Fixtures - Interactive Weighing Scale + Wall Clock
    ------------------------------------------------------------
    Right-click a Weighing Scale  -> reads current weight + nutrition.
    Right-click a Wall Clock      -> reads current in-game time.

    Detection is based on the tile's "CustomName" property, confirmed against
    the game's own tile data:
      Weighing Scale tiles: CustomName = "Scale"   (GroupName = "Weighing")
      Wall Clock tiles:     CustomName = "Clock"   (GroupName = "Wall")
    GroupName is reused by other unrelated objects (e.g. Wall Vault also has
    GroupName "Wall"), so CustomName is the reliable one to match on.

    Note: as of Build 42.8.0, wall clocks already show moving hands that
    reflect real in-game time -- but only on their East/South-facing sprites.
    This option gives you the time regardless of which way the clock faces,
    and works for players who don't want to squint at pixel-art hands.
--]]

local function getCustomName(obj)
    local sprite = obj:getSprite()
    if not sprite then return nil end
    local props = sprite:getProperties()
    if not props then return nil end
    if props:Is("CustomName") then
        return props:Val("CustomName")
    end
    return nil
end

local function onCheckScale(player)
    local nutrition = player:getNutrition()
    if not nutrition then return end

    local weight = math.floor(nutrition:getWeight() + 0.5)
    local cal    = math.floor(nutrition:getCalories())
    local carbs  = math.floor(nutrition:getCarbohydrates())
    local prot   = math.floor(nutrition:getProteins())
    local fat    = math.floor(nutrition:getLipids())

    player:Say(string.format("%d kg. %d kcal | C:%d P:%d F:%d", weight, cal, carbs, prot, fat))
end

local function onCheckClock(player)
    -- getHourMinute() is a built-in global helper that returns the current
    -- in-game time already formatted (used internally by the digital watch).
    local timeStr = getHourMinute()
    player:Say("It's " .. tostring(timeStr))
end

local function OnFillWorldObjectContextMenu(playerNum, context, worldobjects, test)
    if not worldobjects or (#worldobjects < 1) then return end
    local player = getSpecificPlayer(playerNum)
    if not player then return end

    local addedScale, addedClock = false, false

    for _, obj in ipairs(worldobjects) do
        local customName = getCustomName(obj)

        if customName == "Scale" and not addedScale then
            context:addOption("Check your weight", player, onCheckScale)
            addedScale = true
        elseif customName == "Clock" and not addedClock then
            context:addOption("Check the time", player, onCheckClock)
            addedClock = true
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)
