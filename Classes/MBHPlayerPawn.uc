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
var bool stunnedByHit;
var bool isDead;
var bool isSprinting;

// Jump variables
var bool jumpUpdating;

// animation
var AnimNodePlayCustomAnim WeaponType;
var AnimNodeCrossfader JumpNode;
var AnimNodePlayCustomAnim LongIdle;
var UDKAnimBlendByWeapon FireOneHanded;
var UDKAnimBlendByWeapon FireTwoHanded;
var AnimNodeBlend DuckNode;
var AnimNodeBlend DuckNodeIdle;
var AnimNodeCrossfader deathNode;
var AnimNodeBlendPerBone twoHandedBlend;
var AnimNodeBlendPerBone oneHandedBlend;
var AnimNodeBlend SprintNode;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

simulated event Destroyed()
{
	super.Destroyed();

	FireOneHanded = None;
	FireTwoHanded = None;
	WeaponType = None;
	JumpNode = None;
	deathNode = None;
	DuckNode = None;
	DuckNodeIdle = None;
	LongIdle = None;
	twoHandedBlend = None;
	oneHandedBlend = None;
	SprintNode = None;
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	
	FireOneHanded = UDKAnimBlendByWeapon(SkelComp.FindAnimNode('FireOneHanded'));
	FireOneHanded.AnimStopFire();

	FireTwoHanded = UDKAnimBlendByWeapon(SkelComp.FindAnimNode('FireTwoHanded'));
	FireTwoHanded.AnimStopFire();

	JumpNode = AnimNodeCrossfader(SkelComp.FindAnimNode('JumpNode'));

	DuckNode = AnimNodeBlend(SkelComp.FindAnimNode('DuckNode'));
	DuckNodeIdle = AnimNodeBlend(SkelComp.FindAnimNode('DuckNodeIdle'));

	deathNode = AnimNodeCrossfader(SkelComp.FindAnimNode('deathNode'));

	LongIdle = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('LongIdle'));

	WeaponType = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('WeaponType'));
	if(WeaponType != none)
		WeaponType.PlayCustomAnim('Hunter_idle_aim_crossbow',1.0, 0.1, 0.1, true, true);

	twoHandedBlend = AnimNodeBlendPerBone(SkelComp.FindAnimNode('twoHandedRunningBlend'));

	oneHandedBlend = AnimNodeBlendPerBone(SkelComp.FindAnimNode('oneHandedRunningBlend'));

	SprintNode = AnimNodeBlend(SkelComp.FindAnimNode('SprintNode'));
}


simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	GotoState('Dying');
	bReplicateMovement = false;
	bTearOff = true;
	Velocity += TearOffMomentum;
	SetDyingPhysics();
	bPlayedDeath = true;

	KismetDeathDelayTime = default.KismetDeathDelayTime + WorldInfo.TimeSeconds;
}

function bool DoJump( bool bUpdating )
{
	if (bJumpCapable && !bIsCrouched && !bWantsToCrouch && (Physics == PHYS_Walking || Physics == PHYS_Ladder || Physics == PHYS_Spider))
	{
		stopLongIdle();
		JumpNode.PlayOneShotAnim('Hunter_jump', 0.1, 0.1, false, 1.0);
		SetTimer(0.24, false, 'jumpTimer');
		return true;
	}
	return false;
}

function jumpTimer()
{
	if ( Physics == PHYS_Spider )
		Velocity = JumpZ * Floor;
	else if ( Physics == PHYS_Ladder )
		Velocity.Z = 0;
	else if ( bIsWalking )
		Velocity.Z = Default.JumpZ;
	else
		Velocity.Z = JumpZ;
	if (Base != None && !Base.bWorldGeometry && Base.Velocity.Z > 0.f)
	{
		Velocity.Z += Base.Velocity.Z;
	}
	SetPhysics(PHYS_Falling);
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

event TakeDamage(int DamageAmount, Controller EventInstigator, 
	vector HitLocation, vector Momentum,
class<DamageType> DamageType,
	optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(!bInvulnerable && !isDead)
	{
		stopLongIdle();
		FireTwoHanded.AnimFire('Hunter_get_hit', false, 1.0);
		SetTimer(0.6667, false, 'endStun');
		stunnedByHit = true;
		bInvulnerable = true;
		SetTimer(InvulnerableTime, false, 'EndInvulnerable');

		bRegenerating = false;
		SetTimer(regenDelay, false, 'startRegenerating');

		super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

		if(Health <= 0)
		{
			isDead=true;
			deathNode.PlayOneShotAnim('Hunter_death', 0.1, 0.0, true, 1.0);
		}
	}
}

function endStun()
{
	stunnedByHit = false;
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
	if(Velocity.X != 0 || Velocity.Y != 0 || Velocity.Z != 0)
		stopLongIdle();

	if(!IsTimerActive('startLongIdle') && !LongIdle.bIsPlayingCustomAnim)
		SetTimer(6.0, false, 'startLongIdle');
}

function startLongIdle()
{
	SetWeaponAttachmentVisibility(false);
	LongIdle.PlayCustomAnim('Hunter_idle_cycle_LONG', 1.0, 0.2, 0.2, true, true);
}

function stopLongIdle()
{
	SetWeaponAttachmentVisibility(true);
	LongIdle.StopCustomAnim(0.1);
	ClearTimer('startLongIdle');
}

function ShouldCrouch( bool bCrouch )
{
	super.ShouldCrouch(bCrouch);

	if(bCrouch)
	{
		stopLongIdle();
		DuckNode.SetBlendTarget(1.0, 0.1);
		DuckNodeIdle.SetBlendTarget(1.0, 0.1);
	}
	else
	{
		DuckNode.SetBlendTarget(0.0, 0.1);
		DuckNodeIdle.SetBlendTarget(0.0, 0.1);
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
			return;
		}
	}
}

exec function StartSprint()
{
	SprintNode.SetBlendTarget(1.0, 0.1);
	isSprinting = true;
	Groundspeed = 700;
}

exec function StopSprint()
{
	SprintNode.SetBlendTarget(0.0, 0.1);
	isSprinting = false;
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

	stunnedByHit=false
	isSprinting=false

	SpawnSound=none

	SoundGroupClass=none

	CamOffset=(X=5.0,Y=-50.0,Z=0.0)
}