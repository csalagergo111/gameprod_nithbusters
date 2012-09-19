class MBHAIController extends AIController;

// Reference to the current player
var Pawn thePlayer;
// Needed to reset the isAngry variable
var MBHEnemyPawn abstractPawn;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	Pawn.SetMovementPhysics();

	if(MBHEnemyPawn(Pawn) == none)
		`log("Warning: Pawn is not MBHEnemyPawn!");
	else
		abstractPawn = MBHEnemyPawn(Pawn);
}

function Tick( float DeltaTime )
{
	local PlayerController PC;

	if(thePlayer != none)
	{
		if(thePlayer.Health <= 0)
		{
			thePlayer = none;
		}
	}
	if(thePlayer == none)
	{
		abstractPawn.isAngry = false;
		foreach LocalPlayerControllers(class'PlayerController', PC)
		{
			if(PC.Pawn != none)
			{
				if(PC.Pawn.Health > 0)
					thePlayer = PC.Pawn;
			}
		}
	}
}

DefaultProperties
{
}