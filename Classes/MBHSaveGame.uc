class MBHSaveGame extends Actor
	config(MBHSave);

var config bool SavedBefore;
//var config float X;
//var config float Y;
//var config float Z;
var config string Level;
var config int ResWidth;
var config int ResHeight;
var config bool Fullscreen;
var config bool VSync;

function PostBeginPlay()
{
	if (SavedBefore == false)
	{
		SavedBefore = true;
		ResWidth = 1280;
		ResHeight = 720;
		Fullscreen = false;
		VSync = false;
		SaveConfig();
	}

	ConsoleCommand("SCALE SET ResX" @ ResWidth);
	ConsoleCommand("SCALE SET ResY" @ ResHeight);
	ConsoleCommand("SCALE SET Fullscreen" @ Fullscreen);
	ConsoleCommand("SCALE SET UseVSync" @ VSync);

	//ConsoleCommand("SETRES 1280x720x32 f");
}

function SetLevel(string pLevel)
{
	Level = pLevel;
}

function SaveGame()
{
	SaveConfig();
}

function SetFullscreen(bool pFullscreen)
{
	Fullscreen = pFullscreen;
}

function ToggleFullscreen()
{
	Fullscreen = !Fullscreen;
}

function setResolution(int x, int y)
{
	ResWidth = x;
	ResHeight = y;
}

DefaultProperties
{
	SavedBefore=true
	//X=10
	Fullscreen=false
	VSync=false
	ResWidth=1280
	ResHeight=720
}
