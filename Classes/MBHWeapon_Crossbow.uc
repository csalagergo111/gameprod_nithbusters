class MBHWeapon_Crossbow extends MBHWeapon;

DefaultProperties
{
	AttachmentClass=class'UTGameContent.UTAttachment_ShockRifle'
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InventoryGroup=3

	ShotCost(0)=1
	InstantHitDamage(0)=30
	//InstantHitDamageTypes(0)=none
	
	FireInterval(0)=+0.77
	AmmoCount=12
	LockerAmmoCount=12
	MaxAmmoCount=12

	bZoomedFireMode(1)=1
	ZoomedTargetFOV=40
	ZoomedRate=100
}
