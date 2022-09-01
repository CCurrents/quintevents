/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 10-06-2021
 * @last modified by  : ratiksinghal@addonblue.com
**/
@isTest public class UpdateOpportunityBatchTest {
    
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }

    @isTest static void testOne(){
        Test.startTest();
        List<String> lstGiftCodeTypes = new List<String>{'F1 Access Code','Fanatics Gift Code','Memento Premium','Memento Ultimate'};
        
        Account objAccount = new Account();
        objAccount.Name = 'Addon Blue ';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.FirstName = 'Test data';
        objContact.LastName = 'Data';
        objContact.Email = 'addontest@addonblue.com';
        objContact.AccountId = objAccount.Id;
        insert objContact;

        PriceBook2 pbook = TestDataFactory.createPricebook(1,'Test PB '+ Utility.getRandomNumber().SubString(0,8))[0];
        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, objAccount.Id, objContact.Id, pbook.Id);
        PricebookEntry  pbEntry = TestDataFactory.createPricebookEntry();
        List<OpportunityLineItem> lstOppLineItem = TestDataFactory.createOpportunityLineItem(2,lstOpportunities[0].Id, pbEntry.Id);
        
        //Set<Id> setOpportunityId = UpdateOpportunityBatch.getOppID(lstOrder);
        Set<Id> setOpportunityId = new Set<Id>();
        for(Opportunity opp :lstOpportunities){
            setOpportunityId.add(opp.Id);
        }
        
        List<Quote> objQuote = TestDataFactory.createQuote(1,lstOpportunities[0].Id, lstOpportunities[0].Primary_Contact__c, lstOpportunities[0].Pricebook2Id,true);


        List<Order> lstOrder = new List<Order>();
        for(integer i= 0; i<2; i++){ 
            Order objOrder = new Order(
                AccountId = objAccount.Id,
                QuoteId = objQuote[0].Id,
                OpportunityId = lstOpportunities[0].Id,
                EffectiveDate = date.newInstance(2020, 3, 01),
                Status = 'Creation',
                Order_Payment_Status__c = 'Partially Paid',
                Pricebook2Id = pbook.Id,
                ShipToContactId = objContact.Id,
                BillToContactId = objContact.Id,
                Primary_Attendee_Contact__c = objContact.Id
            );
            lstOrder.add(objOrder);
        }
        insert lstOrder;

        
        UpdateOpportunityBatch.updateOpportunities(setOpportunityId);
        UpdateOpportunityBatch.getOppID(lstOrder);

        UpdateOpportunityBatch batch = new UpdateOpportunityBatch('2021');
        ID batchprocessid = Database.executeBatch(batch);
        Test.stopTest();
    }
}