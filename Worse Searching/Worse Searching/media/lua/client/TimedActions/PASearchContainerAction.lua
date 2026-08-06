--***********************************************************
--**                    ROBERT JOHNSON                     **
--***********************************************************
--local button = nil
require "TimedActions/ISBaseTimedAction"

PASearchContainerAction = ISBaseTimedAction:derive("PASearchContainerAction");

function PASearchContainerAction:isValid()
	local mData = nil
	if self.container:getContainingItem() then
		local parent = self.container:getContainingItem()
		mData = parent:getModData()
	elseif self.container:getVehiclePart() then
		local parent = self.container:getVehiclePart()
		mData = parent:getModData()
	elseif self.container:getParent() then
		local parent = self.container:getParent()
		mData = parent:getModData()
	end
	if mData.searched then return false end
	if mData.combinationLocked and mData.combinationLocked > 0 then return false end
	if mData.locked and mData.locked > 0 then return false end
	return true
end


function PASearchContainerAction:waitToStart()	
	--print("Wait") 
	if self.character:getVehicle() then return false end
	self.character:faceThisObject(self.container:getParent())
	return self.character:shouldBeTurning()
end


function PASearchContainerAction:update()
	--print("update")
	self.character:faceThisObject(self.container:getParent())
	if not self.sound then
		self.sound = self.character:getEmitter():playSound("PutItemInBag2")
	end
	
end

function PASearchContainerAction:start()
	--print("start")
	-- self:setActionAnim("Loot");
	-- if ( self.container:getParent() and self.container:getParent():getSprite() and self.container:getParent():getSprite():getProperties():Is("MoveType")=="WallObject") then
		
	-- elseif  self.character:isSneaking()
	-- or (self.container:getParent() and ISMoveableSpriteProps:getTotalTableHeight(self.container:getParent():getSquare()) < 1 )
	-- then
		-- self:setAnimVariable("LootPosition", "Low");
	-- end
	-- self:setOverrideHandModels(nil, nil);
	
    self.sound = self.character:getEmitter():playSound("PutItemInBag2")
	local cont = self.container

	self:setActionAnim("Loot");
	self:setAnimVariable("LootPosition", "");
	self:setOverrideHandModels(nil, nil);
	self.character:clearVariable("LootPosition");
	if cont:getContainerPosition() then
		self:setAnimVariable("LootPosition", cont:getContainerPosition());
	end
	if cont:getType() == "freezer" and cont:getFreezerPosition() then
		self:setAnimVariable("LootPosition", cont:getFreezerPosition());
	end
	if instanceof(cont:getParent(), "IsoDeadBody") or cont:getType() == "floor" then
		self:setAnimVariable("LootPosition", "Low");
	end
	if cont:getContainingItem() and cont:getContainingItem():getWorldItem() then
		self:setAnimVariable("LootPosition", "Low");
	end
	self.character:playSound("PutItemInBag");
	
	--if self.container:getPart() then print("INVENTORY ITEM!") end




end

function PASearchContainerAction:stop()	
	if self.sound then
		self.character:getEmitter():stopSound(self.sound)
		self.sound = nil
	end
	--print("stop")
    ISBaseTimedAction.stop(self);
end

function PASearchContainerAction:perform()
	if self.sound then
		self.character:getEmitter():stopSound(self.sound)
		self.sound = nil
	end
	--print("perform")
	self.container:setExplored(true);
	
	if self.container:getContainingItem() then
		--print("Item")
		local parent = self.container:getContainingItem()
		--local parent = self.container:getParent()
		local mData = parent:getModData()
		mData.searched = true
		if mData.movableData then mData.movableData.seached = true end
		parent:transmitModData()
	--end
	elseif self.container:getVehiclePart() then
		--print("Vehicle Part")
		local parent = self.container:getVehiclePart()
		local mData = parent:getModData()		
		local vehicle = parent:getVehicle()
		mData.searched = true
		if mData.movableData then mData.movableData.seached = true end
		-- parent:transmitModData()
		-- Vehicles.Update.Searched(vehicle, parent)
		-- WorseSearching_ServerVehicles(parent)
		
		-- print("Part " .. tostring(parent))
		-- print("PartID " .. tostring(parent:getId()))
		-- print("Vehicle " .. tostring(vehicle))
		-- print("VehicleID " .. tostring(vehicle:getId()))
		sendClientCommand(self.character, "Worse_Searching", "Searched", { part = parent:getId(), vehicle = vehicle:getId()})
		-- print("Sending Vehicle Search")
	--end
	elseif self.container:getParent() then
	--if self.container:getParent() then
		--print("Parent")
		local parent = self.container:getParent()
		local mData = parent:getModData()
		mData.searched = true
		if mData.movableData then mData.movableData.seached = true end
		parent:transmitModData()
	end
	
	-- if self.container:getParent() then
		-- --print("Parent")
		-- local parent = self.container:getParent()
		-- local mData = parent:getModData()
		-- mData.searched = true
		-- if mData.movableData then mData.movableData.seached = true end
	-- end
	
	-- if self.container:getContainingItem() then
		-- --print("Item")
		-- local parent = self.container:getContainingItem()
		-- --local parent = self.container:getParent()
		-- local mData = parent:getModData()
		-- mData.searched = true
		-- if mData.movableData then mData.movableData.seached = true end
	-- end
	local playerNum = self.character:getPlayerNum()		
	local pdata = getPlayerData(playerNum)
	pdata.lootInventory:refreshBackpacks();
	pdata.playerInventory:refreshBackpacks();
	
	--print("Self Button Send - " .. tostring(self.button))
	--ISInventoryPage.selectContainer2(self.button)
	--selectContainer2(self.button, self.containers)
	--print("Self Button Send - " .. tostring(self.button))
	
	self.action:stopTimedActionAnim();
	self.action:setLoopedAction(false);
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end


function PASearchContainerAction:new(button, playerObj)--character, container, time)
-- function PASearchContainerAction:new(button, containers)--character, container, time)
-- function PASearchContainerAction:new(playerObj, button, containers)--character, container, time)
	--button = button
	--print("new - " .. tostring(button.inventory:getParent()))
	--print("new Button - " .. tostring(button))
	--print("new Containers - " .. tostring(containers))
	local o = {}
	setmetatable(o, self)
	self.__index = self
	--o.character = character;
	-- local playerObj = getPlayer()
	--button.inventory = 
	o.button = button
	--o.button.inventory = button.inventory
	o.character =  playerObj
	o.container = button.inventory
	o.containers = containers
	o.item = nil;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	local time = button.inventory:getMaxWeight()
	+ (button.inventory:getCapacityWeight() * 2)
	if playerObj:HasTrait("Dextrous") then
		time = time * 0.5
	end
	if playerObj:HasTrait("AllThumbs") then
		time = time * 1.5
	end
	time = time*2.5
	--print("time?", time)
	o.maxTime = time;
	--print("Max time?", tostring(o.maxTime))
	--o.loopedAction = true;
	--o:checkQueueList();
	return o
end
