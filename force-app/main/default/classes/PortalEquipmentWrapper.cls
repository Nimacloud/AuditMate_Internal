public with sharing class PortalEquipmentWrapper {
    
    @AuraEnabled
    public Equipment__c equipment {get; set;}

    @AuraEnabled
    public Schindler_Maintenance_Activity__c activity {get; set;}
    
    public PortalEquipmentWrapper(Equipment__c equipment, Schindler_Maintenance_Activity__c activity) {

        this.equipment = equipment;
        this.activity = activity;
    }
}