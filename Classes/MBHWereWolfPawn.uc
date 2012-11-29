class MBHWereWolfPawn extends MBHEnemyPawn
	placeable ClassGroup(MonsterBountyHunter);

var int maxHealth;
// Attack animation
var UDKAnimBlendByWeapon attackNode;
var AnimNodeCrossfader deathNode;

function PostBeginPlay()
{
	super(UDKPawn).PostBeginPlay();
	maxHealth = Health;

	Mesh.SetAnimTreeTemplate(AnimTree'MBHWereWolfModels.WereWolf.WereWolfAnimTree');
}

exec function playShoutAnim()
{
	deathNode.PlayOneShotAnim('Werewolf_shout_intro', 0.1, 0.3, false, 1.0);
}

simulated event Destroyed()
{
	super.Destroyed();

	attackNode = None;
	deathNode = None;
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	attackNode = UDKAnimBlendByWeapon(SkelComp.FindAnimNode('AttackAnim'));
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
			ConsoleCommand("SetLevel lvl2");
			isDead = true;
			deathNode.PlayOneShotAnim('werewolf_death', 0.1, 0.0, true, 1.0);
		}
	}
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+88.000000
		CollisionRadius=80
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
	meleeAttackDistance=129.0
	isAngry=false
}