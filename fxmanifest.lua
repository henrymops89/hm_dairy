fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'HM Scripts'
description 'HM Dairy UI - Single Cow Mode mit Auto-Spawning'
version '4.0.0'

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'                -- Konfiguration
}

client_scripts {
    'client/blip.lua',          -- Map-Blip
    'client/cows.lua',          -- Kuh-Spawning
    'client/ui.lua',            -- UI Management
    'client/main.lua'           -- Event Handler
}

server_scripts {
    'server/ui_integration.lua' -- Server Logic
}

ui_page 'html/index.html'

files {
    'html/index.html'
}