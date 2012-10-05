class MBHFaraoPawn extends MBHEnemyPawn
	placeable ClassGroup(MonsterBountyHunter);

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
	ControllerClass=class'MonsterBountyHunter.MBHFaraoAIController'

	GroundSpeed=900;

	bJumpCapable=false
	bCanJump=false

	bumpDamage=100.0
	followDistance=2000.0
	meleeAttackDistance=96.0
	isAngry=true

	CustomGravityScaling
}
