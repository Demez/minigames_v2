DeriveGamemode('fluffy_mg_base')

GM.Name = 'Laser Dance'
GM.Author = 'FluffyXVI'
GM.HelpText = [[
    Get as many kills as you can!
    This is a fast-paced free-for-all deathmatch.
    
    The laser guns have insane knockback.
    Aim underneath you to go flying into the air.
    
    Just one direct hit is deadly - be cautious.
]]

GM.TeamBased = false	-- Is the gamemode FFA or Teams?
GM.Elimination = false
GM.WinBySurvival = false

GM.RoundNumber = 5      -- How many rounds?
GM.RoundTime = 120      -- Seconds each round lasts for

GM.ThirdpersonEnabled = true

function GM:Initialize()

end