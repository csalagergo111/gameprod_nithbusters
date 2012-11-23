class MBHWeapon_Shotgun extends MBHWeapon;

var() int numOfProjectiles;

var() Rotator projectileMaxSpread;
/*********************************************************************************************
 Muzzle Flash
********************************************************************************************* */

/** Holds the name of the socket to attach a muzzle flash too */
var name                    MuzzleFlashSocket;

/** Muzzle flash PSC and Templates*/
var UTParticleSystemComponent    MuzzleFlashPSC;

/** Particle Systems for our firemodes */
var ParticleSystem            MuzzleFlashPSCTemplate;

/** How long the Muzzle Flash should be there */
var() float                    MuzzleFlashDuration;

/** Whether muzzleflash has been initialized */
var bool                    bMuzzleFlashAttached;

simulated function CustomFire()
{
	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
	local ImpactInfo	TestImpact;
	local Projectile	SpawnedProjectile;
	local Rotator		projectileAngleOffset;
	local int i;

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
										(i*projectileMaxSpread.Yaw/(numOfProjectiles*(CurrentFireMode+1))) +
										Rand(projectileMaxSpread.Yaw/(numOfProjectiles*(CurrentFireMode+1)));
			
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

/*********************************************************************************************
 Muzzle Flash Methods
********************************************************************************************* */
 
/**
 * PlayFireEffects Is the root function that handles all of the effects associated with
 * a weapon.  This function creates the 1st person effects.  It should only be called
 * on a locally controlled player.
 */
simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
 // Start muzzle flash effect
 CauseMuzzleFlash();
}
/**
 * Called on a client, this function Attaches the MuzzleFlashParticleSystemComponent
 */
simulated function AttachMuzzleFlash()
{
 local SkeletalMeshComponent SKMesh;
 
 // Attach the Muzzle Flash
 bMuzzleFlashAttached = true;
 SKMesh = SkeletalMeshComponent(Mesh);
 if (  SKMesh != none )
 {
	`log("mesh found");
 //if our weapon has at least one muzzle flash
 //lets attach our muzzle flash particle system component
 if ( MuzzleFlashPSCTemplate != none )
 {
 MuzzleFlashPSC = new(Outer) class'UTParticleSystemComponent';
 MuzzleFlashPSC.bAutoActivate = false;
 MuzzleFlashPSC.SetDepthPriorityGroup(SDPG_Foreground);
 MuzzleFlashPSC.SetFOV(UDKSkeletalMeshComponent(SKMesh).FOV);
 SKMesh.AttachComponentToSocket(MuzzleFlashPSC, MuzzleFlashSocket);
 }
 }
}
 
/**
 * Causes the muzzle flash to turn on and setup a time to
 * turn it back off again.
 */
simulated event CauseMuzzleFlash()
{
 local UTPawn P;
 local ParticleSystem MuzzleTemplate;
 
 
 //If we aren't the client, make sure this pawn exists
 //before we create a muzzle flash for it
 if ( WorldInfo.NetMode != NM_Client )
 {
 P = UTPawn(Instigator);
 if ( P == None )
 {
 return;
 }
 }
 
 
 //Only proceed if our firing mode has a muzzle flash
 
 if ( !bMuzzleFlashAttached )
 {
 AttachMuzzleFlash();
 }
 if (MuzzleFlashPSCTemplate != None)
 {
 if (!MuzzleFlashPSC.bIsActive || MuzzleFlashPSC.bWasDeactivated)
 {
 MuzzleTemplate = MuzzleFlashPSCTemplate;
 
 //If our current PSC is using a different muzzle flash particle
 //Lets go ahead and swap it with the one we need
 if (MuzzleTemplate != MuzzleFlashPSC.Template)
 {
 MuzzleFlashPSC.SetTemplate(MuzzleTemplate);
 }
 SetMuzzleFlashParams(MuzzleFlashPSC);
 MuzzleFlashPSC.ActivateSystem();
 }
 }
 // Set when to turn it off.
 SetTimer(MuzzleFlashDuration,false,'MuzzleFlashTimer');
 }
 
/**
 * Turns the MuzzleFlashPSC off
 */
simulated event MuzzleFlashTimer()
{
 if (MuzzleFlashPSC != none)
 {
 MuzzleFlashPSC.DeactivateSystem();
 }
}
 
simulated event StopMuzzleFlash()
{
 ClearTimer('MuzzleFlashTimer');
 MuzzleFlashTimer();
 
 if ( MuzzleFlashPSC != none )
 {
 MuzzleFlashPSC.DeactivateSystem();
 }
}
 
/**
 * Allows a child to setup custom parameters on the muzzle flash
 */
 
simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
 return;
}
DefaultProperties
{
	Begin Object Class=SkeletalMeshComponent Name=ShotgunSkeletalMesh
	End Object
	Mesh = ShotgunSkeletalMesh

	Begin Object Name=PickUpMesh
		SkeletalMesh=SkeletalMesh'MBHShotGunModels.MBH_Wpn_Shotgun_w-sockets_done'
	End Object

	WeaponFireSnd[0] = SoundCue'MBHShotGunModels.Shotgun_shot_soundcue'
	WeaponFireSnd[1] = SoundCue'MBHShotGunModels.Shotgun_shot_soundcue'
	
	AttachmentClass=class'MonsterBountyHunter.MBHShotgunAttachment'
	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Custom

	InventoryGroup=2

	ShotCost(0)=1
	ShotCost(1)=2
	
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashDuration=0.05f
	MuzzleFlashPSCTemplate=ParticleSystem'MBH_MuzzleFlash.MuzzleFlashShotgun'
	WeaponProjectiles(0)=class'MBHProjectile_Shotgun'
	WeaponProjectiles(1)=class'MBHProjectile_Shotgun'

	
	FireInterval(0)=+0.77
	FireInterval(1)=+0.77
	AmmoCount=2
	LockerAmmoCount=2
	MaxAmmoCount=2

	numOfProjectiles=10
	projectileMaxSpread=(Pitch=7000,Yaw=16384,Roll=0)

	weaponHudIndex=1
}
