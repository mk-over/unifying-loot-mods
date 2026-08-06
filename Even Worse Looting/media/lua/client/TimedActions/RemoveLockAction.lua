--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

RemoveLockAction = ISBaseTimedAction:derive("RemoveLockAction");

function RemoveLockAction:isValid()
	return true;
end


function RemoveLockAction:waitToStart()
	self.character:faceThisObject(self.cont)
	return self.character:shouldBeTurning()
end

function RemoveLockAction:update()
	self.character:faceThisObject(self.cont)
end

function RemoveLockAction:start()
	self:setActionAnim("Loot");
	self:setOverrideHandModels(nil, nil); 
    self.character:getEmitter():playSound("LockDoor");
end

function RemoveLockAction:stop()
    ISBaseTimedAction.stop(self);
end

function RemoveLockAction:perform()
    self.character:getEmitter():playSound("UnlockDoor");
	local mData = self.cont:getModData()
	local padlock = nil
	local combination = nil
	
	if mData.padlocked then padlock = true end
	if mData.combinationLocked and mData.combinationLocked > 0 then combination = true end	
	
	if not combination then
		if padlock then
			local padlock = self.character:getInventory():AddItem("Base.Padlock");			
			local keyToUse = self.character:getInventory():haveThisKeyId(mData.locked);
			padlock:setNumberOfKey(1);
			padlock:setKeyId(keyToUse:getKeyId());
			if self.character:getPrimaryHandItem() == keyToUse then self.character:setPrimaryHandItem(nil) end
			if self.character:getSecondaryHandItem() == keyToUse then self.character:setSecondaryHandItem(nil) end
			keyToUse:getContainer():Remove(keyToUse);
		end
		if mData and mData.locked then mData.locked = -1 end
		if mData and mData.combinationLocked then mData.combinationLocked = -1 end
		if mData and mData.padlocked then mData.combination = nil end
		self.cont:transmitModData()
	elseif combination then
		local padlock = self.character:getInventory():AddItem("Base.CombinationPadlock");
		if mData and mData.locked then mData.locked = -1 end
		if mData and mData.combinationLocked then mData.combinationLocked = -1 end
		if mData and mData.padlocked then mData.combination = nil end
		self.cont:transmitModData()
	end
	
	getPlayerData(0).lootInventory:refreshBackpacks();
	getPlayerData(0).playerInventory:refreshBackpacks();
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function RemoveLockAction:new(character, cont)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.cont = cont;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = 50;
	return o;
end
