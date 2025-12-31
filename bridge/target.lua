-- bridge/target.lua
-- Universal Target Bridge für HM Dairy
-- Supports: ox_target, qb-target

Target = {}

-- ═══════════════════════════════════════════════════════════════
-- AUTO-DETECT TARGET SYSTEM
-- ═══════════════════════════════════════════════════════════════

local TargetName = nil

if Config.Target.System == 'auto' then
    if GetResourceState('ox_target') == 'started' then
        TargetName = 'ox_target'
        print('^2[HM Dairy Target] Using ox_target^0')
    elseif GetResourceState('qb-target') == 'started' then
        TargetName = 'qb-target'
        print('^2[HM Dairy Target] Using qb-target^0')
    else
        print('^1[HM Dairy Target] ERROR: No supported target system detected!^0')
        TargetName = 'ox_target' -- Fallback
    end
else
    TargetName = Config.Target.System
    print('^2[HM Dairy Target] Using configured system: ' .. TargetName .. '^0')
end

-- ═══════════════════════════════════════════════════════════════
-- ADD TARGET TO MODEL
-- ═══════════════════════════════════════════════════════════════

function Target.AddModel(model, options)
    if TargetName == 'ox_target' then
        -- ox_target format
        local oxOptions = {}
        
        for _, opt in ipairs(options) do
            table.insert(oxOptions, {
                name = opt.name,
                label = opt.label,
                icon = opt.icon,
                distance = opt.distance or Config.Target.Distance,
                onSelect = opt.onSelect
            })
        end
        
        exports.ox_target:addModel(model, oxOptions)
        
    elseif TargetName == 'qb-target' then
        -- qb-target format
        local qbOptions = {}
        
        for _, opt in ipairs(options) do
            table.insert(qbOptions, {
                label = opt.label,
                icon = opt.icon,
                action = opt.onSelect,
                canInteract = function(entity)
                    if opt.canInteract then
                        return opt.canInteract(entity)
                    end
                    return true
                end
            })
        end
        
        exports['qb-target']:AddTargetModel(model, {
            options = qbOptions,
            distance = Config.Target.Distance
        })
    end
end

-- ═══════════════════════════════════════════════════════════════
-- REMOVE TARGET FROM MODEL
-- ═══════════════════════════════════════════════════════════════

function Target.RemoveModel(model, optionNames)
    if TargetName == 'ox_target' then
        exports.ox_target:removeModel(model, optionNames)
        
    elseif TargetName == 'qb-target' then
        exports['qb-target']:RemoveTargetModel(model, optionNames)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- GET TARGET SYSTEM NAME
-- ═══════════════════════════════════════════════════════════════

function Target.GetSystemName()
    return TargetName
end

-- Export
exports('GetTargetSystem', Target.GetSystemName)