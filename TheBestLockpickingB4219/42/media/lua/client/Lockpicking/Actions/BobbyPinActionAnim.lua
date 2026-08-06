require "TimedActions/ISBaseTimedAction"
--require "Lockpicking/Crowbar/CrowbarWindow"
require "Lockpicking/BobbyPin/BobbyPinWindow"

BobbyPinActionAnim = ISBaseTimedAction:derive("BobbyPinActionAnim")

function BobbyPinActionAnim:isValid()
    if not self.lockpick_object then
        --print("BobbyPinActionAnim:isValid - lockpick_object is nil")
        return false
    end
    if instanceof(self.lockpick_object, "IsoDoor") or instanceof(self.lockpick_object, "IsoWindow") then
        return true
    elseif self.lockpick_object:getVehicle() then  -- Проверка на nil встроена
        return self.lockpick_object:getVehicle():isStopped()
    end
    --print("BobbyPinActionAnim:isValid - Invalid lockpick_object: ", self.lockpick_object)
    return false
end

function BobbyPinActionAnim:waitToStart()
    if not self.character or not self.lockpick_object then
        --print("Error in waitToStart: character or lockpick_object is nil")
        return false
    end

    if instanceof(self.lockpick_object, "IsoDoor") or instanceof(self.lockpick_object, "IsoWindow") then
        self.character:faceThisObject(self.lockpick_object)
        return self.character:shouldBeTurning()
    elseif self.lockpick_object:getVehicle() then
        self.character:faceThisObject(self.lockpick_object:getVehicle())
        return self.character:shouldBeTurning()
    end
    --print("Error in waitToStart: lockpick_object is invalid")
    return false
end

function BobbyPinActionAnim:update()
    if not self.character then
        --print("Error in update: character is nil")
        return
    end
    if not self.lockpick_object then
        --print("Error in update: lockpick_object is nil")
        return
    end

    local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
    if uispeed ~= 1 then
        UIManager.getSpeedControls():SetCurrentGameSpeed(1)
    end

    if instanceof(self.lockpick_object, "IsoDoor") or instanceof(self.lockpick_object, "IsoWindow") then
        self.character:faceThisObject(self.lockpick_object)
    elseif self.lockpick_object:getVehicle() then
        self.character:faceThisObject(self.lockpick_object:getVehicle())
    else
        --print("Error in update: lockpick_object is invalid, type: ", type(self.lockpick_object))
    end
end

function BobbyPinActionAnim:start()
    self:setActionAnim("Bob_PicklockAction")
    self.character:getModData().zReBLStopFlag = 0
end

function BobbyPinActionAnim:stop()
    if self.character and self.character:getModData().zReBLStopFlag == 0 then
        if BobbyPinWindow.instance then
            BobbyPinWindow.instance:close()
        end
        self.character:getModData().zReBLStopFlag = 1
    end
    ISBaseTimedAction.stop(self)
end

function BobbyPinActionAnim:perform()
    ISBaseTimedAction.perform(self)
end

function BobbyPinActionAnim:new(character, lockpick_object)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.lockpick_object = lockpick_object
    o.maxTime = 50000
    --print("BobbyPinActionAnim created with lockpick_object: ", lockpick_object, " character: ", character)
    return o
end