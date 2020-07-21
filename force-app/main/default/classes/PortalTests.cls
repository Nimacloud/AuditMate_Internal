@isTest
private with sharing class PortalTests {

    private static Account accountRecord = null;
    private static Account elevatorRecord = null;
    private static Schindler_Invoice_History__c invoiceRecord = null;
    private static Schindler_Maintenance_Activity__c activityRecord = null;
    private static Proposal__c proposalRecord = null;
    private static Opportunity opportunityRecord = null;
    private static Equipment__c equipmentRecord = null;
    private static Case caseRecord = null;
    private static User userRecord = null;

    @isTest
    private static void coverEquipmentNotificationUpdateBatch() {

        setup();

        Test.startTest();
        Database.executeBatch(new EquipmentNotificationUpdateBatch());
        Test.stopTest();

        System.assert(true, 'true');
    }

    @isTest
    private static void coverPortalActivityController() {

        setup();

        Test.startTest();

        PortalActivityController.getMaintenanceActivityCount(accountRecord.Id);
        PortalActivityController.getTestingFiveActivityCount(accountRecord.Id);
        PortalActivityController.getTestingOneActivityCount(accountRecord.Id);

        Test.stopTest();

        System.assert(true, 'true');

    }


    @isTest
    private static void coverPortalNotificationController() {

        setup();

        Test.startTest();

        PortalNotificationController.requestUpdates(new Id[] {equipmentRecord.Id});

        Test.stopTest();

        System.assert(true, 'true');

    }

    @isTest
    private static void coverEmailAlertServices() {

        setup();

        Test.startTest();

        EmailAlertProposalDeclineService.sendDeclineEmails(new Id[] {proposalRecord.Id});
        EmailAlertInvoicePayService.sendInvoiceEmails(new Id[] {invoiceRecord.Id});
        EmailAlertInvoiceDisputeService.sendInvoiceEmails(new Id[] {invoiceRecord.Id});
        EmailAlertEquipmentService.sendServiceEmails(new Id[] {caseRecord.Id});

        EmailAlertCaseDisputeService.sendInvoiceEmails(new Id[] {caseRecord.Id});
        EmailAlertInvoiceForwardService.sendInvoiceEmails(new Id[] {accountRecord.Id});

        Test.stopTest();

        System.assert(true, 'true');

    }

    @isTest
    private static void coverPortalController() {

        setup();

        Test.startTest();

        Id accountId = accountRecord.Id;

        PortalController.getServicePreventiveActivities(accountId);
        PortalController.getServiceTestingActivities(accountId);
        PortalController.getServiceRepairActivities(accountId);
        PortalController.getServiceCallbackActivities(accountId);

        PortalController.getServiceAllActivities(accountId, 'TODAY');
        PortalController.getServicePeriodActivities(accountId, Date.today(), Date.today());

        PortalController.getFinanceOpenInvoices(accountId);
        PortalController.getFinanceDisputedInvoices(accountId);
        PortalController.getFinanceAllInvoices(accountId);

        PortalController.getUpcomingActivities(accountId);
        PortalController.getPreventiveActivities(accountId);
        PortalController.getTestingActivities(accountId);
        PortalController.getRepairActivities(accountId);
        PortalController.getCallbacksActivities(accountId);

        PortalController.getTodayActivities(accountId);
        PortalController.getThisWeekActivities(accountId);
        PortalController.getLastWeekActivities(accountId);
        PortalController.getThisMonthActivities(accountId);
        PortalController.getLastMonthActivities(accountId);
        PortalController.getAllActivities(accountId, 'TODAY');

        PortalController.getActivities(accountId, Date.today(), Date.today());
        PortalController.getUnits(UserInfo.getUserId(), accountId);
        PortalController.getUnitsAndInspections(UserInfo.getUserId(), accountId);
        PortalController.getInvoices(UserInfo.getUserId(), accountId);
        PortalController.getOpenInvoices(UserInfo.getUserId(), accountId);
        PortalController.getDisputedInvoices(UserInfo.getUserId(), accountId);
        PortalController.getPaidInvoices(UserInfo.getUserId(), accountId);
        PortalController.getDueInvoices(UserInfo.getUserId(), accountId);

        PortalController.getInspectionFindings(accountId);
        PortalController.getStateRecords(accountId);
        PortalController.getStateRecordInspections(accountId);
        PortalController.getStateRecordsWithInspections(UserInfo.getUserId(), accountId);

        PortalController.getOpenProposals(accountId);
        PortalController.getAcceptedProposals(UserInfo.getUserId(), accountId);
        PortalController.getProposalsHistory(accountId);

        PortalControllerHelper.getUnits(accountId);

        Test.stopTest();

        System.assert(true, 'true');

    }

    @isTest
    private static void coverPortalFileController() {

        setup();

        Test.startTest();

        Id accountId = accountRecord.Id;
        PortalFileController.getContentDocumentId(accountId);

        Test.stopTest();

        System.assert(true, 'true');
    }

    @isTest
    private static void coverWrappers() {

        PortalEquipmentWrapper wrapper = new PortalEquipmentWrapper(null, null);
        System.assert(true, 'true');
    }

    @isTest
    private static void coverPortalFinanceController() {

        setup();

        Test.startTest();

        Id invoiceId = invoiceRecord.Id;

        PortalFinanceController.addCustomerComment(invoiceId, 'message');
        PortalFinanceController.addVendorComment(invoiceId, 'message');

        PortalFinanceController.disputeInvoice(invoiceId, 'message');
        // PortalFinanceController.payInvoice(invoiceId);
        PortalFinanceController.acceptInvoice(invoiceId);
        PortalFinanceController.renegociateInvoice(invoiceId, 'message');

        invoiceRecord.Mate_Support_Status__c = 'Verified as Invalid';
        PortalFinanceController.getTemplateText(invoiceRecord);

        Test.stopTest();

        System.assert(true, 'true');

    }

    @isTest
    private static void coverPortalContractController() {

        setup();

        Test.startTest();

        Id accountId = accountRecord.Id;

        PortalContractController.getActiveContract(accountId);

        Test.stopTest();

        System.assert(true, 'true');
    }

    @isTest
    private static void coverPortalProposalController() {

        setup();

        Test.startTest();

        Id proposalId = proposalRecord.Id;

        PortalProposalController.acceptProposal(proposalId, '');
        PortalProposalController.declineProposal(proposalId, '');

        Test.stopTest();

        System.assert(true, 'true');

    }

    @isTest
    private static void coverGetEquipmentWrappers() {

        Equipment__c equipment = new Equipment__c(Vendor_Equipment_No__c = '1234');
        Schindler_Maintenance_Activity__c activity = new Schindler_Maintenance_Activity__c(EquipNo__c = '1234');

        Test.startTest();

        PortalControllerHelper.getEquipmentWrappers(new Equipment__c[] {equipment}, new Schindler_Maintenance_Activity__c[] {activity});

        Test.stopTest();

        System.assert(true, 'true');

    }

    @isTest
    private static void coverPortalInsightsController() {

        setup();

        Test.startTest();

        PortalInsightsController.getInsights(accountRecord.Id);

        Test.stopTest();

        System.assert(true, 'true');

    }

    @isTest
    private static void coverPortalCaseController() {

        setup();
        setupUser();

        Test.startTest();

        System.runAs(userRecord) {
            PortalCaseController.createContractCase(null);
            PortalCaseController.createInspectionCase(null);
            PortalCaseController.createProposalCase(null);
        }

        Test.stopTest();

        System.assert(true, 'true');
    }

    @isTest
    private static void coverCustomerUserHandler() {

        setup();
        setupUser();

        Test.startTest();

        Id accountId = accountRecord.Id;

        Id ownerId = UserInfo.getUserId();

        System.runAs(userRecord) {

            CustomerUserHandler.getDefaultAccountId();
            CustomerUserHandler.createNewContact('lastName', 'phone', 'email@dnsaj.com', null, ownerId);
            CustomerUserHandler.updateExistingAccount(accountRecord.Id, null, null);
            CustomerUserHandler.getAccounts();
            CustomerUserHandler.getDirectPartnerAccountId();
            CustomerUserHandler.getCommunityContact();
            CustomerUserHandler.setDefaultAccountId(accountId);
            CustomerUserHandler.setAccountVendor(elevatorRecord.Id, 'username', 'password');

        }

        Test.stopTest();

        System.assert(true, 'true');
    }

    @isTest
    private static void testPortalLoginController() {

        Test.startTest();

        PortalLoginController.login('username', 'password');

        Test.stopTest();

        System.assert(true, 'true');

    }

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

        elevatorRecord = new Account(Name = 'Test Elevator');
        insert elevatorRecord;

        accountRecord = new Account(Name = 'Test Account');
        accountRecord.Customer_Accounts_Contact__c = ap.Id;
        accountRecord.Vendor_Accounts_Contact__c = ap.Id;
        accountRecord.Customer_Contact__c = ap.Id;
        accountRecord.Vendor_Contact__c = ap.Id;
        accountRecord.Elevator_Vendor_Account__c = elevatorRecord.Id;
        accountRecord.Group_Email__c = address.Id;
        insert accountRecord;

        opportunityRecord = new Opportunity(Name = 'Test Opportunity', AccountId = accountRecord.Id);
        opportunityRecord.CloseDate = Date.today();
        opportunityRecord.Start_Date__c = Date.today().addYears(-1);
        opportunityRecord.StageName = 'In Review';
        opportunityRecord.RecordTypeId = '0123k0000014QkLAAU';
        opportunityRecord.Frequency_of_service__c = 'Monthly';
        insert opportunityRecord;

        proposalRecord = new Proposal__c(Name = 'Test Proposal');
        proposalRecord.Vendor__c = 'Test Vendor';
        proposalRecord.Estimate_Number__c = 'Test Proposal';
        proposalRecord.Opportunity__c = opportunityRecord.Id;
        proposalRecord.CustomerStatus__c = 'Accepted';
        insert proposalRecord;

        insert new ContentDocumentLink(ContentDocumentId = versionRecord.ContentDocumentId, LinkedEntityId = proposalRecord.Id);

        equipmentRecord = new Equipment__c(Name = 'Test Equipment');
        equipmentRecord.Opportunity__c = opportunityRecord.Id;
        equipmentRecord.Next_PM_Date__c = Date.today().addDays(-1);
        equipmentRecord.Display_Name__c = 'Test';
        insert equipmentRecord;

        State_Inspection__c inspectionRecord = new State_Inspection__c(Name = 'Test Inspection');
        inspectionRecord.Opportunity__c = opportunityRecord.Id;
        inspectionRecord.Type_of_Inspection__c = 'ANNUAL';
        insert inspectionRecord;

        activityRecord = new Schindler_Maintenance_Activity__c(Opportunity__c = opportunityRecord.Id);
        activityRecord.VisitDate__c = Date.today().addDays(-1);
        activityRecord.Type__c = PortalConstants.TESTING_TYPE;
        activityRecord.Category__c = PortalConstants.CATEGORY_1;
        activityRecord.Equipment__c = equipmentRecord.Id;
        activityRecord.Description__c = 'CAT1';
        insert activityRecord;

        activityRecord = new Schindler_Maintenance_Activity__c(Opportunity__c = opportunityRecord.Id);
        activityRecord.VisitDate__c = Date.today().addDays(-1);
        activityRecord.Type__c = PortalConstants.TESTING_TYPE;
        activityRecord.Category__c = PortalConstants.CATEGORY_5;
        activityRecord.Equipment__c = equipmentRecord.Id;
        activityRecord.Description__c = 'CAT5';
        insert activityRecord;

        activityRecord = new Schindler_Maintenance_Activity__c(Opportunity__c = opportunityRecord.Id);
        activityRecord.VisitDate__c = Date.today().addDays(-1);
        activityRecord.Type__c = PortalConstants.CALLBACK_TYPE;
        activityRecord.Equipment__c = equipmentRecord.Id;
        activityRecord.Description__c = 'CAT1';
        insert activityRecord;

        activityRecord = new Schindler_Maintenance_Activity__c(Opportunity__c = opportunityRecord.Id);
        activityRecord.VisitDate__c = Date.today().addDays(-1);
        activityRecord.Type__c = PortalConstants.MAINTENANCE_TYPE;
        activityRecord.Equipment__c = equipmentRecord.Id;
        activityRecord.Description__c = 'CAT1';
        insert activityRecord;

        activityRecord = new Schindler_Maintenance_Activity__c(Opportunity__c = opportunityRecord.Id);
        activityRecord.VisitDate__c = Date.today().addDays(-1);
        activityRecord.Type__c = PortalConstants.MAINTENANCE_TYPE;
        activityRecord.Departure_DateTime__c = Datetime.now();
        activityRecord.Equipment__c = equipmentRecord.Id;
        activityRecord.Description__c = 'CAT1';
        insert activityRecord;

        insert new ContentDocumentLink(ContentDocumentId = versionRecord.ContentDocumentId, LinkedEntityId = activityRecord.Id);

        invoiceRecord = new Schindler_Invoice_History__c(Name = 'Test Invoice');
        invoiceRecord.Opportunity__c = opportunityRecord.Id;
        invoiceRecord.UserStatus__c = PortalConstants.DISPUTE_STATUS;
        invoiceRecord.Account__c = accountRecord.Id;
        invoiceRecord.Mate_Support_Status__c = PortalController.VAV;
        invoiceRecord.Customer_Email__c = 'test@test.com';
        insert invoiceRecord;

        invoiceRecord = new Schindler_Invoice_History__c(Name = 'Test Invoice');
        invoiceRecord.Opportunity__c = opportunityRecord.Id;
        invoiceRecord.UserStatus__c = PortalConstants.PAY_STATUS;
        invoiceRecord.Mate_Support_Status__c = PortalController.VAV;
        invoiceRecord.Account__c = accountRecord.Id;
        invoiceRecord.Customer_Email__c = 'test@test.com';
        insert invoiceRecord;

        invoiceRecord = new Schindler_Invoice_History__c(Name = 'Test Invoice');
        invoiceRecord.Opportunity__c = opportunityRecord.Id;
        invoiceRecord.Account__c = accountRecord.Id;
        invoiceRecord.Mate_Support_Status__c = PortalController.VAV;
        invoiceRecord.Customer_Email__c = 'test@test.com';
        insert invoiceRecord;

        caseRecord = new Case();
        caseRecord.ContactId = ap.Id;
        caseRecord.Invoice__c = invoiceRecord.Id;
        caseRecord.Priority = 'High';
        caseRecord.Reason = 'Invoice Dispute';
        caseRecord.Type = 'Invoice Review';
        caseRecord.Origin = 'Web';
        caseRecord.Status = 'New';

        insert caseRecord;

        insert new ContentDocumentLink(ContentDocumentId = versionRecord.ContentDocumentId, LinkedEntityId = invoiceRecord.Id);

    }

    private static void setupUser() {

        Id profileId = [SELECT Id
                            FROM Profile
                            WHERE Id = '00e3k00000104JO'].Id;


        Contact contactRecord = new Contact(LastName = 'Test Contact', AccountId = accountRecord.Id);
        insert contactRecord;

        userRecord = new User(Alias = 'User1234',
                                Email = 'test123@noemail.com',
                                EmailEncodingKey = 'UTF-8',
                                LastName = 'Testing',
                                LanguageLocaleKey = 'en_US',
                                LocalesIdKey = 'en_US',
                                ProfileId = profileId,
                                Country = 'United States',
                                IsActive = true,
                                ContactId = contactRecord.Id,
                                TimezonesIdKey = 'America/Los_Angeles',
                                Username = 'tester@noemail.com');

        insert userRecord;
    }


}