public without sharing class EmailAlertCaseDisputeService {

    @InvocableMethod(label='Dispute Case' description='Send Disputes to Vendors' category='Case')
    public static void sendInvoiceEmails(List<Id> caseIds) {

        Case[] caseRecords = new Case[]{};

        caseRecords = [SELECT
                        Invoice__c,
                        Invoice__r.Customer_Comments__c,
                        Invoice__r.Account__r.Group_Email__c,
                        Invoice__r.Account__r.Customer_Accounts_Contact__c,
                        Invoice__r.Account__r.Vendor_Accounts_Contact__c,
                        Contact.Email,
                        Invoice_Group_Email__c
                        FROM Case
                        WHERE Id IN :caseIds];

        Id[] invoiceIds = new Id[] {};
        for (Case caseRecord :caseRecords) {
            invoiceIds.add(caseRecord.Invoice__c);
        }

        ContentDocumentLink[] pdfs = [SELECT ContentDocumentId,
                                            LinkedEntityId
                                        FROM ContentDocumentLink
                                        WHERE LinkedEntityId IN :invoiceIds];

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
        handler.sendDisputeInvoiceEmails(caseRecords, pdfByInvoiceId);
    }
}