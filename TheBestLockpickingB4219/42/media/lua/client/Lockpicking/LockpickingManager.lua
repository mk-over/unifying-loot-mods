require "Lockpicking/BobbyPin/BobbyPinWindow"
require "Lockpicking/BobbyPin/BobbyPinWindowNew"

LockpickingManager = {}

function LockpickingManager.createVehicleDoor(playerObj, part)
    -- Get the sandbox setting (defaults to 1 if not set)
    local mode = SandboxVars.TheBestLockpicking and SandboxVars.TheBestLockpicking.LockpickingMode or 2
    if mode == 2 then
        --BobbyPinWindowNew.createVehicleDoor(playerObj, part)
		ISTimedActionQueue.add(EmptyAction:new(playerObj, BobbyPinWindowNew.createVehicleDoor, nil, playerObj, part))
    else
        --BobbyPinWindow.createVehicleDoor(playerObj, part)
		ISTimedActionQueue.add(EmptyAction:new(playerObj, BobbyPinWindow.createVehicleDoor, nil, playerObj, part))
    end
end

function LockpickingManager.createBuildingDoor(playerObj, door, goToOpen)
    -- Get the sandbox setting (defaults to 1 if not set)
    local mode = SandboxVars.TheBestLockpicking and SandboxVars.TheBestLockpicking.LockpickingMode or 1
    if mode == 2 then
        --BobbyPinWindowNew.createBuildingDoor(playerObj, door, goToOpen)
		ISTimedActionQueue.add(EmptyAction:new(playerObj, BobbyPinWindowNew.createBuildingDoor, nil, playerObj, door, goToOpen))
    else
        --BobbyPinWindow.createBuildingDoor(playerObj, door, goToOpen)
		ISTimedActionQueue.add(EmptyAction:new(playerObj, BobbyPinWindow.createBuildingDoor, nil, playerObj, door, goToOpen))
    end
end


return LockpickingManager