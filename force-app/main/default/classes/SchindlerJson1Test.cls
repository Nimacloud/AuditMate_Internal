@isTest
private class SchindlerJson1Test {

  @isTest
  static void testClass() {
    String testJson = '{ "Successful": true, "OcrPages": [ { "PageNumber": 1, "Successful": true, "Lines": [ { "LineText": "Schindler", "Words": [ { "WordText": "Schindler", "LineNumber": 0, "WordNumber": 17, "XLeft": 1053, "YTop": 1906, "Width": 21, "Height": 25, "ConfidenceLevel": 0.95, "BlockNumber": 0, "ParagraphNumber": 0, "PageNumber": 1 } ] } ] } ] }';
    SchindlerJson1 ocrData = SchindlerJson1.parse(testJson);
    System.Debug(ocrData);
    System.Debug(ocrData.OcrPages[0].Lines[0].LineText);
    //System.assertEquals(testJson.);
  }

}