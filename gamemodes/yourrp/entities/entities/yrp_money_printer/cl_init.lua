--Copyright (C) 2017 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

include("shared.lua")

function moneyPrinterButton( mp, parent, w, h, x, y, item, _net, name, _up, _full )
  local ply = LocalPlayer()
  local tmp = createD( "DPanel", parent, w, h, x, y )
  function tmp:Paint( pw, ph )
    draw.RoundedBox( ctr( 10 ), 0, 0, pw, ph, Color( 0, 0, 0, 200 ) )

    draw.RoundedBox( 0, 0, 0, ( mp:GetNWInt( item, -1 ) / mp:GetNWInt( item .. "Max", -1 ) ) * ctr( 360 ) , ph, Color( 0, 0, 255, 200 ) )

    draw.SimpleText( mp:GetNWInt( item, -1 ) .. "/" .. mp:GetNWInt( item .. "Max", -1 ) .. " " .. name, "HudBars", ctr( 10 ), ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
  end
  local tmpBut = createD( "DButton", tmp, ctr( 220 ), h, w - ctr( 220 ), 0 )
  tmpBut:SetText( "" )
  function tmpBut:Paint( pw, ph )
    local cost = mp:GetNWInt( item .. "Cost" )
    if mp:GetNWInt( item ) < mp:GetNWInt( item .. "Max" ) then
      if self:IsHovered() then
        draw.RoundedBox( ctr( 10 ), 0, 0, pw, ph, Color( 255, 255, 0, 200 ) )
        draw.SimpleText( formatMoney( ply, cost ), "HudBars", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
      else
        draw.RoundedBox( ctr( 10 ), 0, 0, pw, ph, Color( 255, 255, 255, 200 ) )
        draw.SimpleText( _up, "HudBars", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
      end
    else
      draw.RoundedBox( ctr( 10 ), 0, 0, pw, ph, Color( 0, 255, 0, 200 ) )
      draw.SimpleText( _full, "HudBars", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
  end
  function tmpBut:DoClick()
    net.Start( _net )
      net.WriteEntity( mp )
    net.SendToServer()
  end
end

local upgradeframe = nil
net.Receive( "getMoneyPrintMenu", function( len )
  local ply = LocalPlayer()

  local mp = net.ReadEntity()

  if upgradeframe == nil then
  	upgradeframe = createD( "DFrame", nil, ctr( 600 ), ctr( 600 ), 0, 0 )
  	upgradeframe:SetTitle( "" )
    upgradeframe:ShowCloseButton( false )
    function upgradeframe:Remove()
      upgradeframe = nil
    end
    function upgradeframe:Paint( pw, ph )
      draw.RoundedBox( ctr( 30 ), 0, 0, pw, ph, Color( 40, 40, 40, 200 ) )

      draw.SimpleText( lang.moneyprinter, "HudBars", pw/2, ctr( 30 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    --CPU
    moneyPrinterButton( mp, upgradeframe, ctr( 580 ), ctr( 60 ), ctr( 10 ), ctr( 60 ), "cpu", "upgradeCPU", lang.cpu, lang.upgrade, lang.max )

    --Cooler
    moneyPrinterButton( mp, upgradeframe, ctr( 580 ), ctr( 60 ), ctr( 10 ), ctr( 60 + 70 ), "cooler", "upgradeCooler", lang.cooler, lang.upgrade, lang.max )

    --Printer
    moneyPrinterButton( mp, upgradeframe, ctr( 580 ), ctr( 60 ), ctr( 10 ), ctr( 60 + 140 ), "printer", "upgradePrinter", lang.printer, lang.upgrade, lang.max )

    --Printer
    moneyPrinterButton( mp, upgradeframe, ctr( 580 ), ctr( 60 ), ctr( 10 ), ctr( 60 + 210 ), "storage", "upgradeStorage", lang.storage, lang.upgrade, lang.max )

    --Fuel
    moneyPrinterButton( mp, upgradeframe, ctr( 580 ), ctr( 60 ), ctr( 10 ), ctr( 60 + 280 ), "fuel", "fuelUP", lang.fuel, lang.fuelup, lang.full )

    --Withdraw
    local moneyInfo = createD( "DPanel", upgradeframe, ctr( 580 ), ctr( 60 ), ctr( 10 ), ctr( 60 + 390 ) )
    function moneyInfo:Paint( pw, ph )
      draw.RoundedBox( ctr( 10 ), 0, 0, pw, ph, Color( 0, 0, 0, 200 ) )

      draw.RoundedBox( 0, 0, 0, ( mp:GetNWInt( "money", -1 ) / mp:GetNWInt( "moneyMax", -1 ) ) * ctr( 360 ) , ph, Color( 0, 0, 255, 200 ) )

      draw.SimpleText( formatMoney( ply, mp:GetNWInt( "money", -1 ) ) .. "/" .. formatMoney( ply, mp:GetNWInt( "moneyMax" , -1 ) ), "HudBars", ctr( 10 ), ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    end

  	local withdrawMoney = createD( "DButton", moneyInfo, ctr( 220 ), ctr( 60 ), ctr( 360 ), ctr( 0 ) )
    withdrawMoney:SetText( "" )
    function withdrawMoney:Paint( pw, ph )
      if self:IsHovered() then
        draw.RoundedBox( ctr( 10 ), 0, 0, pw, ph, Color( 255, 255, 0, 200 ) )
        draw.SimpleText( lang.withdraw, "HudBars", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
      else
        draw.RoundedBox( ctr( 10 ), 0, 0, pw, ph, Color( 255, 255, 255, 200 ) )
        draw.SimpleText( lang.withdraw, "HudBars", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
      end
    end
    function withdrawMoney:DoClick()
      net.Start( "withdrawMoney" )
        net.WriteEntity( mp )
      net.SendToServer()
    end

    --Working
    local workingB = createD( "DButton", upgradeframe, ctr( 250 ), ctr( 60 ), ctr( 10 ), ctr( 520 ) )
    workingB:SetText( "" )
    function workingB:Paint( pw, ph )
      local working = lang.off
      if mp:GetNWBool( "working" ) then
        working = lang.on
      end
      if self:IsHovered() then
        draw.RoundedBox( ctr( 10 ), 0, 0, pw, ph, Color( 255, 255, 0, 200 ) )
        draw.SimpleText( lang.toggle, "HudBars", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
      else
        if mp:GetNWBool( "working" ) then
          draw.RoundedBox( ctr( 10 ), 0, 0, pw, ph, Color( 0, 255, 0, 200 ) )
        else
          draw.RoundedBox( ctr( 10 ), 0, 0, pw, ph, Color( 255, 0, 0, 200 ) )
        end
        draw.SimpleText( working, "HudBars", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
      end
    end
    function workingB:DoClick()
      net.Start( "startMoneyPrinter" )
        net.WriteEntity( mp )
      net.SendToServer()
    end

    --CLOSE
    local closeMenu = createD( "DButton", upgradeframe, 30, 30, 150-15, 300-30-10 )
    closeMenu:SetText( "" )
    function closeMenu:Paint( pw, ph )
      if self:IsHovered() then
        draw.RoundedBox( ctr( 10 ), 0, 0, pw, ph, Color( 255, 255, 0, 200 ) )
      else
        draw.RoundedBox( ctr( 10 ), 0, 0, pw, ph, Color( 255, 255, 255, 200 ) )
      end

      draw.SimpleText( "X", "HudBars", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    function closeMenu:DoClick()
      upgradeframe:Close()
    end

    upgradeframe:Center()

    upgradeframe:MakePopup()
  end
end)

function ENT:Draw()
  local ply = LocalPlayer()
  local dist = ply:GetPos():Distance( self:GetPos() )
  if dist < 2000 then
    self:DrawModel()
  end
end