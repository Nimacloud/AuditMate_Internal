public without sharing class CustomerUserHandler {

    @AuraEnabled
    public static Contact createNewContact(String lastName, String phone, String email, String accountId, String ownerId) {

        Contact newContact = new Contact(LastName = lastName, Phone = phone, Email = email, AccountId = accountId, OwnerId = ownerId);
        insert newContact;

        return newContact;
    }

    @AuraEnabled
    public static Account updateExistingAccount(String accountId, String apContactId, String vendorContactId) {

        Account record = new Account(Id = accountId, Customer_Accounts_Contact__c = apContactId, Vendor_Accounts_Contact__c = vendorContactId);
        update record;

        return record;
    }

    @AuraEnabled
    public static void setAccountVendor(Id accountId, String vendorUsername, String vendorPassword) {

        User userRecord = [SELECT
                                ContactId,
                                Contact.Id,
                                Contact.AccountId,
                                Contact.Account.Elevator_Vendor_Account__c,
                                Contact.Portal_Ready__c,
                                Contact.Portal_Provisioned__c
                                FROM User
                                WHERE Id = :UserInfo.getUserId()];

        if (userRecord.ContactId != null) {

            Account accountRecord = new Account(Id = userRecord.Contact.AccountId,
                                                Elevator_Vendor_Account__c = accountId,
                                                Vendor_Username__c = vendorUsername,
                                                Vendor_Password__c = vendorPassword);
            update accountRecord;

            Contact contactRecord = new Contact(Id = userRecord.ContactId);
            contactRecord.Portal_Provisioned__c = true;

            update contactRecord;
        }

    }

    @AuraEnabled
    public static Account getSelectedAccount(Id accountId) {

        Account[] accountRecords = new Account[] {};

        accountRecords = [SELECT
                            Average_Response_Time__c,
                            Testing_Completion_Rate__c,
                            Maintenance_Completion_Rate__c,
                            Maintenance_Visits_YTD__c
                            FROM Account
                            WHERE Id = :accountId];

        return accountRecords.isEmpty() ? null : accountRecords[0];
    }

    @AuraEnabled(cacheable = true)
    public static Contact getCommunityContact() {

        User userRecord = [SELECT
                                ContactId,
                                Contact.Id,
                                Contact.AccountId,
                                Contact.Account.OwnerId,
                                Contact.Account.Elevator_Vendor_Account__c,
                                Contact.Portal_Ready__c,
                                Contact.Portal_Provisioned__c
                                FROM User
                                WHERE Id = :UserInfo.getUserId()];

        return (userRecord.ContactId != null) ? userRecord.Contact : null;
    }

    @AuraEnabled(cacheable = true)
    public static Id getDirectPartnerAccountId() {

        User userRecord = [SELECT
                                ContactId,
                                Contact.AccountId
                                FROM User
                                WHERE Id = :UserInfo.getUserId()];

        return (userRecord.ContactId != null && userRecord.Contact.AccountId != null)
                ? userRecord.Contact.AccountId
                : null;
    }

    @AuraEnabled
    public static Account[] getAccounts() {

        Account[] results = new Account[] {};

        User userRecord = [SELECT
                                ContactId,
                                Contact.AccountId,
                                Contact.Account.Name,
                                Contact.Account.ParentId,
                                Contact.Portal_Selected_Account_Id__c
                                FROM User
                                WHERE Id = :UserInfo.getUserId()];

        if (userRecord.ContactId != null) {

            Account[] accountRecords = [SELECT Name
                                        FROM Account
                                        WHERE Id = :userRecord.Contact.AccountId
                                        OR Id = :userRecord.Contact.Account.ParentId
                                        OR (ParentId = :userRecord.Contact.Account.ParentId
                                            AND ParentId != null)
                                        OR (ParentId = :userRecord.Contact.AccountId
                                            AND ParentId != null)
                                        ORDER BY Name];

            results = accountRecords;
        }

        return results;
    }


    @AuraEnabled
    public static Id getDefaultAccountId() {

        User userRecord = [SELECT
                                Contact.Portal_Selected_Account_Id__c,
                                Contact.AccountId
                            FROM User
                            WHERE Id = :UserInfo.getUserId()];

        return (userRecord.Contact.Portal_Selected_Account_Id__c != null) ? userRecord.Contact.Portal_Selected_Account_Id__c : userRecord.Contact.AccountId;
    }

    @AuraEnabled
    public static void setDefaultAccountId(String accountId) {

        User userRecord = [SELECT
                                ContactId,
                                Contact.Portal_Selected_Account_Id__c
                                FROM User
                                WHERE Id = :UserInfo.getUserId()];


        if (userRecord.ContactId != null) {
            Contact contactRecord = new Contact(Id = userRecord.ContactId, Portal_Selected_Account_Id__c = accountId);
            update contactRecord;
        }
    }

}