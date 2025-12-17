-- ═══════════════════════════════════════════════════════════════
-- HM DAIRY SYSTEM - SERVER
-- ═══════════════════════════════════════════════════════════════

local cooldowns = {} -- Format: [identifier_cowIndex] = timestamp

-- ═══════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function GetCooldownKey(identifier, cowIndex)
    return identifier .. '_cow' .. cowIndex
end

local function IsOnCooldown(identifier, cowIndex)
    local key = GetCooldownKey(identifier, cowIndex)
    local cooldownTime = cooldowns[key]
    
    if not cooldownTime then
        return false, 0
    end
    
    local currentTime = os.time()
    local cooldownDuration = Config.Milking.Cooldown * 60 -- Convert minutes to seconds
    local timeLeft = cooldownDuration - (currentTime - cooldownTime)
    
    if timeLeft > 0 then
        return true, math.ceil(timeLeft / 60) -- Return minutes left
    else
        cooldowns[key] = nil
        return false, 0
    end
    
end

local function SetCooldown(identifier, cowIndex)
    local key = GetCooldownKey(identifier, cowIndex)
    cooldowns[key] = os.time()
    
    if Config.Debug then
        print('^3[HM Dairy] Cooldown set for ' .. key .. ' at ' .. os.time() .. '^0')
    end
end

-- ═══════════════════════════════════════════════════════════════
-- EVENTS
-- ═══════════════════════════════════════════════════════════════

-- Check if player can milk cow
lib.callback.register('hm_dairy:server:canMilkCow', function(source, cowIndex)
    local identifier = Framework.GetPlayerIdentifier(source)
    
    if not identifier then
        if Config.Debug then
            print('^1[HM Dairy] ERROR: Could not get player identifier for source ' .. source .. '^0')
        end
        return false, 'error'
    end
    
    -- Check required items
    if not Inventory.HasItem(source, Config.Milking.RequiredItems.bucket, 1) then
        return false, 'missing_bucket'
    end
    
    if not Inventory.HasItem(source, Config.Milking.RequiredItems.stool, 1) then
        return false, 'missing_stool'
    end
    
    -- Check cooldown
    local onCooldown, minutesLeft = IsOnCooldown(identifier, cowIndex)
    if onCooldown then
        return false, 'cooldown', minutesLeft
    end
    
    -- Check inventory space
    if not Inventory.CanCarryItem(source, Config.Milking.Output.item, Config.Milking.Output.amount) then
        return false, 'no_space'
    end
    
    return true, 'success'
end)

-- Process milking (after progress bar completes)
RegisterNetEvent('hm_dairy:server:processMilking', function(cowIndex)
    local source = source
    local identifier = Framework.GetPlayerIdentifier(source)
    
    if not identifier then
        if Config.Debug then
            print('^1[HM Dairy] ERROR: Could not get player identifier for source ' .. source .. '^0')
        end
        return
    end
    
    -- Double-check items (anti-cheat)
    if not Inventory.HasItem(source, Config.Milking.RequiredItems.bucket, 1) then
        if Config.Debug then
            print('^1[HM Dairy] CHEAT ATTEMPT: Player ' .. source .. ' tried to milk without bucket^0')
        end
        return
    end
    
    if not Inventory.HasItem(source, Config.Milking.RequiredItems.stool, 1) then
        if Config.Debug then
            print('^1[HM Dairy] CHEAT ATTEMPT: Player ' .. source .. ' tried to milk without stool^0')
        end
        return
    end
    
    -- Check cooldown again (anti-cheat)
    local onCooldown, minutesLeft = IsOnCooldown(identifier, cowIndex)
    if onCooldown then
        if Config.Debug then
            print('^1[HM Dairy] CHEAT ATTEMPT: Player ' .. source .. ' tried to bypass cooldown^0')
        end
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Dairy Farm',
            description = Config.Notifications.Error.cooldown:format(minutesLeft),
            type = 'error'
        })
        return
    end
    
    -- Check inventory space again (anti-cheat)
    if not Inventory.CanCarryItem(source, Config.Milking.Output.item, Config.Milking.Output.amount) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Dairy Farm',
            description = Config.Notifications.Error.no_space,
            type = 'error'
        })
        return
    end
    
    -- Give milk
    local success = Inventory.AddItem(source, Config.Milking.Output.item, Config.Milking.Output.amount)
    
    if success then
        -- Set cooldown
        SetCooldown(identifier, cowIndex)
        
        -- Notify player
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Dairy Farm',
            description = Config.Notifications.Success.milked,
            type = 'success'
        })
        
        if Config.Debug then
            print('^2[HM Dairy] Player ' .. source .. ' successfully milked cow #' .. cowIndex .. '^0')
        end
    else
        if Config.Debug then
            print('^1[HM Dairy] ERROR: Failed to add milk to player ' .. source .. ' inventory^0')
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- COOLDOWN CLEANUP (every 30 minutes)
-- ═══════════════════════════════════════════════════════════════

CreateThread(function()
    while true do
        Wait(30 * 60 * 1000) -- 30 minutes
        
        local currentTime = os.time()
        local cooldownDuration = Config.Milking.Cooldown * 60
        local cleaned = 0
        
        for key, timestamp in pairs(cooldowns) do
            if (currentTime - timestamp) > cooldownDuration then
                cooldowns[key] = nil
                cleaned = cleaned + 1
            end
        end
        
        if Config.Debug and cleaned > 0 then
            print('^3[HM Dairy] Cleaned up ' .. cleaned .. ' expired cooldowns^0')
        end
    end
end)



-- ═══════════════════════════════════════════════════════════════
-- DEBUG COMMANDS
-- ═══════════════════════════════════════════════════════════════

if Config.Debug then
    RegisterCommand('dairy_cooldowns', function(source)
        local count = 0
        for _ in pairs(cooldowns) do count = count + 1 end
        print('^3[HM Dairy] Active cooldowns: ' .. count .. '^0')
        for key, timestamp in pairs(cooldowns) do
            print('^3  - ' .. key .. ': ' .. os.date('%Y-%m-%d %H:%M:%S', timestamp) .. '^0')
        end
    end, true)
    
    RegisterCommand('dairy_clearcooldowns', function(source)
        cooldowns = {}
        print('^2[HM Dairy] All cooldowns cleared!^0')
    end, true)
end