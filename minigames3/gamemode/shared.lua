--[[
    Robert A Fraser 2018
    Minigames Reborn
	
	Base file for the gamemode which is loaded on both client and server
]]--

-- Load the other shared files
DeriveGamemode('base')

-- These variables should be altered in each sub gamemode's shared.lua file
-- If not defined, they will return to these values here
GM.Name = 'Minigames'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    There doesn't appear to be any help text for this gamemode.
    Report this to the creator.
]]

GM.TeamBased = true

function GM:Initialize()
	-- Gamemode crashes without this function so don't remove it
	-- There's nothing that needs to be handled here, hence the blank
end

function GM:CreateTeams()
	team.SetUp(TEAM_RED, "Red Team", Color(255, 80, 80), true)
	team.SetUp(TEAM_BLUE, "Blue Team", Color(80, 80, 255), true)
	team.SetUp(TEAM_SPECTATOR, "Spectators", Color(255, 255, 80), true)
    team.SetUp(TEAM_LOBBY, "Lobby", Color(245, 246, 250)
end