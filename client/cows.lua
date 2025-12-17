-- client/cows.lua
-- Kuh-Spawning System

local spawnedCows = {}
local DEBUG = Config.Debug

local function DebugPrint(msg)
    if DEBUG then
        print('[HM Dairy Cows] ' .. msg)
    end
end

-- Kuh spawnen
local function SpawnCow(location, index)
    local model = GetHashKey(Config.CowSpawns.Model)
    
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 5000 do
        Wait(100)
        timeout = timeout + 100
    end
    
    if not HasModelLoaded(model) then
        DebugPrint('Fehler beim Laden des Kuh-Models!')
        return nil
    end
    
    local coords = location.coords
    local cow = CreatePed(28, model, coords.x, coords.y, coords.z, coords.w, false, false)
    
    if DoesEntityExist(cow) then
        SetEntityAsMissionEntity(cow, true, true)
        SetPedFleeAttributes(cow, 0, false)
        SetPedCombatAttributes(cow, 17, true)
        SetBlockingOfNonTemporaryEvents(cow, true)
        
        -- Scenario starten
        if location.scenario then
            TaskStartScenarioInPlace(cow, location.scenario, 0, true)
        end
        
        -- Invincible machen (optional)
        SetEntityInvincible(cow, true)
        
        DebugPrint('Kuh #' .. index .. ' gespawnt bei ' .. coords)
        
        return cow
    else
        DebugPrint('Fehler beim Spawnen von Kuh #' .. index)
        return nil
    end
end

-- Kühe in der Nähe spawnen
local function SpawnNearbyCows()
    if not Config.CowSpawns.Enabled then return end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    for index, location in ipairs(Config.CowSpawns.Locations) do
        local coords = location.coords
        local distance = #(playerCoords - vector3(coords.x, coords.y, coords.z))
        
        -- Spawnen wenn in Reichweite und noch nicht gespawnt
        if distance < Config.CowSpawns.SpawnDistance and not spawnedCows[index] then
            local cow = SpawnCow(location, index)
            if cow then
                spawnedCows[index] = {
                    entity = cow,
                    coords = coords
                }
            end
        end
        
        -- Löschen wenn zu weit weg
        if distance > Config.CowSpawns.DeleteDistance and spawnedCows[index] then
            if DoesEntityExist(spawnedCows[index].entity) then
                DeleteEntity(spawnedCows[index].entity)
                DebugPrint('Kuh #' .. index .. ' gelöscht (zu weit weg)')
            end
            spawnedCows[index] = nil
        end
    end
end

-- Haupt-Thread: Kühe spawnen/despawnen
CreateThread(function()
    -- Warte bis Spieler richtig geladen ist
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(1000)
    end
    
    Wait(5000) -- Extra Wartezeit
    
    DebugPrint('Kuh-Spawning System gestartet')
    
    while true do
        if Config.CowSpawns.Enabled then
            SpawnNearbyCows()
            Wait(5000) -- Alle 5 Sekunden checken
        else
            Wait(30000) -- Wenn disabled, seltener checken
        end
    end
end)

-- Cleanup beim Resource-Stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    DebugPrint('Lösche alle gespawnten Kühe...')
    
    for index, cowData in pairs(spawnedCows) do
        if DoesEntityExist(cowData.entity) then
            DeleteEntity(cowData.entity)
        end
    end
    
    spawnedCows = {}
end)

-- Export: Alle gespawnten Kühe
function GetSpawnedCows()
    return spawnedCows
end

-- Export: Kuh-Index von Entity finden
function GetCowIndexFromEntity(entity)
    for index, cowData in pairs(spawnedCows) do
        if cowData.entity == entity then
            return index
        end
    end
    return nil
end

-- Exports
exports('GetSpawnedCows', GetSpawnedCows)
exports('GetCowIndexFromEntity', GetCowIndexFromEntity)

DebugPrint('Kuh-Spawning System geladen')