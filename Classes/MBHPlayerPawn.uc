class MBHPlayerPawn extends UTPawn
	placeable ClassGroup(MonsterBountyHunter);

var int Pos;
var bool bInvulnerable;
var () float InvulnerableTime;
var bool bRegenerating;
var () float regenDelay;
var () float regenAmount;
var float floatHealth;
var () float fMeleeArc;
var () int iMeleeDmg;
var () int iMeleeRange;

// Attack animation
var AnimNodePlayCustomAnim IdleWeaponType;
var UDKAnimBlendByWeapon IdleFire;
var AnimNodePlayCustomAnim RunningWeaponType;
var AnimNodePlayCustomAnim JumpNode;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

simulated event Destroyed()
{
	super.Destroyed();

	IdleWeaponType = None;
	IdleFire = None;
	RunningWeaponType = None;
	JumpNode = None;
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	IdleWeaponType = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('IdleWeaponType'));
	if(IdleWeaponType != none)
		IdleWeaponType.PlayCustomAnim('Hunter_idle_cycle',1.0, 0.1, 0.1, true, true);

	IdleFire = UDKAnimBlendByWeapon(SkelComp.FindAnimNode('IdleFire'));

	JumpNode = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('JumpNode'));

	RunningWeaponType = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('RunningWeaponType'));
	if(RunningWeaponType != none)
		RunningWeaponType.PlayCustomAnim('Hunter_idle_cycle',1.0, 0.1, 0.1, true, true);
}

function bool DoJump( bool bUpdating )
{
	local bool didJump;
	didJump = super.DoJump(bUpdating);
	if(didJump && JumpNode != none)
		JumpNode.PlayCustomAnim('Hunter_jump',1.0,0.0,0.0,false,true);
	return didJump;
}

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

	DesiredCameraZOffset = (Health > 0) ? 1.6 * GetCollisionHeight() + Mesh.Translation.Z : 0.f;
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



//exec function MoveCamera()
//{
//	if (Pos == 10)
//	{
//		Pos = 50;
//	}
//	else
//	{
//		Pos = 10;
//	}  
//}

event TakeDamage(int DamageAmount, Controller EventInstigator, 
	vector HitLocation, vector Momentum,
class<DamageType> DamageType,
	optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(!bInvulnerable)
	{
		bInvulnerable = true;
		SetTimer(InvulnerableTime, false, 'EndInvulnerable');

		bRegenerating = false;
		SetTimer(regenDelay, false, 'startRegenerating');

		super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	}
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	if(bRegenerating)
	{
		if (Health < HealthMax)
		{
			floatHealth+=regenAmount*DeltaTime;
			while(floatHealth > 1.0)
			{
				floatHealth-=1.0;
				Health+=1;
			}
		}
		if(Health > HealthMax)
			Health=HealthMax;
	}
}

function EndInvulnerable()
{
	bInvulnerable = false;
}

function startRegenerating()
{
	bRegenerating = true;
}

//melee attack function, launched by exec useHunterPunch
//the melee attack deals damage to any actor in a small arc in front of the player
//for every actor of the enemy type it calculates its location and orientation in comparison
//to the player, if it's within range and vision it executes the TakeDamage function that deals damage to the enemy actor.
function HunterPunch()	
{
	local MBHEnemyPawn enemyPawn;
	local float fInFront;

	foreach	AllActors(class'MBHEnemyPawn', enemyPawn)
	{
		fInFront = Normal(enemyPawn.Location - Location ) dot vector(Rotation);

		//`log("Enemylocation"@enemyPawn.Location);
		//`log("Playerlocation"@Location);
		//`log("Dotproduct"@fInFront);
		if((VSize(enemyPawn.Location - Location) <= iMeleeRange) && (fInFront >= fMeleeArc))
		{

			`log("Inrange");
			enemyPawn.TakeDamage(iMeleeDmg,none,enemyPawn.Location,vect(0,0,0), class 'UTDmgType_LinkPlasma');
		}
	}
}

exec function StartSprint()
{
	//ConsoleCommand("Sprint");
	Groundspeed = 700;
	//bSprinting = true;
	//StopFiring();
}

exec function StopSprint()
{
	Groundspeed = default.GroundSpeed;
}

exec function CrossbowZoom()
{
	`log("------------------------CrossbowZoom");
	if (Weapon.Class == class'MonsterBountyHunter.MBHWeapon_Crossbow')
	{
		`log("---------------------------It works---------");
	}
}

defaultproperties
{
	Pos=50
	InvulnerableTime=0.6
	fMeleeArc=0.907
	iMeleeDmg=100
	iMeleeRange=100
	maxMultiJump=0
	multiJumpRemaining=0
	InventoryManagerClass=class'MonsterBountyHunter.MBHInventoryManager'

	bRegenerating=false
	regenDelay=5.0
	regenAmount=5.0

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0030.000000
		CollisionHeight=+040.000000
	End Object
	CylinderComponent = CollisionCylinder

	SpawnSound=none

	//CamOffset=(X=20.0,Y=30.0,Z=-1.0)
}