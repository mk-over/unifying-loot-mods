require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"

require "Definitions/ContainerButtonIcons"

require "defines"


require "ISUI/ISInventoryPage"

local old_keys_ISInventoryPane_refreshContainer = ISInventoryPane.refreshContainer


function ISInventoryPane:refreshContainer()

    local it = self.inventory:getItems();
    for i = 0, it:size()-1 do
        local item = it:get(i);
		if item and instanceof(item, "Key") and item:getModData().keyId then
			print("Key Re-keyed")
			item:setKeyId(item:getModData().keyId)	
			item:setName(item:getScriptItem():getDisplayName())
		end
		
	end

	old_keys_ISInventoryPane_refreshContainer(self)
	
end