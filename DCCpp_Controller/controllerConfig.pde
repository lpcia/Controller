//////////////////////////////////////////////////////////////////////////
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
//  ToDo:
//    Fix backGroundColor
//    Make sure power is off when hitting the quit button  Compeleted 2018 05 15
//    Error when pressing a throttle when power is not on.
//    Add Turnouts to main screen.   PVC
//    Add indicator (Signal?) lamps for sidings that are clear to the main line.
//    Does PImage really need to be on line 92 of DCCpp_Controller, if so, should it be proceeded by the "Final" keyword
//    locomotive lamps lite up as soon as power button is pushed.  I don't like this.     aPort.write("<0>"); 
//    disableing the background image showed that the clock acting strangely
//
//
//
//////////////////////////////////////////////////////////////////////////

// DECLARE "GLOBAL" VARIABLES and OBJECTS

  PApplet Applet = this;                         // Refers to this program --- needed for Serial class

  int cursorType;
  String baseID;
  boolean keyHold=false;
  boolean saveXMLFlag=false;
  int lastTime;
  PFont throttleFont, messageFont, buttonFont;
  color backgroundColor;
  color buttonColor;
  XML dccStatusXML, arduinoPortXML, sensorButtonsXML, cabDefaultsXML, serverListXML;
  
  DccComponent selectedComponent, previousComponent;
  ArrayList<DccComponent> dccComponents = new ArrayList<DccComponent>();
  ArrayList<CabButton> cabButtons = new ArrayList<CabButton>();
  ArrayList<CallBack> callBacks = new ArrayList<CallBack>();
  ArrayList<DccComponent> buttonQueue = new ArrayList<DccComponent>();
  ArrayList<DccComponent> buttonQueue2 = new ArrayList<DccComponent>();
  HashMap<Integer,EllipseButton> remoteButtonsHM = new HashMap<Integer,EllipseButton>();
  ArrayList<MessageBox> msgAutoCab = new ArrayList<MessageBox>();
  HashMap<Integer,TrackSensor> sensorsHM = new HashMap<Integer,TrackSensor>();    
  HashMap<String,CabButton> cabsHM = new HashMap<String,CabButton>();
  HashMap<Integer,TrackButton> trackButtonsHM = new HashMap<Integer,TrackButton>();  
  
  ArduinoPort       aPort;
  PowerButton       powerButton;
  //AutoPilotButton   autoPilot;
  //CleaningCarButton cleaningCab;
  Throttle          throttleA;
  Layout            layout,layout2,layoutBridge;
  MessageBox        msgBoxMain, msgBoxDiagIn, msgBoxDiagOut, msgBoxClock;
  CurrentMeter      currentMeter;
  Window            mainWindow, accWindow, progWindow, portWindow, extrasWindow, opWindow, diagWindow, autoWindow, sensorWindow, ledWindow;
  ImageWindow       imageWindow;
  JPGWindow         helpWindow;
  PNGWindow         cabWindow;
  MessageBox        msgAutoState, msgAutoTimer;
  InputBox          activeInputBox;
  InputBox          accAddInput, accSubAddInput;
  InputBox          progCVInput, progHEXInput, progDECInput, progBINInput;
  InputBox          opCabInput, opCVInput, opHEXInput, opDECInput, opBINInput, opBitInput;
  InputBox          shortAddInput, longAddInput;
  MessageBox        activeAddBox;
  MessageBox        portBox, portNumBox;
  MessageBox        ledHueMsg, ledSatMsg, ledValMsg, ledRedMsg, ledGreenMsg, ledBlueMsg;
  PortScanButton    portScanButton;
  LEDColorButton    ledColorButton;
  
// DECLARE TRACK BUTTONS, ROUTE BUTTONS, and CAB BUTTONS WHICH WILL BE DEFINED BELOW AND USED "GLOBALLY"  

  TrackButton      tButton1,tButton2,tButton3,tButton4,tButton5;
  TrackButton      tButton6,tButton7,tButton8,tButton9,tButton10;
  TrackButton      tButton20,tButton30,tButton40,tButton50;
  
  RouteButton      rButton1,rButton2,rButton3,rButton4,rButton5,rButton6,rButton7;
  RouteButton      rButton10,rButton11,rButton12,rButton13,rButton14;
  RouteButton      rButtonR1,rButtonR2,rButton15,rButton16,rButton17,rButtonSpiral,rButtonReset,rButtonBridge;  

  CabButton        cab5,cab55,cab7,cab77,cab91,cab85,cab4,cab9,cab8,cab6720,cab11,cab12;  // ,cab13,cab14,cab15  For a future 2nd page
  
////////////////////////////////////////////////////////////////////////
//  Initialize --- configures everything!
////////////////////////////////////////////////////////////////////////

  void Initialize(){

    colorMode(RGB,255);
    throttleFont=loadFont("OCRAExtended-26.vlw");
    messageFont=loadFont("LucidaConsole-18.vlw");
    buttonFont=loadFont("LucidaConsole-18.vlw");
    rectMode(CENTER);
    textAlign(CENTER,CENTER);
    backgroundColor=color(#A2724D);
    buttonColor=color(30);
    backGroundImage = loadImage("DCCppBackground.png");
    aPort=new ArduinoPort();

        
// READ, OR CREATE IF NEEDED, XML DCC STATUS FILE
    
    dccStatusXML=loadXML(STATUS_FILE);
    if(dccStatusXML==null){
      dccStatusXML=new XML("dccStatus");
    }

    arduinoPortXML=dccStatusXML.getChild("arduinoPort");
    if(arduinoPortXML==null){
      arduinoPortXML=dccStatusXML.addChild("arduinoPort");
      arduinoPortXML.setContent("Emulator");
    }
    
    serverListXML=dccStatusXML.getChild("serverList");
    if(serverListXML==null){
      serverListXML=dccStatusXML.addChild("serverList");
      serverListXML.setContent("127.0.0.1");
    }
    
    sensorButtonsXML=dccStatusXML.getChild("sensorButtons");
    if(sensorButtonsXML==null){
      sensorButtonsXML=dccStatusXML.addChild("sensorButtons");
    }
    
    cabDefaultsXML=dccStatusXML.getChild("cabDefaults");
    if(cabDefaultsXML==null){
      cabDefaultsXML=dccStatusXML.addChild("cabDefaults");
    }
    
    saveXMLFlag=true;
      
// CREATE THE ACCESSORY CONTROL WINDOW
    
    accWindow = new Window(500,200,300,160,color(200,200,200),color(200,50,50));
    new DragBar(accWindow,0,0,300,10,color(200,50,50));
    new CloseButton(accWindow,288,0,10,10,color(200,50,50),color(255,255,255));
    new MessageBox(accWindow,150,22,0,0,color(200,200,200),20,"Accessory Control",color(200,50,50));
    new MessageBox(accWindow,20,60,-1,0,color(200,200,200),16,"Acc Address (0-511):",color(200,50,50));
    accAddInput = new InputBox(accWindow,230,60,16,color(200,200,200),color(50,50,200),3,InputType.DEC);
    new MessageBox(accWindow,20,90,-1,0,color(200,200,200),16,"Sub Address   (0-3):",color(200,50,50));
    accSubAddInput = new InputBox(accWindow,230,90,16,color(200,200,200),color(50,50,200),1,InputType.DEC);
    new AccessoryButton(accWindow,90,130,55,25,100,18,"ON",accAddInput,accSubAddInput);
    new AccessoryButton(accWindow,210,130,55,25,0,18,"OFF",accAddInput,accSubAddInput);
    accAddInput.setNextBox(accSubAddInput);
    accSubAddInput.setNextBox(accAddInput);
    
// CREATE THE SERIAL PORT WINDOW
    
    portWindow = new Window(500,200,500,170,color(200,200,200),color(200,50,50));
    new DragBar(portWindow,0,0,500,10,color(200,50,50));
    new CloseButton(portWindow,488,0,10,10,color(200,50,50),color(255,255,255));
    new MessageBox(portWindow,250,22,0,0,color(200,200,200),20,"Select Arduino Port",color(200,50,50));
    portScanButton = new PortScanButton(portWindow,100,60,85,20,100,18,"SCAN");
    new PortScanButton(portWindow,400,60,85,20,0,18,"CONNECT");
    new PortScanButton(portWindow,120,140,15,20,120,18,"<");
    new PortScanButton(portWindow,380,140,15,20,120,18,">");
    portBox = new MessageBox(portWindow,250,100,380,25,color(250,250,250),20,"",color(50,150,50));
    portBox.setMessage("Please press SCAN",color(150,50,50));
    portNumBox = new MessageBox(portWindow,250,140,0,0,color(200,200,200),20,"",color(50,50,50));

// CREATE THE PROGRAMMING CVs ON THE PROGRAMMING TRACK WINDOW
    
    progWindow = new Window(500,100,500,400,color(200,180,200),color(50,50,200));
    new DragBar(progWindow,0,0,500,10,color(50,50,200));
    new CloseButton(progWindow,488,0,10,10,color(50,50,200),color(255,255,255));
    new RectButton(progWindow,250,30,210,30,40,color(0),18,"Programming Track",ButtonType.TI_COMMAND,101);        
    
    new MessageBox(progWindow,20,90,-1,0,color(200,180,200),16,"CV (1-1024):",color(50,50,200));
    new MessageBox(progWindow,20,130,-1,0,color(200,180,200),16,"Value (HEX):",color(50,50,200));
    new MessageBox(progWindow,20,160,-1,0,color(200,180,200),16,"Value (DEC):",color(50,50,200));
    new MessageBox(progWindow,20,190,-1,0,color(200,180,200),16,"Value (BIN):",color(50,50,200));
    progCVInput = new InputBox(progWindow,150,90,16,color(200,180,200),color(200,50,50),4,InputType.DEC);
    progHEXInput = new InputBox(progWindow,150,130,16,color(200,180,200),color(200,50,50),2,InputType.HEX);
    progDECInput = new InputBox(progWindow,150,160,16,color(200,180,200),color(200,50,50),3,InputType.DEC);
    progBINInput = new InputBox(progWindow,150,190,16,color(200,180,200),color(200,50,50),8,InputType.BIN);
    progCVInput.setNextBox(progHEXInput);
    progHEXInput.setNextBox(progDECInput);
    progDECInput.setNextBox(progBINInput);
    progDECInput.linkBox(progHEXInput);
    progBINInput.setNextBox(progHEXInput);
    progBINInput.linkBox(progHEXInput);        
    new ProgWriteReadButton(progWindow,300,90,65,25,100,14,"READ",progCVInput,progHEXInput);
    new ProgWriteReadButton(progWindow,390,90,65,25,0,14,"WRITE",progCVInput,progHEXInput);

    new MessageBox(progWindow,20,240,-1,0,color(200,180,200),16,"ENGINE ADDRESSES",color(50,50,200));
    new MessageBox(progWindow,20,280,-1,0,color(200,180,200),16,"Short  (1-127):",color(50,50,200));
    new MessageBox(progWindow,20,310,-1,0,color(200,180,200),16,"Long (0-10239):",color(50,50,200));
    new MessageBox(progWindow,20,340,-1,0,color(200,180,200),16,"Active        :",color(50,50,200));
    shortAddInput = new InputBox(progWindow,190,280,16,color(200,180,200),color(200,50,50),3,InputType.DEC);
    longAddInput = new InputBox(progWindow,190,310,16,color(200,180,200),color(200,50,50),5,InputType.DEC);
    activeAddBox = new MessageBox(progWindow,190,340,-1,0,color(200,180,200),16,"?",color(200,50,50));
    new ProgAddReadButton(progWindow,300,240,65,25,100,14,"READ",shortAddInput,longAddInput,activeAddBox);
    new ProgShortAddWriteButton(progWindow,300,280,65,25,0,14,"WRITE",shortAddInput);
    new ProgLongAddWriteButton(progWindow,300,310,65,25,0,14,"WRITE",longAddInput);
    new ProgLongShortButton(progWindow,300,340,65,25,0,14,"Long",activeAddBox);
    new ProgLongShortButton(progWindow,390,340,65,25,0,14,"Short",activeAddBox);

// CREATE THE PROGRAMMING CVs ON THE MAIN OPERATIONS TRACK WINDOW
    
    opWindow = new Window(500,100,500,300,color(220,200,200),color(50,50,200));
    new DragBar(opWindow,0,0,500,10,color(50,50,200));
    new CloseButton(opWindow,488,0,10,10,color(50,50,200),color(255,255,255));
    new MessageBox(opWindow,250,30,0,0,color(220,200,200),20,"Operations Programming",color(50,100,50));
    new MessageBox(opWindow,20,90,-1,0,color(220,200,200),16,"Cab Number :",color(50,50,200));
    new MessageBox(opWindow,20,120,-1,0,color(220,200,200),16,"CV (1-1024):",color(50,50,200));
    new MessageBox(opWindow,20,160,-1,0,color(220,200,200),16,"Value (HEX):",color(50,50,200));
    new MessageBox(opWindow,20,190,-1,0,color(220,200,200),16,"Value (DEC):",color(50,50,200));
    new MessageBox(opWindow,20,220,-1,0,color(220,200,200),16,"Value (BIN):",color(50,50,200));
    opCabInput = new InputBox(opWindow,150,90,16,color(220,200,200),color(200,50,50),5,InputType.DEC);
    opCVInput = new InputBox(opWindow,150,120,16,color(220,200,200),color(200,50,50),4,InputType.DEC);
    opHEXInput = new InputBox(opWindow,150,160,16,color(220,200,200),color(200,50,50),2,InputType.HEX);
    opDECInput = new InputBox(opWindow,150,190,16,color(220,200,200),color(200,50,50),3,InputType.DEC);
    opBINInput = new InputBox(opWindow,150,220,16,color(220,200,200),color(200,50,50),8,InputType.BIN);
    opCVInput.setNextBox(opHEXInput);
    opHEXInput.setNextBox(opDECInput);
    opDECInput.setNextBox(opBINInput);
    opDECInput.linkBox(opHEXInput);
    opBINInput.setNextBox(opHEXInput);
    opBINInput.linkBox(opHEXInput);        
    new OpWriteButton(opWindow,300,90,65,25,0,14,"WRITE",opCVInput,opHEXInput);
    new MessageBox(opWindow,20,260,-1,0,color(220,200,200),16,"  Bit (0-7):",color(50,50,200));
    opBitInput = new InputBox(opWindow,150,260,16,color(220,200,200),color(200,50,50),1,InputType.DEC);
    new OpWriteButton(opWindow,300,260,65,25,50,14,"SET",opCVInput,opBitInput);
    new OpWriteButton(opWindow,390,260,65,25,150,14,"CLEAR",opCVInput,opBitInput);

// CREATE THE DCC++ CONTROL <-> DCC++ BASE STATION COMMUNICATION DIAGNOSTICS WINDOW
    
    diagWindow = new Window(400,300,500,120,color(175),color(50,200,50));
    new DragBar(diagWindow,0,0,500,10,color(50,200,50));
    new CloseButton(diagWindow,488,0,10,10,color(50,200,50),color(255,255,255));
    new MessageBox(diagWindow,250,20,0,0,color(175),18,"Diagnostics Window",color(50,50,200));
    new MessageBox(diagWindow,10,60,-1,0,color(175),18,"Sent:",color(50,50,200));
    msgBoxDiagOut=new MessageBox(diagWindow,250,60,0,0,color(175),18,"---",color(50,50,200));
    new MessageBox(diagWindow,10,90,-1,0,color(175),18,"Proc:",color(50,50,200));
    msgBoxDiagIn=new MessageBox(diagWindow,250,90,0,0,color(175),18,"---",color(50,50,200));
  
// CREATE THE SENSORS DIAGNOSTICS WINDOW 
    
    sensorWindow = new Window(400,300,500,350,color(175),color(50,200,50));
    new DragBar(sensorWindow,0,0,500,10,color(50,200,50));
    new CloseButton(sensorWindow,488,0,10,10,color(50,200,50),color(255,255,255));
    new MessageBox(sensorWindow,250,20,0,0,color(175),18,"Sensors Window",color(50,50,150));

// CREATE THE HELP WINDOW
      
  helpWindow=new JPGWindow("helpMenu.jpg",1000,650,100,50,color(0,100,0));    
        
// CREATE THE EXTRAS WINDOW:

    extrasWindow = new Window(500,200,500,250,color(255,255,175),color(100,100,200));
    new DragBar(extrasWindow,0,0,500,10,color(100,100,200));
    new CloseButton(extrasWindow,488,0,10,10,color(100,100,200),color(255,255,255));
    new MessageBox(extrasWindow,250,20,0,0,color(175),18,"Extra Functions",color(50,50,200));
//    new RectButton(extrasWindow,260,80,120,50,85,color(0),16,"Sound\nEffects",0);        

/* CREATE THE LED LIGHT-STRIP WINDOW:    // No Light Show for me (yet)   Good example of controlling devices from the arduino's GPIO pins????

    ledWindow = new Window(500,200,550,425,color(0),color(0,0,200));
    new DragBar(ledWindow,0,0,550,10,color(0,0,200));
    new CloseButton(ledWindow,538,0,10,10,color(0,0,200),color(200,200,200));
    new MessageBox(ledWindow,275,20,0,0,color(175),18,"LED Light Strip",color(200,200,200));
    ledColorButton=new LEDColorButton(ledWindow,310,175,30,201,0.0,0.0,1.0);
    new LEDColorSelector(ledWindow,150,175,100,ledColorButton);
    new LEDValSelector(ledWindow,50,330,200,30,ledColorButton);
    ledHueMsg = new MessageBox(ledWindow,360,80,-1,0,color(175),18,"Hue:   -",color(200,200,200));
    ledSatMsg = new MessageBox(ledWindow,360,115,-1,0,color(175),18,"Sat:   -",color(200,200,200));
    ledValMsg = new MessageBox(ledWindow,360,150,-1,0,color(175),18,"Val:   -",color(200,200,200));
    ledRedMsg = new MessageBox(ledWindow,360,185,-1,0,color(175),18,"Red:   -",color(200,200,200));
    ledGreenMsg = new MessageBox(ledWindow,360,220,-1,0,color(175),18,"Green: -",color(200,200,200));
    ledBlueMsg = new MessageBox(ledWindow,360,255,-1,0,color(175),18,"Blue:  -",color(200,200,200));
*/

// Create Image Window for current Loco
  //  Placeholder
  //new MessageBox(198,590,372,131,color(255),14,"Picture of Current Loco\nGoes Here",color(30,30,150));
  //        cabWindow = new PNGWindow("cab-3.png",198,590,372,131,color(0,100,0)); 
// CREATE POWER BUTTON, QUIT BUTTON, and CURRENT METER
    powerButton=new PowerButton(69,675,100,30,100,18,"POWER");
                new QuitButton(184,675,100,30,250,18,"QUIT");  //  x, y, kWidth, kHeight, boxColor, fontSize)
    currentMeter = new CurrentMeter(30,755,300,100,675,5);

// CREATE TWO LINE MESSAGE BAR     xPos, yPos, kWidth, kHeight, boxColor, fontSize
    msgBoxMain=new MessageBox(198,720,372,50,color(255),14,"Searching for Base Station:\n"+arduinoPortXML.getContent(),color(30,30,150));

// CREATE CLOCK  AND HELP BUTTON
    msgBoxClock=new MessageBox(174,875,0,30,#A2724D,30,"00:00:00",color(#A2724D));
                new HelpButton(364,875,22,22,150,20,"?");

// CREATE THROTTLE, DEFINE CAB BUTTONS, and SET FUNCTIONS FOR EACH CAB  ================================================================================
    
    int tAx=170;  // Horizontal Button Location 
    int tAy=215;  // Vertical Button location 
    int rX=800;
    int rY=550;
    
//  cabButton parameters    CabButton(xPos, yPos, Width, Height, baseHue, fontSize, Cab Number, Throttle)
//  setThrottleDefaults parameters (int fullSpeed, int slowSpeed, int reverseSpeed, int reverseSlowSpeed)
//  setFunctionButtonWindow para:  (xPos, yPos, Width, Height, backgroundColor, outlineColor)
//  setFunction parameters (xPos, yPos, Width, Height, baseHue, fontSize, button Number, Button Name, ButtonType.buttonType, CabFunction.cFunc)
    
    throttleA=new Throttle(tAx,tAy,1.3);
      
    // Cab 1 
    //  Santa Fe F7A  |Road Number: 300 |DCC Addr: 5 |Decoder: Digitrax SDN144K0A  |Model:  Kato 176-2121
    //  Digitrax 1 Amp N Scale SoundFX/Mobile/FX3 Function Decoder for Kato SD40-2 and similar locos (SDN144K0A)
        cab5 = new CabButton(tAx-125,tAy-150,50,30,150,15,5,throttleA);
        cab5.setThrottleDefaults(53,30,-20,-13); 
        cab5.functionButtonWindow(212,52,160,385,backgroundColor,backgroundColor);
          cab5.setFunction(80, 15,156,30,30,12, 0,"Lights",ButtonType.NORMAL,CabFunction.F_LIGHT,CabFunction.R_LIGHT);
          cab5.setFunction(80, 50,156,30,30,12, 1,"Bell",ButtonType.NORMAL,CabFunction.BELL);
          cab5.setFunction(80, 85,156,30,30,12, 2,"Horn",ButtonType.HOLD,CabFunction.HORN);
          cab5.setFunction(80,120,156,30,30,12, 3,"Coupler Crash",ButtonType.ONESHOT);
          cab5.setFunction(80,155,156,30,30,12, 4,"Air Feature Disable",ButtonType.ONESHOT);
          cab5.setFunction(80,190,156,30,30,12, 5,"Dynamic Brake Fans",ButtonType.NORMAL);
          cab5.setFunction(80,225,156,30,30,12, 6,"Notch Up",ButtonType.ONESHOT);
          cab5.setFunction(80,260,156,30,30,12, 7,"Crossing Gate",ButtonType.ONESHOT);
          cab5.setFunction(80,295,156,30,30,12, 8,"Mute",ButtonType.NORMAL);
          cab5.setFunction(80,330,156,30,30,12, 9,"Brake Squeal",ButtonType.ONESHOT);
          cab5.setFunction(80,365,156,30,30,12,11,"Handbrake",ButtonType.NORMAL);    
//          cabWindow=new PNGWindow("cab-3.png",198,590,372,131,color(0,100,0));  
          
    // Cab 2 
    // Santa Fe F7B |Road Number: 356 |DCC Addr: 55 |Decoder: Digitrax DN163K1C  |Model:  Kato 176-2211
        cab55 = new CabButton(tAx-125,tAy-110,50,30,150,15,55,throttleA);
        cab55.setThrottleDefaults(50,25,-25,-15);
        cab55.functionButtonWindow(212,52,0,0,backgroundColor,backgroundColor);
      
    // Cab 3 -70
    //  Sant SD40-2 |Road Number: 5073 |DCC Addr: 7 |Decoder: Digitrax SDN144K1E |Model:  Kato 176-8208 
    //  Digitrax 1 Amp N Scale SoundFX/Mobile/FX3 Function Decoder for Kato SD40-2 and similar locos (SDN144K1E)
        cab7 = new CabButton(tAx-125,tAy-70,50,30,150,15,7,throttleA);
        cab7.setThrottleDefaults(53,30,-20,-13);  
        cab7.functionButtonWindow(212,52,160,385,backgroundColor,backgroundColor);
          cab7.setFunction(80, 15,156,30,30,12, 0,"Lights",ButtonType.NORMAL,CabFunction.F_LIGHT,CabFunction.R_LIGHT);
          cab7.setFunction(80, 50,156,30,30,12, 1,"Bell",ButtonType.NORMAL,CabFunction.BELL);
          cab7.setFunction(80, 85,156,30,30,12, 2,"Horn",ButtonType.HOLD,CabFunction.HORN);
          cab7.setFunction(80,120,156,30,30,12, 3,"Coupler Crash",ButtonType.ONESHOT);
          cab7.setFunction(80,155,156,30,30,12, 4,"Air Feature Disable",ButtonType.ONESHOT);
          cab7.setFunction(80,190,156,30,30,12, 5,"Dynamic Brake Fans",ButtonType.NORMAL);
          cab7.setFunction(80,225,156,30,30,12, 6,"Notch Up",ButtonType.ONESHOT);
          cab7.setFunction(80,260,156,30,30,12, 7,"Crossing Gate",ButtonType.ONESHOT);
          cab7.setFunction(80,295,156,30,30,12, 8,"Mute",ButtonType.NORMAL);
          cab7.setFunction(80,330,156,30,30,12, 9,"Brake Squeal",ButtonType.ONESHOT);
          cab7.setFunction(80,365,156,30,30,12,11,"Handbrake",ButtonType.NORMAL);           
      
    // Cab 4 
    //  Santa Fe SD40-2 |Road Number: 5077 |DCC Addr: 77 |Decoder: Digitrax DN163K1C |Model:  Kato 176-8208
    //  Digitrax 1 Amp N Scale Mobile Decoder for Kato N scale SD40-2 locos made from year 2006 onward (DN163K1C)
        cab77 = new CabButton(tAx-125,tAy-30,50,30,150,15,77,throttleA);  // Create a CabButton Object w/
        cab77.setThrottleDefaults(100,50,-50,-45);
        cab77.functionButtonWindow(212,52,160,30,backgroundColor,backgroundColor);
          cab77.setFunction(80,15,156,30,30,12,0,"Lights",ButtonType.NORMAL,CabFunction.F_LIGHT,CabFunction.R_LIGHT);
 
    // Cab 5 
    //  Sant Fe EMD FP5 |Road Number: 91 |DCC Addr: 91 |Decoder: Digitrax SDN144K1E |Model:  Athern ATH22478 
    //  Digitrax 1 Amp N Scale SoundFX/Mobile/FX3 Function Decoder for Kato SD40-2 and similar locos (SDN144K1E)
        cab91 = new CabButton(tAx-125,tAy+10,50,30,150,15,91,throttleA);
        cab91.setThrottleDefaults(53,30,-20,-13);
        cab91.functionButtonWindow(212,52,160,385,backgroundColor,backgroundColor);
          cab91.setFunction(80, 15,156,30,30,12, 0,"Lights",ButtonType.NORMAL,CabFunction.F_LIGHT,CabFunction.R_LIGHT);
          cab91.setFunction(80, 50,156,30,30,12, 1,"Bell",ButtonType.NORMAL,CabFunction.BELL);
          cab91.setFunction(80, 85,156,30,30,12, 2,"Horn",ButtonType.HOLD,CabFunction.HORN);
          cab91.setFunction(80,120,156,30,30,12, 3,"Coupler Crash",ButtonType.ONESHOT);
          cab91.setFunction(80,155,156,30,30,12, 4,"Air Feature Disable",ButtonType.ONESHOT);
          cab91.setFunction(80,190,156,30,30,12, 5,"Dynamic Brake Fans",ButtonType.NORMAL);
          cab91.setFunction(80,225,156,30,30,12, 6,"Notch Up",ButtonType.ONESHOT);
          cab91.setFunction(80,260,156,30,30,12, 7,"Crossing Gate",ButtonType.ONESHOT);
          cab91.setFunction(80,295,156,30,30,12, 8,"Mute",ButtonType.NORMAL);
          cab91.setFunction(80,330,156,30,30,12, 9,"Brake Squeal",ButtonType.ONESHOT);
          cab91.setFunction(80,365,156,30,30,12,11,"Handbrake",ButtonType.NORMAL);    

    // Cab 6 
    // BNSF ES44AC "GEVO"  |Road Number: 5785 |DCC Addr: 85 |Decoder: Digitrax DN163K1C |Model:  Kato 176-8925
        cab85 = new CabButton(tAx-125,tAy+50,50,30,150,15,85,throttleA);
        cab85.setThrottleDefaults(77,46,-34,-30);
        cab85.functionButtonWindow(212,52,160,30,backgroundColor,backgroundColor);
          cab85.setFunction(80,15,156,30,30,12,0,"Lights",ButtonType.NORMAL,CabFunction.F_LIGHT,CabFunction.R_LIGHT);

    // Cab 7 
    //  Santa Fe Ge 44 Ton Switcher |Road Number: 62 |DCC Addr: 4 |Decoder: Bachmann 2 Function Decoder 36-552 |Model:  Bachman 81852
          cab4 = new CabButton(tAx-125,tAy+90,50,30,150,15,4,throttleA);
          cab4.setThrottleDefaults(61,42,-30,-22);    
          cab4.functionButtonWindow(212,52,160,30,backgroundColor,backgroundColor);
            cab4.setFunction(80,15,156,30,30,12,0,"Lights",ButtonType.NORMAL,CabFunction.F_LIGHT,CabFunction.R_LIGHT);
  
    // Cab 8 
    //  Nickle Plate Road PA1 |Road Number: 190 |DCC Addr: 9 |Decoder: Digitrax DN136D |Model:  Lifelike 7058
        cab9 = new CabButton(tAx-125,tAy+130,50,30,150,15,9,throttleA);
        cab9.setThrottleDefaults(100,50,-50,-45);  //  WHAT IS THIS?? 
        cab9.functionButtonWindow(212,52,160,30,backgroundColor,backgroundColor);
          cab9.setFunction(80,15,156,30,30,12,0,"Lights",ButtonType.NORMAL,CabFunction.F_LIGHT,CabFunction.R_LIGHT);
  
    // Cab 9 
    //  Santa Fe NW2 Switcher |Road Number: 2404 |DCC Addr: 8 |Decoder: Digitrax K3D3 |Model:  Kobo 176-4366-1
        cab8 = new CabButton(tAx-125,tAy+170,50,30,150,15,8,throttleA);  // Create a CabButton Object w/
        cab8.setThrottleDefaults(100,50,-50,-45);  //  WHAT IS THIS?? 
        cab8.functionButtonWindow(212,52,160,30,backgroundColor,backgroundColor);
          cab8.setFunction(80,15,156,30,30,12,0,"Lights",ButtonType.NORMAL,CabFunction.F_LIGHT,CabFunction.R_LIGHT);
  

    // Cab 10  LARGE SCREEN VERSION    4 >bHeight, 5 > baseHue, 6 > fontSize    
    //  Pennsylvania M1a 4-8-2 |Road Number: 6720 |DCC Addr:  |Decoder: Paragon2 Sound |Model:  Paragon 3073
        cab6720 = new CabButton(tAx-125,tAy+210,50,30,150,15,3,throttleA);
        cab6720.setThrottleDefaults(34,14,-5,-3);
        cab6720.functionButtonWindow(212,52,160,426,backgroundColor,backgroundColor);  //220,59,1,1
          cab6720.setFunction( 80, 15,156,30,30,12,14,"Passenger Notices",ButtonType.ONESHOT);
          cab6720.setFunction( 80, 50,156,30,30,12,15,"Freight Notices",ButtonType.ONESHOT);
          cab6720.setFunction( 80, 85,156,30,30,12,16,"Maintenance Sounds",ButtonType.ONESHOT);
          cab6720.setFunction( 80,120,156,30,30,12,17,"Crew Radio",ButtonType.ONESHOT);
          cab6720.setFunction( 80,155,156,30,30,12,18,"City Sounds",ButtonType.ONESHOT);
          cab6720.setFunction( 80,190,156,30,30,12,19,"Farm Sounds",ButtonType.ONESHOT);
          cab6720.setFunction( 80,225,156,30,30,12,20,"Industry Sounds",ButtonType.ONESHOT);
          cab6720.setFunction( 80,260,156,30,30,12,21,"Lumber Mill",ButtonType.ONESHOT);
        cab6720.functionButtonWindow(212,52,160,426,backgroundColor,backgroundColor);
          cab6720.setFunction( 80, 15,156,30,30,12, 0,"Headlight",ButtonType.NORMAL,CabFunction.F_LIGHT);
          cab6720.setFunction( 80, 50,156,30,30,12, 1,"Bell",ButtonType.NORMAL,CabFunction.BELL);
          cab6720.setFunction( 53, 85,102,30,30,12, 2,"Whistle",ButtonType.HOLD,CabFunction.HORN);
          cab6720.setFunction(137, 85, 42,30,30,12,22,"Alt",ButtonType.NORMAL);
          cab6720.setFunction( 80,120,156,30,30,12, 4,"Coupler Stack\nCoupler Air Pump",ButtonType.NORMAL);
          cab6720.setFunction( 80,155,156,30,30,12, 5,"Blow Down\nIncrease Chuff",ButtonType.NORMAL);
          cab6720.setFunction( 80,190,156,30,30,12, 6,"Water Fill\nDecrease Chuff",ButtonType.NORMAL);
          cab6720.setFunction( 80,225,156,30,30,12, 8,"Mute",ButtonType.NORMAL);
          cab6720.setFunction( 80,260,156,30,30,12, 9,"Startup\nShutdown Engine",ButtonType.NORMAL);
          cab6720.setFunction( 80,295,156,30,30,12,10,"Coal Shovel / Auger",ButtonType.NORMAL);
          cab6720.setFunction( 80,330,156,30,30,12,11,"Water Injectors",ButtonType.ONESHOT);
          cab6720.setFunction( 80,365,156,30,30,12,12,"Brake Set, Release\nSqueal",ButtonType.ONESHOT);
          cab6720.setFunction( 80,400,156,30,30,12,13,"Grade Crossing Horn",ButtonType.ONESHOT,CabFunction.S_HORN);
//  My current inventory ends here.

//   FunctionButton fields = xPos,yPos,bWidth,bHeight,baseHue,fontSize,this,fNum,name,buttonType,cFunc);}

    // Cab 11 
    //   |Road Number:  |DCC Addr:  |Decoder: Digitrax  |Model:  Kato 
        cab11 = new CabButton(tAx-125,tAy+250,50,30,31,15,111,throttleA);  // Create a CabButton Object w/
        cab11.setThrottleDefaults(100,50,-50,-45);
        cab11.functionButtonWindow(212,52,0,0,backgroundColor,backgroundColor);
    // Cab 12 
    //   |Road Number:  |DCC Addr:  |Decoder: Digitrax  |Model:  Kato 
        cab12 = new CabButton(tAx-125,tAy+290,50,30,32,15,112,throttleA);  // Create a CabButton Object w/
        cab12.setThrottleDefaults(100,50,-50,-45);
        cab12.functionButtonWindow(212,52,0,0,backgroundColor,backgroundColor);

/*  Future Second page???
    // Cab 13 
    //   |Road Number:  |DCC Addr:  |Decoder: Digitrax  |Model:  Kato 
        cab13 = new CabButton(tAx-125,tAy+330,50,30,33,15,113,throttleA);  // Create a CabButton Object w/
        cab13.setThrottleDefaults(100,50,-50,-45);
        cab13.functionButtonWindow(220,125,0,0,backgroundColor,backgroundColor);

    // Cab 14 
    //   |Road Number:  |DCC Addr:  |Decoder: Digitrax  |Model:  Kato 
        cab14 = new CabButton(tAx-125,tAy+370,50,30,34,15,114,throttleA);  // Create a CabButton Object w/
        cab14.setThrottleDefaults(100,50,-50,-45);
        cab14.functionButtonWindow(220,125,0,0,backgroundColor,backgroundColor);

    // Cab 15 
    //   |Road Number:  |DCC Addr:  |Decoder: Digitrax  |Model:  Kato 
        cab15 = new CabButton(tAx-125,tAy+410,50,30,35,15,115,throttleA);  // Create a CabButton Object w/
        cab15.setThrottleDefaults(100,50,-50,-45); 
        cab15.functionButtonWindow(220,125,0,0,backgroundColor,backgroundColor);
*/
          
//  CREATE THE IMAGE WINDOW FOR THROTTLE A (must be done AFTER throttle A is defined above)

    imageWindow=new ImageWindow(throttleA,975,450,200,50,color(200,50,50));    //  Not sure if this is required.
    
    
  } // Initialize

//////////////////////////////////////////////////////////////////////////