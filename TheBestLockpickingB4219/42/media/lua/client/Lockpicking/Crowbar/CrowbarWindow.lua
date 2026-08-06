require "Lockpicking/LockpickControlInterceptor"

local function predicateNotBroken(item)
    return not item:isBroken();
end

CrowbarWindow = ISPanel:derive("CrowbarWindow");

local WINDOW_WIDTH = 340
local WINDOW_HEIGHT = 150
local xShift = 20
local yShift = 40

local MODE_VEHICLE_DOOR = 0
local MODE_WINDOW = 1
local MODE_BUILDING_DOOR = 2

local arrowTex = getTexture("media/textures/BetLock_arrow.png")
local arrow_scale_step = 0
local arrowSpeed = 1
local arrow_dx = arrowSpeed
local arrow_step_to_x = (WINDOW_WIDTH - xShift*2)/100

local crowbarTimer = 0
local progressBarVal = 0

function CrowbarWindow:setVisible(visible)
    self.javaObject:setVisible(visible);
end

function CrowbarWindow:prerender()
    ISPanel.prerender(self)
    self:drawRect(xShift, yShift + 30, WINDOW_WIDTH - xShift*2, 20, 0.8, 1, 0, 0)
    self:drawRect(xShift + self.shiftYellow, yShift + 30, self.yellowSize*3, 20, 0.8, 1, 1, 0)
    self:drawRect(xShift + self.shiftGreen, yShift + 30, self.greenSize*3, 20, 0.8, 0, 1, 0)
    self:drawRectBorder(xShift, yShift + 30, WINDOW_WIDTH - xShift*2, 20, 1, 0.4, 0.4, 0.4)
end

local lastRenderMillis = nil
function CrowbarWindow:render()
    self:drawText(getText("UI_Controls_Crowbar"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Small, getText("UI_Controls_Crowbar")) / 2), 10, 1,1,1,1, UIFont.Small);
    self:drawProgressBar(xShift, yShift, WINDOW_WIDTH - xShift*2, 20, progressBarVal, {r=0, g=0.6, b=0, a=0.8 })
    self:drawRectBorder(xShift, yShift, WINDOW_WIDTH - xShift*2, 20, 1, 0.4, 0.4, 0.4)
    self:drawTexture(arrowTex, xShift - arrowTex:getWidth()/2 + arrow_scale_step*arrow_step_to_x, 75+30, 1, 1, 1, 1)
    
    local currentMillis = math.floor(getTimeInMillis())
    local isNewTimeStep = false
    if lastRenderMillis ~= currentMillis then
        lastRenderMillis = currentMillis
        isNewTimeStep = true
    end

    if crowbarTimer > 0 then return end
    
    local endurance = self.character:getStats():get(CharacterStat.ENDURANCE)
    if endurance <= 0.5 then
        self:close()
        return
    end
    
    if isNewTimeStep then
        arrow_scale_step = arrow_scale_step + arrow_dx * UIManager.getMillisSinceLastRender() * 0.12
        if arrow_scale_step >= 100 then
            arrow_scale_step = 100
            arrow_dx = -arrowSpeed
        elseif arrow_scale_step <= 0 then
            arrow_scale_step = 0
            arrow_dx = arrowSpeed
        end
    end
end

function CrowbarWindow:onOptionMouseDown(button, x, y)
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();
        self:close()
    end
end

function CrowbarWindow:doUnlock()
    if self.mode == MODE_VEHICLE_DOOR then
        sendClientCommand(self.character, 'crowbar', 'vehicleDoor', { vehicle=self.lockpick_object:getVehicle():getId(), part=self.lockpick_object:getId() })
        self.character:playSoundLocal("UnlockDoor");
    elseif self.mode == MODE_WINDOW then
        self.lockpick_object:setIsLocked(false)
		self.lockpick_object:setPermaLocked(false);
        local skill = self.character:getPerkLevel(Perks.Lockpicking)
        local modData = self.lockpick_object:getModData()
        local level = (modData.LockpickLevel and modData.LockpickLevel.num) or 1
        local chanceBreak = BetLock.Utils.getChanceBreakLock(skill, level)
        if ZombRand(100) < chanceBreak then
            self.lockpick_object:Damage(100)
        end
    else
        local originalKeyId = self.lockpick_object:getKeyId()
        self.lockpick_object:setLockedByKey(false);
        self.lockpick_object:setLocked(false);
        self.lockpick_object:setKeyId(-3);
        self.lockpick_object:Damage(50)
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
        sendClientCommand(self.character, 'BetLock', 'unlockBuildingDoor', {
            x = self.lockpick_object:getSquare():getX(),
            y = self.lockpick_object:getSquare():getY(),
            z = self.lockpick_object:getSquare():getZ(),
            keyId = originalKeyId,
            crowbar = true
        })
        -- B42.19: setOpen(true) removed, bypasses animation and causes door state desync
        self.character:playSoundLocal("UnlockDoor");
    end
    sendClientCommand(self.character, "BetLock", "addLockpickingXP", {amount = self.addingXP or 5})
    self.character:getXp():AddXPHaloText(Perks.Lockpicking, self.addingXP or 5)
end

function CrowbarWindow:close()
    self.character:getModData().zReBLStopFlag = 1
    self.lockpick_object:getModData()["BetLock_crowbarProgressBar"] = progressBarVal
    self.character:getModData().isLockpicking = false
    ISTimedActionQueue.clear(self.character)
    CrowbarWindow.instance = nil
    ISPanel.close(self)
end

function CrowbarWindow:createVehicleDoor(playerObj, part)
    local modal = CrowbarWindow:new(Core:getInstance():getScreenWidth()/2 - WINDOW_WIDTH/2 + 300, Core:getInstance():getScreenHeight()/2 - 500/2, WINDOW_WIDTH, WINDOW_HEIGHT)
    modal.lockpick_object = part
    modal.mode = MODE_VEHICLE_DOOR
    modal.character = playerObj
    local vehModData = part:getVehicle() and part:getVehicle():getModData() or {}
    modal.diffLevel = (vehModData.LockpickLevel and vehModData.LockpickLevel.num) or 1
    modal.addingXP = (vehModData.LockpickLevel and vehModData.LockpickLevel.xp) or 5
    modal.isGarage = false
    modal:initialise()
    modal:addToUIManager()
end

function CrowbarWindow:createBuildingWindow(playerObj, window)
    local dx = window:getSquare():getX() - playerObj:getSquare():getX()
    local dy = window:getSquare():getY() - playerObj:getSquare():getY()
    local zGood = math.abs(window:getSquare():getZ() - playerObj:getSquare():getZ()) < 2
    local dist = math.sqrt(dx*dx + dy*dy)
    
    if not zGood or dist > 2 then return end
    if not window:isLocked() then
        playerObj:Say(getText("UI_window_is_unlocked"))
        return
    end
    
    local modal = CrowbarWindow:new(Core:getInstance():getScreenWidth()/2 - WINDOW_WIDTH/2 + 300, Core:getInstance():getScreenHeight()/2 - 500/2, WINDOW_WIDTH, WINDOW_HEIGHT)
    modal.lockpick_object = window
    modal.mode = MODE_WINDOW
    modal.character = playerObj
    local modData = window:getModData()
    modal.diffLevel = (modData.LockpickLevel and modData.LockpickLevel.num) or 1
    modal.addingXP = (modData.LockpickLevel and modData.LockpickLevel.xp) or 5
    modal.isGarage = false

    -- B42.17 facing fix (getPlayerMoveDir removed)
    if playerObj and window then
        playerObj:faceThisObject(window)
    end

    modal:initialise()
    modal:addToUIManager()
end

function CrowbarWindow:createBuildingDoor(playerObj, door)
    if not door or not playerObj then return end

    local dx = door:getSquare():getX() - playerObj:getSquare():getX()
    local dy = door:getSquare():getY() - playerObj:getSquare():getY()
    local zGood = math.abs(door:getSquare():getZ() - playerObj:getSquare():getZ()) < 2
    local dist = math.sqrt(dx*dx + dy*dy)
    
    if not zGood or dist > 2 then return end

    if not door:isLocked() then
        playerObj:Say(getText("UI_door_is_unlocked"))
        return
    end

    local modal = CrowbarWindow:new(Core:getInstance():getScreenWidth()/2 - WINDOW_WIDTH/2 + 300, Core:getInstance():getScreenHeight()/2 - 500/2, WINDOW_WIDTH, WINDOW_HEIGHT)
    modal.lockpick_object = door
    modal.mode = MODE_BUILDING_DOOR
    modal.character = playerObj
    modal.isGarage = IsoDoor.getGarageDoorIndex(door) ~= -1

    -- B42.17 SAFE modData
    local modData = door:getModData()
    modal.diffLevel = (modData.LockpickLevel and modData.LockpickLevel.num) or 1
    modal.addingXP = (modData.LockpickLevel and modData.LockpickLevel.xp) or 5

    -- B42.17 facing fix (getPlayerMoveDir removed)
    if playerObj and door then
        playerObj:faceThisObject(door)
    end

    modal:initialise()
    modal:addToUIManager()
end

function CrowbarWindow:initialise()
    if not self.lockpick_object then return end
    if not self.character then return end
	local crowbarinv = self.character:getInventory():getFirstTagEvalRecurse(ItemTag.CROWBAR, predicateNotBroken);
    if not crowbarinv then return end

    ISPanel.initialise(self)
    self:create()
    CrowbarWindow.instance = self

    local zReBLStrength = self.character:getPerkLevel(Perks.Strength)
    local skill = zReBLStrength <= 3 and 0 or math.max(0, zReBLStrength - 3)
    local sizes = BetLock.Utils.getGreenYellowSize(skill, self.diffLevel or 1)
    self.maxGreenSize = sizes[1]  
    self.yellowSize = sizes[2]    

    local endurance = self.character:getStats():get(CharacterStat.ENDURANCE)
    self.greenSize = self.maxGreenSize * (0.2 + 0.8 * (endurance - 0.5))
    if self.greenSize < 1 then self.greenSize = 1 end

    self.shiftYellow = ZombRand(100 - math.ceil(self.yellowSize)) * 3
    if self.shiftYellow < 0 then self.shiftYellow = 0 end
    if self.shiftYellow > (100 - math.ceil(self.yellowSize)) * 3 then self.shiftYellow = (100 - math.ceil(self.yellowSize)) * 3 end
    self.shiftGreen = self.shiftYellow + (self.yellowSize - self.greenSize) * 1.5

    progressBarVal = self.lockpick_object:getModData()["BetLock_crowbarProgressBar"] or 0
    self.character:getModData().isLockpicking = true
    ISTimedActionQueue.clear(self.character)
    ISTimedActionQueue.add(CrowbarActionAnim:new(self.character, self.isGarage, self.lockpick_object))
end

function CrowbarWindow:create()
    self.cancel = ISButton:new((self:getWidth() / 2) - 50, self:getHeight() - 25, 100, 20, getText("UI_Cancel"), self, CrowbarWindow.onOptionMouseDown);
    self.cancel.internal = "CANCEL";
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.cancel);
end

function CrowbarWindow:new(x, y, width, height)
    local o = {};
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    o:setWantKeyEvents(true)
    return o;
end

function CrowbarWindow:ActionKeyPressed()
    local zReBLSkillStrength = self.character:getPerkLevel(Perks.Strength)
    local zReBLSkillFitness = self.character:getPerkLevel(Perks.Fitness)
    local zReBLSkillLockpicking = self.character:getPerkLevel(Perks.Lockpicking)
    local endurance = self.character:getStats():get(CharacterStat.ENDURANCE)
    
    local zReLPSTR_1 = 1
    local zReLPSTR_2 = 0
    local zReLPSTR_3 = 0
    local zReLPFIT = 0
    if zReBLSkillLockpicking <= 1 then
        zReLPSTR_1 = 1 zReLPSTR_2 = 0 zReLPSTR_3 = 0 zReLPFIT = 0
    elseif zReBLSkillLockpicking <= 4 then
        zReLPSTR_1 = 2 zReLPSTR_2 = 1 zReLPSTR_3 = 0 zReLPFIT = 0.15
    elseif zReBLSkillLockpicking == 5 then
        zReLPSTR_1 = 3 zReLPSTR_2 = 2 zReLPSTR_3 = 1 zReLPFIT = 0.25
    elseif zReBLSkillLockpicking <= 8 then
        zReLPSTR_1 = 4 zReLPSTR_2 = 3 zReLPSTR_3 = 2 zReLPFIT = 0.35
    else
        zReLPSTR_1 = 5 zReLPSTR_2 = 4 zReLPSTR_3 = 3 zReLPFIT = 0.5
    end
    
    local zReSTR_1 = 9
    local zReSTR_2 = 6
    local zReSTR_3 = 4
    if zReBLSkillStrength <= 1 then
        zReSTR_1 = 9 zReSTR_2 = 6 zReSTR_3 = 4
    elseif zReBLSkillStrength <= 4 then
        zReSTR_1 = 10 zReSTR_2 = 7 zReSTR_3 = 5
    elseif zReBLSkillStrength == 5 then
        zReSTR_1 = 12 zReSTR_2 = 8 zReSTR_3 = 6
    elseif zReBLSkillStrength <= 8 then
        zReSTR_1 = 15 zReSTR_2 = 10 zReSTR_3 = 7
    else
        zReSTR_1 = 18 zReSTR_2 = 12 zReSTR_3 = 9
    end

    local zReFIT = 4.8
    if zReBLSkillFitness <= 1 then zReFIT = 4.8
    elseif zReBLSkillFitness <= 4 then zReFIT = 4.0
    elseif zReBLSkillFitness == 5 then zReFIT = 3.2
    elseif zReBLSkillFitness <= 8 then zReFIT = 2.4
    else zReFIT = 1.6 end
    local zReFIT_1 = zReFIT
    local zReFIT_2 = zReFIT * 1.75
    local zReFIT_3 = zReFIT * 2.5

    if crowbarTimer > 0 then return end
	
	local bd = self.character:getBodyDamage()
    local upperArmL = bd:getBodyPart(BodyPartType.UpperArm_L)
    local upperArmR = bd:getBodyPart(BodyPartType.UpperArm_R)
    local foreArmL  = bd:getBodyPart(BodyPartType.ForeArm_L)
    local foreArmR  = bd:getBodyPart(BodyPartType.ForeArm_R)

    local stiffnessAdd = 0
    local enduranceDrain = 0

    if arrow_scale_step >= self.shiftGreen/3 and arrow_scale_step <= (self.shiftGreen/3 + self.greenSize) then
        progressBarVal = progressBarVal + (zReSTR_1 + zReLPSTR_1)/100
		enduranceDrain = (zReFIT_1 - zReLPFIT)/200
        stiffnessAdd = 1.2
        crowbarTimer = 10

    elseif arrow_scale_step >= self.shiftYellow/3 and arrow_scale_step <= (self.shiftYellow/3 + self.yellowSize) then
        progressBarVal = progressBarVal + (zReSTR_2 + zReLPSTR_2)/100
		enduranceDrain = (zReFIT_2 - zReLPFIT)/200
        stiffnessAdd = 2.5
        crowbarTimer = 25

    else
        progressBarVal = progressBarVal + (zReSTR_3 + zReLPSTR_3)/100
		enduranceDrain = (zReFIT_3 - zReLPFIT)/200
        stiffnessAdd = 4.0
        crowbarTimer = 50
    end
	
    local reduction = math.max(0.45, 1 - (zReBLSkillStrength * 0.045 + zReBLSkillFitness * 0.032))

    sendClientCommand(self.character, "crowbar", "applyDrain", {
        enduranceDrain = enduranceDrain,
        stiffnessAdd   = stiffnessAdd * reduction
    })

    self.greenSize = self.maxGreenSize * (0.2 + 0.8 * (endurance - 0.5))
    if self.greenSize < 1 then self.greenSize = 1 end

    self.shiftYellow = ZombRand(100 - math.ceil(self.yellowSize)) * 3
    if self.shiftYellow < 0 then self.shiftYellow = 0 end
    if self.shiftYellow > (100 - math.ceil(self.yellowSize)) * 3 then self.shiftYellow = (100 - math.ceil(self.yellowSize)) * 3 end
    self.shiftGreen = self.shiftYellow + (self.yellowSize - self.greenSize) * 1.5

    if progressBarVal >= 1.0 then
        self.isEnd = true
        self:doUnlock()
    end
end

CrowbarWindow.OnKeyStartPressed = function(key)
    if CrowbarWindow.instance == nil then return end
    local win = CrowbarWindow.instance
    if key == Keyboard.KEY_SPACE then win:ActionKeyPressed() end
    if key == Keyboard.KEY_ESCAPE then
        win:setVisible(false);
        win:removeFromUIManager();
        win:close()
    end
end

local lastMillis = nil
CrowbarWindow.onTick = function()
    local currentMillis = math.floor(getTimeInMillis()/50)
    if lastMillis ~= currentMillis then
        lastMillis = currentMillis
        if CrowbarWindow.instance == nil then return end
        if crowbarTimer > 0 then
            crowbarTimer = crowbarTimer - 1
            if crowbarTimer == 0 and CrowbarWindow.instance.isEnd then
                CrowbarWindow.instance:close()
            end
        end
    end
end

Events.OnKeyStartPressed.Add(CrowbarWindow.OnKeyStartPressed);
Events.OnTick.Add(CrowbarWindow.onTick);