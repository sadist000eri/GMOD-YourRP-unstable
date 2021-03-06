--Copyright (C) 2017-2018 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

local thirst = Material( "icon16/cup.png" )

function showMT( ply )
  return ply:GetNWBool( "toggle_thirst", false )
end

function hudMT( ply, color )
  if showMT( ply ) then
    local _mttext = math.Round( ( math.Round( ply:GetNWInt( "thirst", 0 ), 0 ) / 100 ) * 100, 0 ) .. "%"
    drawHUDElement( "mt", ply:GetNWInt( "thirst", 0 ), 100, _mttext, thirst, color )
  end
end

function hudMTBR( ply )
  if showMT( ply ) then
    drawHUDElementBr( "mt" )
  end
end
