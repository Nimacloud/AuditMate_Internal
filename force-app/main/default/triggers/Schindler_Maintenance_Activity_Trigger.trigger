trigger Schindler_Maintenance_Activity_Trigger on Schindler_Maintenance_Activity__c (before insert) {

  /*
  Map<String,String> eqOppMap = new Map<String,String>();
  Map<String,String> eqIdMap  = new Map<String,String>();
  Set<String> eqSet = new Set<String>();
  String eqNo,opportunityId,equipmentId;
  Date arrivalDate,callPlacedDate,departureDate,dispatchedDate;
  Time arrivalTime,callPlacedTime,departureTime,dispatchedTime;

  if(trigger.isBefore && trigger.isInsert) {

    for(Schindler_Maintenance_Activity__c rec : Trigger.new) {
      if(rec.EquipNo__c != null) {
        eqNo = rec.EquipNo__c;
        if(!eqSet.contains(eqNo)) {
          eqSet.add(eqNo);
        }
      }
    }

    List<Equipment__c> eqList = [SELECT Id, Vendor_Equipment_No__c , Opportunity__c FROM Equipment__c WHERE Vendor_Equipment_No__c IN :eqSet];
    for(Equipment__c eqRec : eqList) {
      eqOppMap.put(eqRec.Vendor_Equipment_No__c, eqRec.Opportunity__c);
      eqIdMap.put(eqRec.Vendor_Equipment_No__c,eqRec.Id);
    }

    for(Schindler_Maintenance_Activity__c rec : Trigger.new) {
      if(rec.EquipNo__c != null) {
        eqNo = rec.EquipNo__c;
        if(eqOppMap.containsKey(eqNo)) {
          opportunityId = eqOppMap.get(eqNo);
          equipmentId   = eqIdMap.get(eqNo);
          rec.Opportunity__c = opportunityId;
          rec.equipment__c   = equipmentId;
        }
      }

      arrivalDate    = rec.Arrival_date__c;
      callPlacedDate = rec.Call_placed_date__c;
      dispatchedDate = rec.Dispatched_date__c;
      departureDate  = rec.Closed_date__c;

      arrivalTime    = SchindlerEquipmentUpdateHelper.getTime(rec.Arrival_time__c);
      callPlacedTime = SchindlerEquipmentUpdateHelper.getTime(rec.Call_placed_time__c);
      dispatchedTime = SchindlerEquipmentUpdateHelper.getTime(rec.Dispatched_time__c);
      departureTime  = SchindlerEquipmentUpdateHelper.getTime(rec.Closed_time__c);

      if(arrivalDate != null && arrivalTime != null) {
        rec.Arrival_DateTime__c = DateTime.newInstance(arrivalDate,arrivalTime);
      }
      if(callPlacedDate != null && callPlacedTime != null) {
        rec.Call_Placed_DateTime__c = DateTime.newInstance(callPlacedDate,callPlacedTime);
      }
      if(dispatchedDate != null && dispatchedTime != null) {
        rec.Dispatched_DateTime__c = DateTime.newInstance(dispatchedDate,dispatchedTime);
      }
      if(departureDate != null && departureTime != null) {
        rec.Departure_DateTime__c = DateTime.newInstance(departureDate,departureTime);
      }

    }

  }

  */

}