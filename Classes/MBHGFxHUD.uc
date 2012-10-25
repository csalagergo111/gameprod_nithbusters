class MBHGFxHUD extends GFxMoviePlayer;

//var Pawn thePlayer;



function Init (optional LocalPlayer LocPlay)
{
	super.Init (LocPlay);
	Start();
	Advance(0.f);
}

function TickHUD() //MBHHUDWrappers Postrender makes this happen every tick
{

	/*local PlayerController PC;
	local int ammoC;
	local Weapon weaponT;
	local String weaponName;
	local int playerHealth;
	PC = GetPC();
	playerHealth = PC.Pawn.Health;
	//ammoCount = PC.Pawn.Weapon.AmmoCount;
	//ammoCount = UTPlayerController(PC).UTPawn.UTWeapon.AmmoCount;
	//weaponType = PC.Pawn.Weapon;
	//ammoC = UTWeapon(weaponType).getAmmoCount();
	weaponT = (GetPC()).Pawn.Weapon;

	
	//weaponType = MBHWeapon(PawnOwner.Weapon);
	//ammoC = MBHWeapon(PawnOwner.Weapon).AmmoCount;
	ammoC =0;
	SetVariableNumber("AmmoCount", 10);
	SetVariableString("WeaponType","weaponT");*/
}

defaultproperties
{
	//Swf asset
	//MovieInfo=SwfMovie'MBHHUD.MBHHUD'
	//bDisplayWithHudOff=false
	//bIgnoreMouseInput=true
	//bAutoPlay=true
}