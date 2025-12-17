-- server/ui_integration.lua
-- HM Dairy UI Server - Mit Single-Cow Support

local cowCooldowns = {} -- Table: [playerId][cowIndex] = timestamp
local DEBUG = Config.Debug

local function DebugPrint(msg)
    if DEBUG then
        print('[HM Dairy Server] ' .. msg)
    end
end

-- Hilfsfunktion: Cooldown checken
local function IsOnCooldown(source, cowIndex)
    if not cowCooldowns[source] then
        cowCooldowns[source] = {}
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

-- Hilfsfunktion: Verbleibende Cooldown-Zeit
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

-- Hilfsfunktion: Einzelne Kuh-Daten erstellen
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

-- Event: UI öffnen
RegisterNetEvent('hm_dairy:server:openUI', function(cowIndex)
    local src = source
    
    DebugPrint('Spieler ' .. src .. ' öffnet UI' .. (cowIndex and ' für Kuh #' .. cowIndex or ' (alle Kühe)'))
    
    -- Modus checken: Einzelne Kuh oder alle?
    if cowIndex and not Config.UI.ShowAllCows then
        -- NUR die eine Kuh
        local cow = GetCowData(src, cowIndex)
        DebugPrint('Sende Kuh #' .. cowIndex .. ' an Spieler ' .. src)
        TriggerClientEvent('hm_dairy:client:openUI', src, cow)
    else
        -- Alle Kühe (Fallback für Testing oder wenn ShowAllCows = true)
        local cows = {}
        local totalCows = #Config.CowSpawns.Locations
        
        for i = 1, totalCows do
            table.insert(cows, GetCowData(src, i))
        end
        
        DebugPrint('Sende ' .. #cows .. ' Kühe an Spieler ' .. src)
        TriggerClientEvent('hm_dairy:client:openUI', src, cows)
    end
end)

-- Event: Kuh melken
RegisterNetEvent('hm_dairy:server:milkCow', function(cowIndex)
    local src = source
    
    DebugPrint('Spieler ' .. src .. ' melkt Kuh #' .. cowIndex)
    
    -- 1. Cooldown checken
    if IsOnCooldown(src, cowIndex) then
        local remaining = math.ceil(GetCooldownRemaining(src, cowIndex) / 60)
        TriggerClientEvent('hm_dairy:client:showNotification', src, 
            'Diese Kuh wurde kürzlich gemolken! Noch ' .. remaining .. ' Minuten warten.')
        return
    end
    
    -- 2. Items checken (wenn aktiviert)
    if Config.Milking.RequireItems then
        local hasItems = exports.ox_inventory:Search(src, 'count', {
            Config.Milking.RequiredItems.bucket,
            Config.Milking.RequiredItems.stool
        })
        
        if not hasItems or 
           hasItems[Config.Milking.RequiredItems.bucket] < 1 or 
           hasItems[Config.Milking.RequiredItems.stool] < 1 then
            TriggerClientEvent('hm_dairy:client:showNotification', src, 
                'Du benötigst einen Melkeimer und einen Melkschemel!')
            return
        end
    end
    
    -- 3. Cooldown setzen
    if not cowCooldowns[src] then
        cowCooldowns[src] = {}
    end
    cowCooldowns[src][cowIndex] = os.time()
    
    -- 4. Item geben
    local success = exports.ox_inventory:AddItem(src, 
        Config.Milking.Output.item, 
        Config.Milking.Output.amount)
    
    if success then
        DebugPrint('Spieler ' .. src .. ' hat Kuh #' .. cowIndex .. ' erfolgreich gemolken')
        TriggerClientEvent('hm_dairy:client:showNotification', src, 
            'Kuh erfolgreich gemolken! +' .. Config.Milking.Output.amount .. 'x ' .. Config.Milking.Output.label)
    else
        DebugPrint('FEHLER: Konnte Item nicht geben an Spieler ' .. src)
        TriggerClientEvent('hm_dairy:client:showNotification', src, 
            'Fehler: Item konnte nicht hinzugefügt werden!')
        
        -- Cooldown zurücksetzen bei Fehler
        if cowCooldowns[src] then
            cowCooldowns[src][cowIndex] = nil
        end
    end
end)

-- Cleanup beim Disconnect
AddEventHandler('playerDropped', function(reason)
    local src = source
    if cowCooldowns[src] then
        cowCooldowns[src] = nil
        DebugPrint('Cooldowns für Spieler ' .. src .. ' entfernt')
    end
end)

DebugPrint('UI Integration geladen (Single-Cow Mode: ' .. tostring(not Config.UI.ShowAllCows) .. ')')