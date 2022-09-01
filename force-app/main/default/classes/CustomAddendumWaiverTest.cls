@isTest
public with sharing class CustomAddendumWaiverTest {
@TestSetup static void makeData(){
    TestDataFactory.createTriggerSettingsEntry();
}
     @isTest static void test1(){
         PriceBook2 objprice = TestDataFactory.createPricebook(); 
        objprice.Addendum_A_Waiver_AR__c = 'test';
        Utility.processRecords(objprice, 'update');
        Quote objQuote = TestDataFactory.createQuote();
        objQuote.Language__c = 'Arabic';
        objQuote.Pricebook2Id = objprice.id;
        Utility.processRecords(objQuote, 'update');
        CustomAddendumWaiver.processCustomAddendumWaiver(objQuote.id);
          System.assertEquals('test',objprice.Addendum_A_Waiver_AR__c);
     }
     @isTest static void test2(){
        PriceBook2 objprice = TestDataFactory.createPricebook(); 
        objprice.Addendum_A_Waiver_FR__c = 'test';
        Utility.processRecords(objprice, 'update');
        Quote objQuote = TestDataFactory.createQuote();
        objQuote.Language__c = 'French';
        objQuote.Pricebook2Id = objprice.id;
        Utility.processRecords(objQuote, 'update');
        CustomAddendumWaiver.processCustomAddendumWaiver(objQuote.id);
       System.assertEquals('test',objprice.Addendum_A_Waiver_FR__c);
    }
       @isTest static void test3(){
        PriceBook2 objprice = TestDataFactory.createPricebook(); 
        objprice.Addendum_A_Waiver_ES__c = 'test';
        Utility.processRecords(objprice, 'update');
        Quote objQuote = TestDataFactory.createQuote();
        objQuote.Language__c = 'Spanish';
        objQuote.Pricebook2Id = objprice.id;
        Utility.processRecords(objQuote, 'update');
        CustomAddendumWaiver.processCustomAddendumWaiver(objQuote.id);
          System.assertEquals('test',objprice.Addendum_A_Waiver_ES__c);
    }
        @isTest static void test4(){
        PriceBook2 objprice = TestDataFactory.createPricebook(); 
        objprice.Addendum_A_Waiver_ZH__c = 'test';
        Utility.processRecords(objprice, 'update');
        Quote objQuote = TestDataFactory.createQuote();
        objQuote.Language__c = 'Chinese';
        objQuote.Pricebook2Id = objprice.id;
        Utility.processRecords(objQuote, 'update');
        CustomAddendumWaiver.processCustomAddendumWaiver(objQuote.id);
         System.assertEquals('test',objprice.Addendum_A_Waiver_ZH__c);
    }
        @isTest static void test5(){
        PriceBook2 objprice = TestDataFactory.createPricebook(); 
        objprice.Addendum_A_Waiver_JA__c = 'test';
        Utility.processRecords(objprice, 'update');
        Quote objQuote = TestDataFactory.createQuote();
        objQuote.Language__c = 'Japanese';
        objQuote.Pricebook2Id = objprice.id;
        Utility.processRecords(objQuote, 'update');
        CustomAddendumWaiver.processCustomAddendumWaiver(objQuote.id);
         System.assertEquals('test',objprice.Addendum_A_Waiver_JA__c);
    }
     @isTest static void test6(){
        PriceBook2 objprice = TestDataFactory.createPricebook(); 
        objprice.Addendum_A_Waiver_DE__c = 'test';
        Utility.processRecords(objprice, 'update');
        Quote objQuote = TestDataFactory.createQuote();
        objQuote.Language__c = 'German';
        objQuote.Pricebook2Id = objprice.id;
        Utility.processRecords(objQuote, 'update');
        CustomAddendumWaiver.processCustomAddendumWaiver(objQuote.id);
        System.assertEquals('test',objprice.Addendum_A_Waiver_DE__c);
    }
       @isTest static void test7(){
        PriceBook2 objprice = TestDataFactory.createPricebook(); 
        objprice.Addendum_A_Waiver_IT__c = 'test';
        Utility.processRecords(objprice, 'update');
        Quote objQuote = TestDataFactory.createQuote();
        objQuote.Language__c = 'Italian';
        objQuote.Pricebook2Id = objprice.id;
        Utility.processRecords(objQuote, 'update');
        CustomAddendumWaiver.processCustomAddendumWaiver(objQuote.id);
        System.assertEquals('test',objprice.Addendum_A_Waiver_IT__c);
    }
      @isTest static void test8(){
        PriceBook2 objprice = TestDataFactory.createPricebook(); 
        objprice.Addendum_A_Waiver__c = 'test';
        Utility.processRecords(objprice, 'update');
        Quote objQuote = TestDataFactory.createQuote();
        objQuote.Language__c = 'English';
        objQuote.Pricebook2Id = objprice.id;
        Utility.processRecords(objQuote, 'update');
        CustomAddendumWaiver.processCustomAddendumWaiver(objQuote.id);
        System.assertEquals('test',objprice.Addendum_A_Waiver__c);
    }

}