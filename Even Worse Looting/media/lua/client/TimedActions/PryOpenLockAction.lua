--***********************************************************
--**                    ROBERT JOHNSON                     **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

PryOpenLockAction = ISBaseTimedAction:derive("PryOpenLockAction");

function PryOpenLockAction:isValid()

		if not self.character:hasEquippedTag("RemoveBarricade") then
			return false
		end
	
	return true;
end

function PryOpenLockAction:waitToStart()
	self.character:faceThisObject(self.item)
	return self.character:shouldBeTurning()
end

function PryOpenLockAction:update()
	self.character:faceThisObject(self.item)

    self.character:setMetabolicTarget(Metabolics.LightWork);
end

function PryOpenLockAction:start()
--    getSoundManager():PlayWorldSound("crackwood", false, self.character:getSquare(), 1, 5, 1, false)
   -- local barricade = self.item:getBarricadeForCharacter(self.character)

        self:setActionAnim("RemoveBarricade")
        
      
            self:setAnimVariable("RemoveBarricade", "CrowbarMid")

            self:setOverrideHandModels(self.character:getPrimaryHandItem(), nil)
       
        self.sound = self.character:playSound("BeginRemoveBarricadePlank");
        addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), 10, 1)

end

function PryOpenLockAction:stop()
	if self.sound then
		self.character:getEmitter():stopSound(self.sound)
		self.sound = nil
	end
    ISBaseTimedAction.stop(self);
end

function PryOpenLockAction:perform()
    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
        self.sound = nil
    end
	local part = self.character:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L)
	local stiffness = part:getStiffness()
	part:setStiffness(stiffness + 50 - (self.character:getPerkLevel(Perks.Strength) * 5))
	part = self.character:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R)
	stiffness = part:getStiffness()
	part:setStiffness(stiffness + 50 - (self.character:getPerkLevel(Perks.Strength) * 5))
	part = self.character:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L)
	stiffness = part:getStiffness()
	part:setStiffness(stiffness + 50 - (self.character:getPerkLevel(Perks.Strength) * 5))
	part = self.character:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R)
	stiffness = part:getStiffness()
	part:setStiffness(stiffness + 50 - (self.character:getPerkLevel(Perks.Strength) * 5))

	
	local tool = self.tool
	--print("tool " .. tostring(tool))
	if not tool then tool = self.character:getPrimaryHandItem() end
	
	if tool 
	and tool:getConditionLowerChance()
	and ZombRand(tool:getConditionLowerChance()) == 0
	then
		tool:setCondition(tool:getCondition() - 1)
		ISWorldObjectContextMenu.checkWeapon(self.character);
	end


	if ZombRand(10) < self.character:getPerkLevel(Perks.Strength) then
		self.character:playSound("BreakMetalItem")
		addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), 10, 1)


		local cont = self.item
		local mData = cont:getModData()
		
		local lock = nil
		
		if instanceof(cont, "IsoThumpable") then
			local lock = "Padlock_Snapped"
			cont:setLockedByPadlock(false);
			cont:setKeyId(-1);
			if cont:getLockedByCode() > 0 then
				lock = "CombinationPadlock_Snapped"
			end
			cont:setLockedByCode(0)
		end
		if mData.combinationLocked and mData.combinationLocked > 0 then
			lock = "CombinationPadlock_Snapped"
		end
		if mData and mData.locked then
			mData.locked = -1
			cont:transmitModData()
		end
		if mData and mData.combinationLocked then
			mData.combinationLocked = -1
			cont:transmitModData()
		end
		
		if lock then 
			local scrap = InventoryItemFactory.CreateItem(lock)
			--self.character:getInventory():AddItem(link)
			local square = self.character:getSquare()
			square:AddWorldInventoryItem(scrap, 0.0, 0.0, 0.0)	
		end
			
		getPlayerData(0).lootInventory:refreshBackpacks();
		getPlayerData(0).playerInventory:refreshBackpacks();
	else
		self.character:playSound("DoorIsLocked")		
	end
	
	
	ISBaseTimedAction.perform(self);
end

function PryOpenLockAction:new(character, item, tool, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.item = item;
	o.tool = tool
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time;
	if character:HasTrait("Handy") then
		o.maxTime = time - 20;
    end
    if character:isTimedActionInstant() then
        o.maxTime = 1;
    end
	return o;
end
