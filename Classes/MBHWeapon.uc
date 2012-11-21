class MBHWeapon extends UTWeapon
	abstract;

var() float ReloadTime;
var MBHPlayerController thePlayer;
var MBHHud theHud;
var int weaponHudIndex;

simulated function PostBeginPlay()
{
	local MBHPlayerController PC;

	super.PostBeginPlay();

	foreach LocalPlayerControllers(class'MBHPlayerController', PC)
	{
		if(PC.Pawn != none)
		{
			thePlayer = PC;
		}
	}
}

simulated function Activate()
{
	super.Activate();

	thePlayer.activeWeaponIndex = weaponHudIndex;
	thePlayer.activeWeapon = self;
}

simulated function PutDownWeapon()
{
	// Prevent reloading after changing weapon
	ClearReloadTimer();
	super.PutDownWeapon();
}

exec function Reload()
{
	//AddAmmo(MaxAmmoCount);
	if (AmmoCount != MaxAmmoCount && !IsTimerActive('AddMaxAmmo')) 
	{
		ForceEndFire();
		SetTimer(ReloadTime, false, 'AddMaxAmmo');
	}
}

function ClearReloadTimer()
{
	ClearTimer('AddMaxAmmo');
}

function AddMaxAmmo()
{
	AddAmmo(MaxAmmoCount);
}

//simulated function float GetWeaponRating()
//{
//	if( InvManager != None )
//	{
//		return InvManager.GetWeaponRatingFor( Self );
//	}

//	//if( !HasAnyAmmo() )
//	//{
//	//	return -1;
//	//}

//	return 1;
//}

simulated function WeaponEmpty()
{
	// If we were firing, stop
	if ( IsFiring() )
	{
		GotoState('Active');
	}

        // This is the code that switches to another weapon when it has no ammo
	//if ( Instigator != none && Instigator.IsLocallyControlled() )
	//{
	//	Instigator.InvManager.SwitchToBestWeapon( true );
	//}
}

simulated function StartFire(byte FireModeNum)
{
	//IsTimerActive('AddMaxAmmo');

	if( (Instigator == None || !Instigator.bNoWeaponFiring) && IsTimerActive('AddMaxAmmo') == false)
	{
		if( Role < Role_Authority )
		{
			// if we're a client, synchronize server
			ServerStartFire(FireModeNum);
		}

		// Start fire locally
		BeginFire(FireModeNum);
		StopFire(FireModeNum);
	}
}

DefaultProperties
{
	ReloadTime=1.0
	bNeverForwardPendingFire=true
	weaponHudIndex=-1
}
