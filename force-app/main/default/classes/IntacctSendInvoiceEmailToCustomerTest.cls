/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 01-28-2022
 * @last modified by  : ratiksinghal@addonblue.com
**/
@istest
public class IntacctSendInvoiceEmailToCustomerTest {
    
    public static testmethod void testOne(){
        TestDataFactory.createTriggerSettingsEntry();
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        IntacctSendInvoiceEmailToCustomer.getPaymentTerm(payTerm.id);
    }
    
    public static testmethod void testTwo(){
        TestDataFactory.createTriggerSettingsEntry();
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        blob b = blob.valueof('TEST');
        List<String> toMails = new List<String>{'testmail@gmail.com'};
        String Subject = 'Test Email'; 
        String Message = 'Message Body';
        List<String> ccTo  = new List<String>{'testmail@gmail.com'};
        IntacctSendInvoiceEmailToCustomer.sendEmail(payTerm, b, toMails, Subject, Message, ccTo);
    }
    
    public static testmethod void sendmail(){
        TestDataFactory.createTriggerSettingsEntry();
        Payment_Term__c payTerm = TestDataFactory.createPaymentTerm();
        
        IntacctSendInvoiceEmailToCustomer.processEmail('testmail@gmail.com', 'Email Subject', 'Email Message', 'testcc@gmail.com', payTerm.id);
    }
}