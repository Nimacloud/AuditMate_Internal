public without sharing class PortalActivityController {

    @AuraEnabled
    public static ActivityWrapper getMaintenanceActivityCount(Id accountId) {

        ActivityWrapper wrapper = new ActivityWrapper();

        Opportunity[] opportunities = [SELECT
                                            Start_Date__c,
                                            Months_Since_Start__c,
                                            Frequency_of_service__c,

                                            (SELECT Id FROM Equipments__r)

                                        FROM Opportunity
                                        WHERE AccountId = :accountId
                                        AND Frequency_of_service__c = 'Monthly'
                                        AND RecordType.DeveloperName = 'Vendor_Contract'];

        if (!opportunities.isEmpty()) {

            Opportunity opportunityRecord = opportunities[0];
            Decimal valueSinceStart = Math.ceil(opportunityRecord.Months_Since_Start__c);

            wrapper = execute(opportunityRecord.Id, valueSinceStart, 'MNT', 0, 0);
            wrapper.setFrequency(true);
        }

        return wrapper;
    }

    @AuraEnabled
    public static ActivityWrapper getTestingOneActivityCount(Id accountId) {

        ActivityWrapper wrapper = new ActivityWrapper();

        Opportunity[] opportunities = [SELECT
                                            Start_Date__c,
                                            Months_Since_Start__c,
                                            Frequency_of_service__c,

                                            (SELECT Id FROM Equipments__r)

                                        FROM Opportunity
                                        WHERE AccountId = :accountId
                                        AND RecordType.DeveloperName = 'Vendor_Contract'];

        if (!opportunities.isEmpty()) {

            Opportunity opportunityRecord = opportunities[0];
            Decimal valueSinceStart = opportunityRecord.Months_Since_Start__c / 12;
            valueSinceStart = Math.ceil(valueSinceStart);

            wrapper = execute(opportunityRecord.Id, valueSinceStart, 'TEST', 1, opportunityRecord.Equipments__r.size());
        }

        wrapper.setFrequency(true);
        return wrapper;

    }

    @AuraEnabled
    public static ActivityWrapper getTestingFiveActivityCount(Id accountId) {

        ActivityWrapper wrapper = new ActivityWrapper();

        Opportunity[] opportunities = [SELECT
                                            Start_Date__c,
                                            Months_Since_Start__c,
                                            Frequency_of_service__c,

                                            (SELECT Id FROM Equipments__r)

                                        FROM Opportunity
                                        WHERE AccountId = :accountId
                                        AND RecordType.DeveloperName = 'Vendor_Contract'];

        if (!opportunities.isEmpty()) {

            Opportunity opportunityRecord = opportunities[0];

            Decimal valueSinceStart = opportunityRecord.Months_Since_Start__c / (12 * 5);
            valueSinceStart = Math.ceil(valueSinceStart);

            wrapper = execute(opportunityRecord.Id, valueSinceStart, 'TEST', 5, opportunityRecord.Equipments__r.size());
        }

        wrapper.setFrequency(true);
        return wrapper;
    }


    private static ActivityWrapper execute(Id opportunityId, Decimal valueSinceStart, String activityType, Integer testLength, Integer equipmentCount) {

        ActivityWrapper wrapper = new ActivityWrapper(testLength, equipmentCount);

        Equipment__c[] equipmentsWithActivities = new Equipment__c[] {};

        equipmentsWithActivities = [SELECT Name,
                                        (SELECT
                                            VisitDate__c,
                                            Description__c
                                        FROM Schindler_Maintenance_Activities__r
                                        WHERE Type__c = :activityType
                                        AND Opportunity__c = :opportunityId)
                                    FROM Equipment__c
                                    WHERE Opportunity__c = :opportunityId];

        for (Equipment__c equipmentWithActivities :equipmentsWithActivities) {

            Map<Date, Integer> activitiesByDate = new Map<Date, Integer>();

            Integer activityCount = equipmentWithActivities.Schindler_Maintenance_Activities__r.size();

            Decimal incompleteActivities = valueSinceStart - activityCount;

            wrapper.incompletedActivities += incompleteActivities.intValue();

            Schindler_Maintenance_Activity__c[] activityRecords = getRelevantActivities(equipmentWithActivities.Schindler_Maintenance_Activities__r, testLength);

            for (Schindler_Maintenance_Activity__c activityRecord :activityRecords) {

                Date initialVisitDate = null;

                if (testLength == 0) {
                    initialVisitDate = activityRecord.VisitDate__c.toStartOfMonth();
                }
                else {
                    initialVisitDate = Date.newInstance(activityRecord.VisitDate__c.year(), 1, 1);
                }


                if (!activitiesByDate.containsKey(initialVisitDate)) {
                    activitiesByDate.put(initialVisitDate, 0);
                }

                Integer value = activitiesByDate.get(initialVisitDate);
                activitiesByDate.put(initialVisitDate, ++value);

            }

            for (Integer value :activitiesByDate.values()) {

                wrapper.completedActivities ++;
                wrapper.lateActivities += value - 1;
            }

            wrapper.sanitizeValues();
        }

        return wrapper;

    }

    private static Schindler_Maintenance_Activity__c[] getRelevantActivities(Schindler_Maintenance_Activity__c[] records, Integer testLength) {

        Schindler_Maintenance_Activity__c[] result = new Schindler_Maintenance_Activity__c[] {};

        if (testLength == 0) {
            result = records;
        }
        else {

            for (Schindler_Maintenance_Activity__c record :records) {

                String description = record.Description__c;

                if (testLength == 5 && description.containsIgnoreCase('CAT5')) {
                    result.add(record);
                }
                else if (testLength == 1 && (description.containsIgnoreCase('CAT1') || description.containsIgnoreCase('ANNUAL'))) {
                    result.add(record);
                }
            }
        }

        return result;
    }

    public class ActivityWrapper {

        @AuraEnabled
        public Integer completedActivities {get; set;}

        @AuraEnabled
        public Integer incompletedActivities {get; set;}

        @AuraEnabled
        public Integer lateActivities {get; set;}

        @AuraEnabled
        public Boolean isMonthlyFrequency {get; set;}

        public Integer testLength;
        public Integer recordCount;

        public ActivityWrapper() {

            lateActivities = 0;
            incompletedActivities = 0;
            completedActivities = 0;
            isMonthlyFrequency = null;
        }

        public ActivityWrapper(Integer testLength, Integer recordCount) {

            this();

            this.testLength = testLength;
            this.recordCount = recordCount;
        }

        public void setFrequency(Boolean value) {
            isMonthlyFrequency = value;
        }

        public void sanitizeValues() {

            if (incompletedActivities < 0) {
                incompletedActivities = 0;
            }

            if (testLength == 5) {

                Integer totalTasks = completedActivities + incompletedActivities + lateActivities;

                if (totalTasks < recordCount) {
                    incompletedActivities += recordCount - totalTasks;
                }
            }

        }
    }

}