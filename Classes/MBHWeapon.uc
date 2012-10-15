class MBHWeapon extends UTWeapon
	abstract;

var() float ReloadTime;

exec function Reload()
{
	//AddAmmo(MaxAmmoCount);

	ForceEndFire();
	SetTimer(ReloadTime, false, 'AddMaxAmmo');
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


DefaultProperties
{
	ReloadTime=1.0

	bNeverForwardPendingFire=true
}
