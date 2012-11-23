class MBHWereWolfAIController extends MBHAIController;

// Reference to casted enemyPawn
var MBHWereWolfPawn thePawn;

// Variables for making the werewolf circling the player:
// Current degree from player position
var float circlingDegree;
// Distance from player when circling
var float circlingDistance;
// How many degrees to increase circlingDegree with
var float circlingIncrement;
// Location we want to move to calculated from circlingDegree
// and circlingDistance (convert polar to cartesian coordinates)
var vector desiredLocation;

var bool playingAttack;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	if(MBHWereWolfPawn(Pawn) == none)
		`log("Warning: Pawn is not MBHWereWolfAIController!");
	else
		thePawn = MBHWereWolfPawn(Pawn);

	thePawn.SetMovementPhysics();

	thePawn.RotationRate.Yaw = 65536;
	thePawn.RotationRate.Pitch = 65536;
	thePawn.RotationRate.Roll = 65536;

	GoToState('LookingForPlayer');
}

function Tick( float DeltaTime )
{
	super.Tick(DeltaTime);
	if(thePlayer == none)
	{
		GoToState('LookingForPlayer');
	}
}

function CalculateRotationLocation()
{
	desiredLocation.X = circlingDistance*Cos(circlingDegree*PI/180);
	desiredLocation.Y = circlingDistance*Sin(circlingDegree*PI/180);
}

state LookingForPlayer
{
	function Tick( float DeltaTime )
	{
		super.Tick(DeltaTime);

		if(thePlayer != none)
		{
			if(VSize(thePawn.Location - thePlayer.Location) < thePawn.followDistance || thePawn.isAngry)
			{
				GoToState('AttackPlayer');
			}
		}
		else
			thePawn.Health = thePawn.maxHealth;
	}
Begin:
	MoveTo(thePawn.startPosition);
}

state CirclingPlayer
{
	function Tick( float DeltaTime )
	{
		super.Tick(DeltaTime);

		circlingDegree+=circlingIncrement*DeltaTime;
		while(circlingDegree > 360)
		{
			circlingDegree-=360;
		}
		CalculateRotationLocation();
	}
	function BeginState(Name PreviousStateName)
	{
		if(Rand(2) == 1)
			circlingIncrement=-circlingIncrement;
		CalculateRotationLocation();
		SetTimer(Rand(5)+5,false, 'Attacktimer');
	}
	function Attacktimer()
	{
		GoToState('AttackPlayer');
	}
	function EndState(name NextStateName)
	{
		ClearTimer('Attacktimer');
	}
Begin:
	if(thePlayer != none)
		MoveTo( desiredLocation+thePlayer.Location );
	GoTo('Begin');
}

state AttackPlayer
{
	function BeginState(Name PreviousStateName)
	{
		SetTimer(2,false,'endAttack');
	}
	function Tick( float DeltaTime )
	{
		super.Tick(DeltaTime);

		if(VSize(thePawn.Location - thePlayer.Location) < thePawn.meleeAttackDistance && !playingAttack)
		{
			ClearTimer('endAttack');
			`log("Close enough..");
			playingAttack=true;
			thePawn.GroundSpeed=0;
			SetTimer(0.25, false, 'startSlap');
		}
	}

	function startSlap()
	{
		thePawn.attackNode.AnimFire('Werewolf_attack_right_hand', false, 1.0);
		SetTimer(0.14, false, 'doDamage');
	}

	function doDamage()
	{
		if(VSize(thePawn.Location - thePlayer.Location) < thePawn.meleeAttackDistance)
		{
			thePlayer.TakeDamage(thePawn.bumpDamage,Self,thePawn.Location,vect(0,0,0),class 'UTDmgType_LinkPlasma');
		}
		SetTimer(0.5, false, 'endAttack');
	}

	function endAttack()
	{
		ClearTimer('endAttack');
		playingAttack=false;
		thePawn.GroundSpeed = thePawn.default.GroundSpeed;
		GoToState('CirclingPlayer');
	}
	function EndState(name NextStateName)
	{
		ClearTimer('endAttack');
		ClearTimer('doDamage');
	}
Begin:
	if(thePlayer != none)
	{
		MoveToward(thePlayer);
		endAttack();
	}
	GoTo('Begin');
}

DefaultProperties
{
	circlingDistance=512
	circlingIncrement=80
	playingAttack=false
}