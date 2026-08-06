local original = ISVehicleMenu.onToggleTrunkLocked
function ISVehicleMenu.onToggleTrunkLocked(playerObj)
	local vehicle = playerObj:getVehicle();
	if not vehicle then return end
------ zRe FIX for Vanilla: -----------------------------------------
	local trunkdoor = vehicle:getPartById("TrunkDoor");
	if trunkdoor then
		if trunkdoor:getDoor():isLockBroken() then
			playerObj:Say(getText("IGUI_PlayerText_VehicleLockIsBroken"))
			return 
		end
	end
	local trunkdoor2 = vehicle:getPartById("DoorRear");
	if trunkdoor2 then
		if trunkdoor2:getDoor():isLockBroken() then
			playerObj:Say(getText("IGUI_PlayerText_VehicleLockIsBroken"))
			return
		end
	end
	original(playerObj)
end