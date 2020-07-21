public without sharing class SchindlerOcrProcess {

  public static List<SchindlerOcrStaging__c> getStagedData(String contentVersionId) {
    
    List<SchindlerOcrStaging__c> data = new List<SchindlerOcrStaging__c>();
    Integer i,listLength;
    Decimal pn,xl,yt;
    for (List<SchindlerOcrStaging__c> dataList : [SELECT ContentVersionId__c,PageNumber__c,LineText__c,WordText__c,XLeft__c,YTop__c,YTopModified__c FROM SchindlerOcrStaging__c  WHERE ContentVersionId__c = :contentVersionId ORDER BY ContentVersionId__c,PageNumber__c,YTopModified__c,XLeft__c]) {
      listLength = dataList.size();
      data.addAll(dataList);
    }
    return data;
  }

  private Static String getPdfFilename(String contentVersionId ) {
    String jsonTitle,pdfTitle;
    ContentVersion jsonCvRec = [SELECT Title FROM ContentVersion WHERE Id = :contentVersionId];
    jsonTitle = jsonCvRec.Title.toLowerCase();
    pdfTitle  = jsonTitle.replace('.json','.pdf');
    return pdfTitle;
  }

  private Static Decimal cleanDec(String numToConvert) {
    Decimal retVal;
    String noDollarNoComma = '', cleanNum = '';
    noDollarNoComma = numToConvert.removeStart('$').replaceAll(',','');
    cleanNum        = noDollarNoComma.replaceAll(' ','');
    retVal         = Decimal.valueOf(cleanNum);
    return retVal;
  }

  private Static Boolean isInvoiceNumber(String num) {
    // Invoice # can be all digits or digits with an 'R' on the end.
    Boolean isValid = false;
    if(isOnlyDigits(num)) {
      System.debug( num + ' is only digits');
      isValid = true;
    } else {
      if(num.endsWithIgnoreCase('r')) {
        System.debug( num + ' end with R');
        Integer rPos = num.toLowerCase().indexOf('r');
        String lNum  = num.substring(0,rPos-1);
        System.debug( 'lnum: ' + lnum);
        if(isOnlyDigits(lNum)) {
          System.debug( lNum + ' is only digits');
          isValid = true;
        }
      }
    }
    return isValid;
  }

  private Static Boolean isOnlyDigits(String num) {
    Boolean isValid = true;
    String noSpaceNum = num.replaceAll(' ','');
    String digitRegex = '^[0-9]+$';
    Pattern p = Pattern.compile(digitRegex);
    Matcher m = p.matcher(noSpaceNum);
    isValid = m.matches();
    System.debug(isValid);
    return isValid;
  }

  private Static Boolean isNumber(String num) {
    Boolean isValid = true;
    String noSpaceNum = num.replaceAll(' ','');
    String digitRegex = '^[.0-9]+$';
    Pattern p = Pattern.compile(digitRegex);
    Matcher m = p.matcher(noSpaceNum);
    isValid = m.matches();
    if(isValid) {
      try {
        Decimal testDec = Decimal.valueOf(noSpaceNum);
      } catch(system.TypeException te) {
        isValid = false; // This will catch e.g. 123.45.6, 345..45.56 etc.
      }
    }
    return isValid;
  }

  private Static Date convertToDate(String stringToConvert) {
    String[] testArray = stringToConvert.split('/');
    String months,days,years;
    Integer monthsInt=0,daysInt=0,yearsInt=0;
    Date retVal;
    if(testArray.size() == 3) {
      months    = testArray[0];
      days      = testArray[1];
      years     = testArray[2];
      monthsInt = Integer.valueOf(months);
      daysInt   = Integer.valueOf(days);
      yearsInt  = Integer.valueOf(years);
      retVal = Date.newinstance(yearsInt, monthsInt, daysInt);
    }
    return retVal;
  }

  private Static Boolean isDate(String stringToTest) {
    Boolean isValid = false;
    String months,days,years;
    Integer monthsInt=0,daysInt=0,yearsInt=0;
    if(stringToTest.indexOf('/') == 2) {
      String[] testArray = stringToTest.split('/');
      if(testArray.size() == 3) {
        months = testArray[0];
        days   = testArray[1];
        years  = testArray[2];
        if(isOnlyDigits(months)) {
          monthsInt = Integer.valueOf(months);
        }
        if(isOnlyDigits(days)) {
          daysInt = Integer.valueOf(days);
        }
        if(isOnlyDigits(years)) {
          yearsInt = Integer.valueOf(years);
        }       
        if(monthsInt > 0 && daysInt > 0 && yearsInt > 0) {
          try {
            Date testDate = Date.newinstance(yearsInt, monthsInt, daysInt);
            isValid =  true;
          } catch(system.TypeException te) {
            // System.debug('isValid is false');
          }
        }
      } 
    } 
    if(isValid) {
      System.debug(stringToTest + ' is a date.');
    } else {
      System.debug(stringToTest + ' is not a date.');
    }
    return isValid;
  }
/*
  private static List<Equipment__c> getAccountEquipment(String acctId) {
    List<Equipment__c> data = new List<Equipment__c>();
    Integer listLength; //	0013k00002fZbqCAAS
    for (List<Equipment__c> dataList : [ 
      SELECT Id,Name,Opportunity__c,Cat1_Count__c,Cat5_Count__c,Last_30_Day_Count__c,Last_12_Month_Count__c,Last_Cat1_Date__c,Last_Cat5_Date__c,Last_Visit_Date__c,Last_Visit_Reason__c,Next_Cat1_Date__c,Next_Cat5_Date__c,Vendor_Equipment_No__c,Visit_Count__c 
      FROM Equipment__c WHERE Opportunity__r.AccountId = :acctId AND Vendor_Equipment_No__c != null ORDER BY Vendor_Equipment_No__c
    ]) {
      listLength = dataList.size();
      data.addAll(dataList);
      System.debug(listLength);
    }
    System.debug(data.size());
    return data;  
  }
  
  private static Map<String,String> getContractNumbers(String acctId) {
    List<Opportunity> data = [
      SELECT Vendor_Contract_Number__c,Id 
      FROM Opportunity 
      WHERE AccountId = :acctId
    ];
    Map<String,String> contractMap = new Map<String,String>();
    for(Opportunity rec : data) {
        System.debug(rec);
      if(!contractMap.containsKey(rec.Vendor_Contract_Number__c)) {
        contractMap.put(rec.Vendor_Contract_Number__c,rec.Id);
      }
    }
    System.debug(contractMap);
    return contractMap;  
  }
*/

  public static String processStagedData(String contentVersionId,String acctId) {
    System.debug(contentVersionId);
    String [] problemsArray;
    Integer [] faxPtrArray,contractPtrArray,telephonePtrArray;
    Integer i,j,ptr,listLength,yTop,xLeft,pageNumber=0,taxPtr=0,subtotalPtr=0,amountPtr=0,remitPtr=0,usePtr=0,directPtr=0,numberPtr=0,toPtr=0,payerPtr=0,invoiceDateCnt=0;
    Integer invoiceDateMonth,invoiceDateDay,invoiceDateYear;
    String localOffice='',billTo='',serviceLocation = '',invoiceNumber='',invoiceDateStr='',salesContact='',fieldContact='',telephone='',fax='';
    String federalTaxId='',dunsNumber='',orderType='',orderNo='',billingId='',contract='',description='',remitPart1='',remitPart2='',remitPart3='',remitTo='',payer='';
    Decimal labor=0,expenses=0,tax=0,subtotal=0,invoiceTotal=0;
    Decimal pageNumberD,xLeftD,yTopD;
    String  retVal = 'ok', lineText, word, prevWord='',nextWord='',lLineText='',lWord='',lNextWord='',lPrevWord='';
    Date invoiceDate;

    Integer descriptionPtr=0,laborPtr=0,expensesPtr=0,invoiceDatePtr=0,localOfficePtr=0;
    Integer billingIdPtr=0,salesContactPtr=0,fieldContactPtr=0,invoiceNumberPtr=0,telephonePtr=0,faxPtr=0;
    Integer federalTaxIdPtr=0,dunsNumberPtr=0,contractPtr=0,orderTypePtr=0,remittancePtr=0,localOfficeAbovePtr=0,billToPtr=0,serviceLocationPtr=0,notificationPtr=0,payablePtr=0;
    String federalTaxIdStr='',dunsNumberStr='',contractStr='',orderTypeStr='',billToStr='',serviceLocationStr='',orderNumberStr='',problemString='',daysStr='', notification = '';
    Integer termsSpecialCase1Ptr=0,termsSpecialCase2Ptr=0,daysPtr=0,daysToPay=30;
    Integer invoicePtr=0,billingPtr=0,orderNoPtr=0,orderNumberPtr=0;
    Integer invoiceCnt=0;
    String laborStr,expensesStr,taxStr,subtotalStr,invoiceTotalStr,billingStr,localOfficeStr='',orderNoStr,billingIdStr,salesContactStr,fieldContactStr,invoiceNumberStr,invoiceDateString;
    String telephoneStr='',faxStr='',notificationStr='';

    problemsArray     = new List<String>();
    faxPtrArray       = new List<Integer>();
    contractPtrArray  = new List<Integer>();
    telephonePtrArray = new List<Integer>();

    String pdfFile = getPdfFilename(contentVersionId);
    List<SchindlerOcrStaging__c> data = SchindlerOcrProcess.getStagedData(contentVersionId);
    listLength = data.size();
    SchindlerOcrStaging__c rec,prevRec,nextRec;
      
    for(i=0;i<listLength;i++) {
      rec = data[i];
      
      prevWord = '';
      nextWord = '';
      if(i>0) {
        prevRec  = data[i-1];
        prevWord = prevRec.WordText__c;
      }
      if(i<listLength-1) {
        nextRec  = data[i+1];
        nextWord = nextRec.WordText__c;
      }

      lineText    = rec.LineText__c;
      word        = rec.WordText__c;
      pageNumberD = rec.PageNumber__c;
      xLeftD      = rec.XLeft__c;
      yTopD       = rec.YTopModified__c;
      pageNumber  = pageNumberD.intValue();
      xLeft       = xLeftD.intValue();
      yTop        = yTopD.intValue();

      lLineText = lineText.toLowerCase();
      lWord     = word.toLowerCase();
      lNextWord = nextWord.toLowerCase();
      lPrevWord = prevWord.toLowerCase();

      xLeftD      = rec.XLeft__c;
      yTopD       = rec.YTopModified__c;
      xLeft       = xLeftD.intValue();
      yTop        = yTopD.intValue();

      // Invoice Amount is not clearly deliniated with consistant markers,
      // so look for the range each special case is and find first number.
      if(lineText.containsIgnoreCase('PAYABLE UPON RECEIPT')) {
        termsSpecialCase1Ptr = i;
      }

      if(lineText.containsIgnoreCase('Invoice Amount')) {
        termsSpecialCase2Ptr = i;
      }

      switch on lLineText {
        when 'sales contact' {
          if(salesContactPtr == 0) {
            salesContactPtr = i;
          }
        }
        
        when 'field contact' {
          if(fieldContactPtr == 0) {
            fieldContactPtr = i;
          }
        }        
      }

      switch on lWord {
        when 'description' {
         if(descriptionPtr == 0) {
            descriptionPtr = i;
          }
        }
        when 'labor' {     
          if(!String.isBlank(lNextWord)) {     
            if(lNextWord != 'standards') {
              laborPtr = i;
            }
          }
        }

        when 'expenses' {   
          if(expensesPtr == 0) {       
            expensesPtr = i;
          }
        }    
        when 'tax' { 
          if(taxPtr == 0 && lPrevWord != 'federal') {
            taxPtr = i;
          }
        } 
        when 'subtotal'{ 
          if(subtotalPtr == 0) {
            subtotalPtr = i;
          }
        } 
        when 'amount' { 
          if(amountPtr == 0  && lPrevWord == 'invoice') {
            amountPtr = i;
          }
        } 
        when 'remit' {
          if(remitPtr == 0) {
            remitPtr = i;
          }
        }
        when 'remittance' {
          if(remittancePtr == 0) {
            remittancePtr = i; 
          }
        }  
        when 'use' {
          if(usePtr == 0 && lNextWord == 'this') {
            usePtr = i;
          }
        }
        when 'direct' {
          if(directPtr == 0) {
            directPtr = i;
          }
        }

        when 'number' {
          if(numberPtr == 0) {
            numberPtr = i;
          }
        }

        when 'payer' {
          if(payerPtr == 0) {
            payerPtr = i;
          }
        }

        when 'to' {
          if(toPtr == 0) {
            toPtr = i;
          }         
        }

        when 'invoice','nvoice' {
          if(invoiceNumberPtr == 0 && lNextWord == 'number') {
            invoiceNumberPtr = i;
          }

          if(invoiceDatePtr == 0 && lNextWord == 'date') {
            invoiceDateCnt++;
            invoiceCnt++;
            invoiceDatePtr = i;
          }
        }

        when 'bill' {          
          if(billToPtr == 0) {
            billToPtr = i;
          }
        }        

        when 'billing' {  
          if(lNextWord == 'id') {
            billingIdPtr = i;
          }        
          if(billingPtr == 0) {
            billingPtr = i;
          }
        }
        when 'loca','local' {
          if(localOfficePtr == 0) {
            localOfficePtr = i; 
          }
        }
        when 'order' {
          if(orderNoPtr == 0 && lNextWord == 'no' && lPrevWord != 'purchase') {
            orderNoPtr = i; 
          }
          // Using 2nd occurance, if it exists, as it seems more reliable to have # after it.
          if(lNextWord == 'type') {
            orderTypePtr = i;
          }
          if(orderNumberPtr == 0 && lNextWord == 'number') {
            orderNumberPtr = i;
          }
        }
        when 'sales' {
          if(salesContactPtr == 0 && lNextWord == 'contact') {
            salesContactPtr = i; 
          }
        }
        when 'field' {
          if(fieldContactPtr == 0 && lNextWord == 'contact') {
            fieldContactPtr = i; 
          }
        }
        when 'telephone','telephon' {
          telephonePtrArray.add(i);
        }
        when 'fax' {
          faxPtrArray.add(i);
        }
        when 'federal' {
          if(federalTaxIdPtr == 0 && lNextWord == 'tax') {
            federalTaxIdPtr = i;
          }
        }
        when 'duns' {
          if(dunsNumberPtr == 0 && lNextWord == 'number') {
            dunsNumberPtr = i;
          }
        }
        when 'contract' {
          if(lPrevWord != 'your') {
            contractPtrArray.add(i);
          }
        }
        when 'office' {
          if(lPrevWord == 'local' && lNextWord == 'above.') {
            localOfficeAbovePtr = i;
          }
        }
        when 'service' {
          if(serviceLocationPtr == 0) {
            serviceLocationPtr = i;
          }
        }                                                                                
        when 'notification' {
          if(notificationPtr == 0) {
            notificationPtr = i;
          }
        }
        when 'payable' {
          if(payablePtr == 0 && lNextWord == 'upon') {
            payablePtr = i;
          }
        }
        when 'days' {
          if(daysPtr == 0 && lNextWord == 'are') {
            daysPtr = i;
          }
        }           

      }

      ///////// ASSIGN Backup vars

      if(rec.PageNumber__c == 1) {
        if(yTop > 160 && yTop < 240 && xLeft < 700) {
          if(lWord != 'local' && lWord != 'office') {
            localOffice += word + ' ';
          }
        }
  
        if(yTop > 370 && yTop < 480 && xleft < 700) {
          if(lWord != 'bill' && lWord != 'to') {
            billTo += word + ' ';
          }
        }
  
        if(yTop > 560 && yTop < 680 && xleft < 700) {
          if(lWord != 'service' && lWord != 'location') {
            serviceLocation += word + ' ';
          }
        }
      
        if(yTop > 160 && yTop < 180 && xleft > 1000) {
          invoiceNumber = word;
        }
  
        if(yTop > 180 && yTop < 220 && xleft > 1000) {
          invoiceDateString = word;
        }
  
        if(yTop > 220 && yTop < 240 && xleft > 1000) {
          billingId = word;
        }
  
        if(yTop > 310 && yTop < 340 && xleft > 1000) {
          salesContact += word + ' ';
        }
  
        if(yTop > 340 && yTop < 370 && xleft > 1000) {
          fieldContact += word + ' ';
        }
  
        if(yTop > 370 && yTop < 400 && xleft > 1000) {
          telephone += word + ' ';
        }
  
        if(yTop > 400 && yTop < 430 && xleft > 1000) {
          fax += word + ' ';
        }
  
        if(yTop > 460 && yTop < 490 && xleft > 1000) {
          federalTaxId += word + ' ';
        }
  
        if(yTop > 490 && yTop < 520 && xleft > 1000) {
          dunsNumber += word + ' ';
        }
  
        if(yTop > 550 && yTop < 580 && xleft > 1000) {
          orderType += word;
        }
  
        if(yTop > 620 && yTop < 640 && xleft > 1000) {
          contract = word;
        }
  
        if(yTop > 1650 && yTop < 1670 && xleft > 1000) { // 2nd Occurrance
          orderNo = word;
        }

      }

    }

    System.debug('------------------------------------------');
    System.debug('billingIdPtr (not used?) :  ' + billingIdPtr.format());

    System.debug('descriptionPtr:      ' + descriptionPtr.format()      );
    System.debug('billingPtr:          ' + billingPtr.format()          );
    System.debug('localOfficePtr:      ' + localOfficePtr.format()      );
    System.debug('laborPtr:            ' + laborPtr.format()            );
    System.debug('expensesPtr :        ' + expensesPtr.format()         ); 
    System.debug('taxPtr :             ' + taxPtr.format()              );
    System.debug('subtotalPtr:         ' + subtotalPtr.format()         );
    System.debug('amountPtr:           ' + amountPtr.format()           );
    System.debug('remitPtr:            ' + remitPtr.format()            );
    System.debug('remittancePtr:       ' + remittancePtr.format()       );
    System.debug('usePtr:              ' + usePtr.format()              );
    System.debug('directPtr:           ' + directPtr.format()           );
    System.debug('numberPtr:           ' + numberPtr.format()           );
    System.debug('orderNoPtr:          ' + orderNoPtr.format()          );
    System.debug('orderNumberPtr:      ' + orderNumberPtr.format()      );
    System.debug('payerPtr:            ' + payerPtr.format()            );
    System.debug('toPtr :              ' + toPtr.format()               );
    System.debug('invoicePtr:          ' + invoicePtr.format()          );
    System.debug('invoiceDatePtr:      ' + invoiceDatePtr.format()      );   
    System.debug('invoiceNumberPtr:    ' + invoiceNumberPtr.format()    );   
    System.debug('salesContactPtr:     ' + salesContactPtr.format()     );   
    System.debug('fieldContactPtr:     ' + fieldContactPtr.format()     );   
    System.debug('telephonePtr:        ' + telephonePtr.format()        );   
    System.debug('faxPtr:              ' + faxPtr.format()              );   
    System.debug('federalTaxIdPtr:     ' + federalTaxIdPtr.format()     );   
    System.debug('dunsNumberPtr:       ' + dunsNumberPtr.format()       );   
    System.debug('contractPtr:         ' + contractPtr.format()         );   
    System.debug('orderTypePtr:        ' + orderTypePtr.format()        );   
    System.debug('localOfficeAbovePtr: ' + localOfficeAbovePtr.format() );
    System.debug('serviceLocationPtr:  ' + serviceLocationPtr.format()  );
    System.debug('payablePtr:          ' + payablePtr.format()          );
    System.debug('daysPtr:             ' + daysPtr.format()             );

    System.debug('notificationPtr:     ' + notificationPtr.format());
    System.debug('invoiceDateString:   ' + invoiceDateString);

    String line,num;
    Integer problemTotal=0;
    Boolean termsFound = false;

    // Uses pointer existance to first attempt to find each field's value, with fallback to backup fields when possible.
    if (descriptionPtr > 0 && notificationPtr > descriptionPtr) {
      for(i=descriptionPtr+2;i<notificationPtr+2;i++) {
        word = data[i].WordText__c;
        description += word + ' ';
      } 
    } else {
      problemsArray.add('Problem: Finding Description (no backup for Description).');
    }

    if(notificationPtr > 0) {
      num =  data[notificationPtr+1].WordText__c;
      if(isOnlyDigits(num)) {
        notificationStr = String.valueOf(Integer.valueOf(num)); // Remove leading zeros
      } else {
        problemsArray.add('Problem: Finding Notification (no backup for Notification).');
      }
    } else {
      problemsArray.add('Problem: Finding Notification (no backup for Notification).');
    }

    if(localOfficePtr > 0) {
      for(i=localOfficePtr+1;i<billingPtr;i++) {
        word   = data[i].WordText__c;
        lWord  = word.toLowerCase();
        xLeftD = data[i].XLeft__c;
        xLeft  = xLeftD.intValue();
        if(lWord != 'local' && lWord != 'office' && xLeft < 700) {
          localOfficeStr += word + ' ';
        }
      }
    } else {
      if(!String.isBlank(localOffice)) {
        localOfficeStr = localOffice;
        problemsArray.add('Warning: Using Local Office backup.');
      }  else {
        problemsArray.add('Problem: Finding Local Office and backup.');
      }       
    }

    if(fieldContactPtr > 0 && federalTaxIdPtr > fieldContactPtr) {
      billToStr = '';
      for(i=fieldContactPtr+2;i<federalTaxIdPtr; i++) {
        line  = data[i].LineText__c;
        xLeftD = data[i].XLeft__c;
        xLeft  = xLeftD.intValue();
        if(xLeft > 200 && xLeft < 700) {
          if(billToStr.indexOf(line) == -1) {
            billToStr += line + ' ';
          } 
        }
      }
    } else {
      if(!String.isBlank(billTo)) {
        billToStr = billTo;
        problemsArray.add('Warning: Using Bill To backup.');
      } else {
        problemsArray.add('Problem: Finding Bill To and backup.');
      }        
    }

    if(serviceLocationPtr > 0 && descriptionPtr > serviceLocationPtr) {
      for(i=serviceLocationPtr+2;i<descriptionPtr; i++) {
        line  = data[i].LineText__c;
        xLeftD = data[i].XLeft__c;
        xLeft  = xLeftD.intValue();
        if(xLeft > 200 && xLeft < 700) {
          if(serviceLocationStr.indexOf(line) == -1) {
            serviceLocationStr += line + ' ';
          } 
        }
      }
    } else {
      if(!String.isBlank(serviceLocation)) {
        serviceLocationStr = serviceLocation;
        problemsArray.add('Warning: Using Service Location backup.');
      }  else {
        problemsArray.add('Problem: Finding Service Location and backup.');
      }
    }


    if(billingIdPtr > 0) {
      num = data[billingIdPtr+2].WordText__c;
      if(isOnlyDigits(num)) {
        billingIdStr = num;
      } else {
        num = data[billingIdPtr-1].WordText__c;
        if(isOnlyDigits(num)) {
          billingIdStr = num;
        } else {
          if(isOnlyDigits(billingId)) {
            billingIdStr = billingId;
            problemsArray.add('Warning: Using Billing Id backup.');
          } else {
            problemsArray.add('Problem: Finding Billing Id and backup');
          }
        }
      }
    } else {
      if(isOnlyDigits(billingId)) {
        billingIdStr = billingId;
        problemsArray.add('Warning: Using Billing Id backup.');
      } else {
        problemsArray.add('Problem: Finding Billing Id and backup.');
      }
    }

    if(laborPtr > 0) {
      num = data[laborPtr+1].LineText__c;
      if(isNumber(num)) {
        laborStr = num;
        labor = cleanDec(laborStr);
      } else {
        problemsArray.add('Problem: Finding Labor (no backup for Labor).');
      }
    } else {
      problemsArray.add('Problem: Finding Labor (no backup for Labor).');
    }

    if(expensesPtr > 0) {
      num = data[expensesPtr+1].LineText__c;
      if(isNumber(num)) {
        expensesStr = num;
        expenses    = cleanDec(expensesStr);
      } else {
        problemsArray.add('Problem: Finding Expenses (no backup for Expenses).');
      }
    } else {
      problemsArray.add('Problem: Finding Expenses (no backup for Expenses).');
    }

    Boolean taxFound = false;
    if(taxPtr > 0 && payablePtr > taxPtr) {
      num = data[taxPtr+1].LineText__c;
      if(num == '0.00' || isNumber(num)) {
        taxFound = true;
        taxStr   = num;
        tax      = cleanDec(taxStr);
      } else {
        if(num == 'Applied unless an exemption certificate is on file') {
          for(i=taxPtr+2;i<payablePtr;i++) {
            System.debug('tax pointer: ' + i.format());
            num = data[i].LineText__c;
            if(num == '0.00' || isNumber(num)) {
              taxFound = true;
              taxStr   = num;
              tax      = cleanDec(taxStr);
              break;
            } 
          }
        }
      } 
    }
    if(!taxFound) {   
      problemsArray.add('Problem: Finding Tax (no backup for tax).');
    }  

    if(subtotalPtr > 0) {
      num = data[subtotalPtr+1].LineText__c;
      if(isNumber(num)) {
        subtotalStr = num;
        subtotal    = cleanDec(subtotalStr);
      } else {
        problemsArray.add('Problem: Finding Sub Total (no backup for Sub Total).');
      }
   
    } else {
      problemsArray.add('Problem: Finding Sub Total (no backup for Sub Total).');
    }

    Integer startIdx,endIdx,spi;
    if(termsSpecialCase1Ptr > 0) {
      startIdx = termsSpecialCase1Ptr-10;
      endIdx = termsSpecialCase1Ptr+10;
      endIdx = Math.min(listLength,endIdx);
      for(spi=startIdx;spi<endIdx;spi++) {
        num = data[spi].WordText__c;
        if(num.startsWith('$')) {
          invoiceTotalStr = num;
          invoiceTotal    = cleanDec(num);
          termsFound      = true;
          problemsArray.add('Info: Found Terms ' + num + ' with SP1');
          break;
        }
      }
    }
    if(!termsFound && termsSpecialCase2Ptr > 0) {
      startIdx = termsSpecialCase2Ptr-10;
      endIdx = termsSpecialCase2Ptr+10;
      endIdx = Math.min(listLength,endIdx);
      for(spi=startIdx;spi<endIdx;spi++) {
        num = data[spi].WordText__c;
        if(num.startsWith('$')) {
          invoiceTotalStr = num;
          invoiceTotal    = cleanDec(num);
          termsFound      = true;
          problemsArray.add('Info: Found Terms ' + num + ' with SP2');
          break;
        }
      }
    }
    if(!termsFound) {
      problemsArray.add('Problem: Finding Invoice Terms (no backup for Invoice Terms).');
    }

    if(invoiceDatePtr > 0) {
      if(invoiceDatePtr+2 > listLength) {
        problemsArray.add('Problem: Finding Invoice Date and backup.');
      } else {
        invoiceDateStr = data[invoiceDatePtr+2].WordText__c;

        if(!isDate(invoiceDateStr)) {
          invoiceDateStr = data[invoiceDatePtr-1].WordText__c;
          if(!isDate(invoiceDateStr)) {
            if(!isDate(invoiceDateString)) {
              problemsArray.add('Problem: Finding Invoice Date and backup.');
            } else {
              invoiceDateStr = invoiceDateString;
              invoiceDate = convertToDate(invoiceDateStr);
              problemsArray.add('Warning: Using backup Invoice Date.');
            }
          } else {
            invoiceDate = convertToDate(invoiceDateStr);    
          }
        } else {
          invoiceDate = convertToDate(invoiceDateStr);    
        }
      }
    } else {
      if(isDate(invoiceDateString)) {
        invoiceDateStr = invoiceDateString;
        invoiceDate = convertToDate(invoiceDateStr);
        problemsArray.add('Warning: Using backup Invoice Date.');
      } else {
        problemsArray.add('Problem: Finding Invoice Date and backup.');
      }
    }

    if(invoiceNumberPtr > 0) {
      num = data[invoiceNumberPtr+2].LineText__c;
      if(isInvoiceNumber(num)) {
        invoiceNumberStr = num;
      } else {
        num = data[invoiceNumberPtr-1].LineText__c;
        if(isInvoiceNumber(num)) {
          invoiceNumberStr = num;
        } else {
          if(isInvoiceNumber(invoiceNumber)) {
            invoiceNumberStr = invoiceNumber;
            problemsArray.add('Warning: Using backup Invoice Number.');
          } else {
            problemsArray.add('Problem: Finding Invoice Number and backup.');
          }
          problemsArray.add('Problem: Finding Invoice Number');
        }
      }
    } else {
      if(isInvoiceNumber(invoiceNumber)) {
        invoiceNumberStr = invoiceNumber;
      } else {
        problemsArray.add('Problem: Finding Invoice Number and backup.');
      }
    }

    // Sometimes Telephone # is on the line that comes before the word 'Telephone', so check each occurance to see if we can find it after.
    Integer tas = telephonePtrArray.size();
    if(tas > 0) {
      Boolean telephoneFound = false;
      for(j=0;j<tas;j++) {
        ptr = telephonePtrArray[j];
        num = data[ptr+1].LineText__c;
        if(isOnlyDigits(num)) {
          telephonePtr   = ptr;
          telephoneStr   = num;
          telephoneFound = true;
          break;   
        }
      }
      if(!telephoneFound) {
        if(!String.isBlank(telephone)) {
          telephoneStr = telephone;
          problemsArray.add('Warning: Using backup Telephone Number.');
        } else {
          problemsArray.add('Problem: Finding Telephone Number and backup.');
        }
      }
    }

    // Sometimes Fax # is on the line that comes before the word 'Fax', so check each occurance to see if we can find it after.
    Integer fas = faxPtrArray.size();
    if(fas > 0) {
      Boolean faxFound = false;
      for(j=0;j<fas;j++) {
        ptr = faxPtrArray[j];
        num = data[ptr+1].LineText__c;
        if(isOnlyDigits(num)) {
          faxPtr   = ptr;
          faxStr   = num;
          faxFound = true;
          break;   
        }
      }
      if(!faxFound) {
        if(!String.isBlank(fax)) {
          faxStr = fax;
          problemsArray.add('Warning: Using backup Fax Number.');
        } else {
          problemsArray.add('Problem: Finding Fax Number and backup.');
        }
      }
    }

    // Sometimes Contract # is on the line that comes before the word 'Contract', so check each occurance to see if we can find it after.
    Integer cas = contractPtrArray.size();
    Boolean contractFound = false;    
    if(cas > 0) {
      for(j=0;j<cas;j++) {
        ptr = contractPtrArray[j];
        num = data[ptr+1].LineText__c;
        if(isOnlyDigits(num)) {
          contractPtr   = ptr;
          contractStr   = num;
          contractFound = true;
          break;   
        }
      }
      if(!contractFound) {
        if(!String.isBlank(contract)) {
          contractStr = contract;
          problemsArray.add('Warning: Using backup Contract Number.');
        } else {
          problemsArray.add('Problem: Finding Contract Number and backup.');
        }
      }
    }    

    // Remit To info is messy.
    Decimal minXleftD,maxXleftD;
    Integer minXleft,maxXleft;
    if(remitPtr > 0 && usePtr > 0 && localOfficeAbovePtr-3 > remitPtr) {
      minXleftD = data[remitPtr].XLeft__c;
      maxXleftD = data[usePtr].XLeft__c;
      minXleft  = minXleftD.intValue() + 30;
      maxXleft  = maxXleftD.intValue() - 10;
      for(i=remitPtr+1;i<localOfficeAbovePtr;i++) {
        xLeftD    = data[i].XLeft__c;
        xLeft     = xLeftD.intValue();
        if(xLeft > minXleft && xLeft < maxXleft) {
          remitTo += data[i].WordText__c + ' ';
        }
      }
    } else {
      problemsArray.add('Problem: Finding Remit To.');
    }

    // Payer Info is messy.
    if(payerPtr > 0 && (payerPtr + 20 < listLength) ) {
      for(i=payerPtr+1;i < payerPtr + 20;i++) {
        rec  = data[i];
        word = rec.WordText__c;
        if(word == 'Date') {
          break;
        }
        if(rec.XLeft__c < 600 && rec.WordText__c != 'Payer') {
          payer += rec.WordText__c + ' ';
        }
      }
    } else {
      problemsArray.add('Problem: Finding Payer');
    }

    // Order No and Order Number can both appear on invoice.  Give precedence to No
    if(orderNoPtr > 0) {
      num = data[orderNoPtr+2].LineText__c;
      if(isOnlyDigits(num)) {
        orderNoStr = num;
      } else {
        if(orderNumberPtr > 0) {
          num = data[orderNumberPtr+2].LineText__c;
          if(isOnlyDigits(num)) {
            orderNumberStr = num;
          } else {
            if(isOnlyDigits(orderNo)) {
              orderNoStr = orderNo;
              problemsArray.add('Warning: Using Order Number backup.');
            } else {
              problemsArray.add('Problem: Finding Order Number and backup.');
            }
          }
        } else {
          if(isOnlyDigits(orderNo)) {
            orderNoStr = orderNo;
            problemsArray.add('Warning: Using Order Number backup.');
          } else {
            problemsArray.add('Problem finding Order Number and backup.');
          }
        }
      }
    } else {
      if(orderNumberPtr > 0) {
        num = data[orderNumberPtr+2].LineText__c;
        if(isOnlyDigits(num)) {
          orderNumberStr = num;
        } else {
          if(isOnlyDigits(orderNo)) {
            orderNoStr = orderNo;
            problemsArray.add('Warning: Using Order Number backup.');
          } else {
            problemsArray.add('Problem: Finding Order Number and backup.');
          }
        }
      } else {
        if(isOnlyDigits(orderNo)) {
          orderNoStr = orderNo;
          problemsArray.add('Warning: Using Order Number backup.');
        } else {
          problemsArray.add('Problem: Finding Order Number and backup.');
        }
      }
    }    

    if(salesContactPtr > 0) {
      if(data[salesContactPtr+1].LineText__c != 'Sales Contact') {
        salesContactStr = data[salesContactPtr+1].LineText__c;
      } else {
        if(data[salesContactPtr+2].LineText__c != 'Sales Contact') {
          salesContactStr = data[salesContactPtr+2].LineText__c;
        } else {
          if(!String.isBlank(salesContact)) {
            salesContactStr = salesContact;
            problemsArray.add('Warning: Using Sales Contact backup.');  
          } else{
            problemsArray.add('Problem: Finding Sales Contact and backup.');
          }
        }
      }
    } else {
      if(!String.isBlank(salesContact)) {
        salesContactStr = salesContact;
        problemsArray.add('Warning: Using Sales Contact backup.');  
      } else{
        problemsArray.add('Problem: Finding Sales Contact and backup.');
      }
    }

    if(fieldContactPtr > 0) {
      if(data[fieldContactPtr+1].LineText__c != 'Field Contact') {
        fieldContactStr = data[fieldContactPtr+1].LineText__c;
      } else {
        if(data[fieldContactPtr+2].LineText__c != 'Sales Contact') {
          fieldContactStr = data[fieldContactPtr+2].LineText__c;
        } else {
          if(!String.isBlank(fieldContact)) {
            fieldContactStr = fieldContact;
            problemsArray.add('Warning: Using Field Contact backup.');  
          } else{
            problemsArray.add('Problem: Finding Field Contact and backup.');
          }
        }
      }
    } else {
      if(!String.isBlank(fieldContact)) {
        fieldContactStr = fieldContact;
        problemsArray.add('Warning: Using Field Contact backup.');  
      } else{
        problemsArray.add('Problem: Finding Field Contact and backup.');
      }
    }

    if(federalTaxIdPtr > 0) {
      num = data[federalTaxIdPtr+3].LineText__c;
      if(isOnlyDigits(num)) {
        federalTaxIdStr = num;
      } else {
        if(!String.isBlank(federalTaxId)) {
          federalTaxIdStr = federalTaxId;
          problemsArray.add('Warning: Using backup Federal Tax Id.');
        } else {
          problemsArray.add('Problem: Finding Federal Tax Id and backup');
        }      
      }
    } else {
      if(!String.isBlank(federalTaxId)) {
        federalTaxIdStr = federalTaxId;
        problemsArray.add('Warning: Using backup Federal Tax Id.');
      } else {
        problemsArray.add('Problem: Finding Federal Tax Id and backup');
      }      
    }

    if(dunsNumberPtr > 0) { 
      num = data[dunsNumberPtr+3].LineText__c;
      if(isOnlyDigits(num)) {
        dunsNumberStr = num;
      } else {
        num = data[dunsNumberPtr-1].LineText__c;
        if(isOnlyDigits(num)) {
          dunsNumberStr = num;
        } else {
          if(!String.isBlank(dunsNumber)) {
            dunsNumberStr = dunsNumber;
            problemsArray.add('Warning: Using backup Duns Number.');
          } else {
            problemsArray.add('Problem: Finding Duns Number and backup');
          }
        }
      }  
    } else {
      if(!String.isBlank(dunsNumber)) {
        dunsNumberStr = dunsNumber;
        problemsArray.add('Warning: Using backup Duns Number.');
      } else {
        problemsArray.add('Problem: Finding Duns Number and backup');
      }
    }
  
    if(orderTypePtr > 0) {
      word  = data[orderTypePtr+2].LineText__c;
      lWord = word.toLowerCase();
      if(lWord != 'location') {
        orderTypeStr = word;
      } else {
        if(!String.isBlank(orderType)) {
          orderTypeStr = orderType;
          problemsArray.add('Warning: Using backup Order Type.');
        } else {
          problemsArray.add('Problem: Finding Order Type and backup.');    
        }
      }
    } else {
      if(!String.isBlank(orderType)) {
        orderTypeStr = orderType;
        problemsArray.add('Warning: Using backup Order Type.');
      } else {
        problemsArray.add('Problem: Finding Order Type and backup.');    
      }
    }

    if(daysPtr > 0) {
      num = data[daysPtr+1].WordText__c;
      if(isOnlyDigits(num)) {
        daysStr = num;
        daysToPay = Integer.valueOf(daysStr);
      } else {
        problemsArray.add('Problem: Finding Days To Pay - using default.');
      }
    } else {
      problemsArray.add('Problem: Finding Days To Pay - using default.');
    }

    System.debug('** Primary vars **');
    System.debug('localOffice:     ' + localOfficeStr);
    System.debug('billTo:          ' + billToStr);
    System.debug('serviceLocation: ' + serviceLocationStr);
    System.debug('invoiceNumber:   ' + invoiceNumberStr);
    System.debug('invoiceDate:     ' + invoiceDateStr);
    System.debug('billingId:       ' + billingIdStr);
    System.debug('salesContact:    ' + salesContactStr);
    System.debug('fieldContact:    ' + fieldContactStr);
    System.debug('telephone:       ' + telephoneStr);
    System.debug('fax:             ' + faxStr);
    System.debug('federalTaxId:    ' + federalTaxIdStr);
    System.debug('dunsNumber:      ' + dunsNumberStr);
    System.debug('orderType:       ' + orderTypeStr);
    if(!String.isBlank(orderNoStr)) {
      System.debug('orderNo:         ' + orderNoStr);
    } else {
      System.debug('orderNumberStr:  ' + orderNumberStr);
    }

    System.debug('contract:        ' + contractStr);
    System.debug('notification:    ' + notificationStr);
    System.debug('description:     ' + description);
    System.debug('labor str:       ' + laborStr);
    System.debug('expenses str:     ' + expensesStr);
    System.debug('tax Str:          ' + taxStr);
    System.debug('subtotal str:     ' + subtotalStr);
    System.debug('invoiceTotal Str: ' + invoiceTotalStr);
    System.debug('remitTo:         ' + remitTo);
    System.debug('payer:           ' + payer);

    problemString = 'No problems';
    problemTotal = problemsArray.size();
    if(problemTotal > 0) {
      problemString =  String.join(problemsArray,' , ');
    }

    if(false) {
      System.debug('-- Backup vars --');
      System.debug('localOffice:     ' + localOffice);
      System.debug('billTo:          ' + billTo);
      System.debug('serviceLocation: ' + serviceLocation);
      System.debug('invoiceNumber:   ' + invoiceNumber);
      System.debug('invoiceDate:     ' + invoiceDate);
      System.debug('billingId:       ' + billingId);
      System.debug('salesContact:    ' + salesContact);
      System.debug('fieldContact:    ' + fieldContact);
      System.debug('telephone:       ' + telephone);
      System.debug('fax:             ' + fax);
      System.debug('federalTaxId:    ' + federalTaxId);
      System.debug('dunsNumber:      ' + dunsNumber);
      System.debug('orderType:       ' + orderType);
      System.debug('orderNo:         ' + orderNo);
      System.debug('contract:        ' + contract);
      System.debug('notification:    ' + notification);
      System.debug('description:     ' + description);
      System.debug('labor:           ' + labor);
      System.debug('expenses:        ' + expenses);
      System.debug('tax:             ' + tax);
      System.debug('subtotal:        ' + subtotal);
      System.debug('invoiceTotal:    ' + invoiceTotal);
      System.debug('remitTo:         ' + remitTo);
      System.debug('payer:           ' + payer);

      System.debug('*** Problems ***');
      System.debug(problemString);
      System.debug('*** Problems ***');

    } 

    Schindler_Invoice_History__c newRec = new Schindler_Invoice_History__c();
    newRec.ContentVersionId__c = contentVersionId;
    newRec.PdfFilename__c      = pdfFile;
    newRec.Local_Office__c     = localOfficeStr;
    newRec.Bill_To__c          = billToStr;
    newRec.Service_Location__c = serviceLocationStr;    
    newRec.Invoice_Number__c   = invoiceNumberStr;
    newRec.Name                = invoiceNumberStr;
    newRec.Invoice_Date__c     = invoiceDate;
    newRec.Billing_Id__c       = billingIdStr;
    newRec.Sales_Contact__c    = salesContactStr;
    newRec.Field_Contact__c    = fieldContactStr;
    newRec.Telephone__c        = telephoneStr;
    newRec.Fax__c              = faxStr;
    newRec.Federal_Tax_Id__c   = federalTaxIdStr;
    newRec.Duns_Number__c      = dunsNumberStr;
    newRec.Order_Type__c       = orderTypeStr;
    if(!String.isBlank(orderNoStr)) {
      newRec.Order_No__c         = orderNoStr;
    } else {
      newRec.Order_No__c         = orderNumberStr;
    }
    newRec.Contract__c         = contractStr;
    newRec.Notification__c     = NotificationStr;
    newRec.Description__c      = description; 
    newRec.Labor__c            = labor;
    newRec.Expenses__c         = expenses;
    newRec.Invoice_Total__c    = invoiceTotal;
    newRec.Tax__c              = tax;
    newRec.Sub_Total__c        = subtotal;
    newRec.Remit_To__c         = remitTo;
    newRec.Payer__c            = payer;
    newRec.Problems__c         = problemString;
    newRec.Problem_Count__c    = problemTotal;

    // record should be linked to Opportunity if we have a contract Id.
    // Otherwise, link to Account.
    List<Opportunity> opportunityData = [
      SELECT Vendor_Contract_Number__c,Id 
      FROM Opportunity 
      WHERE AccountId = :acctId
    ];
    Map<String,String> contractMap = new Map<String,String>();
    for(Opportunity oppRec : opportunityData) {
        System.debug(rec);
      if(!contractMap.containsKey(oppRec.Vendor_Contract_Number__c)) {
        contractMap.put(oppRec.Vendor_Contract_Number__c,oppRec.Id);
      }
    }
    System.debug(contractMap);

    if(!String.isBlank(contractStr)) {
      if(contractMap.containsKey(contractStr)) {
        String oppId = contractMap.get(contractStr);
        newRec.Opportunity__c = oppId;
        System.debug(oppId);
        System.debug('************** Using ContractStr');
      } else {
        System.debug('************** Using acctId not ContractStr');
        newRec.Account__c = acctId;
      }
    } else {
      System.debug('************** Using acctId not ContractStr');      
      newRec.Account__c = acctId;
    }
    
    System.debug(newRec);

    try {
      insert newRec;
      System.debug('Inserted record');
    } catch(DmlException error) {
      retVal = 'Errors!';
      System.debug(error);
    }
   
    return retVal;
  }

}