class MBHPlayerController extends UTPlayerController;

var bool bCanPunch;
var () int iMeleeCDTime;
var int activeWeaponIndex;
var MBHWeapon activeWeapon;
var MBHPlayerPawn thePlayer;

var SoundCue soundBlade;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	Pawn.Mesh.SetSkeletalMesh(SkeletalMesh'MBHPlayerModels.Player.Hunter_skeletal_mesh');
	bNoCrosshair = true;
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	thePlayer = MBHPlayerPawn(self.Pawn);
	if(thePlayer == none)
		`log("The player is not MBHPlayerPawn!");

	self.Pawn.Mesh.SetSkeletalMesh(SkeletalMesh'MBHPlayerModels.Player.Hunter_skeletal_mesh');

	self.Pawn.Mesh.SetMaterial(0,Material'MBHPlayerModels.Player.Hunter_diffuse_Mat');

	self.Pawn.Mesh.SetPhysicsAsset(PhysicsAsset'CTF_Flag_IronGuard.Mesh.S_CTF_Flag_IronGuard_Physics' );

	self.Pawn.Mesh.AnimSets[0]=AnimSet'MBHPlayerModels.Player.PlayerAnimSet';

	self.Pawn.Mesh.SetAnimTreeTemplate(AnimTree'MBHPlayerModels.Player.PlayerAnimTree');
}

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

	if(bCanPunch && !thePlayer.stunnedByHit)
	{
		thePlayer.stopLongIdle();
		thePlayer.twoHandedBlend.SetBlendTarget(1.0, 0.0);
		thePlayer.HunterPuncNode.PlayCustomAnim('Hunter_melee_attack', 1.0, 0.1, 0.05, false, true);
		PlaySound(soundBlade);
		bCanPunch = false;
		thePlayer.bIsPunching = true;
		SetTimer(0.37, false, 'doPunchDamage');
		SetTimer(iMeleeCDTime, false, 'PunchIsReady');
		SetTimer(0.8333, false, 'endPunch');
	}
}

function doPunchDamage()
{
	thePlayer.HunterPunch();
}

function endPunch()
{
	thePlayer.bIsPunching = false;
	if(thePlayer.oneHandedBlend.Child2Weight > 0.0)
		thePlayer.twoHandedBlend.SetBlendTarget(0.0, 0.1);
}

exec function MBHSetFullscreen()
{
	//ConsoleCommand("SCALE TOGGLE Fullscreen");
	//ConsoleCommand("SETRES 1280x720x32 f");

	ConsoleCommand("SCALE SET ResX 1920");
	ConsoleCommand("SCALE SET ResY 1080");
	ConsoleCommand("SCALE TOGGLE Fullscreen");
	ConsoleCommand("SCALE SET UseVSync true");
}


exec function MBHVSync()
{
	ConsoleCommand("SCALE TOGGLE UseVSync");
}

exec function MBHSetResolution(int x, int y)
{
	ConsoleCommand("SCALE SET ResX" @ x);
	ConsoleCommand("SCALE SET ResY" @ y);
}


defaultproperties
{
	bCanPunch=TRUE	
	iMeleeCDTime=2
	//InputClass=class'MonsterBountyHunter.MBHInput'

	bBehindView=true
	activeWeaponIndex=0

	soundBlade=SoundCue'MBHPlayerModels.SteamBladeSoundCue'
}

