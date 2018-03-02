//////////////////////////////////////////////////////////////////////////
//  DCC++ CONTROLLER: Classes for Sensors and AutoPilot Control
//
//  PVC 2018 02 15  Removed Autopilot. 
//
//  TrackSensor     - defines a track sensor that triggers when the first car of a train passes, and
//                    then again when the last car of that same train passes.
//                  - creates a track sensor button on the track layout where ther sensor is located
//                  - a given track sensor is defined to be "on" once an initial trigger is received from passage
//                    of first the car of a train, and defined to be "off" once a second trigger is received from
//                    passage of last car of that same train
//                  - if the on/off status of a track sensor button seems out of sync with the actual train,
//                    user can manually toggle the sensor "on" or "off" by clicking the appropriate sensor button
//                  
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
//  DCC Component: TrackSensor
//////////////////////////////////////////////////////////////////////////

class TrackSensor extends Track{
  boolean isActive=false;
  boolean sensorDefault;
  int xPos, yPos;
  int mTime;
  int kWidth, kHeight;
  String sensorName;
  int sensorNum;
  XML sensorButtonXML;
  MessageBox msgBoxSensor;

  TrackSensor(Track refTrack, int trackPoint, float tLength, int kWidth, int kHeight, int sensorNum, boolean sensorDefault){
    super(refTrack,trackPoint,tLength);
    this.kWidth=kWidth;
    this.kHeight=kHeight;
    this.xPos=int(x[1]*layout.sFactor+layout.xCorner);
    this.yPos=int(y[1]*layout.sFactor+layout.yCorner);   
    this.sensorNum=sensorNum;
    sensorName="Sensor"+sensorNum;
    componentName=sensorName;
    this.sensorDefault=sensorDefault;
    sensorButtonXML=sensorButtonsXML.getChild(sensorName);
    if(sensorButtonXML==null){
      sensorButtonXML=sensorButtonsXML.addChild(sensorName);
      sensorButtonXML.setContent(str(isActive));
    } else{
      isActive=boolean(sensorButtonXML.getContent());
    }
  sensorsHM.put(sensorNum,this);
  msgBoxSensor=new MessageBox(sensorWindow,0,sensorNum*22+22,-1,0,color(175),18,"S-"+nf(sensorNum,2)+":",color(50,50,250));  
  }

  TrackSensor(Track refTrack, int trackPoint, float curveRadius, float curveAngleDeg, int kWidth, int kHeight, int sensorNum, boolean sensorDefault){
    super(refTrack,trackPoint,curveRadius,curveAngleDeg);
    this.kWidth=kWidth;
    this.kHeight=kHeight;
    this.xPos=int(x[1]*layout.sFactor+layout.xCorner);
    this.yPos=int(y[1]*layout.sFactor+layout.yCorner);    
    this.sensorNum=sensorNum;
    this.sensorDefault=sensorDefault;
    sensorName="Sensor"+sensorNum;
    componentName=sensorName;
    sensorButtonXML=sensorButtonsXML.getChild(sensorName);
    if(sensorButtonXML==null){
      sensorButtonXML=sensorButtonsXML.addChild(sensorName);
      sensorButtonXML.setContent(str(isActive));
    } else{
      isActive=boolean(sensorButtonXML.getContent());
    }
  sensorsHM.put(sensorNum,this);
  msgBoxSensor=new MessageBox(sensorWindow,0,sensorNum*22+22,-1,0,color(175),18,"S-"+nf(sensorNum,2)+":",color(50,50,250));
  }
  
//////////////////////////////////////////////////////////////////////////

  void display(){
    ellipseMode(CENTER);

    strokeWeight(1);
    stroke(color(255,255,0));
    noFill();
    
    if(isActive)
      fill(color(50,50,200));
    
    ellipse(xPos,yPos,kWidth/2,kHeight/2);
  } // display()  
  
//////////////////////////////////////////////////////////////////////////

  void pressed(){
    pressed(!isActive);
  }
  
//////////////////////////////////////////////////////////////////////////

  void pressed(boolean isActive){
    this.isActive=isActive;    
//    autoPilot.process(sensorNum,isActive);
    sensorButtonXML.setContent(str(isActive));
    saveXMLFlag=true;
    if(isActive){
      msgBoxSensor.setMessage("S-"+nf(sensorNum,2)+": "+nf(hour(),2)+":"+nf(minute(),2)+":"+nf(second(),2)+" - "+nf((millis()-mTime)/1000.0,0,1)+" sec");
      mTime=millis();
    }
            
  } // pressed

//////////////////////////////////////////////////////////////////////////

  void reset(){
    pressed(sensorDefault);
            
  } // reset

//////////////////////////////////////////////////////////////////////////

  void check(){
    if(selectedComponent==null && (mouseX-xPos)*(mouseX-xPos)/(kWidth*kWidth/4.0)+(mouseY-yPos)*(mouseY-yPos)/(kHeight*kHeight/4.0)<=1){
      cursorType=HAND;
      selectedComponent=this;
    }
    
  } // check

} // TrackSensor Class