class MBHFaraoPawn extends MBHEnemyPawn
	placeable ClassGroup(MonsterBountyHunter);

// Distance from center when circling
var() float circlingDistance;
// How many degrees to increase circlingDegree with
var() float circlingSpeed;
var int maxHealth;
// Attack animation
var AnimNodePlayCustomAnim faraoCustomNode;

function PostBeginPlay()
{
	super(UDKPawn).PostBeginPlay();
	maxHealth = Health;

	Mesh.SetAnimTreeTemplate(AnimTree'MBHPharaoModels.PharaoAnimTree');
}

simulated event Destroyed()
{
	super.Destroyed();

	faraoCustomNode = None;
	//deathNode = None;
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	faraoCustomNode = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('AttackAnim'));
}
event TakeDamage(int DamageAmount, Controller EventInstigator, 
	vector HitLocation, vector Momentum,
class<DamageType> DamageType,
	optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	//`log("Health left: "@Health);
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+88.000000
	End Object

	Begin Object Class=SkeletalMeshComponent Name=WofPawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'MBHPharaoModels.MBH_Farao_SkeletalMesh'
		AnimSets(0)=AnimSet'MBHPharaoModels.PharaoAnimSet'
		HiddenGame=FALSE
		HiddenEditor=FALSE
		Scale3D=(X=2.0,Y=2.0,Z=2.0)
	End Object

	Mesh=WofPawnSkeletalMesh

	Components.Add(WofPawnSkeletalMesh)
	ControllerClass=class'MonsterBountyHunter.MBHFaraoAIController'

	GroundSpeed=900;

	bJumpCapable=false
	bCanJump=false
	bCanStrafe=true
	bCanFly=true

	Health=500

	bumpDamage=100.0
	followDistance=2000.0
	meleeAttackDistance=96.0
	isAngry=true
	circlingDistance=1000
	circlingSpeed=20
}