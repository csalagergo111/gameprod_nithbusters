class MBHMummyPawn extends MBHEnemyPawn
	placeable ClassGroup(MonsterBountyHunter);

// Attack animation
var AnimNodePlayCustomAnim mummyCustomNode;
// Death animation
var AnimNodeCrossfader deathNode;

function PostBeginPlay()
{
	super.PostBeginPlay();

	SpawnDefaultController();
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	mummyCustomNode = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('MummyAnim'));
	deathNode = AnimNodeCrossfader(SkelComp.FindAnimNode('deathNode'));
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
			deathNode.PlayOneShotAnim('MBH_Mummy_Ani_Death',0.1, 0.0, true, 1.0);
			isDead=true;
		}
		else
		{
			mummyCustomNode.PlayCustomAnimByDuration('MBH_Mummy_Ani_Get-Hit', 0.6667, 0.1, 0.1, false, true);
			GroundSpeed = 0;
			SetTimer(0.6667, false, 'takeDamageEnded');
		}
	}
}

function takeDamageEnded()
{
	GroundSpeed = Default.GroundSpeed;
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+50.000000
		CollisionRadius=+25.000000
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
