class MBHFaraoAIController extends MBHAIController;

var MBHFaraoPawn thePawn;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	if(MBHFaraoPawn(Pawn) == none)
		`log("Warning: Pawn is not MBHFaraoPawn!");
	else
		thePawn = MBHFaraoPawn(Pawn);

	thePawn.SetPhysics(PHYS_Flying);

	//thePawn.RotationRate.Yaw = 100000;
}

DefaultProperties
{
}
