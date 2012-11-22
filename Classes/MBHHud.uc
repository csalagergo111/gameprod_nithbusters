class MBHHud extends UTHUD;

var CanvasIcon AimIcons[3];
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
		Canvas.DrawIcon(AimIcons[thePlayer.activeWeaponIndex],
			Canvas.ClipX/2-AimIcons[thePlayer.activeWeaponIndex].UL/2,
			Canvas.ClipY/2-AimIcons[thePlayer.activeWeaponIndex].VL/2, 1);

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
		Canvas.ClipX-pistolEmpty.UL-hudOffsetX,
		Canvas.ClipY-pistolEmpty.VL-hudOffsetY);

	if(thePlayer.activeWeapon.AmmoCount > 5)
	{
		Canvas.DrawIcon(pistolFull,
			Canvas.ClipX-pistolEmpty.UL-hudOffsetX+10,
			Canvas.ClipY-pistolEmpty.VL-hudOffsetY+19);
	}
	if(thePlayer.activeWeapon.AmmoCount > 4)
	{
		Canvas.DrawIcon(pistolFull,
			Canvas.ClipX-pistolEmpty.UL-hudOffsetX+10,
			Canvas.ClipY-pistolEmpty.VL-hudOffsetY+47);
	}
	if(thePlayer.activeWeapon.AmmoCount > 3)
	{
		Canvas.DrawIcon(pistolFull,
			Canvas.ClipX-pistolEmpty.UL-hudOffsetX+32,
			Canvas.ClipY-pistolEmpty.VL-hudOffsetY+60);
	}
	if(thePlayer.activeWeapon.AmmoCount > 2)
	{
		Canvas.DrawIcon(pistolFull,
			Canvas.ClipX-pistolEmpty.UL-hudOffsetX+55,
			Canvas.ClipY-pistolEmpty.VL-hudOffsetY+47);
	}
	if(thePlayer.activeWeapon.AmmoCount > 1)
	{
		Canvas.DrawIcon(pistolFull,
			Canvas.ClipX-pistolEmpty.UL-hudOffsetX+55,
			Canvas.ClipY-pistolEmpty.VL-hudOffsetY+19);
	}
	if(thePlayer.activeWeapon.AmmoCount > 0)
	{
		Canvas.DrawIcon(pistolFull,
			Canvas.ClipX-pistolEmpty.UL-hudOffsetX+32,
			Canvas.ClipY-pistolEmpty.VL-hudOffsetY+7);
	}
}

function DrawShotgunHud()
{
	
	Canvas.DrawIcon(shotGunEmpty,
					Canvas.ClipX-shotGunEmpty.UL-hudOffsetX,
					Canvas.ClipY-shotGunEmpty.VL-hudOffsetY);

	if(thePlayer.activeWeapon.AmmoCount > 1)
	{
		Canvas.DrawIcon(shotGunFull,
						Canvas.ClipX-shotGunEmpty.UL-hudOffsetX,
						Canvas.ClipY-shotGunEmpty.VL-hudOffsetY);
	}
	if(thePlayer.activeWeapon.AmmoCount > 0)
	{
		Canvas.DrawIcon(shotGunFull,
						Canvas.ClipX-shotGunFull.UL-hudOffsetX,
						Canvas.ClipY-shotGunFull.VL-hudOffsetY);
	}
}

function DrawCrossbowHud()
{
	Canvas.DrawIcon(crossbowEmpty,
					Canvas.ClipX-crossbowEmpty.UL-hudOffsetX,
					Canvas.ClipY-crossbowEmpty.VL-hudOffsetY);
	if(thePlayer.activeWeapon.AmmoCount > 0)
	{
		Canvas.DrawIcon(crossbowFull,
						Canvas.ClipX-crossbowFull.UL-hudOffsetX,
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
	AimIcons(0)=(Texture=Texture2D'MBHHudAssets.HUD',U=188,V=46,UL=20,VL=20)
	AimIcons(1)=(Texture=Texture2D'MBHHudAssets.HUD',U=188,V=46,UL=20,VL=20)
	AimIcons(2)=(Texture=Texture2D'MBHHudAssets.HUD',U=188,V=46,UL=20,VL=20)
	
	crossbowFull=(Texture=Texture2D'MBHHudAssets.HUD',U=16,V=0,UL=13,VL=108)
	crossbowEmpty=(Texture=Texture2D'MBHHudAssets.HUD',U=0,V=0,UL=14,VL=108)
	
	pistolFull=(Texture=Texture2D'MBHHudAssets.HUD',U=166,V=46,UL=21,VL=22)
	pistolEmpty=(Texture=Texture2D'MBHHudAssets.HUD',U=31,V=0,UL=85,VL=89)
	
	shotGunFull=(Texture=Texture2D'MBHHudAssets.HUD',U=117,V=46,UL=44,VL=46)
	shotGunEmpty=(Texture=Texture2D'MBHHudAssets.HUD',U=117,V=0,UL=96,VL=46)
	
	HealthOverlay=Texture2D'MBHHudAssets.Health'
	hudFont=Font'MBHHudAssets.Hudfont'

	hudOffsetX=10.0
	hudOffsetY=10.0
}