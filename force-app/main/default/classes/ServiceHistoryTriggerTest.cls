@isTest // (SeeAllData=true)
public without sharing class ServiceHistoryTriggerTest {

  @isTest
  public static void test1() {
    ServiceHistory__c sh = new ServiceHistory__c();
    sh.Equipment_Name__c   = 'Test';
    sh.Vendor_Equipment__c = 'S1452462';
    insert sh;
    System.debug(sh.id);
  }

}