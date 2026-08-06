require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"

require "Definitions/ContainerButtonIcons"

require "defines"


require "ISUI/ISInventoryPage"


local old_searched_ISInventoryPane_lootAll = ISInventoryPane.lootAll

function ISInventoryPane:lootAll()


	local object = self.inventory:getVehiclePart() or self.inventory:getParent() or self.inventory:getContainingItem()
	local mData = nil
	if object and object:getModData() then
		--print("object")
		mData = object:getModData()
		if button 
		and button.inventory 
		and button.inventory:getParent() 
		and instanceof(button.inventory:getParent(), "IsoPlayer") and mData 
		then mData.searched = true end
		searched = mData.searched
	end
	--print("Searched? " .. tostring(searched))
	
    -- if button and button.inventory and button.inventory:getType() and button.inventory:getType() == "floor" then
		-- print("Floor")
	-- --or instanceof(button.inventory:getParent(), "IsoPlayer")	then
        -- searched = true
    -- end
	if self.inventory:getType() == "floor" then
        searched = true
    end
	
	
	if not searched then return false end

	old_searched_ISInventoryPane_lootAll(self)

	-- local playerObj = getSpecificPlayer(self.player)
	-- local playerInv = getPlayerInventory(self.player).inventory
	-- local items = {}
	-- local it = self.inventory:getItems();
	-- local heavyItem = nil
	-- if luautils.walkToContainer(self.inventory, self.player) then
		-- for i = 0, it:size()-1 do
			-- local item = it:get(i);
			-- if isForceDropHeavyItem(item) then
				-- heavyItem = item
			-- else
				-- table.insert(items, item)
			-- end
		-- end
		-- if heavyItem and it:size() == 1 then
			-- ISInventoryPaneContextMenu.equipHeavyItem(playerObj, heavyItem)
			-- return
		-- end
		-- self:transferItemsByWeight(items, playerInv)
	-- end
	-- self.selected = {};
	-- getPlayerLoot(self.player).inventoryPane.selected = {};
	-- getPlayerInventory(self.player).inventoryPane.selected = {};
end