fx_version 'adamant'
games { 'gta5' }

author 'Magni#0247'

client_scripts {
	'config.lua',
	'client/main.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
}

ui_page {
    'html/index.html'
}

files {
    'html/index.html',
    'html/script.js',
    'html/style.css'
}