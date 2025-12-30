-- client/main.lua
-- HM Dairy UI - Mit Single-Cow Support & Multi-Actions (V5.0)

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
    DebugPrint('Starte Melken für Kuh ' .. cowId)
    
    -- UI schließen
    CloseDairyUI()
    
    -- Checke ob Kuh noch existiert und in Reichweite ist
    if not currentCowEntity or not DoesEntityExist(currentCowEntity) then
        Framework.Notify('Kuh nicht gefunden!', 'error')
        return
    end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    local cowCoords = GetEntityCoords(currentCowEntity)
    local distance = #(playerCoords - cowCoords)
    
    if distance > Config.UI.MaxDistance then
        Framework.Notify('Du bist zu weit von der Kuh entfernt!', 'error')
        return
    end
    
    -- Progress Bar starten
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
        lib.callback('hm_dairy:server:milkCow', false, function(success, amount)
            if success then
                DebugPrint('Kuh ' .. cowId .. ' erfolgreich gemolken: +' .. amount .. ' Milch')
            end
        end, cowId)
    else
        -- Abgebrochen
        DebugPrint('Melken abgebrochen')
        Framework.Notify('Melken abgebrochen!', 'error')
    end
    
    -- Reset
    currentCowEntity = nil
end)

-- ============================================
-- OX_TARGET INTEGRATION
-- ============================================

if Config.Target.Enabled then
    CreateThread(function()
        local options = {}
        
        -- MELKEN
        if Config.Target.Options.milk then
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
                    
                    -- Finde Kuh-ID
                    local cowId = exports.hm_dairy:GetCowIdFromEntity(entity)
                    
                    if not cowId then
                        DebugPrint('Kuh-ID nicht gefunden!')
                        Framework.Notify('Diese Kuh ist nicht registriert!', 'error')
                        return
                    end
                    
                    DebugPrint('ox_target: Öffne UI für Kuh ' .. cowId)
                    
                    -- Speichere aktuelle Kuh-Entity
                    currentCowEntity = entity
                    
                    -- Server fragen nach Daten für DIESE Kuh
                    lib.callback('hm_dairy:server:getCowData', false, function(cowData)
                        if cowData then
                            TriggerEvent('hm_dairy:client:openUI', cowData)
                        end
                    end, cowId)
                end
            })
        end
        
        -- FÜTTERN
        if Config.Care.Feed.Enabled and Config.Target.Options.feed then
            table.insert(options, {
                name = 'hm_dairy_feed',
                label = Config.Target.Options.feed.label,
                icon = Config.Target.Options.feed.icon,
                distance = Config.Target.Distance,
                onSelect = function(data)
                    local cowId = exports.hm_dairy:GetCowIdFromEntity(data.entity)
                    if cowId then
                        TriggerEvent('hm_dairy:client:feedCow', cowId, data.entity)
                    end
                end
            })
        end
        
        -- BÜRSTEN
        if Config.Care.Brush.Enabled and Config.Target.Options.brush then
            table.insert(options, {
                name = 'hm_dairy_brush',
                label = Config.Target.Options.brush.label,
                icon = Config.Target.Options.brush.icon,
                distance = Config.Target.Distance,
                onSelect = function(data)
                    local cowId = exports.hm_dairy:GetCowIdFromEntity(data.entity)
                    if cowId then
                        TriggerEvent('hm_dairy:client:brushCow', cowId, data.entity)
                    end
                end
            })
        end
        
        -- STREICHELN
        if Config.Care.Pet.Enabled and Config.Target.Options.pet then
            table.insert(options, {
                name = 'hm_dairy_pet',
                label = Config.Target.Options.pet.label,
                icon = Config.Target.Options.pet.icon,
                distance = Config.Target.Distance,
                onSelect = function(data)
                    local cowId = exports.hm_dairy:GetCowIdFromEntity(data.entity)
                    if cowId then
                        TriggerEvent('hm_dairy:client:petCow', cowId, data.entity)
                    end
                end
            })
        end
        
        -- TIERARZT
        if Config.Care.VetCheck.Enabled and Config.Target.Options.vet then
            table.insert(options, {
                name = 'hm_dairy_vet',
                label = Config.Target.Options.vet.label,
                icon = Config.Target.Options.vet.icon,
                distance = Config.Target.Distance,
                onSelect = function(data)
                    local cowId = exports.hm_dairy:GetCowIdFromEntity(data.entity)
                    if cowId then
                        TriggerEvent('hm_dairy:client:vetCheck', cowId, data.entity)
                    end
                end
            })
        end
        
        -- Registriere alle Optionen
        exports.ox_target:addModel(Config.CowSpawns.Model, options)
        
        DebugPrint('ox_target mit ' .. #options .. ' Optionen registriert')
    end)
end

-- ============================================
-- COMMANDS (für Testing)
-- ============================================

-- Command: UI direkt öffnen (alle Kühe) - Nur für Testing!
if DEBUG then
    RegisterCommand('dairyui', function()
        DebugPrint('Command /dairyui ausgeführt (Test-Modus)')
        lib.callback('hm_dairy:server:getAllCows', false, function(cows)
            if cows and #cows > 0 then
                OpenDairyUI(cows)
            else
                DebugPrint('Keine Kühe gefunden!')
            end
        end)
    end, false)
end

DebugPrint('Client geladen - Gehe zu einer Kuh und drücke E')
DebugPrint('Setze Config.Debug = false wenn alles funktioniert')
