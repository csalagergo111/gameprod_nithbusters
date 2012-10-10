class MBHWolfAIController extends MBHAIController;

// Reference to casted enemyPawn
var MBHWolfPawn thePawn;

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
	function Tick( float DeltaTime )
	{
		super.Tick(DeltaTime);

		if(VSize(thePawn.Location - thePlayer.Location) < thePawn.meleeAttackDistance)
		{
			thePlayer.TakeDamage(thePawn.bumpDamage,Self,thePawn.Location,vect(0,0,0),class 'UTDmgType_LinkPlasma');
		}
	}
Begin:
	if(thePlayer != none)
	{
		MoveToward(thePlayer,,thePawn.meleeAttackDistance-55);
	}
	GoTo('Begin');
}

defaultproperties
{
}