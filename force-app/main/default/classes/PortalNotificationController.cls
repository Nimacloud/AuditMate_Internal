public with sharing class PortalNotificationController {


    @AuraEnabled
    public static void requestUpdates(Id[] equipmentIds) {

        if (equipmentIds != null) {

            Request_Update__e[] events = new Request_Update__e[] {};

            for (Id equipmentId :equipmentIds) {

                Request_Update__e eventRecord = new Request_Update__e(Record_Id__c = equipmentId);
                events.add(eventRecord);
            }

            EventBus.publish(events);
        }
    }

}