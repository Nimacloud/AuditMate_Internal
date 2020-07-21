@isTest (SeeAllData=true)
public without sharing class InvoicePageControllerTest {

 @isTest
  public static void Test1(){ 
    List<ServiceHistory__c> data = InvoicePageController.getAllTimeTickets();
    Integer listLength = data.size();
    System.assertNotEquals(0, listLength);
  }

 @isTest
  public static void Test2(){ 
    List<Schindler_Invoice_History__c> data = InvoicePageController.getAllInvoices();
    Integer listLength = data.size();
    System.assertNotEquals(0, listLength);
  }

 @isTest
  public static void Test3(){ 
    List<Equipment__c> data = InvoicePageController.getAllEquipment();
    Integer listLength = data.size();
    System.assertNotEquals(0, listLength);

    String oppid = data[0].Opportunity__c;
    List<Equipment__c> data2 = InvoicePageController.getOpportunityEquipment(oppid);
    Integer listLength2 = data2.size();
    System.assertNotEquals(0, listLength2);

  }

 @isTest
  public static void Test4(){ 
    List<Schindler_Maintenance_Activity__c> data = InvoicePageController.getAllMaintenanceVisits();
    Integer listLength = data.size();
    System.assertNotEquals(0, listLength);
  }


}