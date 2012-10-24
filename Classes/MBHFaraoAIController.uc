class MBHFaraoAIController extends MBHAIController;

var MBHFaraoPawn thePawn;
var array<MBHFaraoNode> movementNodes;
var MBHFaraoNode theNextNode, centerNode;
var MBHFaraoWeapon theWeapon;
var int nextNodeIndex, attackCounter;
var float maxHealth;

var int lastTeleportDegree;

// Variables for making the farao circle the middle of the map:
// Current degree from center position
var float circlingDegree;
// Distance from center when circling
var float circlingDistance;
// How many degrees to increase circlingDegree with
var float circlingIncrement;
// Location we want to move to calculated from circlingDegree
// and circlingDistance (convert polar to cartesian coordinates)
var vector desiredLocation;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	local MBHFaraoNode FN;	

	super.Possess(inPawn, bVehicleTransition);

	if(MBHFaraoPawn(Pawn) == none)
		`log("Warning: Pawn is not MBHFaraoPawn!");
	else
	{
		thePawn = MBHFaraoPawn(Pawn);

		thePawn.SetPhysics(PHYS_Flying);

		foreach AllActors(class'MBHFaraoNode', FN)
		{
			movementNodes[movementNodes.length] = FN;
			if(FN.index == -1)
			{
				centerNode = FN;
				`log("Centernode set!");
			}
		}

		nextNodeIndex = -1;

		thePawn.RotationRate.Yaw = 65536;
		thePawn.RotationRate.Pitch = 65536;
		thePawn.RotationRate.Roll = 65536;

		theWeapon = Spawn(class'MBHFaraoWeapon',thePawn);
		theWeapon.GiveTo(thePawn);

		maxHealth = thePawn.Health;

		GotoState('MoveToNextNode');
	}
}

function CalculateRotationLocation()
{
	desiredLocation.X = circlingDistance*Cos(circlingDegree*PI/180);
	desiredLocation.Y = circlingDistance*Sin(circlingDegree*PI/180);
}

state MoveToNextNode
{
	function BeginState(Name PreviousStateName)
	{
		local int i;

		if(nextNodeIndex < movementNodes.length-2)
			nextNodeIndex++;
		else
			nextNodeIndex = 0;

		for(i = 0; i < movementNodes.length; i++)
		{
			if(nextNodeIndex == movementNodes[i].index)
			{
				theNextNode = movementNodes[i];
				break;
			}
		}
	}

	function Tick( float DeltaTime )
	{
		super.Tick(DeltaTime);
	}
Begin:
	if(thePlayer != none)
	{
		MoveTo(movementNodes[nextNodeIndex].Location,thePlayer);
		GotoState('AttackPlayer');
	}
	else
		Sleep(1);
		goto('Begin');
}

state CircleCenter
{
	function BeginState(Name PreviousStateName)
	{
		CalculateRotationLocation();
		SetTimer(Rand(5)+5,false, 'Attacktimer');
	}
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
	function Attacktimer()
	{
		GoToState('AttackPlayer');
	}
	function EndState(name NextStateName)
	{
		ClearTimer('Attacktimer');
	}
Begin:
	MoveTo( desiredLocation+centerNode.Location, thePlayer );
	GoTo('Begin');
}

state circleTeleport
{
	function BeginState(Name PreviousStateName)
	{
		CalculateRotationLocation();
		SetTimer(Rand(5)+5,false, 'Attacktimer');
	}
	function Tick( float DeltaTime )
	{
		super.Tick(DeltaTime);

		circlingDegree+=circlingIncrement*DeltaTime;

		if(circlingDegree > 10000)
		{
			circlingDegree=0;
		}

		if(circlingDegree > lastTeleportDegree+180)
		{
			circlingDegree += Rand(91)+90;
			lastTeleportDegree = circlingDegree;
			CalculateRotationLocation();
			thePawn.SetLocation(desiredLocation+centerNode.Location);
		}

		CalculateRotationLocation();
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
	MoveTo( desiredLocation+centerNode.Location, thePlayer );
	GoTo('Begin');
}

state AttackPlayer
{
	function BeginState(Name PreviousStateName)
	{
		thePawn.AirSpeed = 0;
		Focus = thePlayer;
	}
	function Tick( float DeltaTime )
	{
		super.Tick(DeltaTime);

		if(thePlayer != none)
		{
			if(isAimingAt(thePlayer,0.95))
			{
				if(thePawn.Health < maxHealth/100*30)
					stageThreeFire();
				else if(thePawn.Health < maxHealth/100*66)
					stageTwoFire();
				else
					stageOneFire();
			}
		}
	}

	function stageOneFire()
	{
		if(attackCounter < 2)
		{
			theWeapon.CurrentFireMode=0;
			attackCounter++;
		}
		else
		{
			theWeapon.CurrentFireMode=1;
			attackCounter=0;
		}
		theWeapon.ProjectileFire();

		GotoState('MoveToNextNode');
	}

	function stageTwoFire()
	{
		local MBHScorpionPawn spawnPawn;
		if(attackCounter < 2)
		{
			theWeapon.CurrentFireMode=0;
			theWeapon.ProjectileFire();

			attackCounter++;
		}
		else if(attackCounter < 3)
		{
			spawnPawn = Spawn(class'MBHScorpionPawn',,,thePawn.Location+vect(-50,0,-200));
			MBHAIController(spawnPawn.Controller).thePlayer = thePlayer;
			spawnPawn.warnOthers();
			spawnPawn = Spawn(class'MBHScorpionPawn',,,thePawn.Location+vect(50,0,-200));
			MBHAIController(spawnPawn.Controller).thePlayer = thePlayer;
			spawnPawn.warnOthers();
			spawnPawn = Spawn(class'MBHScorpionPawn',,,thePawn.Location+vect(0,0,-200));
			MBHAIController(spawnPawn.Controller).thePlayer = thePlayer;
			spawnPawn.warnOthers();

			attackCounter++;
		}
		else
		{
			theWeapon.CurrentFireMode=1;
			theWeapon.ProjectileFire();

			attackCounter=0;
		}

		GotoState('CircleCenter');
	}

	function stageThreeFire()
	{
		local MBHScorpionPawn spawnPawn;
		if(attackCounter < 2)
		{
			theWeapon.CurrentFireMode=0;
			theWeapon.ProjectileFire();

			attackCounter++;
		}
		else if(attackCounter < 3)
		{
			spawnPawn = Spawn(class'MBHScorpionPawn',,,thePawn.Location+vect(-50,0,-200));
			MBHAIController(spawnPawn.Controller).thePlayer = thePlayer;
			spawnPawn.warnOthers();
			spawnPawn = Spawn(class'MBHScorpionPawn',,,thePawn.Location+vect(50,0,-200));
			MBHAIController(spawnPawn.Controller).thePlayer = thePlayer;
			spawnPawn.warnOthers();
			spawnPawn = Spawn(class'MBHScorpionPawn',,,thePawn.Location+vect(0,0,-200));
			MBHAIController(spawnPawn.Controller).thePlayer = thePlayer;
			spawnPawn.warnOthers();

			attackCounter++;
		}
		else
		{
			theWeapon.CurrentFireMode=1;
			theWeapon.ProjectileFire();

			attackCounter=0;
		}

		GotoState('circleTeleport');
	}

	function EndState(name NextStateName)
	{
		thePawn.AirSpeed = 1000;
	}
}

DefaultProperties
{
	attackCounter=0
	circlingDistance=1500
	circlingIncrement=20
	lastTeleportDegree=0
}
