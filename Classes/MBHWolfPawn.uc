class MBHWolfPawn extends MBHEnemyPawn
	placeable ClassGroup(MonsterBountyHunter);

// Other wolves closer than this distance will also
// attack the player when this wolf is notified
var() float alarmOthersDistance;
// Array containing reference to all other wolves in
// the level (filled in PostBeginPlay)
var array<MBHWolfPawn> otherWolves;

// bool for checking if the takedamage animation is playing
var bool takingDamage;

// Attack animation
var AnimNodePlayCustomAnim wolfCustomNode;
// Death animation
var AnimNodeCrossfader deathNode;

function PostBeginPlay()
{
	local MBHWolfPawn WP;

	super.PostBeginPlay();

	SpawnDefaultController();

	foreach AllActors(class'MBHWolfPawn', WP)
		otherWolves[otherWolves.length] = WP;
}

simulated event Destroyed()
{
	super.Destroyed();

	wolfCustomNode = None;
	deathNode = None;
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	wolfCustomNode = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('AttackAnim'));
	deathNode = AnimNodeCrossfader(SkelComp.FindAnimNode('DeathNode'));
}

event TakeDamage(int DamageAmount, Controller EventInstigator, 
				vector HitLocation, vector Momentum,
				class<DamageType> DamageType,
				optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	if(!isDead)
	{
		warnOthers();

		if(Health <= 0)
		{
			deathNode.PlayOneShotAnim('MBH_Wolf_Ani_Death',0.1, 0.0, true, 1.0);
			isDead=true;
			ConsoleCommand("SetLevel lvl2");
		}
		else
		{
			wolfCustomNode.PlayCustomAnimByDuration('MBH_Wolf_Ani_Get-Hit', 0.5, 0.1, 0.1, false, true);
			GroundSpeed = 0;
			SetTimer(0.5, false, 'takeDamageEnded');
		}
	}
}

function takeDamageEnded()
{
	GroundSpeed = Default.GroundSpeed;
}

function warnOthers()
{
	local int i;

	isAngry = true;

	for(i = 0; i < otherWolves.length; i++)
	{
		if(otherWolves[i] != none)
			if(VSize(otherWolves[i].Location - Location) < alarmOthersDistance && !otherWolves[i].isAngry)
				otherWolves[i].warnOthers();
	}
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+80.000000
		CollisionRadius=+20.000000
	End Object

	Begin Object Class=SkeletalMeshComponent Name=WofPawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'MBHWolfModel.MBH_Wolf_SkeletalRig'
		AnimSets(0)=AnimSet'MBHWolfModel.WolfAnimSet'
		AnimTreeTemplate=AnimTree'MBHWolfModel.WolfAnimTree'
		HiddenGame=FALSE
		HiddenEditor=FALSE
	End Object

	Mesh=WofPawnSkeletalMesh

	Components.Add(WofPawnSkeletalMesh)
	ControllerClass=class'MonsterBountyHunter.MBHWolfAIController'

	bJumpCapable=false
	bCanJump=false

	GroundSpeed=400.0

	bumpDamage=30.0

	followDistance=512.0
	meleeAttackDistance=100.0
	isAngry=false
	alarmOthersDistance=256.0
}