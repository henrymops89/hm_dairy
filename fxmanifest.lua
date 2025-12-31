fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'HM Scripts'
description 'HM Dairy - SECURE VERSION mit Multi-Target Support'
version '5.1.0'

dependencies {
    'ox_lib',
    -- ox_target oder qb-target (nur eines benötigt)
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'bridge/target.lua',        -- Target System Bridge (NEW!)
    'client/blip.lua',
    'client/cows.lua',
    'client/ui.lua',
    'client/main.lua'
}

server_scripts {
    'sv_config.lua',
    'bridge/inventory.lua',
    'server/security.lua',
    'server/ui_integration.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}