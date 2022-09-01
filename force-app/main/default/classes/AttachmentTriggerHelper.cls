/**
 * @File Name          : AttachmentTriggerHelper.cls
 * @Description        : AttachmentTriggerHandler helper
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 3/30/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    3/30/2020   kchavda@addonblue.com     Initial Version
**/
public with sharing class AttachmentTriggerHelper {

    private Map<Id, Attachment> newAttachmentMap; 
    private Map<Id, Attachment> oldAttachmentMap;
    private List<Attachment> newAttachmentList;
    private List<Attachment> oldAttachmentList;


    public AttachmentTriggerHelper() {
        
        this.newAttachmentMap = (Map<Id, Attachment>) Trigger.newMap;
        this.oldAttachmentMap = (Map<Id, Attachment>) Trigger.oldMap;
        this.newAttachmentList = (List<Attachment>) Trigger.new;
        this.oldAttachmentList = (List<Attachment>) Trigger.old;
        
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
                System.debug('In After Insert!');
                onAfterInsertAttachment();
            }
            
            when AFTER_UPDATE {
                System.debug('In After Update!');
                
            }
            
            when AFTER_DELETE {
                System.debug('In After Delete!');
            }
            
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            
            when else {
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    
    /**
    * @description  : To delete commercial invoices for domestic shipping
    * @author       : kchavda@addonblue.com
    * @param        : 
    * @return       : void 
    **/
    public void onAfterInsertAttachment() {
        set<Id> setmcShipments = new set<Id>();
        set<Id> setmcShipmentsIds = new set<Id>();
        for(Attachment att: newAttachmentList){
            String objectName = string.valueof(att.parentId.getsobjecttype());
            if(objectName == 'zkmulti__MCShipment__c'){
                setmcShipmentsIds.add(att.parentId);
            }
        }
        for (zkmulti__MCShipment__c mcship: [Select id,zkmulti__Recipient_Country__c from zkmulti__MCShipment__c where id in:setmcShipmentsIds and zkmulti__Recipient_Country__c  = 'US']) {
            setmcShipments.add(mcship.id);
        }
        
        List<Attachment> lstAttachmentsToDelete = New List<Attachment>([Select id from attachment where parentid In: setmcShipments and Name = 'International-Forms.pdf' and Id in: newAttachmentList]);
        if(lstAttachmentsToDelete.size()>0) Delete lstAttachmentsToDelete;
    }

}