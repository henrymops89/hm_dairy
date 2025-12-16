Framework = {}

-- Auto-detect framework if set to 'auto'
if Config.Framework == 'auto' then
    if GetResourceState('qbx_core') == 'started' then
        Config.Framework = 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        Config.Framework = 'qbcore'
    elseif GetResourceState('es_extended') == 'started' then
        Config.Framework = 'esx'
    else
        print('^1[HM Dairy] ERROR: No supported framework detected!^0')
    end
end

if Config.Debug then
    print('^2[HM Dairy] Framework detected: ' .. Config.Framework .. '^0')
end

-- ═══════════════════════════════════════════════════════════════
-- QBOX FRAMEWORK
-- ═══════════════════════════════════════════════════════════════
if Config.Framework == 'qbox' then
    if IsDuplicityVersion() then -- Server
        Framework.GetPlayer = function(source)
            return exports.qbx_core:GetPlayer(source)
        end
        
        Framework.GetPlayerIdentifier = function(source)
            local player = Framework.GetPlayer(source)
            return player and player.PlayerData.citizenid or nil
        end
    else -- Client
        Framework.GetPlayerData = function()
            return exports.qbx_core:GetPlayerData()
        end
    end

-- ═══════════════════════════════════════════════════════════════
-- QBCORE FRAMEWORK
-- ═══════════════════════════════════════════════════════════════
elseif Config.Framework == 'qbcore' then
    local QBCore = exports['qb-core']:GetCoreObject()
    
    if IsDuplicityVersion() then -- Server
        Framework.GetPlayer = function(source)
            return QBCore.Functions.GetPlayer(source)
        end
        
        Framework.GetPlayerIdentifier = function(source)
            local player = Framework.GetPlayer(source)
            return player and player.PlayerData.citizenid or nil
        end
    else -- Client
        Framework.GetPlayerData = function()
            return QBCore.Functions.GetPlayerData()
        end
    end

-- ═══════════════════════════════════════════════════════════════
-- ESX FRAMEWORK
-- ═══════════════════════════════════════════════════════════════
elseif Config.Framework == 'esx' then
    local ESX = exports['es_extended']:getSharedObject()
    
    if IsDuplicityVersion() then -- Server
        Framework.GetPlayer = function(source)
            return ESX.GetPlayerFromId(source)
        end
        
        Framework.GetPlayerIdentifier = function(source)
            local player = Framework.GetPlayer(source)
            return player and player.identifier or nil
        end
    else -- Client
        Framework.GetPlayerData = function()
            return ESX.GetPlayerData()
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

if not IsDuplicityVersion() then -- Client only
    function Framework.Notify(message, type, duration)
        lib.notify({
            title = 'Dairy Farm',
            description = message,
            type = type or 'info',
            duration = duration or 5000,
            position = 'top'
        })
    end
end