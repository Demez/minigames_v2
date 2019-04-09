AddCSLuaFile()
ENT.Type = "point"
ENT.Team = TEAM_UNASSIGNED

function ENT:Initialize()

end

function ENT:KeyValue(key, value)
	if key == 'team' then
		self.Team = value
	elseif key == 'arena' then
        self.ArenaName = arena
    end
end

function ENT:GetTeam()
	return self.Team
end

function ENT:GetArenaName()
    return self.ArenaName
end