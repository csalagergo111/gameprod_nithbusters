class MBHWereWolfPawn extends MBHEnemyPawn
	placeable ClassGroup(MonsterBountyHunter);

var int maxHealth;
// Attack animation
var AnimNodePlayCustomAnim attackNode;

function PostBeginPlay()
{
	super(UDKPawn).PostBeginPlay();
	maxHealth = Health;

	Mesh.SetAnimTreeTemplate(AnimTree'MBHWereWolfModels.WereWolf.WereWolfAnimTree');
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

	if(!isDead)
	{
		isAngry = true;

		if(Health <= 0)
		{
			ConsoleCommand("SetLevel lvl2");
			isDead = true;
		}
	}
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+88.000000
	End Object

	Begin Object Class=SkeletalMeshComponent Name=WofPawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'MBHWereWolfModels.WereWolf.Werewolf_skeletal_mesh'
		AnimSets(0)=AnimSet'MBHWereWolfModels.WereWolf.WereWoflAnimeSet'
		HiddenGame=FALSE
		HiddenEditor=FALSE
	End Object

	Mesh=WofPawnSkeletalMesh

	Components.Add(WofPawnSkeletalMesh)
	ControllerClass=class'MonsterBountyHunter.MBHWereWolfAIController'

	GroundSpeed=900;

	bJumpCapable=false
	bCanJump=false

	Health=500

	bumpDamage=100.0
	followDistance=2000.0
	meleeAttackDistance=96.0
	isAngry=false
}