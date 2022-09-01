/**
 * @File Name          : AttachmentTriggerTest .cls
 * @Description        : Test class for AttachmentTrigger classes
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 03/30/2020
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    03/30/2020   kchavda@addonblue.com     Initial Version
**/
@isTest
private class AttachmentTriggerTest{
    
    /**
    * @description  : 
    * @author       : kchavda@addonblue.com
    * @return       : void
    **/
    @isTest static void testMethod_one() {
        TestDataFactory.createTriggerSettingsEntry();
        
        List<zkmulti__MCShipment__c> lstmcShipment  = TestDataFactory.createMCShipment(1);
        List<Attachment> lstAttachments = new List<Attachment>();
        for(integer i = 0; i<1; i++) {
            attachment attachment = new Attachment();
            attachment.Body = Blob.valueOf('retsd');
            attachment.Name = String.valueOf('International-Forms.pdf');
            attachment.ParentId = lstmcShipment[i].ID;
            lstAttachments.add(attachment); 
        }
        Utility.processRecords(lstAttachments, 'insert');        
    }
}