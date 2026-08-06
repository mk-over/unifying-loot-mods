require "TimedActions/ISBaseTimedAction"
require "Lockpicking/Crowbar/CrowbarWindow"

CrowbarActionAnim = ISBaseTimedAction:derive("CrowbarActionAnim")

function CrowbarActionAnim:isValid()
    --print("isValid called with lockpick_object: ", self.lockpick_object)
    if instanceof(self.lockpick_object, "IsoDoor") or instanceof(self.lockpick_object, "IsoWindow") then
        return true
    elseif self.lockpick_object and self.lockpick_object:getVehicle() then
        return self.lockpick_object:getVehicle():isStopped()
    end
    --print("isValid returning false: invalid lockpick_object")
    return false
end

function CrowbarActionAnim:waitToStart()
    --print("waitToStart called with lockpick_object: ", self.lockpick_object)
    if not self.character then
        --print("Error in waitToStart: character is nil")
        return false
    end
    if not self.lockpick_object then
        --print("Error in waitToStart: lockpick_object is nil")
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


function CrowbarActionAnim:update()
    -- Проверка на nil для character и lockpick_object
    if not self.character then
        --print("Error in update: character is nil")
        return
    end
    if not self.lockpick_object then
        --print("Error in update: lockpick_object is nil")
        return
    end

    -- Управление скоростью игры
    local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
    if uispeed ~= 1 then
        UIManager.getSpeedControls():SetCurrentGameSpeed(1)
    end
    
    -- Управление звуком
    if not self.sound or not self.sound:isPlaying() then
        self.sound = getSoundManager():PlayWorldSound("zReBL_crowbarSound", self.character:getCurrentSquare(), 1, 25, 2, true)
    end

    -- Поворот персонажа к объекту
    if instanceof(self.lockpick_object, "IsoDoor") or instanceof(self.lockpick_object, "IsoWindow") then
        self.character:faceThisObject(self.lockpick_object)
    elseif self.lockpick_object:getVehicle() then
        self.character:faceThisObject(self.lockpick_object:getVehicle())
    else
        --print("Error in update: lockpick_object is invalid, type: ", type(self.lockpick_object))
    end
end

function CrowbarActionAnim:start()
	if self.isGarage then
		self:setActionAnim("Bob_CrowbarGarageAction")
	elseif instanceof(self.lockpick_object, "IsoWindow") then
		self:setActionAnim("Bob_CrowbarWindowAction")
	else
		self:setActionAnim("Bob_CrowbarDoorAction")
	end
	
	self.character:getModData().zReBLStopFlag = 0
end

function CrowbarActionAnim:stop()
	getSoundManager():StopSound(self.sound)
	
	if self.character:getModData().zReBLStopFlag == 0 then
		CrowbarWindow.instance:close()
		self.character:getModData().zReBLStopFlag = 1
	end
	
	ISBaseTimedAction.stop(self)
end

function CrowbarActionAnim:perform()
	getSoundManager():StopSound(self.sound)
	ISBaseTimedAction.perform(self)
end

function CrowbarActionAnim:new(character, isGarage, lockpick_object)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.lockpick_object = lockpick_object
    o.maxTime = 50000
    o.isGarage = isGarage
    --print("CrowbarActionAnim created with lockpick_object: ", lockpick_object, " character: ", character)
    return o
end