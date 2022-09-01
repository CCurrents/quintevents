/**
 * @File Name          : Order_Sent_Intacct_btn_Class_Test.cls
 * @Description        : 
 * @Author             : Lovel Panchal
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/9/2020, 3:16:46 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    5/9/2020   Lovel Panchal     Initial Version
**/
@isTest public class Order_Sent_Intacct_btn_Class_Test {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    @isTest static void test1(){       
       Test.setCurrentPageReference(new PageReference('Page.Order_Sent_Intacct_btn')); 
       test.startTest();
       Payment_Term__c objPT = TestDataFactory.createPaymentTerm();
    
       Order objorder = [Select Id,AccountId,status,QuoteId from Order where Id =: objPT.Order__c];
       Quote objquote = [Select id,OpportunityId from Quote where Id =:objOrder.QuoteId];
       QuoteLineItem QLI = TestDataFactory.createQuoteLineItem(1,objquote.id,true)[0];
       orderItem item = TestDataFactory.createOrderItem(1,objorder.id,QLI)[0];      
       System.currentPageReference().getParameters().put('Orderid', objorder.Id);
       ApexPages.StandardController stdController;
       Order_Sent_Intacct_btn_Class cls = new Order_Sent_Intacct_btn_Class(stdController);
       cls.displayMsg = 'Testdsmg';
       cls.oppRec = null;
       cls.RedirectMethod();
       cls.closePopup();
       test.stoptest();
    }
    
     @isTest static void test2(){       
       Test.setCurrentPageReference(new PageReference('Page.Order_Sent_Intacct_btn')); 
       test.startTest();       
       System.currentPageReference().getParameters().put('Orderid', TestDataFactory.createOrder().Id);
       ApexPages.StandardController stdController;
       Order_Sent_Intacct_btn_Class cls = new Order_Sent_Intacct_btn_Class(stdController);
       cls.displayMsg = 'Testdsmg';
       cls.oppRec = null;
       cls.RedirectMethod();
       cls.closePopup();
       test.stoptest();
    }
    
     @isTest static void test3(){       
       Test.setCurrentPageReference(new PageReference('Page.Order_Sent_Intacct_btn')); 
       test.startTest();       
       Order od = TestDataFactory.createOrder();
       od.Intacct_id__c = 'Sales order-35465765';
       update od;
       System.currentPageReference().getParameters().put('Orderid', od.Id);
       ApexPages.StandardController stdController;
       Order_Sent_Intacct_btn_Class cls = new Order_Sent_Intacct_btn_Class(stdController);
       cls.displayMsg = 'Testdsmg';
       cls.oppRec = null;
       cls.RedirectMethod();
       cls.closePopup();
       test.stoptest();
    }
}