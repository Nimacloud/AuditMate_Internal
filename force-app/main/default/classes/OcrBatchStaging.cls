public without sharing class OcrBatchStaging implements Database.Batchable<sObject> {

  public Database.QueryLocator start(Database.BatchableContext BC) {
      // Note: Using limit of 5
      // AuditmateUtility.incIntVal('OcrBatchCount');
      String sQuery = 'SELECT Id,JsonVersionId__c,Staged__c,Status__c,Title__c FROM OCR_Send_Log__c WHERE Status__c = \'Sent\' AND Staged__c = false AND Result__c != \'Errors!\' LIMIT 5';
      System.debug(sQuery);
      // Integer currentBatchCount = AuditmateUtility.getIntVal('OcrBatchCount');
      // System.debug('OcrBatchStaging currentBatchCount ' + currentBatchCount.format() );
      return Database.getQueryLocator(sQuery);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
      List<OCR_Send_Log__c> ocrUpdateList = new List<OCR_Send_Log__c>();
      String result;
      Integer count = 0;
      for (sObject s : scope) {
        count++;
        OCR_Send_Log__c logRec = (OCR_Send_Log__c) s;	
        System.debug(count.format() +  ' - Staging: ' + logRec.Title__c);
        result = SchindlerOcrStaging.launch(logRec.JsonVersionId__c);
        logRec.Result__c = result;
        if(result == 'ok') {
          logRec.Staged__c = true;
        }
        ocrUpdateList.add(logRec);
      }

      System.debug('[1] OcrBatchStaging execute: ocrUpdateList');
      System.debug(ocrUpdateList);

      Database.SaveResult[] srList = Database.update(ocrUpdateList, false);
      for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
          for(Database.Error err : sr.getErrors()) {
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
          }
        } else {
          String updatedId = sr.getId();
          System.debug('OcrBatchStaging execute updated Id:' + updatedId);
        }
      }

    }

    public void finish(Database.BatchableContext BC) {

      AggregateResult[] cnts = [SELECT Count(Id) Cnt FROM OCR_Send_Log__c WHERE Status__c = 'Sent' AND Staged__c = false AND Result__c != 'Errors!'];
      Integer unstagedCnt = (Integer) cnts[0].get('Cnt');

//    AuditmateUtility.decIntVal('OcrBatchCount');

//    Integer currentBatchCount = AuditmateUtility.getIntVal('OcrBatchCount');
//    if(currentBatchCount < 30 ) {
        if( unstagedCnt > 0 ) {
//        AuditmateUtility.incIntVal('OcrBatchCount');
          System.debug('OcrBatchStaging Found ' + unstagedCnt.format() + ' records in OCR_Send_Log__c requiring staging.');
          System.debug('OcrBatchStaging is now launching itself');
          Id batchInstanceId = Database.executeBatch(new OcrBatchStaging());
          System.debug('OcrBatchStaging started.  Job Id:');
          System.debug(batchInstanceId);
        } else {
          System.debug(datetime.now().format('yyyy.MM.dd HH:mm:ss z') + ' OcrBatchStaging did not see any unstaged sent records in OCR_Send_Log__c.');
        }
//    } else {
//      System.debug('OcrBatchStaging sees currentBatchCount = ' + currentBatchCount.format());
//      System.debug('OcrBatchStaging is not launching OcrBatchStaging at this time');
//    }
    }

}