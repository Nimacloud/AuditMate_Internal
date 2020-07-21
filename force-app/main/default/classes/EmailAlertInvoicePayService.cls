public without sharing class EmailAlertInvoicePayService {

    @InvocableMethod(label='Pay Invoice' description='Send Invoices to Customer' category='Invoice')
    public static void sendInvoiceEmails(List<Id> invoiceIds) {

        Schindler_Invoice_History__c[] invoices = new Schindler_Invoice_History__c[]{};

        invoices = [SELECT
                        Account__r.Group_Email__c,
                        Account__r.Customer_Accounts_Contact__c,
                        Account__r.Vendor_Accounts_Contact__c,
                        Account__r.Customer_Accounts_Contact__r.Email,
                        Account__r.Vendor_Accounts_Contact__r.Email,
                        Account__r.Vendor_Contact__r.Email
                        FROM Schindler_Invoice_History__c
                        WHERE Id IN :invoiceIds];

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
        handler.sendPaidInvoiceEmails(invoices, pdfByInvoiceId);
    }

}