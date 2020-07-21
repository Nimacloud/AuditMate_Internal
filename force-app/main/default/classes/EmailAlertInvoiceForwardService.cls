public without sharing class EmailAlertInvoiceForwardService {


    @InvocableMethod(label='Forward Invoice' description='Forward Invoice to Customer' category='Invoice')
    public static void sendInvoiceEmails(List<Id> accountIds) {

        Map<String, Id> templatesByName = new Map<String,Id>();

        EmailTemplate[] templates = [SELECT DeveloperName
                                        FROM EmailTemplate
                                        WHERE IsActive = true];

        for (EmailTemplate template :templates) {
            templatesByName.put(template.DeveloperName, template.Id);
        }

        Id templateId = templatesByName.get('fwd_invoice_request');


        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[] {};

        for (Account accountRecord :[SELECT
                                        Auditmate_Email__c,
                                        Group_Email__c,
                                        Vendor_Contact__r.Email
                                        FROM Account WHERE Id IN :accountIds])
        {


            emails.add(createEmail(accountRecord, templateId));

        }

        if (!Test.isRunningTest()) {
            Messaging.sendEmail(emails);
        }
    }


    private static Messaging.SingleEmailMessage createEmail(Account accountRecord, Id templateId) {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email = Messaging.renderStoredEmailTemplate(templateId, null, accountRecord.Id);
        email.setOrgWideEmailAddressId(accountRecord.Group_Email__c);
        email.setToAddresses(new String[] { accountRecord.Vendor_Contact__r.Email });
        email.setCcAddresses(new String[] { accountRecord.Customer_Accounts_Contact__r.Email });

        return email;
    }

}