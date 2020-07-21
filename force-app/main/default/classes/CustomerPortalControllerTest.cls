@IsTest (SeeAllData=true)
public with sharing class CustomerPortalControllerTest {

  @IsTest public static void Test1() {
    List<Account> data = CustomerPortalController.getAccounts();
    System.assertNotEquals(0, data.size());
  }

  @IsTest public static void Test2() {
    List<Equipment__c> eqList = [SELECT  Opportunity__r.AccountId FROM Equipment__c WHERE Opportunity__r.AccountId != null LIMIT 1];
    String acctId = eqList[0].Opportunity__r.AccountId;
    List<Equipment__c> data = CustomerPortalController.getAccountEquipment(acctId);
    System.assertNotEquals(0, data.size());
  }

  @IsTest public static void Test3() {
    List<Schindler_Invoice_History__c> invList = [SELECT  Opportunity__r.AccountId FROM Schindler_Invoice_History__c  WHERE Opportunity__r.AccountId  != null LIMIT 1]; 
    String acctId = invList[0].Opportunity__r.AccountId;
    List<Schindler_Invoice_History__c> data = CustomerPortalController.getAccountInvoices(acctId);
    System.assertNotEquals(0, data.size());
  }

  @IsTest public static void Test4() {
    List<Schindler_Maintenance_Activity__c> maintList = [SELECT  Opportunity__r.AccountId FROM Schindler_Maintenance_Activity__c  WHERE Opportunity__r.AccountId  != null LIMIT 1]; 
    String acctId = maintList[0].Opportunity__r.AccountId;
    List<Schindler_Maintenance_Activity__c> data = CustomerPortalController.getAccountMaintenance(acctId);
    System.assertNotEquals(0, data.size());
  }

}