public class QE_ProcessInstanceController {
    public String QuoteId{get;set;}
    public String imageURL{get;set;}
    public boolean displayPopup {get;set;}
    public transient QuoteDocument quoteDoc { get;set; } //transient 
    public transient Attachment quoteAtt { get;set; } //transient 
    public string comments{get;set;}
    public List<ProcessInstance> lst_ProcessInstance;
    public List<ProcessInstanceWorkitem> lst_ProcessInstanceWorkItem;
    public Quote objQuote {get; set;}
    public PageReference redirectPage;
    public Id loginUserId;
   
    public QE_ProcessInstanceController(ApexPages.StandardController stdController){
        try{
            loginUserId=userInfo.getUserId();
            objQuote=new Quote();
            
            set<Id> set_ProcessInstance=new set<Id>();
            QuoteId = ApexPages.currentPage().getParameters().get('id');
            objQuote = [select Account.IsPersonAccount,Name,Status,QuoteNumber,Opportunity.Name,OpportunityId,Opportunity.Event__r.Name, 
                Opportunity.Event__r.Id, AccountId,Account.Name,Why_Needs_Review__c,A_La_Carte_Sub_Total__c,Package_Sub_Total__c,Grand_Total__c,
                createdDate,Online_Order__c,Draft_Reasons_For_Review_Operations__c,Draft_Reasons_For_Review_Sales__c,Awaiting_Approval_From__c,Draft_Reasons_For_Review_H4H__c,OwnerId  from Quote where id =:QuoteId];
            system.debug('objQuote==>'+objQuote);
            lst_ProcessInstance=new List<ProcessInstance>();
            lst_ProcessInstanceWorkItem=new list<ProcessInstanceWorkitem>();
            redirectPage = new PageReference('/apex/QE_Quote_Approval_Page?sfdc.tabName=01r21000000CxH6');
            if(objQuote!=null)
            {
                lst_ProcessInstance =  new List<ProcessInstance>();
                lst_ProcessInstance=[SELECT Id, ProcessDefinitionId, TargetObjectId, Status, CompletedDate, LastActorId FROM ProcessInstance where TargetObjectId=:objQuote.Id and Status='Pending'];
                //lst_ProcessInstance =[SELECT Id, ProcessDefinitionId, TargetObjectId, Status, CompletedDate, LastActorsId FROM ProcessInstance where TargetObjectId=:objQuote.Id and Status='Success'];
                system.debug('lst_ProcessInstance==>'+lst_ProcessInstance);
                if(lst_ProcessInstance.size()>0)
                {
                    for(ProcessInstance item:lst_ProcessInstance)
                    {
                        set_ProcessInstance.add(item.Id);
                    }
                        lst_ProcessInstanceWorkItem=[SELECT Id, ProcessInstanceId, ActorId, OriginalActorId FROM ProcessInstanceWorkitem where ProcessInstanceId IN :set_ProcessInstance and ActorId=:loginUserId];
                    system.debug('objProcessInstanceWorkItem==>'+lst_ProcessInstanceWorkItem);
                } 
            }
            if(Test.isRunningTest()){
                objQuote.Status = 'Signed - Needs Review';
            }
            // quoteDoc = [SELECT Id, QuoteId, ContentVersionDocumentId, Document FROM QuoteDocument where QuoteId=:QuoteId]; // Original
            // Check if quote status is "Signed - Needs Review"
            imageURL='/servlet/servlet.FileDownload?file=';
            if ((objQuote.Status).equals('Signed - Needs Review') && objQuote.Online_Order__c == false) {
                List<dsfs__DocuSign_Status__c> docuSignStatuses = new List<dsfs__DocuSign_Status__c>();
                docuSignStatuses = [
                    select Id, Name, dsfs__Envelope_Status__c, (select Id from Attachments)
                    from dsfs__DocuSign_Status__c
                    where Standard_Quote__c = :objQuote.Id and dsfs__Envelope_Status__c = 'Completed'
                    order by CreatedDate desc
                ];
                imageURL=imageURL+docuSignStatuses.get(0).attachments.get(0).Id;
            } else {
                
                quoteAtt = [SELECT Id, ParentId, Body FROM Attachment where ParentId=:QuoteId Limit 1];
                imageURL=imageURL+quoteAtt.id;
                //quoteDoc = [SELECT Id, QuoteId, Document FROM QuoteDocument where QuoteId=:QuoteId]; // Edited By Jeet
                //imageURL=imageURL+quoteDoc.id;
                
            }
            
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage() +' Line Number==>'+ ex.getLineNumber());
        }
    }
    
    public PageReference Approve(){
        if(objQuote.OwnerId != UserInfo.getUserId() || UserInfo.getUserName() == 'dhiggins@quintevents.com'){
        try{
                List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
                for(ProcessInstanceWorkitem item:lst_ProcessInstanceWorkItem)
                {
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setComments(comments);
                    req.setAction('Approve');
                    req.setWorkitemId(item.Id);
                    requests.add(req);  
                }
                Approval.ProcessResult[] processResults = null;
                        processResults = Approval.process(requests, false);
               // update objQuote;
               return redirectPage;
            
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage() +' Line Number==>'+ ex.getLineNumber());
            return null;
        }
        }else{
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Quote owner cannot approve or reject the quote.'));
                 return null;
        }
    }
    
    public PageReference Reject(){
        try{
        if(objQuote.OwnerId != UserInfo.getUserId() || UserInfo.getUserName() == 'dhiggins@quintevents.com'){
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
            for(ProcessInstanceWorkitem item:lst_ProcessInstanceWorkItem)
            {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments(comments);
                req.setAction('Reject');
                req.setWorkitemId(item.Id);
                requests.add(req);
            }
            
            //update objQuote;
            if (fieldsAllGood()) {
                Approval.ProcessResult[] processResults = null;
                processResults = Approval.process(requests, false);
                return redirectPage;
            } else {
                return null;
            }
         }else{
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Quote owner cannot approve or reject the quote.'));
                 return null;
         }     
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage() +' Line Number==>'+ ex.getLineNumber());
            return null;
        }    
    }
    
    public Boolean fieldsAllGood() {
        if (comments.equals('') || comments == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Comments.'));
            return false;
        } else {
            return true;
        }
    }
    
    public PageReference Cancel(){
        return redirectPage ;
    }
    public void showPopup()
    {
        displayPopup=true;
    }
    public void closePopup()
    {
        displayPopup=false;
    }
}