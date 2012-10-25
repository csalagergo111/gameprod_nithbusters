class MBHProjectile_Arrow extends UTProjectile;


DefaultProperties
{
	Physics=PHYS_Falling

	//Arrows=10

	Speed=8000.0
	MaxSpeed=8000.0

	Damage=50.0

	CustomGravityScaling=0.15

	ProjFlightTemplate=ParticleSystem'VH_Scorpion.Effects.P_Scorpion_Bounce_Projectile'

	ProjExplosionTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Impact'

	//MyDamageType=class'UTDmgType_Burning'
	MyDamageType=class'MBHDamageType_Fire'
}
