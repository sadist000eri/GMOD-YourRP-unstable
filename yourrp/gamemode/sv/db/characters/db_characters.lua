--Copyright (C) 2017-2018 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

-- DO NOT TOUCH THE DATABASE FILES! If you have errors, report them here:
-- https://discord.gg/sEgNZxg

local _db_name = "yrp_characters"

sql_add_column( _db_name, "SteamID", "TEXT" )

sql_add_column( _db_name, "roleID", "INT     DEFAULT 1" )
sql_add_column( _db_name, "groupID", "INT     DEFAULT 1" )

sql_add_column( _db_name, "playermodelID", "INT     DEFAULT 1" )
sql_add_column( _db_name, "skin", "INT     DEFAULT 1" )
sql_add_column( _db_name, "bg0", "INT     DEFAULT 0" )
sql_add_column( _db_name, "bg1", "INT     DEFAULT 0" )
sql_add_column( _db_name, "bg2", "INT     DEFAULT 0" )
sql_add_column( _db_name, "bg3", "INT     DEFAULT 0" )
sql_add_column( _db_name, "bg4", "INT     DEFAULT 0" )
sql_add_column( _db_name, "bg5", "INT     DEFAULT 0" )
sql_add_column( _db_name, "bg6", "INT     DEFAULT 0" )
sql_add_column( _db_name, "bg7", "INT     DEFAULT 0" )

sql_add_column( _db_name, "keynrs", "TEXT    DEFAULT ''" )
sql_add_column( _db_name, "rpname", "TEXT    DEFAULT 'ID_RPNAME'" )
sql_add_column( _db_name, "gender", "TEXT    DEFAULT 'male'" )
sql_add_column( _db_name, "money", "TEXT     DEFAULT '250'" )
sql_add_column( _db_name, "moneybank", "TEXT     DEFAULT '500'" )
sql_add_column( _db_name, "position", "TEXT" )
sql_add_column( _db_name, "angle", "TEXT" )
sql_add_column( _db_name, "map", "TEXT" )

--db_drop_table( _db_name )
--db_is_empty( _db_name )

util.AddNetworkString( "change_rpname" )

net.Receive( "change_rpname", function( len, ply )
  local _new_rp_name = net.ReadString()
  db_update( "yrp_characters", "rpname = '" .. db_sql_str( _new_rp_name ) .. "'", "uniqueID = " .. ply:CharID() )
  ply:SetNWString( "rpname", db_sql_str( _new_rp_name ) )
end)


util.AddNetworkString( "charGetGroups" )
util.AddNetworkString( "charGetRoles" )
util.AddNetworkString( "charGetRoleInfo" )

util.AddNetworkString( "yrp_get_characters" )

util.AddNetworkString( "DeleteCharacter" )
util.AddNetworkString( "CreateCharacter" )

util.AddNetworkString( "EnterWorld" )

net.Receive( "charGetGroups", function( len, ply )
  local tmpTable = db_select( "yrp_groups", "*", nil )
  if tmpTable == nil then
    tmpTable = {}
  end
  net.Start( "charGetGroups" )
    net.WriteTable( tmpTable )
  net.Send( ply )
end)

net.Receive( "charGetRoles", function( len, ply )
  local groupID = net.ReadString()
  local netTable = {}
  local tmpTable = db_select( "yrp_roles", "*", "groupID = " .. tonumber( groupID ) )
  if tmpTable != nil then
    local count = 1
    for k, v in pairs( tmpTable ) do
      local insert = true
      if tonumber( v.adminonly ) == 1 then
        if ply:IsAdmin() or ply:IsSuperAdmin() then
          insert = true
        else
          insert = false
        end
      else
        if tonumber( v.maxamount ) > 0 then
          if tonumber( v.uses ) < tonumber( v.maxamount ) then
            insert = true
          else
            insert = false
          end
        end
        if insert then
          if tonumber( v.whitelist ) == 1 then
            insert = isWhitelisted( ply, v.uniqueID )
          end
        end
      end
      if insert then
        netTable[count] = {}
        netTable[count] = v
        count = count + 1
      end
    end
  end
  net.Start( "charGetRoles" )
    net.WriteTable( netTable )
  net.Send( ply )
end)

net.Receive( "charGetRoleInfo", function( len, ply )
  local roleID = net.ReadString()
  local tmpTable = db_select( "yrp_roles", "*", "uniqueID = " .. tonumber( roleID ) )
  if tmpTable == nil then
    tmpTable = {}
  end
  net.Start( "charGetRoleInfo" )
    net.WriteTable( tmpTable )
  net.Send( ply )
end)

net.Receive( "yrp_get_characters", function( len, ply )
  printGM( "db", ply:Name() .. " ask for characters" )
  local netTable = {}

  local chaTab = db_select( "yrp_characters", "*", "SteamID = '" .. ply:SteamID() .. "'")

  local _charCount = 0
  if worked( chaTab, "yrp_get_characters" ) then
    for k, v in pairs( chaTab ) do
      if worked( v.roleID, "charGetCharacters roleID" ) and worked( v.groupID, "charGetCharacters groupID" ) then
        _charCount = _charCount + 1
        netTable[_charCount] = {}
        netTable[_charCount].char = v
        local tmp = db_select( "yrp_roles", "*", "uniqueID = " .. tonumber( v.roleID ) )
        if worked( tmp, "charGetCharacters role" ) then
          tmp = tmp[1]
          netTable[_charCount].role = tmp
        else
          local tmpDefault = db_select( "yrp_roles", "*", "uniqueID = " .. "1" )
          if worked( tmpDefault, "charGetCharacters tmpDefault" ) then
            tmpDefault = tmpDefault[1]
            netTable[_charCount].role = tmpDefault
          end
        end
        local tmp2 = db_select( "yrp_groups", "*", "uniqueID = " .. tonumber( v.groupID ) )
        if worked( tmp2, "charGetCharacters group" ) then
          tmp2 = tmp2[1]
          netTable[_charCount].group = tmp2
        end
      end
    end
  end
  local plytab = ply:GetPlyTab()
  netTable.plytab = plytab

  net.Start( "yrp_get_characters" )
    net.WriteTable( netTable )
  net.Send( ply )
end)

net.Receive( "DeleteCharacter", function( len, ply )
  local charID = net.ReadString()

  local result = db_delete_from( "yrp_characters", "uniqueID = " .. tonumber( charID ) )
  if result == nil then
    printGM( "db", "DeleteCharacter: success"  )
  else
    printGM( "note", "DeleteCharacter: fail"  )
  end
end)

net.Receive( "CreateCharacter", function( len, ply )
  local ch = net.ReadTable()

  local role = db_select( "yrp_roles", "*", "uniqueID = " .. tonumber( ch.roleID ) )

  local cols = "SteamID, rpname, gender, roleID, groupID, playermodelID, money, moneybank, map, skin, bg0, bg1, bg2, bg3, bg4, bg5, bg6, bg7"
  local vals = "'" .. ply:SteamID() .. "', "
  vals = vals .. "'" .. db_sql_str( ch.rpname ) .. "', "
  vals = vals .. "'" .. db_sql_str( ch.gender ) .. "', "
  vals = vals .. tonumber( role[1].uniqueID ) .. ", "
  vals = vals .. tonumber( role[1].groupID ) .. ", "
  vals = vals .. tonumber( ch.playermodelID ) .. ", "
  vals = vals .. 250 .. ", "
  vals = vals .. 500 .. ", "
  vals = vals .. "'" .. db_sql_str2( game.GetMap() ) .. "', "
  vals = vals .. tonumber( ch.skin ) .. ", "
  vals = vals .. tonumber( ch.bg[0] ) .. ", "
  vals = vals .. tonumber( ch.bg[1] ) .. ", "
  vals = vals .. tonumber( ch.bg[2] ) .. ", "
  vals = vals .. tonumber( ch.bg[3] ) .. ", "
  vals = vals .. tonumber( ch.bg[4] ) .. ", "
  vals = vals .. tonumber( ch.bg[5] ) .. ", "
  vals = vals .. tonumber( ch.bg[6] ) .. ", "
  vals = vals .. tonumber( ch.bg[7] )
  db_insert_into( "yrp_characters", cols, vals )

  local chars = db_select( "yrp_characters", "*", nil )
  if worked( chars, "CreateCharacter" ) then
    local result = db_update( "yrp_players", "CurrentCharacter = " .. tonumber( chars[#chars].uniqueID ), "SteamID = '" .. ply:SteamID() .. "'" )
  end
end)

net.Receive( "EnterWorld", function( len, ply )
  local char = net.ReadString()
  local result = db_update( "yrp_players", "CurrentCharacter = " .. tonumber( char ), "SteamID = '" .. ply:SteamID() .. "'" )
  local test = db_select( "yrp_players", "*", nil )
  ply:Spawn()
end)

util.AddNetworkString( "get_menu_bodygroups" )

net.Receive( "get_menu_bodygroups", function( len, ply )
  local _charid = ply:CharID()
  local _result = db_select( "yrp_characters", "bg0, bg1, bg2, bg3, bg4, bg5, bg6, bg7, skin, playermodelID", "uniqueID = " .. tonumber( _charid ) )
  _result = _result[1]
  local _role = ply:GetRolTab()
  _result.playermodels = _role.playermodels
  net.Start( "get_menu_bodygroups" )
    net.WriteTable( _result )
  net.Send( ply )
end)

util.AddNetworkString( "inv_bg_up" )

net.Receive( "inv_bg_up", function( len, ply )
  local _cur = net.ReadInt( 16 )
  local _id = net.ReadInt( 16 )
  ply:SetBodygroup( _id, _cur )
  local _charid = ply:CharID()
  db_update( "yrp_characters", "bg" .. tonumber( _id ) .. " = " .. tonumber( _cur ), "uniqueID = " .. tonumber( _charid ) )
end)

util.AddNetworkString( "inv_bg_do" )

net.Receive( "inv_bg_do", function( len, ply )
  local _cur = net.ReadInt( 16 )
  local _id = net.ReadInt( 16 )
  ply:SetBodygroup( _id, _cur )
  local _charid = ply:CharID()
  db_update( "yrp_characters", "bg" .. tonumber( _id ) .. " = " .. tonumber( _cur ), "uniqueID = " .. tonumber( _charid ) )
end)

util.AddNetworkString( "inv_skin_up" )

net.Receive( "inv_skin_up", function( len, ply )
  local _cur = net.ReadInt( 16 )
  ply:SetSkin( _cur )
  local _charid = ply:CharID()
  db_update( "yrp_characters", "skin" .. " = " .. tonumber( _cur ), "uniqueID = " .. tonumber( _charid ) )
end)

util.AddNetworkString( "inv_skin_do" )

net.Receive( "inv_skin_do", function( len, ply )
  local _cur = net.ReadInt( 16 )
  ply:SetSkin( _cur )
  local _charid = ply:CharID()
  db_update( "yrp_characters", "skin" .. " = " .. tonumber( _cur ), "uniqueID = " .. tonumber( _charid ) )
end)

util.AddNetworkString( "inv_pm_up" )

net.Receive( "inv_pm_up", function( len, ply )
  local _cur = net.ReadInt( 16 )
  local _pms = string.Explode( ",", ply:GetRolTab().playermodels )
  ply:SetModel( _pms[_cur] )
  local _charid = ply:CharID()
  db_update( "yrp_characters", "playermodelID" .. " = " .. tonumber( _cur ), "uniqueID = " .. tonumber( _charid ) )
end)

util.AddNetworkString( "inv_pm_do" )

net.Receive( "inv_pm_do", function( len, ply )
  local _cur = net.ReadInt( 16 )
  local _pms = string.Explode( ",", ply:GetRolTab().playermodels )
  ply:SetModel( _pms[_cur] )
  local _charid = ply:CharID()
  db_update( "yrp_characters", "playermodelID" .. " = " .. tonumber( _cur ), "uniqueID = " .. tonumber( _charid ) )
end)
