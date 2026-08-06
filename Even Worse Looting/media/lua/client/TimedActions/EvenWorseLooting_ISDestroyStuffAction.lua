require "TimedActions/ISDestroyStuffAction"


function ISDestroyStuffAction:perform()
	-- we add the items contained inside the item we destroyed to put them randomly on the ground
	for i=1,self.item:getContainerCount() do
		local container = self.item:getContainerByIndex(i-1)
		for j=1,container:getItems():size() do
			local item = container:getItems():get(j-1)
			if item:getCondition() and (not item:isBroken()) then
				local maxC = item:getCondition()-1
				if maxC < 1 then maxC = 1 end
				item:setCondition(ZombRand(1, maxC))
				if item:getCondition() > maxC then item:setCondition(maxC) end
			end
			if instanceof(item, "HandWeapon") and ZombRand(0,2) == 0 then item:setBroken(true) end
			if item:isBroken() then item:setCondition(0) end
			self.item:getSquare():AddWorldInventoryItem(item, 0.0, 0.0, 0.0)
		end
	end
	-- local pdata = getPlayerData(self.character:getPlayerNum())
	-- pdata.lootInventory:refreshBackpacks();
	-- pdata.playerInventory:refreshBackpacks();


	-- destroy window if wall is destroyed
	if self.item:getSquare():getWall(false) == self.item or self.item:getSquare():getWall(true) == self.item then
		for i=0,self.item:getSquare():getSpecialObjects():size()-1 do
			local o = self.item:getSquare():getSpecialObjects():get(i)
			if instanceof(o, 'IsoWindow') and (o:getNorth() == self.item:getProperties():Is(IsoFlagType.cutN)) then
				self.item = o
				break
			end
		end
	end

	-- destroy barricades if door or window is destroyed
	if instanceof(self.item, 'IsoDoor') or (instanceof(self.item, 'IsoThumpable') and self.item:isDoor()) or
			instanceof(self.item, 'IsoWindow') then
		local barricade1 = self.item:getBarricadeOnSameSquare()
		local barricade2 = self.item:getBarricadeOnOppositeSquare()
		if barricade1 then
			barricade1:getSquare():transmitRemoveItemFromSquare(barricade1)
			barricade1:getSquare():RemoveTileObject(barricade1)
		end
		if barricade2 then
			barricade2:getSquare():transmitRemoveItemFromSquare(barricade2)
			barricade2:getSquare():RemoveTileObject(barricade2)
		end
	end

	-- remove curtains if window is destroyed
	if instanceof(self.item, 'IsoWindow') and self.item:HasCurtains() then
		local curtains = self.item:HasCurtains()
		curtains:getSquare():transmitRemoveItemFromSquare(curtains)
		local sheet = InventoryItemFactory.CreateItem("Base.Sheet")
		self.item:getSquare():AddWorldInventoryItem(sheet, 0, 0, 0)
    end
    -- remove sheet rope too
    if instanceof(self.item, 'IsoWindow') or instanceof(self.item, 'IsoThumpable') then
        self.item:removeSheetRope(nil);
    end

	if instanceof(self.item, 'IsoCurtain') and self.item:getSquare() then
		local sheet = InventoryItemFactory.CreateItem("Base.Sheet")
		self.item:getSquare():AddWorldInventoryItem(sheet, 0, 0, 0)
	end
	
	-- toggle off if it was a generator
	if instanceof(self.item, 'IsoGenerator') then
		self.item:setActivated(false);
	end

	-- Hack, should we do triggerEvent("OnDestroyIsoThumpable") here?
	-- When you destroy with an axe, you get "need:XXX" materials back.
	if isClient() then
		local sq = self.item:getSquare()
		local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ(), index = self.item:getObjectIndex() }
		sendClientCommand(self.character, 'object', 'OnDestroyIsoThumpable', args)
	end

	-- Destroy all 3 stair objects (and sometimes the floor at the top)
	local stairObjects = buildUtil.getStairObjects(self.item)
	-- Destroy all 4 double-door objects
	local doubleDoorObjects = buildUtil.getDoubleDoorObjects(self.item)
	local garageDoorObjects = buildUtil.getGarageDoorObjects(self.item)
	local graveObjects = buildUtil.getGraveObjects(self.item)
	if #stairObjects > 0 then
		for i=1,#stairObjects do
            if isClient() then
                sledgeDestroy(stairObjects[i]);
			else
				stairObjects[i]:getSquare():transmitRemoveItemFromSquare(stairObjects[i])
			end
		end
	elseif #doubleDoorObjects > 0 then
		for i=1,#doubleDoorObjects do
			if isClient() then
				sledgeDestroy(doubleDoorObjects[i]);
			else
				doubleDoorObjects[i]:getSquare():transmitRemoveItemFromSquare(doubleDoorObjects[i])
			end
		end
	elseif #garageDoorObjects > 0 then
		for i=1,#garageDoorObjects do
			local object = garageDoorObjects[i]
			if isClient() then
				sledgeDestroy(object)
			else
				object:getSquare():transmitRemoveItemFromSquare(object)
			end
		end
	elseif #graveObjects > 0 then
		for i=1,#graveObjects do
			if isClient() then
				sledgeDestroy(graveObjects[i]);
			else
				graveObjects[i]:getSquare():transmitRemoveItemFromSquare(graveObjects[i])
			end
		end
    else
        if isClient() then
            sledgeDestroy(self.item);
		else
			self.item:getSquare():transmitRemoveItemFromSquare(self.item)
		end
	end

--~ 	local aboveGrid = getCell():getGridSquare(self.item:getSquare():getX(), self.item:getSquare():getY(), self.item:getSquare():getZ() + 1);
--~ 	if aboveGrid then
--~ 		print("grid exist");
--[[ do this only if the destroyed object was a lower crate;  it doesn't handle carpentry crates
		for i=0, self.item:getSquare():getObjects():size() - 1 do
			local itemAbove = self.item:getSquare():getObjects():get(i);
			if itemAbove:getSprite() then
				if itemAbove:getSprite():getName() == "carpentry_01_17" then
					itemAbove:setSprite(getSprite("carpentry_01_16"));
				end
				if itemAbove:getSprite():getName() == "carpentry_01_18" then
					itemAbove:setSprite(getSprite("carpentry_01_17"));
				end
			end
		end
--]]
--~ 	end

--	getSoundManager():PlaySound("breakdoor", false, 1);
	-- add a sound to the list so zombie/npc can hear it
	addSound(self.character, self.character:getX(),self.character:getY(),self.character:getZ(), 10, 10);
    -- reduce the sledge condition
    local sledge = self.character:getPrimaryHandItem();
    if ZombRand(sledge:getConditionLowerChance() * 2) == 0 then
        sledge:setCondition(sledge:getCondition() - 1);
        ISWorldObjectContextMenu.checkWeapon(self.character);
    end

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end