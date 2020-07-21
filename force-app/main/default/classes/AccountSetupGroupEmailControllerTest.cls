@isTest
private with sharing class AccountSetupGroupEmailControllerTest {

    @isTest
    private static void testEmailCreation() {

        Account record = [SELECT Id FROM Account LIMIT 1];

        ApexPages.StandardController std = new ApexPages.StandardController(record);
        AccountSetupGroupEmailController controller = new AccountSetupGroupEmailController(std);

        Test.setMock(HttpCalloutMock.class, new GoogleHttpMock());

        Test.startTest();
        controller.createGroupEmail();
        Test.stopTest();
    }

    @TestSetup
    private static void makeData() {

        Google_Settings__c settings = Google_Settings__c.getOrgDefaults();
        settings.Client_Id__c = '12345';
        settings.Client_Secret__c = '12345';
        settings.Redirect_Uri__c = 'https://test.com';
        settings.Refresh_Token__c = 'refreshToken';
        upsert settings;

        Account record = new Account(Name = 'Test Account');
        insert record;
    }

}