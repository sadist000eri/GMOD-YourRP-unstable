--Copyright (C) 2017-2018 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

-- DO NOT TOUCH THE DATABASE FILES! If you have errors, report them here:
-- https://discord.gg/sEgNZxg

local _db_name = "yrp_jail"

sql_add_column( _db_name, "SteamID", "TEXT DEFAULT ''" )
sql_add_column( _db_name, "nick", "TEXT DEFAULT ''" )
sql_add_column( _db_name, "reason", "TEXT DEFAULT '-'" )
sql_add_column( _db_name, "time", "INT DEFAULT 1" )

--db_drop_table( _db_name )
--db_is_empty( _db_name )

function teleportToReleasepoint( ply )
  local _tmpTele = db_select( "yrp_" .. db_sql_str2( string.lower( game.GetMap() ) ), "*", "type = '" .. "releasepoint" .. "'" )

  if _tmpTele != nil then
    local _tmp = string.Explode( ",", _tmpTele[1].position )
    tp_to( ply, Vector( _tmp[1], _tmp[2], _tmp[3] ) )
    _tmp = string.Explode( ",", _tmpTele[1].angle )
    ply:SetEyeAngles( Angle( _tmp[1], _tmp[2], _tmp[3] ) )
  else
    local _str = lang_string( "noreleasepoint" )
    printGM( "note", _str )

    net.Start( "yrp_noti" )
      net.WriteString( "noreleasepoint" )
      net.WriteString( "" )
    net.Broadcast()
  end
end

function teleportToJailpoint( ply )
  local _tmpTele = db_select( "yrp_" .. db_sql_str2( string.lower( game.GetMap() ) ), "*", "type = '" .. "jailpoint" .. "'" )

  if _tmpTele != nil then
    local _tmp = string.Explode( ",", _tmpTele[1].position )
    tp_to( ply, Vector( _tmp[1], _tmp[2], _tmp[3] ) )
    _tmp = string.Explode( ",", _tmpTele[1].angle )
    ply:SetEyeAngles( Angle( _tmp[1], _tmp[2], _tmp[3] ) )
  else
    local _str = lang_string( "nojailpoint" )
    printGM( "note", _str )

    net.Start( "yrp_noti" )
      net.WriteString( "nojailpoint" )
      net.WriteString( "" )
    net.Broadcast()
  end
end


function clean_up_jail( ply )
  local _tmpTable = db_select( "yrp_jail", "*", "SteamID = '" .. ply:SteamID() .. "'" )
  if _tmpTable != nil then
    db_delete_from( "yrp_jail", "SteamID = '" .. ply:SteamID() .. "'" )
    ply:SetNWBool( "inJail", false )
    ply:SetNWInt( "jailtime", 0 )

    teleportToReleasepoint( ply )
  end
end

util.AddNetworkString( "dbAddJail" )

net.Receive( "dbAddJail", function( len, ply )
  local _tmpDBTable = net.ReadString()
  local _tmpDBCol = net.ReadString()
  local _tmpDBVal = net.ReadString()
  if sql.TableExists( _tmpDBTable ) then
    db_insert_into( _tmpDBTable, _tmpDBCol, _tmpDBVal )
  else
    printGM( "error", "dbInsertInto: " .. _tmpDBTable .. " is not existing" )
  end

  local _SteamID = net.ReadString()
  local _tmpTable = db_select( "yrp_jail", "*", "SteamID = '" .. _SteamID .. "'" )
  for k, v in pairs( player.GetAll() ) do
    if v:SteamID() == _SteamID then
      printGM( "note", v:Nick() .. " added to jail")
      v:SetNWBool( "inJail", true )
      v:SetNWInt( "jailtime", _tmpTable[1].time )
    end
  end
end)

util.AddNetworkString( "dbRemJail" )

net.Receive( "dbRemJail", function( len, ply )
  local _uid = net.ReadString()

  local _res = db_delete_from( "yrp_jail", "uniqueID = " .. _uid )

  local _SteamID = net.ReadString()
  local _tmpTable = db_select( "yrp_jail", "*", "SteamID = '" .. _SteamID .. "'" )

  local _in_jailboard = db_select( "yrp_jail", "*", "SteamID = '" .. _SteamID .. "'" )
  if _in_jailboard != nil then
    for k, v in pairs( player.GetAll() ) do
      if v:SteamID() == _SteamID then
        v:SetNWBool( "inJail", true )
        v:SetNWInt( "jailtime", _in_jailboard[1].time )
      end
    end
  else
    for k, v in pairs( player.GetAll() ) do
      if v:SteamID() == _SteamID then
        v:SetNWBool( "inJail", false )
        v:SetNWInt( "jailtime", 0 )
      end
    end
  end
end)
