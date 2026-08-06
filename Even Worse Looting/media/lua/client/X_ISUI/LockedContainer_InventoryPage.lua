local function isMod(mod_Name)
    local mods = getActivatedMods();
    for i=0, mods:size()-1, 1 do
        if mods:get(i) == mod_Name then
            return true;
        end
    end
    return false;
end

function ISInventoryPage:prevUnlockedContainer(index, wrap)
    local playerObj = getSpecificPlayer(self.player)
    for i=index-1,1,-1 do
        local backpack = self.backpacks[i]
        local object = backpack.inventory:getParent()
		local mData = nil
		if object and object:getModData() then mData = object:getModData() end
		local locked = nil
		if mData and mData.locked then locked = mData.locked > 0 end
		if mData and mData.combinationLocked then locked = mData.combinationLocked > 0 end
		local searched = nil
		if mData and mData.searched then searched=true end
		if not isMod("Worse Searching") then searched = true end
        if not (instanceof(object, "IsoThumpable") and object:isLockedToCharacter(playerObj)) and (not locked) and searched then
            return i
        end
    end
    return wrap and self:prevUnlockedContainer(#self.backpacks + 1, false) or -1
end

function ISInventoryPage:nextUnlockedContainer(index, wrap)
    if index < 0 then -- User clicked a container that isn't displayed
        return wrap and self:nextUnlockedContainer(0, false) or -1
    end
    local playerObj = getSpecificPlayer(self.player)
    for i=index+1,#self.backpacks do
        local backpack = self.backpacks[i]
        local object = backpack.inventory:getParent()
		local mData = nil
		if object and object:getModData() then mData = object:getModData() end
		local locked = nil
		if mData and mData.locked then locked = mData.locked > 0 end
		if mData and mData.combinationLocked then locked = mData.combinationLocked > 0 end
		local searched = nil
		if mData and mData.searched then searched=true end
		if not isMod("Worse Searching") then searched = true end
        if not (instanceof(object, "IsoThumpable") and object:isLockedToCharacter(playerObj)) and (not locked) and searched then
            return i
        end
    end
    return wrap and self:nextUnlockedContainer(0, false) or -1
end


function ISInventoryPage:update()
	
    if self.coloredInv and (self.inventory ~= self.coloredInv or self.isCollapsed) then
        if self.coloredInv:getParent() then
            self.coloredInv:getParent():setHighlighted(false)
        end
        self.coloredInv = nil;
    end

    if not self.isCollapsed then
--        print(self.inventory:getParent());
        if self.inventory:getParent() and (instanceof(self.inventory:getParent(), "IsoObject") or instanceof(self.inventory:getParent(), "IsoDeadBody")) then
            self.inventory:getParent():setHighlighted(true, false);
            self.inventory:getParent():setHighlightColor(getCore():getObjectHighlitedColor());
--             self.inventory:getParent():setHighlightColor(ColorInfo.new(0.3,0.3,0.3,1));
            --            self.inventory:getParent():setBlink(true);
--            self.inventory:getParent():setCustomColor(0.98,0.56,0.11,1);
            self.coloredInv = self.inventory;
        end
	end
	
    if (ISMouseDrag.dragging ~= nil and #ISMouseDrag.dragging > 0) or self.pin then
        self.collapseCounter = 0;
        if isClient() and self.isCollapsed then
            self.inventoryPane.inventory:requestSync();
        end
        self.isCollapsed = false;
        self:clearMaxDrawHeight();
        self.collapseCounter = 0;
    end

    if not self.onCharacter then
        -- add "remove all" button for trash can/bins
        self.removeAll:setVisible(self:isRemoveButtonVisible())

        local playerObj = getSpecificPlayer(self.player)
        if self.lastDir ~= playerObj:getDir() then
            self.lastDir = playerObj:getDir()
            self:refreshBackpacks()
        elseif self.lastSquare ~= playerObj:getCurrentSquare() then
            self.lastSquare = playerObj:getCurrentSquare()
            self:refreshBackpacks()
        end

        -- If the currently-selected container is locked to the player, select another container.
        local object = self.inventory and self.inventory:getParent() or nil
		
		
		local mData = nil
		if object and object:getModData() then mData = object:getModData() end
		local locked = nil
		if mData and mData.locked then locked = mData.locked > 0 end
		if mData and mData.combinationLocked then locked = mData.combinationLocked > 0 end
		
        if #self.backpacks > 1 and
		((instanceof(object, "IsoThumpable") and object:isLockedToCharacter(playerObj)) or locked) then
            local currentIndex = self:getCurrentBackpackIndex()
            local unlockedIndex = self:prevUnlockedContainer(currentIndex, false)
            if unlockedIndex == -1 then
                unlockedIndex = self:nextUnlockedContainer(currentIndex, false)
            end
            if unlockedIndex ~= -1 then
                self:selectContainer(self.backpacks[unlockedIndex])
                if playerObj:getJoypadBind() ~= -1 then
                    self.backpackChoice = unlockedIndex
                end
            end
        end
    end

	self:syncToggleStove()
end