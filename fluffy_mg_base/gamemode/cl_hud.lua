include('drawarc.lua')

--[[
    Welcome to the Minigames HUD v2!
    This file has been pretty much completely made for lots of improvements around the board!
    Note: this HUD isn't the most efficient thing ever created, but the latest updates have improved framerates significantly.
--]]

-- Hide default HUD components
local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true,
    CHudCrosshair = true
} 
hook.Add( "HUDShouldDraw", "FluffyHideHUD", function( name )
	if ( hide[ name ] ) then return false end
end )

-- Main HUD function
-- This calls many of the sub functions below
function GM:HUDPaint()
    -- Obey the convar
    local shouldDraw = GetConVar('cl_drawhud'):GetBool()
    if !shouldDraw then 
		if GAMEMODE.ScoringPaneEnabled and IsValid(ScorePane) then
			ScorePane:Hide()
		end
		return 
	end
    
    -- Draw some of the parts
    self:DrawRoundState()
    self:DrawHealth()
    self:DrawAmmo()
    
    -- Crosshair - account for third person too
    if GAMEMODE.ThirdPersonEnabled and LocalPlayer().Thirdperson then
    	local x,y = 0,0
		local tr = LocalPlayer():GetEyeTrace()
		x = tr.HitPos:ToScreen().x
		y = tr.HitPos:ToScreen().y
        self:DrawCrosshair(x, y)
    else
        local tr = LocalPlayer():GetEyeTrace()
        if (tr.Entity and not tr.Entity:IsPlayer()) or (!tr.Entity) then
            self:DrawCrosshair(ScrW()/2, ScrH()/2)
        end
    end
	
	-- Scoring pane
	if GAMEMODE.ScoringPaneEnabled then
		if !IsValid(ScorePane) then 
			GAMEMODE:CreateScoringPane() 
		else
			ScorePane:Show()
		end
	end
    
    -- Hooks! Yay!
    hook.Run( "HUDDrawTargetID" )
	hook.Run( "HUDDrawPickupHistory" )
    hook.Run( "DrawDeathNotice", 0.85, 0.04 )
end

-- Convenience to draw a circle (uncached)
-- If the same circle is being drawn a lot - use the cached version below
function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

-- Cache a circle polygon to draw later
function draw.CirclePoly(x, y, radius, seg)
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    return cir
end

-- Circle properties
local c_pos = 72
local seg = 36
local radius = 48
-- Cache the circles
local round_circle = draw.CirclePoly(c_pos, c_pos, radius, seg)
local round_circle_shadow = draw.CirclePoly(c_pos+3, c_pos+3, radius, seg)
local health_circle = draw.CirclePoly(c_pos, ScrH() - c_pos, radius, seg)
local health_circle_shadow = draw.CirclePoly(c_pos, ScrH() - c_pos+3, radius, seg)
local ammo_circle = draw.CirclePoly(ScrW() - c_pos, ScrH() - c_pos, radius, seg)
local ammo_circle_shadow = draw.CirclePoly(ScrW() - c_pos+3, ScrH() - c_pos+3, radius, seg)

-- Convar to disable the fancy arcs
-- This used to be important before, but now the arcs barely drop the frame rates
local fast_hud = CreateClientConVar("minigames_fast_hud", "0", true, false, "Set to 1 to stop drawing arcs")

-- Draw the state of the round, including time and round number
-- This is in the top left corner
function GM:DrawRoundState()
    -- Get round information
    local GAME_STATE = GetGlobalString('RoundState', 'GameNotStarted')
    local RoundTime = GetGlobalFloat('RoundStart')
    
    -- Only draw this if the game hasn't yet started
    if GAME_STATE == 'GameNotStarted' then
        draw.SimpleText( 'Waiting For Players...', "FS_40", 4+2, 4+3, GAMEMODE.FColShadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP ) -- shadow
		draw.SimpleText( 'Waiting For Players...', "FS_40", 4, 4, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        return
    end
    
    -- Draw message for end of rounds (if applicable)
    -- This amazingly hasn't been improved in a while -> consider reworking & making nice
    -- 14th November: Slightly improved
    if EndGameMessage then
        draw.SimpleText( EndGameMessage, "FS_32", ScrW()/2 + 2, 35, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText( EndGameMessage, "FS_32", ScrW()/2, 32, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Draw spectating message on bottom (very rare)
    if LocalPlayer():Team() == TEAM_SPECTATOR then
        draw.SimpleTextOutlined( 'You are a spectator', "FS_32", ScrW()/2, ScrH() - 32, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
    end
    
    -- Draw the cool round timer
    if !RoundTime then return end
    if GAME_STATE == 'EndRound' then return end
    
    -- Get some information about the rounds
	local tmax = GAMEMODE.RoundTime or 60
	if GAME_STATE == 'PreRound' then tmax = GAMEMODE.RoundCooldown or 5 end
    local round = GetGlobalInt('RoundNumber') or 1
	local rmax = GAMEMODE.RoundNumber or 5
	
    -- Draw the circle shadow
    surface.SetDrawColor(GAMEMODE.FCol3)
    surface.DrawPoly(round_circle_shadow)
    
    -- Calculate the size of the text to adapt the box
    local round_message = "Round " .. round .. " / " .. rmax, "FS_24"
    if round == rmax then round_message = "Final Round!" end
    surface.SetFont('FS_24')
    local w = surface.GetTextSize(round_message)
    
    -- Draw the box with sizing information determined above
    local rect_height = 32
    local rect_width = w + 64
    surface.SetDrawColor(GAMEMODE.FCol3)
    surface.DrawRect( c_pos, c_pos - rect_height/2, rect_width, rect_height + 3 )
    surface.SetDrawColor(GAMEMODE.FCol2)
    surface.DrawRect( c_pos, c_pos - rect_height/2, rect_width, rect_height )
    
    -- Draw the top layer of the circle
    surface.SetDrawColor(GAMEMODE.FCol2)
    surface.DrawPoly(round_circle)
    
    -- Calculate time remaining
	local t = tmax - (CurTime() - RoundTime)
	if t < 0 then t = 0 end
    
    -- Draw the arc (if applicable)
    if !fast_hud:GetBool() and t != 0 then
        draw.Arc( c_pos, c_pos, 42, 14, math.Round((t/tmax * -360) + 90), 90, 8, GAMEMODE.FCol1 )
    end
    
    -- Draw the time text
    draw.SimpleText( math.floor(t), "FS_40", c_pos+1, c_pos+2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) -- shadow
	draw.SimpleText( math.floor(t), "FS_40", c_pos, c_pos, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    
    -- Draw the round information
	if round == rmax then
        draw.SimpleText( 'Final Round!', "FS_24", c_pos+53, c_pos+3, GAMEMODE.FColShadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER ) -- shadow
		draw.SimpleText( 'Final Round!', "FS_24", c_pos+52, c_pos+2, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	else
        draw.SimpleText( "Round " .. round .. " / " .. rmax, "FS_24", c_pos+53, c_pos+3, GAMEMODE.FColShadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER ) -- shadow
		draw.SimpleText( "Round " .. round .. " / " .. rmax, "FS_24", c_pos+52, c_pos+2, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end

-- Draw the health bar
-- Armor is not included -> is there any gamemode that actually uses armor?
function GM:DrawHealth()
    -- Don't draw health for spectators
    if not LocalPlayer():Alive() or LocalPlayer():Team() == TEAM_SPECTATOR then 
        HealthBarHP = 0 
        return 
    end
    
    -- Small animation for the arc
    local hp_max = LocalPlayer():GetMaxHealth() or 100
    if HealthBarHP then
        HealthBarHP = math.Approach( HealthBarHP, LocalPlayer():Health(), 70*FrameTime() )
    else
        HealthBarHP = 100
    end
    
    local hp = HealthBarHP
    if hp <= 0 then return end
    
    -- Draw the circle shadow
    draw.NoTexture()
    surface.SetDrawColor(GAMEMODE.FCol3)
    surface.DrawPoly(health_circle_shadow)
    
    -- Calculate the size of the team name text
    -- Then draw a rectangle
    local team_name = team.GetName( LocalPlayer():Team() )
    if GAMEMODE.TeamBased then
        surface.SetFont('FS_24')
        local w = surface.GetTextSize(team_name)
        local rect_height = 32
        local rect_width = w + 64
        surface.SetDrawColor(GAMEMODE.FCol3)
        surface.DrawRect( c_pos, ScrH() - c_pos - rect_height/2, rect_width, rect_height + 3 )
        surface.SetDrawColor(GAMEMODE.FCol2)
        surface.DrawRect( c_pos, ScrH() - c_pos - rect_height/2, rect_width, rect_height )
    end
    
    -- Draw the top layer of the circle
    surface.SetDrawColor(GAMEMODE.FCol2)
    surface.DrawPoly(health_circle)
    
    -- Draw arc (if applicable)
    if !fast_hud:GetBool() and hp > 0 then
        local ang = (hp/hp_max) * -360
        if ang % 2 == 1 then ang = ang - 1 end
        draw.Arc( c_pos, ScrH() - c_pos, 42, 10, math.Round(ang+90), 90, 12, GAMEMODE.FCol1 )
    end
    
    -- Draw the health number
    draw.SimpleText( math.floor(LocalPlayer():Health()), "FS_40", c_pos+1, ScrH() - c_pos+2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) -- shadow
	draw.SimpleText( math.floor(LocalPlayer():Health()), "FS_40", c_pos, ScrH() - c_pos, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    
    -- Draw the team name (if applicable)
    if GAMEMODE.TeamBased then
        draw.SimpleText( team_name, "FS_24", c_pos+53, ScrH() - c_pos+3, GAMEMODE.FColShadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        draw.SimpleText( team_name, "FS_24", c_pos+52, ScrH() - c_pos+2, GAMEMODE.FCol1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

-- Draw the ammo
-- Note: secondary ammo is not drawn -> is there any gamemode that actually needs this?
function GM:DrawAmmo()
    -- Check the player is alive and playing the game
    if !LocalPlayer():Alive() then return end
    if GAMEMODE.TeamBased then
        if LocalPlayer():Team() == TEAM_SPECTATOR or LocalPlayer():Team() == TEAM_UNASSIGNED or LocalPlayer():Team() == 0 then return end
    end
    
    -- Grab the current weapon
    local wep = LocalPlayer():GetActiveWeapon()
    if !IsValid( wep ) then return end
    if wep.DrawAmmo == false then return end
    
    -- Get the ammo information from the gun
    -- There's a lot of unusual cases here that could be handled better in futures
    local ammo = {}
    ammo['PrimaryClip'] = wep:Clip1()
    ammo['SecondaryClip'] = wep:Clip2()
    ammo['PrimaryAmmo'] = LocalPlayer():GetAmmoCount( wep:GetPrimaryAmmoType() )
    ammo['SecondaryAmmo'] = LocalPlayer():GetAmmoCount( wep:GetSecondaryAmmoType() )
    ammo['MaxPrimaryClip'] = wep:GetMaxClip1()
    ammo['MaxSecondaryClip'] = wep:GetMaxClip2()
    
    -- Some weapons have a custom ammo display function to calculate this table
    if wep.CustomAmmoDisplay then
        if wep:CustomAmmoDisplay() != nil then ammo = wep:CustomAmmoDisplay() end
    end
    
    -- Check the ammo table is valid
    if !ammo then return end
    if ammo['PrimaryClip'] == -1 then return end
    
    -- Draw the shadow & circle
    draw.NoTexture()
    surface.SetDrawColor(GAMEMODE.FCol3)
    surface.DrawPoly(ammo_circle_shadow)
    surface.SetDrawColor(GAMEMODE.FCol2)
    surface.DrawPoly(ammo_circle)
    
    -- Draw the arc (if applicable)
    if !fast_hud:GetBool() then
        if ammo['MaxPrimaryClip'] and ammo['MaxPrimaryClip'] > -1 then
            -- Calculate the percentage with slight interpolation
            local p = ammo['PrimaryClip'] / ammo['MaxPrimaryClip']
            if ClipPercentage then
                ClipPercentage = math.Approach( ClipPercentage, p, FrameTime() )
            else
                ClipPercentage = p
            end
            
            -- Draw the arc
            local ang = ClipPercentage * -360
            draw.Arc( ScrW() - c_pos, ScrH() - c_pos, 42, 6, math.Round(ang+90), 90, 12, GAMEMODE.FCol1 )
        end
    end
    
    -- If there is a 'reserve' value for this gun, draw clip & ammo
    -- Otherwise, just draw the clip
    if ammo['PrimaryAmmo'] and ammo['PrimaryAmmo'] > -1 then
        -- Clip & ammo
        draw.SimpleText( ammo['PrimaryClip'], "FS_40", ScrW() - c_pos+1, ScrH() - c_pos+2 - 4, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) --shadow
        draw.SimpleText( ammo['PrimaryClip'], "FS_40", ScrW() - c_pos, ScrH() - c_pos - 4, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        
        draw.SimpleText( ammo['PrimaryAmmo'] or 72, "FS_16", ScrW() - c_pos+1, ScrH() - c_pos+2 + 16, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) --shadow
        draw.SimpleText( ammo['PrimaryAmmo'] or 72, "FS_16", ScrW() - c_pos, ScrH() - c_pos + 16, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    else
        -- Clip1 only
        draw.SimpleText( ammo['PrimaryClip'], "FS_60", ScrW() - c_pos+1, ScrH() - c_pos+2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) --shadow
        draw.SimpleText( ammo['PrimaryClip'], "FS_60", ScrW() - c_pos, ScrH() - c_pos, GAMEMODE.FCol1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    
    -- What about secondary ammo?? :(
    -- Todo: add a check for 'infinite' ammo (I think this is done)
end

-- Play a COOL sound when the round ends!
-- Also display the EndGameMessage -> update the look of this soon
net.Receive( 'EndRound', function()
	surface.PlaySound( 'friends/friend_join.wav' )
    EndGameMessage = net.ReadString()
    timer.Simple( GAMEMODE.RoundCooldown, function() EndGameMessage = nil end )
end )

function GM:ScoringPaneScore(ply)
	return ply:Frags()
end

function GM:ScoreRefreshSort()
    if !ScorePane then return end
    local scores = {}
    for k,v in pairs( player.GetAll() ) do
        local score = GAMEMODE:ScoringPaneScore(v)
        table.insert( scores, {v, score} )
    end
    table.sort( scores, function( a, b ) return a[2] > b[2] end )
    
    ScorePane:Clear()
    local count = ScrW()*0.5 / 68
    count = math.floor( count )
    
    local n = math.min( #scores, count )
    local xx = ScrW()*0.25 - (n*34)
    
    for k,v in pairs(scores) do
        if k > count then return end
        ScorePane:CreatePlayer( v[1], xx )
        xx = xx + 68
    end
end

function GM:CreateScoringPane()
    local Frame = vgui.Create('DPanel')
    Frame:SetSize( ScrW() * 0.5, 96 )
    Frame:SetPos( ScrW() * 0.25, ScrH() - 72 )
    
    function Frame:CreatePlayer( ply, x )
        local p = vgui.Create('DPanel', Frame )
        p:SetPos( x, 0 )
        p:SetSize( 64, 80 )
        function p:Paint()
            local score = GAMEMODE:ScoringPaneScore(ply) or 0
            draw.SimpleText(score, 'FS_32', 32 + 2, 40 + 2, GAMEMODE.FColShadow, TEXT_ALIGN_CENTER )
            draw.SimpleText(score, 'FS_32', 32, 40, GAMEMODE.FCol1, TEXT_ALIGN_CENTER )
        end
        
        local Avatar = vgui.Create('AvatarImage', p )
        Avatar:SetSize( 36, 36 )
        Avatar:SetPos( 14, 0 )
        Avatar:SetPlayer( ply, 64 )
    end
    
    function Frame:Paint()
    
    end
    ScorePane = Frame
	
	ScoreRefreshPlayers = timer.Create('RefreshPlayers', 2, 0, function()
		GAMEMODE:ScoreRefreshSort()
	end)
end

GM.PlayerPanels = {}
function GM:GetPlayerInfoPanel(ply)
    if GAMEMODE.PlayerPanels[ply] then return GAMEMODE.PlayerPanels[ply] end
    local panel = vgui.Create("DPanel")
    panel:SetSize(160, 64)
    panel:SetPaintedManually(true)
    local avatar = vgui.Create('AvatarCircle', panel)
    avatar:SetSize(32, 32)
    avatar:SetPos(16, 16)
    local last_health = ply:GetMaxHealth() or 100
    function panel:Paint(w, h)
        -- Small animation for the arc
        local hp_max = ply:GetMaxHealth() or 100
        if last_health then
            last_health = math.Approach(last_health, ply:Health(), 300*FrameTime())
        else
            last_health = 100
        end
        
        local hp = last_health
        if hp <= 0 then return end
        
        draw.NoTexture()
        
        local c = team.GetColor(ply:Team())
        
        local poly = poly or draw.CirclePoly(32, 32, 24, 24)
        surface.SetDrawColor(c)
        surface.DrawPoly(poly)
        
        local ang = (hp/hp_max) * -360
        if ang % 2 == 1 then ang = ang - 1 end
        draw.Arc(32, 32, 20, 8, math.Round(ang+90), 90, 12, GAMEMODE.FCol1)
        
        local name = ply:Nick()
        draw.SimpleText(name, "FS_24", 64 + 1, 32 + 1, GAMEMODE.FColShadow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(name, "FS_24", 64, 32, c, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    GAMEMODE.PlayerPanels[ply] = panel
    return panel
end

function GM:HUDDrawTargetID()
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if !trace.Hit then return end
	if !trace.HitNonWorld then return end
    
    if not trace.Entity:IsPlayer() then return end
    local xx, yy = gui.MousePos()
    if xx == 0 and yy == 0 then
        xx = ScrW()/2
        yy = ScrH()/2
    end
    
    local panel = GAMEMODE:GetPlayerInfoPanel(trace.Entity)
    panel:SetPos(xx - panel:GetWide()/2, yy - panel:GetTall()/2)
    panel:PaintManual()
end