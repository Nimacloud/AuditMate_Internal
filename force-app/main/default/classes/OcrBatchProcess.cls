public without sharing class OcrBatchProcess implements Database.Batchable<sObject> {

  public Database.QueryLocator start(Database.BatchableContext BC) {
    String sQuery = 'SELECT Id,Account__c,JsonVersionId__c,Staged__c,Status__c,Title__c,Processed__c FROM OCR_Send_Log__c WHERE Staged__c = true AND Processed__c = false AND Result__c != \'Errors!\' LIMIT 5';
    System.debug(sQuery);
    return Database.getQueryLocator(sQuery);
  }

  public void execute(Database.BatchableContext BC, List<sObject> scope){
    List<OCR_Send_Log__c> ocrUpdateList = new List<OCR_Send_Log__c>();
    String result;
    for (sObject s : scope) {
      OCR_Send_Log__c logRec = (OCR_Send_Log__c) s;	
      // 
      result = SchindlerOcrProcess.processStagedData(logRec.JsonVersionId__c, logRec.Account__c);
      logRec.Result__c = result;
      if(result == 'ok') {
        logRec.Processed__c = true;
      }
      System.debug(logRec.Title__c);
      System.debug(logRec.Staged__c);
      System.debug(logRec.Processed__c);
      ocrUpdateList.add(logRec);
    }
  
    Database.SaveResult[] srList = Database.update(ocrUpdateList, false);
    for (Database.SaveResult sr : srList) {
      if (!sr.isSuccess()) {
        for(Database.Error err : sr.getErrors()) {
          System.debug(err.getStatusCode() + ': ' + err.getMessage());
        }
      } else {
        String updatedId = sr.getId();
        System.debug('OCR_Send_Log updated Id:' + updatedId);
      }
    }

  }

  public void finish(Database.BatchableContext BC) {

    // Integer currentBatchCount = AuditmateUtility.getIntVal('OcrBatchCount');
    // if(currentBatchCount < 30 ) {
      AggregateResult[] cnts = [SELECT Count(Id) Cnt FROM OCR_Send_Log__c WHERE Staged__c = true AND Processed__c = false AND Result__c != 'Errors!'];
      Integer unprocessedCnt = (Integer) cnts[0].get('Cnt');
      if( unprocessedCnt > 0) {
        System.debug('OcrBatchProcess Found ' + unprocessedCnt.format() + ' records in OCR_Send_Log__c requiring to process.');
        Id batchInstanceId = Database.executeBatch(new OcrBatchProcess());
        System.debug('OcrBatchProcess started new OcrBatchProcess.  Job Id:');
        System.debug(batchInstanceId);
      } else {
        System.debug(datetime.now().format('yyyy.MM.dd HH:mm:ss z') + ' OcrBatchProcess did not see any unprocesse sent records in OCR_Send_Log__c.');
      }
    // } else {
    //   System.debug('OcrBatchProcess sees currentBatchCount = ' + currentBatchCount.format());
    //   System.debug('OcrBatchProcess is not launching OcrBatchProcess at this time');
    // }
  }

}