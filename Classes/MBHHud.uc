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


var GFxMoviePlayer PauseMenuMovie;

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
	if (PauseMenuMovie != none && PauseMenuMovie.bMovieIsOpen)
	{
		PlayerOwner.SetPause(False);
		PauseMenuMovie.Close(False);  // Keep the Pause Menu loaded in memory for reuse.
		SetVisible(True);
	}
	else
	{
		PlayerOwner.SetPause(True);

		if (PauseMenuMovie == None)
		{
			PauseMenuMovie = new class'GFxMoviePlayer';
			PauseMenuMovie.MovieInfo = SwfMovie'MBH.PauseMenu'; // Replace 'UDKHud.udk_pausemenu' with a reference to your own pause menu swf asset
			PauseMenuMovie.bEnableGammaCorrection = False;
			PauseMenuMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
			PauseMenuMovie.SetTimingMode(TM_Real);
			PauseMenuMovie.bCaptureMouseInput = true;
		}

		SetVisible(false);
		PauseMenuMovie.Start();
		PauseMenuMovie.Advance(0);

		// Do not prevent 'escape' to unpause if running in mobile previewer
		if( !WorldInfo.IsPlayInMobilePreview() )
		{
			PauseMenuMovie.AddFocusIgnoreKey('Escape');
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
	local int i,j;
	local CanvasIcon drawCan;

	j=0;
	for(i=0; i < 6; i++)
	{
		if(thePlayer.activeWeapon.AmmoCount < i+1)
		{
			drawCan = pistolEmpty;
		}
		else
		{
			drawCan = pistolFull;
		}
		Canvas.DrawIcon(drawCan,
						Canvas.ClipX/2 - drawCan.UL*1 - drawCan.UL*i + drawCan.UL*j,
						Canvas.ClipY/2 - drawCan.VL*3 + drawCan.VL*i);
		if(i > 1)
			j++;
		if(i > 2)
			j++;
	}
}

function DrawShotgunHud()
{
	local int i;
	local CanvasIcon drawCan;

	for(i=0; i < 2; i++)
	{
		if(thePlayer.activeWeapon.AmmoCount < i+1)
		{
			drawCan = pistolEmpty;
		}
		else
		{
			drawCan = pistolFull;
		}
		Canvas.DrawIcon(drawCan,
						Canvas.ClipX/2-(i*drawCan.UL),
						Canvas.ClipY/2);
	}
}

function DrawCrossbowHud()
{
	if(thePlayer.activeWeapon.AmmoCount > 0)
	{
		Canvas.DrawIcon(crossbowFull,
						Canvas.ClipX/2-crossbowFull.UL/2,
						Canvas.ClipY/2-crossbowFull.VL/2);
	}
	else
	{
		Canvas.DrawIcon(crossbowEmpty,
						Canvas.ClipX/2-crossbowEmpty.UL/2,
						Canvas.ClipY/2-crossbowEmpty.VL/2);
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
	AimIcons(0)=(Texture=Texture2D'MBHHudAssets.HUD',U=0,V=0,UL=71,VL=69)
	AimIcons(1)=(Texture=Texture2D'MBHHudAssets.HUD',U=0,V=0,UL=71,VL=69)
	AimIcons(2)=(Texture=Texture2D'MBHHudAssets.HUD',U=0,V=0,UL=71,VL=69)
	
	crossbowFull=(Texture=Texture2D'MBHHudAssets.HUD',U=0,V=126,UL=71,VL=57)
	crossbowEmpty=(Texture=Texture2D'MBHHudAssets.HUD',U=0,V=0,UL=121,VL=863)
	
	pistolFull=(Texture=Texture2D'MBHHudAssets.HUD',U=71,V=0,UL=21,VL=19)
	pistolEmpty=(Texture=Texture2D'MBHHudAssets.HUD',U=71,V=19,UL=21,VL=19)
	
	shotGunFull=(Texture=Texture2D'MBHHudAssets.HUD',U=71,V=0,UL=21,VL=19)
	shotGunEmpty=(Texture=Texture2D'MBHHudAssets.HUD',U=71,V=0,UL=21,VL=19)
	
	HealthOverlay=Texture2D'MBHHudAssets.Health'
	hudFont=Font'MBHHudAssets.Hudfont'
}