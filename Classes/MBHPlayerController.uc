class MBHPlayerController extends UTPlayerController;

var bool bCanPunch;
var () int iMeleeCDTime;

state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

   function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
   {
      if( Pawn == None )
      {
         return;
      }

      if (Role == ROLE_Authority)
      {
         // Update ViewPitch for remote clients
         Pawn.SetRemoteViewPitch( Rotation.Pitch );
      }

      Pawn.Acceleration = NewAccel;

      CheckJumpOrDuck();
   }
}

function UpdateRotation( float DeltaTime )
{
   local Rotator   DeltaRot, newRotation, ViewRotation;

   ViewRotation = Rotation;
   if (Pawn!=none)
   {
      Pawn.SetDesiredRotation(ViewRotation);
   }

   // Calculate Delta to be applied on ViewRotation
   DeltaRot.Yaw   = PlayerInput.aTurn;
   DeltaRot.Pitch   = PlayerInput.aLookUp;

   ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
   SetRotation(ViewRotation);

   NewRotation = ViewRotation;
   NewRotation.Roll = Rotation.Roll;

   if ( Pawn != None )
      Pawn.FaceRotation(NewRotation, deltatime);
}   

function PunchIsReady()
{
	//used by settimer to determine wheter or not the melee attack can be used
	bCanPunch = TRUE;
}

//activates the melee attack function HunterPunch
//once it's run it starts a cooldowntimer which disables the use of
// the melee attackuntill it's finsiehd counting down.
simulated exec function useHunterPunch()
{
	//`log("punch key pressed");

	if(MBHPlayerPawn(Pawn) != none && bCanPunch == TRUE)
	{
		MBHPlayerPawn(Pawn).HunterPunch();
		bCanPunch = FALSE;
		SetTimer(iMeleeCDTime, false, 'PunchIsReady');
	}
}
defaultproperties
{
	bCanPunch=TRUE	
	iMeleeCDTime=5
	//InputClass=class'MonsterBountyHunter.MBHInput'
}

