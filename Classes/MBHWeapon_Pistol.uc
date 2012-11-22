class MBHWeapon_Pistol extends MBHWeapon;

var () float quickFireDelay;
var() Rotator projectileMaxSpread;
var bool altFiring;

/*
simulated function InstantFire()
{
	if(CurrentFireMode == 0 && !altFiring)
		ClearTimer('fireTimer');
	super.InstantFire();
}*/

simulated function FireAmmunition()
{
	if((CurrentFireMode == 0 && !altFiring) || CurrentFireMode == 1)
	{
		super.FireAmmunition();
	}
}

simulated function PutDownWeapon()
{
	ClearTimer('fireTimer');
	super.PutDownWeapon();
}

exec function Reload()
{
	ClearTimer('fireTimer');
	super.Reload();
}

simulated function CustomFire()
{
	altFiring = true;
	ClearTimer('fireTimer');
	AmmoCount++;
	fireTimer();
}

function fireTimer()
{
	local Rotator		projectileAngleOffset;

	//Fire!
	projectileAngleOffset.Pitch = Rand(projectileMaxSpread.Pitch) -
									  (projectileMaxSpread.Pitch/2);
	projectileAngleOffset.Yaw   = Rand(projectileMaxSpread.Yaw) -
									  (projectileMaxSpread.Yaw/2);
	AddSpread(projectileAngleOffset);

	AmmoCount--;
	InstantFire();
	thePlayerPawn.IdleFire.AnimFire('Hunter_idle_fire_revolver',false,1.0);
	SetTimer(quickFireDelay, false, 'endFireAnim');
	animatingFire = true;


	if(AmmoCount > 0)
	{
		SetTimer(quickFireDelay, false, 'fireTimer');
	}
	else
		altFiring = false;
}

DefaultProperties
{
	Begin Object Class=SkeletalMeshComponent Name=PistolSkeletalMesh
	End Object

	Begin Object Name=PickUpMesh
		SkeletalMesh=SkeletalMesh'MBHRevoverModels.MBH_Wpn_Revolver_socket_tex'
	End Object
	
	ReloadTime=3.0

	AttachmentClass=class'MonsterBountyHunter.MBHPistolAttachment'
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_Custom

	
	//soundFire = SoundCue'MBHShotGunModels.Pistol_shot_soundcue';
	
	
	InventoryGroup=1

	ShotCost(0)=1
	ShotCost(1)=1

	InstantHitDamage(0)=30
	InstantHitDamage(1)=30
	//InstantHitDamageTypes(0)=none

	
	WeaponFireSnd[0] = SoundCue'MBHRevoverModels.SoundCue_pistol';
	WeaponFireSnd[1] = SoundCue'MBHRevoverModels.SoundCue_pistol';
	
	FireInterval(0)=+0.5
	FireInterval(1)=+0.77
	//MinReloadPct(0)=4.0
	AmmoCount=6
	LockerAmmoCount=6
	MaxAmmoCount=6


	//bZoomedFireMode(1)=1
	//ZoomedTargetFOV=40
	//ZoomedRate=100

	weaponHudIndex=0

	quickFireDelay=0.2
	projectileMaxSpread=(Pitch=7000,Yaw=7000,Roll=0)

	altFiring=false
}
