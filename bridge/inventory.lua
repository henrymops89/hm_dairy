-- bridge/inventory.lua
-- Universal Inventory Bridge für HM Dairy
-- Supports: ox_inventory, tgiann-inventory, qb-inventory

Inventory = {}

-- ═══════════════════════════════════════════════════════════════
-- AUTO-DETECT INVENTORY SYSTEM
-- ═══════════════════════════════════════════════════════════════

local InventoryName = nil

if GetResourceState('tgiann-inventory') == 'started' then
    InventoryName = 'tgiann'
    print('^2[HM Dairy Inventory] Using tgiann-inventory^0')
elseif GetResourceState('ox_inventory') == 'started' then
    InventoryName = 'ox'
    print('^2[HM Dairy Inventory] Using ox_inventory^0')
elseif GetResourceState('qb-inventory') == 'started' then
    InventoryName = 'qb'
    print('^2[HM Dairy Inventory] Using qb-inventory^0')
elseif GetResourceState('qs-inventory') == 'started' then
    InventoryName = 'qs'
    print('^2[HM Dairy Inventory] Using qs-inventory^0')
else
    print('^1[HM Dairy Inventory] ERROR: No supported inventory detected!^0')
    InventoryName = 'ox' -- Fallback
end

-- ═══════════════════════════════════════════════════════════════
-- SERVER-SIDE FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

if IsDuplicityVersion() then -- Server only
    
    -- Check if player has item
    function Inventory.HasItem(source, item, amount)
        amount = amount or 1
        
        if InventoryName == 'tgiann' then
            -- tgiann-inventory: GetItemCount (SERVER ONLY!)
            local success, count = pcall(function()
                return exports['tgiann-inventory']:GetItemCount(source, item)
            end)
            
            if success and count then
                return count >= amount
            end
            
            -- Fallback: GetItemsTotalAmount
            local success2, count2 = pcall(function()
                return exports['tgiann-inventory']:GetItemsTotalAmount(source, item)
            end)
            
            if success2 and count2 then
                return count2 >= amount
            end
            
            return false
            
        elseif InventoryName == 'ox' then
            local count = exports.ox_inventory:Search(source, 'count', item)
            return count >= amount
            
        elseif InventoryName == 'qb' or InventoryName == 'qs' then
            local Player = exports['qb-core']:GetCoreObject().Functions.GetPlayer(source)
            if Player then
                local itemData = Player.Functions.GetItemByName(item)
                return itemData and itemData.amount >= amount
            end
            return false
        end
        
        return false
    end
    
    -- Remove item from player
    function Inventory.RemoveItem(source, item, amount)
        amount = amount or 1
        
        if InventoryName == 'tgiann' then
            local success, result = pcall(function()
                return exports['tgiann-inventory']:RemoveItem(source, item, amount)
            end)
            return success and result
            
        elseif InventoryName == 'ox' then
            local success = exports.ox_inventory:RemoveItem(source, item, amount)
            return success ~= nil
            
        elseif InventoryName == 'qb' or InventoryName == 'qs' then
            local Player = exports['qb-core']:GetCoreObject().Functions.GetPlayer(source)
            if Player then
                return Player.Functions.RemoveItem(item, amount)
            end
            return false
        end
        
        return false
    end
    
    -- Add item to player
    function Inventory.AddItem(source, item, amount, metadata)
        amount = amount or 1
        
        if InventoryName == 'tgiann' then
            local success, result = pcall(function()
                return exports['tgiann-inventory']:AddItem(source, item, amount, nil, metadata)
            end)
            return success and result
            
        elseif InventoryName == 'ox' then
            local success = exports.ox_inventory:AddItem(source, item, amount, metadata)
            return success ~= nil
            
        elseif InventoryName == 'qb' or InventoryName == 'qs' then
            local Player = exports['qb-core']:GetCoreObject().Functions.GetPlayer(source)
            if Player then
                return Player.Functions.AddItem(item, amount, false, metadata)
            end
            return false
        end
        
        return false
    end
    
    -- Check if player can carry item
    function Inventory.CanCarryItem(source, item, amount)
        amount = amount or 1
        
        if InventoryName == 'tgiann' then
            local success, result = pcall(function()
                return exports['tgiann-inventory']:CanCarryItem(source, item, amount)
            end)
            return success and result or false
            
        elseif InventoryName == 'ox' then
            return exports.ox_inventory:CanCarryItem(source, item, amount)
            
        elseif InventoryName == 'qb' or InventoryName == 'qs' then
            -- QB doesn't have direct CanCarry check, assume true
            return true
        end
        
        return false
    end
    
-- ═══════════════════════════════════════════════════════════════
-- CLIENT-SIDE FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

else -- Client only
    
    -- Get item count (client-side check for UI purposes ONLY!)
    -- ⚠️ NEVER use this for server-side validation!
    function Inventory.GetItemCount(item)
        if InventoryName == 'tgiann' then
            -- tgiann: Search (READ-ONLY, not reliable for validation)
            local count = exports['tgiann-inventory']:Search('count', item)
            return count or 0
            
        elseif InventoryName == 'ox' then
            return exports.ox_inventory:Search('count', item) or 0
            
        elseif InventoryName == 'qb' or InventoryName == 'qs' then
            -- QB client-side item check not recommended
            return 0
        end
        
        return 0
    end
    
end

-- Export inventory name for debugging
function Inventory.GetInventoryName()
    return InventoryName
end