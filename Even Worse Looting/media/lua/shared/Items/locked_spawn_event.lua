locked_spawn_event = function(roomName, containerType, container)
	--locked_Spawn2(roomName, containerType, container)
	locked_Spawn(roomName, containerType, container)
end

Events.OnFillContainer.Add ( locked_spawn_event )

