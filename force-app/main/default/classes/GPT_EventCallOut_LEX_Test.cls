@IsTest
public class GPT_EventCallOut_LEX_Test{
    @testSetup static void setup() {
        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        insert program;
    
        QE360_Event__c events = new QE360_Event__c();
        events.Name = 'Test Event';
        events.CurrencyIsoCode = 'USD';
        events.Program__c = program.Id;
        events.GPE_Event__c = true;
        insert events;
    }
    @isTest static void testMethodOne() {
        QE360_Event__c events =[Select id from QE360_Event__c];
        Test.startTest();
         StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
         mock.setStaticResource('GPTJson');
         mock.setStatusCode(200);
         mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
         //QE_HttpMockCall httpmock = new QE_HttpMockCall();
         Test.setMock(HttpCalloutMock.class, mock);
         HttpResponse res = GPT_EventCallOut_LEX.httpCallOut('GET','https://www.gpt-worldwide.com/api/v1.1/gpe/en/event/3041/articles');

        /*PageReference pageRef = Page.QE_GPT_Article_Id;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',events.id);
        ApexPages.StandardController sc = new ApexPages.standardController(events);*/
        GPT_EventCallOut_LEX.eventObjCallOut(events.id);
        //GPT_EventCallOut_LEX.insertNewProduct(events.id);
        Test.stopTest();
    }
}