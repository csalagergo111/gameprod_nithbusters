class MBHWolfAIController extends MBHAIController;

// Reference to casted enemyPawn
var MBHWolfPawn thePawn;
// Temp destination for navigation
var Vector TempDest;

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

// Bool for checking if we're playing an animation
var bool playingAttackAnim;

// how long the wolf should chase the player
var () float chaseTime;
// how long the wolf should circle player before attacking again
// Will be +- 1 second at random
var () float circleTime;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	if(MBHWolfPawn(Pawn) == none)
		`log("Warning: Pawn is not MBHWolfPawn!");
	else
		thePawn = MBHWolfPawn(Pawn);

	thePawn.SetMovementPhysics();

	thePawn.RotationRate.Yaw = 65536;
	thePawn.RotationRate.Pitch = 65536;
	thePawn.RotationRate.Roll = 65536;

	GoToState('LookingForPlayer');
}

function Tick( float DeltaTime )
{
	super.Tick(DeltaTime);
	if(thePlayer == none && !thePawn.isDead)
	{
		GoToState('LookingForPlayer');
	}
	else if(thePawn.isDead)
	{
		GoToState('');
	}
}

function CalculateRotationLocation()
{
	desiredLocation.X = circlingDistance*Cos(circlingDegree*PI/180);
	desiredLocation.Y = circlingDistance*Sin(circlingDegree*PI/180);
}

state LookingForPlayer
{
/*
	event SeePlayer (Pawn Seen)
	{
		super.SeePlayer(Seen);

		thePawn.warnOthers();
		GotoState('AttackPlayer');
	}*/

	function Tick( float DeltaTime )
	{
		super.Tick(DeltaTime);

		if(thePlayer != none)
		{
			if(VSize(thePawn.Location - thePlayer.Location) < thePawn.followDistance || thePawn.isAngry)
			{
				GoToState('AttackPlayer');
				thePawn.warnOthers();
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
		SetTimer((Rand(2)-1)+circleTime, false, 'Attacktimer');
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
	ignores SeePlayer;

	function BeginState(Name PreviousStateName)
	{
		SetTimer(chaseTime,false,'endAttack');
	}

	function Tick( float DeltaTime )
	{
		super.Tick(DeltaTime);

		if(VSize(thePawn.Location - thePlayer.Location) < thePawn.meleeAttackDistance && !playingAttackAnim)
		{
			playingAttackAnim = true;
			ClearTimer('endAttack');
			startAttackAnim();
		}
	}

	function startAttackAnim()
	{
		thePawn.wolfCustomNode.PlayCustomAnimByDuration('MBH_Wolf_Ani_Attack', 0.5, 0.1, 0.1, false, true);
		SetTimer(0.25, false, 'doAttack');
	}

	function doAttack()
	{
		if(VSize(thePawn.Location - thePlayer.Location) < thePawn.meleeAttackDistance)
			thePlayer.TakeDamage(thePawn.bumpDamage,Self,thePawn.Location,vect(0,0,0),class 'UTDmgType_LinkPlasma');
		SetTimer(0.25, false, 'endAttack');
	}

	function endAttack()
	{
		playingAttackAnim = false;
		ClearTimer('endAttack');
		GoToState('CirclingPlayer');
	}

	function bool FindNavMeshPath()
	{
		// Clear cache and constraints (ignore recycling for the moment)
		NavigationHandle.PathConstraintList = none;
		NavigationHandle.PathGoalList = none;

		// Create constraints
		class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle,thePlayer );
		class'NavMeshGoal_At'.static.AtActor( NavigationHandle, thePlayer,32 );

		// Find path
		return NavigationHandle.FindPath();
	}

Begin:
	if(thePlayer != none)
	{
		if(NavigationHandle.ActorReachable(thePlayer))
		{
			//FlushPersistentDebugLines();

			MoveToward(thePlayer,,thePawn.meleeAttackDistance-55);
		}
		else if(FindNavMeshPath())
		{
			NavigationHandle.SetFinalDestination(thePlayer.Location);
			//FlushPersistentDebugLines();
			NavigationHandle.DrawPathCache(,TRUE);
			`log("Found navMesh");
			// move to the first node on the path
			if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
			{
				//DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
				//DrawDebugSphere(TempDest,16,20,255,0,0,true);

				MoveTo( TempDest, thePlayer );
				//`log("Moving to navigation point");
			}
		}
		else
		{
			// Should go back to start here!!!!!
			MoveToward(thePlayer,,thePawn.meleeAttackDistance-55);
		}
	}
	
	GoTo('Begin');
}

defaultproperties
{
	circlingDistance=512
	circlingIncrement=80
	chaseTime=5.0
	circleTime=3.0
	playingAttackAnim=false
}