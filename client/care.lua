-- client/care.lua
-- Pflege-Aktionen für Kühe (V5.0)

local isBusy = false

local function DebugPrint(msg)
    if Config.Debug then
        print('[HM Dairy Care] ' .. msg)
    end
end

local function CheckDistance(entity, maxDist)
    if not entity or not DoesEntityExist(entity) then
        return false
    end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    local entityCoords = GetEntityCoords(entity)
    local distance = #(playerCoords - entityCoords)
    
    return distance <= maxDist
end

-- ============================================
-- FÜTTERN
-- ============================================

RegisterNetEvent('hm_dairy:client:feedCow', function(cowId, entity)
    if isBusy then
        Framework.Notify(Config.Notifications.Error.already_busy, 'error')
        return
    end
    
    -- Distanz-Check
    if not CheckDistance(entity, Config.Target.Distance) then
        Framework.Notify(Config.Notifications.Error.too_far, 'error')
        return
    end
    
    -- Item-Auswahl
    local input = lib.inputDialog('Kuh füttern', {
        {
            type = 'select',
            label = 'Futter wählen',
            options = (function()
                local opts = {}
                for _, food in ipairs(Config.Care.Feed.Items) do
                    table.insert(opts, {
                        value = food.item,
                        label = food.label .. ' (+' .. food.gain .. '%)'
                    })
                end
                return opts
            end)(),
            required = true
        }
    })
    
    if not input then return end
    
    local feedItem = input[1]
    
    isBusy = true
    
    -- Progress Bar
    local success = lib.progressCircle({
        duration = Config.Care.Feed.Duration,
        label = 'Kuh füttern...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = Config.Care.Feed.Animation.dict,
            clip = Config.Care.Feed.Animation.clip
        }
    })
    
    if success then
        lib.callback('hm_dairy:server:feedCow', false, function(result, gain, oldProd, newProd)
            if result then
                DebugPrint('Kuh ' .. cowId .. ' gefüttert: ' .. oldProd .. '% → ' .. newProd .. '%')
            end
        end, cowId, feedItem)
    end
    
    ClearPedTasks(PlayerPedId())
    isBusy = false
end)

-- ============================================
-- BÜRSTEN
-- ============================================

RegisterNetEvent('hm_dairy:client:brushCow', function(cowId, entity)
    if isBusy then
        Framework.Notify(Config.Notifications.Error.already_busy, 'error')
        return
    end
    
    if not CheckDistance(entity, Config.Target.Distance) then
        Framework.Notify(Config.Notifications.Error.too_far, 'error')
        return
    end
    
    isBusy = true
    
    local success = lib.progressCircle({
        duration = Config.Care.Brush.Duration,
        label = 'Kuh bürsten...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = Config.Care.Brush.Animation.dict,
            clip = Config.Care.Brush.Animation.clip
        }
    })
    
    if success then
        lib.callback('hm_dairy:server:brushCow', false, function(result, gain, oldProd, newProd)
            if result then
                DebugPrint('Kuh ' .. cowId .. ' gebürstet: ' .. oldProd .. '% → ' .. newProd .. '%')
            end
        end, cowId)
    end
    
    ClearPedTasks(PlayerPedId())
    isBusy = false
end)

-- ============================================
-- STREICHELN
-- ============================================

RegisterNetEvent('hm_dairy:client:petCow', function(cowId, entity)
    if isBusy then
        Framework.Notify(Config.Notifications.Error.already_busy, 'error')
        return
    end
    
    if not CheckDistance(entity, Config.Target.Distance) then
        Framework.Notify(Config.Notifications.Error.too_far, 'error')
        return
    end
    
    isBusy = true
    
    local success = lib.progressCircle({
        duration = Config.Care.Pet.Duration,
        label = 'Kuh streicheln...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = true,
            combat = true
        },
        anim = {
            dict = Config.Care.Pet.Animation.dict,
            clip = Config.Care.Pet.Animation.clip
        }
    })
    
    if success then
        lib.callback('hm_dairy:server:petCow', false, function(result, gain, oldProd, newProd)
            if result then
                DebugPrint('Kuh ' .. cowId .. ' gestreichelt: ' .. oldProd .. '% → ' .. newProd .. '%')
            end
        end, cowId)
    end
    
    ClearPedTasks(PlayerPedId())
    isBusy = false
end)

-- ============================================
-- TIERARZT-CHECK
-- ============================================

RegisterNetEvent('hm_dairy:client:vetCheck', function(cowId, entity)
    if isBusy then
        Framework.Notify(Config.Notifications.Error.already_busy, 'error')
        return
    end
    
    if not CheckDistance(entity, Config.Target.Distance) then
        Framework.Notify(Config.Notifications.Error.too_far, 'error')
        return
    end
    
    isBusy = true
    
    local success = lib.progressCircle({
        duration = Config.Care.VetCheck.Duration,
        label = 'Tierarzt-Check durchführen...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = Config.Care.VetCheck.Animation.dict,
            clip = Config.Care.VetCheck.Animation.clip
        }
    })
    
    if success then
        lib.callback('hm_dairy:server:vetCheck', false, function(result, gain, oldProd, newProd)
            if result then
                DebugPrint('Kuh ' .. cowId .. ' Tierarzt-Check: ' .. oldProd .. '% → ' .. newProd .. '%')
            end
        end, cowId)
    end
    
    ClearPedTasks(PlayerPedId())
    isBusy = false
end)

DebugPrint('Pflege-Aktionen geladen')
