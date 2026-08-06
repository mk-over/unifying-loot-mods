require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"

require "Definitions/ContainerButtonIcons"

require "defines"


require "ISUI/ISInventoryPage"

local old_searched_ISInventoryPane_refreshContainer = ISInventoryPane.refreshContainer


function ISInventoryPane:refreshContainer()

	local searched = nil
	local object = self.inventory:getVehiclePart() or self.inventory:getParent() or self.inventory:getContainingItem()
	local mData = nil
	if object and object:getModData() then
		mData = object:getModData()
		if instanceof(self.inventory:getParent(), "IsoPlayer") then mData.searched = true end
		searched = mData.searched
	end
    if self.inventory:getType() == "floor" then
        searched = true
    end



	-- if searched then
		-- old_ISInventoryPane_refreshContainer(self)
	-- end

    self.itemslist = {}
    self.itemindex = {}

	if searched then
		old_searched_ISInventoryPane_refreshContainer(self)
	end


    -- if self.collapsed == nil then
        -- self.collapsed = {}
    -- end
	-- if self.selected == nil then
		-- self.selected = {}
	-- end

	-- local selected = self:saveSelection({})
	-- table.wipe(self.selected)

	-- local playerObj = getSpecificPlayer(self.player)

	-- if not self.hotbar then
		-- self.hotbar = getPlayerHotbar(self.player);
	-- end

	-- local isEquipped = {}
	-- local isInHotbar = {}
	-- if self.parent.onCharacter then
		-- local wornItems = playerObj:getWornItems()
		-- for i=1,wornItems:size() do
			-- local wornItem = wornItems:get(i-1)
			-- isEquipped[wornItem:getItem()] = true
		-- end
		-- local item = playerObj:getPrimaryHandItem()
		-- if item then
			-- isEquipped[item] = true
		-- end
		-- item = playerObj:getSecondaryHandItem()
		-- if item then
			-- isEquipped[item] = true
		-- end
		-- if self.hotbar and self.hotbar.attachedItems then
			-- for _,item in pairs(self.hotbar.attachedItems) do
				-- isInHotbar[item] = true
			-- end
		-- end
	-- end

    -- local it = self.inventory:getItems();
    -- for i = 0, it:size()-1 do
        -- local item = it:get(i);
		-- local add = true;
		-- -- don't add the ZedDmg category, they are just equipped models
		-- if item:isHidden() or ( mData and not searched ) then
			-- add = false;
		-- end
		-- if add then
		
		
		
		
			-- local itemName = item:getName();
			-- if item:IsFood() and item:getHerbalistType() and item:getHerbalistType() ~= "" then
				-- if playerObj:isRecipeKnown("Herbalist") then
					-- if item:getHerbalistType() == "Berry" then
						-- itemName = (item:getPoisonPower() > 0) and getText("IGUI_PoisonousBerry") or getText("IGUI_Berry")
					-- end
					-- if item:getHerbalistType() == "Mushroom" then
						-- itemName = (item:getPoisonPower() > 0) and getText("IGUI_PoisonousMushroom") or getText("IGUI_Mushroom")
					-- end
				-- else
					-- if item:getHerbalistType() == "Berry"  then
						-- itemName = getText("IGUI_UnknownBerry")
					-- end
					-- if item:getHerbalistType() == "Mushroom" then
						-- itemName = getText("IGUI_UnknownMushroom")
					-- end
				-- end
				-- if itemName ~= item:getDisplayName() then
					-- item:setName(itemName);
				-- end
				-- itemName = item:getName()
			-- end
			-- local equipped = false
			-- local inHotbar = false
			-- if self.parent.onCharacter then
				-- if isEquipped[item] then
					-- itemName = "equipped:"..itemName
					-- equipped = true
				-- elseif item:getType() == "KeyRing" and playerObj:getInventory():contains(item) then
					-- itemName = "keyring:"..itemName
					-- equipped = true
				-- end
				-- if self.hotbar then
					-- inHotbar = isInHotbar[item];
					-- if inHotbar and not equipped then
						-- itemName = "hotbar:"..itemName
					-- end
				-- end
			-- end
			-- if self.itemindex[itemName] == nil then
				-- self.itemindex[itemName] = {};
				-- self.itemindex[itemName].items = {}
				-- self.itemindex[itemName].count = 0
			-- end
			-- local ind = self.itemindex[itemName];
			-- ind.equipped = equipped
			-- ind.inHotbar = inHotbar;

			-- ind.count = ind.count + 1
			-- ind.items[ind.count] = item;
		-- end
    -- end

    -- for k, v in pairs(self.itemindex) do

        -- if v ~= nil then
            -- table.insert(self.itemslist, v);
            -- local count = 1;
            -- local weight = 0;
            -- for k2, v2 in ipairs(v.items) do
                -- if v2 == nil then
                    -- table.remove(v.items, k2);
                -- else
                    -- count = count + 1;
                    -- weight = weight + v2:getUnequippedWeight();
                -- end
            -- end
            -- v.count = count;
            -- v.invPanel = self;
            -- v.name = k -- v.items[1]:getName();
            -- v.cat = v.items[1]:getDisplayCategory() or v.items[1]:getCategory();
            -- v.weight = weight;
            -- if self.collapsed[v.name] == nil then
                -- self.collapsed[v.name] = true;
            -- end
        -- end
    -- end


    -- --print("Preparing to sort inv items");
    -- table.sort(self.itemslist, self.itemSortFunc );
    
    -- -- Adding the first item in list additionally at front as a dummy at the start, to be used in the details view as a header.
    -- for k, v in ipairs(self.itemslist) do
        -- local item = v.items[1];
        -- table.insert(v.items, 1, item);
    -- end

    -- self:restoreSelection(selected);
    -- table.wipe(selected);
    
    -- self:updateScrollbars();
    -- self.inventory:setDrawDirty(false);

    -- -- Update the buttons
    -- if self:isMouseOver() then
        -- self:onMouseMove(0, 0)
    -- end
end