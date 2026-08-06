function PAS_KR(player)
	--print("KEY RING TEST")
	-- local keyRing = player:getInventory():getItemFromType("Base.KeyRing")
	-- if keyRing and player then
		-- --print("KEY RING " .. tostring(keyRing))
		-- local mData = keyRing:getModData()
		-- mData.searched = true
	-- end
	local items = player:getInventory():getItemsFromCategory("Container")
	for i=0, items:size()-1 do
		local item = items:get(i)
		--if item:getCategory() == "Container" then
			local mData = item:getModData()
			mData.searched = true
		--end
	end
end