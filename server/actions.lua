-- server/actions.lua - NUTZT DEINE BRIDGE!

-- Kuh-Daten abrufen
lib.callback.register('hm_dairy:server:getCowData', function(source, cowId)
    local cow = GetCowData(cowId)
    
    local milkReady, milkRemaining = CheckCooldown(cowId, 'milked')
    local feedReady, feedRemaining = CheckCooldown(cowId, 'fed')
    local brushReady, brushRemaining = CheckCooldown(cowId, 'brushed')
    local petReady, petRemaining = CheckCooldown(cowId, 'petted')
    local vetReady, vetRemaining = CheckCooldown(cowId, 'vet_check')
    
    local tier = nil
    for _, t in ipairs(Config.Production.Tiers) do
        if cow.production >= t.min and cow.production <= t.max then
            tier = t
            break
        end
    end
    
    return {
        id = cowId,
        production = cow.production,
        total_milk = cow.total_milk,
        times_milked = cow.times_milked,
        tier = tier,
        cooldowns = {
            milk = { ready = milkReady, remaining = milkRemaining },
            feed = { ready = feedReady, remaining = feedRemaining },
            brush = { ready = brushReady, remaining = brushRemaining },
            pet = { ready = petReady, remaining = petRemaining },
            vet = { ready = vetReady, remaining = vetRemaining }
        }
    }
end)

-- Alle Kühe abrufen
lib.callback.register('hm_dairy:server:getAllCows', function(source)
    local allCows = {}
    for _, spawn in ipairs(Config.CowSpawns.Locations) do
        local cow = GetCowData(spawn.id)
        
        local milkReady, milkRemaining = CheckCooldown(spawn.id, 'milked')
        local feedReady, feedRemaining = CheckCooldown(spawn.id, 'fed')
        local brushReady, brushRemaining = CheckCooldown(spawn.id, 'brushed')
        local petReady, petRemaining = CheckCooldown(spawn.id, 'petted')
        local vetReady, vetRemaining = CheckCooldown(spawn.id, 'vet_check')
        
        local tier = nil
        for _, t in ipairs(Config.Production.Tiers) do
            if cow.production >= t.min and cow.production <= t.max then
                tier = t
                break
            end
        end
        
        table.insert(allCows, {
            id = spawn.id,
            production = cow.production,
            total_milk = cow.total_milk,
            times_milked = cow.times_milked,
            tier = tier,
            cooldowns = {
                milk = { ready = milkReady, remaining = milkRemaining },
                feed = { ready = feedReady, remaining = feedRemaining },
                brush = { ready = brushReady, remaining = brushRemaining },
                pet = { ready = petReady, remaining = petRemaining },
                vet = { ready = vetReady, remaining = vetRemaining }
            }
        })
    end
    return allCows
end)

-- MELKEN
lib.callback.register('hm_dairy:server:milkCow', function(source, cowId)
    if Config.Milking.RequireItems then
        if not Inventory.HasItem(source, Config.Milking.RequiredItems.bucket) then
            Framework.Notify('Melkeimer fehlt!', 'error')
            return false
        end
        if not Inventory.HasItem(source, Config.Milking.RequiredItems.stool) then
            Framework.Notify('Melkschemel fehlt!', 'error')
            return false
        end
    end
    
    local success, result, amount = PerformAction(cowId, 'milked')
    
    if not success then
        if result == 'cooldown' then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Dairy Farm',
                description = Config.Notifications.Error.cooldown:format(amount..' Minuten'),
                type = 'error'
            })
        end
        return false
    end
    
    Inventory.AddItem(source, Config.Milking.Output.item, amount)
    
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Dairy Farm',
        description = Config.Notifications.Success.milked:format(amount),
        type = 'success'
    })
    
    return true, amount
end)

-- FÜTTERN
lib.callback.register('hm_dairy:server:feedCow', function(source, cowId, feedItem)
    if not Inventory.HasItem(source, feedItem) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Dairy Farm',
            description = Config.Notifications.Error.no_item:format(feedItem),
            type = 'error'
        })
        return false
    end
    
    local success, result, gain, oldProd, newProd = PerformAction(cowId, 'fed', feedItem)
    
    if not success then
        if result == 'cooldown' then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Dairy Farm',
                description = Config.Notifications.Error.cooldown:format(gain..' Minuten'),
                type = 'error'
            })
        end
        return false
    end
    
    Inventory.RemoveItem(source, feedItem, 1)
    
    if newProd >= 100 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Dairy Farm',
            description = Config.Notifications.Error.max_production,
            type = 'info'
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Dairy Farm',
            description = Config.Notifications.Success.fed:format(gain),
            type = 'success'
        })
    end
    
    return true, gain, oldProd, newProd
end)

-- BÜRSTEN
lib.callback.register('hm_dairy:server:brushCow', function(source, cowId)
    if Config.Care.Brush.RequiredItem then
        if not Inventory.HasItem(source, Config.Care.Brush.RequiredItem) then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Dairy Farm',
                description = Config.Notifications.Error.no_item:format(Config.Care.Brush.RequiredItem),
                type = 'error'
            })
            return false
        end
    end
    
    local success, result, gain, oldProd, newProd = PerformAction(cowId, 'brushed')
    
    if not success then
        if result == 'cooldown' then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Dairy Farm',
                description = Config.Notifications.Error.cooldown:format(gain..' Minuten'),
                type = 'error'
            })
        end
        return false
    end
    
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Dairy Farm',
        description = newProd >= 100 and Config.Notifications.Error.max_production or Config.Notifications.Success.brushed:format(gain),
        type = newProd >= 100 and 'info' or 'success'
    })
    
    return true, gain, oldProd, newProd
end)

-- STREICHELN
lib.callback.register('hm_dairy:server:petCow', function(source, cowId)
    local success, result, gain, oldProd, newProd = PerformAction(cowId, 'petted')
    
    if not success then
        if result == 'cooldown' then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Dairy Farm',
                description = Config.Notifications.Error.cooldown:format(gain..' Minuten'),
                type = 'error'
            })
        end
        return false
    end
    
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Dairy Farm',
        description = newProd >= 100 and Config.Notifications.Error.max_production or Config.Notifications.Success.petted:format(gain),
        type = newProd >= 100 and 'info' or 'success'
    })
    
    return true, gain, oldProd, newProd
end)

-- TIERARZT
lib.callback.register('hm_dairy:server:vetCheck', function(source, cowId)
    if Config.Care.VetCheck.RequiredItem then
        if not Inventory.HasItem(source, Config.Care.VetCheck.RequiredItem) then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Dairy Farm',
                description = Config.Notifications.Error.no_item:format(Config.Care.VetCheck.RequiredItem),
                type = 'error'
            })
            return false
        end
    end
    
    local success, result, gain, oldProd, newProd = PerformAction(cowId, 'vet_check')
    
    if not success then
        if result == 'cooldown' then
            local hours = math.floor(gain / 60)
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Dairy Farm',
                description = Config.Notifications.Error.cooldown:format(hours..' Stunden'),
                type = 'error'
            })
        end
        return false
    end
    
    if Config.Care.VetCheck.RequiredItem then
        Inventory.RemoveItem(source, Config.Care.VetCheck.RequiredItem, 1)
    end
    
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Dairy Farm',
        description = newProd >= 100 and Config.Notifications.Error.max_production or Config.Notifications.Success.vetcheck:format(gain),
        type = newProd >= 100 and 'info' or 'success'
    })
    
    return true, gain, oldProd, newProd
end)
