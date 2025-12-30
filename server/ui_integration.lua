-- server/ui_integration.lua
-- HM Dairy UI Server - SECURE VERSION mit tgiann-inventory Support

local cowCooldowns = {} -- Table: [source][cowIndex] = timestamp
local DEBUG = Config.Debug

local function DebugPrint(msg)
    if DEBUG then
        print('[HM Dairy Server] ' .. msg)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- DISCORD LOGGING
-- ═══════════════════════════════════════════════════════════════

local function SendDiscordLog(eventType, data)
    if not SvConfig.Discord.Enabled then return end
    if not SvConfig.Discord.Webhook or SvConfig.Discord.Webhook == '' then return end
    
    local embed = {}
    local color = SvConfig.Discord.Colors.Info
    
    if eventType == 'MilkCow' then
        color = SvConfig.Discord.Colors.Success
        embed = {
            title = '🐄 Cow Milked',
            description = string.format('Player %d milked Cow #%d', data.player, data.cowIndex),
            fields = {
                { name = 'Player', value = tostring(data.player), inline = true },
                { name = 'Cow', value = '#' .. data.cowIndex, inline = true },
                { name = 'Item', value = data.item, inline = true },
                { name = 'Amount', value = tostring(data.amount), inline = true },
            },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%S')
        }
    elseif eventType == 'RateLimit' then
        color = SvConfig.Discord.Colors.Warning
        embed = {
            title = '⚠️ Rate Limit Exceeded',
            description = string.format('Player %d triggered rate limit', data.player),
            fields = {
                { name = 'Player', value = tostring(data.player), inline = true },
                { name = 'Action', value = data.action, inline = true },
            },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%S')
        }
    elseif eventType == 'DistanceCheat' then
        color = SvConfig.Discord.Colors.Error
        embed = {
            title = '🚨 Distance Check Failed',
            description = string.format('Player %d tried to milk from too far away', data.player),
            fields = {
                { name = 'Player', value = tostring(data.player), inline = true },
                { name = 'Cow', value = '#' .. data.cowIndex, inline = true },
                { name = 'Distance', value = string.format('%.2fm', data.distance), inline = true },
            },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%S')
        }
    elseif eventType == 'InvalidCow' then
        color = SvConfig.Discord.Colors.Error
        embed = {
            title = '🚨 Invalid Cow Index',
            description = string.format('Player %d used invalid cow index', data.player),
            fields = {
                { name = 'Player', value = tostring(data.player), inline = true },
                { name = 'Cow Index', value = tostring(data.cowIndex), inline = true },
            },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%S')
        }
    end
    
    embed.color = color
    
    PerformHttpRequest(SvConfig.Discord.Webhook, function(err, text, headers) end, 'POST', json.encode({
        username = SvConfig.Discord.BotName,
        avatar_url = SvConfig.Discord.BotAvatar,
        embeds = { embed }
    }), { ['Content-Type'] = 'application/json' })
end

-- ═══════════════════════════════════════════════════════════════
-- COOLDOWN MANAGEMENT
-- ═══════════════════════════════════════════════════════════════

local function IsOnCooldown(source, cowIndex)
    if not cowCooldowns[source] then
        return false
    end
    
    local lastMilked = cowCooldowns[source][cowIndex]
    if not lastMilked then
        return false
    end
    
    local cooldownTime = Config.Milking.Cooldown * 60 -- Minuten zu Sekunden
    local currentTime = os.time()
    local timePassed = currentTime - lastMilked
    
    return timePassed < cooldownTime
end

local function GetCooldownRemaining(source, cowIndex)
    if not cowCooldowns[source] then
        return 0
    end
    
    local lastMilked = cowCooldowns[source][cowIndex]
    if not lastMilked then
        return 0
    end
    
    local cooldownTime = Config.Milking.Cooldown * 60
    local currentTime = os.time()
    local timePassed = currentTime - lastMilked
    local remaining = cooldownTime - timePassed
    
    return remaining > 0 and remaining or 0
end

local function SetCooldown(source, cowIndex)
    if not cowCooldowns[source] then
        cowCooldowns[source] = {}
    end
    cowCooldowns[source][cowIndex] = os.time()
    
    DebugPrint('Cooldown set for Player ' .. source .. ', Cow #' .. cowIndex)
end

-- ═══════════════════════════════════════════════════════════════
-- COW DATA
-- ═══════════════════════════════════════════════════════════════

local function GetCowData(source, cowIndex)
    local isOnCooldown = IsOnCooldown(source, cowIndex)
    local cooldownRemaining = GetCooldownRemaining(source, cowIndex)
    
    return {
        id = cowIndex,
        name = 'Kuh #' .. cowIndex,
        canMilk = not isOnCooldown,
        cooldownRemaining = cooldownRemaining,
        production = math.random(70, 95)
    }
end

-- ═══════════════════════════════════════════════════════════════
-- EVENT: UI öffnen
-- ═══════════════════════════════════════════════════════════════

RegisterNetEvent('hm_dairy:server:openUI', function(cowIndex)
    local src = source
    
    -- 🔒 SECURITY: Rate Limit Check
    if not Security.CheckRateLimit(src, 'openUI', 10, 60) then
        TriggerClientEvent('hm_dairy:client:showNotification', src, 
            'Slow down! Too many UI opens.')
        return
    end
    
    -- 🔒 SECURITY: Validate Player
    if not Security.ValidatePlayer(src) then
        return
    end
    
    -- 🔒 SECURITY: Validate Cow Index (if provided)
    if cowIndex and not Security.ValidateCowIndex(cowIndex) then
        DebugPrint('ERROR: Invalid cow index ' .. tostring(cowIndex) .. ' from player ' .. src)
        TriggerClientEvent('hm_dairy:client:showNotification', src, 
            'Error: Invalid cow!')
        return
    end
    
    DebugPrint('Player ' .. src .. ' opens UI' .. (cowIndex and ' for Cow #' .. cowIndex or ' (all cows)'))
    
    -- Modus: Single Cow oder Alle
    if cowIndex and not Config.UI.ShowAllCows then
        -- NUR die eine Kuh
        local cow = GetCowData(src, cowIndex)
        TriggerClientEvent('hm_dairy:client:openUI', src, cow)
    else
        -- Alle Kühe (Fallback)
        local cows = {}
        local totalCows = #Config.CowSpawns.Locations
        
        for i = 1, totalCows do
            table.insert(cows, GetCowData(src, i))
        end
        
        TriggerClientEvent('hm_dairy:client:openUI', src, cows)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- EVENT: Kuh melken (SECURE VERSION)
-- ═══════════════════════════════════════════════════════════════

RegisterNetEvent('hm_dairy:server:milkCow', function(cowIndex)
    local src = source
    
    DebugPrint('Player ' .. src .. ' attempts to milk Cow #' .. cowIndex)
    
    -- 🔒 SECURITY 1: Rate Limit Check (10 actions per minute)
    if not Security.CheckRateLimit(src, 'milkCow', 10, 60) then
        DebugPrint('BLOCKED: Rate limit exceeded for player ' .. src)
        TriggerClientEvent('hm_dairy:client:showNotification', src, 
            'Slow down! Du melkst zu schnell.')
        
        -- Discord Log
        if SvConfig.Discord.Enabled and SvConfig.Discord.LogEvents.RateLimit then
            SendDiscordLog('RateLimit', { player = src, action = 'milkCow' })
        end
        
        return
    end
    
    -- 🔒 SECURITY 2: Action Cooldown (5 seconds between attempts)
    if not Security.CheckCooldown(src, 'milkAction', 5) then
        DebugPrint('BLOCKED: Action cooldown for player ' .. src)
        TriggerClientEvent('hm_dairy:client:showNotification', src, 
            'Warte 5 Sekunden!')
        return
    end
    
    -- 🔒 SECURITY 3: Validate Player
    if not Security.ValidatePlayer(src) then
        DebugPrint('BLOCKED: Invalid player ' .. src)
        return
    end
    
    -- 🔒 SECURITY 4: Validate Cow Index
    if not Security.ValidateCowIndex(cowIndex) then
        DebugPrint('BLOCKED: Invalid cow index ' .. tostring(cowIndex) .. ' from player ' .. src)
        TriggerClientEvent('hm_dairy:client:showNotification', src, 
            'Error: Invalid cow!')
        
        -- Discord Log
        if SvConfig.Discord.Enabled and SvConfig.Discord.LogEvents.InvalidCow then
            SendDiscordLog('InvalidCow', { player = src, cowIndex = cowIndex })
        end
        
        return
    end
    
    -- 🔒 SECURITY 5: Distance Validation
    local cowLocation = Security.GetCowLocation(cowIndex)
    if not cowLocation then
        DebugPrint('ERROR: Could not get location for cow #' .. cowIndex)
        return
    end
    
    if not Security.ValidateDistance(src, cowLocation, Config.UI.MaxDistance) then
        DebugPrint('BLOCKED: Player ' .. src .. ' too far from Cow #' .. cowIndex)
        
        -- Calculate actual distance for log
        local playerPed = GetPlayerPed(src)
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - cowLocation)
        
        TriggerClientEvent('hm_dairy:client:showNotification', src, 
            'Du bist zu weit von der Kuh entfernt!')
        
        -- Discord Log
        if SvConfig.Discord.Enabled and SvConfig.Discord.LogEvents.DistanceCheat then
            SendDiscordLog('DistanceCheat', { 
                player = src, 
                cowIndex = cowIndex,
                distance = distance
            })
        end
        
        return
    end
    
    -- 🔒 SECURITY 6: Cow Cooldown Check
    if IsOnCooldown(src, cowIndex) then
        local remaining = math.ceil(GetCooldownRemaining(src, cowIndex) / 60)
        DebugPrint('BLOCKED: Cow #' .. cowIndex .. ' on cooldown for player ' .. src .. ' (' .. remaining .. 'm remaining)')
        TriggerClientEvent('hm_dairy:client:showNotification', src, 
            'Diese Kuh wurde kürzlich gemolken! Noch ' .. remaining .. ' Minuten warten.')
        return
    end
    
    -- 🔒 SECURITY 7: Items Check (wenn aktiviert)
    if Config.Milking.RequireItems then
        local hasBucket = Inventory.HasItem(src, Config.Milking.RequiredItems.bucket, 1)
        local hasStool = Inventory.HasItem(src, Config.Milking.RequiredItems.stool, 1)
        
        if not hasBucket or not hasStool then
            DebugPrint('BLOCKED: Player ' .. src .. ' missing required items')
            TriggerClientEvent('hm_dairy:client:showNotification', src, 
                'Du benötigst einen Melkeimer und einen Melkschemel!')
            return
        end
    end
    
    -- 🔒 SECURITY 8: Inventory Space Check
    if not Inventory.CanCarryItem(src, Config.Milking.Output.item, Config.Milking.Output.amount) then
        DebugPrint('BLOCKED: Player ' .. src .. ' inventory full')
        TriggerClientEvent('hm_dairy:client:showNotification', src, 
            'Dein Inventar ist voll!')
        return
    end
    
    -- ✅ ALL CHECKS PASSED - Process Milking
    
    -- Set Cooldown
    SetCooldown(src, cowIndex)
    
    -- Give Milk
    local success = Inventory.AddItem(src, 
        Config.Milking.Output.item, 
        Config.Milking.Output.amount)
    
    if success then
        DebugPrint('SUCCESS: Player ' .. src .. ' milked Cow #' .. cowIndex)
        TriggerClientEvent('hm_dairy:client:showNotification', src, 
            'Kuh erfolgreich gemolken! +' .. Config.Milking.Output.amount .. 'x ' .. Config.Milking.Output.label)
        
        -- Discord Logging
        if SvConfig.Discord.Enabled and SvConfig.Discord.LogEvents.MilkCow then
            SendDiscordLog('MilkCow', {
                player = src,
                cowIndex = cowIndex,
                item = Config.Milking.Output.item,
                amount = Config.Milking.Output.amount
            })
        end
    else
        DebugPrint('ERROR: Failed to add item to player ' .. src)
        TriggerClientEvent('hm_dairy:client:showNotification', src, 
            'Fehler: Item konnte nicht hinzugefügt werden!')
        
        -- Rollback: Remove cooldown on failure
        if cowCooldowns[src] then
            cowCooldowns[src][cowIndex] = nil
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════

-- Cleanup beim Disconnect
AddEventHandler('playerDropped', function(reason)
    local src = source
    if cowCooldowns[src] then
        cowCooldowns[src] = nil
        DebugPrint('Cooldowns removed for disconnected player ' .. src)
    end
end)

-- Cleanup expired cooldowns (every 30 minutes)
CreateThread(function()
    while true do
        Wait(30 * 60 * 1000) -- 30 minutes
        
        local currentTime = os.time()
        local cooldownDuration = Config.Milking.Cooldown * 60
        local cleaned = 0
        
        for source, cows in pairs(cowCooldowns) do
            for cowIndex, timestamp in pairs(cows) do
                if (currentTime - timestamp) > cooldownDuration then
                    cowCooldowns[source][cowIndex] = nil
                    cleaned = cleaned + 1
                end
            end
        end
        
        if DEBUG and cleaned > 0 then
            print('^3[HM Dairy] Cleaned up ' .. cleaned .. ' expired cow cooldowns^0')
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- DEBUG COMMANDS
-- ═══════════════════════════════════════════════════════════════

if DEBUG then
    RegisterCommand('dairy_cooldowns', function(source)
        local count = 0
        for src, cows in pairs(cowCooldowns) do
            for cowIndex, _ in pairs(cows) do
                count = count + 1
            end
        end
        print('^3[HM Dairy] Active cow cooldowns: ' .. count .. '^0')
        
        for src, cows in pairs(cowCooldowns) do
            for cowIndex, timestamp in pairs(cows) do
                local remaining = GetCooldownRemaining(src, cowIndex)
                print('^3  - Player ' .. src .. ', Cow #' .. cowIndex .. ': ' .. math.ceil(remaining / 60) .. 'm remaining^0')
            end
        end
    end, true)
    
    RegisterCommand('dairy_clearcooldowns', function(source)
        cowCooldowns = {}
        print('^2[HM Dairy] All cow cooldowns cleared!^0')
    end, true)
end

DebugPrint('UI Integration loaded (SECURE VERSION - Single-Cow Mode: ' .. tostring(not Config.UI.ShowAllCows) .. ')')
print('^2[HM Dairy] Inventory System: ' .. Inventory.GetInventoryName() .. '^0')