public with sharing class OCRServiceUtils {

    // Auxiliary methods

    public static Case getCase(Id caseId) {

        Case[] result = [SELECT
                            AccountId,
                            Account.ParentId,
                            ContactId,
                            Vendor__c,
                            Vendor__r.Vendor_Company__c
                        FROM Case
                        WHERE Id = :caseId];

        return result.isEmpty() ? null : result[0];
    }

    public static Id getOpportunityId(Case record) {

        Opportunity[] result = [SELECT Id
                                FROM Opportunity
                                WHERE Vendor_Contract_Stage__c = 'Vendor_Contract_Active'
                                AND IsWon = true
                                AND AccountId = :record.AccountId];

        return result.isEmpty() ? null : result[0].Id;

    }

    public static ContentVersion getCaseContentVersion(Id recordId) {

        ContentVersion[] result = new ContentVersion[] {};

        ContentDocumentLink[] links = [SELECT
                                            ContentDocumentId,
                                            ContentDocument.LatestPublishedVersionId
                                        FROM ContentDocumentLink
                                        WHERE LinkedEntityId = :recordId];

        if (!links.isEmpty()) {

            Id contentVersionId = links[0].ContentDocument.LatestPublishedVersionId;

            result = [SELECT
                            ContentDocumentId,
                            VersionData
                        FROM ContentVersion
                        WHERE Id = :contentVersionId];
        }

        return result.isEmpty() ? null : result[0];
    }

    public static Schindler_Invoice_History__c insertInvoice(Object page, Case caseRecord, ContentVersion contentVersionRecord) {

        Type classType = getStrategy(caseRecord);

        if (classType == null) {
            String unverifiedMessage = 'The invoice was not correcly verified.'
                                     + ' Please review the attached file';
            return insertDummyInvoice(caseRecord, contentVersionRecord, unverifiedMessage);
        }

        OCRStrategy strategy = (OCRStrategy) classType.newInstance();
        strategy.setStream(page);

        Schindler_Invoice_History__c invoice = strategy.createInvoice();

        if (invoice != null) {

            // Information from Case
            invoice.Case__c = caseRecord.Id;
            invoice.Vendor__c = caseRecord.Vendor__c;
            invoice.Account__c = caseRecord.AccountId;
            invoice.Opportunity__c = getOpportunityId(caseRecord);

            // Audit Information
            invoice.UserStatus__c = null;
            invoice.Mate_Support_Status__c = 'Unverified';

            insert invoice;

            if (contentVersionRecord != null) {

                ContentDocumentLink[] links = createNewLinks(invoice, caseRecord, contentVersionRecord);

                insert links;
            }
        }

        return invoice;
    }

    public static Schindler_Invoice_History__c insertDummyInvoice(Case caseRecord, ContentVersion contentVersionRecord, String responseBody) {

            Schindler_Invoice_History__c invoice = new Schindler_Invoice_History__c();

            // Information from Case
            invoice.Case__c = caseRecord.Id;
            invoice.Vendor__c = caseRecord.Vendor__c;
            invoice.Account__c = caseRecord.AccountId;
            invoice.Opportunity__c = getOpportunityId(caseRecord);

            // Audit Information
            invoice.UserStatus__c = null;
            invoice.Mate_Support_Status__c = 'Unverified';
            invoice.Description__c = responseBody;

            insert invoice;

            if (contentVersionRecord != null) {

                ContentDocumentLink[] links = createNewLinks(invoice, caseRecord, contentVersionRecord);

                insert links;
            }

            return invoice;

    }

    private static ContentDocumentLink[] createNewLinks(Schindler_Invoice_History__c invoice, Case caseRecord, ContentVersion contentVersionRecord) {

        ContentDocumentLink[] links = new ContentDocumentLink[] {};

        ContentDocumentLink link = new ContentDocumentLink();
        link.LinkedEntityId = invoice.Id;
        link.ContentDocumentId = contentVersionRecord.ContentDocumentId;
        link.Visibility = 'AllUsers';
        link.ShareType = 'V';
        links.add(link);

        link = new ContentDocumentLink();
        link.LinkedEntityId = invoice.Account__c;
        link.ContentDocumentId = contentVersionRecord.ContentDocumentId;
        link.Visibility = 'AllUsers';
        link.ShareType = 'V';
        links.add(link);

        if (caseRecord.Account.ParentId != null) {

            link = new ContentDocumentLink();
            link.LinkedEntityId = caseRecord.Account.ParentId;
            link.ContentDocumentId = contentVersionRecord.ContentDocumentId;
            link.Visibility = 'AllUsers';
            link.ShareType = 'V';
            links.add(link);
        }

        return links;
    }

    public static Type getStrategy(Case caseRecord) {

        String vendorCompany = caseRecord.Vendor__r.Vendor_Company__c;

        Type result = null;

        switch on vendorCompany {

            when 'Thyssen' {
                result = Type.forName('OCRStrategyThyssen');
            }
            when 'Schindler' {
                result = Type.forName('OCRStrategySchindler');
            }
            when 'Kone' {
                result = Type.forName('OCRStrategyKone');
            }
            when else {
                // Nothing
            }
        }

        return result;
    }
}