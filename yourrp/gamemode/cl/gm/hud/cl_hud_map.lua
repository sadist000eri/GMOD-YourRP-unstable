--Copyright (C) 2017-2018 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

--cl_hud_map.lua

local map = {}

local _map = _map or {}
_map.open = false

function getCoords()
  net.Start( "askCoords" )
  net.SendToServer()
end

function toggleMap()
  if isNoMenuOpen() and !_map.open then
    _map.open = true
    openMenu()
    net.Start( "askCoords")
      net.WriteEntity( LocalPlayer() )
    net.SendToServer()
  else
    _map.open = false
    closeMap()
  end
end

function closeMap()
  if _map.window != nil and _map.window != NULL then
    closeMenu()
    _map.window:Remove()
    _map.window = nil
  end
end

local CamDataMap = {}
function openMap()
  map.open = true

  _map.window = vgui.Create( "DFrame" )
  _map.window:SetTitle("")
  _map.window:SetPos( 0, 0 )
  _map.window:SetSize( ScrW(), ScrH() )
  _map.window:ShowCloseButton( false )
  _map.window:SetDraggable( false )
  function _map.window:Paint( pw, ph )
    if map != nil then
      if map.facX != nil and map.facY != nil then
        local ply = LocalPlayer()
        draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color( 0, 0, 0, 254 ) )           --_map.window of Map

        local win = {}
        win.w, win.h = lowerToScreen( map.sizeX, map.sizeY )
        win.x = ( ScrW() / 2 ) - ( win.w / 2 )
        win.y = ( ScrH() / 2 ) - ( win.h / 2 )

        draw.RoundedBox( 0, win.x - ctr(2), win.y - ctr(2), win.w + ctr( 4 ), win.h + ctr( 4 ), Color( 255, 255, 0, 240 ) )
        draw.RoundedBox( 0, win.x, win.y, win.w, win.h, Color( 0, 0, 0, 255 ) )

        local _mapName = string.Replace( string.upper( game.GetMap() ), "_", " " )

        local _testHeight = 4000
        local tr = util.TraceLine( {
          start = ply:GetPos() + Vector( 0, 0, 16 ),
          endpos = ply:GetPos() + Vector( 0, 0, _testHeight ),
          filter = _filterENTS
        } )
        local _height = 0
        if tr.Hit then
          _height = tr.HitPos.z
        else
          _height = _testHeight
        end
        CamDataMap.angles = Angle( 90, 90, 0 )
        CamDataMap.origin = Vector( 0, 0, _height - 16 )
        CamDataMap.x = 0
        CamDataMap.y = 0
        CamDataMap.w = ScrW()
        CamDataMap.h = ScrH()
        CamDataMap.ortho = true
        CamDataMap.ortholeft = map.sizeW
        CamDataMap.orthoright = map.sizeE
        CamDataMap.orthotop = map.sizeS
        CamDataMap.orthobottom = map.sizeN

        map_RT = GetRenderTarget( "YRP_Map", win.w, win.h, true )
        map_RT_mat = CreateMaterial( "YRP_Map", "UnlitGeneric", { ["$basetexture"] = "YRP_Map" } )
        local old_RT = render.GetRenderTarget()
        local old_w, old_h = ScrW(), ScrH()
        render.SetRenderTarget( map_RT )
          render.SetViewPort( win.x, win.y, win.w, win.h )

          render.Clear( 0, 0, 0, 0 )

            cam.Start2D()
              render.RenderView( CamDataMap )
            cam.End2D()

          render.SetViewPort( 0, 0, old_w, old_h )
        render.SetRenderTarget( old_RT )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( map_RT_mat )
        surface.DrawTexturedRect( win.x, win.y, win.w, win.h )

        local plyPos = {}
        plyPos.xMax = map.sizeX
        plyPos.yMax = map.sizeY
        if map.sizeW < 0 then
          plyPos.xtmp = ( LocalPlayer():GetPos().x - map.sizeW )
        else
          plyPos.xtmp = ( LocalPlayer():GetPos().x + map.sizeE )
        end
        if map.sizeS < 0 then
          plyPos.ytmp = ( LocalPlayer():GetPos().y - map.sizeS )
        else
          plyPos.ytmp = ( LocalPlayer():GetPos().y + map.sizeN )
        end
        plyPos.x = win.x + win.w * ( plyPos.xtmp / plyPos.xMax )
        plyPos.y = win.y + win.h - win.h * ( plyPos.ytmp / plyPos.yMax )

        --You
        draw.RoundedBox( ctr(8), plyPos.x-ctr(8), plyPos.y-ctr(8), ctr(16), ctr(16), Color(40,40,40))
        draw.RoundedBox( ctr(8), plyPos.x-ctr(6), plyPos.y-ctr(6), ctr(12), ctr(12), Color(255,10,10))
        draw.SimpleTextOutlined( lang_string( "you" ), "sef", plyPos.x, plyPos.y-ctr(24), Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )

        --Coords
        draw.SimpleTextOutlined( math.Round( ply:GetPos().x, 0 ), "sef", ScrW()/2, ScrH() - ctr( 25 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
        draw.SimpleTextOutlined( ", " .. math.Round( ply:GetPos().y, 0 ), "sef", ScrW()/2, ScrH() - ctr( 25 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )

        draw.SimpleTextOutlined( "[M] - " .. lang_string( "map" ) .. ": " .. _mapName, "HudBars", ctr( 10 ), ctr( 10 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0 ) )

        if ( LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) and true then
          for k, plys in pairs( player.GetAll() ) do
            if plys != LocalPlayer() then
              --Other players
              local tmpPly = {}
              tmpPly.xMax = map.sizeX
              tmpPly.yMax = map.sizeY
              if map.sizeW < 0 then
                tmpPly.xtmp = ( plys:GetPos().x - map.sizeW )
              else
                tmpPly.xtmp = ( plys:GetPos().x + map.sizeE )
              end
              if map.sizeS < 0 then
                tmpPly.ytmp = ( plys:GetPos().y - map.sizeS )
              else
                tmpPly.ytmp = ( plys:GetPos().y + map.sizeN )
              end
              tmpPly.x = win.x + win.w * ( tmpPly.xtmp / tmpPly.xMax )
              tmpPly.y = win.y + win.h - win.h * ( tmpPly.ytmp / tmpPly.yMax )

              --Draw
              draw.RoundedBox( ctr(8), tmpPly.x-ctr(8), tmpPly.y-ctr(8), ctr(16), ctr(16), Color( 40, 40, 40, 200 ))
              draw.RoundedBox( ctr(8), tmpPly.x-ctr(6), tmpPly.y-ctr(6), ctr(12), ctr(12), Color( 40, 40, 255, 200 ))
              draw.SimpleTextOutlined( plys:Nick(), "sef", tmpPly.x, tmpPly.y-ctr(24), Color(0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
            end
          end
        end
      end
    end
  end
  function _map.window:OnClose()
    map.open = false
    closeMenu()
  end
  function _map.window:OnRemove()
    map.open = false
    closeMenu()
  end

  --_map.window:MakePopup()
end

net.Receive( "sendCoords", function()
  if net.ReadBool() then
    map = net.ReadTable()
    openMap()
  else
    printGM( "note", "wait for server coords" )
  end
end)
