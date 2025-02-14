SWEP.Base = "weapon_base"
SWEP.PrintName = "Portal Gun"

SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.ViewModelFlip = false
SWEP.UseHands = true

SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.SetHoldType = "pistol"

SWEP.Weight = 5
SWEP.AutoSwichTo = true
SWEP.AutoSwichFrom = false

SWEP.Category = "Seamless Portals"
SWEP.Slot = 0
SWEP.SlotPos = 1

SWEP.DrawAmmo = true
SWEP.DrawChrosshair = true

SWEP.Spawnable = true
SWEP.AdminSpawnable = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1 
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false

-- from portal gun addon
local function VectorAngle(vec1, vec2)
	local costheta = vec1:Dot(vec2) / (vec1:Length() * vec2:Length())
	local theta = math.acos(costheta)
	return math.deg(theta)
end

local seamless_check = function(e) return !(e:GetClass() == "seamless_portal" or e:GetClass() == "player") end 
local function setPortalPlacement(owner, portal)
	local tr = util.TraceLine({
		start = owner:GetShootPos(),
		endpos = owner:GetShootPos() + owner:GetAimVector() * 99999,
		filter = seamless_check,
		noDetour = true,
	})

	local rotatedAng = tr.HitNormal:Angle() + Angle(90, 0, 0)

	local elevationangle = VectorAngle(vector_up, tr.HitNormal)
	if elevationangle < 1 or (elevationangle > 179 and elevationangle < 181) then 
		rotatedAng.y = owner:EyeAngles().y + 180
	end

	portal:SetPos((tr.HitPos + tr.HitNormal * 10))	--20
	portal:SetAngles(rotatedAng)
	if CPPI then portal:CPPISetOwner(owner) end
end

function SWEP:ShootFX(primary)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	if CLIENT then 
		EmitSound("NPC_Vortigaunt.Shoot", self:GetPos(), self:EntIndex(), CHAN_AUTO, 0.25)	-- quieter for client
	end
end

function SWEP:PrimaryAttack()
	self:ShootFX(true)
	if CLIENT then return end

	if !self.Portal or !self.Portal:IsValid() then
		self.Portal = ents.Create("seamless_portal")
		self.Portal:Spawn()
		self.Portal:LinkPortal(self.Portal2)
		self.Portal:SetExitSize(Vector(1, 0.6, 1))
	end

	setPortalPlacement(self.Owner, self.Portal)
	self:SetNextPrimaryFire(CurTime() + 0.1)
end

function SWEP:SecondaryAttack() 
	self:ShootFX(true)
	if CLIENT then return end

	if !self.Portal2 or !self.Portal2:IsValid() then
		self.Portal2 = ents.Create("seamless_portal")
		self.Portal2:Spawn()
		self.Portal2:LinkPortal(self.Portal)
		self.Portal2:SetExitSize(Vector(1, 0.6, 1))
	end

	setPortalPlacement(self.Owner, self.Portal2)
	self:SetNextSecondaryFire(CurTime() + 0.1)
end

function SWEP:OnRemove()
	if CLIENT then return end
	SafeRemoveEntity(self.Portal)
	SafeRemoveEntity(self.Portal2)
end

function SWEP:Reload() 
	if CLIENT then return end
	SafeRemoveEntity(self.Portal)
	SafeRemoveEntity(self.Portal2)
end

