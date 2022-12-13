/**
 * Created by joshlequire1 on 12/7/22.
 */

@IsTest
private class CreateConsentTransactionInvocableTest {

    @IsTest
    static void testBehavior() {

        List<Pricebook2> testPBs = TestDataFactory.createPricebook(3, 'test');
        List<Id> testPBIds = new List<Id>();

        List<String> testStrings = new List<String>();
        for (Pricebook2 pb : [SELECT Id, Name FROM Pricebook2]) {
            testStrings.add(String.valueOf(pb.Id));
            testPBIds.add(pb.Id);
        }

        Test.startTest();
        List<List<Pricebook2>> testResults = CreateConsentTransactionInvocable.parseStringToIds(testStrings);
        Test.stopTest();

        for (List<Pricebook2> pb : testResults) {
            Assert.isTrue(testPBIds.contains(pb[0].Id));
        }
    }
}