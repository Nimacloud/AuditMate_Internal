@isTest
  public class SchindlerEmailService2Test{

    @isTest (SeeAllData=true)
    public static  void Test1(){ 
      SchindlerEmailService2 handler = new SchindlerEmailService2();

    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
    email.subject        = 'This is the Email Subject';
    email.plainTextBody  = 'Hello, this a test email body. For testing purposes only.';
    envelope.fromAddress = 'test.testing@sometest.com';
    handler.handleInboundEmail(email, envelope);


    Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
    String dS = 'Dummy Blob';
    Blob   dB = Blob.valueof(dS);

    List<Messaging.InboundEmail.BinaryAttachment> binList = new List<Messaging.InboundEmail.BinaryAttachment>(); 
    Messaging.InboundEmail.BinaryAttachment binaryA = new Messaging.InboundEmail.BinaryAttachment();
    binaryA.FileName = 'DummyFile.Pdf';
    binaryA.body     = dB;
    binList.add(binaryA);
    email.binaryAttachments = binList;

   // email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});

    Messaging.InboundEmailResult result = handler.handleInboundEmail(email, envelope);
    System.assertEquals( result.success,true );

  }

}