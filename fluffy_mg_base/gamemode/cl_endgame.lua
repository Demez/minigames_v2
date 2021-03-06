--[[
	This file is in charge of the end game panel
	The end game panel is currently a bit of a disaster
	The key parts of the panel are:
	 - Experience and level up display
	 - Map vote screen
	 - Stats / leaderboard overview
--]]

local sounds = {
    "vo/coast/odessa/male01/nlo_cheer01.wav",
    "vo/coast/odessa/male01/nlo_cheer02.wav",
    "vo/coast/odessa/male01/nlo_cheer03.wav",
    "vo/coast/odessa/male01/nlo_cheer04.wav",
    "vo/coast/odessa/female01/nlo_cheer01.wav",
    "vo/coast/odessa/female01/nlo_cheer02.wav",
    "vo/coast/odessa/female01/nlo_cheer03.wav",
}

function GM:OpenEndGamePanel()
    local frame = vgui.Create('DFrame')
    local w = ScrW()
    local h = ScrH()
    frame:SetSize(w, h)
    frame:SetPos(0, 0)
    frame:SetTitle("")
    frame:ShowCloseButton(true)
    frame:SetBackgroundBlur(true)
    frame:MakePopup()
    frame:SetPopupStayAtBack(true)
    frame:SetKeyboardInputEnabled(false)
    frame.CurrentScreen = "End of Game"
    frame.offx = 0
    frame.offy = 0
    frame.bar_h = 64
    frame.Background = Material('gamemodes/fluffy_mg_base/content/materials/fluffy/pattern1.png', 'noclamp')
    
    -- Prepare variables to do with level information
    frame.CurrentXP = LocalPlayer():GetExperience()
    frame.MaxXP = LocalPlayer():GetMaxExperience()
    frame.Level = LocalPlayer():GetLevel()
    frame.TargetXP = frame.CurrentXP
    frame.XPMessage = ""
    frame.XPMessageTime = nil
    
    local c1 = Color(0, 168, 255)
    local c2 = Color(0, 151, 230)
    
    function frame:Paint(w, h)
        local psize = 512
        self.offx = (self.offx - FrameTime()*0.1) % 1
        self.offy = (self.offy - FrameTime()*0.15) % 1
        
        -- UV stuff
        -- DrawTexturedRectUV has a lot of quirks
        local uw = ScrW()/psize
        local vh = ScrH()/psize
        uw = uw + uw/psize
        vh = vh + vh/psize
        
        surface.SetDrawColor(color_white)
        surface.SetMaterial(self.Background)
        surface.DrawTexturedRectUV(0, 0, w, h, self.offx, self.offy, uw+self.offx, vh+self.offy)
        
        -- Draw the bar at the bottom of the panel
        local bar_h = self.bar_h
        self:PaintXPMessage(w, h, bar_h)
        surface.SetDrawColor(c1)
        draw.NoTexture()
        surface.DrawTexturedRect(0, h-bar_h, w, bar_h)
        
        -- Draw the basic level information
        local tw = draw.SimpleText('Level', 'FS_L48', 8, h - bar_h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        tw = tw + draw.SimpleText(self.Level, 'FS_L64', 116, h - bar_h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(math.floor(self.CurrentXP) .. '/' .. self.MaxXP .. 'XP', 'FS_L32', 224, h - bar_h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Draw the bar
        local bar_empty = Color(220, 221, 225)
        local bar_filled = Color(0, 151, 230)
        
        -- XP animation
        self.CurrentXP = math.Approach(self.CurrentXP, self.TargetXP, FrameTime()*25)
        if self.CurrentXP >= self.MaxXP then
            self:LevelUp()
        end
        
        local percentage = math.Clamp(self.CurrentXP/self.MaxXP, 0, 1)
        local bar_fill_width = (w-480-48)
        draw.RoundedBox(16, 416, h - 3*(bar_h/4), w - 480, bar_h/2, bar_empty)
        draw.RoundedBox(16, 414, h - 3*(bar_h/4), 48 + (bar_fill_width*percentage), bar_h/2, bar_filled)
        draw.SimpleText(math.floor(percentage*100) .. '%', 'FS_L24', 424, h - bar_h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    function frame:PaintXPMessage(w, h, bar_h)
        if not self.XPMessage or self.XPMessage == '' then return end
        
        -- Draw the XP message (if applicable)
        local xph = math.Clamp((CurTime() - self.XPMessageTime), 0, 1) * (bar_h/2)
        local ca = Color(c2.r, c2.g, c2.b, 255 - xph*2)
        draw.SimpleText(self.XPMessage or '', 'FS_L32', w/2, h - bar_h - 2 + xph, ca, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end
    
    -- Confetti effect on level up
    function frame:PaintOver(w, h)
        if self.LevelledUp then
            if not self.Confetti then
                self.Confetti = {}
                for i = 1, w/3 do
                    local piece = {}
                    piece.x = i * 3 + math.random(-8, 8)
                    piece.y = h + 32
                    piece.vx = 0
                    piece.vy = math.random(-800, -100)
                    piece.ax = math.random(-20, 20)
                    piece.ay = 300
                    piece.ang = math.random(0, 6)
                    piece.angv = math.random(-1, 1)
                    piece.c = HSVToColor(math.random(360), 1, 1)
                    table.insert(self.Confetti, piece)
                end
            else
                for k,p in pairs(self.Confetti) do
                    p.vx = p.vx + p.ax * FrameTime()
                    p.vy = p.vy + p.ay * FrameTime()
                    p.x = p.x + p.vx * FrameTime()
                    p.y = p.y + p.vy * FrameTime()
                    p.ang = p.ang + p.angv
                    draw.NoTexture()
                    surface.SetDrawColor(p.c)
                    surface.DrawTexturedRectRotated(p.x, p.y, 12, 20, p.ang)
                end
            end
        end
    end
    
    function frame:AddXP(amount, reason)
        if (self.TargetXP or self.CurrentXP) > self.CurrentXP then
            self.CurrentXP = self.TargetXP
        end
        self.TargetXP = self.CurrentXP + amount
        self.XPMessage = "+" .. amount .. "XP: " .. reason
        self.XPMessageTime = (CurTime() + amount/25)
        
        local percentage = math.Clamp(self.TargetXP/self.MaxXP, 0, 1)
        local pitch = 150 + (percentage*100)
        LocalPlayer():EmitSound('ambient/alarms/warningbell1.wav', 75, pitch)
    end
    
    function frame:LevelUp()
        self.Level = self.Level + 1
        self.CurrentXP = 0
        self.TargetXP = (self.TargetXP or self.MaxXP) - self.MaxXP
        self.LevelledUp = true
    
        local sound = table.Random(sounds)
        LocalPlayer():EmitSound(sound, 75, math.random(95, 115))
    end

    function frame:ProcessXP(tbl)
        local ttime = 1
        for k,v in pairs(tbl) do
            local amount = v[3]
            local reason = v[1]
            if amount == 0 then continue end
            timer.Simple(ttime, function() self:AddXP(amount, reason) end)
            ttime = ttime + (amount/25) + 1.25
        end
    
        --timer.Simple(ttime + 2.5, function() self:GetParent():TriggerMapVote() end)
    end
    
    function frame:ProcessStatisticsTable(tbl)
        local duration = 20
        local stat_duration = duration/(table.Count(tbl)+1)
        local i = 1
        for k,v in pairs(tbl) do
            local statistic = k
            local data = v
            timer.Simple(i * stat_duration, function() self:UpdateScoreboardStat(statistic, data) end)
            i = i + 1
        end
        
        timer.Simple(duration, function() self:DisplayMapVote() end)
    end
    
    function frame:UpdateScoreboardStat(category, data)
        self.scoreboard.ScoreboardMessage = category
        self.scoreboard:Clear()
        self.scoreboard.ShowTeams = false
        self.scoreboard.yy = 56
        
        for k,v in pairs(data) do
            self.scoreboard:CreatePlayerRow(k, v[1], v[2], false)
        end
    end
    
    function frame:SetMapVoteOptions(tbl)
        self.MapVoteOptions = tbl
    end
    
    function frame:DisplayMapVote()
        self.scoreboard:Remove()
        if not self.MapVoteOptions then return end
        
        self.VotePanels = {}
        local margin = 32
        local box = ((self:GetTall() - self.bar_h) - (3*margin))/2
        local gap = self:GetWide() - (3*box) - (2*margin)
        gap = gap/2
        
        for j = 1,2 do
            local yy = margin
            if j == 2 then yy = (self:GetTall()-self.bar_h) - box - margin end
        
            for i = 1,3 do
                local map = vgui.Create('MapVotePanel', self)
                map:SetSize(box, box)
                map:SetPos(margin + (box+gap)*(i-1), yy)
                map:AddChildren()
                map:SetIndex(i + (j-1)*3)
                self.VotePanels[i + (j-1)*3] = map
                
                if self.MapVoteOptions then
                    map:SetOptions(self.MapVoteOptions[i + (j-1)*3])
                end
            end
        end
    end
    
    GAMEMODE.EndGamePanel = frame
    
    local scoreboard = vgui.Create('DPanel', frame)
    local h = ScrH() - 64 - (40*2)
    local w = h * 0.75
    scoreboard:SetSize(w, h)
    scoreboard:SetPos(ScrW()/2 - w/2, 40)
    scoreboard.ScoreboardMessage = 'Scoreboard'
    scoreboard.ShowTeams = true
    scoreboard.yy = 56
    frame.scoreboard = scoreboard
    function scoreboard:Paint(w, h)
        DisableClipping(true)
        draw.RoundedBox(16, -4, -4, w+8, h+8, Color(0, 168, 255))
        DisableClipping(false)
        draw.RoundedBox(16, 0, 0, w, h, color_white)
        
        -- Draw the header of the scoreboard
        draw.SimpleText(self.ScoreboardMessage, 'FS_L48', w/2, 4, c1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        
        -- Paint Team Info
        self:PaintTeamInfo()
    end
    
    if GAMEMODE.TeamBased and scoreboard.ShowTeams then
        scoreboard.yy = 112
    end
    
    function scoreboard:PaintTeamInfo()
        if GAMEMODE.TeamBased and scoreboard.ShowTeams then
            local tab_width = (w-40)/2
            draw.RoundedBox(8, 16, 48, tab_width, 52, team.GetColor(1))
            draw.SimpleText(team.GetName(1), 'FS_32', 24, 48, color_white)
            draw.SimpleText('Kills: ' .. team.TotalFrags(1), 'FS_16', 24, 72, color_white)
            draw.SimpleText(team.GetScore(1), 'FS_60', 16 + tab_width - 4, 72, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
            
            local t2 = w - tab_width - 16
            draw.RoundedBox(8, t2, 48, tab_width, 52, team.GetColor(2))
            draw.SimpleText(team.GetName(2), 'FS_32', t2+8, 48, color_white, TEXT_ALIGN_LEFT )
            draw.SimpleText('Kills: ' .. team.TotalFrags(2), 'FS_16', t2+8, 72, color_white, TEXT_ALIGN_LEFT )
            draw.SimpleText(team.GetScore(2), 'FS_60', t2 + tab_width - 4, 72, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
        end
    end
    
    local medal_icons = {Material('icon16/medal_gold_2.png'), Material('icon16/medal_silver_2.png'), Material('icon16/medal_bronze_2.png')}
    
    function scoreboard:CreatePlayerRow(k, ply, num, detailed)
        local row = vgui.Create('DPanel', self)
        --row:SetSize(self:GetWide() - 32, 52)
        row:SetPos(16, self.yy)
        row.Value = num
        row.Player = ply
        row.Position = k
        
        if detailed then
            function row:Paint(w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(236, 240, 241))
                draw.SimpleText(self.Player:Nick() or 'Player?', 'FS_32', 72, h/2 + 2, c1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                local ty = h/2
                
                -- Draw team information
                if GAMEMODE.TeamBased then
                    local pt = self.Player:Team()
                    local name = 'None'
                    -- WHY DO GOOD PEOPLE DO BAD THINGS WTF
                    if pt == 1 then name = 'Red' end
                    if pt == 2 then name = 'Blue' end
                    if pt == 1002 then name = 'Spec' end
                    draw.SimpleText(name, 'FS_24', 400, ty - 20, team.GetColor(pt), TEXT_ALIGN_CENTER)
                    draw.SimpleText('Team', 'FS_16', 400, ty + 4, c1, TEXT_ALIGN_CENTER)
                end
                
                -- Draw the score
                draw.SimpleText(self.Player:Frags(), 'FS_32', 475, ty - 24, c1, TEXT_ALIGN_CENTER)
                draw.SimpleText('Score', 'FS_16', 475, ty + 4, c1, TEXT_ALIGN_CENTER)
                
                -- Draw the deaths
                draw.SimpleText(self.Player:Deaths(), 'FS_32', 550, ty - 24, c1, TEXT_ALIGN_CENTER)
                draw.SimpleText('Deaths', 'FS_16', 550, ty + 4, c1, TEXT_ALIGN_CENTER)
            end
        else
            function row:Paint(w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(236, 240, 241))
                draw.SimpleText(self.Player:Nick() or 'Player?', 'FS_32', 72, h/2 + 2, c1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                if k == 1 then
                    draw.SimpleText(num or 0, 'FS_56', w - 36, h/2 + 1, c1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText(num or 0, 'FS_60', w - 32, h/2 + 1, c1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end    
        end
        
        function row:PaintOver(w, h)
            if self.Position <= 3 then
                surface.SetDrawColor(color_white)
                surface.SetMaterial(medal_icons[self.Position])
				surface.DrawTexturedRect(2, 0, 16, 16)
            end
        end
        
        -- Add the avatar
		row.Avatar = row:Add('AvatarCircle')
        if IsValid(row.Avatar) then
            row.Avatar.Avatar:SetPlayer(ply, 64) -- Don't ask
            row.Avatar:SetPos(2, 2)
            --row.Avatar:SetSize(48, 48)
        end
        
        if k == 1 then
            row:SetSize(self:GetWide() - 32, 64)
            row.Avatar:SetSize(60, 60)
            self.yy = self.yy + 72
        else
            row:SetSize(self:GetWide() - 32, 52)
            row.Avatar:SetSize(48, 48)
            self.yy = self.yy + 60
        end
    end
    
    -- Start off with the default scoreboard display
    local players = player.GetAll()
    table.sort(players, function(a, b) return a:Frags() > b:Frags() end)
    for k,v in pairs(players) do
        scoreboard:CreatePlayerRow(k, v, v:Frags(), true)
    end
end

function TestEndGameScreen()
    GAMEMODE:OpenEndGamePanel()
    timer.Simple(1, function()
        local stats = {
            {'Thanks for playing!', nil, 25},
            {'Rounds Won', nil, 10},
            {'Crates Broken', nil, 45},
            {'lol filler text', nil, 30},
        }
        GAMEMODE.EndGamePanel:ProcessXP(stats)
    end)
end

-- Open up the end game panel when the server says the game has ended
net.Receive("MinigamesGameEnd", function( len, ply )
    GAMEMODE:OpenEndGamePanel()
end )

-- Get the map vote options information from the server
net.Receive("SendMapVoteTable", function()
    GAMEMODE.VotingOptions = net.ReadTable()
    GAMEMODE.EndGamePanel:SetMapVoteOptions(GAMEMODE.VotingOptions)
    --GAMEMODE.MapVoteScreen:SetVotes(GAMEMODE.VotingOptions)
end)

-- Get the stats report information from the server
net.Receive("SendExperienceTable", function()
    GAMEMODE.XPReport = net.ReadTable()
    GAMEMODE.StatsReport = net.ReadTable()
    
    if GAMEMODE.EndGamePanel then
        GAMEMODE.EndGamePanel:ProcessXP(GAMEMODE.XPReport)
        GAMEMODE.EndGamePanel:ProcessStatisticsTable(GAMEMODE.StatsReport)
    end
end)