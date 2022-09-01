@isTest
private class convertedLead_LIV_GOLF_London_Test{
    @testSetup 
    static void setup() {
        TestDataFactory.createTriggerSettingsEntry();
        Lead objLead = TestDataFactory.createLead();

        objLead.Marketing_Email_Consent__c = 'Yes';
        update objLead;
    }
    static testmethod void test() {        
        Test.startTest();
        Lead objLead = [Select Id FROM Lead LIMIT 1];
        Set<String> setId = new Set<String>();
        setId.add(objLead.Id);
        
        Date CloseDate = date.newInstance(2022, 5, 25);
        convertedLead_LIV_GOLF_London objBatch = new convertedLead_LIV_GOLF_London(setId, CloseDate);
        Id batchId = Database.executeBatch(objBatch);
        Test.stopTest();
    }
}