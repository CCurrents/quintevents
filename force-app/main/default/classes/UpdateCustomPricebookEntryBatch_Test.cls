@isTest
public class UpdateCustomPricebookEntryBatch_Test {
    
     @isTest static void processCustomPriceBookEntryBatch() {
        Test.StartTest();
        
        TestDataFactory.createTriggerSettingsEntry();
        
        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        insert program;

        QE360_Event__c events = new QE360_Event__c();
        events.Name = 'Test Event';
        events.CurrencyIsoCode = 'USD';
        events.Program__c = program.Id;
        insert events;
        
        product2 product =new product2();
        Id recordTypeId = [Select Id,Name From RecordType Where sObjectType='Product2' and DeveloperName='Product'].Id;
        Product.RecordTypeId = recordTypeId;
        product.Name = 'Test Productss';
        product.Event__c = events.Id;
        product.Type__c = 'Hotel';
        product.CurrencyIsoCode = 'USD';
        product.Price__c = 120.00;
        product.A_La_Carte__c = true;
        product.isActive = true;
        insert product;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = product.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 10.00;
        pbe.IsActive = True;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;
        
        Price_Book_Entry_Custom__c cpbe = new Price_Book_Entry_Custom__c();
        cpbe.CurrencyIsoCode = pbe.CurrencyIsoCode;
        cpbe.Price_Book__c = pbe.Pricebook2Id;
        cpbe.Price_Book_Entry_Id__c = pbe.Id;
        cpbe.Product__c = pbe.Product2Id;
        insert cpbe;
       
        UpdateCustomPricebookEntryBatchSchedule sh1 = new UpdateCustomPricebookEntryBatchSchedule();
        UpdateCustomPricebookEntryBatchSchedule.processCustomPriceBookEntry();
        String sch = '0 0 23 * * ?'; 
        system.schedule('CustomPriceBookEntryUpdate', sch, sh1);
        
        Test.stopTest();
    }
}