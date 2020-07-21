public without sharing class InvoicePageController {

  @AuraEnabled (cacheable=true) 
  public static List<ServiceHistory__c> getAllTimeTickets() {
    List<ServiceHistory__c> data = new List<ServiceHistory__c>();
    Integer listLength;
    for (List<ServiceHistory__c> dataList : [
      SELECT Building_NameAddress__c, Doubletime_Onsite_time__c, Doubletime_Travel_time__c, Equipment_Name__c, Id, Name, Opportunity__c, Overtime_Onsite_time__c, Overtime_Travel_time__c, Problem_reported__c, Repoted_By__c, Service_Report_Date__c, Standard_Onsite_time__c, Standard_Travel_time__c, Status__c, Technician_Arrival_DateTime__c, Technician_Departure_DateTime__c, Technician__c, Time_unit_returned_to_service__c, Type__c, Vendor_Building_ID__c, Vendor_Contract_Number__c, Vendor_Equipment__c, Vendor_Notification__c, Vendor_Sales_Order__c, Vendor_Work_Order__c, Work_description__c 
      FROM ServiceHistory__c 
      ORDER BY Vendor_Notification__c,Service_Report_Date__c DESC Nulls Last]) {
      listLength = dataList.size();
      data.addAll(dataList);
      System.debug(listLength);
    }
    System.debug(data.size());
    return data;  
  }

  @AuraEnabled (cacheable=true) 
  public static List<Schindler_Invoice_History__c> getAllInvoices() {
    List<Schindler_Invoice_History__c> data = new List<Schindler_Invoice_History__c>();
    Integer listLength;
    for (List<Schindler_Invoice_History__c> dataList : [
      SELECT PdfFilename__c,Billing_Id__c,Bill_To__c,ContentVersionId__c,Contract__c,Description__c,Duns_Number__c,Expenses__c,Fax__c,Federal_Tax_Id__c,Field_Contact__c,Id,Invoice_Date__c,Invoice_Number__c,Invoice_Total__c,Labor__c,Local_Office__c,Notification__c,Order_No__c,Order_Type__c,Payer__c,Problems__c,Problem_Count__c,Remit_To__c,Sales_Contact__c,Service_Location__c,Sub_Total__c,Tax__c,Telephone__c 
      FROM Schindler_Invoice_History__c 
      ORDER BY Notification__c
    ]) {
      listLength = dataList.size();
      data.addAll(dataList);
      System.debug(listLength);
    }
    System.debug(data.size());
    return data;  
  }

  @AuraEnabled (cacheable=true) 
  public static List<Equipment__c> getAllEquipment() {
    List<Equipment__c> data = new List<Equipment__c>();
    Integer listLength;
    for (List<Equipment__c> dataList : [
      SELECT Id,Name,Opportunity__c,Cat1_Count__c,Cat5_Count__c,Last_30_Day_Count__c,Last_12_Month_Count__c,Last_Cat1_Date__c,Last_Cat5_Date__c,Last_Visit_Date__c,Last_Visit_Reason__c,Next_Cat1_Date__c,Next_Cat5_Date__c,Vendor_Equipment_No__c,Visit_Count__c FROM Equipment__c WHERE Vendor_Equipment_No__c != null ORDER BY Vendor_Equipment_No__c
    ]) {
      listLength = dataList.size();
      data.addAll(dataList);
      System.debug(listLength);
    }
    System.debug(data.size());
    return data;  
  }

  @AuraEnabled (cacheable=true) 
  public static List<Equipment__c> getOpportunityEquipment(String oppId) {
    List<Equipment__c> data = new List<Equipment__c>();
    Integer listLength;
    for (List<Equipment__c> dataList : [ 
      SELECT Id,Name,Opportunity__c,Cat1_Count__c,Cat5_Count__c,Last_30_Day_Count__c,Last_12_Month_Count__c,Last_Cat1_Date__c,Last_Cat5_Date__c,Last_Visit_Date__c,Last_Visit_Reason__c,Next_Cat1_Date__c,Next_Cat5_Date__c,Vendor_Equipment_No__c,Visit_Count__c FROM Equipment__c WHERE Opportunity__c = :oppId AND Vendor_Equipment_No__c != null ORDER BY Vendor_Equipment_No__c
    ]) {
      listLength = dataList.size();
      data.addAll(dataList);
      System.debug(listLength);
    }
    System.debug(data.size());
    return data;  
  }

  @AuraEnabled (cacheable=true) 
  public static List<Schindler_Maintenance_Activity__c> getAllMaintenanceVisits() {
    List<Schindler_Maintenance_Activity__c> data = new List<Schindler_Maintenance_Activity__c>();
    Integer listLength;
    for (List<Schindler_Maintenance_Activity__c> dataList : [
      SELECT Arrival_DateTime__c,Caller__c,Call_Placed_DateTime__c,ContractNo__c,Departure_DateTime__c,Description__c,Dispatched_DateTime__c,Employee__c,EquipName__c,EquipNo__c,EquipStatus__c,Id,JobID__c,Location__c,Name,Opportunity__c,Resolution__c,Task_Completed__c,Type__c,VisitDate__c 
      FROM Schindler_Maintenance_Activity__c 
      ORDER BY EquipNo__c,VisitDate__c Desc Nulls Last
    ]) {
      listLength = dataList.size();
      data.addAll(dataList);
      System.debug(listLength);
    }
    System.debug(data.size());
    return data;  
  }


  
}