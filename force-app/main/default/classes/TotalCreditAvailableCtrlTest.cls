@isTest
public class TotalCreditAvailableCtrlTest {
    
    @isTest static void test1(){
        TestDataFactory.createTriggerSettingsEntry();
        Quote objQuote = TestDataFactory.createQuote();
        TotalCreditAvailableController.getTotalCreditFromAccount(objQuote.Id);
    }
    @isTest static void test2(){
        TestDataFactory.createTriggerSettingsEntry();
        Quote objQuote = TestDataFactory.createQuote();
        delete objQuote;
        try{
            TotalCreditAvailableController.getTotalCreditFromAccount(objQuote.Id);
        }
        catch(Exception e){
        }
    }
}