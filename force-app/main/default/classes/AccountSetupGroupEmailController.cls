public with sharing class AccountSetupGroupEmailController {

    private Account record;

    public Boolean isCompleted {get; set;}
    public Boolean hasError {get; set;}
    public String message {get; set;}

    public AccountSetupGroupEmailController(ApexPages.StandardController std) {

        isCompleted = false;
        hasError = false;
        message = null;

        record = getAccount(std.getId());
    }

    public PageReference createGroupEmail() {

        if (record.Auditmate_Email__c != null) {

            message = 'Account email is already provisioned';
            hasError = true;
        }
        else {

            String accountName = record.Name.trim().replaceAll(' ', '').toLowerCase();
            String accountEmail = accountName + '@auditmate.com';

            GoogleDirectoryController.createEmailGroup(record.Id, accountEmail);
        }

        return null;
    }

    private static Account getAccount(Id accountId) {

        return [SELECT
                    Name,
                    Auditmate_Email__c
                FROM Account
                WHERE Id = :accountId];
    }
}