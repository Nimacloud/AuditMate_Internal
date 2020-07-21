public without sharing class CustomerPortalController {
  
  @ReadOnly    
  @RemoteAction
  public static List<Account> getAccounts() {
    List<Account> data = new List<Account>();
    for (List<Account> dataList : [
      SELECT Id,IsCustomerPortal,Name,ParentId,Phone,ShippingCity,ShippingPostalCode,ShippingState,ShippingStreet,Type,
             Average_Response_Time__c,Callsbacks_YTD__c,Disputed_Invoice_Count__c,Maintenance_Visits_YTD__c,New_Invoice_Count__c,Notification_Count__c,Paid_Invoice_Count__c,Testing_Completion_Rate__c,
        (SELECT Email,FirstName,Id,LastName,MailingCity,MailingPostalCode,MailingState,MailingStreet,MobilePhone,Name,Phone,Title FROM Contacts)
      FROM Account
      WHERE Type = 'Customer'
      ORDER BY Name ASC NULLS LAST]) {
      data.addAll(dataList);
    }
    return data;  
  }

  @ReadOnly    
  @RemoteAction
  public static List<Equipment__c> getAccountEquipment(String accountId) {
    List<Equipment__c> data = new List<Equipment__c>();
    for (List<Equipment__c> dataList : [ 
      SELECT Cat1_Count__c,Cat5_Count__c,Class__c,Controller_Type__c,Id,Inspection_Witness__c,Last_12_Month_Count__c,Last_30_Day_Count__c,Last_Cat1_Date__c,Last_Cat5_Date__c,Last_Cleandown_Date__c,Last_Index_Test_Date__c,Last_PM_Date__c,Last_Visit_Date__c,Last_Visit_Reason__c,Load_Lb__c,Name,Next_Cat1_Date__c,Next_Cat5_Date__c,Next_Cleandown_Date__c,Next_Index_Test_Date__c,Next_PM_Date__c,Opportunity__c,Remote_Monitoring__c,Speed__c,State_Certificate_Expiration_Date__c,State_Certificate_First_Issue_Date__c,State_Certificate_Issue_Date__c,State_Elevator_Subtype__c,State_Elevator_Type__c,State_ID__c,State_Location_City__c,State_Location_Description__c,State_Location_Street__c,State_Location_Zip__c,State_Owner_Name__c,State_Region__c,State_Serial_Number__c,State_Status__c,Stops__c,Type__c,Vendor_Equipment_No__c,Visit_Count__c 
      FROM Equipment__c
      WHERE Opportunity__r.AccountId = :accountId AND Vendor_Equipment_No__c != null ORDER BY Name
    ]) {
      data.addAll(dataList);
    }
    return data;  
  }

  @ReadOnly    
  @RemoteAction
  public static List<Schindler_Invoice_History__c> getAccountInvoices(String accountId) {
    List<Schindler_Invoice_History__c> data = new List<Schindler_Invoice_History__c>();
    for (List<Schindler_Invoice_History__c> dataList : [ 
      SELECT PdfFilename__c,Billing_Id__c,Bill_To__c,ContentVersionId__c,Contract__c,Description__c,Duns_Number__c,Expenses__c,Fax__c,Federal_Tax_Id__c,Field_Contact__c,Id,Invoice_Date__c,Invoice_Number__c,Invoice_Total__c,Labor__c,Local_Office__c,Notification__c,Order_No__c,Order_Type__c,Payer__c,Problems__c,Problem_Count__c,Remit_To__c,Sales_Contact__c,Service_Location__c,Sub_Total__c,Tax__c,Telephone__c 
      FROM Schindler_Invoice_History__c  WHERE Opportunity__r.AccountId = :accountId  ORDER BY Invoice_Date__c,Invoice_Number__c
    ]) {
      data.addAll(dataList);
    }
    return data;  
  }

  @ReadOnly    
  @RemoteAction
  public static List<Schindler_Maintenance_Activity__c> getAccountMaintenance(String accountId) {
    List<Schindler_Maintenance_Activity__c> data = new List<Schindler_Maintenance_Activity__c>();
    for (List<Schindler_Maintenance_Activity__c> dataList : [ 
      SELECT Arrival_DateTime__c,Caller__c,Call_Placed_DateTime__c,ContractNo__c,Departure_DateTime__c,Description__c,Dispatched_DateTime__c,Employee__c,EquipName__c,EquipNo__c,EquipStatus__c,Id,JobID__c,Location__c,Name,Opportunity__c,Resolution__c,Task_Completed__c,Type__c,VisitDate__c 
      FROM Schindler_Maintenance_Activity__c 
      WHERE Opportunity__r.AccountId = :accountId 
      ORDER BY EquipNo__c,VisitDate__c Desc Nulls Last      
    ]) {
      data.addAll(dataList);
    }
    return data;  
  }


}