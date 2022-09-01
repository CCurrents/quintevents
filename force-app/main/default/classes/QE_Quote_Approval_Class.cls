public with sharing class QE_Quote_Approval_Class{

    public List<wrapperClass> lstWrapperClass {get;set;}
    public List<wrapperClassSignedReview> lstWrapperSignedReview {get;set;}
    public List<wrapperClassSignedReview> lstWrapperOnlineOrderSignedReview {get;set;}
    public List<opportunityWrapperClass> lstWrapperOpportunity {get;set;}
    public List<Quote> draftApprovedList {get;set;}
    public List<Quote> draftDeniList {get;set;}
    public List<Quote> signApprovedList {get;set;}
    public List<Quote> signApprovedOnlineOrdersList {get;set;}
    public List<Quote> signDeniList {get;set;}
    public List<Quote> signDeniOnlineOrderList {get;set;}
    public List<ProcessInstanceWorkitem > lstProcessInstance;
    public List<Quote> lstQuote;
    public List<Opportunity> lstOpportunity;
    public List<Quote> Quotelist;
    public map<Id,ProcessInstanceWorkitem> map_ProcessInstance;
    public QE_Quote_Approval_Class(){
        map_ProcessInstance=new map<Id,ProcessInstanceWorkitem>();
        lstProcessInstance=new List<ProcessInstanceWorkitem >();
        lstQuote = new List<Quote>();
        lstOpportunity = new List<Opportunity>();
        lstWrapperClass=new List<wrapperClass>();
        lstWrapperSignedReview = new List<wrapperClassSignedReview>();
        lstWrapperOnlineOrderSignedReview = new List<wrapperClassSignedReview>();
        lstWrapperOpportunity = new List<opportunityWrapperClass>();
        Quotelist = new List<Quote>();
        draftApprovedList = new List<Quote>();
        draftDeniList = new List<Quote>();
        signApprovedList = new List<Quote>();
        signApprovedOnlineOrdersList = new List<Quote>();
        signDeniList = new List<Quote>();
        signDeniOnlineOrderList = new List<Quote>();
        
        set<Id> quoteIdSet=new set<Id>();
        Map<string,Quote> quoteMap=new Map<string,Quote>();
        Map<string,Opportunity> opportunityMap=new Map<string,Opportunity>();
        
        //Approval Process for Draft & Signed Review Needed
        lstProcessInstance=[Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId,p.ProcessInstanceId,p.OriginalActorId,p.Id,p.ActorId,p.ElapsedTimeInDays,p.ElapsedTimeInHours,p.ElapsedTimeInMinutes From ProcessInstanceWorkitem p Order By p.ElapsedTimeInMinutes Desc];
        
        if(lstProcessInstance.size() > 0){
        
            for(ProcessInstanceWorkitem item:lstProcessInstance){
                
                if(!map_ProcessInstance.containsKey(item.ProcessInstance.TargetObjectId))
                    map_ProcessInstance.put(item.ProcessInstance.TargetObjectId,item);
            }
            System.debug('map_ProcessInstance=>'+map_ProcessInstance.keySet());
            if(map_ProcessInstance.size() > 0){
                quoteIdSet = map_ProcessInstance.keySet();
                //quoteIdSet.add(item.ProcessInstance.TargetObjectId);
            }
        }
        System.debug('lstProcessInstance size: '+lstProcessInstance.size());
        if(quoteIdSet.size() > 0) {
            lstQuote=[select Id,Name,QuoteNumber,Opportunity.Event__r.Name,Opportunity.Account.Name,AccountId,Status,Opportunity.Owner.Alias,GrandTotal,Online_Order__c,LastModifiedDate,SystemModstamp,Awaiting_Approval_From__c from Quote where Id in : quoteIdSet];
        }
        if(lstQuote.size() > 0){
            for(Quote item:lstQuote){
                quoteMap.put(item.Id,item);
            }
        }
        
        if(quoteIdSet.size() > 0) {
            lstOpportunity=[select Id,Name,Account.Name,Awaiting_Approval_From__c,StageName,Event__r.Name,Owner.Alias,Grand_Total__c,LastModifiedDate,SystemModstamp from Opportunity where Id in : quoteIdSet]; //quoteIdSet is holding target object ids from items in approval queue
        }
        if(lstOpportunity.size() > 0) {
            for(Opportunity oppt : lstOpportunity) {
                opportunityMap.put(oppt.Id,oppt);
            }
        }
        
        if(lstProcessInstance.size() > 0){
            for(ProcessInstanceWorkitem item:map_ProcessInstance.values()){   
                //Draft Review Needed
                if(quoteMap.containsKey(item.ProcessInstance.TargetObjectId) && item.ProcessInstance.Status == 'Pending' && quoteMap.get(item.ProcessInstance.TargetObjectId).Status == 'Draft - Needs Review')
                {
                    wrapperClass objWrapper=new wrapperClass(item.ProcessInstance.Status,quoteMap.get(item.ProcessInstance.TargetObjectId),item.Id,item.ElapsedTimeInDays,item.ElapsedTimeInHours,item.ElapsedTimeInMinutes);
                    lstWrapperClass.add(objWrapper);
                }
                // Signed Needs Review
                if(quoteMap.containsKey(item.ProcessInstance.TargetObjectId) && item.ProcessInstance.Status == 'Pending' && quoteMap.get(item.ProcessInstance.TargetObjectId).Status == 'Signed - Needs Review' && quoteMap.get(item.ProcessInstance.TargetObjectId).Online_Order__c == false)
                {
                    wrapperClassSignedReview objWrapperSigned=new wrapperClassSignedReview(item.ProcessInstance.Status,quoteMap.get(item.ProcessInstance.TargetObjectId),item.Id,item.ElapsedTimeInDays,item.ElapsedTimeInHours,item.ElapsedTimeInMinutes);
                    lstWrapperSignedReview.add(objWrapperSigned);
                }
                // Signed Needs Review - Online Orders
                if(quoteMap.containsKey(item.ProcessInstance.TargetObjectId) && item.ProcessInstance.Status == 'Pending' && quoteMap.get(item.ProcessInstance.TargetObjectId).Status == 'Signed - Needs Review' && quoteMap.get(item.ProcessInstance.TargetObjectId).Online_Order__c == true)
                {
                    wrapperClassSignedReview objWrapperSigned=new wrapperClassSignedReview(item.ProcessInstance.Status,quoteMap.get(item.ProcessInstance.TargetObjectId),item.Id,item.ElapsedTimeInDays,item.ElapsedTimeInHours,item.ElapsedTimeInMinutes);
                    lstWrapperOnlineOrderSignedReview.add(objWrapperSigned);
                }
                // Canceled Opportunites
                if(opportunityMap.containsKey(item.ProcessInstance.TargetObjectId) && item.ProcessInstance.Status == 'Pending' && opportunityMap.get(item.ProcessInstance.TargetObjectId).StageName == 'Request Cancelation')
                {
                    opportunityWrapperClass objOpportunityWrapper=new opportunityWrapperClass(item.ProcessInstance.Status,opportunityMap.get(item.ProcessInstance.TargetObjectId),item.Id,item.ElapsedTimeInDays,item.ElapsedTimeInHours,item.ElapsedTimeInMinutes);
                    lstWrapperOpportunity.add(objOpportunityWrapper);
                }
            }
        }
        
        Quotelist = [SELECT Id,Opportunity.Event__r.Name,Opportunity.Account.Name,Status,Opportunity.Owner.Alias,GrandTotal,Online_Order__c,Awaiting_Approval_From__c from Quote WHERE Status != 'Draft - Needs Review' OR Status != 'Signed - Needs Review' limit 10 ];
        for(Quote q: Quotelist){
            if(q.Status == 'Draft - Approved'){
                draftApprovedList.add(q);
            }else if(q.Status == 'Draft - Denied'){
                draftDeniList.add(q);
            }else if(q.Status == 'Signed - Approved' && q.Online_Order__c == false){
                signApprovedList.add(q);
            }else if(q.Status == 'Signed - Approved' && q.Online_Order__c == true){
                signApprovedOnlineOrdersList.add(q);
            }else if(q.Status == 'Signed - Denied' && q.Online_Order__c == false){
                signDeniList.add(q);
            }else if(q.Status == 'Signed - Denied' && q.Online_Order__c == true){
                signDeniOnlineOrderList.add(q);
            }
        }
    }
    
    
    public class opportunityWrapperClass{
        public Opportunity objOpportunity{get;set;}
        public String status{get;set;}
        public Id processLink {get;set;}
        public Decimal elapsedTimeInDays {get;set;}
        public Decimal elapsedTimeInHours {get;set;}
        public Decimal elapsedTimeInMinutes {get;set;}
        
        public opportunityWrapperClass(String approvalStatus, Opportunity objTempOpportunity, Id link, Decimal elapsedTimeInDay, Decimal elapsedTimeInHrs, Decimal elapsedTimeInMins)
        {
            objOpportunity=objTempOpportunity;
            status=approvalStatus;
            processLink = link;
            elapsedTimeInDays = elapsedTimeInHrs;
            elapsedTimeInHours = elapsedTimeInHrs;
            elapsedTimeInMinutes = elapsedTimeInMins;
        }
    }
    
    public class wrapperClass{
        public Quote objQuote{get;set;}
        public String status{get;set;}
        public Id processLink {get;set;}
        public Decimal elapsedTimeInDays {get;set;}
        public Decimal elapsedTimeInHours {get;set;}
        public Decimal elapsedTimeInMinutes {get;set;}
        
        public wrapperClass(String approvalStatus, Quote objTempQuote,Id link, Decimal elapsedTimeInDay, Decimal elapsedTimeInHrs, Decimal elapsedTimeInMins)
        {
            objQuote=objTempQuote;
            status=approvalStatus;
            processLink = link;
            elapsedTimeInDays = elapsedTimeInHrs;
            elapsedTimeInHours = elapsedTimeInHrs;
            elapsedTimeInMinutes = elapsedTimeInMins;
        }
    }
    
    public class wrapperClassSignedReview{
        public Quote objQuote{get;set;}
        public string status{get;set;}
        public Id processLink {get;set;}
        public Decimal elapsedTimeInDays {get;set;}
        public Decimal elapsedTimeInHours {get;set;}
        public Decimal elapsedTimeInMinutes {get;set;}
        
        public wrapperClassSignedReview(string approvalStatus, Quote objTempQuote, Id link, Decimal elapsedTimeInDay, Decimal elapsedTimeInHrs, Decimal elapsedTimeInMins)
        {
            objQuote=objTempQuote;
            status=approvalStatus;
            processLink = link;
            elapsedTimeInDays = elapsedTimeInHrs;
            elapsedTimeInHours = elapsedTimeInHrs;
            elapsedTimeInMinutes = elapsedTimeInMins;
        }
    }
}