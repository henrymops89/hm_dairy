fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'HM Scripts'
description 'HM Dairy - SECURE VERSION mit tgiann-inventory Support'
version '5.0.0'

dependencies {
    'ox_lib',
    'ox_target'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/blip.lua',          -- Map-Blip
    'client/cows.lua',          -- Kuh-Spawning
    'client/ui.lua',            -- UI Management
    'client/main.lua'           -- Event Handler
}

server_scripts {
    'sv_config.lua',            -- Server-Only Config (Discord Webhooks, etc.)
    'bridge/inventory.lua',     -- Universal Inventory Bridge
    'server/security.lua',      -- Security System
    'server/ui_integration.lua' -- Server Logic
}

ui_page 'html/index.html'

files {
    'html/index.html'
}