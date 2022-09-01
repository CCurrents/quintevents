Public class SendCreditAddendumOpportunity{
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
    
    public SendCreditAddendumOpportunity(){         
        lstopportunities = new List<clsopps>();    
    }
    
    public void fillOpportunityList(){
        system.debug('###streventId =='+streventId );
        system.debug('###strOppIds  =='+strOppIds );
        set<string> oppIds = new set<string>();
        if(strOppIds != null && strOppIds != ''){
            oppIds.addall(strOppIds.split(','));
        }
        if(streventId != null){
            string strquery = 'Select id,primary_contact__c,Email__c,Name,Primary_Contact__r.Name,Pricebook2.Start_Date__c,DocuSign_Recipient__c from opportunity where Send_To_Docusign__c = false';
            if(!string.isblank(strOwnerId)){
               strquery += ' and account.ownerid =: strOwnerId'; 
            }
            if(oppIds.size()>0){
                system.debug('###strquery =='+strquery );
                strquery += ' and id in :oppIds';
            }
            opps = new ApexPages.StandardSetController(Database.getQueryLocator(strquery));
            totalrecords = Database.countQuery('select count() from opportunity where '+strquery.split('where')[1]);
        }
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
             List<opportunity> lstopp = new List<opportunity>([select id,Primary_Contact__r.Name,DocuSign_Recipient__c,Event__c,Send_To_Docusign__c,Refund_Response__c, (Select id,BillingName,Email,OpportunityId from quotes) from opportunity where id=: opId]); 
             List<Pricebook2> lstpb = new List<Pricebook2>([select id,Move_to_2020_Addendum_Envelope_Message__c,Move_to_2021_Addendum_Envelope_Message__c,Refund_Addendum_Envelope_Message__c from Pricebook2 where Legacy_Id__c =: lstopp[0].Event__c ]);        
             //Integer expireinNdays = (system.today()).daysBetween(Date.valueOf(system.label.DSExpiredEnvelopeNDays));
             Integer expireinNdays = (system.today()).daysBetween(system.today().adddays(30));
                
             // Reminder and Expiration Settings
             string dsRes = '0,0,0,1,'+expireinNdays+',0';
             string headerdata= ApexPages.currentPage().getHeaders().get('Host');
              
                //SEM
                // Recipient name
                String recipientName = lstopp[0].Primary_Contact__r.Name == null ? lstopp[0].Quotes[0].BillingName : lstopp[0].Primary_Contact__r.Name;
                // Main Recipient
                string mainDsCrl = 'Email~'+(lstopp[0].DocuSign_Recipient__c != null ? lstopp[0].DocuSign_Recipient__c : lstopp[0].Quotes[0].Email)+';LastName~'+recipientName+';RoutingOrder~1';                 
                String[] stringList = new String[0];
                // adding main recipent to list
                stringList.add(mainDsCrl); 
                //check for existing envolope records        
                String dsCrl = String.join(stringList, ',');
                String strCEM = '';
                if(lstpb.size()>0){                    
                    if(lstopp[0].Refund_Response__c == 'Confirm Refund') strCEM = lstpb[0].Refund_Addendum_Envelope_Message__c;
                    else if(lstopp[0].Refund_Response__c == 'Apply Credit to New Date in 2020') strCEM = lstpb[0].Move_to_2020_Addendum_Envelope_Message__c;
                    else if(lstopp[0].Refund_Response__c == 'Apply Credit* to the 2021 Event') strCEM = lstpb[0].Move_to_2021_Addendum_Envelope_Message__c;
                }
                //For custom Email Subject
                string strCES= '';
                if(lstopp[0].Refund_Response__c == 'Confirm Refund') strCES = system.label.DSConfirmRefundES;
                else if(lstopp[0].Refund_Response__c == 'Apply Credit to New Date in 2020') strCES = system.label.DSMove2020ES;
                else if(lstopp[0].Refund_Response__c == 'Apply Credit* to the 2021 Event') strCES = system.label.DSMove2021ES;

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