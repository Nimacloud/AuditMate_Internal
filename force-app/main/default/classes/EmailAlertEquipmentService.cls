public without sharing class EmailAlertEquipmentService {

    @InvocableMethod(label='Send Requests' description='Send Requests to Vendors' category='Equipment')
    // public static void sendServiceEmails(List<Id> equipmentIds) {

    //     Equipment__c[] equipments = new Equipment__c[]{};

    //     equipments = [SELECT
    //                     Opportunity__r.Account.Group_Email__c,
    //                     Opportunity__r.Account.Customer_Accounts_Contact__c,
    //                     Opportunity__r.Account.Vendor_Accounts_Contact__c,
    //                     Opportunity__r.Account.Customer_Accounts_Contact__r.Email,
    //                     Opportunity__r.Account.Vendor_Accounts_Contact__r.Email,
    //                     Opportunity__r.Account.Vendor_Contact__r.Email,
    //                     Opportunity__r.Vendor_Email__c
    //                 FROM Equipment__c
    //                 WHERE Id IN :equipmentIds];

    //     EmailAlertsServiceHandler handler = new EmailAlertsServiceHandler();
    //     handler.sendServiceEmails(equipments);
    // }

    public static void sendServiceEmails(List<Id> caseIds) {

        Case[] cases = new Case[] {};

        cases = [SELECT
                        Equipment__c,
                        Equipment__r.Vendor_Name__c,
                        Equipment__r.Customer_Number__c,
                        Equipment__r.Next_Maintenance_Date__c,
                        Equipment__r.Vendor_Equipment_No__c,
                        Equipment__r.Customer_Name__c,

                        Opportunity__r.Vendor_Contract_Number__c,
                        Opportunity__r.Account.Group_Email__c,
                        Opportunity__r.Account.Customer_Accounts_Contact__c,
                        Opportunity__r.Account.Vendor_Accounts_Contact__c,
                        Opportunity__r.Account.Customer_Accounts_Contact__r.Email,
                        Opportunity__r.Account.Vendor_Accounts_Contact__r.Email,
                        Opportunity__r.Account.Vendor_Contact__r.Email,
                        Opportunity__r.Vendor_Email__c
                    FROM Case
                    WHERE Id IN :caseIds];

        EmailAlertsServiceHandler handler = new EmailAlertsServiceHandler();
        handler.sendServiceEmails(cases);
    }
}