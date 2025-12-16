fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'HenryMods'
description 'HM Dairy System - Multi-Framework Cow Milking System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'test.lua',
    'bridge/framework.lua',
    'bridge/inventory.lua',
    'client/*.lua'
}

server_scripts {
    'bridge/framework.lua',
    'bridge/inventory.lua',
    'server/*.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory'
}