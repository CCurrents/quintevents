/**
* @File Name          : QE_Intacct_AttachmentCalloutBatch.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : Lovel Panchal
* @Last Modified On   : 5/27/2020, 4:55:07 PM
* @Modification Log   : 
* Ver       Date            Author                  Modification
* 1.0    1/20/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
* 1.1       3/4/2020        jagrawal@addonblue.com Updated Class Name and the referenced class name
**/
public class IntacctAttachmentBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{  
    Id quoteId;
    Id orderId;
    RequestResponse_Log__c objRequestResponse_Log =  new RequestResponse_Log__c();
    public IntacctAttachmentBatch(Id orderId,Id quoteId){
        this.quoteId = quoteId;
        this.orderId = orderId;
    }  
    public Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'Select Id,ParentId, Name,body,ContentType From Attachment a where parentid =: QuoteId limit 1';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Attachment> scope){
        if(!scope.isEmpty()){
            List<Order> ord = new List<Order>([Select Id,QuoteAttachmentId__c from order where id =: orderId]);
            if(ord.size()>0 && ord[0].QuoteAttachmentId__c == null){
                IntacctOrderSyncBatchHelper helper = new IntacctOrderSyncBatchHelper();
                objRequestResponse_Log = (RequestResponse_Log__c)helper.createAttachmentXML(orderId);
            }
        }
    }
    public void finish(Database.BatchableContext BC){
        if(objRequestResponse_Log.Status_Code__c == '200') {
            Order objOrder = new Order();
            objOrder.Id = orderId;
            objOrder.QuoteAttachmentId__c = quoteId;
            objOrder.Intacct_Status__c = 'Attachment Synced';
             Utility.processRecords(objOrder, 'update');
        }
    }
}