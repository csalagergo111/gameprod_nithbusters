class MBHWereWolfPawn extends UDKPawn
	placeable ClassGroup(MonsterBountyHunter);

var() float FollowDistance;
var() float AttackDistance;
var() float AttackDamage;

event TakeDamage(int DamageAmount, Controller EventInstigator, 
	vector HitLocation, vector Momentum,
class<DamageType> DamageType,
	optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(5,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	if(Health <= 0)
		Destroy();
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+88.000000
	End Object

	Begin Object Class=SkeletalMeshComponent Name=WofPawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		HiddenGame=FALSE
		HiddenEditor=FALSE
		Scale3D=(X=2.0,Y=2.0,Z=2.0)
	End Object

	Mesh=WofPawnSkeletalMesh

	Components.Add(WofPawnSkeletalMesh)
	ControllerClass=class'MonsterBountyHunter.MBHWereWolfAIController'

	GroundSpeed=900;

	bJumpCapable=false
	bCanJump=false

	FollowDistance=2000.0
	AttackDistance=96.0
	AttackDamage=100.0
}