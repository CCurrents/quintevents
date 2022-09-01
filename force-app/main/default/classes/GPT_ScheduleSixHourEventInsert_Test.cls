@isTest
Private with sharing class GPT_ScheduleSixHourEventInsert_Test {
   @testSetup static void setup() {

        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        insert program;

        QE360_Event__c events = new QE360_Event__c();
        events.Name = 'Test Event';
        events.CurrencyIsoCode = 'USD';
        events.Program__c = program.Id;
        events.GPT_Event_Id__c = '37473';
        events.GPT_Price_Markup_Percentage__c = 10;
        events.GPE_Event__c = true;
        insert events;

        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = events.Id;
        insert parentPackage;

        product2 product =new product2();
        Product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();
        product.Name = 'Test Product1';
        product.Event__c = events.Id;
        product.Type__c = 'Hotels';
        product.CurrencyIsoCode = 'USD';
        product.Price__c = 1230.00;
        product.A_La_Carte__c = true;
        product.isActive = true;
        product.Parent_Package__c = parentPackage.Id;
        product.GPT_Article_Id__c = '89073';
        product.GPT_Gross_Price__c = 8736;
        insert product;
    }
    @isTest static void testMethodOne() {
        QE360_Event__c events = [Select id,GPT_Event_Id__c from QE360_Event__c limit 1];
        List<Product2> productList = [Select id from Product2];
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GPTJson');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Set<String> EventSet = new Set<String>();
        EventSet.add(events.GPT_Event_Id__c);
        GPT_ScheduleSixHourEventInsert sh1 = new GPT_ScheduleSixHourEventInsert();
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Check', sch, sh1);
        Test.setMock(HttpCalloutMock.class, mock);
        GPT_CreateEventSixHourlyQueueableClass queueClass = new GPT_CreateEventSixHourlyQueueableClass(EventSet);
        System.enqueueJob(queueClass);
        GPT_CreateEventSixHourlyQueueableClass queueableClass = new GPT_CreateEventSixHourlyQueueableClass(productList, productList);
        System.enqueueJob(queueClass);
    }
}