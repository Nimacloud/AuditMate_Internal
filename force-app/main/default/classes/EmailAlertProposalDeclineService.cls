public with sharing class EmailAlertProposalDeclineService {

    @InvocableMethod(label='Decline Proposal' description='Send Vendor email with declined Proposal' category='Proposal')
    public static void sendDeclineEmails(Id[] recordIds) {

        Proposal__c[] records = new Proposal__c[] {};

        records = [SELECT
                        Opportunity__r.Account.Group_Email__c,
                        Opportunity__r.Account.Customer_Accounts_Contact__c,
                        Opportunity__r.Account.Vendor_Accounts_Contact__c,
                        Opportunity__r.Account.Customer_Accounts_Contact__r.Email,
                        Opportunity__r.Account.Vendor_Accounts_Contact__r.Email,
                        Opportunity__r.Account.Vendor_Contact__r.Email
                        FROM Proposal__c
                        WHERE Id IN :recordIds];

        ContentDocumentLink[] pdfs = [SELECT ContentDocumentId,
                                            LinkedEntityId
                                        FROM ContentDocumentLink
                                        WHERE LinkedEntityId IN :recordIds];

        Id[] contentDocumentIds = new Id[] {};

        for (ContentDocumentLink pdf :pdfs) {
            contentDocumentIds.add(pdf.ContentDocumentId);
        }

        ContentVersion[] versions = [SELECT ContentDocumentId
                                        FROM ContentVersion
                                        WHERE ContentDocumentId IN :contentDocumentIds];

        Map<Id, Id> versionsByContentId = new Map<Id, Id>();
        for (ContentVersion version :versions) {
            versionsByContentId.put(version.ContentDocumentId, version.Id);
        }

        Map<Id, Id[]> pdfByInvoiceId = new Map<Id, Id[]>();

        for (ContentDocumentLink pdf :pdfs) {

            if (!pdfByInvoiceId.containsKey(pdf.LinkedEntityId)) {
                pdfByInvoiceId.put(pdf.LinkedEntityId, new Id[] {});
            }

            if (versionsByContentId.containsKey(pdf.ContentDocumentId)) {
                pdfByInvoiceId.get(pdf.LinkedEntityId).add(versionsByContentId.get(pdf.ContentDocumentId));
            }
        }

        EmailAlertsServiceHandler handler = new EmailAlertsServiceHandler();
        handler.sendDeclineProposalEmails(records, pdfByInvoiceId);
    }


}