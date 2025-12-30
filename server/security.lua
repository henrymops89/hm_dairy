-- server/security.lua
-- Security System für HM Dairy
-- Rate Limiting, Cooldowns, Distance Validation

Security = {}

-- ═══════════════════════════════════════════════════════════════
-- RATE LIMITING SYSTEM
-- ═══════════════════════════════════════════════════════════════

local rateLimits = {} -- [source][action] = { count, firstAction }

function Security.CheckRateLimit(source, action, maxActions, timeWindow)
    maxActions = maxActions or 10
    timeWindow = timeWindow or 60
    
    local identifier = action .. '_' .. source
    local currentTime = os.time()
    
    if not rateLimits[identifier] then
        rateLimits[identifier] = { count = 1, firstAction = currentTime }
        return true
    end
    
    local data = rateLimits[identifier]
    local elapsed = currentTime - data.firstAction
    
    if elapsed > timeWindow then
        rateLimits[identifier] = { count = 1, firstAction = currentTime }
        return true
    end
    
    if data.count >= maxActions then
        if Config.Debug then
            print('^1[HM Dairy Security] Rate limit exceeded for ' .. source .. ' (action: ' .. action .. ')^0')
        end
        return false
    end
    
    data.count = data.count + 1
    return true
end

-- ═══════════════════════════════════════════════════════════════
-- COOLDOWN SYSTEM
-- ═══════════════════════════════════════════════════════════════

local playerCooldowns = {} -- [source] = { [action] = timestamp }

function Security.CheckCooldown(source, action, seconds)
    local identifier = action .. '_' .. source
    local currentTime = os.time()
    
    if playerCooldowns[identifier] then
        local elapsed = currentTime - playerCooldowns[identifier]
        if elapsed < seconds then
            if Config.Debug then
                print('^3[HM Dairy Security] Cooldown active for ' .. source .. ' (action: ' .. action .. ', remaining: ' .. (seconds - elapsed) .. 's)^0')
            end
            return false
        end
    end
    
    playerCooldowns[identifier] = currentTime
    return true
end

function Security.GetCooldownRemaining(source, action, seconds)
    local identifier = action .. '_' .. source
    local currentTime = os.time()
    
    if playerCooldowns[identifier] then
        local elapsed = currentTime - playerCooldowns[identifier]
        local remaining = seconds - elapsed
        return remaining > 0 and remaining or 0
    end
    
    return 0
end

-- ═══════════════════════════════════════════════════════════════
-- DISTANCE VALIDATION
-- ═══════════════════════════════════════════════════════════════

function Security.ValidateDistance(source, targetCoords, maxDistance)
    local playerPed = GetPlayerPed(source)
    if playerPed == 0 then
        if Config.Debug then
            print('^1[HM Dairy Security] Invalid player ped for source ' .. source .. '^0')
        end
        return false
    end
    
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - targetCoords)
    
    if distance > maxDistance then
        if Config.Debug then
            print('^1[HM Dairy Security] Distance check failed for ' .. source .. ' (distance: ' .. distance .. ', max: ' .. maxDistance .. ')^0')
        end
        return false
    end
    
    return true
end

-- ═══════════════════════════════════════════════════════════════
-- COW VALIDATION
-- ═══════════════════════════════════════════════════════════════

function Security.ValidateCowIndex(cowIndex)
    if not cowIndex or type(cowIndex) ~= 'number' then
        if Config.Debug then
            print('^1[HM Dairy Security] Invalid cow index type: ' .. type(cowIndex) .. '^0')
        end
        return false
    end
    
    if cowIndex < 1 or cowIndex > #Config.CowSpawns.Locations then
        if Config.Debug then
            print('^1[HM Dairy Security] Cow index out of range: ' .. cowIndex .. ' (max: ' .. #Config.CowSpawns.Locations .. ')^0')
        end
        return false
    end
    
    return true
end

function Security.GetCowLocation(cowIndex)
    if not Security.ValidateCowIndex(cowIndex) then
        return nil
    end
    
    local location = Config.CowSpawns.Locations[cowIndex]
    if not location or not location.coords then
        if Config.Debug then
            print('^1[HM Dairy Security] No location found for cow #' .. cowIndex .. '^0')
        end
        return nil
    end
    
    return vector3(location.coords.x, location.coords.y, location.coords.z)
end

-- ═══════════════════════════════════════════════════════════════
-- PLAYER VALIDATION
-- ═══════════════════════════════════════════════════════════════

function Security.ValidatePlayer(source)
    if not source or source < 1 then
        if Config.Debug then
            print('^1[HM Dairy Security] Invalid source: ' .. tostring(source) .. '^0')
        end
        return false
    end
    
    local playerPed = GetPlayerPed(source)
    if playerPed == 0 then
        if Config.Debug then
            print('^1[HM Dairy Security] Player ped not found for source ' .. source .. '^0')
        end
        return false
    end
    
    -- Check if player is alive
    if IsPlayerDead(source) then
        if Config.Debug then
            print('^3[HM Dairy Security] Player ' .. source .. ' is dead^0')
        end
        return false
    end
    
    return true
end

-- ═══════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════

-- Cleanup expired rate limits (every 5 minutes)
CreateThread(function()
    while true do
        Wait(5 * 60 * 1000) -- 5 minutes
        
        local currentTime = os.time()
        local cleaned = 0
        
        for identifier, data in pairs(rateLimits) do
            if (currentTime - data.firstAction) > 120 then -- 2 minutes old
                rateLimits[identifier] = nil
                cleaned = cleaned + 1
            end
        end
        
        if Config.Debug and cleaned > 0 then
            print('^3[HM Dairy Security] Cleaned up ' .. cleaned .. ' expired rate limits^0')
        end
    end
end)

-- Cleanup on player disconnect
AddEventHandler('playerDropped', function(reason)
    local source = source
    
    -- Clean rate limits
    for identifier, _ in pairs(rateLimits) do
        if string.find(identifier, '_' .. source) then
            rateLimits[identifier] = nil
        end
    end
    
    -- Clean cooldowns
    for identifier, _ in pairs(playerCooldowns) do
        if string.find(identifier, '_' .. source) then
            playerCooldowns[identifier] = nil
        end
    end
    
    if Config.Debug then
        print('^3[HM Dairy Security] Cleaned up data for disconnected player ' .. source .. '^0')
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- DEBUG COMMANDS
-- ═══════════════════════════════════════════════════════════════

if Config.Debug then
    RegisterCommand('dairy_security_stats', function(source)
        local rateLimitCount = 0
        local cooldownCount = 0
        
        for _ in pairs(rateLimits) do rateLimitCount = rateLimitCount + 1 end
        for _ in pairs(playerCooldowns) do cooldownCount = cooldownCount + 1 end
        
        print('^3[HM Dairy Security] Stats:^0')
        print('^3  - Active rate limits: ' .. rateLimitCount .. '^0')
        print('^3  - Active cooldowns: ' .. cooldownCount .. '^0')
    end, true)
    
    RegisterCommand('dairy_security_reset', function(source)
        rateLimits = {}
        playerCooldowns = {}
        print('^2[HM Dairy Security] All security data reset!^0')
    end, true)
end

print('^2[HM Dairy Security] Security system loaded^0')