function zReBL_CheckDrops(zombie)

	if not zombie:getOutfitName() then return false end
	local outfit = tostring(zombie:getOutfitName());
	local inv = zombie:getInventory();
	if (outfit == "Bandit") or (outfit == "InmateEscaped") then

		if 50 >= ZombRand(1, 100) then
			inv:AddItems("BetLock.AlarmMag", 1);
		end
		if 90 >= ZombRand(1, 100) then
			inv:AddItems("BetLock.LockpickingMag", 1);
		end
		
	end
end

Events.OnZombieDead.Add(zReBL_CheckDrops);