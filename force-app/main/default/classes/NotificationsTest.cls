@isTest
public without sharing class NotificationsTest {
    
  @testSetup static void setup() {

    Account testAccount1 = new Account();
    testAccount1.Name = 'My Test Account 1';
    insert testAccount1;

    Account testAccount2 = new Account();
    testAccount2.Name = 'My Test Account 2';
    insert testAccount2;

    Opportunity testOpp1 = new Opportunity();
    testOpp1.AccountId = testAccount1.Id;
    testOpp1.Name      = 'My Test Opp 1';
    testOpp1.StageName = 'Closed-Vendor Contract';
    testOpp1.CloseDate = Date.today();
    insert testOpp1;

    Opportunity testOpp2 = new Opportunity();
    testOpp2.AccountId = testAccount2.Id;
    testOpp2.Name      = 'My Test Opp 2';
    testOpp2.StageName = 'Closed-Vendor Contract';
    testOpp2.CloseDate = Date.today();
    insert testOpp2;

    Equipment__c testEq1 = new Equipment__c();
    testEq1.Name                  = 'My Test Eq 1';
    testEq1.Last_Visit_Date__c    = Date.today();
    testEq1.Opportunity__c        = testOpp1.Id;
    testEq1.Days_CAT1_Past_Due__c = 10;
    testEq1.Days_CAT5_Past_Due__c = 20;
    testEq1.Days_PM_Past_Due__c   = 30;
    insert testEq1;

    Equipment__c testEq2 = new Equipment__c();
    testEq2.Name                  = 'My Test Eq 2';
    testEq2.Last_Visit_Date__c    = Date.today();
    testEq2.Opportunity__c        = testOpp2.Id;
    testEq2.Days_CAT1_Past_Due__c = 10;
    testEq2.Days_CAT5_Past_Due__c = 20;
    testEq2.Days_PM_Past_Due__c   = 30;
    insert testEq2;

    Notification__c testMaster = new Notification__c();
    testMaster.Account__c          = testAccount1.Id;
    testMaster.NotificationType__c = 'Eq_Past_Due';
    testMaster.Max_Count__c        = 33;
    testMaster.Send_Count__c       = 0;
    testMaster.Date_First_Sent__c  = null;
    testMaster.Date_Last_Sent__c   = null;
    testMaster.User_Disabled__c    = false;
    insert testMaster;

    NotificationItem__c testDetail = new NotificationItem__c();
    testDetail.Equipment__c    = testEq1.Id;
    testDetail.Notification__c = testMaster.Id;
    insert testDetail;

  }

  @isTest
  public static void test1() {

    List<Notification__c> notificationList = [
      SELECT Account__c,Account__r.Name,Date_First_Sent__c,Date_Last_Sent__c,Id,Max_Count__c,Send_Count__c,NotificationType__c ,User_Disabled__c,
      (SELECT Equipment__c,Equipment__r.Vendor_Equipment_No__c FROM NotificationItems__r)
      FROM Notification__c 
      WHERE Max_Count__c = 33
      ORDER BY Account__r.Name, NotificationType__c, Date_Last_Sent__c Desc
    ];
    System.debug('notificationList');
    System.debug(notificationList);
    Notifications.equipmentNotifications();
  }

  @isTest
  public static void test2() {
    List<Account> accountList = [SELECT Id FROM Account      WHERE Name = 'My Test Account 2'];
    List<Equipment__c> eqList = [SELECT Id FROM Equipment__c WHERE Name = 'My Test Eq 2'];
    List<Id> eqIdList = new List<Id>();
    eqIdList.add(eqList[0].Id);
    Notifications.requestUpdate(accountList[0].Id, eqIdList);
  }

  @isTest
  public static void test3() {
    List<Account> accountList = [SELECT Id FROM Account      WHERE Name = 'My Test Account 1'];
    Id accId = accountList[0].Id;
    Notifications.getUpdates(accId,'Eq_Request');
  }

}