public without sharing class PortalInsightsController {

    @AuraEnabled
    public static InsightsWrapper getInsights(Id accountId) {

        return getInsights(accountId, Date.today().addYears(-5), Date.today());
    }

    public static InsightsWrapper getInsights(Id accountId, Date startDate, Date endDate) {

        InsightsWrapper result = new InsightsWrapper();

        // Load Activity Data
        Schindler_Maintenance_Activity__c[] maintenanceActivities = new Schindler_Maintenance_Activity__c[] {};
        Schindler_Maintenance_Activity__c[] callbackActivities = new Schindler_Maintenance_Activity__c[] {};
        Schindler_Maintenance_Activity__c[] testingActivities = new Schindler_Maintenance_Activity__c[] {};
        Schindler_Maintenance_Activity__c[] activities = PortalController.getActivities(accountId, startDate, endDate);

        Integer maintenanceTasksQuantity = 0;
        Decimal maintenanceDuration = 0;
        Decimal responseTime = 0;

        for (Schindler_Maintenance_Activity__c activity :activities) {

            if (PortalConstants.TESTING_TYPE.equalsIgnoreCase(activity.Type__c)) {
                // maintenanceActivities.add(activity);

                if (PortalConstants.CATEGORY_1.equalsIgnoreCase(activity.Category__c)) {

                    if (activity.Departure_DateTime__c != null) {
                        result.category1.firstAmount ++;
                    }
                    else {
                        result.category1.secondAmount ++;
                    }
                }
                else if (PortalConstants.CATEGORY_5.equalsIgnoreCase(activity.Category__c)) {

                    if (activity.Departure_DateTime__c != null) {
                        result.category5.firstAmount ++;
                    }
                    else {
                        result.category5.secondAmount ++;
                    }
                }
            }
            else if (PortalConstants.MAINTENANCE_TYPE.equalsIgnoreCase(activity.Type__c)) {
                // testingActivities.add(activity);

                maintenanceTasksQuantity ++;
                responseTime += activity.Response_Time__c != null ? activity.Response_Time__c : 0;
                maintenanceDuration += activity.Maintenance_Duration__c != null ? activity.Maintenance_Duration__c : 0;

                if (activity.Departure_DateTime__c != null) {
                    result.maintenance.firstAmount ++;
                }
                else {
                    result.maintenance.secondAmount ++;
                }
            }
            else if (PortalConstants.CALLBACK_TYPE.equalsIgnoreCase(activity.Type__c)) {
                // callbackActivities.add(activity);
                result.callbacks ++;
            }
        }

        result.maintenance.firstAmountLabel = 'Completed';
        result.maintenance.secondAmountLabel = 'Not Completed';
        result.category1.firstAmountLabel = 'Completed';
        result.category1.secondAmountLabel = 'Not Completed';
        result.category5.firstAmountLabel = 'Completed';
        result.category5.secondAmountLabel = 'Not Completed';

        if (maintenanceTasksQuantity > 0) {
            result.responseAverage = (responseTime / maintenanceTasksQuantity).intValue();
            result.maintenanceAverage = (maintenanceDuration / maintenanceTasksQuantity).intValue();
        }

        // Load Invoice Data
        Schindler_Invoice_History__c[] invoices = PortalController.getInvoices(null, accountId);

        Integer acceptedInvoicesQuantity = 0;
        Integer disputedInvoicesQuantity = 0;
        Integer openInvoicesQuantity = 0;

        for (Schindler_Invoice_History__c invoiceRecord :invoices) {

            result.totalBilledInvoices.total += invoiceRecord.Invoice_Total__c != null ? invoiceRecord.Invoice_Total__c : 0;

            if (PortalConstants.PAY_STATUS.equalsIgnoreCase(invoiceRecord.UserStatus__c)) {
                acceptedInvoicesQuantity ++;
            }
            else if (PortalConstants.DISPUTE_STATUS.equalsIgnoreCase(invoiceRecord.UserStatus__c)) {
                disputedInvoicesQuantity ++;
            }
            else {
                openInvoicesQuantity ++;
            }
        }

        result.totalBilledInvoices.firstAmount = openInvoicesQuantity;
        result.totalBilledInvoices.firstAmountLabel = 'Open';
        result.totalBilledInvoices.secondAmount = disputedInvoicesQuantity;
        result.totalBilledInvoices.secondAmountLabel = 'Disputed';
        result.totalBilledInvoices.thirdAmount = acceptedInvoicesQuantity;
        result.totalBilledInvoices.thirdAmountLabel = 'Accepted';

        // Load Proposal Data
        Proposal__c[] proposals = PortalController.getProposalsHistory(accountId);

        Integer openProposalsQuantity = 0;
        Integer acceptedProposalsQuantity = 0;
        Integer declinedProposalsQuantity = 0;

        for (Proposal__c proposalRecord :proposals) {

            result.totalProposedRepairs.total += proposalRecord.Price__c != null ? proposalRecord.Price__c : 0;

            if (PortalConstants.ACCEPTED_STATUS.equalsIgnoreCase(proposalRecord.CustomerStatus__c)) {
                acceptedProposalsQuantity ++;
            }
            else if (PortalConstants.DECLINED_STATUS.equalsIgnoreCase(proposalRecord.CustomerStatus__c)) {
                declinedProposalsQuantity ++;
            }
            else {
                openProposalsQuantity ++;
            }
        }

        result.totalProposedRepairs.firstAmount = openProposalsQuantity;
        result.totalProposedRepairs.firstAmountLabel = 'Open';
        result.totalProposedRepairs.secondAmount = declinedProposalsQuantity;
        result.totalProposedRepairs.secondAmountLabel = 'Declined';
        result.totalProposedRepairs.thirdAmount = acceptedProposalsQuantity;
        result.totalProposedRepairs.thirdAmountLabel = 'Accepted';

        //Load Certificates
        Equipment__c[] equipments = PortalController.getUnits(null, accountId);

        Integer expiredCertificatesQuantity = 0;
        Integer activeCertificatesQuantity = 0;

        for (Equipment__c equipmentRecord :equipments) {

            if (equipmentRecord.State_Certificate_Expiration_Date__c != null && equipmentRecord.State_Certificate_Expiration_Date__c < Date.today()) {
                expiredCertificatesQuantity ++;
            }
            else {
                activeCertificatesQuantity ++;
            }
        }

        result.certificates.firstAmount = activeCertificatesQuantity;
        result.certificates.firstAmountLabel = 'Active';
        result.certificates.secondAmount = expiredCertificatesQuantity;
        result.certificates.secondAmountLabel = 'Expired';

        // Load State Records with Inspections
        State_Inspection__c[] inspections = PortalController.getStateRecordsWithInspections(null, accountId);

        Integer averageViolations = 0;
        Integer passedInspections = 0;
        Integer incompleteInspections = 0;
        Integer failedInspections = 0;

        for (State_Inspection__c inspectionRecord :inspections) {

            if (inspectionRecord.Inspection_Findings__r != null) {
                averageViolations += inspectionRecord.Inspection_Findings__r.size();
            }

            if (PortalConstants.INSPECTION_PASS.equalsIgnoreCase(inspectionRecord.Result__c) ||
                PortalConstants.INSPECTION_PASS_CONDITIONS.equalsIgnoreCase(inspectionRecord.Result__c)) {

                passedInspections ++;
            }
            else if (PortalConstants.INSPECTION_INCOMPLETE.equalsIgnoreCase(inspectionRecord.Result__c)) {

                incompleteInspections ++;
            }
            else if (PortalConstants.INSPECTION_FAIL.equalsIgnoreCase(inspectionRecord.Result__c)) {

                failedInspections ++;
            }
        }

        result.stateInspectionReports.firstAmount = passedInspections;
        result.stateInspectionReports.firstAmountLabel = 'Passed';
        result.stateInspectionReports.secondAmount = incompleteInspections;
        result.stateInspectionReports.secondAmountLabel = 'Incomplete';
        result.stateInspectionReports.thirdAmount = failedInspections;
        result.stateInspectionReports.thirdAmountLabel = 'Failed';

        if (!inspections.isEmpty()) {
            result.violationAverage = averageViolations / inspections.size();
        }

        return result;
    }

    public class InsightsWrapper {

        @AuraEnabled
        public InsightsChartWrapper maintenance {get; set;}

        @AuraEnabled
        public InsightsChartWrapper category1 {get; set;}

        @AuraEnabled
        public InsightsChartWrapper category5 {get; set;}

        @AuraEnabled
        public Integer maintenanceAverage {get; set;}

        @AuraEnabled
        public Integer responseAverage {get; set;}

        @AuraEnabled
        public Integer callbacks {get; set;}

        @AuraEnabled
        public Decimal violationAverage {get; set;}

        @AuraEnabled
        public InsightsChartWrapper totalContractSpending {get; set;}

        @AuraEnabled
        public InsightsChartWrapper totalBilledInvoices {get; set;}

        @AuraEnabled
        public InsightsChartWrapper totalProposedRepairs {get; set;}

        @AuraEnabled
        public InsightsChartWrapper stateInspectionReports {get; set;}

        @AuraEnabled
        public InsightsChartWrapper certificates {get; set;}

        public InsightsWrapper() {
            callbacks = 0;
            responseAverage = 0;
            maintenanceAverage = 0;
            violationAverage = 0;

            maintenance = new InsightsChartWrapper();
            category1 = new InsightsChartWrapper();
            category5 = new InsightsChartWrapper();

            totalBilledInvoices = new InsightsChartWrapper();
            certificates = new InsightsChartWrapper();
            stateInspectionReports = new InsightsChartWrapper();
            totalProposedRepairs = new InsightsChartWrapper();
        }
    }

    public class InsightsChartWrapper {

        @AuraEnabled
        public Decimal firstAmount {get; set;}

        @AuraEnabled
        public Decimal secondAmount {get; set;}

        @AuraEnabled
        public Decimal thirdAmount {get; set;}

        @AuraEnabled
        public Decimal total {get; set;}

        @AuraEnabled
        public String firstAmountLabel {get; set;}

        @AuraEnabled
        public String secondAmountLabel {get; set;}

        @AuraEnabled
        public String thirdAmountLabel {get; set;}

        public InsightsChartWrapper() {

            firstAmount = 0;
            secondAmount = 0;
            thirdAmount = 0;
            total = 0;
        }
    }
}