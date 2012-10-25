class MBHHud extends UTHUD;

var CanvasIcon AimIcons[3];
var int AimIndex;
var MBHPlayerPawn thePlayer;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if(MBHPlayerPawn(PlayerOwner.Pawn) == none)
		`log("Warning: Player is not MBHPlayerPawn");
	else
		thePlayer = MBHPlayerPawn(PlayerOwner.Pawn);
}

function DrawGameHud()
{
	Canvas.DrawIcon(AimIcons[AimIndex],
					Canvas.ClipX/2-AimIcons[AimIndex].UL/2,
					Canvas.ClipY/2-AimIcons[AimIndex].VL/2, 1);
	//PlayerOwner.
}

DefaultProperties
{
	AimIcons(0)=(Texture=Texture2D'MBHHudAssets.crosshair_pistol',U=0,V=0,UL=64,VL=64)
	AimIcons(1)=(Texture=Texture2D'MBHHudAssets.crosshair_shotgun',U=0,V=0,UL=64,VL=64)
	AimIcons(2)=(Texture=Texture2D'MBHHudAssets.crosshair_crossbow',U=0,V=0,UL=64,VL=64)
	AimIndex=0
}
