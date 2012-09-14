class MBHWereWolfAIController extends AIController;

var MBHWereWolfPawn thePawn;
var Pawn thePlayer;
var float circlingDegree;
var float circlingDistance;
var vector desiredLocation;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	Pawn.SetMovementPhysics();
	if(MBHWereWolfPawn(Pawn) == none)
		`log("Warning: Pawn is not MBHWereWolfAIController!");
	else
		thePawn = MBHWereWolfPawn(Pawn);
}

function Tick( float DeltaTime )
{
	local PlayerController PC;

	if(thePlayer == none)
	{
		foreach LocalPlayerControllers(class'PlayerController', PC)
		{
			if(PC.Pawn != none)
			{
				if(PC.Pawn.Health > 0)
				{
					thePlayer = PC.Pawn;
					GoToState('CirclingPlayer');
				}
			}
		}
	}
	else
	{
	}
}

state CirclingPlayer
{
Begin:
	if(thePlayer != none)
		MoveTo( desiredLocation+thePlayer.Location );
	circlingDegree+=10;
}

DefaultProperties
{
	circlingDistance=512;
}