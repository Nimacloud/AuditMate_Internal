public without sharing class SchindlerEquipmentUpdate {

  private class EquipStats {
    Integer Cat1Count        {get;set;}
    Integer Cat5Count        {get;set;}
    Integer VisitCount       {get;set;}
    Integer Last30DayCount   {get;set;}
    Integer Last12MonthCount {get;set;}
    String  VisitReason      {get;set;}
    Date    LastVisitDate    {get;set;} 
    Date    LastCat1Date     {get;set;}
    Date    LastCat5Date     {get;set;}
    Boolean HaveActivity     {get;set;}
  }

  public static String updateEq() {

    String description,equipNo,type,lType,retVal;
    Date visitDate,lastVisitDate,lastCat1Date,lastCat5Date;
    Date today         = Date.today();
    Date todayMinus30  = today.addDays(-30);
    Date todayLastYear = today.addYears(-1);
    Date nullDate      = Date.newinstance(1900,1,1);
    Map<String,EquipStats> equipStatsMap = new Map<String,EquipStats>();  
    Set <String> keySet = new Set<String>();
    Set <String> idSet  = new Set<String>();
    EquipStats currentEqRec;

    for(Schindler_Maintenance_Activity__c sma : [
      SELECT Id,VisitDate__c, Description__c,EquipNo__c,EquipName__c,Resolution__c,Type__c FROM Schindler_Maintenance_Activity__c WHERE EquipName__c != null ORDER BY EquipNo__c, VisitDate__c ASC NULLS FIRST]) {

      equipNo     = null;
      if(!String.isBlank(sma.EquipNo__c)) {
        equipNo     = sma.EquipNo__c;
      }

      description = '';
      if(!String.isBlank(sma.Description__c)) {
        description = sma.Description__c.toLowerCase();
      }
      
      visitDate = null;
      if(sma.VisitDate__c != null) {
        visitDate   = sma.VisitDate__c;
      }

      type = null;
      if(!String.isBlank(sma.Type__c)) {
        type        = sma.Type__c;
        lType       = type.toLowerCase();
      }
    
      if(equipNo != null && visitDate != null && type != null) {
        if(!equipStatsMap.containsKey(equipNo)) {
          currentEqRec = new EquipStats();
          currentEqRec.HaveActivity     = false;
          currentEqRec.Cat1Count        = 0;
          currentEqRec.Cat5Count        = 0;
          currentEqRec.VisitCount       = 0;
          currentEqRec.Last30DayCount   = 0;
          currentEqRec.Last12MonthCount = 0;
          currentEqRec.LastVisitDate    = date.newinstance(1900,1,1);
          currentEqRec.LastCat1Date     = date.newinstance(1900,1,1);
          currentEqRec.LastCat5Date     = date.newinstance(1900,1,1);
          equipStatsMap.put(equipNo,currentEqRec);
        }

        currentEqRec  = equipStatsMap.get(equipNo); 
        // Note: Cat 5 tests are often done with a 'REP' visit type.
        // Ignoring NOTIF and VST types.
        if(lType != 'notif' && lType != 'vst') {
          currentEqRec.VisitCount++;
          equipStatsMap.put(equipNo,currentEqRec);
          if(visitDate >= todayMinus30) {
            currentEqRec.Last30DayCount++;
            currentEqRec.HaveActivity = true;
            equipStatsMap.put(equipNo,currentEqRec);
          }
          if(visitDate >= todayLastYear) {
            currentEqRec.Last12MonthCount++;
            currentEqRec.HaveActivity = true;
            equipStatsMap.put(equipNo,currentEqRec);
          }
          if(description.startsWith('cat1')) {
            if(visitDate > currentEqRec.LastCat1Date) {
              currentEqRec.LastCat1Date = visitDate;
              currentEqRec.Cat1Count++;
              currentEqRec.HaveActivity = true;
              equipStatsMap.put(equipNo,currentEqRec);
            }
          } else {
            if(description.startsWith('cat5')) {
              if(visitDate > currentEqRec.LastCat5Date) {
                currentEqRec.LastCat5Date  = visitDate;
                currentEqRec.Cat5Count++;
                currentEqRec.HaveActivity = true;
                equipStatsMap.put(equipNo,currentEqRec);
              }
            } else {
               if(visitDate > currentEqRec.LastVisitDate) {
                currentEqRec.LastVisitDate = visitDate;
                currentEqRec.VisitReason = type;
                currentEqRec.HaveActivity = true;
                equipStatsMap.put(equipNo,currentEqRec);
              }
            }
          }
        }

      }
    }
    
    keySet = equipStatsMap.keySet();
    // Set VisitReason for Cats if they are the most recent date.  Non Cat visits get the reason set above.
    for(String key : keySet) {
      currentEqRec = equipStatsMap.get(key);
      if(currentEqRec.HaveActivity) {
        if(currentEqRec.LastCat1Date > currentEqRec.LastCat5Date && currentEqRec.LastCat1Date >= currentEqRec.LastVisitDate ) {
          currentEqRec.VisitReason = 'Cat 1';
        } else {
          if(currentEqRec.LastCat5Date > currentEqRec.LastCat1Date && currentEqRec.LastCat5Date >= currentEqRec.LastVisitDate ) {
            currentEqRec.VisitReason = 'Cat 5';
          }
        }
        if(currentEqRec.LastCat1Date.isSameDay(nullDate)) {
          currentEqRec.LastCat1Date = null; 
        }
        if(currentEqRec.LastCat5Date.isSameDay(nullDate)) {
          currentEqRec.LastCat5Date = null; 
        }
        if(currentEqRec.LastVisitDate.isSameDay(nullDate)) {
          currentEqRec.LastVisitDate = null; 
        }   
        equipStatsMap.put(key,currentEqRec);
        currentEqRec = equipStatsMap.get(key);
        System.debug('Latest stats for ' + key);
        System.debug(currentEqRec);
      }
    }    

    Date nextCat1Date,nextCat5Date;
    List<Equipment__c> updateList = new List<Equipment__c>();
    for(Equipment__c eq : [SELECT Cat1_Count__c,Cat5_Count__c,Id,Last_30_Day_Count__c,Last_12_Month_Count__c,Last_Cat1_Date__c,Last_Cat5_Date__c,Last_Visit_Date__c,Last_Visit_Reason__c,Next_Cat1_Date__c,Next_Cat5_Date__c,Vendor_Equipment_No__c,Visit_Count__c FROM Equipment__c WHERE Vendor_Equipment_No__c != null ORDER BY Vendor_Equipment_No__c]) {
      equipNo = eq.Vendor_Equipment_No__c;
      if(equipStatsMap.containsKey(equipNo)) {
        currentEqRec = equipStatsMap.get(equipNo);
        if(currentEqRec.HaveActivity) {
          lastCat1Date = currentEqRec.LastCat1Date;
          if(lastCat1Date != null){
            nextCat1Date = lastCat1Date.addYears(1);
            eq.Next_Cat1_Date__c = nextCat1Date;
          }
          lastCat5Date = currentEqRec.LastCat5Date;
          if(lastCat5Date != null){
            nextCat5Date = lastCat5Date.addYears(5);
            eq.Next_Cat5_Date__c = nextCat5Date;
          }
          eq.Cat1_Count__c          = currentEqRec.Cat1Count;
          eq.Cat5_Count__c          = currentEqRec.Cat5Count;
          eq.Last_30_Day_Count__c   = currentEqRec.Last30DayCount;
          eq.Last_12_Month_Count__c = currentEqRec.Last12MonthCount;
          eq.Last_Cat1_Date__c      = currentEqRec.LastCat1Date;
          eq.Last_Cat5_Date__c      = currentEqRec.LastCat5Date;
          eq.Last_Visit_Date__c     = currentEqRec.LastVisitDate;
          eq.Last_Visit_Reason__c   = currentEqRec.VisitReason;
          eq.Visit_Count__c         = currentEqRec.VisitCount;
        } else {
          eq.Last_30_Day_Count__c   = 0;
          eq.Last_12_Month_Count__c  = 0;
        }
      } else {
        eq.Last_30_Day_Count__c    = 0;
        eq.Last_12_Month_Count__c  = 0;
      }
      updateList.add(eq);
    }

    retVal = 'ok';
    Database.SaveResult[] srList = Database.update(updateList, false);
    for (Database.SaveResult sr : srList) {
      if (!sr.isSuccess()) {
        // Operation failed, so get all errors                
        retVal = 'Errors - check log';
        for(Database.Error err : sr.getErrors()) {
          System.debug('The following error has occurred.');                    
          System.debug(err.getStatusCode() + ': ' + err.getMessage());
        }
      }
    }
    return retVal;
  }

}