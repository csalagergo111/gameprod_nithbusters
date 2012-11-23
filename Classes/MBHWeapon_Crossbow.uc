class MBHWeapon_Crossbow extends MBHWeapon;

var int Arrows;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	fireSequence='Hunter_idle_fire_crossbow';
}

exec function Reload()
{
	if (Arrows > 0)
	{
		super.Reload();
		Arrows--;
	}
}

DefaultProperties
{
	Begin Object Class=SkeletalMeshComponent Name=CrossbowSkeletalMesh
	End Object


	Begin Object Name=PickUpMesh
		SkeletalMesh=SkeletalMesh'MBHCrossbowModels.MBH_Wpn_Crossbow'
	End Object
		
	Arrows=10

	ReloadTime=3.0


	AttachmentClass=class'MonsterBountyHunter.MBHCrossbowAttachment'
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_None

	WeaponProjectiles(0)=class'MBHProjectile_Arrow'
	//WeaponProjectiles(0)=class'UTProj_LinkPlasma'

	WeaponFireSnd[0] = SoundCue'MBHCrossbowModels.SoundCue_Crossbow'


	InventoryGroup=3

	ShotCost(0)=1
	//InstantHitDamage(0)=50
	//InstantHitDamageTypes(0)=none
	
	FireInterval(0)=+0.77
	AmmoCount=1
	LockerAmmoCount=1
	MaxAmmoCount=1

	bZoomedFireMode(1)=1
	ZoomedTargetFOV=20
	ZoomedRate=100

	weaponHudIndex=2
}
