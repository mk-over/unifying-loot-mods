WorseSearching_LootRespawn = function(roomName, containerType, container)
	if container:getParent() then
		local parent = container:getParent()
		if parent then
			local mData = parent:getModData()
			if mData then
				mData.searched = nil
				parent:transmitModData()
			end
		end
	end
end


Events.OnFillContainer.Add ( WorseSearching_LootRespawn )

