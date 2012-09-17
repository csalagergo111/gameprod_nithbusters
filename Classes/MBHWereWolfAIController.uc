class MBHWereWolfAIController extends AIController;

var MBHWereWolfPawn thePawn;
var Pawn thePlayer;
var float circlingDegree;
var float circlingDistance;
var float circlingIncrement;
var vector desiredLocation;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	Pawn.SetMovementPhysics();
	if(MBHWereWolfPawn(Pawn) == none)
		`log("Warning: Pawn is not MBHWereWolfAIController!");
	else
		thePawn = MBHWereWolfPawn(Pawn);

	`log("Werewolf Yaw:" @ thePawn.RotationRate.Yaw);

	desiredLocation.Y = 512.0;
	thePawn.RotationRate.Yaw = 100000;
}

function Tick( float DeltaTime )
{
	local PlayerController PC;

	if(thePlayer != none)
	{
		if(thePlayer.Health <= 0)
		{
			thePlayer = none;
			GoToState('');
		}
	}
	else
	{
		foreach LocalPlayerControllers(class'PlayerController', PC)
		{
			if(PC.Pawn != none)
			{
				if(PC.Pawn.Health > 0)
				{
					thePlayer = PC.Pawn;
					GoToState('LookingForPlayer');
				}
			}
		}
	}
}

state LookingForPlayer
{
	function Tick( float DeltaTime )
	{
		Global.Tick(DeltaTime);

		if(thePlayer != none)
			if(VSize(thePawn.Location - thePlayer.Location) < thePawn.FollowDistance)
				GoToState('AttackPlayer');
	}
}

state CirclingPlayer
{
	function Tick( float DeltaTime )
	{
		Global.Tick(DeltaTime);

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
	function CalculateRotationLocation()
	{
		desiredLocation.X = circlingDistance*Cos(circlingDegree*PI/180);
		desiredLocation.Y = circlingDistance*Sin(circlingDegree*PI/180);
	}
	function Attacktimer()
	{
		GoToState('AttackPlayer');
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
		Global.Tick(DeltaTime);

		if(VSize(thePawn.Location - thePlayer.Location) < thePawn.AttackDistance)
		{
			thePlayer.TakeDamage(thePawn.AttackDamage,Self,thePawn.Location,vect(0,0,0),class 'UTDmgType_LinkPlasma');
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