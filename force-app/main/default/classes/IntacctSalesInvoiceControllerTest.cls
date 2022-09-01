/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 01-28-2022
 * @last modified by  : ratiksinghal@addonblue.com
**/

@istest
public class IntacctSalesInvoiceControllerTest {
    
    public static testmethod void testConsturctor(){ 
        TestDataFactory.createTriggerSettingsEntry();
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        ApexPages.StandardController sc = new ApexPages.StandardController(payTerm);  
        ApexPages.currentPage().getParameters().put('id',payTerm.Id);
        IntacctSalesInvoiceController invoiceController = new IntacctSalesInvoiceController(sc);
    }
}