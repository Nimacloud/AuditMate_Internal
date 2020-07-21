public without sharing class notifications_eq_past_due_controller {
  // For VisualForce email template controller
  public ID itemId {get; set;}
  public ID masterId {get; set;}
  public String accountName {get; set;}
  public String emailRecipient {get; set;}
  public String emailRecipientFN {get; set;}
  
  public notifications_eq_past_due_controller() {
  }

  public string getMyRequest() {
    if(emailRecipient == null) {
      return 'this is default request';
    } else {
      return 'return link for portal customer ' + emailRecipient;
    }
  }

  public List<NotificationItem__c> Notifications {
    get {
      Boolean returnEmpty = false;
      List<NotificationItem__c> notificationList;
      System.debug('get Notifications');
      if(itemId == null) {
        System.debug('itemId is null, returning empty list');
        returnEmpty = true;
      } else {
        System.debug('itemId is not null, returning list');
        System.debug(itemId);
        List<NotificationItem__c> masterList = [SELECT Notification__c FROM  NotificationItem__c WHERE Id = :itemId];
        NotificationItem__c masterRec = masterList[0];
        System.debug(masterRec.Notification__c);
        this.masterId = masterRec.Notification__c;
        System.debug('this.masterId:');
        System.debug(this.masterId);
        notificationList = [
          SELECT Notification__r.Account__c, Notification__r.Account__r.Name, Notification__r.Date_First_Sent__c, Notification__r.Date_Last_Sent__c, 
            Notification__r.Send_Count__c, Notification__r.NotificationType__c, Notification__r.User_Disabled__c, Notification__r.Id, Notification__r.Max_Count__c,
            Equipment__r.Days_CAT1_Past_Due__c,Equipment__r.Days_CAT5_Past_Due__c,Equipment__r.Days_PM_Past_Due__c,Equipment__r.Display_Name__c,
            Equipment__r.Last_30_Day_Count__c,Equipment__r.Last_PM_Date__c,Equipment__r.Last_Visit_Date__c,Equipment__r.Vendor_Equipment_No__c,Equipment__r.Visit_Count__c       
          FROM NotificationItem__c
          WHERE Notification__r.Current__c = true And Notification__r.Id = :this.masterId 
          ORDER BY Equipment__r.Display_Name__c          
        ];
        if(notificationList.size() > 0) {
          this.accountName = notificationList[0].notification__r.Account__r.Name;
        } else {
          returnEmpty = true; 
        }    
      }
      if(returnEmpty) {
        notificationList = new List<NotificationItem__c>();
        notificationList.add( new NotificationItem__c() );
      }
      return notificationList;
    }
    set;
  }

}