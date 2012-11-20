class MBHMummyPawn extends MBHEnemyPawn
	placeable ClassGroup(MonsterBountyHunter);

function PostBeginPlay()
{
	super.PostBeginPlay();

	SpawnDefaultController();
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
		CollisionHeight=+80.000000
		CollisionRadius=+10.000000
	End Object

	Begin Object Class=SkeletalMeshComponent Name=MummyPawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'MBHTestModels.Mummy.MBH_Mummy_Skeletal-Mesh'
		AnimSets(0)=AnimSet'MBHTestModels.Mummy.MummyAnimSet'
		AnimTreeTemplate=AnimTree'MBHTestModels.Mummy.MummyAnimTree'
		HiddenGame=FALSE
		HiddenEditor=FALSE
	End Object

	Mesh=MummyPawnSkeletalMesh

	Components.Add(MummyPawnSkeletalMesh)
	ControllerClass=class'MonsterBountyHunter.MBHMummyAIController'

	bJumpCapable=false
	bCanJump=false

	GroundSpeed=200.0

	bumpDamage=10.0

	followDistance=512.0
	meleeAttackDistance=100.0
	isAngry=false
}
