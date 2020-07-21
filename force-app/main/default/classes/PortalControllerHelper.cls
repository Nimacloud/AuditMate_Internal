public without sharing class PortalControllerHelper {

    public static Equipment__c[] getUnits(Id accountId) {

        Equipment__c[] result = new Equipment__c[] {};

        for (Equipment__c record :[SELECT
                                        Cat1_Count__c,
                                        Cat5_Count__c,
                                        Class__c,
                                        Controller_Type__c,
                                        Display_Name__c,
                                        Inspection_Witness__c,
                                        Last_12_Month_Count__c,
                                        Last_30_Day_Count__c,
                                        Last_Cat1_Date__c,
                                        Last_Cat5_Date__c,
                                        Last_Cleandown_Date__c,
                                        Last_Index_Test_Date__c,
                                        Last_PM_Date__c,
                                        Last_Visit_Date__c,
                                        Last_Visit_Reason__c,
                                        Load_Lb__c,
                                        Name,
                                        Next_Cat1_Date__c,
                                        Next_Cat5_Date__c,
                                        Next_Cleandown_Date__c,
                                        Next_Index_Test_Date__c,
                                        Next_PM_Date__c,
                                        Opportunity__c,
                                        Remote_Monitoring__c,
                                        Speed__c,
                                        State_Certificate_Expiration_Date__c,
                                        State_Certificate_First_Issue_Date__c,
                                        State_Certificate_Issue_Date__c,
                                        State_Elevator_Subtype__c,
                                        State_Elevator_Type__c,
                                        State_ID__c,
                                        State_Location_City__c,
                                        State_Location_Description__c,
                                        State_Location_Street__c,
                                        State_Location_Zip__c,
                                        State_Owner_Name__c,
                                        State_Region__c,
                                        State_Serial_Number__c,
                                        State_Status__c,
                                        Stops__c,
                                        Type__c,
                                        Vendor_Equipment_No__c,
                                        Visit_Count__c,
                                        Days_PM_Past_Due__c,

                                        Opportunity__r.year5_test_covered__c,
                                        Opportunity__r.Annual_test_covered__c

                                    FROM Equipment__c
                                    WHERE Opportunity__r.accountId = :accountId
                                    ORDER BY Display_Name__c])
        {
            // Enclosing parenthesis this way to avoid breaking the VSC formatting
            result.Add(record);
        }

        return result;
    }

    public static PortalEquipmentWrapper[] getEquipmentWrappers(Equipment__c[] equipments, Schindler_Maintenance_Activity__c[] activities) {

        return getEquipmentWrappers(equipments, activities, true);
    }

    public static PortalEquipmentWrapper[] getEquipmentWrappers(Equipment__c[] equipments, Schindler_Maintenance_Activity__c[] activities, Boolean hasBreak) {

        PortalEquipmentWrapper[] result = new PortalEquipmentWrapper[] {};

        for (Equipment__c equipment :equipments) {

            for (Schindler_Maintenance_Activity__c activity :activities) {

                if (equipment.Id == activity.Equipment__c) {
                    result.add(new PortalEquipmentWrapper(equipment, activity));

                    if (hasBreak) {
                        break;
                    }
                }
            }
        }

        return result;
    }

}