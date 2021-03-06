if CLIENT then
	-- Define the name and slot clientside
	SWEP.PrintName = "Paintball Shotgun"
	SWEP.Slot = 3
	SWEP.SlotPos = 0
	SWEP.IconLetter = "f"
    killicon.AddFont("paint_shotgun", "HL2MPTypeDeath", "0", Color( 255, 80, 0, 255 ))
    
    SWEP.PaintSplat = Material('decals/decal_paintsplatterpink001')
end

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 10
SWEP.Primary.Delay = 0.5
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0.1

-- Primary ammo settings
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Automatic = true

-- We don't have anything that uses secondary ammo so there's nothing here for it

-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"

function SWEP:Initialize()
    self:SetHoldType('shotgun')
end

function SWEP:DrawWorldModel()
    local v = self.Owner:GetNWVector('WeaponColor', Vector(1, 1, 1))
    render.SetColorModulation(v.x, v.y, v.z)
    self:DrawModel()
    render.SetColorModulation(1, 1, 1)
end

function SWEP:PreDrawViewModel(vm, wep)
    local v = self.Owner:GetNWVector('WeaponColor', Vector(1, 1, 1))
    wep:SetColor(Color(v.x*255, v.y*255, v.z*255))
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end

	self.Weapon:EmitSound('weapons/flaregun/fire.wav', 35, math.random(180, 200))
	self:ShootBullet(self.Primary.Damage, 6, self.Primary.Cone)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:TakePrimaryAmmo(1)
end

function SWEP:SecondaryAttack()
	-- Nothing here!
	-- Make sure this is blank to override the default
end

-- Feel free to steal this code for any weapons
function SWEP:ShootBullet(damage, numbullets, aimcone)
	-- Setup the bullet table and fire it
	local scale = aimcone
	local bullet = {}
	bullet.Num 		= numbullets
	bullet.Src 		= self.Owner:GetShootPos()			
	bullet.Dir 		= self.Owner:GetAimVector()			
	bullet.Spread 	= Vector(scale, scale, 0)		
	bullet.Force	= math.Round(damage * 2)							
	bullet.Damage	= math.Round(damage)
	bullet.AmmoType = "Pistol"
    bullet.HullSize = 8
	bullet.Tracer = 1
    bullet.TracerName = 'paintball_tracer'
	self.Owner:FireBullets(bullet)
    
    -- Make the firing look nice
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	--self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:DoImpactEffect(tr, nDamageType)
    if SERVER then return end
	if tr.HitSky then return end
    
    local v = self.Owner:GetNWVector('WeaponColor', Vector(1, 1, 1))
    c = Color(v.x*255, v.y*255, v.z*255)
    
    local s = 0.1 + 0.2*math.random()
    util.DecalEx(self.PaintSplat, tr.HitEntity or game.GetWorld(), tr.HitPos, tr.HitNormal, c, s, s)
    
    return true
end