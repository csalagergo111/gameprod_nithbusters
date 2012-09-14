class MBHPlayerPawn extends UTPawn;

var int Pos;
var bool bInvulnerable;
var float InvulnerableTime;

//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
   local UTPlayerController UTPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      UTPC = UTPlayerController(PC);
      if (UTPC != None)
      {
         //set player controller to behind view and make mesh visible
         UTPC.SetBehindView(true);
         SetMeshVisibility(UTPC.bBehindView);
      }
   }
}

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local vector CamStart, HitLocation, HitNormal, CamDirX, CamDirY, CamDirZ, CurrentCamOffset;
	local float DesiredCameraZOffset;

	CamStart = Location;
	
	CurrentCamOffset = CamOffset;

	DesiredCameraZOffset = (Health > 0) ? 1.2 * GetCollisionHeight() + Mesh.Translation.Z : 0.f;
	CameraZOffset = (fDeltaTime < 0.2) ? DesiredCameraZOffset * 5 * fDeltaTime + (1 - 5*fDeltaTime) * CameraZOffset : DesiredCameraZOffset;
   
	if ( Health <= 0 )
	{
		CurrentCamOffset = vect(0,0,0);
		CurrentCamOffset.X = GetCollisionRadius();
	}

	CamStart.Z += CameraZOffset;


	GetAxes(out_CamRot, CamDirX, CamDirY, CamDirZ);
	CamDirX *= CurrentCameraScale;

	if ( (Health <= 0) || bFeigningDeath )
	{
		// adjust camera position to make sure it's not clipping into world
		// @todo fixmesteve.  Note that you can still get clipping if FindSpot fails (happens rarely)
		FindSpot(GetCollisionExtent(),CamStart);
	}
	if (CurrentCameraScale < CameraScale)
	{
		CurrentCameraScale = FMin(Pos, CurrentCameraScale + 500 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}
	else if (CurrentCameraScale > CameraScale)
	{
		CurrentCameraScale = FMax(Pos, CurrentCameraScale - 500 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}

	if (CamDirX.Z > GetCollisionHeight())
	{
		CamDirX *= square(cos(out_CamRot.Pitch * 0.0000958738)); // 0.0000958738 = 2*PI/65536
	}

	out_CamLoc = CamStart - CamDirX*CurrentCamOffset.X + CurrentCamOffset.Y*CamDirY + CurrentCamOffset.Z*CamDirZ;

	if (Trace(HitLocation, HitNormal, out_CamLoc, CamStart, false, vect(12,12,12)) != None)
	{
		out_CamLoc = HitLocation;
	}




	//CameraStart = Location + (VSize(CameraOffset) * normal(vector(Rotation + Rotator(CameraOffset))));

	//CameraDistance = default.CameraDistance; // cameraScale ?
	//do {
	//	CameraLocation = CameraStart - Vector(PawnRotation) * CameraDistance;
	//	CameraDistance -= 1;
	//} until (Trace(HitLocation, HitNormal, CameraLocation, CameraStart, false, CameraFOV,, TRACEFLAG_Blocking) == none);


	//out_CamRot = Rotator(CameraStart - CameraLocation);
	//out_CamLoc = CameraLocation;



	return true;
}



exec function MoveCamera()
{
	if (Pos == 10)
	{
		Pos = 50;
	}
	else
	{
		Pos = 10;
	}  
}

event Bump(Actor Other, PrimitiveComponent OtherComp, vector HitNormal)
{
	if(MBHWolfPawn(Other) != none && !bInvulnerable)
	{
		bInvulnerable = true;
		SetTimer(InvulnerableTime, false, 'EndInvulnerable');
		TakeDamage(MBHWolfPawn(Other).BumpDamage, none, Location, vect(0,0,0), class 'UTDmgType_LinkPlasma');
	}
}

function EndInvulnerable()
{
	bInvulnerable = false;
}

function HunterPunch()	
{
	local MBHWolfPawn enemyPawn;


	foreach	AllActors(class'MBHWolfPawn', enemyPawn)
	{
		`log("Enemylocation"@enemyPawn.Location);
		`log("Playerlocation"@Location);
		if(VSize(enemyPawn.Location - Location) <= 100)
		{

			`log("Inrange");
			enemyPawn.TakeDamage(100,none,enemyPawn.Location,vect(0,0,0), class 'UTDmgType_LinkPlasma');
		}
	}

}
defaultproperties
{
	Pos=50
	InvulnerableTime=0.6
}