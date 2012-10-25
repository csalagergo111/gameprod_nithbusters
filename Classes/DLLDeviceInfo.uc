class DLLDeviceInfo extends Object
    DLLBind(DeviceInfo);


/*  Resolution, holds the width and height of a display resolution.
*/
struct Resolution
{
    var int PixelWidth, PixelHeight;
};


/*  An array of Resolutions, listing all the unique display resolutions found
*/
var array<Resolution> AllResolutions;


/*  DLL import declaration, matching the call signature of the function defined in our DLL
*/
dllimport final function int DLLEnumDisplaySettings( int modeNum, out Resolution r );


/*  EnumDeviceModes, builds a list of graphics resolutions supported by the hardware.

    Each call to DLLEnumDisplaySettings may return a new resolution, or a duplicate resolution with
    different bit-depth and refresh rate. For SETRES and our UI options we only require a list of the
    unique resolutions, so we'll filter out all the duplicates.
*/
function EnumDeviceModes()
{
    local Resolution    r;
    local int            modeNum;
    local int            key;
    local array<int>    keys;


    `log("Enumerating device modes...");

    // Start with mode 0
    modeNum = 0;

    // Query device mode 0, 1, 2, ... etc. DLLEnumDisplaySettings returns 0 when all modes have been reported
    while( DLLEnumDisplaySettings(modeNum, r) != 0 )
    {
        // combine width and height into a single integer 'key'
        key = r.PixelWidth << 16 | r.PixelHeight;

    /*  This simple trick filters out duplicate resolutions by creating a unique key for each combination of
        width and height. If our key list doesn't yet contain an entry for this combo then we have a new
        resolution to add to our list of AllResolutions.
        
        Reduces hundreds of reported modes down to a handful of useable options. Which is nice.
    */

        // Already added this combination of width and height?
        if ( keys.Find(key) == INDEX_NONE )
        {
            // Add the new resolution
            AllResolutions.Additem(r);
            // Add the key
            keys.AddItem(key);
        }
        
        // next device mode
        modeNum++;
    }

    // Report some useful info...
    `log(AllResolutions.Length @ "available resolutions from" @ modeNum @ "device modes");
    `log("The following resolutions are supported:");

    foreach AllResolutions(r)
    {
        `log("  " $ r.PixelWidth @ "x" @ r.PixelHeight);
    }
}