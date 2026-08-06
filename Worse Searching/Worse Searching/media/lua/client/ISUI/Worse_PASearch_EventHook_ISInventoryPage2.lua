require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISInventoryPane"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISLayoutManager"

require "Definitions/ContainerButtonIcons"

require "defines"


require "ISUI/ISInventoryPage"

function ISInventoryPage:PA_WorseSearching_Unsearched (self, dunno)
	--print("WORSE")
	--PASearchContainerAction:new(button) 
	for k,containerButton in ipairs(self.backpacks) do
		local item = nil
		local mData = nil

		if containerButton.inventory:getContainingItem()  ~= nil 
		and not instanceof(containerButton.inventory:getContainingItem() , "IsoPlayer")		
		then
			item = containerButton.inventory:getContainingItem() 

		elseif containerButton.inventory:getVehiclePart() ~= nil 
		then
			item = containerButton.inventory:getVehiclePart()
			-- print("Vehicle Part " .. tostring(item))
			-- print("Vehicle Part " .. tostring(item:getInventoryItem():getType()))
			local type = item:getInventoryItem():getType()
			if type:contains("Seat") then 
				mData = item:getModData()
				mData.searched = true
			else
				local vehicle = item:getVehicle()
				mData = Vehicles.Update.IsSearched(vehicle, item)
			end
								
		elseif containerButton.inventory:getParent() ~= nil 
		and not instanceof(containerButton.inventory:getParent(), "IsoPlayer")		
		then
			item = containerButton.inventory:getParent()

		end
		
		
		if item and not containerButton.inventory:getVehiclePart() then
			--print("MData")
			--print(" - " .. tostring(item:getType()))
			mData = item:getModData()
			if instanceof(containerButton.inventory:getParent(), "IsoPlayer") then mData.searched = true end	
		end
		--if mData and not mData.searched then
			--print("Not searched")
			--containerButton.inventory:setExplored(false) end

		--if not containerButton.inventory:isExplored() 
		--if not containerButton.inventory:isExplored() 
		if mData
		and (not mData.searched )
		and (not instanceof(containerButton.inventory:getParent(), "IsoPlayer"))
		then
			--print("Unsearched container 2")
			containerButton.textureOverride = getTexture("media/ui/questionMark.png")
			containerButton:setTextureRGBA(0.1, 0.1, 0.1, 1.0);
			containerButton:setBackgroundRGBA(0.5, 0.5, 0.5, 1.0)
			if mData.locked and mData.locked > 0 then				
				containerButton.textureOverride = getTexture("media/ui/lock.png")
			end
			--print("Self Unsearched .. " .. tostring(self))
			--containerButton.onclick = ISInventoryPage.selectUnsearchedContainer(containerButton, self)
			--monsterX = self
			--print("Index Alpha - " .. tostring(self:getCurrentBackpackIndex()) .. " - " .. tostring(k))
			
			--containerButton.onclick = ISInventoryPage.selectUnsearchedContainer
			containerButton.onclick = ISInventoryPage.selectContainer
			containerButton.onmousedown = nil
			--containerButton:setOnMouseOverFunction(nil)
			containerButton:setOnMouseOutFunction(nil)
			
		end

	end


end




