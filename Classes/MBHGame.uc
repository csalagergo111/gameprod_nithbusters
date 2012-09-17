class MBHGame extends UTDeathmatch;

defaultProperties
{
	PlayerControllerClass=class'MonsterBountyHunter.MBHPlayerController'
	DefaultPawnClass=class'MonsterBountyHunter.MBHPlayerPawn'
	//PlayerControllerClass=class'MonsterBountyHunter.UDNPlayerController'
	//DefaultPawnClass=class'MonsterBountyHunter.UDNPawn'
	DefaultInventory(0)=class'MonsterBountyHunter.MBHWeapon_Pistol'
	DefaultInventory(1)=class'MonsterBountyHunter.MBHWeapon_Shotgun'
	DefaultInventory(2)=class'MonsterBountyHunter.MBHWeapon_Crossbow'
}