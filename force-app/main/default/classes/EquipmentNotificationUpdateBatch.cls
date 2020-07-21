public with sharing class EquipmentNotificationUpdateBatch implements Database.Batchable<sObject>, Schedulable {

    public void execute(SchedulableContext sc) {

        Database.executeBatch(new EquipmentNotificationUpdateBatch());
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        Date today = Date.today();

        return Database.getQueryLocator('SELECT Past_Due__c, Opportunity__r.Account.Group_Email__c, Opportunity__r.Vendor_Email__c FROM Equipment__c WHERE Next_Maintenance_Date__c < :today OR Next_PM_Date__c < :today');
    }

    public void execute(Database.BatchableContext bc, Equipment__c[] scope) {

        for (Equipment__c record :scope) {
            record.Past_Due__c = true;
        }

        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        // Nothing to execute
    }

}