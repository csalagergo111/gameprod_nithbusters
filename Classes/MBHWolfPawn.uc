class MBHWolfPawn extends UDKPawn
	placeable ClassGroup(MonsterBountyHunter);

var() float BumpDamage;
var() float FollowDistance;
var() float AttackDistance;
var() float alarmOthersDistance;
var vector startPosition;
var bool isAngry;
var array<MBHWolfPawn> otherWolves;

function PostBeginPlay()
{
	local MBHWolfPawn WP;
	super.PostBeginPlay();
	startPosition = Location;

	foreach AllActors(class'MBHWolfPawn', WP)
		otherWolves[otherWolves.length] = WP;
}

event TakeDamage(int DamageAmount, Controller EventInstigator, 
				vector HitLocation, vector Momentum,
				class<DamageType> DamageType,
				optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	if(Health <= 0)
		Destroy();
	isAngry = true;
	
	warnOthers();
}

function warnOthers()
{
	local int i;
	for(i = 0; i < otherWolves.length; i++)
	{
		if(VSize(otherWolves[i].Location - Location) < alarmOthersDistance)
			otherWolves[i].isAngry = true;
	}
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+44.000000
	End Object

	Begin Object Class=SkeletalMeshComponent Name=WofPawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		HiddenGame=FALSE
		HiddenEditor=FALSE
	End Object

	Mesh=WofPawnSkeletalMesh

	Components.Add(WofPawnSkeletalMesh)
	ControllerClass=class'MonsterBountyHunter.MBHWolfAIController'

	bJumpCapable=false
	bCanJump=false

	GroundSpeed=400.0
	BumpDamage=5.0
	FollowDistance=512.0
	AttackDistance=96.0
	alarmOthersDistance=256.0;
	isAngry=false
}