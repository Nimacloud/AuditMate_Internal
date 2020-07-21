public without sharing class Notifications {

  @AuraEnabled
  public static Id[] getUpdates(Id accountId, String type) {
    List<id> idList = new List<Id>();
    List<Notification__c> notificationList = [
      SELECT Account__c,Account__r.Name,Date_First_Sent__c,Date_Last_Sent__c,Id,Max_Count__c,Send_Count__c,NotificationType__c ,User_Disabled__c,
      (SELECT Equipment__c,Equipment__r.Vendor_Equipment_No__c FROM NotificationItems__r)
      FROM Notification__c 
      WHERE Current__c = true AND NotificationType__c = :type AND Account__c = :accountId
      ORDER BY Account__r.Name, NotificationType__c, Date_Last_Sent__c Desc
    ];        
    if(notificationList.size() > 0) {
      for(Notification__c nfRec : notificationList) {
        for(NotificationItem__c itemRec : nfRec.NotificationItems__r) {
          idList.add(itemRec.Equipment__c);
        }
      }
    }
    return idList;
  }

  @AuraEnabled
  public static string requestUpdate(Id accountId, Id[] equipmentIds) {
    Map<String, NotificationItem__c> itemMap = new Map<String, NotificationItem__c>();
    List<NotificationItem__c> notificationItemInsertList = new List<NotificationItem__c>();
    Notification__c nfRec;
    Boolean noErrors=true;
    String equipNo,itemKey,itemEqNo,retVal='ok';
    Id notificationId;

    List<Notification__c> notificationUpdateList = new List<Notification__c>();
    List<Notification__c> notificationList = [
      SELECT Account__c,Account__r.Name,Date_First_Sent__c,Date_Last_Sent__c,Id,Max_Count__c,Send_Count__c,NotificationType__c ,User_Disabled__c,
      (SELECT Equipment__c,Equipment__r.Vendor_Equipment_No__c FROM NotificationItems__r)
      FROM Notification__c 
      WHERE Current__c = true AND NotificationType__c = 'Eq_Request' AND Account__c = :accountId
      ORDER BY Account__r.Name, NotificationType__c, Date_Last_Sent__c Desc
    ];    
    if(notificationList.size() > 0) {
      nfRec = notificationList[0];  // There is only 1 current NotificationType__c at any given time.
      for(NotificationItem__c itemRec : nfRec.NotificationItems__r) {
        itemEqNo = itemRec.Equipment__r.Vendor_Equipment_No__c;
        itemKey  = accountId + '-' + itemEqNo;
        itemMap.put(itemKey,itemRec);
      }
      System.debug('Do have a current notification for ' + accountId + ' [Eq_Request]');
      notificationId = nfRec.Id;
    } else {
      System.debug('Do NOT have a current notification for ' + accountId + ' [Eq_Request]');
      Notification__c newNotificationM = new Notification__c();
      newNotificationM.Account__c          = accountId;
      newNotificationM.NotificationType__c = 'Eq_Request';
      newNotificationM.Max_Count__c        = 1;
      newNotificationM.Send_Count__c       = 0;
      try {
        insert newNotificationM;
        notificationId = newNotificationM.Id;
      } catch (DmlException e) {
        retVal = 'Notification error';
        noErrors = false;
        System.debug(e);
      } 
    }

    if(noErrors) {
      List<Equipment__c> eqList = [
        SELECT Id,Opportunity__r.AccountId,Opportunity__r.Account.Name,Days_CAT1_Past_Due__c,Days_CAT5_Past_Due__c,Days_PM_Past_Due__c,Display_Name__c,Has_Monthly_Requirement__c,Last_12_Month_CB_Count__c,Last_12_Month_Count__c,Last_12_Month_PM_Count__c,Last_12_Month_PM_Percent__c,Last_30_Day_Count__c,Last_Cat1_Date__c,Last_Cat5_Date__c,Last_CB_Date__c,Last_PM_Date__c,Last_State_CAT5_Date__c,Last_Visit_Date__c,Opportunity__c,State_Certificate_Expiration_Date__c,State_Certificate_Issue_Date__c,State_ID__c,State_Status__c,Type__c ,Vendor_Equipment_No__c,Visit_Count__c 
        FROM Equipment__c 
        WHERE Id IN :equipmentIds
        ORDER BY Vendor_Equipment_No__c
      ]; 

      for(Equipment__c eqRec : eqList) {
        equipNo = eqRec.Vendor_Equipment_No__c;
        itemKey = accountId + '-' + equipNo;
        if(itemMap.containsKey(itemKey)) {
          System.debug(itemKey + ' Found in ItemMap');
        } else {
          System.debug(itemKey + ' NOT found in ItemMap');
          NotificationItem__c newItem = new NotificationItem__c();
          newItem.Equipment__c    = eqRec.Id;
          newItem.Notification__c = notificationId;
          notificationItemInsertList.add(newItem);
        }      
      }

      if(notificationItemInsertList.size() > 0) {
        try {
          insert notificationItemInsertList;
        } catch (DmlException e) {
          retVal = 'NotificationItem error';
          System.debug(e);
        }
      }
    }

    return retVal;
  }

  public static string equipmentNotifications() {
    // Populates Notification__c and NotificationItem__c for any Accounts with Equipment with 
    // Days_CAT1_Past_Due__c > 0 OR Days_CAT5_Past_Due__c > 0 OR Days_PM_Past_Due__c > 0

    Map<String, Notification__c> notificationMap = new Map<String, Notification__c>();
    Map<String, NotificationItem__c> itemMap = new Map<String, NotificationItem__c>();
    List<NotificationItem__c> notificationItemInsertList = new List<NotificationItem__c>();
    Set<Notification__c> notificationUpdateSet = new Set<Notification__c>();

    Integer sendCount,daysSince,daysSinceMod,weekCount;
    Integer daysCat1Late,daysCat5Late,daysPmLate;
    Date startDate;
    Date today = Date.today();
    Decimal weekCountD,sendCountD,daysCat1LateD,daysCat5LateD,daysPmLateD;
    String eqAccountId,eqAccountName,equipNo,displayName;
    String key,key1,key2,itemKey,accountId,name,type,itemEqNo;
    Notification__c childRec;
    Id notificationId;
    
    Boolean found;
    Notification__c nfRec;

    List<Notification__c> notificationList = [
      SELECT Account__c,Account__r.Name,Date_First_Sent__c,Date_Last_Sent__c,Id,Max_Count__c,Send_Count__c,NotificationType__c ,User_Disabled__c,
      (SELECT Equipment__c,Equipment__r.Vendor_Equipment_No__c FROM NotificationItems__r)
      FROM Notification__c 
      WHERE Current__c = true
      ORDER BY Account__r.Name, NotificationType__c, Date_Last_Sent__c Desc
    ];

    for(Notification__c nfRec1 : notificationList) {
      accountId = nfRec1.Account__c;
      type      = nfRec1.NotificationType__c;
      key =  accountId + '-' + type;
      System.debug('Key: ' + key);
      notificationMap.put(key,nfRec1);
      for(NotificationItem__c itemRec : nfRec1.NotificationItems__r) {
        itemEqNo = itemRec.Equipment__r.Vendor_Equipment_No__c;
        itemKey  = accountId + '-' + itemEqNo;
        itemMap.put(itemKey,itemRec);
      }
    }

    List<Equipment__c> eqList = [
      SELECT Id,Opportunity__r.AccountId,Opportunity__r.Account.Name,Days_CAT1_Past_Due__c,Days_CAT5_Past_Due__c,Days_PM_Past_Due__c,Display_Name__c,Has_Monthly_Requirement__c,Last_12_Month_CB_Count__c,Last_12_Month_Count__c,Last_12_Month_PM_Count__c,Last_12_Month_PM_Percent__c,Last_30_Day_Count__c,Last_Cat1_Date__c,Last_Cat5_Date__c,Last_CB_Date__c,Last_PM_Date__c,Last_State_CAT5_Date__c,Last_Visit_Date__c,Opportunity__c,State_Certificate_Expiration_Date__c,State_Certificate_Issue_Date__c,State_ID__c,State_Status__c,Type__c ,Vendor_Equipment_No__c,Visit_Count__c 
      FROM Equipment__c 
      WHERE Days_CAT1_Past_Due__c > 0 OR Days_CAT5_Past_Due__c > 0 OR Days_PM_Past_Due__c > 0
      ORDER BY Opportunity__r.AccountId,Vendor_Equipment_No__c
    ]; 

    Integer eqListLen = eqList.size();
    Integer i = 0;
    Equipment__c eqRec;
    while (i < eqListLen) {
      eqRec = eqList[i];
      equipNo        = eqRec.Vendor_Equipment_No__c;
      eqAccountId    = eqRec.Opportunity__r.AccountId;
      eqAccountName  = eqRec.Opportunity__r.Account.Name;
      found = false;
      key1   = eqAccountId + '-Eq_Past_Due';
      if(notificationMap.containsKey(key1)) {
        found = true;
        System.debug('Do have a current notification for ' + eqAccountName + ' [Eq_Past_Due]');
        nfRec = notificationMap.get(key1);
        notificationId = nfRec.Id;
      } else {
        System.debug('Do NOT have a current notification for ' + eqAccountName + ' [Eq_Past_Due]');
        Notification__c newNotificationM = new Notification__c();
        newNotificationM.Account__c          = eqAccountId;
        newNotificationM.NotificationType__c = 'Eq_Past_Due';
        newNotificationM.Max_Count__c        = 3;
        newNotificationM.Send_Count__c       = 0;
        newNotificationM.Date_First_Sent__c  = null;
        newNotificationM.Date_Last_Sent__c   = null;
        newNotificationM.User_Disabled__c    = false;
        try {
          insert newNotificationM;
          notificationId = newNotificationM.Id;
        } catch (DmlException e) {
          System.debug(e);
        }        
      }
      while (i < eqListLen && eqAccountId == eqList[i].Opportunity__r.AccountId) {
        eqRec   = eqList[i];
        equipNo = eqRec.Vendor_Equipment_No__c;
        itemKey = eqAccountId + '-' + equipNo;
        if(itemMap.containsKey(itemKey)) {
          System.debug(itemKey + ' Found in ItemMap');
        } else {
          System.debug(itemKey + ' NOT found in ItemMap');
          NotificationItem__c newItem = new NotificationItem__c();
          newItem.Equipment__c    = eqRec.Id;
          newItem.Notification__c = notificationId;
          notificationItemInsertList.add(newItem);
          if(found) {
            nfRec.Date_First_Sent__c = today; // Reset first send and send count.
            nfRec.Send_Count__c      = 0;
            notificationUpdateSet.add(nfRec);
          }
        }
        i++;
      }
    }
    System.debug('notificationItemInsertList:');
    System.debug(notificationItemInsertList);
    System.debug('notificationUpdateSet:');
    System.debug(notificationUpdateSet);
    try {
      insert notificationItemInsertList;
    } catch (DmlException e) {
      System.debug(e);
    }
    if(notificationUpdateSet.size() > 0) {
      List<Notification__c> notificationUpdateList = new List<Notification__c>(notificationUpdateSet);
      try {
        update notificationUpdateList;
      }
        catch (DmlException e) {
        System.debug(e);
      }
    }
    return 'ok';
  }

}