public without sharing class SchindlerOcrStaging {
  // Data returned from https://api.cloudmersive.com/ocr/pdf/to/lines-with-location is stored in a document, as it is too long to fit in a text field.
  // For the passed DocumentId, this routine parses the Json data from the document into a SchindlerJson1 instance and then creates staging records in SchindlerOcrStaging__c.

  Public Static String launch(String contentVersionId) {
    
    ContentVersion cvRec = [SELECT ContentSize,VersionData FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
    Blob versionDataBlob     = cvRec.VersionData;
    String versionDataString = versionDataBlob.toString();
    Blob stringBlob          = EncodingUtil.base64Decode(versionDataString);
    String pdfJson           = stringBlob.toString().unescapeHtml4();
    String result            = SchindlerOcrStaging.stageData(contentVersionId, pdfJson);
    return result;
  }

  Public static void sendEmail(String contentVersionId) {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    mail.setToAddresses(new String[] {'graham.smith@auditmate.com'});
    mail.setReplyTo('graham.smith@auditmate.com');
    mail.setSenderDisplayName('SchindlerOcrStaging');
    mail.setSubject('SchindlerOcrStaging got an error from OCR');
    mail.setPlainTextBody('SchindlerOcrStaging - decoding JSON for contentVersionId ' + contentVersionId + ' found an unsuccessful page from OCR data.');
    if(!Test.isRunningTest()) {
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
  }

  Private Static Integer alignNum(Integer num) {
    String numStr,firstChars,lastChar,newNumStr;
    Integer numLen,newNum;
    numStr = String.valueOf(num);
    numLen = numStr.length();
    if(numLen == 1) {
      firstChars = numStr;
      lastChar   = numStr;
    } else {
      firstChars = numStr.left(numLen-1);
      lastChar   = numStr.right(1);
    }
//  if(lastChar == '0' || lastChar == '5') {
    if(lastChar == '0') {      
      newNum = num;
    } else {
      if(lastChar == '1' || lastChar == '2' || lastChar == '3' || lastChar == '4') {
        if(numLen == 1) {
          newNumStr = '0';
        } else {
          newNumStr = firstChars + '0';
        }
        newNum = Integer.valueOf(newNumStr);
//      System.debug( 'A. numLen is 1 [' + numStr + '] => {' + newNumStr + '}' );   
      } else {
        if(numLen == 1) {
          newNumStr = '10';
          newNum    = Integer.valueOf(newNumStr);
//        System.debug( 'B. numLen is 1 [' + numStr + '] => {' + newNumStr + '}' );         
        } else {
          newNum    = Integer.valueOf(firstChars + '0') + 10;
          newNumStr = String.valueOf(newNum);
//        System.debug( 'C. numLen is > 1 [' + numStr + '] => {' + newNumStr + '}' ); 
        }
      }
    }
    return newNum;
  }

  Public Static String stageData(String contentVersionId, String jsonData) {

    List<SchindlerOcrStaging__c> stageList = new List<SchindlerOcrStaging__c>();
    SchindlerOcrStaging__c stageRec;
    SchindlerJson1 ocrData = SchindlerJson1.parse(jsonData);

    Integer i=0,lws=0,pageNumber=0,xLeft=0,yTop=0,yTopAligned=0;
    String lineText,wordText,retVal;

    Boolean ocrUnsuccessful = false;
    // I think ocrData is always successful from OCR api call.  If the api failed to convert pdf to json, page.successful is false.
    if(ocrData.Successful) {
      for(SchindlerJson1.OcrPages page : ocrData.OcrPages ) {
        if(page.Successful) {
          for(SchindlerJson1.Lines line : page.Lines) {
            lineText = line.LineText;
            lws = line.Words.size();
            for(i=0;i<lws;i++) {
              pageNumber  = line.Words[i].PageNumber;
              wordText    = line.Words[i].WordText;
              xLeft       = line.Words[i].XLeft;
              yTop        = line.Words[i].YTop;
              yTopAligned = alignNum(yTop); 
    
              if(wordText.length() > 200 ) {
                System.debug('Error: Word too long for field ' + wordText);
                wordText = 'Too long: ' + wordText.left(190);
              }
    
              stageRec = new SchindlerOcrStaging__c();
              stageRec.LineText__c          = lineText;
              stageRec.ContentVersionId__c  = contentVersionId;
              stageRec.PageNumber__c        = pageNumber;
              stageRec.WordText__c          = wordText;
              stageRec.XLeft__c             = xLeft;
              stageRec.YTop__c              = yTop;
              stageRec.YTopModified__c      = yTopAligned; 
              stageList.add(stageRec);
            }
          }
        } else {
          // Break on any unsuccessful OCR page.
          System.debug('SchindlerOcrStaging Error - ' + contentVersionId + ' did not OCR a page successfully.');
          ocrUnsuccessful = true;
          break;
        }
      }
    } else {
      System.debug('SchindlerOcrStaging Error - ' + contentVersionId + ' did not OCR successfully.');
      ocrUnsuccessful = true;
    }

    if(ocrUnsuccessful) {
      if(!Test.isRunningTest()) {
        sendEmail(contentVersionId);
      }
      retVal = 'OCR Error';
    } else {
      retVal = 'ok';
      Database.SaveResult[] srList = Database.insert(stageList, false);
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