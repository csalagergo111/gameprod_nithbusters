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
	//SaveConfig();
	ConsoleCommand("SCALE SET UseVSync true");
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

function NewGame()
{
	StaticSaveConfig();
}

//DefaultProperties
//{
//	SavedBefore=true
//	//X=10
//	Fullscreen=false
//	VSync=false
//	ResWidth=1280
//	ResHeight=720
//}
