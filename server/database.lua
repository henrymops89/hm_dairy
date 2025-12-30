-- server/database.lua - NUTZT DEINE BRIDGE!
-- Kürzere Version - Vollständige Version in separater Datei

local MySQL = nil
local cows_cache = {}

if Config.Database.Enabled then
    MySQL = Config.Database.Resource == 'oxmysql' and exports.oxmysql or nil
    if MySQL then print('^2[HM Dairy] MySQL verbunden^0') end
end

local function GetTimestamp() return os.time() * 1000 end

function InitializeCow(cowId)
    if cows_cache[cowId] then return cows_cache[cowId] end
    
    local newCow = {
        cow_id = cowId,
        production = Config.Production.StartLevel,
        total_milk = 0,
        last_milked = nil, last_fed = nil, last_brushed = nil,
        last_petted = nil, last_vet_check = nil,
        times_milked = 0, times_fed = 0, times_brushed = 0, times_petted = 0
    }
    
    if Config.Database.Enabled and MySQL then
        local result = MySQL:query_async('SELECT * FROM hm_dairy_cows WHERE cow_id = ?', {cowId})
        if result and #result > 0 then
            newCow = result[1]
        else
            MySQL:insert_async('INSERT INTO hm_dairy_cows (cow_id, production) VALUES (?, ?)', {cowId, Config.Production.StartLevel})
        end
    end
    
    cows_cache[cowId] = newCow
    return newCow
end

function GetCowData(cowId)
    return cows_cache[cowId] or InitializeCow(cowId)
end

function UpdateCowData(cowId, data)
    if not cows_cache[cowId] then cows_cache[cowId] = {} end
    for k,v in pairs(data) do cows_cache[cowId][k] = v end
    
    if Config.Database.Enabled and MySQL then
        local fields, values = {}, {}
        for k,v in pairs(data) do
            table.insert(fields, k..' = ?')
            table.insert(values, v)
        end
        table.insert(values, cowId)
        MySQL:execute_async('UPDATE hm_dairy_cows SET '..table.concat(fields,', ')..' WHERE cow_id = ?', values)
    end
    return cows_cache[cowId]
end

function ChangeProduction(cowId, amount)
    local cow = GetCowData(cowId)
    local old = cow.production
    local new = math.max(1, math.min(100, old + amount))
    if new ~= old then
        UpdateCowData(cowId, {production = new})
        return true, old, new
    end
    return false, old, old
end

function CheckCooldown(cowId, actionType)
    local cow = GetCowData(cowId)
    local lastTime = cow['last_'..actionType]
    if not lastTime then return true, 0 end
    
    local cooldownMins = ({
        milked = Config.Milking.Cooldown,
        fed = Config.Care.Feed.Cooldown,
        brushed = Config.Care.Brush.Cooldown,
        petted = Config.Care.Pet.Cooldown,
        vet_check = Config.Care.VetCheck.Cooldown
    })[actionType] or 15
    
    local elapsed = (GetTimestamp() - lastTime) / 60000
    if elapsed >= cooldownMins then return true, 0 end
    return false, math.ceil(cooldownMins - elapsed)
end

function PerformAction(cowId, actionType, itemUsed)
    local canDo, remaining = CheckCooldown(cowId, actionType)
    if not canDo then return false, 'cooldown', remaining end
    
    local cow = GetCowData(cowId)
    local data = {['last_'..actionType] = GetTimestamp()}
    local gain = 0
    
    if actionType == 'milked' then
        data.times_milked = cow.times_milked + 1
        local multiplier = 1.0
        for _,tier in ipairs(Config.Production.Tiers) do
            if cow.production >= tier.min and cow.production <= tier.max then
                multiplier = tier.multiplier break
            end
        end
        local amount = math.floor(1 + (cow.production * 0.04 * multiplier))
        data.total_milk = cow.total_milk + amount
        UpdateCowData(cowId, data)
        return true, 'success', amount
        
    elseif actionType == 'fed' then
        data.times_fed = cow.times_fed + 1
        for _,food in ipairs(Config.Care.Feed.Items) do
            if food.item == itemUsed then gain = food.gain break end
        end
        
    elseif actionType == 'brushed' then
        data.times_brushed = cow.times_brushed + 1
        gain = Config.Care.Brush.ProductionGain
        
    elseif actionType == 'petted' then
        data.times_petted = cow.times_petted + 1
        gain = Config.Care.Pet.ProductionGain
        
    elseif actionType == 'vet_check' then
        gain = Config.Care.VetCheck.ProductionGain
    end
    
    UpdateCowData(cowId, data)
    if gain > 0 then
        local _,old,new = ChangeProduction(cowId, gain)
        return true, 'success', gain, old, new
    end
    return true, 'success', 0
end

CreateThread(function()
    Wait(2000)
    for _,spawn in ipairs(Config.CowSpawns.Locations) do InitializeCow(spawn.id) end
end)
