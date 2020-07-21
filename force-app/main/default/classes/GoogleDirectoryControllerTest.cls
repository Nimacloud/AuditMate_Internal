@isTest
private with sharing class GoogleDirectoryControllerTest {

    @isTest
    private static void coverGoogleMethods() {

        ApexPages.currentPage().getParameters().put('code', 'code');

        Test.setMock(HttpCalloutMock.class, new GoogleHttpMock());

        Test.startTest();

        GoogleDirectoryController controller = new GoogleDirectoryController();
        controller.init();
        controller.getClientId();
        controller.getRedirectUri();
        controller.getScopes();

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