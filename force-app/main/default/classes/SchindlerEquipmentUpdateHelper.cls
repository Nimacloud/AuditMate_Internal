public with sharing class SchindlerEquipmentUpdateHelper {

  public static string updateEquimentCat5DatesFromStateData() {
   
    Boolean foundStateCat5Record = false;
    List<State_Inspection__c> inspectionList;
    List<Equipment__c> updateList = new List<Equipment__c>();
    State_Inspection__c mostRecentInspection;
    Date lastStateCat5Date,nextStateCat5Date;
    String lastStateCat5Result;
    //WHERE Vendor_Equipment_No__c IN ('S9767560','s1008369')
    for(List<Equipment__c> dataList : [SELECT Id,Vendor_Equipment_No__c,Display_Name__c,Debug__c,Last_State_CAT5_Date__c,Last_State_CAT5_Result__c,Last_Cat5_Date__c,Next_Cat5_Date__c,(SELECT Completed_Date__c,Result__c,Scheduled_Date__c,State_ID__c,Type_of_Inspection__c,Vendor_Equipment_Number__c FROM State_Inspections__r ORDER BY Completed_Date__c Desc) 
      FROM Equipment__c]
      ){
      System.Debug('Datalist:'   + dataList.size().format());
      for(Equipment__c eqRec : dataList) {
        eqRec.Debug__c = '';
    //  System.Debug(eqRec.Vendor_Equipment_No__c + ' - ' + eqRec.Display_Name__c);
        if(eqRec.State_Inspections__r.size() == 0) {
    //    System.debug(eqRec);
          System.Debug('--- no inspections for ' + eqRec.Vendor_Equipment_No__c  + '  ----');
        } else {
          inspectionList = eqRec.State_Inspections__r;
          foundStateCat5Record = false;
          for(State_Inspection__c inspectionRec : inspectionList) {
            if((inspectionRec.Type_of_Inspection__c == 'ELV-5 YEAR'        ||
              inspectionRec.Type_of_Inspection__c == 'ELV-ACCEPTANCE'    ||
              inspectionRec.Type_of_Inspection__c == 'ELV-RE-INSPECTION') && inspectionRec.Result__c == 'PASS') {
              if(inspectionRec.Completed_Date__c != null) {
                lastStateCat5Date = inspectionRec.Completed_Date__c;
                nextStateCat5Date = lastStateCat5Date.addYears(5);
                lastStateCat5Result = inspectionRec.Result__c;
                eqRec.Debug__c = 'Last State CAT5 Result ' + lastStateCat5Result + '\n';
                eqRec.Last_State_CAT5_Date__c   = lastStateCat5Date;
                eqRec.Last_State_CAT5_Result__c = lastStateCat5Result;
                
                if(eqRec.Last_Cat5_Date__c == null) {
                  eqRec.Last_Cat5_Date__c = lastStateCat5Date;
                  eqRec.Next_Cat5_Date__c = nextStateCat5Date;
                  eqRec.Debug__c += '\n Empty Last Cat5 Date replaced wtih Last State CAT5 Date: ' + lastStateCat5Date.format();
                  eqRec.Debug__c += '\n Next Cat5 Date replaced wtih Last State CAT5 Date + 5 years: ' + nextStateCat5Date.format();
                } else {
                  if(eqRec.Last_Cat5_Date__c < lastStateCat5Date) {
                    eqRec.Last_Cat5_Date__c = lastStateCat5Date;
                    eqRec.Next_Cat5_Date__c = nextStateCat5Date;
                    eqRec.Debug__c += '\n Earlier Last Cat5 Date replaced wtih Last State CAT5 Date: ' + lastStateCat5Date.format();
                    eqRec.Debug__c += '\n Next Cat5 Date replaced wtih Last State CAT5 Date + 5 years: ' + nextStateCat5Date.format();
                  }
                }
                foundStateCat5Record = true;
                break;
              }
            }
          }
          if(foundStateCat5Record) {
            updateList.add(eqRec);
       //   System.Debug(eqRec.Vendor_Equipment_No__c + ' - FOUND CAT 5');
          } else {
            System.Debug(eqRec.Vendor_Equipment_No__c + ' - NO CAT 5 FOUND');
          }
        }
      }
    }

    
    System.Debug('UpdateList:' + updateList.size().format());
    String retVal = 'ok';
    Database.SaveResult[] srList = Database.update(updateList, false);
    for (Database.SaveResult sr : srList) {
      if (!sr.isSuccess()) {
        retVal = 'Errors - check log';
        for(Database.Error err : sr.getErrors()) {
          System.debug(err.getStatusCode() + ': ' + err.getMessage());
        }
      }
    }
    return retVal;
  }

  public static Time getTime(String timeStr)  {
    if(String.isBlank(timeStr)) {
      return null;
    }
    String[] timeParts  = timeStr.split(' ');
    String[] timeDT     = timeParts[0].split(':');
    String timeHourStr  = timeDT[0];
    String timeMinStr   = timeDT[1];
    Integer timeHourInt = Integer.valueOf(timeHourStr);
    Integer timeMinInt  = Integer.valueOf(timeMinStr);
    if(timeParts[1] == 'PM') {
      timeHourInt+=12;
    }
    Time result = Time.newInstance(timeHourInt, timeMinInt, 0, 0);
    result = result.addHours(8); // UTC offset required.  Question: Does this need adjusting for customer's time zone?
    return result;
  }

}