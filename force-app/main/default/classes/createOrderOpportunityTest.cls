@isTest
private class createOrderOpportunityTest {
    @testSetup 
    static void setup() {
        TestDataFactory.createTriggerSettingsEntry();
        
        Pricebook2 testPricebook = new Pricebook2(Name = 'Standard Price Book', IsActive = true, Chargeable_Currencies__c = 'USD');
        insert testPricebook;
        
        Account objAccount = new Account();
        objAccount.Name = 'Addon Blue Account';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.FirstName = 'Test Contact';
        objContact.LastName = 'LastName';
        objContact.Email = 'addontest@addonblue.com';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        objAccount.Primary_Contact__c = objContact.Id;
        update objAccount;
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        for(integer i= 0; i < 10; i++){ 
            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Accountid = objAccount.Id;
            objOpportunity.Name = 'person opportunity '+i;
            objOpportunity.Pricebook2Id = testPricebook.Id;
            objOpportunity.Payment_Method__c ='Credit Card';
            objOpportunity.Email__c = 'testperson'+ i +'@quintevnts.com';
            objOpportunity.Send_Payment_Email__c = false;
            objOpportunity.StageName = 'Canceled';
            objOpportunity.CloseDate = date.today(); 
            objOpportunity.Contact_Site__c = 'quintevents.com';   
            objOpportunity.Primary_Contact__c =  objContact.Id;  
            objOpportunity.Shipping_Outside_US__c = 'Yes'; 
            lstOpportunity.add(objOpportunity);
        }
        insert lstOpportunity;
        
    }
    static testmethod void test() {        
        Test.startTest();
        createOrderOpportunity objBatch = new createOrderOpportunity();
        Id batchId = Database.executeBatch(objBatch);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        //System.assertEquals(10, [select count() from Order]);
    }
}