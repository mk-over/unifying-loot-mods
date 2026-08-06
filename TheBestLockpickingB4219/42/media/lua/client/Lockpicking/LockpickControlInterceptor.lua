local currentInterceptor = nil

local function setupInterceptor()
    local originalOnPlayerUpdate = nil
    local isTrueCrawlPresent = false

    if TrueCrawl and TrueCrawl.OnPlayerUpdate then
        isTrueCrawlPresent = true
        originalOnPlayerUpdate = TrueCrawl.OnPlayerUpdate
    end

    local function onPlayerUpdate(isoPlayer)
        local modData = isoPlayer:getModData()
        local isLockpicking = modData.isLockpicking

        if isLockpicking then
            isoPlayer:setBlockMovement(true)
            isoPlayer:setBannedAttacking(true)
            isoPlayer:setIgnoreAimingInput(true)
            if isTrueCrawlPresent then
                isoPlayer:setVariable("isCrawling", false)
            end
            return
        end

        if isTrueCrawlPresent and originalOnPlayerUpdate then
            originalOnPlayerUpdate(isoPlayer)
        end

        -- Cleanup: runs exactly once after lockpicking ends.
        -- Unconditionally resets all flags — do NOT gate on isBlockMovement(),
        -- because in B42 setBlockMovement auto-resets each frame, so
        -- isBlockMovement() would already be false here, causing setIgnoreAimingInput
        -- to never be cleared and permanently breaking RMB.
        if modData.isLockpicking == false then
            isoPlayer:setBlockMovement(false)
            isoPlayer:setBannedAttacking(false)
            isoPlayer:setIgnoreAimingInput(false)
            modData.isLockpicking = nil
        end
    end

    if currentInterceptor then
        Events.OnPlayerUpdate.Remove(currentInterceptor)
    end
    if isTrueCrawlPresent and originalOnPlayerUpdate then
        Events.OnPlayerUpdate.Remove(originalOnPlayerUpdate)
    end
    currentInterceptor = onPlayerUpdate
    Events.OnPlayerUpdate.Add(onPlayerUpdate)
end

Events.OnGameStart.Add(function()
    setupInterceptor()
end)
