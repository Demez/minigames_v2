DeriveGamemode('fluffy_mg_base')

GM.Name = 'Labyrinth'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    pending
]]

TEAM_RED = 1
TEAM_BLUE = 2

-- Configure teams for Hunter vs Hunted
GM.TeamBased = true
GM.TeamSurvival = true
GM.SurvivorTeam = TEAM_BLUE
GM.HunterTeam = TEAM_RED

GM.RoundNumber = 10 -- How many rounds?
GM.RoundTime = 90 -- How long should each round go for?
GM.RoundCooldown = 5 -- How long between each round?

GM.CanSuicide = true -- Should players be able to die at will? :(
GM.ThirdPersonEnabled = false -- This gamemode overrides some functions to do with this
GM.ForceFFAColors = true -- Force team gamemodes to use FFA colors

function GM:CreateTeams()
	if (!GAMEMODE.TeamBased) then return end
	
	team.SetUp(TEAM_RED, "Skeletons", Color(255, 80, 80), true)
	team.SetSpawnPoint(TEAM_RED, {"info_player_counterterrorist", "info_player_rebel", "info_player_red"})
	
	team.SetUp(TEAM_BLUE, "Humans", Color(80, 80, 255), true)
	team.SetSpawnPoint(TEAM_BLUE, {"info_player_terrorist", "info_player_combine", "info_player_blue"})
	
	team.SetUp(TEAM_SPECTATOR, "Spectators", Color(255, 255, 80), true)
	team.SetSpawnPoint(TEAM_SPECTATOR, { "info_player_start", "info_player_terrorist", "info_player_combine" }) 
end