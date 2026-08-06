require "TimedActions/ISBaseTimedAction"

ISUnHotwire = ISBaseTimedAction:derive("ISUnHotwire")

function ISUnHotwire:isValid()
	local vehicle = self.character:getVehicle()
	return vehicle ~= nil and
		vehicle:isDriver(self.character) and
		not vehicle:isEngineRunning() and
		not vehicle:isEngineStarted()
end

function ISUnHotwire:update()
end

function ISUnHotwire:start()
end

function ISUnHotwire:stop()
	ISBaseTimedAction.stop(self)
end

function ISUnHotwire:perform()
	local vehicle = self.character:getVehicle()
	sendClientCommand(self.character, "BetLockHotwire", "unhotwire", { vehicle = vehicle:getId() })
	ISBaseTimedAction.perform(self)
end

function ISUnHotwire:new(character)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.maxTime = 1000 - (character:getPerkLevel(Perks.Electricity) * 65);
	return o
end
