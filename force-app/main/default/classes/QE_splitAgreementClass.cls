public class QE_splitAgreementClass{

    public Id OpportunityId {get;set;}
    public Id PersonRecordTypeId {get;set;}
    public Id OppAccountID {get;set;}
    public List<wrapperClass> displayContactList{get;set;}
    public List<Contact> contactList {get;set;}
    public List<Opportunity> lstOpportunity {get;set;}
    public List<QE360_Opportunity_Additional_Signee__c> selectedSigneeList{get;set;}
    public Map<Id,Contact> contactMap {get;set;}
    public List<Contact> selectedContactList {get;set;}    
    public QE360_Opportunity_Additional_Signee__c newSignee{get;set;}
    public Map<Id,QE360_Opportunity_Additional_Signee__c> currentSignee{get;set;}
    public boolean proCheck {get;set;}
    public boolean bussOpp {get;set;}
    public List<QE360_Opportunity_Additional_Signee__c> newSigneeList = new List<QE360_Opportunity_Additional_Signee__c>();
    public List<Contact> contactListDel = new List<Contact>();
    
    public QE_splitAgreementClass(ApexPages.StandardController controller) {
        contactList = new list<Contact>();
        displayContactList = new List<wrapperClass>();
        selectedContactList = new List<Contact>();
        contactMap = new Map<Id,Contact>();
        newSignee = new QE360_Opportunity_Additional_Signee__c();
        selectedSigneeList = new List<QE360_Opportunity_Additional_Signee__c>();
        currentSignee = new Map<Id,QE360_Opportunity_Additional_Signee__c>();
        proCheck = true;
        bussOpp = true;
        PersonRecordTypeId = null;
        
        OpportunityId  = ApexPages.currentPage().getParameters().get('Id');
        lstOpportunity = [select Id,Event__c,Event__r.Name,Name,Primary_Contact__c,AccountId,Account.Name,Amount,OwnerId,Grand_Total__c,StageName,Probability,CloseDate,Type,RecordTypeId from Opportunity where Id=:OpportunityId];
        PersonRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();
        OppAccountID = lstOpportunity[0].AccountId;
        System.debug(lstOpportunity[0].RecordTypeId);
        System.debug(PersonRecordTypeId);
        for(QE360_Opportunity_Additional_Signee__c oas: [Select Id, Contact__c, Name, OpportunityS__c FROM QE360_Opportunity_Additional_Signee__c WHERE OpportunityS__c =: OpportunityId]){
            if(oas.Contact__c != null)
            currentSignee.put(oas.Contact__c,oas);
        }
        
        if(lstOpportunity[0].RecordTypeId != null && lstOpportunity[0].RecordTypeId == PersonRecordTypeId){
            bussOpp = false;
            System.debug('bussOpp=>'+bussOpp);
        }
        displayContacts();
    }
    
    public PageReference displayContacts(){
        displayContactList = null;
        currentSignee = new Map<Id,QE360_Opportunity_Additional_Signee__c>();
        
        for(QE360_Opportunity_Additional_Signee__c oas: [Select Id, Contact__c, Name, OpportunityS__c FROM QE360_Opportunity_Additional_Signee__c WHERE OpportunityS__c =: OpportunityId]){
            if(oas.Contact__c != null)
            currentSignee.put(oas.Contact__c,oas);
        }
        
        if(lstOpportunity.size() > 0){
            if(lstOpportunity[0].AccountId != null){
                contactList = [SELECT Id, Name, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE AccountId =: lstOpportunity[0].AccountId];
                displayContactList=new List<wrapperClass>();
                for(Contact con: contactList){
                    if(currentSignee.containsKey(con.Id)){
                        displayContactList.add(new wrapperClass(con,true));
                    }else{
                        displayContactList.add(new wrapperClass(con,false));
                    }
                }
            }
        }
        return null;
    }
    
    public PageReference processSelected() {
        selectedSigneeList = new List<QE360_Opportunity_Additional_Signee__c>();
        if(displayContactList.size() > 0){
            for(wrapperClass pPro: displayContactList) {
                if(pPro.selectBit == true) {
                System.debug('==>'+pPro);
                    if(!contactMap.containsKey(pPro.conObj.Id))
                    contactMap.put(pPro.conObj.Id,pPro.conObj);
                }
            }
        }
        
        if(contactMap.size() > 0){
            selectedContactList = contactMap.values();
        }
        
        if(displayContactList.size() > 0){
            for(Contact con: selectedContactList){
                QE360_Opportunity_Additional_Signee__c OppAddSig =  new QE360_Opportunity_Additional_Signee__c();
                OppAddSig.Account__c = lstOpportunity[0].AccountId;
                OppAddSig.OpportunityS__c = lstOpportunity[0].Id;
                OppAddSig.Name = con.Name;
                OppAddSig.Contact__c = con.Id;
                OppAddSig.City__c = con.MailingCity;
                OppAddSig.State__c = con.MailingState;
                OppAddSig.Email__c = con.Email;
                OppAddSig.Street_Address__c = con.MailingStreet;
                OppAddSig.Zip_Code__c = con.MailingPostalCode;
                //OppAddSig.Amount__c = 0;
                System.debug('==>'+OppAddSig);
                selectedSigneeList.add(OppAddSig);
            }
        }
        
        if(newSigneeList.size() > 0){
            for(QE360_Opportunity_Additional_Signee__c nsl: newSigneeList){
                selectedSigneeList.add(nsl);
            }
        }
        
        return null;
    }
    
    public PageReference addSigneeItem() {
        System.debug('selectedSigneeList==>'+selectedSigneeList);
        if(selectedSigneeList.Size() > 0)
        {
            try{
                System.debug('selectedSigneeList=>'+selectedSigneeList);
                Upsert selectedSigneeList;
            }Catch(Exception ex){
                System.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select the Product'));
            return null;
            }
        
        if (OpportunityId != null ) {
            PageReference pref = new PageReference('/'+OpportunityId); 
            pref.setRedirect(true); 
            return pref;
        }
        return null;
    }
    
    public PageReference Cancel(){
        if(contactListDel.size() > 0){
            delete contactListDel;
        }
        
        if (OpportunityId != null ) {
        PageReference pref = new PageReference('/'+OpportunityId); 
        pref.setRedirect(true); 
        return pref;
        }
        return null;
    }
    
    
    // This is our wrapper/container class. A container class is a class, a data structure, or an abstract data type whose instances are collections of other objects. In this example a wrapper class contains both the standard salesforce object Contact and a Boolean value
    public class wrapperClass {
        public Contact conObj {get; set;}
        public boolean selectBit{get;set;}
        public boolean exsistFlag {get;set;}
        
        //This is the constructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public wrapperClass(Contact p, boolean e) {
            conObj = p;
            selectBit = false;
            exsistFlag = e;
        }
    }
    
    //New Signee create
    public boolean displayPopup {get; set;}     
    
    public void addNewSigee() { 
        displayPopup = false; 
        
        Contact con = new Contact();
        Account acc = new Account();
        System.debug('PersonRecordTypeId=>'+PersonRecordTypeId);
        if(lstOpportunity[0].RecordTypeId != PersonRecordTypeId){
            con.LastName = newSignee.Name;
            con.Email = newSignee.Email__c;
            con.AccountId = newSignee.Account__c;
            con.MailingCity = newSignee.City__c;
            con.MailingState = newSignee.State__c;
            con.MailingStreet = newSignee.Street_Address__c;
            con.MailingPostalCode = newSignee.Zip_Code__c;
            con.Source__c = 'Split Agreement';
            Insert con;
            newSignee.Contact__c = con.Id;
        }else {
            // Create lead and convert to account, to pass the account validation rule
            Lead lead = new Lead();
            lead.LastName = newSignee.Name;
            lead.Status = 'Qualified';
            lead.Source__c = 'Other';
            insert lead;
            
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(lead.id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Qualified');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
    
            Lead convertedLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
            
            if (convertedLead != null) {
                acc.Id = convertedLead.ConvertedAccountId;
                acc.PersonEmail = newSignee.Email__c;
                acc.PersonMailingCity = newSignee.City__c;
                acc.PersonMailingState = newSignee.State__c;
                acc.PersonMailingStreet = newSignee.Street_Address__c;
                acc.PersonMailingPostalCode = newSignee.Zip_Code__c;
                acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
                acc.Source__pc = 'Split Agreement';
                update acc;
            }
            newSignee.Contact__c = acc.PersonContactId ;
        }
        
        contactListDel.add(con);
        newSigneeList.add(newSignee);
        selectedSigneeList.add(newSignee);
        
    } 
    public void closePopup() {        
        displayPopup = false;  
    }    
    public void showPopup() {  
        newSignee = new QE360_Opportunity_Additional_Signee__c();
        newSignee.OpportunityS__c = lstOpportunity[0].Id;
        newSignee.Account__c = OppAccountID;
        displayPopup = true;    
    }
}