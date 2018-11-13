--[[
    Infection
]]--

DeriveGamemode('fluffy_mg_base')

GM.Name = 'Infection'
GM.Author = 'FluffyXVI'

TEAM_RED = 1
TEAM_BLUE = 2

-- Configure teams for Hunter vs Hunted
GM.TeamBased = true
GM.TeamSurvival = true
GM.SurvivorTeam = TEAM_BLUE
GM.HunterTeam = TEAM_RED

GM.RoundNumber = 10 -- How many rounds?
GM.RoundTime = 90 -- How long should each round go for?

GM.CanSuicide = false -- Should players be able to die at will? :(
GM.ThirdPersonEnabled = false -- This gamemode overrides some functions to do with this

function GM:CreateTeams()
	if ( !GAMEMODE.TeamBased ) then return end
	
	team.SetUp( TEAM_RED, "Infected", Color( 80, 255, 80 ), true )
	team.SetSpawnPoint( TEAM_RED, {"info_player_terrorist", "info_player_combine"} )
	
	team.SetUp( TEAM_BLUE, "Survivors", Color( 80, 80, 255 ), true )
	team.SetSpawnPoint( TEAM_BLUE, {"info_player_counterterrorist", "info_player_rebel"} )
	
	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 255, 255, 80 ), true )
	team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_start", "info_player_terrorist", "info_player_combine" } ) 
end