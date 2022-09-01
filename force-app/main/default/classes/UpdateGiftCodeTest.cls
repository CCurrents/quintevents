@isTest
private class UpdateGiftCodeTest {
    @testSetup 
    static void setup() {
        Pricebook2 testPricebook = new Pricebook2(Name = 'Test Pricebook', IsActive = true, Chargeable_Currencies__c = 'USD');
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
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Accountid = objAccount.Id;
        objOpportunity.Name = 'person opportunity';
        objOpportunity.Pricebook2Id = testPricebook.Id;
        objOpportunity.Payment_Method__c ='Credit Card';
        objOpportunity.Email__c = 'testperson@quintevnts.com';
        objOpportunity.Send_Payment_Email__c = false;
        objOpportunity.StageName = 'Closed Won';
        objOpportunity.CloseDate = date.today(); 
        objOpportunity.Contact_Site__c = 'quintevents.com';   
        objOpportunity.Primary_Contact__c =  objContact.Id;  
        objOpportunity.Shipping_Outside_US__c = 'Yes'; 
        insert objOpportunity;
        
        Order objOrder = new Order();
        objOrder.AccountId = objOpportunity.AccountId;
        objOrder.Status = 'Draft';
        objOrder.OpportunityId = objOpportunity.Id;
        objOrder.Name = objOpportunity.Name;
        objOrder.EffectiveDate = objOpportunity.Closedate;
        insert objOrder;
        
        List<Gift_Code__c> lstGF = new List<Gift_Code__c>();
        for(integer i= 0; i < 10; i++) { 
            Gift_Code__c objGC = new Gift_Code__c();
            objGC.Gift_Code__c = '1234567';
            objGC.Opportunity__c = objOpportunity.Id;
            
            lstGF.add(objGC);
        }
        
        insert lstGF;
    }
    static testmethod void test() {        
        Test.startTest();
        UpdateGiftCode objBatch = new UpdateGiftCode();
        Id batchId = Database.executeBatch(objBatch);
        Test.stopTest();
    }
}