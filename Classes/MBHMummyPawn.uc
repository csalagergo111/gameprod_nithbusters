class MBHMummyPawn extends MBHWolfPawn;

DefaultProperties
{
	/*Begin Object Class=SkeletalMeshComponent Name=MummyPawnSkeletalMesh
		SkeletalMesh=StaticMesh'MBHGameModels.Enemies.Mummy_Mummy'
		HiddenGame=FALSE
		HiddenEditor=FALSE
	End Object*/

	//Mesh=MummyPawnSkeletalMesh

	//Components.Add(MummyPawnSkeletalMesh)
	ControllerClass=class'MonsterBountyHunter.MBHMummyAIController'

	bJumpCapable=false
	bCanJump=false

	GroundSpeed=400.0

	bumpDamage=5.0
}
