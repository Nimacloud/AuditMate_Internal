@isTest
public class SchindlerEquipmentUpdateHelperTest {

  @isTest (SeeAllData=true)
  public static void Test1(){ 
    // Just for code coverage!
    Time arrivalTime = SchindlerEquipmentUpdateHelper.getTime('');
    arrivalTime = SchindlerEquipmentUpdateHelper.getTime('9:20 PM');
    SchindlerEquipmentUpdateHelper.updateEquimentCat5DatesFromStateData();
  }

}