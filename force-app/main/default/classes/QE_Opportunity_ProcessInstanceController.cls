public class QE_Opportunity_ProcessInstanceController {
    public String OpportunityId{get;set;}
    public string comments{get;set;}
    public List<ProcessInstance> lst_ProcessInstance;
    public List<ProcessInstanceWorkitem> lst_ProcessInstanceWorkItem;
    public Opportunity objOpportunity {get; set;}
    public PageReference redirectPage;
    public Id loginUserId;
    public QE_Opportunity_ProcessInstanceController(ApexPages.StandardController stdController){
        try{
            loginUserId=userInfo.getUserId();
            objOpportunity=new Opportunity();
            set<Id> set_ProcessInstance=new set<Id>();
            OpportunityId = ApexPages.currentPage().getParameters().get('id');
            objOpportunity = [select Name,StageName,Event__r.Name, Event__r.Id,Account.Name,AccountId,Grand_Total__c,createdDate,Online_Order__c,Reason_For_Cancellation__c from Opportunity where id =:OpportunityId];
            system.debug('objOpportunity==>'+objOpportunity);
            lst_ProcessInstance=new List<ProcessInstance>();
            lst_ProcessInstanceWorkItem=new list<ProcessInstanceWorkitem>();
            redirectPage = new PageReference('/apex/QE_Quote_Approval_Page?sfdc.tabName=01r21000000CxH6');
            if(objOpportunity!=null)
            {
                lst_ProcessInstance =  new List<ProcessInstance>();
                lst_ProcessInstance=[SELECT Id, ProcessDefinitionId, TargetObjectId, Status, CompletedDate, LastActorId FROM ProcessInstance where TargetObjectId=:objOpportunity.Id and Status='Pending'];
               //lst_ProcessInstance=[SELECT Id, ProcessDefinitionId, TargetObjectId, Status, CompletedDate, LastActorId FROM ProcessInstance];
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
            
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage() +' Line Number==>'+ ex.getLineNumber());
        }
    }
    
    public PageReference Approve(){
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
           // update objOpportunity;
            return redirectPage ;
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage() +' Line Number==>'+ ex.getLineNumber());
            return null;
        }
    }
    
    public PageReference Reject(){
        try{
            if (fieldsAllGood()) {
                List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
                for(ProcessInstanceWorkitem item:lst_ProcessInstanceWorkItem)
                {
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setComments(comments);
                    req.setAction('Reject');
                    req.setWorkitemId(item.Id);
                    requests.add(req);
                }
                Approval.ProcessResult[] processResults = null;
                        processResults = Approval.process(requests, false);
                //update objOpportunity;
            
                return redirectPage;
            } else {
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
}