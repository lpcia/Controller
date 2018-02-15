    //  DCC++ CONTROLLER: Configuration and Initialization
    //
    //  * Defines all global variables and objects
    //
    //  * Reads and loads previous status data from status files
    //
    //  * Implements track layout(s), throttles, track buttons, route buttons,
    //    cab buttons, function buttons, windows, current meter,
    //    and all other user-specified components
    //
    //
    //  THINGS TO DO:
    //    Make sure power is off when hitting the quit button
    //    Error when pressing a throttle when power is not on.
    //    Add Turnouts to main screen.   PVC
    //    Add indicator (Signal?) lamps for sidings that are clear to the main line.   PVC
    //
    //    DECLARE "GLOBAL" VARIABLES and OBJECTS  - My Additions
    //    PImage layoutPhoto; 
    //
    //
    // Create the Layout bacground  -  place somewhere in initalize() (starts on line 88)
    //                                 after declareing as PImage in // DECLARE "GLOBAL" VARIABLES and OBJECTS
    //    layoutPhoto = loadImage("LKpng99bVO.png");
    //        image(layoutPhoto, 250, 50);
    //  
    //  Record of changes to other .pde files:
    //	2018 02 12 Started Over to make sure I kept track of the changes.
    //	Changed a few lines here and there to make button color changes.	
    //  2018 02 15 Changed coreComponents:  Turn off power upon quit.  Line 186


 