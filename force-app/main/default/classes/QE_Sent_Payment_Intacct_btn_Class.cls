public class QE_Sent_Payment_Intacct_btn_Class{
public Id pay_ID;
public boolean displayPopup {get;set;}
public String displayMsg {get;set;}
public Payment_term__c payRec {get;set;}
public QE_Sent_Payment_Intacct_btn_Class(ApexPages.StandardController stdController)
{
//RedirectMethod();
}
   public pageReference closePopup()
   {
       displayPopup=false;
       pageReference ref=new pageReference('/'+pay_ID);
       ref.setRedirect(true);
       return ref;
   }
   public pageReference RedirectMethod()
   {
        
        pay_ID = ApexPages.currentPage().getParameters().get('payId');
        system.debug('Payment ID' +pay_ID);
        //if(pay_ID != null)
        payRec = [SELECT Id, Name,Intacct_Status__c,Sandbox_Intacct_Status__c,Status__c,Record_Id__c,Intacct_Id__c,Intacct_Failure_Reason__c,Opportunity__r.Event__r.GPE_Event__c FROM Payment_term__c WHERE Id =: pay_ID];
        System.debug('---payRec-----'+payRec);
        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        if(payRec.Opportunity__r.Event__r.GPE_Event__c == false){
            if(payRec.get(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c') == 'Success'){
                displayPopup=true;
                displayMsg = 'The Payment already sent to Intacct';
                return null;
            }else if(payRec.Status__c == 'Passed'){
                if(Test.isRunningTest()){
                     cs.Active__c = true;
                }
                if( cs.Active__c == true) {
                    /*payRec.Intacct_Status__c = null;
                    payRec.Intacct_Failure_Reason__c = null;*/
                    payRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c' , '');
                    payRec.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c' , '');
                    update payRec;
                    if(!Test.isRunningTest()){
                        QE_Intacct_FutureCallout.paymentUpdateIntacct(payRec.Id);
                    }
                }
                pageReference ref=new pageReference('/'+payRec.Id);
                ref.setRedirect(true);
                return ref;
            }else{
                displayPopup=true;
                displayMsg = 'Can not send the Payment to Intacct the Payment Term is not Passed ';
                return null;
            }
        }
        else{
            pageReference ref=new pageReference('/'+payRec.Id);
                ref.setRedirect(true);
                return ref;
        }
   }
}