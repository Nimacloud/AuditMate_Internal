public with sharing class DateDifference {
  // Taken from https://developer.salesforce.com/forums/?id=906F00000008vmkIAA (A Dev in NZ's answer)

  public class diffWrapper {
    public Integer Days {get;set;}
    public Integer Hours {get;set;}
    public Integer Minutes {get;set;}
    public Integer Seconds {get;set;}
  }
  
  public static diffWrapper getDifference(Datetime d1, Datetime d2) {
    decimal millisecs = decimal.valueOf(d2.getTime() - d1.getTime());
    system.debug('millisecs: ' +millisecs);
    
    decimal dDays = millisecs/1000/60/60/24;
    integer iDays = integer.valueOF(math.floor(dDays));
    decimal remainderDays = dDays- iDays;
    
    decimal dHours = remainderDays * 24;
    integer iHours = integer.valueOf(math.floor(dHours));
    decimal remainderHours = dHours - iHours;
    
    decimal dMinutes = remainderHours * 60;
    integer iMinutes = integer.valueOf(math.floor(dMinutes));
    decimal remainderMinutes = dMinutes - iMinutes;
    
    decimal dSeconds = remainderMinutes * 60;
    integer iSeconds = integer.valueOf(math.floor(dSeconds));
    decimal remainderSeconds = dSeconds - iSeconds;
    
    diffWrapper retVal = new diffWrapper();
    retVal.Days     = iDays;
    retVal.Hours    = iHours;
    retVal.Minutes  = iMinutes;
    retVal.Seconds  = iSeconds;
    return retVal;
  }
}