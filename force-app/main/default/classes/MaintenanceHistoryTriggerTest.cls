@isTest (SeeAllData=true)
public with sharing class MaintenanceHistoryTriggerTest {

  @isTest (SeeAllData=true)
  public static void test1() {
    Date today = Date.today();
    Schindler_Maintenance_Activity__c sma = new Schindler_Maintenance_Activity__c();
    sma.Call_placed_date__c = today;
    sma.Dispatched_date__c  = today;
    sma.Arrival_date__c     = today;
    sma.Closed_date__c      = today;
    sma.Call_placed_time__c = '9:20 AM';
    sma.Dispatched_time__c  = '10:40 AM';
    sma.Arrival_time__c     = '11:01 AM';
    sma.Closed_time__c      = '4:23 PM';
    sma.EquipNo__c          = 'S1452462';
    sma.JobID__c            = '67740594';
    sma.Name                = 'Test';
    sma.Type__c             = 'MNT';
    sma.VisitDate__c        = today;

    insert sma;
    System.debug(sma.id);
  }


}