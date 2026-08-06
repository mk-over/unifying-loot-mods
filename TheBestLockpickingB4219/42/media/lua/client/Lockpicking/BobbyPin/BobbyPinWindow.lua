require "ISUI/ISPanel"

BobbyPinWindow = ISPanel:derive("BobbyPinWindow");

local MODE_VEHICLE_DOOR = 0
local MODE_VEHICLE_ENGINE_KEY = 1
local MODE_BUILDING_DOOR = 2

local xPos = 125
local yPos = 250

local pickLockHealth = 350

local tmpVec1 = Vector3f.new()
local tmpVec2 = Vector3f.new():set(1, 0, 0)

local function forceUnlockChance(playerObj)
    return 10 + playerObj:getPerkLevel(Perks.Strength) + playerObj:getPerkLevel(Perks.Lockpicking)
end

function BobbyPinWindow:setVisible(visible)
    self.javaObject:setVisible(visible);
end

local lastRenderMillis = nil
function BobbyPinWindow:render()
    self:drawText(getText("UI_Controls_BobbyPin"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Small, getText("UI_Controls_BobbyPin")) / 2), 10, 1,1,1,1, UIFont.Small);

    self:DrawTextureAngle(self.tex_LockBack, xPos, yPos, 0)
    self:DrawTextureAngle(self.tex_LockFront, xPos, yPos, self.angleScrew)
    self:DrawTextureAngle(self.tex_Screwdriver, xPos, yPos, self.angleScrew)
    
    local currentMillis = math.floor(getTimeInMillis()/100)
    local isNewTimeStep = false
    if lastRenderMillis ~= currentMillis then
        lastRenderMillis = currentMillis
        isNewTimeStep = true
    end

    if self.breakTimer > 0 then
        if isNewTimeStep then
            self.breakTimer = self.breakTimer - 0.1
        end
        if self.isEnd and not self.isFailEnd then
            self:DrawTextureAngle(self.tex_LockPick, xPos, yPos, self.anglePick)
        else
            self:DrawTextureAngle(self.tex_LockPickBreak, xPos, yPos, self.anglePick)
        end

        if self.breakTimer <= 0 then
            if self.isEnd or self.isFailEnd then
                self:setVisible(false);
                self:removeFromUIManager();
                self:close()
            end
        end
    else
        self:DrawTextureAngle(self.tex_LockPick, xPos, yPos, self.anglePick)
    end
end

function BobbyPinWindow:onOptionMouseDown(button, x, y)
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();
        self:close()
    end
    if button.internal == "FORCE" then
        self:setVisible(false)
        self:forceUnlock()
        self:close()
    end
end

function BobbyPinWindow:forceUnlock()
    if ZombRand(100) < forceUnlockChance(self.character) then
        self:doUnlock()
    else
        self:doBreakLock()
    end

    self.breakTimer = 1
    self.isEnd = true
end

function BobbyPinWindow:doLock()
    self.lockpick_object:setLockedByKey(true);
    self.lockpick_object:setLocked(true)
    if IsoDoor.getGarageDoorIndex(self.lockpick_object) ~= -1 then
        local doorPrev = IsoDoor.getGarageDoorPrev(self.lockpick_object)
        while doorPrev ~= nil do
            doorPrev:setLockedByKey(true);
            doorPrev:setLocked(true);
            doorPrev = IsoDoor.getGarageDoorPrev(doorPrev)
        end

        local doorNext = IsoDoor.getGarageDoorNext(self.lockpick_object)
        while doorNext ~= nil do
            doorNext:setLockedByKey(true);
            doorNext:setLocked(true);
            doorNext = IsoDoor.getGarageDoorNext(doorNext)
        end
    end
    self.character:playSoundLocal("bobby_success");
    sendClientCommand(self.character, "BetLock", "addLockpickingXP", {amount = self.addingXP})
    self.character:getXp():AddXPHaloText(Perks.Lockpicking, self.addingXP)
end

function BobbyPinWindow:doUnlock()
    if self.mode == MODE_VEHICLE_DOOR then
        sendClientCommand(self.character, 'screwdriver', 'vehicleDoor', { vehicle=self.lockpick_object:getVehicle():getId(), part=self.lockpick_object:getId() })
        self.character:playSoundLocal("bobby_success");
    elseif self.mode == MODE_VEHICLE_ENGINE_KEY then
        self.lockpick_object:tryStartEngine(true)
    else
        self.lockpick_object:setLockedByKey(false);

        if IsoDoor.getGarageDoorIndex(self.lockpick_object) ~= -1 then
            local doorPrev = IsoDoor.getGarageDoorPrev(self.lockpick_object)
            while doorPrev ~= nil do
                doorPrev:setLockedByKey(false);
                doorPrev = IsoDoor.getGarageDoorPrev(doorPrev)
            end
    
            local doorNext = IsoDoor.getGarageDoorNext(self.lockpick_object)
            while doorNext ~= nil do
                doorNext:setLockedByKey(false);
                doorNext = IsoDoor.getGarageDoorNext(doorNext)
            end
        end

        self.character:playSoundLocal("bobby_success");
    end
    sendClientCommand(self.character, "BetLock", "addLockpickingXP", {amount = self.addingXP})
    self.character:getXp():AddXPHaloText(Perks.Lockpicking, self.addingXP)
end

function BobbyPinWindow:doBreakLock()
    if self.mode == MODE_VEHICLE_DOOR then
        self.lockpick_object:getDoor():setLockBroken(true)
        self.character:playSoundLocal("lockpick_force_fail");
    elseif self.mode == MODE_VEHICLE_ENGINE_KEY then
        self.lockpick_object:setKeyId(-3);
        self.character:playSoundLocal("lockpick_force_fail");
    else
        self.lockpick_object:setKeyId(-3);

        if IsoDoor.getGarageDoorIndex(self.lockpick_object) ~= -1 then
            local doorPrev = IsoDoor.getGarageDoorPrev(self.lockpick_object)
            while doorPrev ~= nil do
                doorPrev:setKeyId(-3);
                doorPrev = IsoDoor.getGarageDoorPrev(doorPrev)
            end
    
            local doorNext = IsoDoor.getGarageDoorNext(self.lockpick_object)
            while doorNext ~= nil do
                doorNext:setKeyId(-3);
                doorNext = IsoDoor.getGarageDoorNext(doorNext)
            end
        end
        self.character:playSoundLocal("lockpick_force_fail");
    end
    sendClientCommand(self.character, "BetLock", "addLockpickingXP", {amount = self.addingXP / 5})
    self.character:getXp():AddXPHaloText(Perks.Lockpicking, self.addingXP / 5)
end

function BobbyPinWindow:close()
    self.character:getModData().zReBLStopFlag = 1
    self.character:getModData().isLockpicking = false
    ISTimedActionQueue.clear(self.character)
    BobbyPinWindow.instance = nil
    ISPanel.close(self)
end

function BobbyPinWindow:onMouseMoveOutside(dx, dy)
    if self.angleScrew == self.maxAngle or self.breakTimer > 0 then
        return
    end
    
    if self:getMouseY() < 250 then
        tmpVec1:set(self:getMouseX() - 125, self:getMouseY() - 250, 0)
        local angle = tmpVec1:angle(tmpVec2)
        if tmpVec1:y() > 0 then angle = -angle end
        self.anglePick = -((angle/math.pi)*180 + 135 + 90)
    else
        if self:getMouseX() < 125 then
            self.anglePick = -405
        else
            self.anglePick = -405 + 180   
        end
    end

    local diff = math.abs((self.anglePick + 405) - self.keyAngle)
    if diff > 180 then diff = 360 - diff end

    if diff < self.diffAngle then 
        self.maxAngle = 90
    elseif diff >= 45 then
        self.maxAngle = 5
    else
        self.maxAngle = (90 - 2*diff)
    end
end

function BobbyPinWindow:createVehicleDoor(playerObj, part)
    if part:getDoor():isLockBroken() then
        playerObj:Say(getText("IGUI_PlayerText_VehicleLockIsBroken"))
        return
    end
        
    local modal = BobbyPinWindow:new(Core:getInstance():getScreenWidth()/2 - 250/2 + 300, Core:getInstance():getScreenHeight()/2 - 500/2, 250, 90)
    modal.lockpick_object = part
    modal.mode = MODE_VEHICLE_DOOR
    modal.tex_LockBack = getTexture("media/textures/BetLock_Back_VehDoor.png")
    modal.tex_LockFront = getTexture("media/textures/BetLock_Front_VehDoor.png")
    modal.tex_LockPick = getTexture("media/textures/BetLock_PickLock.png")
    modal.tex_LockPickBreak = getTexture("media/textures/BetLock_PickLock_Break.png")
    modal.tex_Screwdriver = getTexture("media/textures/BetLock_Screwdriver.png")
    modal.character = playerObj
    
    -- B42.17 nil-safety
    local vehModData = part:getVehicle() and part:getVehicle():getModData() or {}
    modal.addingXP = (vehModData.LockpickLevel and vehModData.LockpickLevel.xp) or 5

    modal:initialise()
    modal:addToUIManager()
end

function BobbyPinWindow:createBuildingDoor(playerObj, door, goToOpen)
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

    local modal = BobbyPinWindow:new(Core:getInstance():getScreenWidth()/2 - 250/2 + 300, Core:getInstance():getScreenHeight()/2 - 500/2, 250, 90)
    modal.lockpick_object = door
    modal.mode = MODE_BUILDING_DOOR
    modal.tex_LockBack = getTexture("media/textures/BetLock_Back_VehDoor.png")
    modal.tex_LockFront = getTexture("media/textures/BetLock_Front_VehDoor.png")
    modal.tex_LockPick = getTexture("media/textures/BetLock_PickLock.png")
    modal.tex_LockPickBreak = getTexture("media/textures/BetLock_PickLock_Break.png")
    modal.tex_Screwdriver = getTexture("media/textures/BetLock_Screwdriver.png")
    modal.character = playerObj
    modal.goToOpen = goToOpen
    
    -- B42.17 nil-safety + facing fix
    local modData = door:getModData()
    modal.addingXP = (modData.LockpickLevel and modData.LockpickLevel.xp) or 5
    if playerObj and door then
        playerObj:faceThisObject(door)
    end

    modal:initialise()
    modal:addToUIManager()
end

function BobbyPinWindow:initialise()
    if not (self.character:getInventory():getFirstTypeRecurse("BobbyPin") or self.character:getInventory():getFirstTypeRecurse("HandmadeBobbyPin")) then
        return
    end

    ISPanel.initialise(self)
    self:create()
    BobbyPinWindow.instance = self

    self.character:getModData().isLockpicking = true

    local skill = self.character:getPerkLevel(Perks.Lockpicking)

    -- B42.17 nil-safety
    local level
    if self.mode == MODE_VEHICLE_DOOR then
        local vehModData = self.lockpick_object:getVehicle() and self.lockpick_object:getVehicle():getModData() or {}
        level = (vehModData.LockpickLevel and vehModData.LockpickLevel.num) or 0
    else
        local doorModData = self.lockpick_object:getModData()
        level = (doorModData.LockpickLevel and doorModData.LockpickLevel.num) or 0
    end

    self.chanceBreakLock = BetLock.Utils.getChanceBreakLock(skill, level)
    self.diffAngle = BetLock.Utils.getDiffAngleBobbyPin(skill, level)

    local diff = math.abs((self.anglePick + 405) - self.keyAngle)
    if diff > 180 then diff = 360 - diff end

    if diff < self.diffAngle then 
        self.maxAngle = 90
    elseif diff >= 45 then
        self.maxAngle = 5
    else
        self.maxAngle = (90 - 2*diff)
    end

    ISTimedActionQueue.clear(self.character)
    ISTimedActionQueue.add(BobbyPinActionAnim:new(self.character, self.lockpick_object))
end

function BobbyPinWindow:create()
    self.cancel = ISButton:new((self:getWidth() / 2) - 50, self:getHeight() - 55, 100, 20, getText("UI_Cancel"), self, BobbyPinWindow.onOptionMouseDown);
    self.cancel.internal = "CANCEL";
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.cancel);
	
	if self.goToOpen then
        self.forceButton = ISButton:new((self:getWidth() / 2) - 100, self:getHeight() - 30, 200, 20, getText("UI_ForceUnlock") .. " (" .. forceUnlockChance(self.character) .. "%)", self, BobbyPinWindow.onOptionMouseDown);
        self.forceButton.internal = "FORCE";
        self.forceButton:initialise();
        self.forceButton:instantiate();
        self.forceButton.borderColor = {r=1, g=1, b=1, a=0.1};
        self:addChild(self.forceButton)
    end
end

function BobbyPinWindow:new(x, y, width, height)
    local o = {};
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.breakTimer = 0

    o.angleScrew = 0
    o.anglePick = -ZombRand(225, 406)
    o.keyAngle = ZombRand(178) + 1

    o.isEnd = false

    o.comboList = {};
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    o:setWantKeyEvents(true)
    return o;
end

-- B42.17 polled key handling
function BobbyPinWindow.onTick()
    local win = BobbyPinWindow.instance
    if win == nil or win.isEnd or win.breakTimer > 0 then return end

    local now = getTimeInMillis()
    win.deltaTime = now - (win.lastTick or now)
    win.lastTick = now

    if isKeyDown(Keyboard.KEY_A) or isKeyDown(Keyboard.KEY_D) or isKeyDown(Keyboard.KEY_W) or isKeyDown(Keyboard.KEY_S) then
        win.angleScrew = win.angleScrew + win.deltaTime * 0.23
        if win.angleScrew > win.maxAngle then 
            win.angleScrew = win.maxAngle
            if win.angleScrew == 90 then
                if win.goToOpen == nil or win.goToOpen == true then
                    win:doUnlock()
                else
                    win:doLock()
                end

                win.isEnd = true
                win.breakTimer = 1
            else
                pickLockHealth = pickLockHealth - win.deltaTime * 0.1
                if pickLockHealth <= 0 then
                    win.breakTimer = 3
                    win.character:playSoundLocal("bobby_fail")
                    pickLockHealth = 350

                    if ZombRand(100) < win.chanceBreakLock then
                        win:doBreakLock()
                        win:close()                    
                    end
                    
                    local zReBLBP = win.character:getInventory():getFirstTypeRecurse("BobbyPin")
                    local zReBLHBP = win.character:getInventory():getFirstTypeRecurse("HandmadeBobbyPin")
                    if zReBLBP then
                        zReBLBP:getContainer():DoRemoveItem(zReBLBP)
                    elseif zReBLHBP then
                        zReBLHBP:getContainer():DoRemoveItem(zReBLHBP)
                    else
                        win.breakTimer = 2
                        win.isFailEnd = true
                    end
                    if not (win.character:getInventory():getFirstTypeRecurse("BobbyPin") or win.character:getInventory():getFirstTypeRecurse("HandmadeBobbyPin")) then
                        win.breakTimer = 2
                        win.isFailEnd = true
                    end
                end
            end 
        end
    end

    win.angleScrew = win.angleScrew - win.deltaTime * 0.04
    if win.angleScrew < 0 then win.angleScrew = 0 end
end

Events.OnGameStart.Add(function()
    Events.OnTick.Add(BobbyPinWindow.onTick)
end)