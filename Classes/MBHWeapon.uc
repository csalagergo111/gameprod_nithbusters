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

DefaultProperties
{
	ReloadTime=1.0
}
