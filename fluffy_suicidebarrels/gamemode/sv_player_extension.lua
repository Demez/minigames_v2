-- This file contains the useful code that makes the barrels work properly
local taunts = {
	"vo/npc/male01/behindyou01.wav",
	"vo/npc/male01/behindyou02.wav",
	"vo/npc/male01/watchout.wav",
	"vo/npc/male01/upthere01.wav",
	"vo/npc/male01/upthere02.wav",
	"vo/npc/male01/thehacks01.wav",
	"vo/npc/male01/strider_run.wav",
	"vo/npc/male01/runforyourlife01.wav",
	"vo/npc/male01/runforyourlife02.wav",
	"vo/npc/male01/runforyourlife03.wav"
}

-- Make suicide barrels go boom when they die
hook.Add('PlayerDeath', 'SuicideBarrelsDeath', function( ply )
    if ply:Team() == TEAM_RED then
        local boom = ents.Create( "env_explosion" )
        boom:SetPos( ply:GetPos() ) 
        boom:SetOwner( ply )
        boom:Spawn()
        boom:SetKeyValue( "iMagnitude", "135" ) 
        boom:Fire( "Explode", 0, 0 ) 
    end
end )

-- Actually makes the barrel explode
hook.Add('KeyPress', 'SuicideBarrelBoom', function( ply, key )
    if ply:Team() == TEAM_RED and key == IN_ATTACK then
		-- Handle exploding on left click
        if !ply:Alive() then return end
		
        if ply.NextBoom and CurTime() >= ply.NextBoom then
            ply.NextBoom = nil
            ply:SetWalkSpeed(215)
            
			-- Play blip sounds then explode
			-- This should probably be improved
            timer.Simple( .5, function() if IsValid( ply ) and ply:Alive() then ply:EmitSound( "Grenade.Blip" ) end end )
            timer.Simple( 1, function() if IsValid( ply ) and ply:Alive() then ply:EmitSound( "Grenade.Blip" ) end end )
            timer.Simple( 1.5, function() if IsValid( ply ) and ply:Alive() then ply:EmitSound( "Weapon_CombineGuard.Special1" ) end end )
            timer.Simple( 2, function() if IsValid( ply ) and ply:Alive() and ply:Team() == TEAM_RED then ply:Kill() end end )
        end
    elseif ply:Team() == TEAM_RED and key == IN_ATTACK2 then
		-- Handle taunts on right click
        if !ply:Alive() then return end
        if ply.NextTaunt and CurTime() > ply.NextTaunt then
            ply.NextTaunt = CurTime() + 1
            ply:EmitSound(table.Random(taunts), 100, 140 ) -- todo: variety
        end
    end
end )