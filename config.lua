Config = {}

-- Debug Modus (setze auf false für Production)
Config.Debug = true

-- ============================================
-- KUH-SPAWNING
-- ============================================

Config.CowSpawns = {
    Enabled = true,                     -- Kühe automatisch spawnen?
    Model = 'a_c_cow',                  -- Kuh-Model
    SpawnDistance = 100.0,              -- Spawne Kühe wenn Spieler in dieser Distanz
    DeleteDistance = 150.0,             -- Lösche Kühe wenn Spieler zu weit weg
    
    -- Spawn-Positionen (füge hier deine Positionen hinzu!)
    Locations = {
        -- Beispiel-Positionen (ersetze mit deinen echten Koordinaten!)
        { coords = vector4(2447.24, 4784.11, 34.18, 45.0), scenario = 'WORLD_COW_GRAZING' },
        { coords = vector4(2450.12, 4786.45, 34.20, 120.0), scenario = 'WORLD_COW_GRAZING' },
        { coords = vector4(2445.67, 4780.33, 34.15, 200.0), scenario = 'WORLD_COW_GRAZING' },
        { coords = vector4(2443.89, 4788.90, 34.22, 300.0), scenario = 'WORLD_COW_GRAZING' },
        { coords = vector4(2448.55, 4782.12, 34.17, 15.0), scenario = 'WORLD_COW_GRAZING' },
        { coords = vector4(2446.23, 4785.67, 34.19, 270.0), scenario = 'WORLD_COW_GRAZING' },
    }
}

-- ============================================
-- MELK-EINSTELLUNGEN
-- ============================================

Config.Milking = {
    -- Benötigte Items
    RequireItems = true,                -- Items checken?
    RequiredItems = {
        bucket = 'milk_bucket',
        stool = 'milk_stool'
    },
    
    -- Progress Bar
    Duration = 10000,                   -- Dauer in Millisekunden (10 Sek)
    
    -- Cooldown
    Cooldown = 15,                      -- Minuten bis Kuh wieder gemolken werden kann
    
    -- Output
    Output = {
        item = 'raw_milk',
        amount = 1,
        label = 'Rohmilch'
    },
    
    -- Animation
    Animation = {
        dict = 'amb@world_human_bum_wash@male@low@base',
        clip = 'base'
    }
}

-- ============================================
-- UI EINSTELLUNGEN
-- ============================================

Config.UI = {
    ShowAllCows = false,                -- true = Alle Kühe in UI, false = Nur die eine Kuh
    MaxDistance = 3.0,                  -- Max Distanz zur Kuh für UI & Melken (SECURITY!)
}

-- ============================================
-- SECURITY SETTINGS (NEW!)
-- ============================================

Config.Security = {
    -- Rate Limiting
    RateLimit = {
        Enabled = true,
        MaxActions = 10,                -- Max 10 UI Opens per TimeWindow
        TimeWindow = 60                 -- In Sekunden
    },
    
    -- Action Cooldown
    ActionCooldown = {
        Enabled = true,
        Seconds = 5                     -- 5 Sekunden zwischen Melk-Versuchen
    },
    
    -- Distance Check
    DistanceCheck = {
        Enabled = true,
        MaxDistance = 3.0               -- Max 3m von Kuh entfernt (uses Config.UI.MaxDistance)
    },
    
    -- Cow Validation
    ValidateCowIndex = true,            -- Prüfe ob cowIndex gültig ist
    
    -- Player Validation
    ValidatePlayer = true,              -- Prüfe ob Spieler existiert & am Leben ist
}

-- ============================================
-- MAP BLIP
-- ============================================

Config.Blip = {
    Enabled = true,
    Coords = vector3(2447.24, 4784.11, 34.18),  -- Zentrum der Farm
    Sprite = 273,                       -- Kuh-Symbol
    Color = 2,                          -- Grün
    Scale = 0.8,
    Name = 'Milchfarm'
}

-- ============================================
-- OX_TARGET
-- ============================================

Config.Target = {
    Enabled = true,
    Distance = 2.5,
    Label = 'Kuh melken',
    Icon = 'fa-solid fa-cow'
}