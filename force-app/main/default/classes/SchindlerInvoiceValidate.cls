public with sharing class SchindlerInvoiceValidate {

  // SchindlerInvoiceValidate.validate() 
  // This probably should be called from after update trigger on Schindler_Invoice_History__c

// 1. get invoice data (Schindler_Invoice_History__c)
    public static List<Schindler_Invoice_History__c> getInvoiceData() {
      List<Schindler_Invoice_History__c> dataList;
      if(Test.isRunningTest()) {
        dataList = [
          SELECT Equipment__c,Opportunity__r.AccountId,Opportunity__r.Account.Name,Opportunity__r.Call_Back_Coverage__c,Opportunity__r.Coverage_end_time__c,Opportunity__r.Coverage_start_time__c,Opportunity__r.Reponse_Time_ST_Entrapment__c,Opportunity__r.Response_Time_OT_Entrapment__c,
            Opportunity__r.Response_Time_OT_In_Hours__c,Opportunity__r.Response_Time_ST_In_Hours__c,
            Audit_Comments__c,Billing_Id__c,Bill_To__c,JsonVersionId__c,PdfVersionId__c,Contract__c,Customer_Comments__c,DaysToPay__c,Description__c,Duns_Number__c,Expenses__c,Fax__c,Federal_Tax_Id__c,Field_Contact__c,Id,Internal_Comments__c,Invoice_Date__c,Invoice_Due_Date__c,Invoice_Number__c,Invoice_Total__c,Labor__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Local_Office__c,Name,Notification__c,Opportunity__c,Order_No__c,Order_Type__c,Payer__c,PdfFilename__c,Problems__c,Problem_Count__c,Remit_To__c,Sales_Contact__c,Service_Location__c,Sub_Total__c,SystemStatus__c,Tax__c,Telephone__c,UserStatus__c,
            verActualDuration__c,verActualResponseTime__c,verDuringNormalHoursDesc__c,verDuringNormalHours__c,VerNoPriorVisitsLast30days__c,verOvertimeApproved__c,verPriorVisitsLast30days__c,verResponseTime__c,verVisitDuration__c 
          FROM Schindler_Invoice_History__c 
          WHERE Notification__c != null 
        ];      
      } else {
        dataList = [
          SELECT Equipment__c,Opportunity__r.AccountId,Opportunity__r.Account.Name,Opportunity__r.Call_Back_Coverage__c,Opportunity__r.Coverage_end_time__c,Opportunity__r.Coverage_start_time__c,Opportunity__r.Reponse_Time_ST_Entrapment__c,Opportunity__r.Response_Time_OT_Entrapment__c,
            Opportunity__r.Response_Time_OT_In_Hours__c,Opportunity__r.Response_Time_ST_In_Hours__c,
            Audit_Comments__c,Billing_Id__c,Bill_To__c,JsonVersionId__c,PdfVersionId__c,Contract__c,Customer_Comments__c,DaysToPay__c,Description__c,Duns_Number__c,Expenses__c,Fax__c,Federal_Tax_Id__c,Field_Contact__c,Id,Internal_Comments__c,Invoice_Date__c,Invoice_Due_Date__c,Invoice_Number__c,Invoice_Total__c,Labor__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Local_Office__c,Name,Notification__c,Opportunity__c,Order_No__c,Order_Type__c,Payer__c,PdfFilename__c,Problems__c,Problem_Count__c,Remit_To__c,Sales_Contact__c,Service_Location__c,Sub_Total__c,SystemStatus__c,Tax__c,Telephone__c,UserStatus__c,
            verActualDuration__c,verActualResponseTime__c,verDuringNormalHoursDesc__c,verDuringNormalHours__c,VerNoPriorVisitsLast30days__c,verOvertimeApproved__c,verPriorVisitsLast30days__c,verResponseTime__c,verVisitDuration__c 
          FROM Schindler_Invoice_History__c 
        ];
      }
      //           WHERE Notification__c IN ('65863694','65836153')
      //  WHERE Invoice_Number__c = '7153022753'       
      // WHERE Notification__c IN ('65852176','FL20191105070100220116') 
      // JsonVersionId__c != null AND Notification__c  != null
      //  IN ('0683I000000Bo4jQAC', '0683I000000Bo4oQAC', '0683I000000Bo4eQAC', '0683I000000Bo4iQAC', '0683I000000Bo4dQAC', '0683I000000Bo4cQAC', '0683I000000Bo4nQAC', '0683I000000Bo4hQAC', '0683I000000Bo6eQAC', '0683I000000Bo6tQAC', '0683I000000Bo8pQAC', '0683I000000Bo6sQAC', '0683I000000Bnj9QAC', '0683I000000Bnj8QAC', '0683I000000Bo6rQAC', '0683I000000Bo8oQAC', '0683I000000Bo6dQAC', '0683I000000Bo8nQAC', '0683I000000Bo4mQAC')
      // System.debug('Invoices: ' + String.Join(dataList, ',') );
      return dataList;
    }

// 2. extract notifications from #1    
    private static List<String> extractNotificationList(List<Schindler_Invoice_History__c> dataList) {
      List<String> notificationArray = new List<String>();
      String notification;
      Long notificationLong;
      for(Schindler_Invoice_History__c rec : dataList) {
        notification = rec.Notification__c;
        if(!String.isBlank(notification)) {
          if(notification.startsWith('0')) {
            notificationLong = Long.valueOf(notification);
            notification = String.valueOf(notificationLong);
          }
          notificationArray.add(notification);
        }
      }
      // System.debug('notificationArray: ' + String.Join(notificationArray, ',') );
      // return String.Join(notificationArray, ',');
      return notificationArray;
    }

// 3. get time tickets from notifications
    public static Map<String,ServiceHistory__c> getTimeTicketsMap(List<String> notificationList) {
      Map<String,ServiceHistory__c> timeTicketMap = new Map<String,ServiceHistory__c>();
      List<ServiceHistory__c> dataList = [
        SELECT Building_NameAddress__c,Equipment_Name__c,Id,Name,Opportunity__c,Problem_reported__c,Reported_By__c,Service_Report_Date__c,Status__c,Technician_Arrival_DateTime__c,Technician_Departure_DateTime__c,Technician__c,Time_unit_returned_to_service__c,Type__c,Vendor_Building_ID__c,Vendor_Contract_Number__c,Vendor_Equipment__c,Vendor_Notification__c,Vendor_Sales_Order__c,Vendor_Work_Order__c,Work_description__c, 
         Doubletime_Onsite_time__c,Doubletime_Travel_time__c,Overtime_1_5_Onsite_Time__c,Overtime_1_5_Travel_Time__c,Overtime_1_7_Onsite_time__c,Overtime_1_7_Travel_time__c,Overtime_Onsite_time__c,Overtime_Travel_time__c,Standard_Onsite_time__c,Standard_Travel_time__c 
        FROM ServiceHistory__c 
        WHERE Vendor_Notification__c IN :notificationList
      ];
      for(ServiceHistory__c rec : dataList) {
        timeTicketMap.put(rec.Vendor_Notification__c,rec);
      }
      System.debug('Time Tickets: ' + String.Join(dataList, ',') );

      return timeTicketMap;
    }

// 4. get equipment from time tickets    
    public static Map<String,String> extractNotificationEquipmentMap(Map<String,ServiceHistory__c> timeTicketMap) {
      Map<String,String> notificationEquipmentMap  = new Map<String,String>();
      ServiceHistory__c timeTicket;
      String notification,vendorEqNo;
      for(String timeTicketKey : timeTicketMap.keySet() ) {
//      System.debug('Key: ' + timeTicketKey);
        timeTicket = timeTicketMap.get(timeTicketKey);
//      System.debug(timeTicket.Vendor_Notification__c);
        notification = timeTicket.Vendor_Notification__c;
        vendorEqNo   = timeTicket.Vendor_Equipment__c;
        if(!String.isBlank(vendorEqNo)) {
          vendorEqNo   = vendorEqNo.trim().toUpperCase();
          notification = notification.trim().toUpperCase();
          notificationEquipmentMap.put(notification,vendorEqNo);
        }
      }
      return notificationEquipmentMap;
    }

    public static Map<String,Equipment__c> getEquipmentMap(Map<String,String> notificationEquipmentMap) {
      Map<String,Equipment__c> equipmentMap = new Map<String,Equipment__c>();
      List<String> vendorEqNoArray = new List<String>();
      vendorEqNoArray.addAll(notificationEquipmentMap.values());
//    System.debug( vendorEqNo + ' ' + timeTicket.Display_Name__c + ' ' + timeTicket.Vendor_Notification__c + ' ' + visitCount);
//    System.debug(vendorEqNoArray);
      List<Equipment__c> dataList = [
        SELECT Id,Display_Name__c,Last_12_Month_Count__c,Last_30_Day_Count__c,Vendor_Equipment_No__c,Visit_Count__c,Has_Monthly_Requirement__c
        FROM Equipment__c
        WHERE Vendor_Equipment_No__c IN :vendorEqNoArray
      ];

      for(Equipment__c eqRec : dataList) {
        String vendorEqNo = eqRec.Vendor_Equipment_No__c;
        vendorEqNo = vendorEqNo.trim().toUpperCase();
        equipmentMap.put(vendorEqNo,eqRec);
      }
//    System.debug('getEquipmentMap - equipment: ' + String.Join(dataList, ',') );
      return equipmentMap;
    }

    // 5. Get ALL Schindler Maintenance Activities
    public static Map<String,Schindler_Maintenance_Activity__c> getMaintenanceMap(List<String> notificationList) {
      Map<String,Schindler_Maintenance_Activity__c> maintenanceMap = new Map<String,Schindler_Maintenance_Activity__c>();
      List<Schindler_Maintenance_Activity__c> data = new List<Schindler_Maintenance_Activity__c>();
      //         Arrival_DateTime__c,Caller__c,Call_Placed_DateTime__c,ContractNo__c,Departure_DateTime__c,Description__c,Dispatched_DateTime__c,Employee__c,EquipName__c,EquipNo__c,EquipStatus__c,Id,JobID__c,Location__c,Name,Opportunity__c,Opportunity__r.Name,Opportunity__r.Account.Name,Resolution__c,Type__c,VisitDate__c 
      for (List<Schindler_Maintenance_Activity__c> dataList : [
        SELECT Arrival_DateTime__c,Caller__c,Call_Placed_DateTime__c,ContractNo__c,Departure_DateTime__c,Description__c,Dispatched_DateTime__c,Employee__c,EquipName__c,EquipNo__c,EquipStatus__c,Id,JobID__c,Location__c,Name,Opportunity__c,Resolution__c,Type__c,VisitDate__c 
        FROM Schindler_Maintenance_Activity__c 
        ORDER BY JobID__c
      ]) {
        for(Schindler_Maintenance_Activity__c rec : dataList) {
          maintenanceMap.put(rec.JobID__c,rec);
        }
      }      
      System.debug('________________Map Check_________________________');
      System.debug( maintenanceMap.get('65863694') );
      System.debug( maintenanceMap.get('65836153') );
      System.debug('________________Map Check_________________________');
/*
      List<Schindler_Maintenance_Activity__c> dataList = [
        SELECT Arrival_DateTime__c,Caller__c,Call_Placed_DateTime__c,ContractNo__c,Departure_DateTime__c,Description__c,Dispatched_DateTime__c,Employee__c,EquipName__c,EquipNo__c,EquipStatus__c,Id,JobID__c,Location__c,Name,Opportunity__c,Resolution__c,Type__c,VisitDate__c 
        FROM Schindler_Maintenance_Activity__c 
      ];
      for(Schindler_Maintenance_Activity__c rec : dataList) {
        maintenanceMap.put(rec.JobID__c,rec);
      }
*/
//    System.debug('Maintenance Activity: ' + String.Join(dataList, ',') );
      return maintenanceMap;
    }

    public static String validate() {
      // 1. get invoice list (Schindler_Invoice_History__c)
      // 2. extract notifications from #1
      // 3. get time tickets from notifications (getTimeTicketsMap)
      // 4. extract equipmentNos from time tickets
      // 5. get equipment from equipmentNos
      // 6. iterate over invoice list
      // 7. populate ver fields
      List<Schindler_Invoice_History__c> updateList  = new List<Schindler_Invoice_History__c>();
      List<Schindler_Invoice_History__c> invoiceList = getInvoiceData();
      List<String> notificationList                  = extractNotificationList(invoiceList);
      Map<String,ServiceHistory__c> timeTicketMap    = getTimeTicketsMap(notificationList);
      Map<String,String> notificationEquipmentMap    = extractNotificationEquipmentMap(timeTicketMap);
      Map<String,Equipment__c> equipmentMap          = getEquipmentMap(notificationEquipmentMap);
      Map<String,Schindler_Maintenance_Activity__c>  maintenanceMap = getMaintenanceMap(notificationList);
      Equipment__c eqRec;
      ServiceHistory__c timeTicketRec;
      Schindler_Maintenance_Activity__c maintenanceRec, pastMaintenanceRec;
      String notification,accountName,contract;

      DateDifference.diffWrapper durationWrapper;
      DateDifference.diffWrapper responseWrapper;

      Boolean invoiceIsForCallBackVisit = false;
      Boolean haveResponseData          = false;
      Boolean haveDurationData          = false;
      Boolean haveMaintenanceArrival    = false;
      Boolean haveTimeTicketArrival     = false;
      Boolean verConditionMet           = false;

      Date today         = Date.today();
      Date todayMinus30  = today.addDays(-30);
      Date visitDate,serviceReportDate,reportDateMinus30;
      Decimal targetResponseMinutes;
      Decimal responseMinutes, durationMinutes;
      Long notificationLong;
      Integer loopCnt = 0;
      String currentKey = '',vendorEqNo,equipNo,last30DayDates,invDesc,verNoPriorVisitsLast30days;
      List<String> last30DayVisitArray = new List<String>();
      List<String> debugArray          = new List<String>();

      for(Schindler_Invoice_History__c invoice : invoiceList) {
        last30DayVisitArray.clear();
        verConditionMet = false;
        loopCnt++;
        //accountName    = invoice.Account__r.Name;
        accountName    = invoice.Opportunity__r.Account.Name;
        currentKey     = '[AccountName: ' + accountName + ']';
        notification   = invoice.Notification__c;
        contract       = invoice.Contract__c;
        eqRec          = null;
        timeTicketRec  = null;
        maintenanceRec = null;
        
        verNoPriorVisitsLast30days = 'U';
        invoice.verActualDuration__c          = 'U';
        invoice.verActualResponseTime__c      = 'U';
        invoice.verDuringNormalHoursDesc__c   = 'U';
        invoice.verDuringNormalHours__c       = 'U';
//      invoice.VerNoPriorVisitsLast30days__c = 'U';
        invoice.verOvertimeApproved__c        = 'U';
        invoice.verPriorVisitsLast30days__c   = 'U';
        invoice.verResponseTime__c            = 'U';
        invoice.verVisitDuration__c           = 'U';

        System.debug('---- ' + loopCnt.format() + ' ----');
        System.debug('Account: ' + accountName);
//      System.debug('Contract'  + contract);


        if(!String.isBlank(invoice.Invoice_Number__c)) {
          currentKey += '[InvoiceNo: ' + invoice.Invoice_Number__c + ']';
        } else {
          currentKey += '[InvoiceNo: n/a]';
        }

        if(!String.isBlank(invoice.PdfFilename__c)) {
          System.debug('Pdf: ' + invoice.PdfFilename__c);
        }

        if(!String.isBlank(notification)) {
          if(notification.startsWith('0')) {
            notificationLong = Long.valueOf(notification);
            notification = String.valueOf(notificationLong);
          }
          currentKey += '[Notification: ' + notification + ']';
          System.debug('Notification: ' + notification);

          if(notificationEquipmentMap.containsKey(notification)) {
  //        System.debug('found ' + notification + ' in notificationEquipmentMap');
            equipNo = notificationEquipmentMap.get(notification);
            if(equipmentMap.containsKey(equipNo)) {
//            System.debug('found ' + equipNo + ' in equipmentMap');
              eqRec = equipmentMap.get(equipNo);
//            System.debug('**** eqRec:');
//            System.debug(eqRec);
            } else {
//            System.debug('Did not find ' + equipNo + ' in equipmentMap');
            }
          } else {
//          System.debug('Did not find ' + notification + ' in notificationEquipmentMap');
          }

          if(timeTicketMap.containsKey(notification)) {
            timeTicketRec = timeTicketMap.get(notification);
          } else {
  //        System.debug('Don\'t have a time ticket for ' + notification);  
            invoice.SystemStatus__c = 'Needs_Review';
            debugArray.add( currentKey + ' Invoice does not have a related time ticket record.');
          }

          if(maintenanceMap.containsKey(notification)) {
            maintenanceRec = maintenanceMap.get(notification);
            if(eqRec == null && maintenanceRec.EquipNo__c != null) {
              equipNo = maintenanceRec.EquipNo__c;
              if(equipmentMap.containsKey(equipNo)) {
                System.debug('found ' + equipNo + ' in maintenanceMap');
                eqRec = equipmentMap.get(equipNo);
                System.debug('**** eqRec:');
                System.debug(eqRec);
              } else {
                System.debug('Did not find ' + equipNo + ' in maintenanceMap');
              }              
            }
          } else {
            System.debug('Don\'t have a maintenance record for ' + notification);
          }

        } else {
          currentKey += '[Notification: n/a]';
          System.debug('Invoice does not have a notification number to lookup a time ticket.');
          debugArray.add( currentKey + ' Invoice does not have a notification number to lookup a time ticket.');
        }

        if(eqRec != null) {
          if(invoice.Equipment__c == null) {
            invoice.Equipment__c = eqRec.Id;  // Invoice doesn't have this set when it is created, as there is no guarantee the time ticket or maintenance record have been imported at that time.
          }

          System.debug('****** VISIT DATES ******');
          
          if(timeTicketRec != null) {
            if(timeTicketRec.Service_Report_Date__c != null) {
               serviceReportDate = timeTicketRec.Service_Report_Date__c;
               reportDateMinus30 = serviceReportDate.addDays(-30);
              for(String maintenanceKey : maintenanceMap.keySet() ) {
                pastMaintenanceRec = maintenanceMap.get(maintenanceKey);
                equipNo   = pastMaintenanceRec.EquipNo__c;
                visitDate = pastMaintenanceRec.VisitDate__c;
                if(!String.isBlank(equipNo)) {
                  if(visitDate != null && equipNo == eqRec.Vendor_Equipment_No__c) {
                    if(visitDate >= reportDateMinus30 && visitDate < serviceReportDate) {
                      System.debug('Is ' + visitDate.format() + ' between ' + reportDateMinus30.format() + ' and ' + serviceReportDate.format() );
                      System.debug('Is ' + equipNo + ' = ' + eqRec.Vendor_Equipment_No__c );
                      last30DayVisitArray.add(visitDate.format());
                    }
                  }
                }
              }
            }
          }
          System.debug('****** VISIT size DATES ******\n');
          System.debug(last30DayVisitArray.size());
          System.debug('****** VISIT DATES ******\n');
          if(last30DayVisitArray.size() > 0) {
            last30DayDates = String.join(last30DayVisitArray,', ');
            invoice.verPriorVisitsLast30days__c   = last30DayDates;
            verNoPriorVisitsLast30days = 'N';
//          invoice.VerNoPriorVisitsLast30days__c = 'N';
            System.debug(invoice.verPriorVisitsLast30days__c);
          } else {
            verNoPriorVisitsLast30days = 'Y';
//          invoice.VerNoPriorVisitsLast30days__c = 'Y';
            invoice.verPriorVisitsLast30days__c = eqRec.Vendor_Equipment_No__c + ' has not received any prior visits within last 30 days.';
          }
          
          ///System.debug('Display_Name__c,Last_12_Month_Count__c,Last_30_Day_Count__c,Vendor_Equipment_No__c,Visit_Count__c,Has_Monthly_Requirement__c');
          System.debug('*** Equipment rec ***');
          System.debug('Vendor_Equipment_No__c: '     + eqRec.Vendor_Equipment_No__c);
          System.debug('Display_Name__c: '            + eqRec.Display_Name__c);
          System.debug('Has_Monthly_Requirement__c: ' + eqRec.Has_Monthly_Requirement__c);
          System.debug('Last_12_Month_Count__c: '     + eqRec.Last_12_Month_Count__c.format());
          System.debug('Last_30_Day_Count__c: '       + eqRec.Last_30_Day_Count__c.format() );
          System.debug('Visit_Count__c: '             + eqRec.Visit_Count__c.format());
          verConditionMet = true;
          
        } //else {
//        invoice.VerNoPriorVisitsLast30days__c = 'U';
//          verNoPriorVisitsLast30days = 'U';
//        }

        // Building_NameAddress__c,Equipment_Name__c,Id,Name,Opportunity__c,Problem_reported__c,Reported_By__c,Service_Report_Date__c,Status__c,Technician_Arrival_DateTime__c,Technician_Departure_DateTime__c,Technician__c,Time_unit_returned_to_service__c,Type__c,Vendor_Building_ID__c,Vendor_Contract_Number__c,Vendor_Equipment__c,Vendor_Notification__c,Vendor_Sales_Order__c,Vendor_Work_Order__c,Work_description__c         
        // Doubletime_Onsite_time__c,Doubletime_Travel_time__c,Overtime_1_5_Onsite_Time__c,Overtime_1_5_Travel_Time__c,Overtime_1_7_Onsite_time__c,Overtime_1_7_Travel_time__c,Overtime_Onsite_time__c,Overtime_Travel_time__c,Standard_Onsite_time__c,Standard_Travel_time__c 
        if(timeTicketRec != null) {
          if(timeTicketRec.Type__c == 'CallBack') {
            invoiceIsForCallBackVisit = true;
            System.debug('*********************************************');
            System.debug('***    Time Ticket rec - Call Back        ***');
            System.debug('*********************************************');
            System.debug('\n');
            System.debug('Type__c: '  + timeTicketRec.Type__c);
            System.debug('Vendor_Notification__c: ' + timeTicketRec.Vendor_Notification__c);
            System.debug('Technician__c: ' + timeTicketRec.Technician__c);
            System.debug('Technician_Arrival_DateTime__c: ');
            System.debug(timeTicketRec.Technician_Arrival_DateTime__c);
            System.debug('Technician_Departure_DateTime__c: ');

            System.debug('*************** Work_description__c: ' + timeTicketRec.Work_description__c);


//          System.debug(timeTicketRec.Technician_Departure_DateTime__c);
            Datetime arrival   = timeTicketRec.Technician_Arrival_DateTime__c;
            Datetime departure = timeTicketRec.Technician_Departure_DateTime__c;
            if(arrival != null && departure != null) {
              durationWrapper = DateDifference.getDifference(arrival,departure);
              haveDurationData = true;
            System.debug('------------- durationWrapper ---------------');
            System.debug(durationWrapper);
            }

            if(timeTicketRec.Technician_Arrival_DateTime__c != null) {
              haveTimeTicketArrival = true;
              if(invoice.Opportunity__r.Coverage_start_time__c != null && invoice.Opportunity__r.Coverage_end_time__c != null) {
                Time coverageStartTime = invoice.Opportunity__r.Coverage_start_time__c;
                Time coverageEndTime   = invoice.Opportunity__r.Coverage_end_time__c;
 //             Datetime coverageStartDatetime = DateTime.newInstance(today,coverageStartTime);
 //             Datetime coverageEndDatetime   = DateTime.newInstance(today,coverageEndTime);
                Datetime technicianArrivalDateTime = timeTicketRec.Technician_Arrival_DateTime__c;
                System.debug(technicianArrivalDateTime);
                System.debug('coverageStartTime:');
                System.debug(coverageStartTime);
                System.debug('coverageEndTime:');
                System.debug(coverageEndTime);
//                System.debug('coverageStartDatetime -- coverageEndDatetime -- technicianArrivalDateTime');
//                System.debug(coverageStartDatetime);
//                System.debug(coverageEndDatetime);
//                System.debug('technicianArrivalDateTime 1');
//                System.debug(technicianArrivalDateTime);
//                System.debug('technicianArrivalDateTime 2');
//                System.debug(technicianArrivalDateTime.format());
                Integer technicianArrivalHour = technicianArrivalDateTime.hour();
                Integer technicianArrivalMin  = technicianArrivalDateTime.minute();
//              System.debug('technicianArrivalTime (from technicianArrivalDateTime.hour and technicianArrivalDateTime.minute');
                Time technicianArrivalTime = Time.newInstance( technicianArrivalHour, technicianArrivalMin, 0, 0);
                System.debug(technicianArrivalTime);
                System.debug('technicianArrivalHour: ' + technicianArrivalHour.format());
                System.debug('technicianArrivalMin: ' + technicianArrivalMin.format());

                if(technicianArrivalTime >= coverageStartTime  && technicianArrivalTime <= coverageEndTime) {
                  invoice.verDuringNormalHours__c = 'Y';
                  //invoice.verDuringNormalHoursDesc__c = 'Technician arrival time of ' + technicianArrivalTime + ' is within ' + coverageStartTime + ' - ' + coverageEndTime + ' range.';
                  invoice.verDuringNormalHoursDesc__c = 'Technician arrival time is within range.';
                  debugArray.add(currentKey + ' + invoice.verDuringNormalHours__c set true from timeTicketRec');
                } else {
                  invoice.verDuringNormalHours__c = 'N';
                  debugArray.add(currentKey + ' + invoice.verDuringNormalHours__c set false from timeTicketRec');
                }
                verConditionMet = true;

                if(invoice.verDuringNormalHours__c == 'N') {
                  if(!String.isBlank(invoice.Description__c)) {
                    invDesc = invoice.Description__c;
                    if(!String.isBlank(invDesc)) {
                      if(invDesc.contains('AUTHORIZED OVERTIME')) {
                        invoice.verOvertimeApproved__c = 'Y';
                      } else {
                        invoice.verOvertimeApproved__c = 'N';
                      }
                    }
                  }
                }

              } else {
                invoice.verDuringNormalHours__c = 'U';
                debugArray.add(currentKey  + ' + invoice.verDuringNormalHours__c set false from timeTicketRec');
              }
            } else {
              haveMaintenanceArrival = false;
              invoice.verDuringNormalHours__c = 'U';
              debugArray.add( currentKey + ' timeTicketRec does not have a Technician_Arrival_DateTime__c value.');
            }

          }
          if(timeTicketRec.Type__c == 'Maintenance') {
            System.debug('*********************************************');
            System.debug('*** Time Ticket rec - Maintenance         ***');
            System.debug(timeTicketRec);
            System.debug('*** not sure if I should be checking this ***');
            System.debug('*********************************************');
            System.debug('\n');
          }
        }
        
        if(maintenanceRec == null) {
          System.debug('______________ MAINT IS NULL _______________');
        } else {
          System.debug('______________ MAINT IS NOT  NULL _______________');
          System.debug(maintenanceRec.Type__c);
          System.debug('______________ MAINT IS NOT  NULL _______________');
        }

        if(maintenanceRec != null) {
          if(maintenanceRec.Type__c == 'CB') {
            invoiceIsForCallBackVisit = true;
            System.debug('*********************************************');
            System.debug('***    Maintenance rec - CB Type          ***');
            System.debug('*********************************************');
            System.debug('\n');
            System.debug('Arrival_DateTime__c');
            System.debug(maintenanceRec.Arrival_DateTime__c);
            System.debug('Caller__c: ' + maintenanceRec.Caller__c);
            System.debug('Call_Placed_DateTime__c');
            System.debug(maintenanceRec.Call_Placed_DateTime__c);
            System.debug('ContractNo__c: ' + maintenanceRec.ContractNo__c);
            System.debug('Departure_DateTime__c');
            System.debug(maintenanceRec.Departure_DateTime__c);
            System.debug('Description__c');
            System.debug(maintenanceRec.Description__c);
            System.debug('Dispatched_DateTime__c');
            System.debug(maintenanceRec.Dispatched_DateTime__c);
            System.debug('Employee__c: '   + maintenanceRec.Employee__c);
            System.debug('EquipName__c:'   + maintenanceRec.EquipName__c);
            System.debug('EquipNo__c: '    + maintenanceRec.EquipNo__c);
            System.debug('EquipStatus__c:' + maintenanceRec.EquipStatus__c);
            System.debug('Id: '            + maintenanceRec.Id);
            System.debug('JobID__c'        + maintenanceRec.JobID__c);
            System.debug('Location__c: '   + maintenanceRec.Location__c);          
            System.debug('Type__c: '       + maintenanceRec.Type__c);
            System.debug('VisitDate__c:');
            System.debug(maintenanceRec.VisitDate__c);

/*             if(maintenanceRec.Arrival_DateTime__c != null) {
              haveMaintenanceArrival = true;
              if(invoice.Opportunity__r.Coverage_start_time__c != null && invoice.Opportunity__r.Coverage_end_time__c != null) {
                if(maintenanceRec.Arrival_DateTime__c >= invoice.Opportunity__r.Coverage_start_time__c && 
                   maintenanceRec.Arrival_DateTime__c <= invoice.Opportunity__r.Coverage_end_time__c)  {
                  invoice.verDuringNormalHours__c = true;
                  debugArray.add(currentKey + ' + invoice.verDuringNormalHours__c set true from maintenanceRec');
                } else {
                  invoice.verDuringNormalHours__c = false;
                  debugArray.add(currentKey + ' + invoice.verDuringNormalHours__c set false from maintenanceRec');
                }
              } else {
                debugArray.add(currentKey + ' + invoice.verDuringNormalHours__c set false from maintenanceRec');
              }
            } else {
              haveMaintenanceArrival = false;
              debugArray.add( currentKey + ' maintenanceRec does not have an Arrival_DateTime__c value.');
            } */

            if(maintenanceRec.Call_Placed_DateTime__c != null && maintenanceRec.Arrival_DateTime__c != null) {
              Datetime callPlaced = maintenanceRec.Call_Placed_DateTime__c;
              Datetime arrival    = maintenanceRec.Arrival_DateTime__c; 
              responseWrapper = DateDifference.getDifference(callPlaced,arrival);
              debugArray.add(currentKey + ' + responseWrapper available to set Response time set from maintenanceRec');
              System.debug('-------------- responseWrapper -----------------');
              haveResponseData = true;
              System.debug(responseWrapper);
            } else {
              debugArray.add(currentKey + ' - Call placed datetime and/or arrival datetime unknown.  Cannot determine response time.');
            }

          }
          if(maintenanceRec.Type__c != 'CB') {
            System.debug('*********************************************');
            System.debug('*** Maintenance rec - Non-CB Type         ***');
            System.debug(maintenanceRec);
            System.debug('*** not sure if I should be checking this ***');
            System.debug('*********************************************');
            System.debug('\n');
          }          
        }

        if(invoiceIsForCallBackVisit) {

          if(haveMaintenanceArrival && haveTimeTicketArrival) {
            debugArray.add(currentKey + ' * Note: haveMaintenanceArrival && haveTimeTicketArrival');
          }

          if(haveDurationData) {
            durationMinutes = durationWrapper.Days * 60 * 60 + durationWrapper.Hours * 60 + durationWrapper.Minutes;
            if(durationMinutes < 120 ) {
              invoice.verVisitDuration__c = 'Y';
            } else {
              invoice.verVisitDuration__c = 'N';
            }
            invoice.verActualDuration__c = 'D:' + durationWrapper.Days + ' H:' + durationWrapper.Hours + ' M:' + durationWrapper.Minutes + ' S:' + durationWrapper.Seconds;
            debugArray.add(currentKey + ' verActualDuration__c set');
            verConditionMet = true;
//          system.debug('__ invoice.verActualDuration__c __');
//          system.debug(invoice.verActualDuration__c);
          } else {
//          system.debug('__ DO NOT HAVE: invoice.verActualDuration__c __');
            debugArray.add(currentKey + ' verActualDuration__c NOT set');
          }

          targetResponseMinutes = 0;
          if(haveResponseData) {
            if(invoice.verDuringNormalHours__c == 'Y') {
              if(invoice.Opportunity__r.Response_Time_ST_In_Hours__c != null) {
//              system.debug('invoice.verDuringNormalHours__c is Y');
//              system.debug('Does actual response time fall within timeframe of Response_Time_ST_In_Hours__c?');
//              system.debug(invoice.Opportunity__r.Response_Time_ST_In_Hours__c);
                targetResponseMinutes = invoice.Opportunity__r.Response_Time_ST_In_Hours__c * 60;
              } 
            } else {
              if(invoice.Opportunity__r.Response_Time_OT_In_Hours__c != null) {
//              system.debug('invoice.verDuringNormalHours__c is N');
//              system.debug('Does actual response time fall within timeframe of Response_Time_OT_In_Hours__c?');
//              system.debug(invoice.Opportunity__r.Response_Time_OT_In_Hours__c);
                targetResponseMinutes = invoice.Opportunity__r.Response_Time_OT_In_Hours__c * 60;
              }
            }
            if(targetResponseMinutes == 0) {
              debugArray.add(currentKey + 'verActualResponseTime__c NOT set, do not have target time');
            } else {
              responseMinutes = responseWrapper.Days * 60 * 60 + responseWrapper.Hours * 60 + responseWrapper.Minutes;
              if(responseMinutes <= targetResponseMinutes) {
                invoice.verResponseTime__c = 'Y'; 
  //            system.debug('Yes, response time good');
              } else {
                invoice.verResponseTime__c = 'N';
              }
              verConditionMet = true;
              invoice.verActualResponseTime__c = 'D:' + responseWrapper.Days + ' H:' + responseWrapper.Hours + ' M:' + responseWrapper.Minutes + ' S:' + responseWrapper.Seconds;
              debugArray.add(currentKey + ' verActualResponseTime__c set');
//            system.debug('__ invoice.verActualResponseTime__c __');
//            system.debug(invoice.verActualResponseTime__c);
            }
          } else {
            system.debug('__ DO NOT HAVE: invoice.verActualResponseTime__c __');
            debugArray.add(currentKey + ' verActualResponseTime__c NOT set');
          }
        }

//        if(verConditionMet) {
          updateList.add(invoice);
//        }
  
         // verDuringNormalHoursDesc__c,verDuringNormalHours__c
        // verVisitDuration__c
        // verOvertimeApproved__c

        // Status Update
        // invoice.verVisitDuration__c

        /*  Possible status:
              Verified_As_Valid
              Verified_As_Invalid
              Needs_Review
              Data_Error - OCR could not read pdf
              Unverified
        */

        // Note: Needs_Review is set earlier if no time ticket found.
        //             invoice.VerNoPriorVisitsLast30days__c == 'U' &&
        if(invoice.SystemStatus__c != 'Needs_Review') {
          if(
            invoice.verDuringNormalHours__c       == 'U' &&
            verNoPriorVisitsLast30days            == 'U' &&
            invoice.verOvertimeApproved__c        == 'U' &&
            invoice.verResponseTime__c            == 'U' &&
            invoice.verVisitDuration__c           == 'U') {
            invoice.SystemStatus__c = 'Unverified';
          } else {
            if( (invoice.verDuringNormalHours__c       == 'Y' && 
                 invoice.verVisitDuration__c           == 'Y' && 
                 verNoPriorVisitsLast30days            == 'U' &&
                 invoice.verResponseTime__c            == 'Y' 
                ) || (
                 invoice.verDuringNormalHours__c       == 'N' && invoice.verOvertimeApproved__c == 'Y' &&
                 invoice.verVisitDuration__c           == 'Y' && 
                 verNoPriorVisitsLast30days            == 'U' &&
                 invoice.verResponseTime__c            == 'Y'
                )) {
              invoice.SystemStatus__c = 'Verified_As_Valid';
            } else {
              invoice.SystemStatus__c = 'Verified_As_Invalid';
            }
          }
        } 
      }

      if(debugArray.size() > 0) {
        System.debug('<< debugArray >>');
        for(Integer i=0;i<debugArray.size();i++) {
          System.debug(i + ' - ' + debugArray[i]);
        }
      } else {
        System.debug('debugArray is empty?');
      }

      System.debug(updateList);

      String retVal = 'ok';
      Integer updateSize = updateList.size();
      System.debug('Update count: ' + updateSize.format());
      if(updateSize > 0) {
        Database.SaveResult[] srList = Database.update(updateList, false);
        for (Database.SaveResult sr : srList) {
          if (!sr.isSuccess()) {
            retVal = 'Errors - check log';
            for(Database.Error err : sr.getErrors()) {
              System.debug(err.getStatusCode() + ': ' + err.getMessage());
            }
          }
        }
      }
      return retVal;
    }
}