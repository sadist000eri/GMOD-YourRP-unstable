--Copyright (C) 2017-2018 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

local searchIcon = Material( "icon16/magnifier.png" )

--##############################################################################
function derma_change_language( parent, w, h, x, y )
  local _tmp = createD( "DComboBox", parent, w, h, x, y )
  _tmp:AddChoice( "[AUTOMATIC]", "auto" )
  for k, v in pairs( get_all_lang() ) do
    local _select = false
    if lang_string( "language" ) == v.lang then
      _select = true
    end
    _tmp:AddChoice( v.ineng .. "/" .. v.lang, v.short, _select )
  end
  _tmp.OnSelect = function( panel, index, value, data )
    change_language( data )
  end
  return _tmp
end
--##############################################################################

function isInTable( table, item )
  for k, v in pairs( table ) do
    if string.lower( tostring( v ) ) == string.lower( tostring( item.ClassName ) ) then
      return true
    end
  end
  return false
end

function openSelector( table, dbTable, dbSets, dbWhile, closeF )
  local table2 = string.Explode( ",", _globalWorking )
  local frame = createVGUI( "DFrame", nil, 2000, 2000, 0, 0 )
  frame:Center()
  frame:SetTitle( "" )
  function frame:Paint( pw, ph )
    draw.RoundedBox( 0, 0, 0, pw, ph, Color( 0, 0, 0, 254 ) )
  end
  function frame:OnClose()
    hook.Call( closeF )
  end

  _but_len = 160
  local searchButton = createD( "DButton", frame, ctr( _but_len ), ctr( 40 ), ctr( 10 ), ctr( 50 ) )
  searchButton:SetText( "" )
  function searchButton:Paint( pw, ph )
    local _br = 4
    surface.SetDrawColor( 255, 255, 255, 255 )
  	surface.SetMaterial( searchIcon	)
  	surface.DrawTexturedRect( ctr( _br ), ctr( _br ), ctr( 40-2*_br ), ctr( 40-2*_br ) )

    draw.SimpleText( lang_string("search") .. ":", "DermaDefault", ctr( _but_len ), ctr( 20 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
  end

  local search = createVGUI( "DTextEntry", frame, 2000 - 20 - _but_len, 40, 10 + _but_len, 50 )
	--[[function search:Paint( pw, ph )
		draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 255 ) )
		local _string = search:GetText()
		if _string == "" then
			_string = lang_string( "search" )
		end
		draw.SimpleTextOutlined( _string, "DermaDefault", ctr( 10 ), ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, ctr( 1 ), Color( 0, 0, 0, 255 ) )
  end]]--

  local site = {}
  site.cur = 1
  site.max = 1
  site.count = #table
  function getMaxSite()
    local tmpMax = math.Round( site.count/42, 2 )
    site.max = math.Round( site.count/42, 0 )
    if tmpMax > site.max then
      site.max = site.max + 1
    end
  end
  getMaxSite()

  local scrollpanel = createVGUI( "DPanel", frame, 2000 - 20, 2000 - 50 - 40 - 10 - 10, 10, 50+40+10 )
  function scrollpanel:Paint( pw, ph )
    //draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 0, 255 ) )
    draw.SimpleTextOutlined( site.cur .. "/" .. site.max, "sef", pw/2, ph - 50, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
  end

  local tmpCache = {}
  local tmpSelected = {}

  function showList()
    for k, v in pairs( tmpCache ) do
      v:Remove()
    end

    local itemSize = 320

    local tmpBr = 25
    local tmpX = 0
    local tmpY = 0

    site.count = 0
    local count = 0
    for k, v in pairs( table ) do
      if v.WorldModel == nil then
        v.WorldModel = v.Model or ""
      end
      if v.PrintName == nil then
        v.PrintName = v.Name or ""
      end
      if v.ClassName == nil then
        v.ClassName = v.Class or ""
      end

      tmpSelected[k] = {}
      tmpSelected[k].ClassName = v.ClassName
      if isInTable( table2, v ) then
        tmpSelected[k].selected = true
      else
        tmpSelected[k].selected = false
      end

      if string.find( string.lower( v.WorldModel ), search:GetText() ) or string.find( string.lower( v.PrintName ), search:GetText() ) or string.find( string.lower( v.ClassName ), search:GetText() ) then
        site.count = site.count + 1
        if ( site.count - 1 ) >= ( site.cur - 1 ) * 25 and ( site.count - 1 ) < ( site.cur ) * 25 then
          count = count + 1
          tmpCache[k] = createVGUI( "DPanel", scrollpanel, itemSize, itemSize, tmpX, tmpY )

          local tmpPointer = tmpCache[k]
          function tmpPointer:Paint( pw, ph )
            if tmpSelected[k].selected then
              draw.RoundedBox( 0, 0, 0, pw, ph, Color( 0, 255, 0, 200 ) )
            else
              if string.find( v.ClassName, "npc_" ) or string.find( v.ClassName, "base" ) then
                draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 0, 0, 200 ) )
              elseif v.WorldModel == "" then
                draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 0, 200 ) )
              else
                draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 255, 200 ) )
              end
            end
          end

          if v.WorldModel != nil and v.WorldModel != "" then
            local icon = createVGUI( "SpawnIcon", tmpPointer, itemSize, itemSize, 0, 0 )
            icon.item = v
            icon:SetText( "" )
            timer.Create( "shop" .. count, 0.5*count, 1, function()
              if icon != nil and icon != NULL and icon.item != nil then
                icon:SetModel( icon.item.WorldModel )
                if icon.Entity != nil then
                  icon.Entity:SetModelScale( 1, 0 )
                  icon:SetLookAt( Vector( 0, 0, 0 ) )
                  icon:SetCamPos( Vector( 0, -30, 15 ) )
                end
              end
            end)
          end

          local tmpButton = createD( "DButton", tmpPointer, ctr( itemSize ), ctr( itemSize ), 0, 0 )
          tmpButton:SetText( "" )
          function tmpButton:Paint( pw, ph )
            draw.RoundedBox( 0, 0, 0, pw, ph, Color( 0, 0, 0, 0 ) )
            local text = lang_string( "notadded" )
            if tmpSelected[k].selected then
              text = lang_string( "added" )
            end

            local _test = "HAS NO NAME"
            if v.PrintName != nil and v.PrintName != "" then
              _test = v.PrintName
            elseif v.ClassName != nil and v.ClassName != "" then
              _test = v.ClassName
            elseif v.WorldModel != nil and v.WorldModel != "" then
              _test = v.WorldModel
            elseif v.ViewModel != nil and v.ViewModel != "" then
              _test = v.ViewModel
            end
            draw.SimpleTextOutlined( _test, "DermaDefault", ctr( 5 ), ctr( 5 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, ctr( 1 ), Color( 0, 0, 0, 255 ) )

            draw.SimpleTextOutlined( text, "DermaDefault", pw/2, ph - ctr( 5 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, ctr( 1 ), Color( 0, 0, 0, 255 ) )
          end
          function tmpButton:DoClick()
            if tmpSelected[k].selected then
              tmpSelected[k].selected = false
            else
              tmpSelected[k].selected = true
            end
            local tmpString = ""
            for k, v in pairs( tmpSelected ) do
              if v.selected and v.ClassName != nil then
                if tmpString == "" then
                  tmpString = v.ClassName
                else
                  tmpString = tmpString .. "," .. v.ClassName
                end
              end
            end
            net.Start( "dbUpdate" )
              net.WriteString( dbTable )
              net.WriteString( dbSets .. " = '" .. tmpString .. "'" )
              net.WriteString( dbWhile )
            net.SendToServer()
            _globalWorking = tmpString
          end

          tmpX = tmpX + itemSize + tmpBr
          if tmpX > 2000 - itemSize - tmpBr then
            tmpX = 0
            tmpY = tmpY + itemSize + tmpBr
          end
        end
      end
    end
  end

  local nextB = createVGUI( "DButton", frame, 200, 50, 2000 - 10 - 200, 1800 )
  nextB:SetText( "" )
  function nextB:Paint( pw, ph )
    draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 255, 255 ) )
    draw.SimpleTextOutlined( lang_string( "nextsite" ), "sef", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
  end
  function nextB:DoClick()
    if site.max > site.cur then
      site.cur = site.cur + 1
      showList()
    end
  end

  local prevB = createVGUI( "DButton", frame, 200, 50, 10, 1800 )
  prevB:SetText( "" )
  function prevB:Paint( pw, ph )
    draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 255, 255 ) )
    draw.SimpleTextOutlined( lang_string( "prevsite" ), "sef", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
  end
  function prevB:DoClick()
    site.cur = site.cur - 1
    if site.cur < 1 then
      site.cur = 1
    end
    showList()
  end

  function search:OnChange()
    site.cur = 1
    showList()
    getMaxSite()
  end
  showList()

  frame:MakePopup()
end

function openSingleSelector( table, closeF )
  local site = {}
  site.cur = 1
  site.max = 1
  site.count = #table
  function getMaxSite()
    local tmpMax = math.Round( site.count/42, 2 )
    site.max = math.Round( site.count/42, 0 )
    if tmpMax > site.max then
      site.max = site.max + 1
    end
  end
  getMaxSite()

  local shopsize = ScrH()
  local frame = vgui.Create( "DFrame" )
  frame:SetSize( shopsize, shopsize )
  frame:SetPos( ScrW2() - shopsize/2, ScrH2() - shopsize/2 )
  frame:SetTitle( lang_string( "itemMenu" ) )
  function frame:Paint( pw, ph )
    draw.RoundedBox( 0, 0, 0, pw, ph, get_dbg_col() )
  end
  function frame:OnClose()
    hook.Call( closeF )
  end

  local PanelSelect = createD( "DPanel", frame, shopsize - ctr( 20 ), shopsize - ctr( 100 ), ctr( 10 ), ctr( 100 ) )
  PanelSelect:SetText( "" )
  function PanelSelect:Paint( pw, ph )
    //draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 0, 255 ) )
    draw.SimpleTextOutlined( site.cur .. "/" .. site.max, "sef", pw/2, ph - ctr( 50 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
  end

  local searchButton = createD( "DButton", frame, ctr( 40 ), ctr( 40 ), ctr( 10 ), ctr( 50 ) )
  searchButton:SetText( "" )
  function searchButton:Paint( pw, ph )
    local _br = 4
    surface.SetDrawColor( 255, 255, 255, 255 )
  	surface.SetMaterial( searchIcon	)
  	surface.DrawTexturedRect( ctr( _br ), ctr( _br ), ctr( 40-2*_br ), ctr( 40-2*_br ) )
  end

  local search = createD( "DTextEntry", frame, shopsize - ctr( 20+40 ), ctr( 40 ), ctr( 10+40 ), ctr( 50 ) )
	function search:Paint( pw, ph )
		draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 255 ) )
		local _string = search:GetText()
		if _string == "" then
			_string = lang_string( "search" )
		end
		draw.SimpleTextOutlined( _string, "DermaDefault", ctr( 10 ), ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, ctr( 1 ), Color( 0, 0, 0, 255 ) )
  end

  function showList()
    local tmpBr = 25
    local tmpX = 0
    local tmpY = 0

    PanelSelect:Clear()
    local _cat = nil
    if tab == "vehicles" then
      _cat = "Category"
    end

    site.count = 0
    local count = 0
    local iconsize = 384
    local amount = 20
    for k, item in SortedPairsByMemberValue( table, _cat, false ) do
      item.PrintName = item.PrintName or item.Name or ""
      item.ClassName = item.ClassName or item.Class or ""
      item.WorldModel = item.WorldModel or item.Model or ""
      if string.find( string.lower( item.WorldModel or "XXXXXXXXX" ), search:GetText() ) or string.find( string.lower( item.PrintName or "XXXXXXXXX" ), search:GetText() ) or string.find( string.lower( item.ClassName or "XXXXXXXXX" ), search:GetText() ) then
        site.count = site.count + 1
        if ( site.count - 1 ) >= ( site.cur - 1 ) * amount and ( site.count - 1 ) < ( site.cur ) * amount then
          count = count + 1

          if item.WorldModel == nil then
            item.WorldModel = item.Model or ""
          end
          if item.ClassName == nil then
            item.ClassName = item.Class or ""
          end
          if item.PrintName == nil then
            item.PrintName = item.Name or ""
          end

          local icon = createD( "SpawnIcon", PanelSelect, ctr( iconsize ), ctr( iconsize ), ctr( tmpX ), ctr( tmpY ) )
          icon.item = item
          icon:SetText( "" )
          timer.Create( "shop" .. count, 0.6*count, 1, function()
            if icon != nil and icon != NULL and icon.item != nil then
              icon:SetModel( icon.item.WorldModel )
            end
          end)
          icon:SetTooltip( item.PrintName )
          local _tmpName = createVGUI( "DButton", icon, iconsize, iconsize, 10, 10 )
          _tmpName:SetText( "" )
          function _tmpName:Paint( pw, ph )
            draw.SimpleTextOutlined( item.PrintName, "pmT", pw/2, ph-ctr( 35 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
          end
          function _tmpName:DoClick()
            LocalPlayer():SetNWString( "WorldModel", item.WorldModel )
            LocalPlayer():SetNWString( "ClassName", item.ClassName )
            LocalPlayer():SetNWString( "PrintName", item.PrintName )
            LocalPlayer():SetNWString( "Skin", item.Skin )
            frame:Close()
          end
          tmpX = tmpX + iconsize + tmpBr
          if ctr( tmpX ) > shopsize - ctr( iconsize ) - tmpBr then
            tmpX = 0
            tmpY = tmpY + iconsize + tmpBr
          end
        end
      end
    end
  end

  local nextB = createD( "DButton", frame, ctr( 200 ), ctr( 50 ), shopsize - ctr( 10 ) - ctr( 200 ), ctr( 1800 ) )
  nextB:SetText( "" )
  function nextB:Paint( pw, ph )
    draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 255, 255 ) )
    draw.SimpleTextOutlined( lang_string( "nextsite" ), "sef", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
  end
  function nextB:DoClick()
    if site.max > site.cur then
      site.cur = site.cur + 1
      showList()
    end
  end

  local prevB = createD( "DButton", frame, ctr( 200 ), ctr( 50 ), ctr( 10 ), ctr( 1800 ) )
  prevB:SetText( "" )
  function prevB:Paint( pw, ph )
    draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 255, 255 ) )
    draw.SimpleTextOutlined( lang_string( "prevsite" ), "sef", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
  end
  function prevB:DoClick()
    site.cur = site.cur - 1
    if site.cur < 1 then
      site.cur = 1
    end
    showList()
  end

  function search:OnChange()
    site.cur = 1
    showList()
    getMaxSite()
  end
  showList()

  frame:MakePopup()
end

net.Receive( "yrpInfoBox", function( len )
  local _tmp = createVGUI( "DFrame", nil, 800, 400, 0, 0 )
  _tmp:SetTitle( "Notification" )
  local _text = net.ReadString()
  function _tmp:Paint( pw, ph )
    draw.RoundedBox( 0, 0, 0, pw, ph, Color( 0, 0, 0, 80 ) )
    draw.SimpleTextOutlined( _text, "sef", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
  end

  local closeButton = createVGUI( "DButton", _tmp, 200, 50, 400 - 100, 400 - 50 )
  closeButton:SetText( "Close" )
  function closeButton:DoClick()
    _tmp:Close()
  end
  _tmp:Center()
  _tmp:MakePopup()
end)

function GM:InitPostEntity()
  printGM( "note", "All entities are loaded." )
  playerready = true

  net.Start( "player_is_ready" )
  net.SendToServer()

  initLang()

  if tobool( get_tutorial( "tut_welcome" ) ) then

    openHelpMenu()
  end

  timer.Simple( 4, function()
    local _wsitems = engine.GetAddons()
    printGM( "note", "[" .. #_wsitems .. " Workshop items]" )
    printGM( "note", " Nr.\tID\t\tName Mounted" )
    for k, ws in pairs( _wsitems ) do
    	if ws.mounted then
        --printGM( "note", "+[" .. k .. "]\t[" ..ws.wsid .. "]\t[" .. ws.title .. "] is Mounted" )
    	else
        printGM( "note", "+[" .. k .. "]\t[" .. tostring( ws.wsid ) .. "]\t[" .. tostring( ws.title ) .. "] Mounting" )
        game.MountGMA( tostring( ws.path ) )
      end
    end
    printGM( "note", "Workshop Addons Done" )
    playerfullready = true

    --[[ IF STARTED SINGLEPLAYER ]]--
    if game.SinglePlayer() then
      local _warning = createD( "DFrame", nil, 600, 600, 0, 0 )
      _warning:SetTitle( "" )
      _warning:Center()
      function _warning:Paint( pw, ph )
        paintWindow( self, pw, ph, "WARNING!" )
        draw.SimpleTextOutlined( "PLEASE DO NOT USE SINGLEPLAYER!", "HudBars", pw/2, ph/2, Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, ctr( 1 ), Color( 0, 0, 0, 255 ) )
        draw.SimpleTextOutlined( "Use a dedicated server or start multiplayer, thanks!", "HudBars", pw/2, ph/2 + ctr( 100 ), Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, ctr( 1 ), Color( 0, 0, 0, 255 ) )
        draw.SimpleTextOutlined( "PLEASE USE A DEDICATED SERVER, FOR BEST EXPERIENCE!", "HudBars", pw/2, ph/2, Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, ctr( 1 ), Color( 0, 0, 0, 255 ) )
      end
      _warning:MakePopup()
    end
  end)

  loadCompleteHUD()
  testVersion()
end

--Remove Ragdolls after 60 sec
function RemoveDeadRag( ent )
	if (ent == NULL) or (ent == nil) then return end
	if (ent:GetClass() == "class C_ClientRagdoll") then
		if ent:IsValid() and !(ent == NULL) then
			SafeRemoveEntityDelayed( ent, 60 )
		end
	end
end
hook.Add("OnEntityCreated", "RemoveDeadRag", RemoveDeadRag)

function GM:HUDDrawTargetID()
  return false
end

function surfaceBox( x, y, w, h, color )
  surface.SetDrawColor( color )
  surface.DrawRect( x, y, w, h )
end

function drawPlate( ply, string, z, color )
  if ply:Alive() then
    local _abstand = Vector( 0, 0, ply:GetModelScale() * 24 )
    local pos = ply:GetPos() + _abstand
    if ply:LookupBone( "ValveBiped.Bip01_Head1" ) then
      pos = ply:GetBonePosition( ply:LookupBone( "ValveBiped.Bip01_Head1" ) ) + _abstand
    end
    local ang = Angle( 0, LocalPlayer():GetAngles().y-90, 90 )
    local sca = ply:GetModelScale()/4
    local str = string
    local strSize = string.len( str ) + 3
    cam.Start3D2D( pos + Vector( 0, 0, z ) , ang, sca )
      surface.SetFont( "plates" )
      local _tw, _th = surface.GetTextSize( str )
      _tw = math.Round( _tw * 1.06, 0 )
      _th = _th - 8
      color.a = math.Round( color.a*0.5, 0 )
      surfaceBox( -_tw/2, 0, _tw, _th, color )
      surfaceText( str, "plates", 0, _th/2+1, Color( 255, 255, 255, color.a+1 ), 1, 1 )
    cam.End3D2D()
  end
end

hook.Add( "PlayerNoClip", "yrp_noclip_restriction", function( ply, bool )
  return false
end)

function drawPlates( ply )
  if ply:GetNWBool( "tag_dev", false ) then
    if tostring( ply:SteamID() ) == "STEAM_0:1:20900349" then
      drawPlate( ply, "DEVELOPER", 7, Color( 0, 0, 0, ply:GetColor().a ) )
    end
  end
  if ply:GetNWBool( "tag_admin", false ) or ( ply:GetNWBool( "show_tags", false ) and ply:GetMoveType() == MOVETYPE_NOCLIP and !ply:InVehicle() ) then
    if ply:IsSuperAdmin() or ply:IsAdmin() then

      drawPlate( ply, string.upper( ply:GetUserGroup() ), 0, Color( 0, 0, 140, ply:GetColor().a ) )
    end
  end
  ply:drawPlayerInfo()
  ply:drawWantedInfo()
end
hook.Add( "PostPlayerDraw", "DrawName", drawPlates )

net.Receive( "yrp_noti" , function( len )
  if playerready then
    local ply = LocalPlayer()
    if ply != nil then
      if ply:IsSuperAdmin() != nil and ply:IsAdmin() != nil then
        if ply:IsSuperAdmin() or ply:IsAdmin() then
          local _str_lang = net.ReadString()
          local _time = 4
          local _channel = NOTIFY_GENERIC
          local _str = "[" .. lang_string( "adminnotification") .. "] "
          if _str_lang == "noreleasepoint" then
            _str = _str .. lang_string( _str_lang )
          elseif _str_lang == "nojailpoint" then
            _str = _str .. lang_string( _str_lang )
          elseif _str_lang == "nogroupspawn" then
            _str = _str .. "[" .. string.upper( net.ReadString() ) .. "]" .. " " .. lang_string( _str_lang ) .. "!"
          elseif _str_lang == "inventoryclearing" then
            _str = _str .. lang_string( _str_lang ) .. " (" .. lang_string( net.ReadString() ) .. ")"
          elseif _str_lang == "playerisready" then
            _str = _str .. lang_string( "finishedloadingthegamepre" ) .. " " .. net.ReadString() .. " " .. lang_string( "finishedloadingthegamepos" )
          elseif _str_lang == "database_full_server" then
            _str = _str .. "SERVER: Database or disk is full, please make more space!"
            _time = 40
            _channel = NOTIFY_ERROR
          end

        	notification.AddLegacy( _str, _channel, _time )
        end
      end
    end
  end
end)

net.Receive( "yrp_info" , function( len )
  if playerready then
    local ply = LocalPlayer()
    if ply != nil then
      local _str = net.ReadString()
      _str = lang_string( "notallowed" ) .. " ( " .. lang_string( _str ) .. " )"
      notification.AddLegacy( _str, NOTIFY_GENERIC, 3 )
    end
  end
end)
