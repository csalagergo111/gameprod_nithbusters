class MBHWolfAIController extends MBHAIController;

// Reference to casted enemyPawn
var MBHWolfPawn thePawn;
var Vector TempDest;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	if(MBHWolfPawn(Pawn) == none)
		`log("Warning: Pawn is not MBHWolfPawn!");
	else
		thePawn = MBHWolfPawn(Pawn);

	thePawn.SetMovementPhysics();

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

state LookingForPlayer
{
	event SeePlayer (Pawn Seen)
	{
		super.SeePlayer(Seen);

		thePawn.warnOthers();
		GotoState('AttackPlayer');
	}

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

state AttackPlayer
{
	ignores SeePlayer;
	function Tick( float DeltaTime )
	{
		super.Tick(DeltaTime);

		if(VSize(thePawn.Location - thePlayer.Location) < thePawn.meleeAttackDistance)
		{
			thePlayer.TakeDamage(thePawn.bumpDamage,Self,thePawn.Location,vect(0,0,0),class 'UTDmgType_LinkPlasma');
		}
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
			FlushPersistentDebugLines();

			MoveToward(thePlayer,,thePawn.meleeAttackDistance-55);
		}
		else if(FindNavMeshPath())
		{
			NavigationHandle.SetFinalDestination(thePlayer.Location);
			FlushPersistentDebugLines();
			NavigationHandle.DrawPathCache(,TRUE);
			`log("Found navMesh");
			// move to the first node on the path
			if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
			{
				DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
				DrawDebugSphere(TempDest,16,20,255,0,0,true);

				MoveTo( TempDest, thePlayer );
				`log("Moving to navigation point");
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

}