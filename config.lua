Config = {}

-- Framework Detection (auto-detect)
Config.Framework = 'auto' -- 'auto', 'qbox', 'qbcore', 'esx'

-- Inventory System
Config.Inventory = 'ox_inventory' -- Currently only ox_inventory supported

-- Debug Mode
Config.Debug = false

-- ═══════════════════════════════════════════════════════════════
-- MILKING SETTINGS
-- ═══════════════════════════════════════════════════════════════

Config.Milking = {
    -- Required items to milk a cow
    RequiredItems = {
        bucket = 'milk_bucket',  -- Melkeimer
        stool = 'milk_stool'     -- Schemel
    },
    
    -- Duration of milking animation (in milliseconds)
    Duration = 10000, -- 10 seconds
    
    -- Cooldown per player per cow (in minutes)
    Cooldown = 15, -- 15 minutes
    
    -- Output item and amount
    Output = {
        item = 'raw_milk',
        amount = 1,
        label = 'Rohmilch'
    },
    
    -- Animation settings
    Animation = {
        -- ════════════════════════════════════════════════════════
        -- WÄHLE EINE ANIMATION (Kommentiere die anderen aus)
        -- ════════════════════════════════════════════════════════
        
        -- ⭐ OPTION 1: Kniende Position (EMPFOHLEN für Melken)
        dict = 'amb@world_human_bum_wash@male@low@base',
        clip = 'base',
        
        -- ⭐ OPTION 2: Yoga/Sitzend (sehr natürlich)
        -- dict = 'amb@world_human_yoga@male@base',
        -- clip = 'base_a',
        
        -- ⭐ OPTION 3: Mechaniker (arbeitet am Boden)
        -- dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
        -- clip = 'machinic_loop_mechandplayer',
        
        -- ⭐ OPTION 4: Push-ups Position (gebückt)
        -- dict = 'amb@world_human_push_ups@male@base',
        -- clip = 'base',
        
        -- ⭐ OPTION 5: Auf Knien (medizinische Position)
        -- dict = 'amb@medic@standing@kneel@base',
        -- clip = 'base',
        
        -- ⭐ OPTION 6: Sit-ups (liegend/sitzend)
        -- dict = 'amb@world_human_sit_ups@male@base',
        -- clip = 'base',
        
        -- ⭐ OPTION 7: Gärtner (pflanzt etwas)
        -- dict = 'amb@world_human_gardener_plant@male@base',
        -- clip = 'base',
        
        -- ⭐ OPTION 8: Welding (arbeitet am Boden)
        -- dict = 'amb@world_human_welding@male@base',
        -- clip = 'base',
        
        -- ════════════════════════════════════════════════════════
        -- ZUSÄTZLICHE EINSTELLUNGEN
        -- ════════════════════════════════════════════════════════
        
        scenario = nil,  -- Nicht nutzen mit der NO_OXLIB Version
        flag = 1,
        
        -- Position relative to cow
        offset = vector3(0.8, 0.0, -0.3), -- x (side), y (front/back), z (up/down)
        heading = 90.0 -- Player heading relative to cow (90 = faces side)
    }
}

-- ═══════════════════════════════════════════════════════════════
-- COW SPAWN LOCATIONS
-- ═══════════════════════════════════════════════════════════════

Config.CowSpawns = {
    -- Enable/Disable cow spawning system
    Enabled = true,
    
    -- Cow model
    Model = 'a_c_cow',
    
    -- Spawn locations (add as many as you want)
    Locations = {
        -- Example Farm 1
        {
            coords = vector4(2447.24, 4784.11, 34.18, 45.0),
            scenario = 'WORLD_COW_GRAZING' -- Optional: Cow behavior
        },
        {
            coords = vector4(2450.12, 4780.45, 34.18, 90.0),
            scenario = 'WORLD_COW_GRAZING'
        },
        {
            coords = vector4(2445.67, 4788.90, 34.18, 180.0),
            scenario = 'WORLD_COW_GRAZING'
        },
        
        -- Example Farm 2 (Grapeseed area)
        {
            coords = vector4(2378.54, 5049.23, 46.44, 270.0),
            scenario = 'WORLD_COW_GRAZING'
        },
        {
            coords = vector4(2375.89, 5052.67, 46.44, 315.0),
            scenario = 'WORLD_COW_GRAZING'
        },
        
        -- Add more locations here...
    },
    
    -- Spawn distance (cows spawn when player is within this distance)
    SpawnDistance = 100.0,
    
    -- Delete distance (cows despawn when player is beyond this distance)
    DeleteDistance = 150.0
}

-- ═══════════════════════════════════════════════════════════════
-- BLIP SETTINGS
-- ═══════════════════════════════════════════════════════════════

Config.Blip = {
    Enabled = true,
    Coords = vector3(2447.24, 4784.11, 34.18), -- Farm location
    Sprite = 273, -- Kuh-Symbol (273 = Cow)
    Color = 2, -- Grün
    Scale = 0.8,
    Name = 'Milchfarm'
}

-- ═══════════════════════════════════════════════════════════════
-- OX_TARGET SETTINGS
-- ═══════════════════════════════════════════════════════════════

Config.Target = {
    -- Distance for target interaction
    Distance = 2.0,
    
    -- Target icon
    Icon = 'fas fa-hand-holding-droplet',
    
    -- Target label
    Label = 'Kuh melken'
}

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════════

Config.Notifications = {
    -- Success messages
    Success = {
        milked = 'Du hast erfolgreich Rohmilch erhalten!',
    },
    
    -- Error messages
    Error = {
        missing_bucket = 'Du benötigst einen Melkeimer!',
        missing_stool = 'Du benötigst einen Schemel!',
        cooldown = 'Diese Kuh wurde kürzlich gemolken. Warte noch %s Minuten.',
        cancelled = 'Melken abgebrochen!',
        no_space = 'Du hast keinen Platz im Inventar!'
    },
    
    -- Info messages
    Info = {
        milking = 'Melke die Kuh...'
    }
}

-- ═══════════════════════════════════════════════════════════════
-- LOCALE SYSTEM (Future expansion)
-- ═══════════════════════════════════════════════════════════════

Config.Locale = 'de' -- 'en', 'de'