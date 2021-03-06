--Copyright (C) 2017-2018 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

-- DO NOT TOUCH THE DATABASE FILES! If you have errors, report them here:
-- https://discord.gg/sEgNZxg

local _db_name = "yrp_dealers"

sql_add_column( _db_name, "name", "TEXT DEFAULT 'Unnamed dealer'" )
sql_add_column( _db_name, "tabs", "TEXT DEFAULT ''" )
sql_add_column( _db_name, "WorldModel", "TEXT DEFAULT 'models/player/skeleton.mdl'" )
sql_add_column( _db_name, "map", "TEXT DEFAULT 'gm_construct'" )

--db_drop_table( _db_name )
--db_is_empty( _db_name )

if db_select( _db_name, "*", "uniqueID = -1" ) == nil then
  local _global_shop = db_insert_into( _db_name, "name, uniqueID", "'Buy menu', -1" )
end

util.AddNetworkString( "dealer_add" )

function dealer_rem( uid )
  local _del = db_delete_from( _db_name, "uniqueID = '" .. uid .. "'" )
end

function dealer_add( ply )
  local _uid = math.Round( math.Rand( 1, 999999 ), 2 )
  local _insert = db_insert_into(  _db_name, "name, map", "'" .. _uid .. "', '" .. db_sql_str2( string.lower( game.GetMap() ) ) .. "'" )
  local _db_sel = db_select( _db_name, "uniqueID", "name = '" .. _uid .. "'" )

  if _db_sel != nil then
    _db_sel = _db_sel[1]
    local _db_upd = db_update( _db_name, "name = 'Unnamed Dealer'", "uniqueID = " .. _db_sel.uniqueID )

    local _pos = ply:GetPos()
    local _ang = ply:EyeAngles()
    local _vals = "'dealer', '" .. math.Round( _pos.x, 2 ) .. "," .. math.Round( _pos.y, 2 ) .. "," .. math.Round( _pos.z, 2 ) .. "', '" .. math.Round( _ang.p, 2 ) .. "," .. math.Round( _ang.y, 2 ) .. "," .. math.Round( _ang.r, 2 ) .. "', '" .. _db_sel.uniqueID .. "'"
    db_insert_into( "yrp_" .. db_sql_str2( string.lower( game.GetMap() ) ), "type, position, angle, linkID", _vals )
  end
end

net.Receive( "dealer_add", function( len, ply )
  dealer_add( ply )
end)

util.AddNetworkString( "dealer_add_tab" )

net.Receive( "dealer_add_tab", function( len, ply )
  local _dealer_uid = net.ReadString()
  local _tab_uid = net.ReadString()

  local _dealer = db_select( _db_name, "*", "uniqueID = " .. _dealer_uid )

  if _dealer != nil then

    _dealer = _dealer[1]

    local _tabs = string.Explode( ",", _dealer.tabs )
    if _tabs[1] == "" then
      _tabs = {}
    end

    table.insert( _tabs, _tab_uid )
    local _tabs = string.Implode( ",", _tabs )
    local _up = db_update( _db_name, "tabs = '" .. _tabs .. "'", "uniqueID = " .. _dealer_uid )
  end
end)

util.AddNetworkString( "dealer_rem_tab" )

net.Receive( "dealer_rem_tab", function( len, ply )
  local _dealer_uid = net.ReadString()
  local _tab_uid = net.ReadString()

  local _dealer = db_select( _db_name, "*", "uniqueID = " .. _dealer_uid )
  if _dealer != nil then
    _dealer = _dealer[1]
    _dealer.tabs = string.Explode( ",", _dealer.tabs )
    table.RemoveByValue( _dealer.tabs, _tab_uid )
    _dealer.tabs = string.Implode( ",", _dealer.tabs )
    db_update( _db_name, "tabs = '" .. _dealer.tabs .. "'", "uniqueID = " .. _dealer_uid )
  end
end)

util.AddNetworkString( "dealer_edit_name" )

net.Receive( "dealer_edit_name", function( len, ply )
  local _dealer_uid = net.ReadString()
  local _dealer_new_name = net.ReadString()

  local _dealer = db_update( _db_name, "name = '" .. _dealer_new_name .. "'", "uniqueID = " .. _dealer_uid )
end)

util.AddNetworkString( "dealer_edit_worldmodel" )

net.Receive( "dealer_edit_worldmodel", function( len, ply )
  local _dealer_uid = net.ReadString()
  local _dealer_new_wm = net.ReadString()

  local _dealer = db_update( _db_name, "WorldModel = '" .. _dealer_new_wm .. "'", "uniqueID = " .. _dealer_uid )
  for i, npc in pairs( ents.GetAll() ) do
    if npc:GetNWString( "dealerID", "FAILED" ) == tostring( _dealer_uid ) then
      npc:SetModel( _dealer_new_wm )
    end
  end
end)
