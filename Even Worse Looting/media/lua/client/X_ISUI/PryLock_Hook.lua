function pryLockedContainer_Hook (player, context, worldobjects, test)
	pryLockedContainer_Context(player, context, worldobjects, test)
end

Events.OnPreFillWorldObjectContextMenu.Add(pryLockedContainer_Hook)	