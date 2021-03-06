DEFINE_BASECLASS "weapon_mg_base"

if CLIENT then
	-- Define the name and slot clientside
	SWEP.PrintName = "Pistol"
	SWEP.Slot = 1
	SWEP.SlotPos = 0
    
    function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText('-', "HL2MPTypeDeath", x + wide/2, y + tall/2.5, Color(241, 196, 15), TEXT_ALIGN_CENTER)
	end
    
    killicon.AddFont("yeehaw_revolver", "HL2MPTypeDeath", "-", Color(255, 80, 0, 255))
end

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 15
SWEP.Primary.Cone = 0
SWEP.Primary.Delay = 0.2
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = Sound("Weapon_357.Single")
SWEP.Primary.Recoil = 1

-- Primary ammo settings
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic = false

SWEP.Secondary.Automatic = true

SWEP.HoldType = 'pistol'

-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_357.mdl"