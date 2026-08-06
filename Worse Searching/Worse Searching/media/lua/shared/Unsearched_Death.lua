function UnsearchedDeath_Event(player)
	local items = player:getInventory():getItemsFromCategory("Container")
	for i=0, items:size()-1 do
		local item = items:get(i)
		--if item:getCategory() == "Container" then
			local mData = item:getModData()
			mData.searched = nil
		--end
	end
	
	
end