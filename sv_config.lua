-- sv_config.lua
-- SERVER-ONLY CONFIGURATION
-- ⚠️ WICHTIG: Diese Datei wird NUR server-side geladen!
-- ⚠️ Niemals sensitive Daten in config.lua (shared) packen!

SvConfig = {}

-- ═══════════════════════════════════════════════════════════════
-- DISCORD LOGGING
-- ═══════════════════════════════════════════════════════════════

SvConfig.Discord = {
    Enabled = false,                    -- Set true to enable Discord logging
    
    Webhook = '',                       -- Your Discord Webhook URL
    
    -- Welche Events loggen?
    LogEvents = {
        MilkCow = true,                 -- Log wenn Spieler Kuh melkt
        RateLimit = true,               -- Log wenn Rate Limit triggered
        DistanceCheat = true,           -- Log wenn Distance Check fehlschlägt
        InvalidCow = true,              -- Log wenn ungültige Cow ID
    },
    
    -- Embed Farben
    Colors = {
        Success = 3066993,              -- Grün
        Warning = 16776960,             -- Gelb
        Error = 15158332,               -- Rot
        Info = 3447003,                 -- Blau
    },
    
    -- Bot Informationen
    BotName = 'HM Dairy Logger',
    BotAvatar = '',                     -- Optional: Bot Avatar URL
}

-- ═══════════════════════════════════════════════════════════════
-- ADMIN SETTINGS
-- ═══════════════════════════════════════════════════════════════

SvConfig.Admin = {
    -- ACE Permissions für Debug Commands
    DebugCommands = {
        RequireAce = true,
        AcePermission = 'hm_dairy.admin',  -- add_ace group.admin hm_dairy.admin allow
    },
    
    -- Wer kann Security resetten?
    SecurityCommands = {
        RequireAce = true,
        AcePermission = 'hm_dairy.admin',
    },
}

-- ═══════════════════════════════════════════════════════════════
-- BLACKLIST SYSTEM (Optional)
-- ═══════════════════════════════════════════════════════════════

SvConfig.Blacklist = {
    Enabled = false,                    -- Set true to enable blacklist
    
    -- Blacklisted Spieler (by identifier)
    Players = {
        -- 'char1:1234567890',
        -- 'license:abc123def456',
    },
    
    -- Blacklist Message
    Message = 'Du wurdest vom Dairy System ausgeschlossen.',
}

-- ═══════════════════════════════════════════════════════════════
-- ANTI-CHEAT SETTINGS
-- ═══════════════════════════════════════════════════════════════

SvConfig.AntiCheat = {
    -- Ban Spieler nach X fehlgeschlagenen Versuchen?
    AutoBan = {
        Enabled = false,                -- Set true to enable auto-ban
        MaxViolations = 10,             -- Max violations before ban
        BanDuration = 86400,            -- Ban duration in seconds (24h)
        ResetAfter = 3600,              -- Reset violations after 1 hour
    },
    
    -- Welche Violations zählen?
    Violations = {
        RateLimit = true,               -- Rate Limit Exceed = Violation
        DistanceCheat = true,           -- Distance Check Fail = Violation
        InvalidData = true,             -- Invalid Cow Index etc = Violation
    },
}

-- ═══════════════════════════════════════════════════════════════
-- PERFORMANCE MONITORING (Optional)
-- ═══════════════════════════════════════════════════════════════

SvConfig.Performance = {
    Enabled = false,                    -- Set true to enable performance monitoring
    
    LogInterval = 300,                  -- Log performance every 5 minutes
    WarnThreshold = 0.05,               -- Warn if > 0.05ms
}

-- ═══════════════════════════════════════════════════════════════
-- DATABASE SETTINGS (Optional - für künftige Features)
-- ═══════════════════════════════════════════════════════════════

SvConfig.Database = {
    Enabled = false,                    -- Set true to enable database logging
    
    Type = 'mysql',                     -- mysql, oxmysql, ghmattimysql
    
    -- Welche Daten speichern?
    SaveData = {
        MilkHistory = false,            -- Log alle Melk-Aktionen
        PlayerStats = false,            -- Spieler-Statistiken
        CowStats = false,               -- Kuh-Statistiken
    },
}

-- ═══════════════════════════════════════════════════════════════
-- EXPORTS FÜR ANDERE RESOURCES (Optional)
-- ═══════════════════════════════════════════════════════════════

SvConfig.Exports = {
    Enabled = false,                    -- Set true to enable exports
    
    -- Andere Resources die auf Dairy-Daten zugreifen dürfen
    AllowedResources = {
        'hm_market',
        'hm_economy',
    },
}

-- ═══════════════════════════════════════════════════════════════
-- NOTES
-- ═══════════════════════════════════════════════════════════════

--[[
    WICHTIGE HINWEISE:
    
    1. Diese Datei ist SERVER-ONLY!
       → Wird NUR in fxmanifest.lua server_scripts geladen
       → Client hat KEINEN Zugriff darauf
    
    2. Sensitive Daten NIEMALS in config.lua!
       → config.lua ist shared_scripts (Client + Server)
       → Webhooks, API Keys, etc. NUR hier!
    
    3. Für Production:
       → SvConfig.Discord.Enabled = true
       → Webhook URL eintragen
       → Admin ACE Permissions setzen
    
    4. Für Testing/Development:
       → Alles auf false lassen
       → Keine Webhooks nötig
]]

print('^2[HM Dairy] Server-Only Config loaded^0')