Inventory = {}

-- ═══════════════════════════════════════════════════════════════
-- OX_INVENTORY BRIDGE
-- ═══════════════════════════════════════════════════════════════

if IsDuplicityVersion() then -- Server
    
    -- Check if player has item
    function Inventory.HasItem(source, item, amount)
        amount = amount or 1
        local count = exports.ox_inventory:Search(source, 'count', item)
        return count >= amount
    end
    
    -- Remove item from player
    function Inventory.RemoveItem(source, item, amount)
        amount = amount or 1
        return exports.ox_inventory:RemoveItem(source, item, amount)
    end
    
    -- Add item to player
    function Inventory.AddItem(source, item, amount, metadata)
        amount = amount or 1
        return exports.ox_inventory:AddItem(source, item, amount, metadata)
    end
    
    -- Check if player can carry item
    function Inventory.CanCarryItem(source, item, amount)
        amount = amount or 1
        return exports.ox_inventory:CanCarryItem(source, item, amount)
    end
    
else -- Client
    
    -- Get item count (client-side check for UI purposes)
    function Inventory.GetItemCount(item)
        return exports.ox_inventory:Search('count', item)
    end
    
end