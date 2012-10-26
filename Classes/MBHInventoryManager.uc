class MBHInventoryManager extends UTInventoryManager;


simulated function GetWeaponList(out array<UTWeapon> WeaponList, optional bool bFilter, optional int GroupFilter, optional bool bNoEmpty)
{
	local UTWeapon Weap;
	local int i;

	ForEach InventoryActors( class'UTWeapon', Weap )
	{
		if ( (!bFilter || Weap.InventoryGroup == GroupFilter)/* && ( !bNoEmpty || Weap.HasAnyAmmo())*/ )
		{
			if ( WeaponList.Length>0 )
			{
				// Find it's place and put it there.

				for (i=0;i<WeaponList.Length;i++)
				{
					if (WeaponList[i].InventoryWeight > Weap.InventoryWeight)
					{
						WeaponList.Insert(i,1);
						WeaponList[i] = Weap;
						break;
					}
				}
				if (i==WeaponList.Length)
				{
					WeaponList.Length = WeaponList.Length+1;
					WeaponList[i] = Weap;
				}
			}
			else
			{
				WeaponList.Length = 1;
				WeaponList[0] = Weap;
			}
		}
	}
}

simulated function SwitchWeapon(byte NewGroup)
{
	local UTWeapon CurrentWeapon;
	local array<UTWeapon> WeaponList;
	local int NewIndex;

	// Get the list of weapons

   	GetWeaponList(WeaponList,true,NewGroup);

	// Exit out if no weapons are in this list.

	if (WeaponList.Length<=0)
		return;

	CurrentWeapon = UTWeapon(PendingWeapon);
	if (CurrentWeapon == None)
	{
		CurrentWeapon = UTWeapon(Instigator.Weapon);
	}

	if (CurrentWeapon == none || CurrentWeapon.InventoryGroup != NewGroup)
	{
		// Changing groups, so activate the first weapon in the array

		NewIndex = 0;
	}
	else
	{
		// Find the current weapon's position in the list and switch to the one above it

		for (NewIndex=0;NewIndex<WeaponList.Length;NewIndex++)
		{
			if (WeaponList[NewIndex] == CurrentWeapon)
				break;
		}
		NewIndex++;
		if (NewIndex>=WeaponList.Length)		// start the beginning if past the end.
			NewIndex = 0;
	}

	// Begin the switch process...

	//if ( WeaponList[NewIndex].HasAnyAmmo() )
	//{
		SetCurrentWeapon(WeaponList[NewIndex]);
	//}
}

DefaultProperties
{
}
