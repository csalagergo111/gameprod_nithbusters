class MBHWolfPawn extends MBHEnemyPawn
	placeable ClassGroup(MonsterBountyHunter);

// Other wolves closer than this distance will also
// attack the player when this wolf is notified
var() float alarmOthersDistance;
// Array containing reference to all other wolves in
// the level (filled in PostBeginPlay)
var array<MBHWolfPawn> otherWolves;

function PostBeginPlay()
{
	local MBHWolfPawn WP;

	super.PostBeginPlay();

	foreach AllActors(class'MBHWolfPawn', WP)
		otherWolves[otherWolves.length] = WP;
}

event TakeDamage(int DamageAmount, Controller EventInstigator, 
				vector HitLocation, vector Momentum,
				class<DamageType> DamageType,
				optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	
	warnOthers();
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

	bumpDamage=5.0
	followDistance=512.0
	meleeAttackDistance=150.0
	isAngry=false
	alarmOthersDistance=256.0
}