/**
* @File Name          : DocuSignStatusTriggerHelper.cls
* @Description        : 
* @Author             : jthakkar@addonblue.com
* @Group              : 
* @Last Modified By   : fsuraitawala@addonblue.com
* @Last Modified On   : 08-12-2021
* @Modification Log   : 
* Ver       Date            Author              Modification
* 1.0    3/3/2020     jthakkar@addonblue.com     Initial Version
* 1.1    05/05/2021   kchavda@addonblue.com      #242 Quote Envelope Status became "Completed" but Quote status did not update.
* 1.2    08/11/2021   fsuraitawala@addonblue.com #1036 Update "Pending Credit/Refund Addendum" field on Order
**/
global class DocuSignStatusTriggerHelper{
          
    public static String accountId = '';
    public static String userId = ''; // Same for Production and Sandbox
    public static String password = ''; 
    public static String integratorsKey = ''; // Same for Production and Sandbox
    public static String webServiceUrl = '';
    
    private Map<Id, dsfs__DocuSign_Status__c> newDSMap; 
    private Map<Id, dsfs__DocuSign_Status__c> oldDSMap;
    private List<dsfs__DocuSign_Status__c> newDSList;
    private List<dsfs__DocuSign_Status__c> oldDSList;
    
    public DocusignSOAPApi2__mdt docusignSOAPApi2;
    
    public DocuSignStatusTriggerHelper(){
        this.newDSMap = (Map<Id, dsfs__DocuSign_Status__c>) Trigger.newMap;
        this.oldDSMap = (Map<Id, dsfs__DocuSign_Status__c>) Trigger.oldMap;
        this.newDSList = (List<dsfs__DocuSign_Status__c>) Trigger.new;
        this.oldDSList = (List<dsfs__DocuSign_Status__c>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Before Insert!');
            }
            
            when BEFORE_UPDATE {
                System.debug('In Before Update!');                
            }
            
            when BEFORE_DELETE {
                System.debug('In Before Delete!');
            }
            
            when AFTER_INSERT {
                OnAfterUpdate(oldDSList, newDSList, oldDSMap, newDSMap);
                Organization s = [SELECT IsSandbox FROM Organization LIMIT 1];
                if(s.IsSandbox == true){
                    docusignSOAPApi2 = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Environment__c, accountId__c, userId__c, password__c, integratorsKey__c, webServiceUrl__c from DocusignSOAPApi2__mdt WHERE Environment__c =: 'Sandbox'];
                }else{
                    docusignSOAPApi2 = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Environment__c, accountId__c, userId__c, password__c, integratorsKey__c, webServiceUrl__c from DocusignSOAPApi2__mdt WHERE Environment__c =: 'Production'];
                }
                
                accountId = docusignSOAPApi2.accountId__c;
                userId = docusignSOAPApi2.userId__c;
                password = docusignSOAPApi2.password__c;
                integratorsKey = docusignSOAPApi2.integratorsKey__c;
                webServiceUrl = docusignSOAPApi2.webServiceUrl__c;
                
                OnAfterInsert(newDSList, newDSMap);
            }
            
            when AFTER_UPDATE {                
                OnAfterUpdate(oldDSList, newDSList, oldDSMap, newDSMap);
            }
            
            when AFTER_DELETE {
                System.debug('In After Delete!');
            }
            
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
        
    
    /**
    * @description  : after insert trigger call
    * @author       : jthakkar@addonblue.com | 3/3/2020 
    * @param        : 
    * @return       : 
    **/       
    public static void OnAfterInsert(dsfs__DocuSign_Status__c[] newList,Map<Id, dsfs__DocuSign_Status__c> newMap) {
        //Quotes from envelopes which needs to be checked for existing docusign status records
        List<Id> quotesTocheckExistingRecords = new List<Id>();
        List<Id> docuSignStatusNewIds = new List<Id>();
        // Loop through Docusign and collect quote ids
        for (dsfs__DocuSign_Status__c dsStatus : newList) {
            if(dsStatus.Standard_Quote__c!= null){
                quotesTocheckExistingRecords.add(dsStatus.Standard_Quote__c);
                docuSignStatusNewIds.add(dsStatus.id);
            }
        }
        
        if(quotesTocheckExistingRecords.size()> 0){
            VoidEnvelope(quotesTocheckExistingRecords,docuSignStatusNewIds);
        }
    }
    
    /**
    * @description  : after update trigger call
    * @author       : jthakkar@addonblue.com | 3/3/2020 
    * @param        : 
    * @return       : 
    **/   
    public static void OnAfterUpdate(dsfs__DocuSign_Status__c[] oldList, dsfs__DocuSign_Status__c[] newList, Map<Id, dsfs__DocuSign_Status__c> oldMap, Map<Id, dsfs__DocuSign_Status__c> newMap) {
        //Quotes from envelopes which needs to be submitted for approval check.
        List<Id> quotesToSubmitForApprovalCheck = new List<Id>();
        Map<Id, Boolean> OpportunityIds = new Map<Id, Boolean>();
        // Check if envelope don't have counter singee if so submit quote for approval check.
        for (dsfs__DocuSign_Status__c dsStatus : newList) {
            if ((dsStatus.dsfs__Envelope_Status__c).equals('Completed') && 
                (Trigger.IsInsert || (Trigger.IsUpdate && !(oldMap.get(dsStatus.Id).dsfs__Envelope_Status__c).equals('Completed'))) &&
                !(dsStatus.Counter_Signer_Envelope__c)) {
                    // Submit for approval check
                    quotesToSubmitForApprovalCheck.add(dsStatus.Standard_Quote__c);
            }
            //#1036 Update "Pending Credit/Refund Addendum" field on Order -- START
            if((Trigger.IsInsert || (Trigger.IsUpdate && dsStatus.dsfs__Envelope_Status__c != oldMap.get(dsStatus.Id).dsfs__Envelope_Status__c)) &&
               ((dsStatus.dsfs__Subject__c).equals('Transfer to 2021 Event Addendum') || (dsStatus.dsfs__Subject__c).equals('Reimbursement Addendum') || 
                (dsStatus.dsfs__Subject__c).equals('Transfer to Future Event Addendum'))) {
                if(dsStatus.dsfs__Opportunity__c != null) {
                    if((dsStatus.dsfs__Envelope_Status__c).equals('Sent') || (dsStatus.dsfs__Envelope_Status__c).equals('Delivered')){
                        OpportunityIds.put(dsStatus.dsfs__Opportunity__c, true);
                    } else {
                        OpportunityIds.put(dsStatus.dsfs__Opportunity__c, false);
                    }
                }
            }
            //#1036 Update "Pending Credit/Refund Addendum" field on Order -- END
        }
        if(OpportunityIds.size() > 0){
            updateAddendumCheckOnOrder(OpportunityIds);
        }
        system.debug('###'+quotesToSubmitForApprovalCheck);
        // Submit for approval check
        if (quotesToSubmitForApprovalCheck.size() > 0) {
            // Convert set to list, because updateQuoteStatusDocuSign takes list as a parameter.
            List<Id> quoteIdsList = new List<Id>();
            quoteIdsList.addAll(quotesToSubmitForApprovalCheck);            
            // Update Quote
            QuoteUtility.updateQuoteStatusDocuSign(quoteIdsList, 'DocuSign-Trigger-AfterUpdate');
        } 
        
        /*List<Id> quoteIds = new List<Id>();
        Set<Id> lstSentQuoteIds = new Set<Id>(); 
        // Get Quote Ids
        for (dsfs__DocuSign_Status__c currentDocuSignStatus : newList) {
            // Only if its "Compeleted"
            if ((currentDocuSignStatus.dsfs__Envelope_Status__c).equals('Completed')) {
                if(currentDocuSignStatus.Quote__c != null) {
                    quoteIds.add(currentDocuSignStatus.Quote__c);
                }
            }
        }*/
    }
    /**
    * @description  : #1036 Update "Pending Credit/Refund Addendum" field on Order
    * @author       : fsuraitawala@addonblue.com
    * @param        : 
    * @return       : 
    **/
    public static void updateAddendumCheckOnOrder(Map<Id, Boolean> mapOpportunity) {
        List<Order> lstOrder = new List<Order>();
        for(Opportunity objOpp: [Select Id, (Select Id, Pending_Credit_Refund_Addendum__c FROM Orders WHERE Status = 'Active')
                                 FROM Opportunity WHERE Id IN :mapOpportunity.keyset()]) {
            for(Order objOrder: objOpp.Orders) {
                if(objOrder.Pending_Credit_Refund_Addendum__c != mapOpportunity.get(objOpp.Id)) {
                    objOrder.Pending_Credit_Refund_Addendum__c = mapOpportunity.get(objOpp.Id);
                    lstOrder.add(objOrder);
                }
            }
        }
        if(lstOrder.size() > 0){
            update lstOrder;
        }
    }
    /**
    * @description  : future method to send an envelope 
    * @author       : jthakkar@addonblue.com | 3/3/2020 
    * @param        : 
    * @return       : 
    **/    
    @future(callout=true)
    public static void VoidEnvelope(List<Id> quotesTocheckExistingRecords,  List<Id> docuSignStatusNewIds){
        List<dsfs__DocuSign_Status__c> existingDocuSignStatusRecords = new List<dsfs__DocuSign_Status__c>();
        If(test.isRunningTest()){
            existingDocuSignStatusRecords = [select id,dsfs__Envelope_Status__c,Standard_Quote__c,dsfs__DocuSign_Envelope_ID__c,dsfs__Declined_Reason__c,dsfs__Voided_Reason__c from dsfs__DocuSign_Status__c where id in:docuSignStatusNewIds ];    
        }else{
            existingDocuSignStatusRecords = [select id,dsfs__Envelope_Status__c,Standard_Quote__c,dsfs__DocuSign_Envelope_ID__c,dsfs__Declined_Reason__c,dsfs__Voided_Reason__c from dsfs__DocuSign_Status__c where id Not in:docuSignStatusNewIds and Standard_Quote__c in:quotesTocheckExistingRecords and dsfs__Envelope_Status__c != 'Completed' and Counter_Signer_Envelope__c = false ];
        }        
        if(existingDocuSignStatusRecords.size()> 0){          
            for(dsfs__DocuSign_Status__c dsStatus : existingDocuSignStatusRecords){              
                if(dsStatus.dsfs__DocuSign_Envelope_ID__c!= null){ 
                    
                    DocusignSOAPApi2.APIServiceSoap dsApiSend = new DocusignSOAPApi2.APIServiceSoap();
                    dsApiSend.endpoint_x = webServiceUrl;
                    String auth = '<DocuSignCredentials><Username>'+ userId 
                        +'</Username><Password>' + password 
                        + '</Password><IntegratorKey>' + integratorsKey 
                        + '</IntegratorKey></DocuSignCredentials>';
                    System.debug('Setting authentication to: ' + auth);
                    dsApiSend.inputHttpHeaders_x = new Map<String, String>();
                    dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication',auth);
                    
                    Boolean apiVoidSuccess;
                    try {
                        if(!test.isRunningTest()){
                            DocusignSOAPApi2.VoidEnvelopeStatus ves = dsApiSend.VoidEnvelope(dsStatus.dsfs__DocuSign_Envelope_ID__c,'Duplicate Envelope');
                            system.debug('###'+ves);
                            apiVoidSuccess = ves.VoidSuccess; 
                        }                     
                    } catch ( CalloutException e) {
                        System.debug('Exception - ' + e);                           
                    }
                }                
            }
        }
    }
    
    /**
    * @description  : future method to send an envelope from opportunity
    * @author       : jthakkar@addonblue.com | 3/3/2020 
    * @param        : 
    * @return       : 
    **/        
    @future(callout=true)
    public static void VoidEnvelopeFromOpp(List<Id> quotesTocheck){
        System.debug('----inside VoidEnvelopeFromOpp----');
        List<dsfs__DocuSign_Status__c> docuSignStatusRecords = new List<dsfs__DocuSign_Status__c>();
        if(Test.isRunningTest()){
            docuSignStatusRecords = [select id,dsfs__Envelope_Status__c,Standard_Quote__c,dsfs__DocuSign_Envelope_ID__c,dsfs__Declined_Reason__c,dsfs__Voided_Reason__c from dsfs__DocuSign_Status__c limit 1];
        }else{
            docuSignStatusRecords = [select id,dsfs__Envelope_Status__c,Standard_Quote__c,dsfs__DocuSign_Envelope_ID__c,dsfs__Declined_Reason__c,dsfs__Voided_Reason__c from dsfs__DocuSign_Status__c where Standard_Quote__c in:quotesTocheck and dsfs__Envelope_Status__c != 'Completed'];    
        }        
        System.debug('----inside docuSignStatusRecords----'+docuSignStatusRecords);
        if(docuSignStatusRecords.size()> 0){          
            for(dsfs__DocuSign_Status__c dsStatus : docuSignStatusRecords){              
                if(dsStatus.dsfs__DocuSign_Envelope_ID__c!= null){ 
                    System.debug('----inside sStatus.dsfs__DocuSign_Envelope_ID__c----'+dsStatus.dsfs__DocuSign_Envelope_ID__c);              
                    DocusignSOAPApi2.APIServiceSoap dsApiSend = new DocusignSOAPApi2.APIServiceSoap();
                    dsApiSend.endpoint_x = webServiceUrl;
                    String auth = '<DocuSignCredentials><Username>'+ userId
                        +'</Username><Password>' + password 
                        + '</Password><IntegratorKey>' + integratorsKey 
                        + '</IntegratorKey></DocuSignCredentials>';
                    System.debug('Setting authentication to: ' + auth);
                    dsApiSend.inputHttpHeaders_x = new Map<String, String>();
                    dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication',auth);
                    
                    Boolean apiVoidSuccess;
                    try {
                        if(!test.isRunningTest()){
                            DocusignSOAPApi2.VoidEnvelopeStatus ves = dsApiSend.VoidEnvelope(dsStatus.dsfs__DocuSign_Envelope_ID__c,'Canceled Envelope');                        
                            apiVoidSuccess = ves.VoidSuccess;
                        }                     
                    } catch ( CalloutException e) {
                        System.debug('Exception - ' + e);                           
                    }
                }                
            }
        }
    }
}