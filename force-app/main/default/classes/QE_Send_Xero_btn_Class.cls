public class QE_Send_Xero_btn_Class{
    public Id opp_ID;
    public boolean displayPopup {get;set;}
    public String displayMsg {get;set;}
    public Opportunity oppRec {get;set;}
    
    public QE_Send_Xero_btn_Class(ApexPages.StandardController stdController){    
    
    }
    public pageReference closePopup(){   
       displayPopup=false;
       pageReference ref=new pageReference('/'+opp_ID);
       ref.setRedirect(true);
       return ref;
    }
    public pageReference RedirectMethod(){            
        opp_ID = ApexPages.currentPage().getParameters().get('Oppid');
                
        oppRec = [SELECT Id, Name,Xero_Contact_Status__c,Xero_Invoice_Status__c, Xero_Failure_Reason__c,Xero_Reference_No__c,IsClosed,StageName,Event__r.GPE_Event__c FROM Opportunity WHERE Id =: opp_ID];
        
        if(oppRec.Event__r.GPE_Event__c == true){
            if(oppRec.Xero_Contact_Status__c == 'Success' && oppRec.Xero_Invoice_Status__c == 'Success'){
                displayPopup=true;
                displayMsg = 'The Sales Order already sent to Xero';
                return null;           
            }
            else if(oppRec.StageName == 'Closed Won'){                
                oppRec.Xero_Failure_Reason__c = null;
                oppRec.Xero_Contact_Status__c = null;
                oppRec.Xero_Invoice_Status__c = null;
                update oppRec;
                QE_Xero_FutureCallout.createContactJson(oppRec.Id);                
               
                pageReference ref=new pageReference('/'+oppRec.Id);
                ref.setRedirect(true);
                return ref;
            }
            else{
                displayPopup=true;
                displayMsg = 'Can not send the Sales Order to Xero the Opportuntiy is not Closed Won ';
                return null;
            }
        }
        else{
            pageReference ref=new pageReference('/'+oppRec.Id);
                ref.setRedirect(true);
                return ref;
        }
        
   }
}