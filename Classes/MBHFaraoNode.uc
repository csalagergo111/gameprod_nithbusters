class MBHFaraoNode extends Actor
	placeable ClassGroup(MonsterBountyHunter);

var() int index;

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_NavP'
	End Object
	Components.Add(Sprite)

	index=0
}
