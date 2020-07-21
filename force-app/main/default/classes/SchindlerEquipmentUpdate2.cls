public without sharing class SchindlerEquipmentUpdate2 {

  private class EquipStats {
    Integer Cat1Count          {get;set;}
    Integer Cat5Count          {get;set;}
    Integer VisitCount         {get;set;}
    Integer Last30DayCount     {get;set;}
    Integer Last12MonthCount   {get;set;}
    Integer Last12MonthCbCount {get;set;}
    Decimal Last12MonthPmCount {get;set;}
    String  VisitReason        {get;set;}
    Date    LastVisitDate      {get;set;} 
    Date    LastPmVisitDate    {get;set;} 
    Date    LastCbVisitDate    {get;set;} 
    Date    LastCat1Date       {get;set;}
    Date    LastCat5Date       {get;set;}
    Boolean HaveActivity       {get;set;}
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
    EquipStats mapStatRec;

    for(Schindler_Maintenance_Activity__c sma : [
      SELECT Id,VisitDate__c, Description__c,EquipNo__c,EquipName__c,Resolution__c,Type__c 
      FROM Schindler_Maintenance_Activity__c 
      WHERE EquipName__c != null ORDER BY EquipNo__c, VisitDate__c ASC NULLS FIRST]) {

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
          mapStatRec = new EquipStats();
          mapStatRec.HaveActivity       = false;
          mapStatRec.Cat1Count          = 0;
          mapStatRec.Cat5Count          = 0;
          mapStatRec.VisitCount         = 0;
          mapStatRec.Last30DayCount     = 0;
          mapStatRec.Last12MonthCount   = 0;
          mapStatRec.Last12MonthCbCount = 0;
          mapStatRec.Last12MonthPmCount = 0;
          mapStatRec.LastPmVisitDate    = date.newinstance(1900,1,1);
          mapStatRec.LastCbVisitDate    = date.newinstance(1900,1,1);
          mapStatRec.LastVisitDate      = date.newinstance(1900,1,1);
          mapStatRec.LastCat1Date       = date.newinstance(1900,1,1);
          mapStatRec.LastCat5Date       = date.newinstance(1900,1,1);
          
          equipStatsMap.put(equipNo,mapStatRec);
        }

        mapStatRec  = equipStatsMap.get(equipNo); 
        // Note: Cat 5 tests are often done with a 'REP' visit type.
        // Ignoring NOTIF and VST types.
        if(lType != 'notif' && lType != 'vst') {
          mapStatRec.VisitCount++;
          equipStatsMap.put(equipNo,mapStatRec);
          if(visitDate >= todayMinus30) {
            mapStatRec.Last30DayCount++;
            mapStatRec.HaveActivity = true;
            equipStatsMap.put(equipNo,mapStatRec);
          }

          if(lType == 'mnt') {
            mapStatRec.LastPmVisitDate = visitDate;
            mapStatRec.HaveActivity = true;
            equipStatsMap.put(equipNo,mapStatRec);
          }

          if(lType == 'cb') {
            mapStatRec.LastCbVisitDate = visitDate;
            mapStatRec.HaveActivity = true;
            equipStatsMap.put(equipNo,mapStatRec);
          }

          if(visitDate >= todayLastYear) {
            mapStatRec.Last12MonthCount++;
            mapStatRec.HaveActivity = true;
            if(lType == 'mnt') {
              mapStatRec.Last12MonthPmCount++;
            }
            // For PM % Calc, include CAT1 and CAT5 as PM visits
            if(description.startsWith('cat1')) {
              mapStatRec.Last12MonthPmCount++;
            }
            if(description.startsWith('cat5')) {
              mapStatRec.Last12MonthPmCount++;
            }

            if(lType == 'cb') {
              mapStatRec.Last12MonthCbCount++;
            }
            equipStatsMap.put(equipNo,mapStatRec);
          }

          if(description.startsWith('cat1')) {
            if(visitDate > mapStatRec.LastCat1Date) {
              mapStatRec.LastCat1Date = visitDate;
              mapStatRec.Cat1Count++;
              mapStatRec.HaveActivity = true;
              equipStatsMap.put(equipNo,mapStatRec);
            }
          } else {
            if(description.startsWith('cat5')) {
              if(visitDate > mapStatRec.LastCat5Date) {
                mapStatRec.LastCat5Date  = visitDate;
                mapStatRec.Cat5Count++;
                mapStatRec.HaveActivity = true;
                equipStatsMap.put(equipNo,mapStatRec);
              }
            } else {
               if(visitDate > mapStatRec.LastVisitDate) {
                mapStatRec.LastVisitDate = visitDate;
                mapStatRec.VisitReason = type;
                mapStatRec.HaveActivity = true;
                equipStatsMap.put(equipNo,mapStatRec);
              }
            }
          }
        }

      }
    }
    
    keySet = equipStatsMap.keySet();
    // Set VisitReason for Cats if they are the most recent date.  Non Cat visits get the reason set above.
    for(String key : keySet) {
      mapStatRec = equipStatsMap.get(key);
      if(mapStatRec.HaveActivity) {
        if(mapStatRec.LastCat1Date > mapStatRec.LastCat5Date && mapStatRec.LastCat1Date >= mapStatRec.LastVisitDate ) {
          mapStatRec.VisitReason = 'Cat 1';
        } else {
          if(mapStatRec.LastCat5Date > mapStatRec.LastCat1Date && mapStatRec.LastCat5Date >= mapStatRec.LastVisitDate ) {
            mapStatRec.VisitReason = 'Cat 5';
          }
        }
        if(mapStatRec.LastCat1Date.isSameDay(nullDate)) {
          mapStatRec.LastCat1Date = null; 
        }
        if(mapStatRec.LastCat5Date.isSameDay(nullDate)) {
          mapStatRec.LastCat5Date = null; 
        }
        if(mapStatRec.LastVisitDate.isSameDay(nullDate)) {
          mapStatRec.LastVisitDate = null; 
        }   
        equipStatsMap.put(key,mapStatRec);
        mapStatRec = equipStatsMap.get(key);
        System.debug('Latest stats for ' + key);
        System.debug(mapStatRec);
      }
    }    
    
    Date nextCat1Date,nextCat5Date;
    Integer cat1DaysLate,cat5DaysLate,nextPmDaysLate;
    Date cat1DueDate,cat5DueDate,nextPmDueDate;
    List<Equipment__c> updateList = new List<Equipment__c>();

    Decimal pmPercent;
    Boolean hasMonthlyRequiement;
    for(Equipment__c eqRec : [
      SELECT Has_Monthly_Requirement__c,Last_CB_Date__c,Last_PM_Date__c,Next_PM_Date__c, Debug__c,Last_12_Month_PM_Message__c,Last_12_Month_CB_Count__c,Last_12_Month_PM_Count__c,Last_12_Month_PM_Percent__c, Cat1_Message__c, Days_PM_Past_Due__c, Cat5_Message__c, Days_CAT1_Past_Due__c,Days_CAT5_Past_Due__c,Cat1_Count__c,Cat5_Count__c,Id,Last_30_Day_Count__c,Last_12_Month_Count__c,Last_Cat1_Date__c,Last_Cat5_Date__c,Last_Visit_Date__c,Last_Visit_Reason__c,Next_Cat1_Date__c,Next_Cat5_Date__c,Vendor_Equipment_No__c,Visit_Count__c 
      FROM Equipment__c 
      WHERE Vendor_Equipment_No__c != null 
      ORDER BY Vendor_Equipment_No__c]) {
      equipNo = eqRec.Vendor_Equipment_No__c;
      System.Debug('--------------------');
      System.Debug(equipNo);
      System.Debug('--------------------');
      eqRec.Debug__c = '';  
      hasMonthlyRequiement = false;    
      if(equipStatsMap.containsKey(equipNo)) {
        mapStatRec = equipStatsMap.get(equipNo);
        if(mapStatRec.HaveActivity) {

          lastCat1Date = mapStatRec.LastCat1Date;
          if(lastCat1Date != null){
            nextCat1Date = lastCat1Date.addYears(1);
            if(eqRec.Next_Cat1_Date__c < nextCat1Date) {
              eqRec.Next_Cat1_Date__c = nextCat1Date;
              eqRec.Debug__c += '\n Next CAT1 date replaced by more recent Schindler CAT1 Maintenance record.';
            }
          }

          lastCat5Date = mapStatRec.LastCat5Date;
          if(lastCat5Date != null){
            nextCat5Date = lastCat5Date.addYears(5); 
            if(eqRec.Next_Cat5_Date__c < nextCat5Date)  {
              eqRec.Next_Cat5_Date__c = nextCat5Date;
              eqRec.Debug__c += '\n State Next CAT5 date replaced by Schindler CAT5 Maintenance record.';
            }
          }

          eqRec.Cat1_Count__c               = mapStatRec.Cat1Count;
          eqRec.Cat5_Count__c               = mapStatRec.Cat5Count;
          eqRec.Last_30_Day_Count__c        = mapStatRec.Last30DayCount;
          eqRec.Last_12_Month_Count__c      = mapStatRec.Last12MonthCount;
          eqRec.Last_12_Month_CB_Count__c   = mapStatRec.Last12MonthCbCount;
          eqRec.Last_12_Month_PM_Count__c   = mapStatRec.Last12MonthPmCount;

          if(eqRec.Has_Monthly_Requirement__c) {
            if(mapStatRec.Last12MonthPmCount > 0) {
              hasMonthlyRequiement = true;
              Decimal last12MonthPmCount = mapStatRec.Last12MonthPmCount;
              pmPercent = (last12MonthPmCount / 12) * 100;
              eqRec.Last_12_Month_PM_Percent__c = pmPercent.setscale(0);
              eqRec.Last_12_Month_PM_Message__c = 'Unit has received ' + pmPercent.setscale(0).format() + '% of expected visits within the last 12 months.';
            } else {
              System.debug('No monthly PM requirement');
            }
          } else {
            System.debug('No PM visits in last 12 months');
          }
          
          if(!mapStatRec.LastPmVisitDate.isSameDay(nullDate)) {
            eqRec.Last_PM_Date__c       = mapStatRec.LastPmVisitDate;
            eqRec.Next_PM_Date__c       = mapStatRec.LastPmVisitDate.addDays(30);
          }

          if(!mapStatRec.LastCbVisitDate.isSameDay(nullDate)) {
            eqRec.Last_CB_Date__c       = mapStatRec.LastCbVisitDate;
          }
          
          eqRec.Last_Cat1_Date__c      = mapStatRec.LastCat1Date;
          eqRec.Last_Cat5_Date__c      = mapStatRec.LastCat5Date;
          eqRec.Last_Visit_Date__c     = mapStatRec.LastVisitDate;
          eqRec.Last_Visit_Reason__c   = mapStatRec.VisitReason;
          eqRec.Visit_Count__c         = mapStatRec.VisitCount;
        } else {
          eqRec.Last_30_Day_Count__c   = 0;
          eqRec.Last_12_Month_Count__c  = 0;
        }
      } else {
        System.Debug('----- NOT FOUND EquipNo in Stats ----');
        eqRec.Last_30_Day_Count__c    = 0;
        eqRec.Last_12_Month_Count__c  = 0;
      }

       // Look for Days Late.....
       if(eqRec.Has_Monthly_Requirement__c) {
//     if(hasMonthlyRequiement) {
        if(eqRec.Next_PM_Date__c != null) {
          nextPmDueDate  = eqRec.Next_PM_Date__c;
          nextPmDaysLate = nextPmDueDate.daysBetween(today);
          if(nextPmDaysLate > 0) {
            eqRec.Days_PM_Past_Due__c = nextPmDaysLate;
            eqRec.PM_Message__c = 'PM is ' + nextPmDaysLate.format() + ' days late.';
          } else {
            eqRec.Days_PM_Past_Due__c = 0;
            eqRec.PM_Message__c = 'PM has ' + Math.Abs(nextPmDaysLate).format() + ' days before due.';
          }
        } else {
          eqRec.Days_PM_Past_Due__c = 999; // Make it obvious we don't have a PM date.
          eqRec.PM_Message__c = 'No record of a PM visit.';
        }
      }

      if(eqRec.Next_Cat1_Date__c != null) {
        cat1DueDate  = eqRec.Next_Cat1_Date__c;
        cat1DaysLate = cat1DueDate.daysBetween(today);
        if(cat1DaysLate > 0) {
          eqRec.Days_CAT1_Past_Due__c = cat1DaysLate;
          eqRec.Cat1_Message__c = 'CAT1 is ' + cat1DaysLate.format() + ' days late.';
        } else {
          eqRec.Days_CAT1_Past_Due__c = 0;
          eqRec.Cat1_Message__c = 'CAT1 has ' + Math.Abs(cat1DaysLate).format() + ' days before due.';
        }
      } else {
        eqRec.Days_CAT1_Past_Due__c = 999; // Make it obvious we don't have a CAT1 date.
        eqRec.Cat1_Message__c = 'No record of a CAT1 Test.';
      }

      if(eqRec.Next_Cat5_Date__c != null) {
        cat5DueDate  = eqRec.Next_Cat5_Date__c;
        cat5DaysLate = cat5DueDate.daysBetween(today);
        if(cat5DaysLate > 0) {
          eqRec.Days_CAT5_Past_Due__c = cat5DaysLate;
          eqRec.Cat5_Message__c = 'CAT5 is ' + cat5DaysLate.format() + ' days late.';
        } else {
          eqRec.Days_CAT5_Past_Due__c = 0;
          eqRec.Cat5_Message__c = 'CAT5 has ' + Math.Abs(cat5DaysLate).format() + ' days before due.';
        }
      } else {
        eqRec.Days_CAT5_Past_Due__c = 999; // Make it obvious we don't have a CAT5 date.
        eqRec.Cat5_Message__c = 'No record of a CAT5 Test.';
        System.debug('We don\'t have a CAT5 date from Schindler or the State, so setting CAT5 999 days late!.');
      }

      updateList.add(eqRec);
    }

    retVal = 'ok';
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
 
}