require "ISUI/ISInventoryPaneContextMenu"

function pryLockedContainer_Context (player, context, worldobjects, test)
    local playerObj = getSpecificPlayer(player)	
	local keyId = nil
	local lockedContainer = nil
	local combination = nil
	
	for x in pairs(worldobjects) do
		local object = worldobjects[x]
		local mData = object:getModData()
		--print("Group Name: " .. tostring(object:getProperties():Val("GroupName")))
		if object and mData and mData.locked and mData.locked > 0 then 
			lockedContainer = worldobjects[x]
			keyId = playerObj:getInventory():haveThisKeyId(mData.locked)
			--print("KEY ID: - " .. tostring(mData.locked))
		end	
		if object and mData and mData.combinationLocked and mData.combinationLocked > 0 then 
			lockedContainer = worldobjects[x]
			combination = mData.combinationLocked
			--print("Combination: - " .. tostring(combination))
		end					
		if instanceof(object, "IsoThumpable") then
			--if cont:isLockedByPadlock() or cont:getLockedByCode() > 0 then
			if object:isLockedByPadlock() or object:getLockedByCode() > 0 then
				lockedContainer = worldobjects[x]	
			end
		end
	end	
	if lockedContainer then
		local playerInv = playerObj:getInventory()
		--local hasRemoveBarricadeTool = PryEquip(playerObj, playerObj:getPrimaryHandItem(), predicatePryLock, true)
		local hasRemoveBarricadeTool = playerObj:getInventory():getFirstEvalRecurse(predicatePryLock)
		--print("Remove Tool: " .. tostring(hasRemoveBarricadeTool))
		if hasRemoveBarricadeTool and playerObj:getPerkLevel(Perks.Strength) > 4 then 
			context:addOption(getText("ContextMenu_Pry_Open_Locked_Container"), lockedContainer, PryLockOpen, player) 
		end
		--local hasKey = nil
		--hasKey = playerInv():haveThisKeyId(keyId)
		if keyId then
			context:addOption(getText("ContextMenu_Unlock_Container"), lockedContainer, lockKeyOpen, player) 
		end
		if combination then
			context:addOption(getText("ContextMenu_Enter_Combination"), lockedContainer, lockCombinationOpen, player) 
		end
		
		
	end
end



function predicatePryLock(item)
	return item:hasTag("Crowbar") and not item:isBroken() 
end


PryLockOpen = function(container, player)
    local playerObj = getSpecificPlayer(player)
	local square = container:getSquare()
	--if luautils.walkAdjWindowOrDoor(playerObj, square, barrel) then	
    if luautils.walkAdj(playerObj, square) then
		if PryEquip(playerObj, playerObj:getPrimaryHandItem(), predicatePryLock, true)		
		and PryEquip(playerObj, playerObj:getSecondaryHandItem(), predicatePryLock, true)
		then
		local tool = playerObj:getPrimaryHandItem()
		--if ISWorldObjectContextMenu.equip(playerObj, playerObj:getPrimaryHandItem(), predicateRemoveBarricade, true) then
			ISTimedActionQueue.add(PryOpenLockAction:new(playerObj, container, tool, (200 - (playerObj:getPerkLevel(Perks.Strength) * 5))))
		end
	end
end

PryEquip = function(playerObj, handItem, item, primary, twoHands)
	if type(item) == "function" then
		local predicate = item
		if not handItem or not predicate(handItem) then
			handItem = playerObj:getInventory():getFirstEvalRecurse(predicate)
			if handItem then
				--ISWorldObjectContextMenu.transferIfNeeded(playerObj, handItem)
				--ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, handItem, 50, primary, twoHands))
				ISInventoryPaneContextMenu.equipWeapon(handItem, true, true, playerObj:getPlayerNum())
			end
		end
		return handItem
	end
	if instanceof(item, "InventoryItem") then
		if handItem ~= item then
			handItem = item
			ISWorldObjectContextMenu.transferIfNeeded(playerObj, handItem)
			ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, handItem, 50, primary, twoHands))
		end
		return handItem
	end
	if not handItem or handItem:getType() ~= item then
		--handItem = playerObj:getInventory():getFirstTypeEvalRecurse(item, predicateNotBroken);
		--handItem = playerObj:getInventory():getFirstTypeRecurse(item)
		if handItem then
			ISWorldObjectContextMenu.transferIfNeeded(playerObj, handItem)
			ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, handItem, 50, primary, twoHands))
		end
	end
	return handItem;
end


lockKeyOpen = function(container, player)
    local playerObj = getSpecificPlayer(player)
	local square = container:getSquare()
	--if luautils.walkAdjWindowOrDoor(playerObj, square, barrel) then	
    if luautils.walkAdj(playerObj, square) then
		local mData = container:getModData()
		local key = playerObj:getInventory():haveThisKeyId(mData.locked)
		local inv = playerObj:getInventory()
		--key:getContainer():Remove(key);
		--inv:AddItem(key)
		--ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, key, key:getContainer(), inv, 0))
		--ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, key, 50, primary, nil))		
		ISInventoryPaneContextMenu.equipWeapon(key, true, false, playerObj:getPlayerNum())
		ISTimedActionQueue.add(RemoveLockAction:new(playerObj, container))
	end
end


removeCombinationPadlockWalkToComplete = function(player, thump)
    local playerObj = getSpecificPlayer(player)
	--playerObj:faceThisObject(thump)
	--if not playerObj:shouldBeTurning() then
		local modal = ISDigitalCode:new(0, 0, 230, 120, nil, ISWorldObjectContextMenu.onCheckCombination, player, nil, thump)--, true);
		--local modal = ISDigitalCode:new(0, 0, 230, 120, nil, ISWorldObjectContextMenu.onCheckDigitalCode, player, nil, thump, true);
		modal:initialise();
		modal:addToUIManager();
		if JoypadState.players[player+1] then
			setJoypadFocus(player, modal)
		end
	--end
end

lockCombinationOpen = function(thump, player)
    local playerObj = getSpecificPlayer(player)
    ISTimedActionQueue.clear(playerObj)

	--if AdjacentFreeTileFinder.isTileOrAdjacent(playerObj:getCurrentSquare(), thump:getSquare()) then
		
		----playerObj:faceThisObject(thump)
		--removeCombinationPadlockWalkToComplete(player, thump)
	--else
		local adjacent = AdjacentFreeTileFinder.Find(thump:getSquare(), playerObj)
		if adjacent ~= nil then
			local action = ISWalkToTimedAction:new(playerObj, adjacent)
			--playerObj:faceThisObject(thump)
			action:setOnComplete(removeCombinationPadlockWalkToComplete, player, thump)
			ISTimedActionQueue.add(action)
		end
	--end
end

function ISWorldObjectContextMenu:onCheckCombination(button, player, padlock, thumpable)
    local playerObj = getPlayer()
    local dialog = button.parent
    if button.internal == "OK" then
		local mData = thumpable:getModData()
		print("combination " .. tostring(mData.combinationLocked))
        if mData.combinationLocked == dialog:getCode() then
			ISTimedActionQueue.add(RemoveLockAction:new(playerObj, thumpable))
        end
    end
end