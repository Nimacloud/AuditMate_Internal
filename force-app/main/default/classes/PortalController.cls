public without sharing class PortalController {

    public static final String VAV = 'Verified as Valid';
    public static final String VAI = 'Verified as Invalid';
    public static final String VAU = 'Unverified';

    public static final String[] VAL = new String[] {VAV, VAI};

    // SERVICE METHODS

    @AuraEnabled
    public static PortalEquipmentWrapper[] getServicePreventiveActivities(Id accountId) {

        Equipment__c[] equipments = PortalControllerHelper.getUnits(accountId);
        Schindler_Maintenance_Activity__c[] activities = getPreventiveActivities(accountId);

        return PortalControllerHelper.getEquipmentWrappers(equipments, activities);
    }

    @AuraEnabled
    public static PortalEquipmentWrapper[] getServiceTestingActivities(Id accountId) {

        Equipment__c[] equipments = PortalControllerHelper.getUnits(accountId);
        Schindler_Maintenance_Activity__c[] activities = getTestingActivities(accountId);

        return PortalControllerHelper.getEquipmentWrappers(equipments, activities);
    }

    @AuraEnabled
    public static PortalEquipmentWrapper[] getServiceRepairActivities(Id accountId) {

        Equipment__c[] equipments = PortalControllerHelper.getUnits(accountId);
        Schindler_Maintenance_Activity__c[] activities = getRepairActivities(accountId);

        return PortalControllerHelper.getEquipmentWrappers(equipments, activities);
    }

    @AuraEnabled
    public static PortalEquipmentWrapper[] getServiceCallbackActivities(Id accountId) {

        Equipment__c[] equipments = PortalControllerHelper.getUnits(accountId);
        Schindler_Maintenance_Activity__c[] activities = getCallbacksActivities(accountId);

        return PortalControllerHelper.getEquipmentWrappers(equipments, activities);
    }

    @AuraEnabled
    public static PortalEquipmentWrapper[] getServiceAllActivities(Id accountId, String period) {

        Equipment__c[] equipments = PortalControllerHelper.getUnits(accountId);
        Schindler_Maintenance_Activity__c[] activities = getAllActivities(accountId, period);

        return PortalControllerHelper.getEquipmentWrappers(equipments, activities, false);
    }

    @AuraEnabled
    public static PortalEquipmentWrapper[] getServicePeriodActivities(Id accountId, Date startDate, Date endDate) {

        Equipment__c[] equipments = PortalControllerHelper.getUnits(accountId);
        Schindler_Maintenance_Activity__c[] activities = getActivities(accountId, startDate, endDate);

        return PortalControllerHelper.getEquipmentWrappers(equipments, activities, false);
    }


    // FINANCE METHODS

    @AuraEnabled
    public static Schindler_Invoice_History__c[] getFinanceOpenInvoices(Id accountId) {

        return getOpenInvoices(UserInfo.getUserId(), accountId);
    }

    @AuraEnabled
    public static Schindler_Invoice_History__c[] getFinanceDisputedInvoices(Id accountId) {

        return getDisputedInvoices(UserInfo.getUserId(), accountId);
    }

    @AuraEnabled
    public static Schindler_Invoice_History__c[] getFinanceAllInvoices(Id accountId) {

        return getPaidInvoices(UserInfo.getUserId(), accountId);
        // return getInvoices(UserInfo.getUserId(), accountId);


    }

    @AuraEnabled
    public static List<Schindler_Maintenance_Activity__c> getUpcomingActivities(Id accountId) {
        // Note: Data from Schindler is not clean.  They have TESTs that are designated as MNT types, so to filter these out, ignore records where the description__c is like Cat% or like Fire%.
        List<Schindler_Maintenance_Activity__c> data = new List<Schindler_Maintenance_Activity__c>();
        for (List<Schindler_Maintenance_Activity__c> dataList : [
        SELECT Id,
        Arrival_DateTime__c,
        Arrival_date__c,
        Arrival_time__c,
        Caller__c,
        Call_Placed_DateTime__c,
        Call_placed_date__c,
        Call_placed_time__c,
        Closed_date__c,
        Closed_time__c,
        ContractNo__c,
        Departure_DateTime__c,
        Description__c,
        Dispatched_DateTime__c,
        Dispatched_date__c,
        Dispatched_time__c,
        Employee__c,
        EquipName__c,
        EquipNo__c,
        EquipStatus__c,
        JobID__c,
        Location__c,
        Opportunity__c,
        Opportunity__r.Name,
        Opportunity__r.Account.Name,
        Resolution__c,
        Task_Completed__c,
        Type__c,
        VisitDate__c,
        Equipment__c,
        Category__c
        FROM Schindler_Maintenance_Activity__c
        WHERE Opportunity__r.accountId = :accountId
        AND VisitDate__c > TODAY
        ORDER BY VisitDate__c Desc
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    public static List<Schindler_Maintenance_Activity__c> getPreventiveActivities(Id accountId) {
        // Note: Data from Schindler is not clean.  They have TESTs that are designated as MNT types, so to filter these out, ignore records where the description__c is like Cat% or like Fire%.
        List<Schindler_Maintenance_Activity__c> data = new List<Schindler_Maintenance_Activity__c>();
        for (List<Schindler_Maintenance_Activity__c> dataList : [
        SELECT Id,
        Arrival_DateTime__c,
        Arrival_date__c,
        Arrival_time__c,
        Caller__c,
        Call_Placed_DateTime__c,
        Call_placed_date__c,
        Call_placed_time__c,
        Closed_date__c,
        Closed_time__c,
        ContractNo__c,
        Departure_DateTime__c,
        Description__c,
        Dispatched_DateTime__c,
        Dispatched_date__c,
        Dispatched_time__c,
        Employee__c,
        EquipName__c,
        EquipNo__c,
        EquipStatus__c,
        JobID__c,
        Location__c,
        Opportunity__c,
        Opportunity__r.Name,
        Opportunity__r.Account.Name,
        Resolution__c,
        Task_Completed__c,
        Equipment__c,
        Type__c,
        VisitDate__c
        FROM Schindler_Maintenance_Activity__c
        WHERE Opportunity__r.accountId = :accountId AND Type__c = 'MNT'
        ORDER BY VisitDate__c Desc
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    public static List<Schindler_Maintenance_Activity__c> getTestingActivities(Id accountId) {
        // Note: Data from Schindler is not clean.  They have Fire, Cat1 and Cat5 TESTs that are designated as MNT types in some cases.
        List<Schindler_Maintenance_Activity__c> data = new List<Schindler_Maintenance_Activity__c>();
        for (List<Schindler_Maintenance_Activity__c> dataList : [
        SELECT Id,
        Arrival_DateTime__c,
        Arrival_date__c,
        Arrival_time__c,
        Caller__c,
        Call_Placed_DateTime__c,
        Call_placed_date__c,
        Call_placed_time__c,
        Closed_date__c,
        Closed_time__c,
        ContractNo__c,
        Departure_DateTime__c,
        Description__c,
        Dispatched_DateTime__c,
        Dispatched_date__c,
        Dispatched_time__c,
        Employee__c,
        EquipName__c,
        EquipNo__c,
        EquipStatus__c,
        JobID__c,
        Location__c,
        Opportunity__c,
        Opportunity__r.Name,
        Opportunity__r.Account.Name,
        Resolution__c,
        Task_Completed__c,
        Type__c,
        Equipment__c,
        VisitDate__c
        FROM Schindler_Maintenance_Activity__c
        WHERE Opportunity__r.accountId = :accountId AND (Type__c = 'TEST' OR  (Description__c LIKE 'Cat%' ) OR (Description__c LIKE 'Fire%' ))
        ORDER BY VisitDate__c Desc
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    public static List<Schindler_Maintenance_Activity__c> getRepairActivities(Id accountId) {
        List<Schindler_Maintenance_Activity__c> data = new List<Schindler_Maintenance_Activity__c>();
        for (List<Schindler_Maintenance_Activity__c> dataList : [
        SELECT Id,
        Arrival_DateTime__c,
        Arrival_date__c,
        Arrival_time__c,
        Caller__c,
        Call_Placed_DateTime__c,
        Call_placed_date__c,
        Call_placed_time__c,
        Closed_date__c,
        Closed_time__c,
        ContractNo__c,
        Departure_DateTime__c,
        Description__c,
        Dispatched_DateTime__c,
        Dispatched_date__c,
        Dispatched_time__c,
        Employee__c,
        EquipName__c,
        EquipNo__c,
        EquipStatus__c,
        JobID__c,
        Location__c,
        Opportunity__c,
        Opportunity__r.Name,
        Opportunity__r.Account.Name,
        Resolution__c,
        Task_Completed__c,
        Type__c,
        Equipment__c,
        VisitDate__c
        FROM Schindler_Maintenance_Activity__c
        WHERE Opportunity__r.accountId = :accountId AND Type__c = 'REP'
        ORDER BY VisitDate__c Desc
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    public static List<Schindler_Maintenance_Activity__c> getCallbacksActivities(Id accountId) {
        List<Schindler_Maintenance_Activity__c> data = new List<Schindler_Maintenance_Activity__c>();
        for (List<Schindler_Maintenance_Activity__c> dataList : [
        SELECT Id,
        Arrival_DateTime__c,
        Arrival_date__c,
        Arrival_time__c,
        Caller__c,
        Call_Placed_DateTime__c,
        Call_placed_date__c,
        Call_placed_time__c,
        Closed_date__c,
        Closed_time__c,
        ContractNo__c,
        Departure_DateTime__c,
        Description__c,
        Dispatched_DateTime__c,
        Dispatched_date__c,
        Dispatched_time__c,
        Employee__c,
        EquipName__c,
        EquipNo__c,
        EquipStatus__c,
        JobID__c,
        Location__c,
        Opportunity__c,
        Opportunity__r.Name,
        Opportunity__r.Account.Name,
        Resolution__c,
        Task_Completed__c,
        Type__c,
        Equipment__c,
        VisitDate__c
        FROM Schindler_Maintenance_Activity__c
        WHERE Opportunity__r.accountId = :accountId AND Type__c = 'CB'
        ORDER BY VisitDate__c Desc
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    public static List<Schindler_Maintenance_Activity__c>  getTodayActivities (Id accountId) {
        return getAllActivities(accountId, 'TODAY');
    }

    @AuraEnabled
    public static List<Schindler_Maintenance_Activity__c>  getThisWeekActivities(Id accountId) {
        return getAllActivities(accountId, 'THIS_WEEK');
    }

    @AuraEnabled
    public static List<Schindler_Maintenance_Activity__c>  getLastWeekActivities(Id accountId) {
        return getAllActivities(accountId, 'LAST_WEEK');
    }

    @AuraEnabled
    public static List<Schindler_Maintenance_Activity__c>  getThisMonthActivities(Id accountId) {
        return getAllActivities(accountId, 'THIS_MONTH');
    }

    @AuraEnabled
    public static List<Schindler_Maintenance_Activity__c>  getLastMonthActivities(Id accountId) {
        return getAllActivities(accountId, 'LAST_MONTH');
    }

    @AuraEnabled
    public static List<Schindler_Maintenance_Activity__c> getAllActivities(Id accountId, String period) {
        List<Schindler_Maintenance_Activity__c> data = new List<Schindler_Maintenance_Activity__c>();
        switch on period {
            when 'TODAY' {
                for (List<Schindler_Maintenance_Activity__c> dataList : [
                SELECT Equipment__c, Arrival_DateTime__c,Caller__c,Call_Placed_DateTime__c,ContractNo__c,Departure_DateTime__c,Description__c,Dispatched_DateTime__c,Employee__c,EquipName__c,EquipNo__c,EquipStatus__c,Id,JobID__c,Location__c,Name,Opportunity__c,Opportunity__r.Name,Opportunity__r.Account.Name,Resolution__c,Type__c,VisitDate__c
                FROM Schindler_Maintenance_Activity__c
                WHERE Opportunity__r.accountId = :accountId AND VisitDate__c >= TODAY
                ORDER BY VisitDate__c Desc
                ]) {
                    data.addAll(dataList);
                }
            }
            when 'THIS_WEEK' {
                for (List<Schindler_Maintenance_Activity__c> dataList : [
                SELECT Equipment__c, Arrival_DateTime__c,Caller__c,Call_Placed_DateTime__c,ContractNo__c,Departure_DateTime__c,Description__c,Dispatched_DateTime__c,Employee__c,EquipName__c,EquipNo__c,EquipStatus__c,Id,JobID__c,Location__c,Name,Opportunity__c,Opportunity__r.Name,Opportunity__r.Account.Name,Resolution__c,Type__c,VisitDate__c
                FROM Schindler_Maintenance_Activity__c
                WHERE Opportunity__r.accountId = :accountId AND VisitDate__c = THIS_WEEK
                ORDER BY VisitDate__c Desc
                ]) {
                    data.addAll(dataList);
                }
            }
            when 'LAST_WEEK' {
                for (List<Schindler_Maintenance_Activity__c> dataList : [
                SELECT Equipment__c, Arrival_DateTime__c,Caller__c,Call_Placed_DateTime__c,ContractNo__c,Departure_DateTime__c,Description__c,Dispatched_DateTime__c,Employee__c,EquipName__c,EquipNo__c,EquipStatus__c,Id,JobID__c,Location__c,Name,Opportunity__c,Opportunity__r.Name,Opportunity__r.Account.Name,Resolution__c,Type__c,VisitDate__c
                FROM Schindler_Maintenance_Activity__c
                WHERE Opportunity__r.accountId = :accountId AND VisitDate__c = LAST_WEEK
                ORDER BY VisitDate__c Desc
                ]) {
                    data.addAll(dataList);
                }
            }
            when 'THIS_MONTH' {
                for (List<Schindler_Maintenance_Activity__c> dataList : [
                SELECT Equipment__c, Arrival_DateTime__c,Caller__c,Call_Placed_DateTime__c,ContractNo__c,Departure_DateTime__c,Description__c,Dispatched_DateTime__c,Employee__c,EquipName__c,EquipNo__c,EquipStatus__c,Id,JobID__c,Location__c,Name,Opportunity__c,Opportunity__r.Name,Opportunity__r.Account.Name,Resolution__c,Type__c,VisitDate__c
                FROM Schindler_Maintenance_Activity__c
                WHERE Opportunity__r.accountId = :accountId AND VisitDate__c = THIS_MONTH
                ORDER BY VisitDate__c Desc
                ]) {
                    data.addAll(dataList);
                }
            }
            when 'LAST_MONTH' {
                for (List<Schindler_Maintenance_Activity__c> dataList : [
                SELECT Equipment__c, Arrival_DateTime__c,Caller__c,Call_Placed_DateTime__c,ContractNo__c,Departure_DateTime__c,Description__c,Dispatched_DateTime__c,Employee__c,EquipName__c,EquipNo__c,EquipStatus__c,Id,JobID__c,Location__c,Name,Opportunity__c,Opportunity__r.Name,Opportunity__r.Account.Name,Resolution__c,Type__c,VisitDate__c
                FROM Schindler_Maintenance_Activity__c
                WHERE Opportunity__r.accountId = :accountId AND VisitDate__c = LAST_MONTH
                ORDER BY VisitDate__c Desc
                ]) {
                    data.addAll(dataList);
                }
            }
            when else {}
        }
        return data;
    }

    @AuraEnabled
    public static List<Schindler_Maintenance_Activity__c> getActivities(Id accountId, Date StartDate, Date EndDate) {
        List<Schindler_Maintenance_Activity__c> data = new List<Schindler_Maintenance_Activity__c>();
        for (List<Schindler_Maintenance_Activity__c> dataList : [
        SELECT Category__c, Response_Time__c, Maintenance_Duration__c, Equipment__c, Arrival_DateTime__c,Caller__c,Call_Placed_DateTime__c,ContractNo__c,Departure_DateTime__c,Description__c,Dispatched_DateTime__c,Employee__c,EquipName__c,EquipNo__c,EquipStatus__c,Id,JobID__c,Location__c,Name,Opportunity__c,Opportunity__r.Name,Opportunity__r.Account.Name,Resolution__c,Type__c,VisitDate__c
        FROM Schindler_Maintenance_Activity__c
        WHERE Opportunity__r.accountId = :accountId AND VisitDate__c >= :StartDate AND VisitDate__c <= :EndDate
        ORDER BY VisitDate__c Desc
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    public static List<Equipment__c> getUnits(Id userId, Id accountId) {
        List<Equipment__c> data = new List<Equipment__c>();
        for (Equipment__c equipmentRecord : [
        SELECT
            Last_12_Month_PM_Percent__c,
            Opportunity__r.year5_test_covered__c,
            Opportunity__r.Annual_test_covered__c,
            Last_12_Month_CB_Count__c,
            Last_CB_Date__c,
            Days_PM_Past_Due__c,
            Cat1_Count__c,
            Cat5_Count__c,
            Class__c,
            Controller_Type__c,
            Display_Name__c,
            Id,
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
            Number_of_Callbacks__c,
            Number_of_Maintenance_Visits__c,
            Number_of_Repairs__c,
            Category_1_Due_Days__c,
            Category_1_Status__c,
            Category_5_Due_Days__c,
            Category_5_Status__c,
            Customer_Email__c,
            Customer_Name__c,
            Customer_Number__c,
            Last_Callback_Date__c,
            Last_Category_1_Date__c,
            Last_Category_5_Date__c,
            Last_Maintenance_Date__c,
            Maintenance_Due_Days__c,
            Maintenance_Status__c,
            Maintenance_Status_Image__c,
            Next_Category_1_Date__c,
            Next_Category_5_Date__c,
            Next_Maintenance_Date__c,
            Past_Due__c,
            Vendor_Name__c,

            (SELECT Id
                FROM Schindler_Maintenance_Activities__r
                WHERE Type__c = 'CB'
                AND VisitDate__c >= LAST_N_MONTHS:12)

        FROM Equipment__c
        WHERE Opportunity__r.accountId = :accountId
        ORDER BY Display_Name__c
        ]) {

            equipmentRecord.Last_12_Month_CB_Count__c = equipmentRecord.Schindler_Maintenance_Activities__r.size();
            data.add(equipmentRecord);
        }

        update data;
        return data;
    }

    @AuraEnabled
    public static List<Equipment__c> getUnitsAndInspections(Id userId, Id accountId) {
        List<Equipment__c> data = new List<Equipment__c>();
        for (List<Equipment__c> dataList : [
        SELECT Cat1_Count__c,Cat5_Count__c,Class__c,Controller_Type__c,Display_Name__c,Id,Inspection_Witness__c,Last_12_Month_Count__c,Last_30_Day_Count__c,Last_Cat1_Date__c,Last_Cat5_Date__c,Last_Cleandown_Date__c,Last_Index_Test_Date__c,Last_PM_Date__c,Last_Visit_Date__c,Last_Visit_Reason__c,Load_Lb__c,Name,Next_Cat1_Date__c,Next_Cat5_Date__c,Next_Cleandown_Date__c,Next_Index_Test_Date__c,Next_PM_Date__c,Opportunity__c,Remote_Monitoring__c,Speed__c,State_Certificate_Expiration_Date__c,State_Certificate_First_Issue_Date__c,State_Certificate_Issue_Date__c,State_Elevator_Subtype__c,State_Elevator_Type__c,State_ID__c,State_Location_City__c,State_Location_Description__c,State_Location_Street__c,State_Location_Zip__c,State_Owner_Name__c,State_Region__c,State_Serial_Number__c,State_Status__c,Stops__c,Type__c,Vendor_Equipment_No__c,Visit_Count__c,
        (SELECT Completed_Date__c,Due_Date__c,Inspection_Findings__c,Inspection_ID__c,Inspector_Name__c,Inspector_Phone_Number__c,Name__c,Result__c,Scheduled_Date__c,State_ID__c,Type_of_Inspection__c,Vendor_Equipment_Number__c FROM State_Inspections__r ORDER BY Completed_Date__c Desc)
        FROM Equipment__c
        WHERE Opportunity__r.accountId = :accountId
        ORDER BY Vendor_Equipment_No__c
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    public static List<Schindler_Invoice_History__c> getInvoices(Id userId, Id accountId) {
        List<Schindler_Invoice_History__c> data = new List<Schindler_Invoice_History__c>();
        for (List<Schindler_Invoice_History__c> dataList : [
        SELECT Invoice_Status__c, Disputed_Date__c, Account__c,Audit_Comments__c,Billing_Id__c,Bill_To__c,ContentVersionId__c,Contract__c,Customer_Comments__c,DaysToPay__c,Description__c,Duns_Number__c,Expenses__c,Fax__c,Federal_Tax_Id__c,Field_Contact__c,Id,Internal_Comments__c,Invoice_Date__c,Invoice_Due_Date__c,Invoice_Number__c,Invoice_Total__c,Labor__c,Local_Office__c,Name,Notification__c,Opportunity__c, Opportunity__r.Vendor_Contract_Number__c, Opportunity__r.Elevator_Vendor_Account__r.Name, Order_No__c,Order_Type__c,Payer__c,PdfFilename__c,Problems__c,Problem_Count__c,Remit_To__c,Sales_Contact__c,Service_Location__c,Sub_Total__c,SystemStatus__c,Tax__c,Telephone__c,UserStatus__c
        FROM Schindler_Invoice_History__c
        WHERE Opportunity__r.accountId = :accountId
        AND Mate_Support_Status__c IN :VAL
        ORDER BY Invoice_Number__c
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    public static List<Schindler_Invoice_History__c> getOpenInvoices(Id userId, Id accountId) {
        List<Schindler_Invoice_History__c> data = new List<Schindler_Invoice_History__c>();
        for (List<Schindler_Invoice_History__c> dataList : [
        SELECT Equipment_Name__c, Vendor_Name__c, Vendor__c, Vendor__r.Name, Mate_Support_Status__c, Vendor_Comments__c, Invoice_Status__c, Disputed_Date__c, Account__c, Account__r.Name ,Audit_Comments__c,Billing_Id__c,Bill_To__c,ContentVersionId__c,Contract__c,Customer_Comments__c,DaysToPay__c,Description__c,Duns_Number__c,Expenses__c,Fax__c,Federal_Tax_Id__c,Field_Contact__c,Id,Internal_Comments__c,Invoice_Date__c,Invoice_Due_Date__c,Invoice_Number__c,Invoice_Total__c,Labor__c,Local_Office__c,Name,Notification__c,Opportunity__c, Opportunity__r.Vendor_Contract_Number__c, Opportunity__r.Elevator_Vendor_Account__r.Name, Order_No__c,Order_Type__c,Payer__c,PdfFilename__c,Problems__c,Problem_Count__c,Remit_To__c,Sales_Contact__c,Service_Location__c,Sub_Total__c,SystemStatus__c,Tax__c,Telephone__c,UserStatus__c,
        (SELECT Id, Invoice__c, Description__c, CreatedDate  FROM Invoice_Comments__r ORDER BY CreatedDate DESC)
        FROM Schindler_Invoice_History__c
        WHERE Opportunity__r.accountId = :accountId
        AND UserStatus__c = 'Awaiting User Action'
        AND Mate_Support_Status__c IN :VAL
        ORDER BY Invoice_Number__c
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    public static List<Schindler_Invoice_History__c> getDisputedInvoices(Id userId, Id accountId) {
        List<Schindler_Invoice_History__c> data = new List<Schindler_Invoice_History__c>();
        for (List<Schindler_Invoice_History__c> dataList : [
        SELECT Equipment_Name__c, Vendor_Name__c, Vendor__c, Vendor__r.Name, Mate_Support_Status__c, Vendor_Comments__c, Invoice_Status__c, Disputed_Date__c, Account__c, Account__r.Name ,Audit_Comments__c,Billing_Id__c,Bill_To__c,ContentVersionId__c,Contract__c,Customer_Comments__c,DaysToPay__c,Description__c,Duns_Number__c,Expenses__c,Fax__c,Federal_Tax_Id__c,Field_Contact__c,Id,Internal_Comments__c,Invoice_Date__c,Invoice_Due_Date__c,Invoice_Number__c,Invoice_Total__c,Labor__c,Local_Office__c,Name,Notification__c,Opportunity__c, Opportunity__r.Vendor_Contract_Number__c, Opportunity__r.Elevator_Vendor_Account__r.Name ,Order_No__c,Order_Type__c,Payer__c,PdfFilename__c,Problems__c,Problem_Count__c,Remit_To__c,Sales_Contact__c,Service_Location__c,Sub_Total__c,SystemStatus__c,Tax__c,Telephone__c,UserStatus__c,
        (SELECT Id, Invoice__c, Description__c, CreatedDate  FROM Invoice_Comments__r ORDER BY CreatedDate DESC)
        FROM Schindler_Invoice_History__c
        WHERE Opportunity__r.accountId = :accountId
        AND UserStatus__c = 'Dispute'
        AND Mate_Support_Status__c IN :VAL
        ORDER BY Invoice_Number__c
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    public static List<Schindler_Invoice_History__c> getPaidInvoices(Id userId, Id accountId) {
        List<Schindler_Invoice_History__c> data = new List<Schindler_Invoice_History__c>();
        for (List<Schindler_Invoice_History__c> dataList : [
        SELECT Equipment_Name__c, Vendor_Name__c, Vendor__c, Vendor__r.Name, Mate_Support_Status__c, Vendor_Comments__c, Invoice_Status__c, Disputed_Date__c, Account__c, Account__r.Name ,Audit_Comments__c,Billing_Id__c,Bill_To__c,ContentVersionId__c,Contract__c,Customer_Comments__c,DaysToPay__c,Description__c,Duns_Number__c,Expenses__c,Fax__c,Federal_Tax_Id__c,Field_Contact__c,Id,Internal_Comments__c,Invoice_Date__c,Invoice_Due_Date__c,Invoice_Number__c,Invoice_Total__c,Labor__c,Local_Office__c,Name,Notification__c,Opportunity__c, Opportunity__r.Vendor_Contract_Number__c, Opportunity__r.Elevator_Vendor_Account__r.Name, Order_No__c,Order_Type__c,Payer__c,PdfFilename__c,Problems__c,Problem_Count__c,Remit_To__c,Sales_Contact__c,Service_Location__c,Sub_Total__c,SystemStatus__c,Tax__c,Telephone__c,UserStatus__c,
        (SELECT Id, Invoice__c, Description__c, CreatedDate  FROM Invoice_Comments__r ORDER BY CreatedDate DESC)
        FROM Schindler_Invoice_History__c
        WHERE Opportunity__r.accountId = :accountId
        AND UserStatus__c = 'Pay'
        AND Mate_Support_Status__c IN :VAL
        ORDER BY Invoice_Number__c
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    public static List<Schindler_Invoice_History__c> getDueInvoices(Id userId, Id accountId) {
        List<Schindler_Invoice_History__c> data = new List<Schindler_Invoice_History__c>();
        for (List<Schindler_Invoice_History__c> dataList : [
        SELECT Equipment_Name__c, Vendor_Name__c, Vendor__c, Vendor__r.Name, Mate_Support_Status__c, Vendor_Comments__c, Invoice_Status__c, Disputed_Date__c, Account__c, Account__r.Name ,Audit_Comments__c,Billing_Id__c,Bill_To__c,ContentVersionId__c,Contract__c,Customer_Comments__c,DaysToPay__c,Description__c,Duns_Number__c,Expenses__c,Fax__c,Federal_Tax_Id__c,Field_Contact__c,Id,Internal_Comments__c,Invoice_Date__c,Invoice_Due_Date__c,Invoice_Number__c,Invoice_Total__c,Labor__c,Local_Office__c,Name,Notification__c,Opportunity__c, Opportunity__r.Vendor_Contract_Number__c, Opportunity__r.Elevator_Vendor_Account__r.Name, Order_No__c,Order_Type__c,Payer__c,PdfFilename__c,Problems__c,Problem_Count__c,Remit_To__c,Sales_Contact__c,Service_Location__c,Sub_Total__c,SystemStatus__c,Tax__c,Telephone__c,UserStatus__c,
        (SELECT Id, Invoice__c, Description__c, CreatedDate  FROM Invoice_Comments__r ORDER BY CreatedDate DESC)
        FROM Schindler_Invoice_History__c
        WHERE Opportunity__r.accountId = :accountId
        AND Invoice_Due_Date__c < TODAY
        AND UserStatus__c != 'Pay'
        AND UserStatus__c != null
        AND Mate_Support_Status__c IN :VAL
        ORDER BY Invoice_Number__c
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    // To Do: *getInvoicesByStatus (need more data), but essentially it's grouping by UserStatus__c.

    @AuraEnabled
    public static List<Inspection_Findings__c> getInspectionFindings(Id accountId) {

        List<Inspection_Findings__c> data = new List<Inspection_Findings__c>();

        for( List<Inspection_Findings__c> dataList : [
                SELECT State_Inspection__r.Equipment__c, Code__c,Due_Date__c,Finding__c,Id,Inspection_Date__c,Name,Responsibility__c,State_Inspection__c,Status__c
                FROM Inspection_Findings__c
                WHERE State_Inspection__r.Opportunity__r.AccountId = :accountId
                AND Status__c = 'Open'
        ])
        {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    // Note:  Boolean isOpen is not applicable to State_Inspection records.
    public static List<State_Inspection__c> getStateRecords(Id accountId) {
        List<State_Inspection__c> data = new List<State_Inspection__c>();
        for (List<State_Inspection__c> dataList : [
        SELECT Equipment__c, Equipment__r.Display_Name__c, Completed_Date__c,Due_Date__c,Id,Inspection_Findings__c,Inspection_ID__c,Inspector_Name__c,Inspector_Phone_Number__c,Name,Name__c,Opportunity__c,Result__c,Scheduled_Date__c,State_ID__c,Type_of_Inspection__c,Vendor_Equipment_Number__c
        FROM State_Inspection__c
        WHERE Opportunity__r.accountId = :accountId
        ORDER BY Inspection_ID__c
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    // Note:  Boolean isOpen is not applicable to State_Inspection records.
    public static Map<Id, String> getStateRecordInspections(Id accountId) {

        Map<Id, String> result = new Map<Id, String>();

        for (State_Inspection__c data : [
        SELECT Equipment__c, Equipment__r.Display_Name__c, Completed_Date__c,Due_Date__c,Id,Inspection_Findings__c,Inspection_ID__c,Inspector_Name__c,Inspector_Phone_Number__c,Name,Name__c,Opportunity__c,Result__c,Scheduled_Date__c,State_ID__c,Type_of_Inspection__c,Vendor_Equipment_Number__c
        FROM State_Inspection__c
        WHERE Opportunity__r.accountId = :accountId
        ORDER BY Inspection_ID__c
        ]) {
            result.put(data.Equipment__c, data.Equipment__r.Display_Name__c);
        }

        return result;
    }

    @AuraEnabled
    // Note:  Boolean isOpen is not applicable to State_Inspection records.
    //        Status__c from Inspection_Findings__r can determine Open/Closed.
    // We don't currently have good examples of Inspection_Findings__c records.
    public static List<State_Inspection__c> getStateRecordsWithInspections(Id userId, Id accountId) {
        List<State_Inspection__c> data = new List<State_Inspection__c>();
        for (List<State_Inspection__c> dataList : [
        SELECT Completed_Date__c,Due_Date__c,Id,Inspection_Findings__c,Inspection_ID__c,Inspector_Name__c,Inspector_Phone_Number__c,Name,Name__c,Opportunity__c,Result__c,Scheduled_Date__c,State_ID__c,Type_of_Inspection__c,Vendor_Equipment_Number__c,
        (SELECT Code__c,Due_Date__c,Finding__c,Id,Inspection_Date__c,Name,Responsibility__c,State_Inspection__c,Status__c FROM Inspection_Findings__r ORDER BY Inspection_Date__c)
        FROM State_Inspection__c
        WHERE Opportunity__r.accountId = :accountId
        ORDER BY Inspection_ID__c
        ]) {
            data.addAll(dataList);
        }

        return data;
    }

    @AuraEnabled
    public static List<Proposal__c> getOpenProposals(Id accountId) {
        List<Proposal__c> data = new List<Proposal__c>();
        for (List<Proposal__c> dataList : [
        SELECT Opportunity__r.Vendor_Contract_Number__c, Opportunity__r.Elevator_Vendor_Account__r.Name, Covered_by_Contract__c,CustomerStatus__c,Date__c,Elevators__c,Estimate_Number__c,Hourly_Rate__c,Id,Labor_Hours__c,Material__c,Mate_Notes__c,Missing_Information__c,Name,Opportunity__c,Price__c,Repair_Description__c,Repair__c,Scope_Reasonable__c,Status__c,Tax__c,Unit_OOS__c,Vendor__c
        FROM Proposal__c
        WHERE Opportunity__r.accountId = :accountId
        AND CustomerStatus__c = 'Customer Review'
        ORDER BY Date__c
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    public static List<Proposal__c> getAcceptedProposals(Id userId, Id accountId) {
        List<Proposal__c> data = new List<Proposal__c>();
        for (List<Proposal__c> dataList : [
        SELECT Opportunity__r.Vendor_Contract_Number__c, Opportunity__r.Elevator_Vendor_Account__r.Name, Covered_by_Contract__c,CustomerStatus__c,Date__c,Elevators__c,Estimate_Number__c,Hourly_Rate__c,Id,Labor_Hours__c,Material__c,Mate_Notes__c,Missing_Information__c,Name,Opportunity__c,Price__c,Repair_Description__c,Repair__c,Scope_Reasonable__c,Status__c,Tax__c,Unit_OOS__c,Vendor__c
        FROM Proposal__c
        WHERE Opportunity__r.accountId = :accountId AND CustomerStatus__c = 'Accepted'
        ORDER BY Date__c
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

    @AuraEnabled
    public static List<Proposal__c> getProposalsHistory(Id accountId) {
        List<Proposal__c> data = new List<Proposal__c>();
        for (List<Proposal__c> dataList : [
        SELECT Opportunity__r.Vendor_Contract_Number__c, Opportunity__r.Elevator_Vendor_Account__r.Name, CustomerStatus__c, Covered_by_Contract__c,Date__c,Elevators__c,Estimate_Number__c,Hourly_Rate__c,Id,Labor_Hours__c,Material__c,Mate_Notes__c,Missing_Information__c,Name,Opportunity__c, Opportunity__r.Expiration_Date__c,Price__c,Repair_Description__c,Repair__c,Scope_Reasonable__c,Status__c,Tax__c,Unit_OOS__c,Vendor__c
        FROM Proposal__c
        WHERE Opportunity__r.accountId = :accountId
        AND (CustomerStatus__c = 'Accepted' OR CustomerStatus__c = 'Declined')
        ORDER BY Date__c
        ]) {
            data.addAll(dataList);
        }
        return data;
    }

}