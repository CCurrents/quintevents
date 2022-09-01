@isTest
public class SingleRelatedListController_Test {

    @testSetup static void setup() {
        Api_Image__c image = new Api_Image__c();
        image.Type__c = 'Photo';
        image.URL__c = 'www.google.com';
        image.RecordTypeId = '0121Y000000txNO';
        insert image;
        
        Program__c program = new Program__c();
        program.Name = 'test prgram F1E'; 
        insert program;

        QE360_Event__c event = new QE360_Event__c();
        event.Name = 'Test Event';
        event.CurrencyIsoCode = 'USD';
        event.Program__c = program.Id;
        insert event;
    }
    @isTest static void testMethodOne() {
        Test.startTest();
        List<Api_Image__c> image =[Select Id from Api_Image__c limit 1]; 
        List<QE360_Event__c> event=[Select Id from QE360_Event__c limit 1]; 
        SingleRelatedListController.initData(image[0].Id);
        SingleRelatedListController.getRecordType(event[0].Id);
        SingleRelatedListController.deleteRecord(image[0].Id,image[0].Id);
        Test.stopTest();
    }
    /*@isTest static void testMethodTwo() {
        QE360_Event__c event = [Select id from QE360_Event__c limit 1];
        product2 product =new product2();
        Product.RecordTypeId = '012i00000012AZt';
        product.Name = 'Test Product';
        product.Event__c = event.Id;
        product.Type__c = 'Hotels';
        product.CurrencyIsoCode = 'USD';
        product.Price__c = 120.00;
        product.A_La_Carte__c = true;
        product.isActive = true;
        insert product;

        SingleRelatedListController.getRecordType(product.Id);
    }*/
}