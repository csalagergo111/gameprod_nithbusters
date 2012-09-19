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

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	if(MBHWereWolfPawn(Pawn) == none)
		`log("Warning: Pawn is not MBHWereWolfAIController!");
	else
		thePawn = MBHWereWolfPawn(Pawn);
	
	GoToState('LookingForPlayer');

	thePawn.RotationRate.Yaw = 100000;
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
	function Tick( float DeltaTime )
	{
		super.Tick(DeltaTime);

		if(VSize(thePawn.Location - thePlayer.Location) < thePawn.meleeAttackDistance)
		{
			thePlayer.TakeDamage(thePawn.bumpDamage,Self,thePawn.Location,vect(0,0,0),class 'UTDmgType_LinkPlasma');
			GoToState('CirclingPlayer');
		 }
	}
Begin:
	if(thePlayer != none)
	{
		MoveToward(thePlayer);
		GoToState('CirclingPlayer');
	}
	GoTo('Begin');
}

DefaultProperties
{
	circlingDistance=512
	circlingIncrement=80
}