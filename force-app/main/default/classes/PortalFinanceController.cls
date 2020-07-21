public without sharing class PortalFinanceController {

    private static final String INVALID_INVOICE = 'Verified as Invalid';

    @AuraEnabled
    public static void payInvoice(Id invoiceId) {

        Schindler_Invoice_History__c invoice = new Schindler_Invoice_History__c(Id = invoiceId);
        invoice.UserStatus__c = PortalConstants.PAY_STATUS;
        invoice.Approved_Date__c = Date.today();
        update invoice;
    }

    @AuraEnabled
    public static void acceptInvoice(Id invoiceId) {

        Schindler_Invoice_History__c invoice = new Schindler_Invoice_History__c(Id = invoiceId);
        invoice.UserStatus__c = PortalConstants.AWAITING_STATUS;
        update invoice;
    }

    @AuraEnabled
    public static void disputeInvoice(Id invoiceId, String message) {

        Schindler_Invoice_History__c invoice = new Schindler_Invoice_History__c(Id = invoiceId);
        invoice.UserStatus__c = PortalConstants.DISPUTE_STATUS;
        invoice.Disputed_Date__c = Date.today();
        invoice.Customer_Comments__c = message;
        update invoice;
    }

    @AuraEnabled
    public static void renegociateInvoice(Id invoiceId, String message) {

        Schindler_Invoice_History__c invoice = new Schindler_Invoice_History__c(Id = invoiceId);
        invoice.UserStatus__c = PortalConstants.RENEGOCIATE_STATUS;
        invoice.Customer_Comments__c = message;
        update invoice;
    }

    @AuraEnabled
    public static void addCustomerComment(Id invoiceId, String message) {

        Schindler_Invoice_History__c invoice = new Schindler_Invoice_History__c(Id = invoiceId);
        invoice.Customer_Comments__c = message;
        update invoice;
    }

    @AuraEnabled
    public static void addVendorComment(Id invoiceId, String message) {

        Schindler_Invoice_History__c invoice = new Schindler_Invoice_History__c(Id = invoiceId);
        invoice.Customer_Comments__c = message;
        update invoice;
    }

    @AuraEnabled
    public static String getTemplateText(Schindler_Invoice_History__c record) {

        String result = null;

        if (INVALID_INVOICE.equalsIgnoreCase(record.Mate_Support_Status__c)) {

            result = 'Hi ' + record.Opportunity__r.Elevator_Vendor_Account__r.Name + ',\n\n' +
            'Customer #: ' + record.Opportunity__r.Vendor_Contract_Number__c + '\n' +
            'Invoice #: ' + record.Name  + '\n\n' +
            'The attached invoice is being disputed for the following reason: \n\n' +
            + record.Audit_Comments__c + '\n\n' +
            'Please credit or revise the invoice in accordance with the contract terms and reply back with confirmation.\n\n' +
            'Thank you,\n\n' +
            record.Account__r.Name + '\n\n';
        }

        return result;
    }

}

// invoiceId: this.record.Id, status: this.record.Mate_Support_Status__c, vendorName: this.record.Vendor__r.Name, customerName: this.record.Account__r.Name