class MBHFaraoAIController extends MBHAIController;

var MBHFaraoPawn thePawn;
var array<MBHFaraoNode> movementNodes;
var MBHFaraoNode theNextNode, centerNode;
var MBHFaraoWeapon theWeapon;
var int nextNodeIndex, attackCounter;
var float maxHealth;
var bool summoningScorps;
var bool attackStarted;

var int lastTeleportDegree;

// Variables for making the farao circle the middle of the map:
// Current degree from center position
var float circlingDegree;
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

		GotoState('LookingForPlayer');
	}
}

function CalculateRotationLocation()
{
	desiredLocation.X = thePawn.circlingDistance*Cos(circlingDegree*PI/180);
	desiredLocation.Y = thePawn.circlingDistance*Sin(circlingDegree*PI/180);
}

function Tick( float DeltaTime )
{
	super.Tick(DeltaTime);
	if(thePlayer == none)
	{
		GoToState('LookingForPlayer');
		summoningScorps = false;
		attackStarted = false;
		nextNodeIndex = -1;
	}
}

state LookingForPlayer
{
	function Tick( float DeltaTime )
	{
		super.Tick(DeltaTime);

		if(thePlayer != none)
		{
			GoToState('MoveToNextNode');
		}
		else
			thePawn.Health = thePawn.maxHealth;
	}
Begin:
	MoveTo(thePawn.startPosition);
}

state MoveToNextNode
{
	function BeginState(Name PreviousStateName)
	{
		local int i;
		thePawn.isAngry = true;

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

		circlingDegree+=thePawn.circlingSpeed*DeltaTime;
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

		circlingDegree+=thePawn.circlingSpeed*DeltaTime;

		if(circlingDegree > 1000)
			circlingDegree=0;

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
// IKKE OVER HER!!§!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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

		if(thePlayer != none && !summoningScorps)
		{
			if(isAimingAt(thePlayer,0.95) && !attackStarted)
			{
				attackStarted = true;
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
			thePawn.faraoCustomNode.PlayCustomAnim('Farao_attack', 1.0, 0.1, 0.1, false, true);
			SetTimer(1.0, false, 'smallFire');
			SetTimer(1.3333, false, 'nextNode');
			attackCounter++;
		}
		else
		{
			thePawn.faraoCustomNode.PlayCustomAnim('Farao_attack', 1.0, 0.1, 0.1, false, true);
			SetTimer(1.0, false, 'bigFire');
			SetTimer(1.3333, false, 'nextNode');
			attackCounter=0;
		}

		
	}

	function stageTwoFire()
	{
		if(attackCounter < 2)
		{
			thePawn.faraoCustomNode.PlayCustomAnim('Farao_attack', 1.0, 0.1, 0.1, false, true);
			SetTimer(1.0, false, 'smallFire');
			SetTimer(1.3333, false, 'cirlceCenterNode');

			attackCounter++;
		}
		else if(attackCounter < 3)
		{
			thePawn.faraoCustomNode.PlayCustomAnim('MBH_Farao_Ani_Scarab-Spawn', 1.0, 0.1, 0.1, false, true);
			summoningScorps = true;
			SetTimer(0.8, false, 'summonScorps');
		}
		else
		{
			thePawn.faraoCustomNode.PlayCustomAnim('Farao_attack', 1.0, 0.1, 0.1, false, true);
			SetTimer(1.0, false, 'bigFire');
			SetTimer(1.3333, false, 'cirlceCenterNode');
		}

	}

	function stageThreeFire()
	{
		if(attackCounter < 2)
		{
			thePawn.faraoCustomNode.PlayCustomAnim('Farao_attack', 1.0, 0.1, 0.1, false, true);
			SetTimer(1.0, false, 'smallFire');
			SetTimer(1.3333, false, 'circleTeleport');

			attackCounter++;
		}
		else if(attackCounter < 3)
		{
			thePawn.faraoCustomNode.PlayCustomAnim('MBH_Farao_Ani_Scarab-Spawn', 1.0, 0.1, 0.1, false, true);
			summoningScorps = true;
			SetTimer(0.8, false, 'summonScorps');
		}
		else
		{
			thePawn.faraoCustomNode.PlayCustomAnim('Farao_attack', 1.0, 0.1, 0.1, false, true);
			SetTimer(1.0, false, 'bigFire');
			SetTimer(1.3333, false, 'circleTeleport');

			attackCounter=0;
		}

	}

	function EndState(name NextStateName)
	{
		thePawn.AirSpeed = 1000;
	}

	function smallFire()
	{
		theWeapon.CurrentFireMode=0;
		theWeapon.ProjectileFire();
	}

	function bigFire()
	{
		theWeapon.CurrentFireMode=1;
		theWeapon.ProjectileFire();
	}

	function nextNode()
	{
		attackStarted = false;
		GotoState('MoveToNextNode');
	}

	function cirlceCenterNode()
	{
		attackStarted = false;
		GotoState('CircleCenter');
	}

	function circleAndTeleport()
	{
		attackStarted = false;
		GotoState('circleTeleport');
	}

	function summonScorps()
	{
		local MBHScorpionPawn spawnPawn;
		spawnPawn = Spawn(class'MBHScorpionPawn',,,thePawn.Location+vect(-50,0,-200));
		MBHAIController(spawnPawn.Controller).thePlayer = thePlayer;
		spawnPawn.warnOthers();
		spawnPawn = Spawn(class'MBHScorpionPawn',,,thePawn.Location+vect(50,0,-200));
		MBHAIController(spawnPawn.Controller).thePlayer = thePlayer;
		spawnPawn.warnOthers();
		spawnPawn = Spawn(class'MBHScorpionPawn',,,thePawn.Location+vect(0,0,-200));
		MBHAIController(spawnPawn.Controller).thePlayer = thePlayer;
		spawnPawn.warnOthers();
		SetTimer(0.8667, false, 'endSummoning');
	}

	function endSummoning()
	{
		summoningScorps = false;
		attackCounter++;
		circleAndTeleport();
	}
}

DefaultProperties
{
	attackStarted=false
	attackCounter=0
	lastTeleportDegree=0
	summoningScorps=false
}
