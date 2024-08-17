fx_version 'cerulean'
games { 'gta5' }

author 'RoyaleWind'
description 'RW DRAW ++'
version '2.1.0'
lua54 'on'

shared_scripts {
    'configuration.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'frontend/*.lua',
}

server_scripts {
    'backend/*.lua',
}