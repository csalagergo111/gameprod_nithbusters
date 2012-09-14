class MBHWeapon_Pistol extends UTWeap_ShockRifle;



exec function Reload()
{
	AddAmmo(6);
}

DefaultProperties
{
	ShotCost(0)=1
	InstantHitDamage=30
	InstantHitDamageTypes(0)=none
	InventoryGroup=1
	FireInterval(0)=+0.77
	MinReloadPct(0)=4.0
	//MaxAmmoCount=6
	AmmoCount=6
	LockerAmmoCount=6
	MaxAmmoCount=6

	WeaponFireTypes(1)=EWFT_None
}
