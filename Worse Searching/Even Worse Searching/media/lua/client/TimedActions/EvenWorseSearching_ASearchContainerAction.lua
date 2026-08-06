require "TimedActions/PASearchContainerAction"

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
		--parent:transmitModData()
	--end
	elseif self.container:getVehiclePart() then
		--print("Vehicle Part")
		local parent = self.container:getVehiclePart()
		local mData = parent:getModData()
		mData.searched = true
		if mData.movableData then mData.movableData.seached = true end
		--parent:transmitModData()
	--end
	elseif self.container:getParent() then
	--if self.container:getParent() then
		--print("Parent")
		local parent = self.container:getParent()
		local mData = parent:getModData()
		mData.searched = true
		if mData.movableData then mData.movableData.seached = true end
		if isClient() then
			local name = self.character:getUsername()
			local square = self.container:getSourceGrid()
			--print("Client Name " .. tostring(name))
			if square then 
				local safehouse = SafeHouse.getSafeHouse(square)
				if safehouse then 
					--print("Safehouse " .. tostring(safehouse))
					if safehouse:playerAllowed(self.character) then
						--print("Player safehouse")
						parent:transmitModData()
					end

				end				
			end
		end
		--parent:transmitModData()
	end
	-- if isClient() and self.srcContainer:getSourceGrid() and SafeHouse.isSafeHouse(self.srcContainer:getSourceGrid(), self.character:getUsername(), true) then
        -- return false;
	-- end
	
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
			
	local pdata = getPlayerData(0)
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