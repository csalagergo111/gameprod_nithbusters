class MBHPistolAttachment extends UTWeaponAttachment;


defaultproperties
{
Begin Object Name=SkeletalMeshComponent0
	SkeletalMesh=SkeletalMesh'MBHRevoverModels.MBH_Wpn_Revolver_socket_tex'
	CullDistance=5000.000000
	Scale=1
End Object

	ProjExplosionTemplate=ParticleSystem'WPN_Projectiles.particle_system.MBH_Shotgun_Hit'
Mesh=SkeletalMeshComponent0

WeaponClass=Class'MBHWeapon_Pistol'
}