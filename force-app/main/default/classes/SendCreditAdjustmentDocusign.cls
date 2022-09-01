/**
 * @File Name          : SendCreditAdjustmentDocusign.cls
 * @Description        : To send Credit Adjustment Envelope docusign
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 05/29/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    05/29/2020  kchavda@addonblue.com     Initial Version
 * 1.1    09/01/2020  kchavda@addonblue.com     #378 Addendum Automation changes for v3
 * 1.2    02/11/2021  kchavda@addonblue.com     #716 Currently we use wording "2021 Event" for credit creation, need to be replaced with "Future Event".
**/
Public class SendCreditAdjustmentDocusign{
    public string streventId{get;set;}    
    public List<clsopps> lstopportunities{get;set;}
    public string strOppIds{get;set;}
    public string strOwnerId{get;set;} 
    public Integer totalrecords{get;set;} 
       
    public ApexPages.StandardSetController opps{ 
        get {
            if(opps == null) {                
                opps = New ApexPages.StandardSetController(Database.getQueryLocator(''));
            }            
            return opps;
        }
        set;
    }
    
    public SendCreditAdjustmentDocusign(){     
        totalrecords = 0;    
        lstopportunities = new List<clsopps>();           
    }
    
    public void fillOpportunityList(){  
        set<string> oppIds = new set<string>();
        if(strOppIds != null && strOppIds != ''){
            oppIds.addall(strOppIds.split(','));
        }          
        Set<Id> setparentOppId = new set<Id>();
        Set<Id> moreparentOppIds = new set<Id>();
        for(Attachment att: [select Id, parentId from attachment where name in ('Confirm Refund.pdf','Apply Credit to New Date in 2020.pdf','Apply Credit to the Future Event.pdf') ]){
            if(att.parentId != null && String.valueof(att.parentId).startswith('006'))
                setparentOppId.add(att.parentId);
        }
        
        for(aggregateresult ar: [select count(Id), parentId parId from attachment where parentid in : setparentOppId and parentid not in (select dsfs__Opportunity__c from dsfs__DocuSign_Status__c where dsfs__Subject__c in ('Reimbursement Addendum', 'Move to Reschedule Dates Addendum', 'Transfer to Future Event Addendum')) group by parentId having count(id)>1]){
            moreparentOppIds.add((ID)ar.get('parId'));
        }
        //string strquery = 'Select id,primary_contact__c,Email__c,Name,Account.OwnerId,Account.Owner.Name,Primary_Contact__r.Name,Pricebook2.Start_Date__c,DocuSign_Recipient__c,Refund_Response__c from opportunity where Refund_Response__c != null and Send_To_Docusign__c = false and id not in (select dsfs__Opportunity__c from dsfs__DocuSign_Status__c where dsfs__Subject__c in (\'Reimbursement Addendum\', \'Move to Reschedule Dates Addendum\', \'Transfer to Future Event Addendum\')) and ((Refund_Response__c = \'Confirm Refund\' and Refund_Amount__c != null and Refund_Amount__c != \'Not Applicable\') or (Refund_Response__c = \'Apply Credit to New Date in 2020\' and ((Event__r.Program__r.Name = \'F1E\' and Collected_Revenue__c != null) or Event__r.Program__r.Name != \'F1E\')) or (Refund_Response__c = \'Apply Credit* to the Future Event\' and Credit_Amount__c != null and Credit_Amount__c != \'Not Applicable\')) and id in: setparentOppId and id not in: moreparentOppIds ';
        string strquery = 'Select id,primary_contact__c,Email__c,Name,Account.OwnerId,Account.Owner.Name,Primary_Contact__r.Name,Pricebook2.Start_Date__c,DocuSign_Recipient__c,Refund_Response__c from opportunity where Refund_Response__c != null and Send_To_Docusign__c = false and id not in (select dsfs__Opportunity__c from dsfs__DocuSign_Status__c where dsfs__Subject__c in (\'Reimbursement Addendum\', \'Move to Reschedule Dates Addendum\', \'Transfer to Future Event Addendum\')) and ((Refund_Response__c = \'Confirm Refund\' and Refund_Amount__c != null and Refund_Amount__c != \'Not Applicable\') or (Refund_Response__c = \'Apply Credit to New Date in 2020\' and (((Event__r.Program__r.Name = \'F1E\' or (Event__c = null and Pricebook2.Program__r.Name = \'F1E\')) and Collected_Revenue__c != null) or (Event__r.Program__r.Name != \'F1E\' or (Event__c = null and Pricebook2.Program__r.Name != \'F1E\')))) or (Refund_Response__c = \'Apply Credit* to the Future Event\' and Credit_Amount__c != null and Credit_Amount__c != \'Not Applicable\')) and id in: setparentOppId and id not in: moreparentOppIds';
        if(!string.isblank(streventId)){
            set<string> EventIds = new set<string>();
            EventIds.addall(streventId.split(',')); 
            if(streventId.startswith('a0b')){
                strquery += ' and Event__c IN: EventIds';                 
            }
            else if(streventId.startswith('01s')){
                strquery += ' and pricebook2Id IN: EventIds'; 
            }
           
        } 
        if(!string.isblank(strOwnerId)){
           strquery += ' and account.ownerid =: strOwnerId'; 
        }        
        if(oppIds.size()>0){
            system.debug('###strquery =='+strquery );
            strquery += ' and id in :oppIds';
        }        
        opps = new ApexPages.StandardSetController(Database.getQueryLocator(strquery));
        totalrecords = Database.countQuery('select count() from opportunity where '+strquery.split('opportunity where')[1]);
        
        opps.setPageSize(50);
        
   }
       
    Public void displayoppList(){
        lstopportunities = new List<clsopps>();
        system.debug('###opps=='+opps.getRecords()); 
        for (opportunity opp: (List<opportunity>)opps.getRecords()){
            clsopps objclsopps = new clsopps();
            objclsopps.objopp = opp;
            objclsopps.blnsend = false;
            lstopportunities.Add(objclsopps);
        }
        system.debug('###lstopportunities=='+lstopportunities);
    }
    
     Public void filloppList(){
        fillOpportunityList();
        displayoppList();
    }
    // create and send with docuSign    
    public pagereference createandSendWithDocuSign() {
          
         string opId = ApexPages.currentPage().getParameters().get('oppId'); 
         
         if(opId != null){ 
             List<opportunity> lstopp = new List<opportunity>([select id,Primary_Contact__r.Name,Refund_Response__c,CreatedDate,DocuSign_Recipient__c,Event__c,Pricebook2id,Send_To_Docusign__c,(Select id,BillingName,Email,OpportunityId,IsSyncing from quotes), (select id,Contact.Name,Contact.Email from opportunitycontactroles where role ='Signee Contact' limit 1) from opportunity where id=: opId]); 
             List<Pricebook2> lstpb = new List<Pricebook2>(); 
             if(lstopp[0].Event__c != null) lstpb = [select id,Move_to_2020_Addendum_Envelope_Message__c,Refund_Addendum_Envelope_Message__c,Move_to_2021_Addendum_Envelope_Message__c from Pricebook2 where Legacy_Id__c =: lstopp[0].Event__c];
             else if(lstopp[0].Pricebook2id != null) lstpb  = [select id,Move_to_2020_Addendum_Envelope_Message__c,Refund_Addendum_Envelope_Message__c,Move_to_2021_Addendum_Envelope_Message__c from Pricebook2 where Id =: lstopp[0].Pricebook2id];  
                                      
             Quote qute = new Quote();
             Date dt = date.newInstance(2020,05,10);
             OpportunityContactRole ocr = new OpportunityContactRole();
             if(lstopp.size()>0){                               
                 if(!lstopp[0].Quotes.isempty()){                     
                     if(lstopp[0].Quotes.size() == 1 && lstopp[0].CreatedDate.date()<=dt) qute = lstopp[0].Quotes[0];
                     else{
                        if(!lstopp[0].opportunitycontactroles.isempty()){
                            ocr = lstopp[0].opportunitycontactroles[0];
                        }
                     }
                 }
             }
             
              Integer expireinNdays = (system.today()).daysBetween(system.today().adddays(30));
                
             // Reminder and Expiration Settings
             string dsRes = '0,0,0,1,'+expireinNdays+',0';
             string headerdata= ApexPages.currentPage().getHeaders().get('Host');
              
            //SEM
            // Recipient name
            String recipientName = '';
            if(lstopp[0].CreatedDate.date()<=dt) recipientName = lstopp[0].Primary_Contact__r.Name != null ? lstopp[0].Primary_Contact__r.Name : (qute.BillingName != null ? qute.BillingName :'');
            else recipientName = (!lstopp[0].opportunitycontactroles.isempty() ? lstopp[0].opportunitycontactroles[0].Contact.Name:'');
            
            // Main Recipient
            string mainDsCrl = '';
            if(lstopp[0].CreatedDate.date()<=dt) mainDsCrl = 'Email~'+(lstopp[0].DocuSign_Recipient__c != null ? lstopp[0].DocuSign_Recipient__c : qute.Email)+';LastName~'+recipientName+';RoutingOrder~1';                 
            else mainDsCrl = 'Email~'+(lstopp[0].DocuSign_Recipient__c != null ? lstopp[0].DocuSign_Recipient__c : (ocr.Contact.Email != null ? ocr.Contact.Email: ''))+';LastName~'+recipientName+';RoutingOrder~1';                 
            String[] stringList = new String[0];
            // adding main recipent to list
            stringList.add(mainDsCrl); 
            //check for existing envolope records        
            String dsCrl = String.join(stringList, ',');
            String strCEM = '';
            if(lstpb.size()>0 ){
                if(lstopp[0].Refund_Response__c == 'Confirm Refund') strCEM = lstpb[0].Refund_Addendum_Envelope_Message__c;
                else if(lstopp[0].Refund_Response__c == 'Apply Credit to New Date in 2020') strCEM = lstpb[0].Move_to_2020_Addendum_Envelope_Message__c;
                else if(lstopp[0].Refund_Response__c == 'Apply Credit* to the Future Event') strCEM = lstpb[0].Move_to_2021_Addendum_Envelope_Message__c;
            }
            //For custom Email Subject
            string strCES= '';
            if(lstopp[0].Refund_Response__c == 'Confirm Refund') strCES = system.label.DSConfirmRefundES;
            else if(lstopp[0].Refund_Response__c == 'Apply Credit to New Date in 2020') strCES = system.label.DSMove2020ES;
            else if(lstopp[0].Refund_Response__c == 'Apply Credit* to the Future Event') strCES = system.label.DSMove2021ES;
            
            PageReference page = new PageReference('/apex/dsfs__DocuSign_CreateEnvelope');
            page.getParameters().put('DSEID','0');
            page.getParameters().put('SourceID', lstopp[0].Id);                
            page.getParameters().put('RES', dsRes);
            if(strCEM != ''){
                page.getParameters().put('CEM', strCEM);
            }
            if(strCES != ''){
                page.getParameters().put('CES', strCES);
            }
            page.getParameters().put('CRL', dsCrl);
            page.getParameters().put('OCO', 'Send');              
            page.setRedirect(true);               
            lstopp[0].Send_To_Docusign__c = true;
            update lstopp[0];           
            return page;              
           
         }
         return null;
    }
   
    //Boolean to check if there are more records after the present displaying records
    public Boolean hasNext{
        get{           
            return opps.getHasNext();
        }
        set;
    }
    //Boolean to check if there are more records before the present displaying records
    public Boolean hasPrevious{
        get{
            return opps.getHasPrevious();
        }
        set;
    }
    
    //Returns the next page of records
    public void next(){         
        opps.next();              
        displayoppList();        
    }
    //Returns the previous page of records
    public void previous(){       
        opps.previous();        
        displayoppList();
    }
    
   
    public class clsopps{
        public opportunity objopp{get;set;}
        Public boolean blnsend{get;set;}
        
        public clsopps(){
            objopp = new opportunity();
            blnsend = false;
        }
    }
}