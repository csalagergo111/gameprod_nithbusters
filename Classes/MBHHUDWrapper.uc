class MBHHUDWrapper extends UTHUDBase;

var MBHGFxHUD HUDMovie;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	HudMovie = new class'MBHGFxHUD';
	HudMovie.SetTimingMode(TM_Real);
	HudMovie.Init();
}

event PostRender()
{
	//local int i;	
	super.PostRender();
	
	if (bShowHud && bEnableActorOverlays)
	{
		DrawHud();
	}
	
	if (HudMovie!=none)
	{
		HudMovie.TickHUD();
	}

}

defaultproperties
{
	
}