class MBHPistolAttachment extends UTWeaponAttachment;


defaultproperties
{
Begin Object Name=SkeletalMeshComponent0
	SkeletalMesh=SkeletalMesh'MBHRevoverModels.MBH_Wpn_Revolver_socket_tex'
	CullDistance=5000.000000
	Scale=1
End Object

	ImpactEffects(0)=(MaterialType=Water, ParticleTemplate=ParticleSystem'WPN_Projectiles.particle_system.MBH_Shotgun_Hit', Sound=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_FireCue')
	Mesh=SkeletalMeshComponent0

	WeaponClass=Class'MBHWeapon_Pistol'
}