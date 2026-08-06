--function locked_Spawn2(roomName, containerType, container)
function locked_Spawn(roomName, containerType, container)	
	local shouldLock = nil
	local combination = nil
	local padlocked = nil
	local vendor = nil
	local notShelf = nil
	local master = nil
	local keyId = nil
	if containerType == "metal_shelves" and container:getParent() and container:getParent():getProperties():Val("CustomName") == "Locker" then
		notShelf = true
	end
	
	
	if roomName:contains("gunstore") or roomName:contains("policestorage") or roomName:contains("armystorage")  or roomName:contains("security") then
		if containerType == "locker" or containerType == "crate" or containerType == "displaycase"  or containerType == "counter" or notShelf then
			if ZombRand(0,9) ~= 0 then
				shouldLock = true
				master = true
			end
		end
	end
	if roomName:contains("hunting")then
		if containerType == "locker" or containerType == "crate" or containerType == "displaycase"  or containerType == "counter" or notShelf then
			if ZombRand(0,9) ~= 0 then
				shouldLock = true
			end
		end
	end
	if roomName:contains("armyhangar") then
		if containerType == "locker" and ZombRand(0,2) == 0 then
			shouldLock = true
		end
	end
	if roomName:contains("jewelrystore") then
		if containerType == "displaycase" and ZombRand(0,9) ~= 0 then
			shouldLock = true
		end
	end
	if roomName:contains("medclinic") or roomName:contains("medical")  or roomName:contains("pharmacystorage") then
		if containerType == "counter" and ZombRand(0,2) == 0 then
			shouldLock = true
		end
	end	
	if containerType == "displaycase" and ZombRand(0,2) == 0 then
		shouldLock = true
	end
	if containerType == "vendingsnack" or containerType == "vendingpop" then
		--print("Should be Vendor")
		if ZombRand(0,9) ~= 0 then
			shouldLock = true
			vendor = true
		end
	end
	if (containerType == "crate" or containerType == "counter" or containerType == "desk" or containerType == "officedrawers") then
		if ZombRand(0,9) == 0 then
			shouldLock = true
		end
	end
	if (containerType == "postbox") and ZombRand(0,2) == 0 then
		shouldLock = true
	end
	if (containerType == "cashregister") and ZombRand(0,9) ~= 0 then
		shouldLock = true
	end
	if shouldLock and (not master) and (containerType == "locker") and roomName ~=("gunstore") then		
		padlocked = true
	end
	if shouldLock and (containerType == "crate") then		
		padlocked = true	
		-- padlocked = nil
		-- shouldLock = nil
	end
	
	if (not shouldLock) and (not master) and containerType == "locker" and ZombRand(0,5) ~= 0 then
		shouldLock = true
		if ZombRand(0,9) == 0 then
			padlocked = true		
		else
			combination = true
		end
	end
	if roomName:contains("policestorage") or roomName:contains("armystorage")  or roomName:contains("security")  or roomName==("gunstore") then
		padlocked = nil
		combination = nil
		master = true
	end
	
	if roomName:contains("bankstorage") then
		if containerType == "filingcabinet" then
			shouldLock = true
		end
	end
	--if containerType == "locker" then shouldLock = true end
	
	if container:getParent() and container:getParent():getProperties():Val("CustomName") == "Chest" and ZombRand(0,2) == 0 then
		shouldLock = true
		if ZombRand(0,2) == 0 then padlocked = true
		else combination = true
		end
	end
	
	if container:getParent()
	and container:getParent():getProperties():Val("GroupName")
	and container:getParent():getProperties():Val("GroupName"):contains("board") then shouldLock = nil end

	
	
	if shouldLock and (containerType == "crate") then		
			shouldLock = nil
	end
	
	
	local cont = container:getParent()
	if cont then 
		keyId = cont:getX() + cont:getY()
		if not padlocked and master then keyId = math.floor( ( math.sqrt(cont:getX()) + math.sqrt(cont:getY()) )/3) end
		if not padlocked and master then
			if roomName:contains("gunstore") then
				keyId = keyId + 100
			elseif roomName:contains("policestorage") then
				keyId = keyId + 200
			elseif roomName:contains("armystorage") then
				keyId = keyId + 300
			elseif roomName:contains("security") then 
				keyId = keyId + 400
			end
		end	
	end
	locked_Spawn2(shouldLock, combination, padlocked, vendor, notShelf, master, keyId, container)
	--local pack = {shouldLock, combination, padlocked, vendor, notShelf, master, keyId}
	-- local pack = {}
	-- pack.shouldLock = shouldLock
	-- pack.combination =combination
	-- pack.padlocked = padlocked
	-- pack.vendor = vendor
	-- pack.notShelf = notShelf
	-- pack.master = master
	-- pack.keyId = keyId
	
	
	
	-- return (pack)
		
end

