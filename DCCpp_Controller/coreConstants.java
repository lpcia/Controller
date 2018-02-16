//////////////////////////////////////////////////////////////////////////
//  DCC++ CONTROLLER: Constants
//////////////////////////////////////////////////////////////////////////

enum ButtonType{
  NORMAL,
  ONESHOT,
  HOLD,
  REVERSE,
  T_COMMAND,
  TI_COMMAND,
  Z_COMMAND
}

enum InputType{
  BIN ("[01]"),
  DEC ("[0-9]"),
  HEX ("[A-Fa-f0-9]");
  
  final String regexp;
  InputType(String regexp){
    this.regexp=regexp;
  }
}

enum CabFunction{
  F_LIGHT,
  R_LIGHT,
  D_LIGHT,
  BELL,
  HORN,
  S_HORN
}

enum ThrottleSpeed{
  FULL,
  SLOW,
  STOP,
  REVERSE,
  REVERSE_SLOW;
  
  static ThrottleSpeed index(String findName){
    for(ThrottleSpeed p : ThrottleSpeed.values()){
      if(p.name().equals(findName))
        return(p);
    }
    return(null);
  }
}