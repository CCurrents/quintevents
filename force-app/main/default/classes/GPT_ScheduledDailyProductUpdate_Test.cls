@isTest
private class GPT_ScheduledDailyProductUpdate_Test {
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
        product.Name = 'Test Product1eeee1';
        product.Event__c = events.Id;
        product.Type__c = 'Hotels';
        product.CurrencyIsoCode = 'USD';
        product.Price__c = 1230.00;
        product.A_La_Carte__c = true;
        product.isActive = true;
        product.Parent_Package__c = parentPackage.Id;
        product.GPT_Article_Id__c = '890473';
        product.GPT_Gross_Price__c = 8736;
        insert product;
    }
    @isTest static void testMethodOne() {
        QE360_Event__c events = [Select id from QE360_Event__c limit 1];
        product2 product = [Select Id,Name,GPT_Article_Id__c,Event__r.GPT_Event_Id__c,Event__r.GPT_Price_Markup_Percentage__c,GPT_Gross_Price__c,Price__c from Product2 limit 1];
        Map<String, Product2> proMap = new Map<String, Product2>();
        proMap.put('89073', product);

        GPT_ScheduledDailyProductUpdate sh1 = new GPT_ScheduledDailyProductUpdate();
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Check', sch, sh1);
        
        GPT_ProductUpdateBatchClass batch = new GPT_ProductUpdateBatchClass(proMap);
        ID batchprocessid = Database.executeBatch(batch);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GPTJson');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        GPT_ScheduledHourlyNewProductInsert scheduleClass= new GPT_ScheduledHourlyNewProductInsert();
        String cron_Job = '0 0 23 * * ?'; 
        System.schedule('Test Check1', cron_Job , scheduleClass);
        Test.setMock(HttpCalloutMock.class, mock);
        
        Set<Id> EventSet = new Set<Id>();
        EventSet.add(events.Id);
        string strquery = 'Select Id,GPT_Event_Id__c,GPT_Price_Markup_Percentage__c from QE360_Event__c where GPT_Event_Id__c != null and GPE_Event__c= true';
        GPT_HourlyNewProductInsertBatchClass batch1 = new GPT_HourlyNewProductInsertBatchClass(strquery);
        ID batchprocessid1 = Database.executeBatch(batch1);
    }
}