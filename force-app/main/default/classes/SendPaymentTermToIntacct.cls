/**
 * @File Name          : SendPaymentTermToIntacct.cls
 * @Description        : To send failed Payment Term to Intacct
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : ratiksinghal@addonblue.com
 * @Last Modified On   : 03-28-2022
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    05/06/2021  kchavda@addonblue.com     Initial Version
*/
public with sharing class SendPaymentTermToIntacct{

   /**
    * @description To send PaymentTerm to Intacct
    * @author kchavda@addonblue.com | SendPaymentTermToXero
    * @param PaymentId 
    * @return string
    **/    
    @Auraenabled
    public static string processPaymentTerm(Id PaymentId){ 
        List<Payment_Term__c> lstPaymentTerms = new List<Payment_Term__c>([Select id,Amount__c,Order__c,order__r.Intacct_Id__c,order__r.QuoteId,Intacct_Id__c,Intacct_Status__c  from Payment_Term__c where id =: PaymentId]);
        String displayMsg = '';
        if(!lstPaymentTerms.isempty()){
            if(lstPaymentTerms[0].order__r.Intacct_Id__c != null){
                if(lstPaymentTerms[0].Intacct_Status__c == 'Success' && lstPaymentTerms[0].Intacct_Id__c != null){
                    displayMsg = 'Payment Term is already sent to Intacct';
                }else{                
                     if(lstPaymentTerms[0].Amount__c == 0){
                         displayMsg = 'Payment Term with 0 amount cannot send to Intacct.';
                     }
                     else{
                         IntacctInvoiceSyncBatch batchId = new IntacctInvoiceSyncBatch(lstPaymentTerms[0].Order__c, String.valueOf(PaymentId), new list<String> {'Sales Invoice'});
                         Database.executebatch(batchId,1);
                     }
                }
            }
        }
        
        return displayMsg;
         
    }
}