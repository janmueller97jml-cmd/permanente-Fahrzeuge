fx_version 'cerulean'
game 'gta5'

author 'permanente-Fahrzeuge'
description 'Permanent vehicle persistence system - saves vehicle positions and restores them after server restart'
version '1.0.0'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server/main.lua'
}

client_scripts {
    'config.lua',
    'client/main.lua'
}
