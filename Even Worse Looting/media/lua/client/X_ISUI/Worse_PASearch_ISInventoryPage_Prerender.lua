--***********************************************************
--**               LEMMY/ROBERT JOHNSON                    **
--***********************************************************

require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"

require "Definitions/ContainerButtonIcons"

require "defines"

require "ISUI/ISInventoryPage"


local function isMod(mod_Name)
    local mods = getActivatedMods();
    for i=0, mods:size()-1, 1 do
        if mods:get(i) == mod_Name then
            return true;
        end
    end
    return false;
end

function ISInventoryPage:prerender()

    if self.blinkContainer then
        if not self.blinkAlphaContainer then self.blinkAlphaContainer = 0.7; self.blinkAlphaIncreaseContainer = false; end
        if not self.blinkAlphaIncreaseContainer then
            self.blinkAlphaContainer = self.blinkAlphaContainer - 0.04 * (UIManager.getMillisSinceLastRender() / 33.3);
            if self.blinkAlphaContainer < 0.3 then
                self.blinkAlphaContainer = 0.3;
                self.blinkAlphaIncreaseContainer = true;
            end
        else
            self.blinkAlphaContainer = self.blinkAlphaContainer + 0.04 * (UIManager.getMillisSinceLastRender() / 33.3);
            if self.blinkAlphaContainer > 0.7 then
                self.blinkAlphaContainer = 0.7;
                self.blinkAlphaIncreaseContainer = false;
            end
        end
        for i,v in ipairs(self.backpacks) do
			if (self.blinkContainerType and v.inventory:getType() == self.blinkContainerType) or not self.blinkContainerType then
            	v:setBackgroundRGBA(1, 0, 0, self.blinkAlphaContainer);
			end
        end
	end

    local titleBarHeight = self:titleBarHeight()
    local height = self:getHeight();
    if self.isCollapsed then
        height = titleBarHeight;
    end

	self:drawRect(0, 0, self:getWidth(), height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);

    if not self.blink then
        self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, titleBarHeight - 2, 1, 1, 1, 1);
    else
        if not self.blinkAlpha then self.blinkAlpha = 1; end
        self:drawRect(2, 1, self:getWidth() - 4, 14, self.blinkAlpha, 1, 1, 1);
--        self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, 14, self.blinkAlpha, 1, 1, 1);

        if not self.blinkAlphaIncrease then
            self.blinkAlpha = self.blinkAlpha - 0.1 * (UIManager.getMillisSinceLastRender() / 33.3);
            if self.blinkAlpha < 0 then
                self.blinkAlpha = 0;
                self.blinkAlphaIncrease = true;
            end
        else
            self.blinkAlpha = self.blinkAlpha + 0.1 * (UIManager.getMillisSinceLastRender() / 33.3);
            if self.blinkAlpha > 1 then
                self.blinkAlpha = 1;
                self.blinkAlphaIncrease = false;
            end
        end
    end
    self:drawRectBorder(0, 0, self:getWidth(), titleBarHeight, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if not self.isCollapsed then
        -- Draw border for backpack area...
        self:drawRect(self:getWidth()-32, titleBarHeight, 32, height-titleBarHeight-7,  self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    end

--~ 	if not self.title then
--~ 		self.title = getSpecificPlayer(self.player):getDescriptor():getForename().." "..getSpecificPlayer(self.player):getDescriptor():getSurname().."'s Inventory";
--~ 	end

    if self.title and self.onCharacter then
        self:drawText(self.title, self.infoButton:getRight() + 1, 0, 1,1,1,1);
    end

	-- load the current weight of the container
	self.totalWeight = ISInventoryPage.loadWeight(self.inventoryPane.inventory);

    local roundedWeight = round(self.totalWeight, 2)

	
	local object = self.inventory:getVehiclePart() or self.inventory:getParent() or self.inventory:getContainingItem()
	local mData = nil
	if object and object:getModData() then mData = object:getModData() end
	local searched = nil
	if mData then searched = mData.searched end	
    if self.inventory:getType() == "floor" then
	--or instanceof(button.inventory:getParent(), "IsoPlayer")	then
        searched = true
    end
	if not isMod("Worse Searching") then searched = true end
	local locked = nil
	if mData and mData.locked then locked = mData.locked > 0 end
	if mData and mData.combinationLocked then locked = mData.combinationLocked > 0 end
	if locked then searched = nil end
	
	if self.capacity then
		if self.inventoryPane.inventory == getSpecificPlayer(self.player):getInventory() then
			self:drawTextRight(roundedWeight .. " / " .. getSpecificPlayer(self.player):getMaxWeight(), self.pinButton:getX(), 0, 1,1,1,1);
		elseif searched then
			self:drawTextRight(roundedWeight .. " / " .. self.capacity, self.pinButton:getX(), 0, 1,1,1,1);
		end
	elseif (not object) or searched then
		self:drawTextRight(roundedWeight .. "", self.width - 20, 0, 1,1,1,1);
    end
    
	local weightWid = getTextManager():MeasureStringX(UIFont.Small, "99.99 / 99")
	weightWid = math.max(90, weightWid)
    self.transferAll:setX(self.pinButton:getX() - weightWid - getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_invpage_Transfer_all")));
    if not self.onCharacter or self.width < 370 then
        self.transferAll:setVisible(false)
    elseif not "Tutorial" == getCore():getGameMode() then
        self.transferAll:setVisible(true)
    end
    
    if self.title and not self.onCharacter then
        local fontHgt = getTextManager():getFontHeight(self.font)
        self:drawTextRight(self.title, self.width - 20 - weightWid, (titleBarHeight - fontHgt) / 2, 1,1,1,1);
    end

    -- self:drawRectBorder(self:getWidth()-32, 15, 32, self:getHeight()-16-6, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:setStencilRect(0,0,self.width+1, height);
    
    if ISInventoryPage.renderDirty then
        ISInventoryPage.renderDirty = false;
        ISInventoryPage.dirtyUI();
    end
end