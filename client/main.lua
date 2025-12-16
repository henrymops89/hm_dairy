-- ═══════════════════════════════════════════════════════════════
-- HM DAIRY SYSTEM - CLIENT (SUPER SIMPLE VERSION)
-- ═══════════════════════════════════════════════════════════════

local spawnedCows = {}
local isPlayerLoaded = false

-- ═══════════════════════════════════════════════════════════════
-- COW SPAWNING SYSTEM
-- ═══════════════════════════════════════════════════════════════

local function SpawnCow(index, location)
    if spawnedCows[index] then return end
    
    lib.requestModel(Config.CowSpawns.Model, 10000)
    
    local coords = location.coords.xyz
    local heading = location.coords.w
    
    local cow = CreatePed(28, GetHashKey(Config.CowSpawns.Model), coords.x, coords.y, coords.z, heading, false, true)
    
    SetEntityAsMissionEntity(cow, true, true)
    SetPedFleeAttributes(cow, 0, false)
    SetPedCombatAttributes(cow, 17, true)
    SetBlockingOfNonTemporaryEvents(cow, true)
    SetPedCanRagdollFromPlayerImpact(cow, false)
    SetPedCanRagdoll(cow, false)
    
    if location.scenario then
        TaskStartScenarioInPlace(cow, location.scenario, 0, true)
    end
    
    FreezeEntityPosition(cow, true)
    
    spawnedCows[index] = {
        entity = cow,
        index = index,
        coords = coords
    }
    
    exports.ox_target:addLocalEntity(cow, {
        {
            name = 'hm_dairy_milk_cow_' .. index,
            icon = Config.Target.Icon,
            label = Config.Target.Label,
            distance = Config.Target.Distance,
            onSelect = function(data)
                MilkCow(index)
            end
        }
    })
    
    if Config.Debug then
        print('^2[HM Dairy] Spawned cow #' .. index .. ' at ' .. coords .. '^0')
    end
end

local function DeleteCow(index)
    if not spawnedCows[index] then return end
    
    local cow = spawnedCows[index].entity
    
    if DoesEntityExist(cow) then
        exports.ox_target:removeLocalEntity(cow, 'hm_dairy_milk_cow_' .. index)
        DeleteEntity(cow)
    end
    
    if Config.Debug then
        print('^3[HM Dairy] Deleted cow #' .. index .. '^0')
    end
    
    spawnedCows[index] = nil
end

local function ManageCowSpawns()
    if not Config.CowSpawns.Enabled or not isPlayerLoaded then return end
    
    local playerCoords = GetEntityCoords(cache.ped)
    
    for index, location in ipairs(Config.CowSpawns.Locations) do
        local coords = location.coords.xyz
        local distance = #(playerCoords - coords)
        
        if distance < Config.CowSpawns.SpawnDistance then
            if not spawnedCows[index] then
                SpawnCow(index, location)
            end
        elseif distance > Config.CowSpawns.DeleteDistance then
            if spawnedCows[index] then
                DeleteCow(index)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- MILKING FUNCTION (SUPER SIMPLE - NO BULLSHIT!)
-- ═══════════════════════════════════════════════════════════════

function MilkCow(cowIndex)
    if Config.Debug then
        print('^3[HM Dairy] === SUPER SIMPLE VERSION ===^0')
        print('^3[HM Dairy] Kuh #' .. cowIndex .. ' angeklickt^0')
    end
    
    -- Server check
    lib.callback('hm_dairy:server:canMilkCow', false, function(canMilk, reason, data)
        if not canMilk then
            local message = Config.Notifications.Error[reason]
            if reason == 'cooldown' then
                message = message:format(data)
            end
            Framework.Notify(message, 'error')
            return
        end
        
        -- EINFACH NUR PROGRESS BAR - NICHTS SONST!
        if Config.Debug then
            print('^3[HM Dairy] Starte Progress Bar...^0')
        end
        
        -- Animation starten (falls konfiguriert)
        local ped = cache.ped
        if Config.Milking.Animation.dict and Config.Milking.Animation.dict ~= '' then
            lib.requestAnimDict(Config.Milking.Animation.dict, 3000)
            TaskPlayAnim(ped, Config.Milking.Animation.dict, Config.Milking.Animation.clip, 8.0, -8.0, -1, 1, 0, false, false, false)
            
            if Config.Debug then
                print('^2[HM Dairy] Animation gestartet: ' .. Config.Milking.Animation.dict .. '^0')
            end
        end
        
        local success = lib.progressBar({
            duration = Config.Milking.Duration,
            label = Config.Notifications.Info.milking,
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                combat = true
            }
        })
        
        -- Animation stoppen
        ClearPedTasks(ped)
        
        if Config.Debug then
            print('^3[HM Dairy] Progress Bar result: ' .. tostring(success) .. '^0')
        end
        
        if success then
            TriggerServerEvent('hm_dairy:server:processMilking', cowIndex)
        else
            Framework.Notify(Config.Notifications.Error.cancelled, 'error')
        end
    end, cowIndex)
end

-- ═══════════════════════════════════════════════════════════════
-- SPAWN MANAGEMENT THREAD
-- ═══════════════════════════════════════════════════════════════

CreateThread(function()
    while true do
        ManageCowSpawns()
        Wait(1000)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- PLAYER LOAD/UNLOAD
-- ═══════════════════════════════════════════════════════════════

local farmBlip = nil

-- Create farm blip
local function CreateFarmBlip()
    if not Config.Blip.Enabled then return end
    
    farmBlip = AddBlipForCoord(Config.Blip.Coords.x, Config.Blip.Coords.y, Config.Blip.Coords.z)
    SetBlipSprite(farmBlip, Config.Blip.Sprite)
    SetBlipDisplay(farmBlip, 4)
    SetBlipScale(farmBlip, Config.Blip.Scale)
    SetBlipColour(farmBlip, Config.Blip.Color)
    SetBlipAsShortRange(farmBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.Name)
    EndTextCommandSetBlipName(farmBlip)
    
    if Config.Debug then
        print('^2[HM Dairy] Farm blip created^0')
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(1000)
        isPlayerLoaded = true
        CreateFarmBlip()
        
        if Config.Debug then
            print('^2[HM Dairy] Resource started - Player loaded^0')
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for index, _ in pairs(spawnedCows) do
            DeleteCow(index)
        end
        
        if farmBlip then
            RemoveBlip(farmBlip)
        end
        
        if Config.Debug then
            print('^3[HM Dairy] Resource stopped - Cleaned up cows^0')
        end
    end
end)

-- Framework-specific player load events
if Config.Framework == 'qbox' or Config.Framework == 'qbcore' then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        isPlayerLoaded = true
        CreateFarmBlip()
        if Config.Debug then
            print('^2[HM Dairy] Player loaded (QBCore/QBox)^0')
        end
    end)
    
    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        isPlayerLoaded = false
        for index, _ in pairs(spawnedCows) do
            DeleteCow(index)
        end
        if farmBlip then
            RemoveBlip(farmBlip)
            farmBlip = nil
        end
        if Config.Debug then
            print('^3[HM Dairy] Player unloaded - Cleaned up cows^0')
        end
    end)
    
elseif Config.Framework == 'esx' then
    RegisterNetEvent('esx:playerLoaded', function()
        isPlayerLoaded = true
        CreateFarmBlip()
        if Config.Debug then
            print('^2[HM Dairy] Player loaded (ESX)^0')
        end
    end)
    
    RegisterNetEvent('esx:onPlayerLogout', function()
        isPlayerLoaded = false
        for index, _ in pairs(spawnedCows) do
            DeleteCow(index)
        end
        if farmBlip then
            RemoveBlip(farmBlip)
            farmBlip = nil
        end
        if Config.Debug then
            print('^3[HM Dairy] Player unloaded - Cleaned up cows^0')
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- DEBUG COMMANDS
-- ═══════════════════════════════════════════════════════════════

if Config.Debug then
    RegisterCommand('dairy_spawncows', function()
        for index, location in ipairs(Config.CowSpawns.Locations) do
            SpawnCow(index, location)
        end
        print('^2[HM Dairy] Spawned all cows^0')
    end, false)
    
    RegisterCommand('dairy_deletecows', function()
        for index, _ in pairs(spawnedCows) do
            DeleteCow(index)
        end
        print('^3[HM Dairy] Deleted all cows^0')
    end, false)
    
    RegisterCommand('dairy_listcows', function()
        local count = 0
        for _ in pairs(spawnedCows) do count = count + 1 end
        print('^3[HM Dairy] Spawned cows: ' .. count .. '^0')
        for index, data in pairs(spawnedCows) do
            print('^3  - Cow #' .. index .. ' (Index: ' .. data.index .. ') at ' .. data.coords .. '^0')
        end
    end, false)
end