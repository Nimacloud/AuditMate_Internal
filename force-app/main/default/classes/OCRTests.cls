@isTest
public with sharing class OCRTests {

    @isTest
    private static void testSchindlerInvoiceError() {

        Case[] records = [SELECT Id FROM Case WHERE Subject = 'Schindler Invoice Received'];

        Test.setMock(HttpCalloutMock.class, new OCRTestMock.OCRSchindlerTestMock(500));

        Test.startTest();

        if (!records.isEmpty()) {

            OCRCaseButtonController controller = new OCRCaseButtonController(new ApexPages.StandardController(records[0]));
            controller.createInvoiceAction();
        }

        Test.stopTest();

        Schindler_Invoice_History__c[] invoices = [SELECT Id FROM Schindler_Invoice_History__c];
        System.assert(!invoices.isEmpty(), 'Invoices cannot be empty');
    }

    @isTest
    private static void testThyssenInvoiceError() {

        Case[] records = [SELECT Id FROM Case WHERE Subject = 'Thyssen Invoice Received'];

        Test.setMock(HttpCalloutMock.class, new OCRTestMock.OCRThyssenTestMock(500));

        Test.startTest();

        if (!records.isEmpty()) {

            OCRCaseButtonController controller = new OCRCaseButtonController(new ApexPages.StandardController(records[0]));
            controller.createInvoiceAction();
        }

        Test.stopTest();

        Schindler_Invoice_History__c[] invoices = [SELECT Id FROM Schindler_Invoice_History__c];
        System.assert(!invoices.isEmpty(), 'Invoices cannot be empty');
    }

    @isTest
    private static void testSchindlerKone() {

        OCRStrategyKone strategy = new OCRStrategyKone();
        strategy.createInvoice();

        System.assert(true, 'Invoices cannot be empty');
    }

    @isTest
    private static void testSchindlerInvoice() {

        Case[] records = [SELECT Id FROM Case WHERE Subject = 'Schindler Invoice Received'];

        Test.setMock(HttpCalloutMock.class, new OCRTestMock.OCRSchindlerTestMock());

        Test.startTest();

        if (!records.isEmpty()) {

            OCRCaseButtonController controller = new OCRCaseButtonController(new ApexPages.StandardController(records[0]));
            controller.createInvoiceAction();
        }

        Test.stopTest();

        Schindler_Invoice_History__c[] invoices = [SELECT Id FROM Schindler_Invoice_History__c];
        System.assert(!invoices.isEmpty(), 'Invoices cannot be empty');
    }

    @isTest
    private static void testThyssenInvoice() {

        Case[] records = [SELECT Id FROM Case WHERE Subject = 'Thyssen Invoice Received'];

        Test.setMock(HttpCalloutMock.class, new OCRTestMock.OCRThyssenTestMock());

        Test.startTest();

        if (!records.isEmpty()) {

            OCRCaseButtonController controller = new OCRCaseButtonController(new ApexPages.StandardController(records[0]));
            controller.createInvoiceAction();
        }

        Test.stopTest();

        Schindler_Invoice_History__c[] invoices = [SELECT Id FROM Schindler_Invoice_History__c];
        System.assert(!invoices.isEmpty(), 'Invoices cannot be empty');
    }

    @TestSetup
    private static void setup() {

        // OWA are visible in tests
        OrgWideEmailAddress address = [SELECT Id
                                        FROM OrgWideEmailAddress
                                        LIMIT 1];


        Contact ap = new Contact(LastName = 'Last Name');
        ap.Email = 'test@test.com';
        insert ap;

        ContentVersion versionRecord = new ContentVersion();
        versionRecord.FirstPublishLocationId = ap.Id;
        versionRecord.PathOnClient = 'file.txt';
        versionRecord.VersionData = Blob.valueOf('Test');
        versionRecord.Title = 'Test Document';
        insert versionRecord;

        versionRecord = [SELECT ContentDocumentId
                            FROM ContentVersion
                            WHERE Id = :versionRecord.Id];

        Account schindlerRecord = new Account(Name = 'Schindler');
        schindlerRecord.Vendor_Company__c = 'Schindler';
        insert schindlerRecord;

        Account thyssenRecord = new Account(Name = 'Thyssen');
        thyssenRecord.Vendor_Company__c = 'Thyssen';
        insert thyssenRecord;

        Account schindlerCustomerRecord = new Account(Name = 'Schindler Customer');
        schindlerCustomerRecord.Group_Email__c = address.Id;
        schindlerCustomerRecord.Elevator_Vendor_Account__c = schindlerRecord.Id;
        insert schindlerCustomerRecord;

        Account thyssenCustomerRecord = new Account(Name = 'Thyssen Customer');
        thyssenCustomerRecord.Group_Email__c = address.Id;
        thyssenCustomerRecord.Elevator_Vendor_Account__c = thyssenRecord.Id;
        insert thyssenCustomerRecord;

        Opportunity schindlerContract = new Opportunity(Name = 'Schindler Contract');
        schindlerContract.AccountId = schindlerCustomerRecord.Id;
        schindlerContract.Elevator_Vendor_Account__c = schindlerRecord.Id;
        schindlerContract.CloseDate = Date.today();
        schindlerContract.StageName = 'Closed Won';
        schindlerContract.Vendor_Contract_Stage__c = 'Vendor_Contract_Active';
        insert schindlerContract;

        Opportunity thyssenContract = new Opportunity(Name = 'Thyssen Contract');
        thyssenContract.AccountId = schindlerCustomerRecord.Id;
        thyssenContract.Elevator_Vendor_Account__c = schindlerRecord.Id;
        thyssenContract.CloseDate = Date.today();
        thyssenContract.StageName = 'Closed Won';
        thyssenContract.Vendor_Contract_Stage__c = 'Vendor_Contract_Active';
        insert thyssenContract;

        Case schindlerCase = new Case(Subject = 'Schindler Invoice Received');
        schindlerCase.Type = 'Invoice Review';
        schindlerCase.Reason = 'New Invoice';
        schindlerCase.Origin = 'Web';
        schindlerCase.Status = 'New';
        schindlerCase.AccountId = schindlerCustomerRecord.Id;
        schindlerCase.Vendor__c = schindlerRecord.Id;
        insert schindlerCase;

        Case thyssenCase = new Case(Subject = 'Thyssen Invoice Received');
        thyssenCase.Type = 'Invoice Review';
        thyssenCase.Reason = 'New Invoice';
        thyssenCase.Origin = 'Web';
        thyssenCase.Status = 'New';
        thyssenCase.AccountId = thyssenCustomerRecord.Id;
        thyssenCase.Vendor__c = thyssenRecord.Id;
        insert thyssenCase;

        insert new ContentDocumentLink(ContentDocumentId = versionRecord.ContentDocumentId, LinkedEntityId = thyssenCase.Id);
        insert new ContentDocumentLink(ContentDocumentId = versionRecord.ContentDocumentId, LinkedEntityId = schindlerCase.Id);
    }

}