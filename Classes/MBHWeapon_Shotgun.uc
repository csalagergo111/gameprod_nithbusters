class MBHWeapon_Shotgun extends MBHWeapon;

//AddSpread()


DefaultProperties
{
	AttachmentClass=class'UTGameContent.UTAttachment_RocketLauncher'
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InventoryGroup=2

	ShotCost(0)=1
	InstantHitDamage(0)=50
	//InstantHitDamageTypes(0)=none
	
	FireInterval(0)=+0.77
	AmmoCount=2
	LockerAmmoCount=2
	MaxAmmoCount=2

	MuzzleFlashSocket=MF
	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashColor=(R=200,G=120,B=255,A=255)
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
}
