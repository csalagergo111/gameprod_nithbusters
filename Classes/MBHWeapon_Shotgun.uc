class MBHWeapon_Shotgun extends MBHWeapon;

//AddSpread()


DefaultProperties
{
	//AttachmentClass=class'UTGameContent.UTAttachment_RocketLauncher'
	AttachmentClass=class'UTGameContent.UTAttachment_ShockRifle'
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit

	InventoryGroup=2

	ShotCost(0)=0
	ShotCost(1)=0
	InstantHitDamage(0)=50
	InstantHitDamage(1)=100
	//InstantHitDamageTypes(0)=none
	
	FireInterval(0)=+0.77
	FireInterval(1)=+0.77
	AmmoCount=2
	LockerAmmoCount=2
	MaxAmmoCount=2

	//Spread(0)=0.02

	//MuzzleFlashSocket=MF
	//MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	//MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	//MuzzleFlashColor=(R=200,G=120,B=255,A=255)
	//MuzzleFlashDuration=0.33
	//MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
}
