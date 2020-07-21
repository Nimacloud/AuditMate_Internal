@isTest (SeeAllData=true)
public without sharing class DateDifferenceTest {

  @isTest (SeeAllData=true)
  public static void test1() {
    // Just for code coverage
    Datetime now = Datetime.now();
    Datetime tomorrow = now.addDays(1).addHours(2).addMinutes(3).addSeconds(4);
    DateDifference.diffWrapper test = DateDifference.getDifference(now,tomorrow); 
    System.assertEquals(1, test.Days);
    System.assertEquals(2, test.Hours);
    System.assertEquals(3, test.Minutes);
    System.assertEquals(4, test.Seconds);
  }

}