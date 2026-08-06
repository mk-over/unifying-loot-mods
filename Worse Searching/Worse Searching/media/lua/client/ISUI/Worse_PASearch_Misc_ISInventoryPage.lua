require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"

require "Definitions/ContainerButtonIcons"

require "defines"


require "ISUI/ISInventoryPage"

function ISInventoryPane:rendericons()
	local searched = nil
	local object = self.inventory:getVehiclePart() or self.inventory:getParent() or self.inventory:getContainingItem()
	local mData = nil
	if object and object:getModData() then
		mData = object:getModData()		
		if instanceof(self.inventory:getParent(), "IsoPlayer") then mData.searched = true end
		searched = mData.searched
	end
	
	
	local xpad = 10;
	local ypad = 10;
	local iw = 40;
	local ih = 40;
	local xmax = math.floor((self.width - (xpad * 2)) / iw);
	local ymax = math.floor((self.height - (ypad * 2)) / ih);
	local xcount = 0;
	local ycount = 0;
    local it = self.inventory:getItems();
    for i = 0, it:size()-1 do
        local item = it:get(i);
        self:drawTexture(item:getTex(), (xcount * iw) + xpad + 4, (ycount * ih) + ypad + 4, 1, 1, 1, 1);
		if mData and not searched then
		
			self.textureOverride = getTexture("media/ui/questionMark.png")
			self:setTextureRGBA(0.1, 0.1, 0.1, 1.0);
			self:setBackgroundRGBA(0.5, 0.5, 0.5, 1.0)
		
		end

		xcount = xcount + 1;

		if xcount >= xmax then
			xcount= 0;
			ycount = ycount + 1;
		end
	end
end
