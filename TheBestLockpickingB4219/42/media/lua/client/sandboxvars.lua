SandboxVars = SandboxVars or {}

SandboxVars.LockpickingSystem = {
    LockpickingMode = 1, -- 1 = Старая система, 2 = Новая система
}

-- In B42.19 MP, AddXP for custom mod perks (declared in perks.txt) does not
-- automatically sync to the client. The server sends "xpGranted" so the client
-- can apply the XP locally to update the skill bar display.
-- isClient() guard prevents double-adding in single-player (where server and
-- client share the same process and AddXP already modifies the live object).
Events.OnServerCommand.Add(function(module, command, args)
    if module ~= "BetLock" or command ~= "xpGranted" then return end
    print("[BetLock][CLIENT] xpGranted received | isClient=" .. tostring(isClient()) .. " | isCoopHost=" .. tostring(isCoopHost()))
    if not isClient() and not isCoopHost() then return end
    local perk = Perks.Lockpicking
    local amount = tonumber(args.amount) or 0
    print("[BetLock][CLIENT] perk=" .. tostring(perk) .. " | amount=" .. tostring(amount))
    if perk and amount > 0 then
        local player = getPlayer()
        if player then
            addXp(player, perk, amount)
            print("[BetLock][CLIENT] addXp done | new level=" .. tostring(player:getPerkLevel(perk)))
        else
            print("[BetLock][CLIENT] getPlayer() returned nil")
        end
    end
end)