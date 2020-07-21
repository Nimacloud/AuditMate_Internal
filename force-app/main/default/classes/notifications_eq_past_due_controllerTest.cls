@isTest (SeeAllData=false)
public without sharing class notifications_eq_past_due_controllerTest {

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

    notifications_eq_past_due_controller testCtrl = new notifications_eq_past_due_controller();
    string myRequest;

    String result1 = testCtrl.getMyRequest();
    System.debug(result1);
    System.assertEquals('this is default request', result1);
    
	  testCtrl.emailRecipient = 'Pusscat';
    String result2 = testCtrl.getMyRequest();
    System.debug(result2);
    System.assertEquals('return link for portal customer Pusscat', result2);
    
    List<NotificationItem__c> myList = new  List<NotificationItem__c>();
    myList = testCtrl.Notifications;
    System.debug(myList);

    // WHERE Notification__r.Current__c = true
    List<NotificationItem__c> notList = [SELECT Id FROM NotificationItem__c LIMIT 1];
    Id notId = notList[0].Id;

    testCtrl.itemId = notId;
    myList = testCtrl.Notifications;
    Integer listLen = myList.size();
    System.assertNotEquals(0, listLen);
  }
}