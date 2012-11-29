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

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	fireSequence='Hunter_idle_fire_revolver';
	startReloadSequence='Hunter_start_reload_revolver';
	reloadingSequence='Hunter_reload_revolver';
}

simulated function FireAmmunition()
{
	if((CurrentFireMode == 0 && !altFiring) || CurrentFireMode == 1)
		super.FireAmmunition();
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
	switch(CurrentFireMode)
	{
	case 0:
		firePistolProjectile();
		break;
	case 1:
		altFiring = true;
		ClearTimer('fireTimer');
		AmmoCount++;
		fireTimer();
		break;
	}
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
	firePistolProjectile();
	PlayFiringSound();

	if(AmmoCount > 0)
	{
		SetTimer(quickFireDelay, false, 'fireTimer');
	}
	else
		altFiring = false;
}

function firePistolProjectile()
{
	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
	local ImpactInfo	TestImpact;
	local Projectile	SpawnedProjectile;
	local Rotator		projectileAngleOffset;

	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// This is where we would start an instant trace. (what CalcWeaponFire uses)
		StartTrace = Instigator.GetWeaponStartTraceLocation();
		AimDir = Vector(GetAdjustedAim( StartTrace ));

		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc(AimDir);

		if( StartTrace != RealStartLoc )
		{
			// if projectile is spawned at different location of crosshair,
			// then simulate an instant trace where crosshair is aiming at, Get hit info.
			EndTrace = StartTrace + AimDir * GetTraceRange();
			TestImpact = CalcWeaponFire( StartTrace, EndTrace );

			// Then we realign projectile aim direction to match where the crosshair did hit.
			AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
		}

		projectileAngleOffset.Pitch = (Rand(projectileMaxSpread.Pitch) - (projectileMaxSpread.Pitch/2))*CurrentFireMode;

		projectileAngleOffset.Yaw = (Rand(projectileMaxSpread.Yaw) - (projectileMaxSpread.Yaw/2))*CurrentFireMode;

		projectileAngleOffset.Roll = 0;
		projectileAngleOffset += rotator(AimDir);

		// Spawn projectile
		SpawnedProjectile = Spawn(GetProjectileClass(), Self,, RealStartLoc);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( AimDir + vector(projectileAngleOffset));
		}
		thePlayerPawn.FireOneHanded.AnimFire('Hunter_idle_fire_revolver',false,2.0);
	}
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
	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Custom

	WeaponProjectiles(0)=class'MBHProjectile_Shotgun'
	WeaponProjectiles(1)=class'MBHProjectile_Shotgun'
	
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
	projectileMaxSpread=(Pitch=2730,Yaw=2730,Roll=0)

	quickFireDelay=0.2

	altFiring=false
}
