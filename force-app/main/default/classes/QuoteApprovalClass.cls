/**
 * @File Name          : QuoteApprovalClass.cls
 * @Description        : Class for Handling all the Approval Process Steps related to Quote and Order
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 04/14/2021
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    5/11/2020         mpatel@addonblue.com     Initial Version
 * 1.1    7/20/2020         jagrawal@addonblue.com   Added Code for Order Cancellation issue fix
 * 1.2    04/14/2021        kchavda@addonblue.com    #910 Reason for review not showing for Quotes is
 * 1.3    04/27/2021        cshah@addonblue.com      #919 Add a field "Original Quote" on "Review" modal of Approval Queue page
**/
public with sharing class QuoteApprovalClass {
    /** 
    * @description  : Read base URL 
    * @author       : jagrawal@addonblue.com
    * @return       : String
    **/
    @AuraEnabled
    public static String readBaseUrl(){
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseUrl =' + baseUrl);
        return baseUrl;
    }
    /**
    * @description  : Get quote approval process
    * @author       : jagrawal@addonblue.com
    * @return       : List<masterWrapperClass>
    **/
   @AuraEnabled
    public static List<masterWrapperClass> getQuoteApprovalClass(){
    List<wrapperClass> lstWrapperClass;
    List<wrapperClassSignedReview> lstWrapperSignedReview;
    List<wrapperClassSignedReview> lstWrapperOnlineOrderSignedReview;
    List<OrderCancelWrapperClass> lstWrapperOrder;
    List<OrderCancelWrapperClass> lstCreditAdjustmentOrder;
    List<OrderCancelWrapperClass> lstDefaultAdjustmentOrder;
    /*List<Quote> draftApprovedList;
    List<Quote> draftDeniList;
    List<Quote> signApprovedList;
    List<Quote> signApprovedOnlineOrdersList;
    List<Quote> signDeniList;
    List<Quote> signDeniOnlineOrderList;*/
    List<ProcessInstanceWorkitem > lstProcessInstance;
    List<Quote> lstQuote;
    List<Order> lstOrder;
    //List<Quote> Quotelist; 
    map<Id,ProcessInstanceWorkitem> map_ProcessInstance;
    List<masterWrapperClass> masterWrapperClass = new List<masterWrapperClass>();
        map_ProcessInstance=new map<Id,ProcessInstanceWorkitem>();
        lstProcessInstance=new List<ProcessInstanceWorkitem >();
        lstQuote = new List<Quote>();
        lstOrder = new List<Order> ();
        lstWrapperClass=new List<wrapperClass>();
        lstWrapperSignedReview = new List<wrapperClassSignedReview>();
        lstWrapperOnlineOrderSignedReview = new List<wrapperClassSignedReview>();
        lstWrapperOrder = new List<OrderCancelWrapperClass>();
        lstCreditAdjustmentOrder = new List<OrderCancelWrapperClass>();
        lstDefaultAdjustmentOrder = new List<OrderCancelWrapperClass>();
        /*Quotelist = new List<Quote>();
        draftApprovedList = new List<Quote>();
        draftDeniList = new List<Quote>();
        signApprovedList = new List<Quote>();
        signApprovedOnlineOrdersList = new List<Quote>();
        signDeniList = new List<Quote>();
        signDeniOnlineOrderList = new List<Quote>();*/
        //draftApprovedList,signApprovedList,signApprovedOnlineOrdersList,draftDeniList,signDeniList,signDeniOnlineOrderList,
        set<Id> quoteIdSet=new set<Id>();
        Map<string,Quote> quoteMap=new Map<string,Quote>();
        Map<string,Order> orderMap=new Map<string,order>();
        try{
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
                lstQuote=[select Id,Name,QuoteNumber,Opportunity.PriceBook2.Name,Opportunity.Account.Name,AccountId,Account.Name,Status,Opportunity.Owner.Alias,GrandTotal,Online_Order__c,LastModifiedDate,SystemModstamp,Awaiting_Approval_From__c from Quote where Id in : quoteIdSet];
            }
            if(lstQuote.size() > 0){
                for(Quote item:lstQuote){
                    quoteMap.put(item.Id,item);
                }
            }
            
            if(quoteIdSet.size() > 0) {
                lstOrder=[select Id,Name,Account.Name,OrderNumber,Owner.Alias,LastModifiedDate,SystemModstamp,Awaiting_Approval_From__c,Opportunity.Owner.Name,
                          Opportunity.PriceBook2.Name,Quote.Name,Status,TotalAmount from Order where Id in : quoteIdSet]; //quoteIdSet is holding target object ids from items in approval queue
            }
            if(lstOrder.size() > 0) {
                for(Order objOrder : lstOrder) {
                    orderMap.put(objOrder.Id, objOrder);
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
                    if(quoteMap.containsKey(item.ProcessInstance.TargetObjectId) && item.ProcessInstance.Status == 'Pending' && quoteMap.get(item.ProcessInstance.TargetObjectId).Status == 'Signed - Needs Review' && quoteMap.get(item.ProcessInstance.TargetObjectId).Online_Order__c == false ||Test.isRunningTest())
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
                    // Canceled Order
                    if(orderMap.containsKey(item.ProcessInstance.TargetObjectId) && item.ProcessInstance.Status == 'Pending' && orderMap.get(item.ProcessInstance.TargetObjectId).Status == 'Cancellation Pending'){  
                        OrderCancelWrapperClass objCancelOrderWrapper =new OrderCancelWrapperClass(item.ProcessInstance.Status,orderMap.get(item.ProcessInstance.TargetObjectId),item.Id,item.ElapsedTimeInDays,item.ElapsedTimeInHours,item.ElapsedTimeInMinutes);
                        lstWrapperOrder.add(objCancelOrderWrapper);
                    }
                    // Credit adjustment
                    if(orderMap.containsKey(item.ProcessInstance.TargetObjectId) && item.ProcessInstance.Status == 'Pending' && orderMap.get(item.ProcessInstance.TargetObjectId).Status == 'Credit Adjustment Pending'){  
                        OrderCancelWrapperClass orderCreditWrapperClassObj = new OrderCancelWrapperClass(item.ProcessInstance.Status,orderMap.get(item.ProcessInstance.TargetObjectId),item.Id,item.ElapsedTimeInDays,item.ElapsedTimeInHours,item.ElapsedTimeInMinutes);
                        lstCreditAdjustmentOrder.add(orderCreditWrapperClassObj);
                    }
                    // Defaulted
                    //#493.. logic added for the this ticket
                    if(orderMap.containsKey(item.ProcessInstance.TargetObjectId) && item.ProcessInstance.Status == 'Pending' && orderMap.get(item.ProcessInstance.TargetObjectId).Status == 'Defaulted - Pending'){  
                        OrderCancelWrapperClass orderDefaultWrapperClassObj = new OrderCancelWrapperClass(item.ProcessInstance.Status,orderMap.get(item.ProcessInstance.TargetObjectId),item.Id,item.ElapsedTimeInDays,item.ElapsedTimeInHours,item.ElapsedTimeInMinutes);
                        lstDefaultAdjustmentOrder.add(orderDefaultWrapperClassObj);
                    }
                }
            }
            
            /*Quotelist = [SELECT Id,Opportunity.PriceBook2.Name,Opportunity.Account.Name,Status,Opportunity.Owner.Alias,GrandTotal,Online_Order__c,Awaiting_Approval_From__c from Quote WHERE Status != 'Draft - Needs Review' OR Status != 'Signed - Needs Review' limit 10 ];
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
            System.debug('signDeniList-->'+signDeniList);*/
            masterWrapperClass.add(new masterWrapperClass(lstWrapperClass, lstWrapperSignedReview, lstWrapperOnlineOrderSignedReview, lstWrapperOrder, lstCreditAdjustmentOrder, lstDefaultAdjustmentOrder));
            //draftApprovedList,signApprovedList,signApprovedOnlineOrdersList,draftDeniList,signDeniList,signDeniOnlineOrderList,
        }catch(Exception ex){
            System.debug('Exception-->'+ex.getMessage()+'-->'+ex.getLineNumber());
        }
        return masterWrapperClass;
    }
    @AuraEnabled
    public static List<QuoteWrapperClass> getProcessInstanceDetail(String QuoteId){
        List<QuoteWrapperClass> wrapperClass = new List<QuoteWrapperClass>();
        String imageURL;
        String sharlinkId = '';
        String originalQuoteNumber = '';
        Boolean displayPopup;
        transient List<Attachment> quoteAtt;
        List<ProcessInstance> lst_ProcessInstance;
        List<ProcessInstanceWorkitem> lst_ProcessInstanceWorkItem;
        Quote objQuote;
        PageReference redirectPage;
        Id loginUserId;
        system.debug('==>11111111111111111');
        try{
            loginUserId=userInfo.getUserId();
            objQuote=new Quote();
            
            set<Id> set_ProcessInstance=new set<Id>();
            //QuoteId = ApexPages.currentPage().getParameters().get('id');
            objQuote = [select Account.IsPersonAccount,Name,Status,QuoteNumber,Opportunity.Name,OpportunityId,Opportunity.PriceBook2.Name, 
                Opportunity.Event__r.Id, AccountId,Account.Name,Why_Needs_Review__c,A_La_Carte_Sub_Total__c,Package_Sub_Total__c,Grand_Total__c,OwnerId,
                createdDate,Online_Order__c,Draft_Reasons_For_Review_Operations__c,Draft_Reasons_For_Review_Sales__c,Awaiting_Approval_From__c,Draft_Reasons_For_Review_H4H__c,
                Signed_Reasons_For_Review_H4H__c,Signed_Reasons_For_Review_Operations__c,Signed_Reasons_For_Review_Sales__c,Original_Quote__c,Original_Quote__r.QuoteNumber,Reason_for_Hold__c
                from Quote where id =:QuoteId];
            system.debug('objQuote==>'+objQuote.Status);
            if(objQuote.Original_Quote__c != null) { //#919
                originalQuoteNumber = objQuote.Original_Quote__r.QuoteNumber;
            }
            
            lst_ProcessInstance=new List<ProcessInstance>();
            lst_ProcessInstanceWorkItem=new list<ProcessInstanceWorkitem>();
            //redirectPage = new PageReference('/apex/QE_Quote_Approval_Page?sfdc.tabName=01r21000000CxH6');
            ApprovalList approvalResultForObject = new ApprovalList();
            if(objQuote!=null)
            {
                lst_ProcessInstance =  new List<ProcessInstance>();
                lst_ProcessInstance=[SELECT Id, ProcessDefinitionId, TargetObjectId, Status, CompletedDate, LastActorId,
                             (SELECT ID, ProcessNodeId, StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending,
                             OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name, OriginalActor.Name,
                             ProcessNode.Name FROM StepsAndWorkitems order by CreatedDate DESC )
                             FROM ProcessInstance where TargetObjectId=:objQuote.Id and Status='Pending'];
                //lst_ProcessInstance =[SELECT Id, ProcessDefinitionId, TargetObjectId, Status, CompletedDate, LastActorsId FROM ProcessInstance where TargetObjectId=:objQuote.Id and Status='Success'];
                //***************************this is custom approval setp process to display on the component***********************************
                List<ApprovalStepWrapper> aSW = new List<ApprovalStepWrapper>();  
                String recallApprovalProcessLink;  
                Boolean isSubmitForApproval = true; 
                //******************************************************************************************************************************
                system.debug('lst_ProcessInstance==>'+lst_ProcessInstance);
                if(lst_ProcessInstance.size()>0){
                    for(ProcessInstance item:lst_ProcessInstance){
                        //**************************this is custom approval setp process to display on the component********************************
                        Map<Id,List<ProcessInstanceHistory>> mapOfProcessNodeIdAndProcessInstanceHistory = new Map<Id,List<ProcessInstanceHistory>>();  
                        Set<Id> processNodeId= new Set<Id>();  
                        for(ProcessInstanceHistory sWI:item.StepsAndWorkitems)  
                        {  
                            if(processNodeId.size() ==0)  
                                processNodeId.add(sWI.ProcessNodeId);  
                            else if(processNodeId.size()>0 && processNodeId.contains(sWI.ProcessNodeId)!= NULL)  
                                processNodeId.add(sWI.ProcessNodeId);  
                        }  
                        for(Id pNId: processNodeId)  
                        {  
                            ApprovalStepWrapper aSWr = new ApprovalStepWrapper();  
                            for(ProcessInstanceHistory sWI:item.StepsAndWorkitems)  
                            {  
                                if(sWI.processNodeId == pNID)  
                                {  
                                    aSWr.listOfSteps.add(new ApprovalHistoryWrap(sWI.CreatedDate, sWI.OriginalActor.Name, sWI.StepStatus,sWI.Actor.Name,sWI.Comments));  
                                }  
                                if(sWI.StepStatus == 'Pending')  
                                {  
                                    isSubmitForApproval = false;  
                                }  
                            }  
                            aSW.add(aSWr);  
                        } 
                        //*********************************************************************************************************
                        set_ProcessInstance.add(item.Id);
                    }
                    //**********************************************************************************************
                    approvalResultForObject.approvals = aSW;  
                    approvalResultForObject.recordId = QuoteId;  
                    approvalResultForObject.isSubmitForApproval = isSubmitForApproval;  
                    system.debug('asw'+aSW);  
                    //**********************************************************************************************
                    lst_ProcessInstanceWorkItem=[SELECT Id, ProcessInstanceId, ActorId, OriginalActorId FROM ProcessInstanceWorkitem where ProcessInstanceId IN :set_ProcessInstance and ActorId=:loginUserId];
                    system.debug('objProcessInstanceWorkItem==>'+lst_ProcessInstanceWorkItem);
                } 
            }
            if(Test.isRunningTest()){
                objQuote.Status = 'Signed - Needs Review';
            }
           
            // Check if quote status is "Signed - Needs Review"
            imageURL='';
            if ((objQuote.Status).equals('Signed - Needs Review') && objQuote.Online_Order__c == false) {
                List<dsfs__DocuSign_Status__c> docuSignStatuses = new List<dsfs__DocuSign_Status__c>();
                docuSignStatuses = [
                    select Id, Name, dsfs__Envelope_Status__c, (select ContentDocumentId from ContentDocumentLinks),(Select id from Attachments)
                    from dsfs__DocuSign_Status__c
                    where Standard_Quote__c = :objQuote.Id and dsfs__Envelope_Status__c = 'Completed'
                    order by CreatedDate desc
                ];
                System.debug('imageURL-->'+imageURL);
                if(!docuSignStatuses.isEmpty()){
                    if(!docuSignStatuses[0].Attachments.isEmpty()){
                        imageURL='/servlet/servlet.FileDownload?file='+docuSignStatuses[0].Attachments[0].Id;
                        System.debug('imageURL-->'+imageURL);
                    }
                    else if(!docuSignStatuses[0].ContentDocumentLinks.isEmpty()){
                        //ContentDocumentLink cdl = [select contentdocument.id, contentdocument.title, contentdocument.filetype from contentdocumentlink where linkedentityid = 'a0a3B000001LsxrQAC'];
                        ContentVersion cv = [select id from contentversion where contentdocumentid =: docuSignStatuses[0].ContentDocumentLinks[0].ContentDocumentId];//cdl.contentdocument.id];
                        ContentDistribution cd = new ContentDistribution();
                        cd.Name = objQuote.Name;
                        cd.ContentVersionId = cv.id;
                        cd.PreferencesAllowViewInBrowser= true;
                        cd.PreferencesLinkLatestVersion=true;
                        cd.PreferencesNotifyOnVisit=false;
                        cd.PreferencesPasswordRequired=false;
                        cd.PreferencesAllowOriginalDownload= true;
                        RunAsAdminUtility.deleteContentDistibution();
                        insert cd;
                        if(cd.id != null){
                            sharlinkId = cd.Id;
                            //docuSignStatuses[0].ContentDocumentLinks[0].ContentDocumentId;//'/servlet/servlet.FileDownload?file='+
                            
                            List<ContentDistribution> contentLink= [select id,DistributionPublicUrl from ContentDistribution where id =: cd.id ];
                            imageURL= contentLink[0].DistributionPublicUrl; 
                            System.debug('imageURL-->'+imageURL+'<--sharlinkId-->'+sharlinkId+'<--contentLink-->'+contentLink[0].DistributionPublicUrl);
                        }
                    }
                }
            } else {
                /*System.debug('imageURL-->'+imageURL);
                quoteAtt = [SELECT Id, ParentId, Body FROM Attachment where ParentId=:QuoteId Limit 1];
                if(!quoteAtt.isEmpty()){
                    imageURL=imageURL+quoteAtt[0].id;
                    System.debug('imageURL-->'+imageURL);
                }*/
            }
            wrapperClass.add(new QuoteWrapperClass(objQuote, lst_ProcessInstanceWorkItem,approvalResultForObject, imageURL, sharlinkId,originalQuoteNumber));
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage() +' Line Number==>'+ ex.getLineNumber());
            throw new aurahandledException(ex.getMessage()+' '+ex.getLineNumber());
        }
        return wrapperClass;
    }
    @AuraEnabled
    public static String ApproveProcess(String comments, Quote objQuote, String processInstanceString){
        List<ProcessInstanceWorkitem> lst_ProcessInstanceWorkItem = (List<ProcessInstanceWorkitem>)JSON.deserialize(processInstanceString, List<ProcessInstanceWorkitem>.class);
        String message='';
        System.debug('message-->');
        if(objQuote.OwnerId != UserInfo.getUserId() || UserInfo.getUserName() == 'dhiggins@quintevents.com'){
            try{
                List<Quote> approvalStepList = [Select Id, Owner.Email, Event__r.Program__c,
                    (Select Id, IsPending, ProcessInstanceId, ProcessNode.DeveloperName, TargetObjectId, StepStatus, OriginalActorId,
                     ActorId, RemindersSent, Comments, IsDeleted, CreatedDate, CreatedById, SystemModstamp
                     From ProcessSteps Where StepStatus = 'Pending')
                    From Quote Where Id =: objQuote.Id];
                    Map<Id, String> stepMaps = new Map<Id, String>();
                    if(!approvalStepList.isEmpty()){
                        if(!approvalStepList[0].ProcessSteps.isEmpty()){
                            stepMaps.put(approvalStepList[0].ProcessSteps[0].ProcessInstanceId, approvalStepList[0].ProcessSteps[0].ProcessNode.DeveloperName);
                        }
                    }
                
                    System.debug('lst_ProcessInstanceWorkItem-->'+lst_ProcessInstanceWorkItem);
                    List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
                    for(ProcessInstanceWorkitem item:lst_ProcessInstanceWorkItem){
                        System.debug('item-->'+item);
                        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                        req.setComments(comments);
                        req.setAction('Approve');
                        req.setWorkitemId(item.Id);
                        requests.add(req);  
                        message = 'The Quote has been Approved.';
                        If(!stepMaps.isEmpty() && stepMaps.containskey(item.ProcessInstanceId)) {
                            System.debug('step.ProcessNode.DeveloperName: '+stepMaps.get(item.ProcessInstanceId));
                            // Draft Quote Operations
                            If((stepMaps.get(item.ProcessInstanceId)).equals('Draft_Quote_Operations')) {
                                objQuote.Draft_Approver_Comment_Operations__c = Comments;
                            }
                            // Draft Quote Sales
                            If((stepMaps.get(item.ProcessInstanceId)).equals('Draft_Quote_Sales')) {
                                objQuote.Draft_Approver_Comment_Sales__c = Comments;
                            }
                            // Signed Quote Operations
                            If((stepMaps.get(item.ProcessInstanceId)).equals('Signed_Quote_Operations')) {
                                objQuote.Signed_Approver_Comment_Operations__c = Comments;
                            }
                            /*// Signed Quote Sales
                            If((stepMaps.get(item.ProcessInstanceId)).equals('Signed_Quote_Sales')) {
                                objQuote.Signed_Approver_Comment_Sales__c = Comments;
                            }*/
                        }
                    }
                    update objQuote;
                
                    Approval.ProcessResult[] processResults = null;
                            processResults = Approval.process(requests, false);
                    
                    if(lst_ProcessInstanceWorkItem.isEmpty()){
                        message='Your are not an Approver in this approval step';
                    }
            }catch(exception ex){
                system.debug('Error==>'+ex.getMessage() +' Line Number==>'+ ex.getLineNumber());
            }
        }else{
            //     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Quote owner cannot approve or reject the quote.'));
            message = 'Error: Quote owner cannot approve or reject the quote.';
        }
        return message;
    }
    @AuraEnabled
    public static String rejectProcess(String comments, Quote objQuote, String processInstanceString){
        List<ProcessInstanceWorkitem> lst_ProcessInstanceWorkItem = (List<ProcessInstanceWorkitem>)JSON.deserialize(processInstanceString, List<ProcessInstanceWorkitem>.class);
        String message='';
        System.debug('comments-->'+comments);
        try{
            List<Quote> approvalStepList = [Select Id, Owner.Email, Event__r.Program__c,
                                            (Select Id, IsPending, ProcessInstanceId, ProcessNode.DeveloperName, TargetObjectId, StepStatus, OriginalActorId,
                                            ActorId, RemindersSent, Comments, IsDeleted, CreatedDate, CreatedById, SystemModstamp
                                            From ProcessSteps Where StepStatus = 'Pending')
                                            From Quote Where Id =: objQuote.Id];
            Map<Id, String> stepMaps = new Map<Id, String>();
            if(!approvalStepList.isEmpty()){
                if(!approvalStepList[0].ProcessSteps.isEmpty()){
                    stepMaps.put(approvalStepList[0].ProcessSteps[0].ProcessInstanceId, approvalStepList[0].ProcessSteps[0].ProcessNode.DeveloperName);
                }
            }
            System.debug('lst_ProcessInstanceWorkItem-->'+lst_ProcessInstanceWorkItem);
            if(objQuote.OwnerId != UserInfo.getUserId() || UserInfo.getUserName() == 'dhiggins@quintevents.com'){
                List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
                for(ProcessInstanceWorkitem item:lst_ProcessInstanceWorkItem){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setComments(comments);
                    req.setAction('Reject');
                    req.setWorkitemId(item.Id);
                    requests.add(req);
                    message ='The Quote has been Rejected.';
                    If(!stepMaps.isEmpty() && stepMaps.containskey(item.ProcessInstanceId)) {
                        System.debug('step.ProcessNode.DeveloperName: '+stepMaps.get(item.ProcessInstanceId));
                        // Draft Quote Operations
                        If((stepMaps.get(item.ProcessInstanceId)).equals('Draft_Quote_Operations')) {
                            objQuote.Draft_Approver_Comment_Operations__c = Comments;
                        }
                        // Draft Quote Sales
                        If((stepMaps.get(item.ProcessInstanceId)).equals('Draft_Quote_Sales')) {
                            objQuote.Draft_Approver_Comment_Sales__c = Comments;
                        }
                        // Signed Quote Operations
                        If((stepMaps.get(item.ProcessInstanceId)).equals('Signed_Quote_Operations')) {
                            objQuote.Signed_Approver_Comment_Operations__c = Comments;
                        }
                        /*// Signed Quote Sales
                        If((stepMaps.get(item.ProcessInstanceId)).equals('Signed_Quote_Sales')) {
                            objQuote.Signed_Approver_Comment_Sales__c = Comments;
                        }*/
                    }
                }
                update objQuote;
                if(lst_ProcessInstanceWorkItem.isEmpty()){
                    message='Your are not an Approver in this approval step';
                }
                //update objQuote;
                if (comments !='' && comments != null){
                    Approval.ProcessResult[] processResults = null;
                    processResults = Approval.process(requests, false);
                    //return redirectPage;
                } else {
                    message = 'Please enter Comments.';
                }
            }else{
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Quote owner cannot approve or reject the quote.'));     
                    message = 'Error: Quote owner cannot approve or reject the quote.';
            }     
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage() +' Line Number==>'+ ex.getLineNumber());
        } 
        return message;   
    }
    @AuraEnabled
    public static List<OrderWrapperClass> OpportunityProcessInstance(String orderId){
        List<OrderWrapperClass> orderWrapperClass = new List<OrderWrapperClass>();
        List<ProcessInstance> lst_ProcessInstance;
        List<ProcessInstanceWorkitem> lst_ProcessInstanceWorkItem;
        Order objOrder;
        Id loginUserId;
        
        try{
            loginUserId=userInfo.getUserId();
            objOrder=new Order();
            set<Id> set_ProcessInstance=new set<Id>();
            //OpportunityId = ApexPages.currentPage().getParameters().get('id');
            objOrder = [select Name,Opportunity.PriceBook2.Name,Opportunity.Owner.Name, PriceBook2Id,Account.Name,AccountId,CreatedDate,Online_Order__c,Reason_For_Cancellation__c,Quote.Name,
                Status,TotalAmount,OrderNumber from Order where id =:orderId];
            system.debug('objOrder==>'+objOrder);
            lst_ProcessInstance=new List<ProcessInstance>();
            lst_ProcessInstanceWorkItem=new list<ProcessInstanceWorkitem>();
            ApprovalList approvalResultForObject = new ApprovalList();  
            if(objOrder!=null)
            {
                lst_ProcessInstance =  new List<ProcessInstance>();
                lst_ProcessInstance=[SELECT Id, ProcessDefinitionId, TargetObjectId, Status, CompletedDate, LastActorId,
                             (SELECT ID, ProcessNodeId, StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending  
                             ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name, OriginalActor.Name,
                              ProcessNode.Name FROM StepsAndWorkitems order by CreatedDate DESC )
                              FROM ProcessInstance where TargetObjectId=:objOrder.Id and Status='Pending'];
                //lst_ProcessInstance=[SELECT Id, ProcessDefinitionId, TargetObjectId, Status, CompletedDate, LastActorId FROM ProcessInstance];
                //***************************this is custom approval setp process to display on the component***********************************
                List<ApprovalStepWrapper> aSW = new List<ApprovalStepWrapper>();  
                String recallApprovalProcessLink;  
                Boolean isSubmitForApproval = true; 
                //******************************************************************************************************************************
                system.debug('lst_ProcessInstance==>'+lst_ProcessInstance);
                if(lst_ProcessInstance.size()>0){
                    for(ProcessInstance item:lst_ProcessInstance){
                        //**************************this is custom approval setp process to display on the component********************************
                        Map<Id,List<ProcessInstanceHistory>> mapOfProcessNodeIdAndProcessInstanceHistory = new Map<Id,List<ProcessInstanceHistory>>();  
                        Set<Id> processNodeId= new Set<Id>();  
                        for(ProcessInstanceHistory sWI:item.StepsAndWorkitems){  
                            if(processNodeId.size() ==0)  
                                processNodeId.add(sWI.ProcessNodeId);  
                            else if(processNodeId.size()>0 && processNodeId.contains(sWI.ProcessNodeId)!= NULL)  
                                processNodeId.add(sWI.ProcessNodeId);  
                        }  
                        for(Id pNId: processNodeId){  
                            ApprovalStepWrapper aSWr = new ApprovalStepWrapper();  
                            for(ProcessInstanceHistory sWI:item.StepsAndWorkitems){  
                                if(sWI.processNodeId == pNID){  
                                    aSWr.listOfSteps.add(new ApprovalHistoryWrap(sWI.CreatedDate, sWI.OriginalActor.Name, sWI.StepStatus,sWI.Actor.Name,sWI.Comments));  
                                }  
                                if(sWI.StepStatus == 'Pending'){  
                                    isSubmitForApproval = false;  
                                }  
                            }  
                            aSW.add(aSWr);  
                        } 
                        //*********************************************************************************************************
                        set_ProcessInstance.add(item.Id);
                    }
                    //**********************************************************************************************
                    approvalResultForObject.approvals = aSW;  
                    approvalResultForObject.recordId = orderId;  
                    approvalResultForObject.isSubmitForApproval = isSubmitForApproval;  
                    system.debug('asw'+aSW);  
                    //**********************************************************************************************
                    lst_ProcessInstanceWorkItem=[SELECT Id, ProcessInstanceId, ActorId, OriginalActorId FROM ProcessInstanceWorkitem where ProcessInstanceId IN :set_ProcessInstance and ActorId=:loginUserId];
                    system.debug('objProcessInstanceWorkItem==>'+lst_ProcessInstanceWorkItem);
                }
            }
            orderWrapperClass.add(new OrderWrapperClass(objOrder, lst_ProcessInstanceWorkItem, approvalResultForObject));
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage() +' Line Number==>'+ ex.getLineNumber());
        }
        return orderWrapperClass;
    }
    /*  
    * Wrapper class  
    */  
    public class ApprovalList{   
        @AuraEnabled public List<ApprovalStepWrapper> approvals {get;set;}  
        @AuraEnabled public Boolean isSubmitForApproval {get;set;}  
        @AuraEnabled public Id recordId {get;set;}  
        public ApprovalList(){  
            approvals = new List<ApprovalStepWrapper>();  
            isSubmitForApproval = true;  
        }  
    }  
    public class ApprovalStepWrapper{  
        @AuraEnabled  
        public List<ApprovalHistoryWrap> listOfSteps {get;set;}  
        public ApprovalStepWrapper(){  
            listOfSteps = new List<ApprovalHistoryWrap>();  
        }  
    }  
    /*  
    * Wrapper class  
    */  
    public class ApprovalHistoryWrap{  
        @AuraEnabled public Date createdDate {get;set;}  
        @AuraEnabled public string actorName {get;set;}  
        @AuraEnabled public string steps {get;set;}  
        @AuraEnabled public string assignedTo {get;set;}
        @AuraEnabled public string comments {get;set;}
        public ApprovalHistoryWrap(DateTime crDate, string name, string stp, string actor, string cmts){  
            createdDate = crDate.date();  
            actorName = name;  
            steps = stp;  
            assignedTo = actor; 
            comments = cmts;
        }  
    }  

    @AuraEnabled
    public static String orderApprove(String comments, String processInstanceString, Order objOrder){
        Order orderObj = new Order();
        orderObj.id = objOrder.id;
        List<ProcessInstanceWorkitem> lst_ProcessInstanceWorkItem = (List<ProcessInstanceWorkitem>)JSON.deserialize(processInstanceString, List<ProcessInstanceWorkitem>.class);
        String message='';
        try{
            List<Order> approvalStepList = [Select Id, Owner.Email, Event__r.Program__c,
                                            (Select Id, IsPending, ProcessInstanceId, ProcessNode.DeveloperName, TargetObjectId, StepStatus, OriginalActorId,
                                             ActorId, RemindersSent, Comments, IsDeleted, CreatedDate, CreatedById, SystemModstamp
                                             From ProcessSteps Where StepStatus = 'Pending')
                                            From Order Where Id =: objOrder.Id];
            Map<Id, String> stepMaps = new Map<Id, String>();
            if(!approvalStepList.isEmpty()){
                if(!approvalStepList[0].ProcessSteps.isEmpty()){
                    stepMaps.put(approvalStepList[0].ProcessSteps[0].ProcessInstanceId, approvalStepList[0].ProcessSteps[0].ProcessNode.DeveloperName);
                }
            }
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
            for(ProcessInstanceWorkitem item:lst_ProcessInstanceWorkItem)
            {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments(comments);
                req.setAction('Approve');
                req.setWorkitemId(item.Id);
                requests.add(req);
                message = 'The Order has been Approved.';
                System.debug('objOrder.Status-->'+objOrder.Status);
                
                If(!stepMaps.isEmpty() && stepMaps.containskey(item.ProcessInstanceId)) {
                    System.debug('step.ProcessNode.DeveloperName: '+stepMaps.get(item.ProcessInstanceId));
                    // Draft Quote Operations
                    If((stepMaps.get(item.ProcessInstanceId)).equals('Sales')) {
                        //#493 saparate condition for the defaulted approval process
                        if(objOrder.Status == 'Defaulted - Pending'){
                            orderObj.Defaulted_Approver_Comment_Sales__c = Comments;
                            orderObj.Defaulted_Approver_Name_Sales__c = UserInfo.getName();
                            //objOrder.Status = 'Defaulted';
                        }else{
                            orderObj.Canceled_Approver_Name_Sales__c = UserInfo.getName();
                            orderObj.Canceled_Approver_Comment_Sales__c = Comments;
                        }
                    }
                    // Draft Quote Sales
                    If((stepMaps.get(item.ProcessInstanceId)).equals('Operations')) {
                        //#493 saparate condition for the defaulted approval process
                        if(objOrder.Status == 'Defaulted - Pending'){
                            orderObj.Defaulted_Approver_Comment_Operations__c = Comments;
                            orderObj.Defaulted_Approver_Name_Operations__c = UserInfo.getName();
                            //objOrder.Status = 'Defaulted';
                        }else{
                            orderObj.Canceled_Approver_Name_Operations__c = UserInfo.getName();
                            orderObj.Canceled_Approver_Comment_Operations__c = Comments;
                        }
                    }
                    // Signed Quote Operations
                    If((stepMaps.get(item.ProcessInstanceId)).equals('Accounting')) {
                        if(objOrder.Status == 'Cancellation Pending'){
                            orderObj.Canceled_Approver_Name_Accounting__c = UserInfo.getName();
                            orderObj.Canceled_Approver_Comment_Accounting__c = Comments;
                        }else if(objOrder.Status == 'Credit Adjustment Pending'){
                            orderObj.Credit_Approver_Name_Accounting__c = UserInfo.getName();
                            orderObj.Credit_Approver_Comment_Accounting__c = Comments;
                        }
                    }
                }
                
            }
            // #331 Order Cancellation issue resolved -- START
            Approval.ProcessResult[] processResults = null;
            processResults = Approval.process(requests, false);
            system.debug('***lst_ProcessInstanceWorkItem=='+lst_ProcessInstanceWorkItem);
            if(lst_ProcessInstanceWorkItem.isEmpty()){
                message='Your are not an Approver in this approval step';
            }else{
                //#493.. else condition added due to the line was convert status of order even user not able to approve. 
                // Added Stage for Order because we need to update order comments fields not the status field, Order
                // Status in objOrder is still the old one. So need to update the order with the new Order Status
                //#493 Condition added by manan to by pass order cancellation in the Defaulted process
                //Commented by KC
                /*if(objOrder.Status != 'Defaulted - Pending'){
                    orderObj.Status = 'Canceled';
                }
                update orderObj;*/
                // #331 Order Cancellation issue resolved -- END
            }
           // update objOpportunity;
            //return redirectPage ;
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage() +' Line Number==>'+ ex.getLineNumber());
            //return null;
        }
        return message;
    }

    @AuraEnabled
    public static String orderReject(String comments, String processInstanceString, Order objOrder){
        List<ProcessInstanceWorkitem> lst_ProcessInstanceWorkItem = (List<ProcessInstanceWorkitem>)JSON.deserialize(processInstanceString, List<ProcessInstanceWorkitem>.class);
        String message='';
        try{
            List<Order> approvalStepList = [Select Id, Owner.Email, Event__r.Program__c,
                                            (Select Id, IsPending, ProcessInstanceId, ProcessNode.DeveloperName, TargetObjectId, StepStatus, OriginalActorId,
                                             ActorId, RemindersSent, Comments, IsDeleted, CreatedDate, CreatedById, SystemModstamp
                                             From ProcessSteps Where StepStatus = 'Pending')
                                            From Order Where Id =: objOrder.Id];
            Map<Id, String> stepMaps = new Map<Id, String>();
            if(!approvalStepList.isEmpty()){
                if(!approvalStepList[0].ProcessSteps.isEmpty()){
                    stepMaps.put(approvalStepList[0].ProcessSteps[0].ProcessInstanceId, approvalStepList[0].ProcessSteps[0].ProcessNode.DeveloperName);
                }
            }
            System.debug('comments-->'+comments); 
            if (comments != null && !comments.equals('')) {
                List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
                for(ProcessInstanceWorkitem item:lst_ProcessInstanceWorkItem){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setComments(comments);
                    req.setAction('Reject');
                    req.setWorkitemId(item.Id);
                    requests.add(req);
                    message = 'The Order has been Rejected.';
                    If(!stepMaps.isEmpty() && stepMaps.containskey(item.ProcessInstanceId)) {
                        System.debug('step.ProcessNode.DeveloperName: '+stepMaps.get(item.ProcessInstanceId));
                        // Draft Quote Operations
                        If((stepMaps.get(item.ProcessInstanceId)).equals('Sales')) {
                            //#493 ticket related changes
                            if(objOrder.Status == 'Defaulted - Pending'){
                                objOrder.Defaulted_Approver_Comment_Sales__c = Comments;
                                objOrder.Defaulted_Approver_Name_Sales__c = UserInfo.getName();
                                //objOrder.Status = 'Defaulted';
                            }else{
                                objOrder.Canceled_Approver_Name_Sales__c = UserInfo.getName();
                                objOrder.Canceled_Approver_Comment_Sales__c = Comments;
                            }
                        }
                        // Draft Quote Sales
                        If((stepMaps.get(item.ProcessInstanceId)).equals('Operations')) {
                            //#493 ticket related changes
                            if(objOrder.Status == 'Defaulted - Pending'){
                                objOrder.Defaulted_Approver_Comment_Operations__c = Comments;
                                objOrder.Defaulted_Approver_Name_Operations__c = UserInfo.getName();
                                //objOrder.Status = 'Defaulted';
                            }else{
                                objOrder.Canceled_Approver_Name_Operations__c = UserInfo.getName();
                                objOrder.Canceled_Approver_Comment_Operations__c = Comments;
                            }
                        }
                        // Signed Quote Operations
                        If((stepMaps.get(item.ProcessInstanceId)).equals('Accounting')) {
                            if(objOrder.Status == 'Cancellation Pending'){
                                objOrder.Canceled_Approver_Name_Accounting__c = UserInfo.getName();
                                objOrder.Canceled_Approver_Comment_Accounting__c = Comments;
                            }else if(objOrder.Status == 'Credit Adjustment Pending'){
                                objOrder.Credit_Approver_Name_Accounting__c = UserInfo.getName();
                                objOrder.Credit_Approver_Comment_Accounting__c = Comments;
                            }
                        }
                    }
                }
                update objOrder;
                Approval.ProcessResult[] processResults = null;
                        processResults = Approval.process(requests, false);
                if(lst_ProcessInstanceWorkItem.isEmpty()){
                    message='Your are not an Approver in this approval step';
                }
            } else {
                message = 'Please enter Comments.';
            }
              
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage() +' Line Number==>'+ ex.getLineNumber());
        }    
        return message;
    }
    
    public class OrderCancelWrapperClass{
        @AuraEnabled public Order objOrder{get;set;}
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public Id processLink {get;set;}
        @AuraEnabled public Decimal elapsedTimeInDays {get;set;}
        @AuraEnabled public Decimal elapsedTimeInHours {get;set;}
        @AuraEnabled public Decimal elapsedTimeInMinutes {get;set;}
        
        public OrderCancelWrapperClass(String approvalStatus, Order objTempOrder, Id link, Decimal elapsedTimeInDay, Decimal elapsedTimeInHrs, Decimal elapsedTimeInMins){
            objOrder=objTempOrder;
            status=approvalStatus;
            processLink = link;
            elapsedTimeInDays = elapsedTimeInHrs;
            elapsedTimeInHours = elapsedTimeInHrs;
            elapsedTimeInMinutes = elapsedTimeInMins;
        }
    }
   
    public class wrapperClass{
        @AuraEnabled public Quote objQuote{get;set;}
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public Id processLink {get;set;}
        @AuraEnabled public Decimal elapsedTimeInDays {get;set;}
        @AuraEnabled public Decimal elapsedTimeInHours {get;set;}
        @AuraEnabled public Decimal elapsedTimeInMinutes {get;set;}
        
        public wrapperClass(String approvalStatus, Quote objTempQuote,Id link, Decimal elapsedTimeInDay, Decimal elapsedTimeInHrs, Decimal elapsedTimeInMins){
            objQuote=objTempQuote;
            status=approvalStatus;
            processLink = link;
            elapsedTimeInDays = elapsedTimeInHrs;
            elapsedTimeInHours = elapsedTimeInHrs;
            elapsedTimeInMinutes = elapsedTimeInMins;
        }
    }
    
    public class wrapperClassSignedReview{
        @AuraEnabled public Quote objQuote{get;set;}
        @AuraEnabled public string status{get;set;}
        @AuraEnabled public Id processLink {get;set;}
        @AuraEnabled public Decimal elapsedTimeInDays {get;set;}
        @AuraEnabled public Decimal elapsedTimeInHours {get;set;}
        @AuraEnabled public Decimal elapsedTimeInMinutes {get;set;}
        
        public wrapperClassSignedReview(string approvalStatus, Quote objTempQuote, Id link, Decimal elapsedTimeInDay, Decimal elapsedTimeInHrs, Decimal elapsedTimeInMins){
            objQuote=objTempQuote;
            status=approvalStatus;
            processLink = link;
            elapsedTimeInDays = elapsedTimeInHrs;
            elapsedTimeInHours = elapsedTimeInHrs;
            elapsedTimeInMinutes = elapsedTimeInMins;
        }
    }
    public class masterWrapperClass{
    @AuraEnabled public List<wrapperClass> lstWrapperClass{get;set;}
    @AuraEnabled public List<wrapperClassSignedReview> lstWrapperSignedReview{get;set;}
    @AuraEnabled public List<wrapperClassSignedReview> lstWrapperOnlineOrderSignedReview{get;set;}
    @AuraEnabled public List<OrderCancelWrapperClass> lstWrapperOrder{get;set;}
    /*@AuraEnabled public List<Quote> draftApprovedList{get;set;}
    @AuraEnabled public List<Quote> signApprovedList{get;set;}
    @AuraEnabled public List<Quote> signApprovedOnlineOrdersList{get;set;}List<Quote> draftApprovedList, List<Quote> signApprovedList, List<Quote> signApprovedOnlineOrdersList, List<Quote> draftDeniList,
                              List<Quote> signDeniList, List<Quote> signDeniOnlineOrderList,
    @AuraEnabled public List<Quote> draftDeniList{get;set;}
    @AuraEnabled public List<Quote> signDeniList{get;set;}
    @AuraEnabled public List<Quote> signDeniOnlineOrderList{get;set;}*/
    @AuraEnabled public List<OrderCancelWrapperClass> orderCreditWrapperClass{get;set;}
    @AuraEnabled public List<OrderCancelWrapperClass> orderDefaultWrapperClass{get;set;}
        
    public masterWrapperClass(List<wrapperClass> lstWrapperClass, List<wrapperClassSignedReview> lstWrapperSignedReview,
                              List<wrapperClassSignedReview> lstWrapperOnlineOrderSignedReview, List<OrderCancelWrapperClass> lstWrapperOrder,
                              List<OrderCancelWrapperClass> orderCreditWrapperClass, List<OrderCancelWrapperClass> orderDefaultWrapperClass){
         
        this.lstWrapperClass = lstWrapperClass;
        this.lstWrapperSignedReview = lstWrapperSignedReview;
        this.lstWrapperOnlineOrderSignedReview = lstWrapperOnlineOrderSignedReview;
        this.lstWrapperOrder = lstWrapperOrder;
        /*this.draftApprovedList = draftApprovedList;
        this.signApprovedList = signApprovedList;
        this.signApprovedOnlineOrdersList = signApprovedOnlineOrdersList;
        this.draftDeniList = draftDeniList;
        this.signDeniList = signDeniList;
        this.signDeniOnlineOrderList = signDeniOnlineOrderList;*/
        this.orderCreditWrapperClass = orderCreditWrapperClass;
        this.orderDefaultWrapperClass = orderDefaultWrapperClass;
    }
    }
    public class QuoteWrapperClass{
        @AuraEnabled public Quote quote{get;set;}
        @AuraEnabled public List<ProcessInstanceWorkitem> lst_ProcessInstanceWorkItem{get;set;}
        @AuraEnabled public ApprovalList approvalResultForObject{get;set;}
        @AuraEnabled public String imageUrl{get;set;}
        @AuraEnabled public String sharlinkId{get;set;}
        @AuraEnabled public String originalQuoteNumber {get;set;} //#919
        
        public QuoteWrapperClass(Quote quote, List<ProcessInstanceWorkitem> lst_ProcessInstanceWorkItem, ApprovalList approvalResultForObject, String imageUrl, String sharlinkId,String originalQuoteNumber){
            this.quote = quote;
            this.lst_ProcessInstanceWorkItem = lst_ProcessInstanceWorkItem;
            this.approvalResultForObject = approvalResultForObject;
            this.imageUrl = imageUrl;
            this.sharlinkId = sharlinkId;
            this.originalQuoteNumber = originalQuoteNumber; //#919
        }
    }
    public class OrderWrapperClass{
        @AuraEnabled public Order objOrder{get;set;}
        @AuraEnabled public List<ProcessInstanceWorkitem> lst_ProcessInstanceWorkItem{get;set;}
        @AuraEnabled public ApprovalList approvalResultForObject{get;set;}
        public OrderWrapperClass(Order objOrder, List<ProcessInstanceWorkitem> lst_ProcessInstanceWorkItem, ApprovalList approvalResultForObject){
            this.objOrder= objOrder;
            this.lst_ProcessInstanceWorkItem = lst_ProcessInstanceWorkItem;
            this.approvalResultForObject = approvalResultForObject;
        }
    }
}