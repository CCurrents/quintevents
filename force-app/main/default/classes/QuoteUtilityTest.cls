@isTest
public class QuoteUtilityTest {
 @TestSetup
    static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();	
    }
     @isTest static void test1(){
         Quote qobj = TestDataFactory.createQuote();
         qobj.Status = 'Draft - Needs Review';
          Utility.processRecords(qobj, 'update');
         List<Quote> quotelist = new List<Quote>();
         quotelist.add(qobj);
         Test.startTest();
         QuoteUtility.quoteApprovalHandling(quotelist);
         Test.stopTest();
     }
      @isTest static void test3(){
         Quote qobj = TestDataFactory.createQuote();
         qobj.Status = 'Signed - Needs Review';
          Utility.processRecords(qobj, 'update');
          Map<id,Quote> mapquo = new Map<id,Quote>();
          mapquo.put(qobj.id, qobj);
         List<Quote> quotelist = new List<Quote>();
         quotelist.add(qobj);
         Test.startTest();
         QuoteUtility.quoteSignedApprovalHandling(quotelist,mapquo);
         Test.stopTest();
     }
        @isTest static void test2(){
            QuoteLineItem qli = TestDataFactory.createQuoteLineItem();
           Quote obj = [select id from Quote where id =: qli.QuoteId];
             obj.Status = 'Draft - Needs Review';
          Utility.processRecords(obj, 'update');
            Product2 probj = [select id from Product2 where id =: qli.Product2ID ];
            probj.IsActive =false;
            probj.Requires_Approval_Upon_Signature__c = true;
            probj.Requires_Double_Approval__c = true;
            Utility.processRecords(probj, 'update');
            System.debug('product--'+probj);
            List<Id> lstis = new List<Id>();
            lstis.add(obj.id);
         Test.startTest();
         QuoteUtility.updateQuoteStatusDocuSign(lstis,'test');
         Test.stopTest();
     }
}