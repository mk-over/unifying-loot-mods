require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"

require "Definitions/ContainerButtonIcons"

require "defines"


require "ISUI/ISInventoryPage"


function LockedContainer_InventoryPage(self, dunno)
	--print("WORSE")
	for k,containerButton in ipairs(self.backpacks) do
		local item = nil
		if containerButton.inventory and containerButton.inventory:getParent() then item = containerButton.inventory:getParent() end
		local mData = nil
		local locked = nil
		if item then
			mData = item:getModData()
		end		
		if mData and mData.locked then locked = (mData.locked > 0 ) end
		if mData and mData.combinationLocked then locked = (mData.combinationLocked > 0 ) end
		
		if locked then
			--print("LOCKED CONTAINER " .. tostring(item:getType()))
			containerButton.onclick = nil
			containerButton.onmousedown = nil
			containerButton:setOnMouseOverFunction(nil)
			containerButton:setOnMouseOutFunction(nil)
			containerButton.textureOverride = getTexture("media/ui/lock.png")		
		end
	end
end


Events.OnRefreshInventoryWindowContainers.Add(LockedContainer_InventoryPage);