public without sharing class EmailAlertsServiceHandler {

    // // Invoices
    // private final Id INVOICE_TEMPLATE = '00X3I000000DkQb';
    // private final Id INVOICE_DISPUTE_TEMPLATE = '00X3I000000DkRK';

    // // Proposals
    // private final Id PROPOSAL_DECLINE_TEMPLATE = '00X3I000000DkV9';

    // // Services
    // private final Id REQUEST_TEMPLATE = '00X3I000000DkQb';

    private static final Id SUPPORT_TEMPLATE = '0D23k000000Gq2v';

    private Map<String, Id> templatesByName;

    public EmailAlertsServiceHandler() {

        templatesByName = new Map<String,Id>();

        EmailTemplate[] templates = [SELECT DeveloperName
                                        FROM EmailTemplate
                                        WHERE IsActive = true];

        for (EmailTemplate template :templates) {
            templatesByName.put(template.DeveloperName, template.Id);
        }
    }

    public void sendPaidInvoiceEmails(Schindler_Invoice_History__c[] invoices, Map<Id, Id[]> pdfByInvoiceId) {

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Schindler_Invoice_History__c invoice :invoices) {
            emails.add(createPayEmail(invoice, pdfByInvoiceId.get(invoice.Id)));
        }

        sendEmails(emails);
    }

    public void sendDisputeInvoiceEmails(Schindler_Invoice_History__c[] invoices, Map<Id, Id[]> pdfByInvoiceId) {

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Schindler_Invoice_History__c invoice :invoices) {
            emails.add(createDisputeEmail(invoice, pdfByInvoiceId.get(invoice.Id)));
        }

        sendEmails(emails);
    }

    public void sendDeclineProposalEmails(Proposal__c[] records, Map<Id, Id[]> pdfByInvoiceId) {

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Proposal__c record :records) {
            emails.add(createProposalDeclineEmail(record, pdfByInvoiceId.get(record.Id)));
        }

        sendEmails(emails);
    }

    public void sendServiceEmails(Case[] records) {

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Case record :records) {
            emails.add(createEmail(record));
        }

        sendEmails(emails);
    }

    private void sendEmails(Messaging.SingleEmailMessage[] emails) {

        if (!Test.isRunningTest()) {
            Messaging.sendEmail(emails);
        }
    }

    private Messaging.SingleEmailMessage createPayEmail(Schindler_Invoice_History__c invoice, Id[] attachmentIds) {

        Id templateId = templatesByName.get('Approve_Invoice_to_Accounting_Department');

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email = Messaging.renderStoredEmailTemplate(templateId, null, invoice.Id);
        email.setOrgWideEmailAddressId(SUPPORT_TEMPLATE);
        email.setToAddresses(new String[] {invoice.Account__r.Customer_Accounts_Contact__r.Email});
        email.setEntityAttachments(attachmentIds);

        return email;
    }

    private Messaging.SingleEmailMessage createDisputeEmail(Schindler_Invoice_History__c invoice, Id[] attachmentIds) {

        // Id templateId = templatesByName.get('Dispute_invoice2');
        Id templateId = templatesByName.get('Customer_Invoice_Dispute');

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email = Messaging.renderStoredEmailTemplate(templateId, null, invoice.Id);
        email.setOrgWideEmailAddressId(invoice.Account__r.Group_Email__c);
        email.setToAddresses(new String[] {invoice.Account__r.Vendor_Contact__r.Email});
        email.setEntityAttachments(attachmentIds);

        return email;
    }

    private Messaging.SingleEmailMessage createProposalDeclineEmail(Proposal__c record, Id[] attachmentIds) {

        Id templateId = templatesByName.get('Proposal_Declined');

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email = Messaging.renderStoredEmailTemplate(templateId, null, record.Id);
        email.setOrgWideEmailAddressId(record.Opportunity__r.Account.Group_Email__c);
        email.setToAddresses(new String[] {record.Opportunity__r.Account.Vendor_Contact__r.Email});
        email.setEntityAttachments(attachmentIds);

        return email;
    }

    private Messaging.SingleEmailMessage createEmail(Case record) {

        Id templateId = templatesByName.get('Request_update_inspection');

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email = Messaging.renderStoredEmailTemplate(templateId, null, record.Id);
        email.setOrgWideEmailAddressId(record.Opportunity__r.Account.Group_Email__c);
        email.setToAddresses(new String[] {record.Opportunity__r.Vendor_Email__c});

        return email;
    }

    // New!

    public void sendDisputeInvoiceEmails(Case[] caseRecords, Map<Id, Id[]> pdfByInvoiceId) {

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Case caseRecord :caseRecords) {
            emails.add(createDisputeEmail(caseRecord, pdfByInvoiceId.get(caseRecord.Invoice__c)));
        }

        sendEmails(emails);
    }

    private Messaging.SingleEmailMessage createDisputeEmail(Case caseRecord, Id[] attachmentIds) {

        Id templateId = templatesByName.get('Customer_Invoice_Dispute');

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email = Messaging.renderStoredEmailTemplate(templateId, null, caseRecord.Id);
        email.setOrgWideEmailAddressId(caseRecord.Invoice_Group_Email__c);
        email.setToAddresses(new String[] {caseRecord.Contact.Email});
        email.setEntityAttachments(attachmentIds);

        return email;
    }

}