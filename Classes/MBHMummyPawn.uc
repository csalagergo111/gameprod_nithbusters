class MBHMummyPawn extends MBHEnemyPawn
	placeable ClassGroup(MonsterBountyHunter);

// Attack animation
var AnimNodePlayCustomAnim attackNode;

function PostBeginPlay()
{
	super.PostBeginPlay();

	SpawnDefaultController();
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	attackNode = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('AttackAnim'));
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
		SkeletalMesh=SkeletalMesh'MBHMummyModels.Mummy.MBH_Mummy_Skeletal-Mesh'
		AnimSets(0)=AnimSet'MBHMummyModels.Mummy.MummyAnimSet'
		AnimTreeTemplate=AnimTree'MBHMummyModels.Mummy.MummyAnimTree'
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
