fx_version "cerulean"
game "gta5"
lua54 "yes"

author "Vertex Scripts"
version "1.0.0"

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"src/server.lua"
}

shared_scripts {
	"@vx_lib/init.lua",
	"config.shared.lua"
}
