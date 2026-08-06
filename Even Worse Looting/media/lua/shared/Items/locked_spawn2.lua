--function locked_Spawn(roomName, containerType, container)
function locked_Spawn2(shouldLock, combination, padlocked, vendor, notShelf, master, keyId, container)
	

	--local pack = locked_Spawn2(roomName, containerType, container)
	
	-- local shouldLock = pack.shouldLock
	-- local combination = pack.combination
	-- local padlocked = pack.padlocked
	-- local vendor = pack.vendor
	-- local notShelf = pack.notShelf
	-- local master = pack.master
	-- local keyId = pack.keyId
	
	if not shouldLock then return false end
	--print("SHOULD LOCK " .. tostring(shouldLock))
	
	local mData = nil
	local cont = nil
	cont = container:getParent()
	if cont and cont:getModData() then mData = cont:getModData() end
	if mData and combination then
		local combo = ZombRand(0,999)+1
		mData.combinationLocked = (combo)
		--print("COMBINATION LOCKED " .. tostring(containerType))
		local square = cont:getSquare()
		if square:getBuilding() and ZombRand(0,9) == 0 then
			--print ("building!")
			local building = square:getBuilding()
			--print("Building " .. tostring(building))
			local room = building:getRandomRoom()
			--print("Room " .. tostring(room))
			--print("Room Containers " .. tostring(room:getContainer():size()))
			local square2 = room:getRandomFreeSquare()
			--print("SQUARE2 " .. tostring(square2))
			if square2 then
				local key = InventoryItemFactory.CreateItem("SheetPaper2")
				key:addPage(1, tostring(combo))
				square2:AddWorldInventoryItem(key, 0.0, 0.0, 0.0)
				--print("Combination Note Spawned in random square!")
			end	
		end
		if ZombRand(0,2) then
			local cell = getCell()
			local zeds = cell:getZombieList()
			if zeds then
				--print("Zeds " .. tostring(zeds:size()))
				if zeds:size() > 0 then
					local roll = ZombRand(zeds:size())
					local zed = zeds:get(ZombRand(roll))
					--print("Zed " .. tostring(zed))
					if zed then
						local key2 = InventoryItemFactory.CreateItem("SheetPaper2")
						key2:addPage(1, tostring(combo))
						zed:addItemToSpawnAtDeath(key2)
						--print("Zombie Key Spawned")
					end					
				end
			end
		end
	else
		--local keyId = cont:getX() + cont:getY()
		--if not padlocked then keyId = math.floor(keyId/20) end
		--if not padlocked and master then keyId = ((cont:getX() * cont:getX() * 4 ) * ( cont:getY() * cont:getY() ))/40000000 end
		--if not padlocked and master then keyId = (math.floor(keyId/4000000)+100) end
		--if not padlocked and master then keyId = math.floor( ( math.sqrt(cont:getX()) + math.sqrt(cont:getY()) )/3) end
		-- if not padlocked and master then
			-- if roomName:contains("gunstore") then
				-- keyId = keyId + 100
			-- elseif roomName:contains("policestorage") then
				-- keyId = keyId + 200
			-- elseif roomName:contains("armystorage") then
				-- keyId = keyId + 300
			-- elseif roomName:contains("security") then 
				-- keyId = keyId + 400
			-- end
		-- end	
		if vendor then
			--print("VENDORRRRR")
			keyId = 1
			keyType = "Key_1"
		end	
		if not padlocked and cont:getKeyId() then cont:setKeyId(keyId) end
		mData.locked = (keyId)
		if padlocked then mData.padlocked = true end
		--print("LOCKED " .. tostring(containerType))
		local square = cont:getSquare()
		local keyType = "KeyContainer"
		if not padlocked and master then
			keyType = ("Key_" .. tostring(keyId))
			local key = InventoryItemFactory.CreateItem(keyType)
			if not key then keyType = "KeyContainer" end
		end
		if square:getBuilding() and master then
			square:getBuilding():getDef():setKeyId(1000 + keyId) 
		end
		if square:getBuilding() and ZombRand(0,19) == 0 then
		--if square:getBuilding() then
			--print ("building!")
			local building = square:getBuilding()
			--print("Building " .. tostring(building))
			local room = building:getRandomRoom()
			--print("Room " .. tostring(room))
			--print("Room Containers " .. tostring(room:getContainer():size()))
			local square2 = room:getRandomFreeSquare()
			--print("SQUARE2 " .. tostring(square2))
			if square2 then
				local key = InventoryItemFactory.CreateItem(keyType)
				key:setKeyId(keyId)
				local mData = key:getModData()
				mData.keyId = keyId
				square2:AddWorldInventoryItem(key, 0.0, 0.0, 0.0)
				--print("Key Spawned in random square!")
			end	
		end
		if ZombRand(0,2) and keyId then
			local cell = getCell()
			local zeds = cell:getZombieList()
			if zeds then
				--print("Zeds " .. tostring(zeds:size()))
				if zeds:size() > 0 then
					local roll = ZombRand(zeds:size())
					local zed = zeds:get(ZombRand(roll))
					--print("Zed " .. tostring(zed))
					if zed then
						local key2 = InventoryItemFactory.CreateItem(keyType)
						key2:setKeyId(keyId)
						local mData = key2:getModData()
						mData.keyId = keyId
						zed:addItemToSpawnAtDeath(key2)
						--print("Zombie Key Spawned")
					end					
				end
			end
		end
		
	end
end

