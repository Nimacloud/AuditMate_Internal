public with sharing class opportunityController {

  @AuraEnabled(cacheable=true)
  public static List<Opportunity> getServiceData(Id id) {
    List<Opportunity> data = [SELECT Id,Name,Start_Date__c, Expiration_date__c,Frequency_of_service__c,Hourly_requirement__c,Annual_test_covered__c,Annual_test_date__c,Commitment_Terms__c,CoverageHours__c,year5_test_covered__c,year5_test_date__c, AccountId,
      (SELECT Building_NameAddress__c,Doubletime_Onsite_time__c,Doubletime_Travel_time__c,Id,Name,Opportunity__c,Overtime_Onsite_time__c,Overtime_Travel_time__c,OwnerId,Problem_reported__c,Repoted_By__c,Service_Report_Date__c,Standard_Onsite_time__c,Standard_Travel_time__c,Status__c,Technician__c,Technician_Arrival_DateTime__c,Technician_Departure_DateTime__c,Time_unit_returned_to_service__c,Vendor_Building_ID__c,Vendor_Contract_Number__c,Vendor_Equipment__c,Vendor_Notification__c,Vendor_Sales_Order__c,Vendor_Work_Order__c,Work_description__c FROM Service_Histories__r ORDER BY Service_Report_Date__c DESC)
       FROM Opportunity Where Id = :id];
    System.debug(data);
    return data;
  }

}