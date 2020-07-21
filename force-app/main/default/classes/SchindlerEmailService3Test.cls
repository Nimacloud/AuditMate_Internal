@isTest
  public class SchindlerEmailService3Test{

    @isTest (SeeAllData=true)
    public static  void Test1() { 
      SchindlerEmailService3 handler = new SchindlerEmailService3();

      Messaging.InboundEmail email = new Messaging.InboundEmail();
      Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
      email.subject        = 'This is the Email Subject';
      email.plainTextBody  = 'Hello, this a test email body. For testing purposes only.';
      envelope.fromAddress = 'test.testing@sometest.com';
      handler.handleInboundEmail(email, envelope);
  
  
//    Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
//    email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});

      String dS = 'Dummy Blob';
      Blob   dB = Blob.valueof(dS);
  
      List<Messaging.InboundEmail.BinaryAttachment> binList = new List<Messaging.InboundEmail.BinaryAttachment>(); 
      Messaging.InboundEmail.BinaryAttachment binaryA = new Messaging.InboundEmail.BinaryAttachment();
      binaryA.FileName = 'DummyFile.Pdf';
      binaryA.body     = dB;
      binList.add(binaryA);
      email.binaryAttachments = binList;

      List<Messaging.InboundEmail.TextAttachment> txtList = new List<Messaging.InboundEmail.TextAttachment>();
      Messaging.InboundEmail.TextAttachment textA = new Messaging.InboundEmail.TextAttachment();
      textA.FileName = 'DummyFile.Pdf';
      textA.body     = 'This is a test';
      txtList.add(textA);
      email.textAttachments = txtList;

      Messaging.InboundEmailResult result = handler.handleInboundEmail(email, envelope);
      System.assertEquals( result.success,true );

  }

}