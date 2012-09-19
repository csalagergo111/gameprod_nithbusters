class MBHWeapon_Crossbow extends MBHWeapon;

DefaultProperties
{
	ReloadTime=3.0

	AttachmentClass=class'UTGameContent.UTAttachment_ShockRifle'
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InventoryGroup=3

	ShotCost(0)=1
	InstantHitDamage(0)=50
	//InstantHitDamageTypes(0)=none
	
	FireInterval(0)=+0.77
	AmmoCount=1
	LockerAmmoCount=1
	MaxAmmoCount=1

	bZoomedFireMode(1)=1
	ZoomedTargetFOV=40
	ZoomedRate=100
}
