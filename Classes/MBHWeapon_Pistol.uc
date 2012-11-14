class MBHWeapon_Pistol extends MBHWeapon;


DefaultProperties
{
	ReloadTime=3.0

	AttachmentClass=class'UTGameContent.UTAttachment_ShockRifle'
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InventoryGroup=1

	ShotCost(0)=1
	InstantHitDamage(0)=30
	//InstantHitDamageTypes(0)=none
	
	FireInterval(0)=+0.77
	//MinReloadPct(0)=4.0
	AmmoCount=6
	LockerAmmoCount=6
	MaxAmmoCount=6


	bZoomedFireMode(1)=1
	ZoomedTargetFOV=40
	ZoomedRate=100

	weaponHudIndex=0
}
