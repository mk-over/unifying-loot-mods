-- function WorseSearching_ServerVehicles(part)
	-- local vehicle = part:getVehicle()
	-- vehicle:transmitPartModData(part)
-- end

if not isServer() then return end 
local Commands = {}
Commands.Worse_Searching = {}

Commands.Worse_Searching.Searched = function(player, args)
	print("Trying to apply search state 1")
	local vehicle = getVehicleById(args.vehicle)
	if vehicle then
		local part = vehicle:getPartById(args.part)
		local mData = part:getModData()
		mData.searched = true
		vehicle:transmitPartModData(part)
	end
end


local onClientCommand = function(module, command, player, args)
	if Commands[module] and Commands[module][command] then
		Commands[module][command](player, args)
	end
end

Events.OnClientCommand.Add(onClientCommand)
