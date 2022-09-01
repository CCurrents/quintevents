@isTest (seeAllData=false)
public class QE_UpdatePricebookEntryBatchTest
{
    static testMethod void testMthd()
    {    Test.StartTest();
        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        insert program;

        QE360_Event__c events = new QE360_Event__c();
        events.Name = 'Test Event';
        events.CurrencyIsoCode = 'USD';
        events.Program__c = program.Id;
        insert events;

        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = events.Id;
        insert parentPackage;

        product2 product =new product2();
        Product.RecordTypeId = '012i00000012AZt';
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
            
        
        String pricebookEntryList;    
        pricebookEntryList = 'select id,UnitPrice,Product2Id,Product2.Price__c,CurrencyIsoCode from PricebookEntry';
        Map<string,double>  isoCodeMap = new Map<string,double>();
        Set<String> code = new Set<String>();
        isoCodeMap.put('USD', 0.15);
        code.add('USD');
        QE_UpdatePricebookEntryBatch newTopicsUpdate = new QE_UpdatePricebookEntryBatch(pricebookEntryList, isoCodeMap, code);
        ID batchprocessid = Database.executeBatch(newTopicsUpdate);
        Test.StopTest();
    }
}