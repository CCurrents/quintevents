public class QE_Sent_Intacct_btn_Class{
public Id opp_ID;
public boolean displayPopup {get;set;}
public String displayMsg {get;set;}
public Opportunity oppRec {get;set;}
public QE_Sent_Intacct_btn_Class(ApexPages.StandardController stdController)
{
//RedirectMethod();
}
   public pageReference closePopup()
   {
       displayPopup=false;
       pageReference ref=new pageReference('/'+opp_ID);
       ref.setRedirect(true);
       return ref;
   }
   public pageReference RedirectMethod()
   {
        
        opp_ID = ApexPages.currentPage().getParameters().get('Oppid');
        //system.debug('opportunity ID' +opp_ID);
        //if(opp_ID != null)
        oppRec = [SELECT Id, Name,Intacct_Status__c,Sandbox_Intacct_Status__c, Intacct_Apex_Error__c,IsClosed,StageName,Event__r.GPE_Event__c,Event__r.Name,Refund_Reconciliation__c FROM Opportunity WHERE Id =: opp_ID];
        //System.debug('---oppRec-----'+oppRec);
        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        if(oppRec.Event__r.GPE_Event__c == false && oppRec.Event__r.Name != 'H4H CUG Hotels' && oppRec.Refund_Reconciliation__c == false){
            if(oppRec.get(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c') == 'Success'){
                displayPopup=true;
                displayMsg = 'The Sales Order already sent to Intacct';
                return null;           
            }else if(oppRec.StageName == 'Closed Won'){
                if(Test.isRunningTest()){
                     cs.Active__c = true;
                }
                if( cs.Active__c == true) {
                    /*oppRec.Intacct_Status__c = null;
                    oppRec.Intacct_Apex_Error__c = null;*/
                    oppRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', null);
                    oppRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', null);
                    update oppRec;
                    if(!Test.isRunningTest()){
                        QE_Intacct_FutureCallout.sendDataIntacct(oppRec.Id);
                    }
                }
                pageReference ref=new pageReference('/'+oppRec.Id);
                ref.setRedirect(true);
                return ref;
            }else{
                displayPopup=true;
                displayMsg = 'Can not send the Sales Order to Intacct the Opportuntiy is not Closed Won ';
                return null;
            }
        }
        else{
            pageReference ref=new pageReference('/'+oppRec.Id);
                ref.setRedirect(true);
                return ref;
        }
        //return null;
   }
}