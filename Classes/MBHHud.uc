class MBHHud extends UTHUD;

var CanvasIcon AimIcon;
var CanvasIcon crossbowFull;
var CanvasIcon crossbowEmpty;
var CanvasIcon pistolFull;
var CanvasIcon pistolEmpty;
var CanvasIcon shotGunFull;
var CanvasIcon shotGunEmpty;
var Texture2D HealthOverlay;
var MBHPlayerController thePlayer;
var Font hudFont;
var string hudText;
var float hudTextWidth, hudTextHeight;
var float textPosX, textPosY, textScale, textVisibleTime;
var float hudOffsetX, hudOffsetY;


var GFxMoviePlayer MBHPauseMenuMovie;

// ShowMenu()

//function TogglePauseMenu()
//{
//    if ( PauseMenuMovie != none && PauseMenuMovie.bMovieIsOpen )
//	{
		
//		if( !WorldInfo.IsPlayInMobilePreview() )
//		{
//			//PauseMenuMovie.PlayCloseAnimation();
//		}
//		else
//		{
//			// On mobile previewer, close right away
//			CompletePauseMenuClose();
//		}
//	}
//	else
//    {
//		CloseOtherMenus();

//        PlayerOwner.SetPause(True);

//        if (PauseMenuMovie == None)
//        {
//	        PauseMenuMovie = new class'GFxMoviePlayer';
//            PauseMenuMovie.MovieInfo = SwfMovie'MBH.PauseMenu';
//            PauseMenuMovie.bEnableGammaCorrection = FALSE;
//			PauseMenuMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
//            PauseMenuMovie.SetTimingMode(TM_Real);
//        }

//		SetVisible(false);
//        PauseMenuMovie.Start();
//        //PauseMenuMovie.PlayOpenAnimation();
//		PauseMenuMovie.Advance(0);

//		// Do not prevent 'escape' to unpause if running in mobile previewer
//		if( !WorldInfo.IsPlayInMobilePreview() )
//		{
//			PauseMenuMovie.AddFocusIgnoreKey('Escape');
//		}
//    }
//}

function TogglePauseMenu()
{
	if (MBHPauseMenuMovie != none && MBHPauseMenuMovie.bMovieIsOpen)
	{
		PlayerOwner.SetPause(False);
		MBHPauseMenuMovie.Close(False);  // Keep the Pause Menu loaded in memory for reuse.
		SetVisible(True);
	}
	else
	{
		PlayerOwner.SetPause(True);

		if (MBHPauseMenuMovie == None)
		{
			MBHPauseMenuMovie = new class'GFxMoviePlayer';
			MBHPauseMenuMovie.MovieInfo = SwfMovie'MBH.PauseMenu'; // Replace 'UDKHud.udk_pausemenu' with a reference to your own pause menu swf asset
			MBHPauseMenuMovie.bEnableGammaCorrection = False;
			MBHPauseMenuMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
			MBHPauseMenuMovie.SetTimingMode(TM_Real);
			MBHPauseMenuMovie.bCaptureMouseInput = true;
		}

		SetVisible(false);
		MBHPauseMenuMovie.Start();
		MBHPauseMenuMovie.Advance(0);

		// Do not prevent 'escape' to unpause if running in mobile previewer
		if( !WorldInfo.IsPlayInMobilePreview() )
		{
			MBHPauseMenuMovie.AddFocusIgnoreKey('Escape');
		}
	}
	
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if(MBHPlayerController(PlayerOwner) == none)
		`log("Warning: Player is not MBHPlayerPawn");
	else
		thePlayer = MBHPlayerController(PlayerOwner);

	clearText();
}

function DisplayHit(vector HitDir, int Damage, class<DamageType> damageType)
{

}

function DrawGameHud()
{
	Canvas.Reset();

	if(thePlayer.activeWeapon != none)
	{
		// Draw aim cross
		Canvas.DrawIcon(AimIcon, Canvas.ClipX/2-AimIcon.UL/2, Canvas.ClipY/2-AimIcon.VL/2, 1);

		switch(thePlayer.activeWeaponIndex)
		{
		case 0:
			DrawPistolHud();
			break;
		case 1:
			DrawShotgunHud();
			break;
		case 2:
			DrawCrossbowHud();
			break;
		}

		// Draw red health overlay covering the whole screen
		Canvas.SetDrawColor(255,255,255,255-(float(thePlayer.Pawn.Health)/float(thePlayer.Pawn.HealthMax)*255.0));
		Canvas.SetPos(0,0);
		Canvas.DrawTileStretched(HealthOverlay,
			Canvas.ClipX, Canvas.ClipY, 0, 0,
			HealthOverlay.SizeX, HealthOverlay.SizeY);

		// Draw info text
		Canvas.Font = hudFont;
		Canvas.StrLen(hudText, hudTextWidth, hudTextHeight);
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.SetPos(textPosX/100*Canvas.ClipX - hudTextWidth/2,
			textPosY/100*Canvas.ClipY - hudTextHeight/2);
		Canvas.DrawText(hudText,,textScale,textScale);
	}
}

function DrawPistolHud()
{
	Canvas.DrawIcon(pistolEmpty,
		hudOffsetX,
		Canvas.ClipY-pistolEmpty.VL-hudOffsetY);

	if(thePlayer.activeWeapon.AmmoCount > 5)
	{
		Canvas.DrawIcon(pistolFull,
			hudOffsetX+11,
			Canvas.ClipY-pistolEmpty.VL-hudOffsetY+20);
	}
	if(thePlayer.activeWeapon.AmmoCount > 4)
	{
		Canvas.DrawIcon(pistolFull,
			hudOffsetX+11,
			Canvas.ClipY-pistolEmpty.VL-hudOffsetY+48);
	}
	if(thePlayer.activeWeapon.AmmoCount > 3)
	{
		Canvas.DrawIcon(pistolFull,
			hudOffsetX+33,
			Canvas.ClipY-pistolEmpty.VL-hudOffsetY+61);
	}
	if(thePlayer.activeWeapon.AmmoCount > 2)
	{
		Canvas.DrawIcon(pistolFull,
			hudOffsetX+56,
			Canvas.ClipY-pistolEmpty.VL-hudOffsetY+48);
	}
	if(thePlayer.activeWeapon.AmmoCount > 1)
	{
		Canvas.DrawIcon(pistolFull,
			hudOffsetX+56,
			Canvas.ClipY-pistolEmpty.VL-hudOffsetY+20);
	}
	if(thePlayer.activeWeapon.AmmoCount > 0)
	{
		Canvas.DrawIcon(pistolFull,
			hudOffsetX+33,
			Canvas.ClipY-pistolEmpty.VL-hudOffsetY+8);
	}
}

function DrawShotgunHud()
{
	
	Canvas.DrawIcon(shotGunEmpty,
					hudOffsetX,
					Canvas.ClipY-shotGunEmpty.VL-hudOffsetY);

	if(thePlayer.activeWeapon.AmmoCount > 1)
	{
		Canvas.DrawIcon(shotGunFull,
						hudOffsetX,
						Canvas.ClipY-shotGunEmpty.VL-hudOffsetY);
	}
	if(thePlayer.activeWeapon.AmmoCount > 0)
	{
		Canvas.DrawIcon(shotGunFull,
						hudOffsetX + shotGunFull.UL + 2,
						Canvas.ClipY-shotGunFull.VL-hudOffsetY);
	}
}

function DrawCrossbowHud()
{
	Canvas.DrawIcon(crossbowEmpty,
					hudOffsetX,
					Canvas.ClipY-crossbowEmpty.VL-hudOffsetY);
	if(thePlayer.activeWeapon.AmmoCount > 0)
	{
		Canvas.DrawIcon(crossbowFull,
						hudOffsetX+1,
						Canvas.ClipY-crossbowFull.VL-hudOffsetY);
	}
}

exec function setText(string screenText, float xPos, float yPos, float _textScale, int visibleTime)
{
	hudText = screenText;
	textPosX = xPos;
	textPosY = yPos;
	textScale = _textScale;
	if(visibleTime > 0)
		SetTimer(visibleTime,false, 'clearTextTimer');
}

exec function clearText()
{
	setText("", 0.0, 0.0, 1.0,0);
}

function clearTextTimer()
{
	clearText();
}

DefaultProperties
{
	AimIcon=(Texture=Texture2D'MBHHudAssets.HUD',U=192,V=71,UL=20,VL=20)
	
	crossbowFull=(Texture=Texture2D'MBHHudAssets.HUD',U=27,V=0,UL=27,VL=120)
	crossbowEmpty=(Texture=Texture2D'MBHHudAssets.HUD',U=0,V=0,UL=26,VL=119)
	
	pistolFull=(Texture=Texture2D'MBHHudAssets.HUD',U=193,V=49,UL=21,VL=22)
	pistolEmpty=(Texture=Texture2D'MBHHudAssets.HUD',U=54,V=0,UL=88,VL=91)
	
	shotGunFull=(Texture=Texture2D'MBHHudAssets.HUD',U=143,V=49,UL=49,VL=49)
	shotGunEmpty=(Texture=Texture2D'MBHHudAssets.HUD',U=143,V=0,UL=99,VL=48)
	
	HealthOverlay=Texture2D'MBHHudAssets.Health'
	hudFont=Font'MBHHudAssets.Hudfont'

	hudOffsetX=10.0
	hudOffsetY=10.0
}