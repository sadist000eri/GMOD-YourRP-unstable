--Copyright (C) 2017-2018 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

print( "Loading api_includes.lua" )

add_luas( "error.lua" )
add_luas( "collect.lua" )
add_luas( "output.lua" )
add_luas( "math.lua" )
add_luas( "sqlite.lua" )
add_luas( "trace.lua" )
add_luas( "vehicles.lua" )
add_luas( "date.lua" )
add_luas( "derma.lua" )
add_luas( "sp.lua" )

AddCSLuaFile( "derma/DYRPCollapsibleCategory.lua" )
AddCSLuaFile( "derma/DYRPDBList.lua" )
AddCSLuaFile( "derma/DYRPTextEntry.lua" )
AddCSLuaFile( "derma/DYRPNumberWang.lua" )
AddCSLuaFile( "derma/DYRPPanelPlus.lua" )
AddCSLuaFile( "derma/DYRPTabs.lua" )
if CLIENT then
  include( "derma/DYRPCollapsibleCategory.lua" )
  include( "derma/DYRPDBList.lua" )
  include( "derma/DYRPTextEntry.lua" )
  include( "derma/DYRPNumberWang.lua" )
  include( "derma/DYRPPanelPlus.lua" )
  include( "derma/DYRPTabs.lua" )
end

print( "Loaded api_includes.lua" )
