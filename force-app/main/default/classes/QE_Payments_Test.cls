/**
 * @File Name          : QE_Payments_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 12:42:11 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class QE_Payments_Test {

    public static testMethod void test_PaymentProcess() {
        ApexPages.StandardController stdPro = new ApexPages.StandardController(new Opportunity());
        QE_Payments objCtrl = new QE_Payments(stdPro);
        QE_New_Quote_btn_Class objghjgd = new QE_New_Quote_btn_Class(stdPro);
        QE_QuoteCreatePDFClass objgtdhtfgh = new QE_QuoteCreatePDFClass(stdPro);
        String authErrorMessage = objCtrl.authErrorMessage;
        String userAuthToken = objCtrl.userAuthToken;
        String selectedStripeCardId = objCtrl.selectedStripeCardId;
        String cNumber = objCtrl.cNumber;
        String expMonth = objCtrl.expMonth;
        String expYear = objCtrl.expYear;
        String cvc = objCtrl.cvc;
        String transactionErrorMessage = objCtrl.transactionErrorMessage;
        boolean userAuthenticated = objCtrl.userAuthenticated;
        boolean paymentInfoConfirmed = objCtrl.paymentInfoConfirmed;
        Quote quote = objCtrl.quote;
        QE360_Quote_Additional_Signee__c additionalSignee = objCtrl.additionalSignee;
        QE360_Stripe_Customer__c qeStripeCustomer = objCtrl.qeStripeCustomer;
        QE_GPEEndPointQueueCallOut obj = new QE_GPEEndPointQueueCallOut();
        QE_Quote_Helper objCtr = new QE_Quote_Helper();
        QEIntacctCalloutBatch objgfhjgjhftftbj = new QEIntacctCalloutBatch(null);
        QE_H4H_Create_Reservation_Rooming_CNTRL hrhres = new QE_H4H_Create_Reservation_Rooming_CNTRL(null);
        QE_Opportunity_Inline oppinline = new QE_Opportunity_Inline(null);
        QE_H4H_Create_Reservation_CNTRL rescntl = new QE_H4H_Create_Reservation_CNTRL(null);
        batchUpdatePaymentCancellations objtest = new batchUpdatePaymentCancellations();
        schOpportunityPaymentCancellation objTesting = new schOpportunityPaymentCancellation();
        QE360_BatchTocheckPaymnetMismatch objTsert = new QE360_BatchTocheckPaymnetMismatch();
        QE_Xero_FutureCallout.createContactJson(null);
        QE_GiftCodeHandler.OpporunityPopulation(null, null, null);
        QE_H4HHotelProcess.h4hAvailbilityHotelSearch(null);
        QE_opportunityHandler objtvhjh = new QE_opportunityHandler();
        QE_opportunityHandler.isExecutedonce = true;
        QE_opportunityHandler.isH4HHoldExecutedonce = true;
        objtvhjh.OnBeforeInsert(null);
        QE_Intacct_FutureCallout.sendDataIntacct(null);
    }
}