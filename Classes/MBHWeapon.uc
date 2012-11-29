class MBHWeapon extends UTWeapon
	abstract;

var() float ReloadTime;
var MBHPlayerController thePlayer;
var MBHPlayerPawn thePlayerPawn;
var MBHHud theHud;
var int weaponHudIndex;
//var bool animatingFire;
var name fireSequence;
var name startReloadSequence;
var name reloadingSequence;

simulated function PostBeginPlay()
{
	local MBHPlayerController PC;

	super.PostBeginPlay();

	foreach LocalPlayerControllers(class'MBHPlayerController', PC)
	{
		if(PC.Pawn != none)
		{
			thePlayer = PC;
			thePlayerPawn = MBHPlayerPawn(PC.Pawn);
		}
	}

	fireSequence='none';
	startReloadSequence='none';
	reloadingSequence='none';
}

simulated function Activate()
{
	super.Activate();

	thePlayerPawn.stopLongIdle();

	thePlayer.activeWeaponIndex = weaponHudIndex;
	thePlayer.activeWeapon = self;
	switch(weaponHudIndex)
	{
	case 0:
		thePlayerPawn.WeaponType.SetCustomAnim('Hunter_idle_aim_revolver');
		thePlayerPawn.twoHandedBlend.SetBlendTarget(0.0, 0.1);
		thePlayerPawn.oneHandedBlend.SetBlendTarget(1.0, 0.1);
		break;
	case 1:
		thePlayerPawn.WeaponType.SetCustomAnim('Hunter_idle_aim_shotgun');
		thePlayerPawn.twoHandedBlend.SetBlendTarget(1.0, 0.1);
		thePlayerPawn.oneHandedBlend.SetBlendTarget(0.0, 0.1);
		break;
	case 2:
		thePlayerPawn.WeaponType.SetCustomAnim('Hunter_idle_aim_crossbow');
		thePlayerPawn.twoHandedBlend.SetBlendTarget(1.0, 0.1);
		thePlayerPawn.oneHandedBlend.SetBlendTarget(0.0, 0.1);
		break;
	}
}

simulated function PutDownWeapon()
{
	// Prevent reloading after changing weapon
	ClearReloadTimer();
	super.PutDownWeapon();
}

simulated function FireAmmunition()
{
	if(!IsTimerActive('AddMaxAmmo') && !thePlayer.bIsPunching && !thePlayerPawn.stunnedByHit && AmmoCount > 0)
	{
		switch(weaponHudIndex)
		{
		case 0:
			thePlayerPawn.stopLongIdle();
			thePlayerPawn.FireOneHanded.AnimStopFire();
			thePlayerPawn.FireTwoHanded.AnimStopFire();
			break;
		case 1:
		case 2:
			thePlayerPawn.stopLongIdle();
			thePlayerPawn.FireOneHanded.AnimStopFire();
			thePlayerPawn.FireTwoHanded.AnimStopFire();
			thePlayerPawn.FireTwoHanded.AnimFire(fireSequence,false,1.0);
			break;
		}
		super.FireAmmunition();
	}
}

exec function Reload()
{
	//AddAmmo(MaxAmmoCount);
	if (!thePlayer.bIsPunching && AmmoCount != MaxAmmoCount && !IsTimerActive('AddMaxAmmo')) 
	{
		ForceEndFire();
		thePlayerPawn.stopLongIdle();

		thePlayerPawn.FireTwoHanded.AnimFire(startReloadSequence,false, 1.0);
		SetTimer(0.45, false, 'playReloadingAnim');

		SetTimer(ReloadTime, false, 'AddMaxAmmo');
	}
}

function playReloadingAnim()
{
	thePlayerPawn.FireTwoHanded.AnimFire(reloadingSequence, true, 1.0);
}

function ClearReloadTimer()
{
	thePlayerPawn.FireTwoHanded.AnimStopFire();
	ClearTimer('AddMaxAmmo');
}

function AddMaxAmmo()
{
	thePlayerPawn.FireTwoHanded.AnimFire(startReloadSequence, false, -1.0);
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

/*
simulated function StartFire(byte FireModeNum)
{
	//IsTimerActive('AddMaxAmmo');
	super.StartFire(FireModeNum);

	if( (Instigator == None || !Instigator.bNoWeaponFiring) && !IsTimerActive('AddMaxAmmo') &&
		 !thePlayer.bIsPunching && !thePlayerPawn.stunnedByHit && AmmoCount > 0 && !animatingFire)
	{
		switch(weaponHudIndex)
		{
		/ *case 0:
			if(CurrentFireMode == 0)
			{
// 				//thePlayerPawn.IdleFire.AnimStopFire();
// 				thePlayerPawn.IdleFire.AnimFire('Hunter_idle_fire_revolver',false,1.0);
				//SetTimer(0.45, false, 'endFireAnim');
				//animatingFire = true;
			}
			break;* /
		case 1:
			thePlayerPawn.IdleFire.AnimStopFire();
			thePlayerPawn.IdleFire.AnimFire('Hunter_idle_fire_shotgun',false,1.0);
			SetTimer(FireInterval[FireModeNum], false, 'endFireAnim');
			animatingFire = true;
			break;
		case 2:
			if(CurrentFireMode == 0)
			{
				thePlayerPawn.IdleFire.AnimStopFire();
				thePlayerPawn.IdleFire.AnimFire('Hunter_idle_fire_crossbow',false,1.0);
				SetTimer(FireInterval[FireModeNum], false, 'endFireAnim');
				animatingFire = true;
				break;
			}
		}

		// Start fire locally
		BeginFire(FireModeNum);
		StopFire(FireModeNum);

	}
}*/

/*
function endFireAnim()
{
	//thePlayerPawn.IdleFire.AnimStopFire();
	animatingFire = false;
}*/

DefaultProperties
{
	ReloadTime=1.0
	bNeverForwardPendingFire=true
	weaponHudIndex=-1
}
