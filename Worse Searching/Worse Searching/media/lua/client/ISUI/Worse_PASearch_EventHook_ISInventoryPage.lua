require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"

require "Definitions/ContainerButtonIcons"

require "defines"


require "ISUI/ISInventoryPage"

monsterX = nil



local function PA_WorseSearching_Unsearched (self, dunno)
	--print("Test 1")
	 ISInventoryPage:PA_WorseSearching_Unsearched (self, dunno)
end

-- function ISInventoryPage:PA_WorseSearching_Unsearched (self, dunno)
	-- --print("WORSE")
	-- --PASearchContainerAction:new(button) 
	-- for k,containerButton in ipairs(self.backpacks) do
		-- local item = nil
		-- local mData = nil
		-- --print("Container:" .. tostring(containerButton.inventory))
		-- --print("Backpack:" .. tostring((self.backpacks[k])))
		
		-- -- if containerButton.inventory:getContainingItem() ~= nil then
			-- -- item = containerButton.inventory:getContainingItem() end
		-- if containerButton.inventory:getContainingItem()  ~= nil 
		-- and not instanceof(containerButton.inventory:getContainingItem() , "IsoPlayer")		
		-- then
			-- item = containerButton.inventory:getContainingItem()  end
			-- --print("Item " .. tostring(item))
			-- if item and item:getType() then
		-- elseif containerButton.inventory:getVehiclePart() ~= nil 
		-- then
			-- item = containerButton.inventory:getVehiclePart() end
			-- print("Vehicle Part " .. tostring(item))
			-- print("Vehicle Part " .. tostring(item:getType()))
			-- if item and item:getType() then
								
		-- elseif containerButton.inventory:getParent() ~= nil 
		-- and not instanceof(containerButton.inventory:getParent(), "IsoPlayer")		
		-- then
			-- item = containerButton.inventory:getParent() end
			-- --print("Item " .. tostring(item))
			-- if item and item:getType() then
				-- --print(" - " .. tostring(item:getType()))
		-- end
		-- if item then
			-- --print("MData")
			-- --print(" - " .. tostring(item:getType()))
			-- mData = item:getModData()
			-- if instanceof(containerButton.inventory:getParent(), "IsoPlayer") then mData.searched = true end	
		-- end
		-- --if mData and not mData.searched then
			-- --print("Not searched")
			-- --containerButton.inventory:setExplored(false) end

		-- --if not containerButton.inventory:isExplored() 
		-- --if not containerButton.inventory:isExplored() 
		-- if mData
		-- and (not mData.searched )
		-- and (not instanceof(containerButton.inventory:getParent(), "IsoPlayer"))
		-- then
			-- --print("Unsearched container 2")
			-- containerButton.textureOverride = getTexture("media/ui/questionMark.png")
			-- containerButton:setTextureRGBA(0.1, 0.1, 0.1, 1.0);
			-- containerButton:setBackgroundRGBA(0.5, 0.5, 0.5, 1.0)
			-- if mData.locked and mData.locked > 0 then				
				-- containerButton.textureOverride = getTexture("media/ui/lock.png")
			-- end
			-- --print("Self Unsearched .. " .. tostring(self))
			-- --containerButton.onclick = ISInventoryPage.selectUnsearchedContainer(containerButton, self)
			-- --monsterX = self
			-- --print("Index Alpha - " .. tostring(self:getCurrentBackpackIndex()) .. " - " .. tostring(k))
			
			-- --containerButton.onclick = ISInventoryPage.selectUnsearchedContainer
			-- containerButton.onclick = ISInventoryPage.selectContainer
			-- containerButton.onmousedown = nil
			-- --containerButton:setOnMouseOverFunction(nil)
			-- containerButton:setOnMouseOutFunction(nil)
			
		-- end

	-- end


-- end



--Events.OnRefreshInventoryWindowContainers.Add(ISInventoryPage.PA_WorseSearching_Unsearched);
Events.OnRefreshInventoryWindowContainers.Add(PA_WorseSearching_Unsearched);







