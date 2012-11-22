class MBHGame extends UTGame;

//var DLLDeviceInfo DeviceInfo;

var MBHSaveGame SaveGame;

var string res;

var array<string> resarray;

event InitGame( string options, out string errorMessage )
{
    super.InitGame(options, errorMessage);

    //DeviceInfo = new class'DLLDeviceInfo';
    //DeviceInfo.EnumDeviceModes();

	SaveGame = spawn(class'MBHSaveGame');

	//SaveGame.Level

	//ConsoleCommand("Open" @ SaveGame.Level);

	//res = ConsoleCommand("DUMPAVAILABLERESOLUTIONS", false);

	//`log(res);

	//ParseStringIntoArray(res, resarray, "\n", true);

	//`log(resarray.Length);
}

exec function SetLevel(string level)
{
	SaveGame.SetLevel(level);
	SaveGame.SaveGame();

	//`log("-----" @ SaveGame.ResWidth @ SaveGame.ResHeight);
}

exec function OpenLevel()
{
	//ConsoleCommand("Open" @ SaveGame.Level $ "?Game=MonsterBountyHunter.MBHGame");

	`log("-----" @ SaveGame.Level);

	ConsoleCommand("Open" @ SaveGame.Level);
}

exec function NewGame()
{
	SaveGame.NewGame();
}

defaultProperties
{
	PlayerControllerClass=class'MonsterBountyHunter.MBHPlayerController'
	DefaultPawnClass=class'MonsterBountyHunter.MBHPlayerPawn'
	DefaultInventory(0)=class'MonsterBountyHunter.MBHWeapon_Pistol'
	DefaultInventory(1)=class'MonsterBountyHunter.MBHWeapon_Shotgun'
	DefaultInventory(2)=class'MonsterBountyHunter.MBHWeapon_Crossbow'
	HUDType=class'MonsterBountyHunter.MBHHud'
	bUseClassicHUD=true
	bGivePhysicsGun=false
}