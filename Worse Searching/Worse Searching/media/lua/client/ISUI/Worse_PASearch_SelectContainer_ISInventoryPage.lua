require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"

require "Definitions/ContainerButtonIcons"

require "defines"

require "ISUI/ISInventoryPage"


local ISInventoryPage_old_searched_selectContainer = ISInventoryPage.selectContainer

function ISInventoryPage:selectContainer(button)

	local playerObj = getSpecificPlayer(self.player)

	local searched = nil
	local locked = nil
	
	
	local object = self.inventory:getVehiclePart() or self.inventory:getParent() or self.inventory:getContainingItem()
	local mData = nil
	if object and object:getModData() then
		--print("object")
		mData = object:getModData()
		if instanceof(button.inventory:getParent(), "IsoPlayer") then mData.searched = true end
		searched = mData.searched
		if mData.locked and mData.locked > 0 then locked = true end
	end
	
	
    if button.inventory:getType() == "floor" then
	--or instanceof(button.inventory:getParent(), "IsoPlayer")	then
        searched = true
    end
	
	
	if mData and not searched and not locked then
		--if ISMouseDrag.dragging ~= nil then
		-- button.onclick = ISTimedActionQueue.add(PASearchContainerAction:new(button))
		button.onclick = ISTimedActionQueue.add(PASearchContainerAction:new(button, playerObj))
			
		self.inventoryPane.lastinventory = button.inventory;
		self.inventoryPane.inventory = button.inventory;
		--end
	--end
	else
		ISInventoryPage_old_searched_selectContainer(self, button)
	end

	self.title = button.name;
	self.capacity = button.capacity;

    self:refreshBackpacks();
    --self:refreshBackpacks();
--~ 	self.inventoryPane.selected = {};
--~ 	getPlayerLoot(self.player).inventoryPane.selected = {};
--~ 	getPlayerInventory(self.player).inventoryPane.selected = {};
end

