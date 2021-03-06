DEFINE_BASECLASS "weapon_mg_base"

if CLIENT then
	-- Define the name and slot clientside
	SWEP.PrintName = "SMG"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
    
    function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText('/', "HL2MPTypeDeath", x + wide/2, y + tall/2.5, Color(241, 196, 15), TEXT_ALIGN_CENTER)
	end
    
    killicon.AddFont("weapon_mg_smg", "HL2MPTypeDeath", "/", Color(255, 80, 0, 255))
end

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 6
SWEP.Primary.Cone = 0.045
SWEP.Primary.Delay = 0.05
SWEP.Primary.NumShots = 1
SWEP.Primary.Sound = Sound("Weapon_SMG1.Single")
SWEP.Primary.Recoil = 1

-- Primary ammo settings
SWEP.Primary.ClipSize = 60
SWEP.Primary.DefaultClip = 60
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Automatic = true

SWEP.Secondary.Automatic = true

SWEP.HoldType = 'smg'

-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_smg1.mdl"