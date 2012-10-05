class MBHWeapon_Shotgun extends MBHWeapon;

var() int numOfProjectiles;

var() Rotator projectileMaxSpread;

//AddSpread()

simulated function CustomFire()
{
	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
	local ImpactInfo	TestImpact;
	local Projectile	SpawnedProjectile;
	local Rotator		projectileAngleOffset;
	local int i;

	//projSpreadInUrealUnits = projectileSpreadAngle/360*65535;

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

		for(i = 0; i < numOfProjectiles*(CurrentFireMode+1); i++)
		{
			projectileAngleOffset.Pitch = Rand(projectileMaxSpread.Pitch) -
											(projectileMaxSpread.Pitch/2);

			projectileAngleOffset.Yaw = (-projectileMaxSpread.Yaw/2) +
										(i*projectileMaxSpread.Yaw/numOfProjectiles*(CurrentFireMode+1)) +
										Rand(projectileMaxSpread.Yaw/numOfProjectiles*(CurrentFireMode+1));
			
			projectileAngleOffset.Roll = 0;
			projectileAngleOffset += rotator(AimDir);

			// Spawn projectile
			SpawnedProjectile = Spawn(GetProjectileClass(), Self,, RealStartLoc,projectileAngleOffset);
			if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
			{
				SpawnedProjectile.Init( AimDir + vector(projectileAngleOffset) );
			}
		}
	}
}


DefaultProperties
{
	AttachmentClass=class'UTGameContent.UTAttachment_ShockRifle'
	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Custom

	InventoryGroup=2

	ShotCost(0)=1
	ShotCost(1)=2
	
	WeaponProjectiles(0)=UTProj_LinkPlasma

	ShotCost(0)=1
	ShotCost(1)=2
	InstantHitDamage(0)=50
	InstantHitDamage(1)=100
	//InstantHitDamageTypes(0)=none
	
	FireInterval(0)=+0.77
	FireInterval(1)=+0.77
	AmmoCount=2
	LockerAmmoCount=2
	MaxAmmoCount=2

	numOfProjectiles=10
	projectileMaxSpread=(Pitch=7000,Yaw=16384,Roll=0)
}
