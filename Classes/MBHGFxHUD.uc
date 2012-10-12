class MBHGFxHUD extends GFxMoviePlayer;

function Init (optional LocalPlayer LocPlay)
{
	super.Init (LocPlay);
	Start();
	Advance(0.f);
}

defaultproperties
{
	//Swf asset
	MovieInfo=SwfMovie'MBHHudTest.bIn.MBHHudThing'
	bDisplayWithHudOff=false
	bIgnoreMouseInput=true
	bAutoPlay=true
}