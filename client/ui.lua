-- client/ui.lua
-- UI Management für HM Dairy

local uiOpen = false
local currentCows = {}
local DEBUG = true -- Setze auf false für Production

local function DebugPrint(msg)
    if DEBUG then
        print('[HM Dairy UI] ' .. msg)
    end
end

-- UI öffnen
function OpenDairyUI(cows)
    if uiOpen then 
        DebugPrint('UI ist bereits offen!')
        return 
    end
    
    DebugPrint('Öffne UI mit ' .. #cows .. ' Kühen')
    uiOpen = true
    currentCows = cows
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openUI',
        cows = cows
    })
end

-- UI schließen
function CloseDairyUI()
    if not uiOpen then 
        DebugPrint('UI ist bereits geschlossen!')
        return 
    end
    
    DebugPrint('Schließe UI')
    uiOpen = false
    
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeUI'
    })
    
    -- Stelle sicher dass alle Controls wieder aktiviert sind
    EnableAllControlActions(0)
end

-- Kühe aktualisieren
function UpdateDairyCows(cows)
    currentCows = cows
    if uiOpen then
        DebugPrint('Aktualisiere ' .. #cows .. ' Kühe')
        SendNUIMessage({
            action = 'updateCows',
            cows = cows
        })
    end
end

-- Notification anzeigen
function ShowDairyNotification(message)
    DebugPrint('Notification: ' .. message)
    SendNUIMessage({
        action = 'showNotification',
        message = message
    })
end

-- NUI Callbacks
RegisterNUICallback('startMilking', function(data, cb)
    local cowId = data.cowId
    DebugPrint('NUI Callback: startMilking für Kuh #' .. tostring(cowId))
    
    if cowId then
        -- Trigger das Melk-Event
        TriggerEvent('hm_dairy:client:startMilking', cowId)
    end
    
    cb('ok')
end)

RegisterNUICallback('closeUI', function(data, cb)
    DebugPrint('NUI Callback: closeUI')
    CloseDairyUI()
    cb('ok')
end)

-- ESC Key Handler
CreateThread(function()
    while true do
        if uiOpen then
            Wait(0)
            -- Disable game controls while UI is open
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
            DisableControlAction(0, 140, true) -- MeleeAttackLight
            DisableControlAction(0, 141, true) -- MeleeAttackHeavy
            DisableControlAction(0, 257, true) -- Attack2
            DisableControlAction(0, 263, true) -- MeleeAttack1
            
            -- Check for ESC key (multiple methods)
            if IsDisabledControlJustPressed(0, 322) or IsControlJustPressed(0, 322) then -- ESC
                DebugPrint('ESC gedrückt - Schließe UI')
                CloseDairyUI()
            end
            
            -- Backup: Also check for Backspace
            if IsDisabledControlJustPressed(0, 177) or IsControlJustPressed(0, 177) then -- BACKSPACE
                DebugPrint('BACKSPACE gedrückt - Schließe UI')
                CloseDairyUI()
            end
        else
            Wait(500)
        end
    end
end)

-- Exports
exports('OpenDairyUI', OpenDairyUI)
exports('CloseDairyUI', CloseDairyUI)
exports('UpdateDairyCows', UpdateDairyCows)
exports('ShowDairyNotification', ShowDairyNotification)

-- Notfall-Commands (für Testing/Debug)
if DEBUG then
    RegisterCommand('dairyclose', function()
        print('[HM Dairy UI] === NOTFALL-CLOSE AUSGEFÜHRT ===')
        if uiOpen then
            CloseDairyUI()
        end
        SetNuiFocus(false, false)
        EnableAllControlActions(0)
        print('[HM Dairy UI] Alle Controls freigegeben')
    end, false)
    
    RegisterCommand('dairystatus', function()
        print('=== HM Dairy UI Status ===')
        print('UI Open: ' .. tostring(uiOpen))
        print('Cows Count: ' .. #currentCows)
        print('NUI Focus: ' .. tostring(HasNuiFocus()))
        print('========================')
    end, false)
end