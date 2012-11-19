class MBHWereWolfPawn extends MBHEnemyPawn
	placeable ClassGroup(MonsterBountyHunter);

var int maxHealth;

function PostBeginPlay()
{
	super(UDKPawn).PostBeginPlay();
	maxHealth = Health;

	Mesh.SetAnimTreeTemplate(AnimTree'MBHTestModels.WereWolf.WereWolfAnimTree');
}

event TakeDamage(int DamageAmount, Controller EventInstigator, 
	vector HitLocation, vector Momentum,
class<DamageType> DamageType,
	optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

	isAngry = true;
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+88.000000
	End Object

	Begin Object Class=SkeletalMeshComponent Name=WofPawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'MBHTestModels.WereWolf.Skeletal_WereWolf'
		AnimSets(0)=AnimSet'MBHTestModels.WereWolf.WereWolfAnimSet'
		HiddenGame=FALSE
		HiddenEditor=FALSE
	End Object

	Mesh=WofPawnSkeletalMesh

	Components.Add(WofPawnSkeletalMesh)
	ControllerClass=class'MonsterBountyHunter.MBHWereWolfAIController'

	GroundSpeed=900;

	bJumpCapable=false
	bCanJump=false

	bumpDamage=100.0
	followDistance=2000.0
	meleeAttackDistance=96.0
	isAngry=false
}