class MBHEnemyPawn extends UDKPawn;

// Amount of damage done when colliding with player
var() float bumpDamage;
// How close the player has to be before "discovering" him
var() float followDistance;
// How close the player has to be for melee-damage to be done
var() float meleeAttackDistance;
// Position to return to when the player is dead
var vector startPosition;
// If this is set to true, for example when the player
// shoots the enemy, ignore followDistance and attack player
var() bool isAngry;

function PostBeginPlay()
{
	super.PostBeginPlay();
	startPosition = Location;
}

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
}