-- client/main.lua
-- HM Dairy UI - Mit Single-Cow Support

local DEBUG = Config.Debug
local currentCowEntity = nil

local function DebugPrint(msg)
    if DEBUG then
        print('[HM Dairy Client] ' .. msg)
    end
end

-- ============================================
-- EVENT HANDLERS FÜR UI
-- ============================================

-- Event: UI öffnen mit Kuh-Daten vom Server
RegisterNetEvent('hm_dairy:client:openUI', function(cow)
    DebugPrint('Öffne UI für Kuh')
    -- Wandle einzelne Kuh in Array um (UI erwartet Array)
    local cows = cow and {cow} or {}
    OpenDairyUI(cows)
end)

-- Event: Notification anzeigen
RegisterNetEvent('hm_dairy:client:showNotification', function(message)
    DebugPrint('Notification: ' .. message)
    ShowDairyNotification(message)
end)

-- Event: Melken starten (wird von UI getriggert über NUI Callback)
RegisterNetEvent('hm_dairy:client:startMilking', function(cowId)
    DebugPrint('Starte Melken für Kuh #' .. cowId)
    
    -- UI schließen
    CloseDairyUI()
    
    -- Items checken (wenn aktiviert)
    if Config.Milking.RequireItems then
        local hasItems = exports.ox_inventory:Search('count', {
            Config.Milking.RequiredItems.bucket,
            Config.Milking.RequiredItems.stool
        })
        
        if not hasItems or 
           hasItems[Config.Milking.RequiredItems.bucket] < 1 or 
           hasItems[Config.Milking.RequiredItems.stool] < 1 then
            ShowDairyNotification('Fehlende Items: Melkeimer & Melkschemel!')
            return
        end
    end
    
    -- Checke ob Kuh noch existiert und in Reichweite ist
    if not currentCowEntity or not DoesEntityExist(currentCowEntity) then
        ShowDairyNotification('Kuh nicht gefunden!')
        return
    end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    local cowCoords = GetEntityCoords(currentCowEntity)
    local distance = #(playerCoords - cowCoords)
    
    if distance > Config.UI.MaxDistance then
        ShowDairyNotification('Du bist zu weit von der Kuh entfernt!')
        return
    end
    
    -- Progress Bar starten
    local playerPed = PlayerPedId()
    
    if lib.progressCircle({
        duration = Config.Milking.Duration,
        position = 'bottom',
        label = 'Kuh wird gemolken...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = Config.Milking.Animation.dict,
            clip = Config.Milking.Animation.clip
        }
    }) then
        -- Erfolgreich gemolken - Server benachrichtigen
        DebugPrint('Melken erfolgreich - Benachrichtige Server')
        TriggerServerEvent('hm_dairy:server:milkCow', cowId)
    else
        -- Abgebrochen
        DebugPrint('Melken abgebrochen')
        ShowDairyNotification('Melken abgebrochen!')
    end
    
    -- Reset
    currentCowEntity = nil
end)

-- ============================================
-- TARGET INTEGRATION (ox_target / qb-target)
-- ============================================

if Config.Target.Enabled then
    CreateThread(function()
        local options = {}
        
        -- MELKEN
        if Config.Target.Options.milk and Config.Target.Options.milk.enabled then
            table.insert(options, {
                name = 'hm_dairy_milk',
                label = Config.Target.Options.milk.label,
                icon = Config.Target.Options.milk.icon,
                distance = Config.Target.Distance,
                onSelect = function(data)
                    local entity = data.entity
                    
                    if not entity or not DoesEntityExist(entity) then
                        DebugPrint('Keine gültige Entity!')
                        return
                    end
                    
                    -- Finde Kuh-Index
                    local cowIndex = exports.hm_dairy:GetCowIndexFromEntity(entity)
                    
                    if not cowIndex then
                        DebugPrint('Kuh-Index nicht gefunden!')
                        Framework.Notify('Diese Kuh ist nicht registriert!', 'error')
                        return
                    end
                    
                    DebugPrint('Target: Öffne UI für Kuh #' .. cowIndex)
                    
                    -- Speichere aktuelle Kuh-Entity
                    currentCowEntity = entity
                    
                    -- Server fragen nach Daten für DIESE Kuh
                    TriggerServerEvent('hm_dairy:server:openUI', cowIndex)
                end
            })
        end
        
        -- FÜTTERN (Beispiel für zukünftige Features)
        if Config.Target.Options.feed and Config.Target.Options.feed.enabled then
            table.insert(options, {
                name = 'hm_dairy_feed',
                label = Config.Target.Options.feed.label,
                icon = Config.Target.Options.feed.icon,
                distance = Config.Target.Distance,
                onSelect = function(data)
                    local cowIndex = exports.hm_dairy:GetCowIndexFromEntity(data.entity)
                    if cowIndex then
                        TriggerEvent('hm_dairy:client:feedCow', cowIndex, data.entity)
                    end
                end
            })
        end
        
        -- BÜRSTEN
        if Config.Target.Options.brush and Config.Target.Options.brush.enabled then
            table.insert(options, {
                name = 'hm_dairy_brush',
                label = Config.Target.Options.brush.label,
                icon = Config.Target.Options.brush.icon,
                distance = Config.Target.Distance,
                onSelect = function(data)
                    local cowIndex = exports.hm_dairy:GetCowIndexFromEntity(data.entity)
                    if cowIndex then
                        TriggerEvent('hm_dairy:client:brushCow', cowIndex, data.entity)
                    end
                end
            })
        end
        
        -- STREICHELN
        if Config.Target.Options.pet and Config.Target.Options.pet.enabled then
            table.insert(options, {
                name = 'hm_dairy_pet',
                label = Config.Target.Options.pet.label,
                icon = Config.Target.Options.pet.icon,
                distance = Config.Target.Distance,
                onSelect = function(data)
                    local cowIndex = exports.hm_dairy:GetCowIndexFromEntity(data.entity)
                    if cowIndex then
                        TriggerEvent('hm_dairy:client:petCow', cowIndex, data.entity)
                    end
                end
            })
        end
        
        -- TIERARZT
        if Config.Target.Options.vet and Config.Target.Options.vet.enabled then
            table.insert(options, {
                name = 'hm_dairy_vet',
                label = Config.Target.Options.vet.label,
                icon = Config.Target.Options.vet.icon,
                distance = Config.Target.Distance,
                onSelect = function(data)
                    local cowIndex = exports.hm_dairy:GetCowIndexFromEntity(data.entity)
                    if cowIndex then
                        TriggerEvent('hm_dairy:client:vetCheck', cowIndex, data.entity)
                    end
                end
            })
        end
        
        -- Registriere alle Optionen mit der Target Bridge
        Target.AddModel(Config.CowSpawns.Model, options)
        
        DebugPrint('Target-System (' .. Target.GetSystemName() .. ') mit ' .. #options .. ' Optionen registriert')
    end)
end
-- ============================================
-- COMMANDS (für Testing)
-- ============================================

-- Command: UI direkt öffnen (alle Kühe) - Nur für Testing!
if DEBUG then
    RegisterCommand('dairyui', function()
        DebugPrint('Command /dairyui ausgeführt (Test-Modus)')
        TriggerServerEvent('hm_dairy:server:openUI', nil) -- nil = alle Kühe
    end, false)
end

DebugPrint('Client geladen - Gehe zu einer Kuh und drücke E')
DebugPrint('Setze Config.Debug = false wenn alles funktioniert')

-- TEST COMMAND: Blip manuell erstellen
RegisterCommand('testblip', function()
    local blip = AddBlipForCoord(Config.Blip.Coords.x, Config.Blip.Coords.y, Config.Blip.Coords.z)
    
    SetBlipSprite(blip, Config.Blip.Sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blip.Scale)
    SetBlipColour(blip, Config.Blip.Color)
    SetBlipAsShortRange(blip, true)
    
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Blip.Name)
    EndTextCommandSetBlipName(blip)
    
    print('TEST: Blip erstellt bei ' .. Config.Blip.Coords)
    print('Öffne Map und checke!')
end)