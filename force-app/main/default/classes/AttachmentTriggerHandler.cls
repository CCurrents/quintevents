/**
 * @File Name          : AttachmentTriggerHandler.cls
 * @Description        : Handle trigger's events of Attachment object
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 3/30/2020
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    3/30/2020   kchavda@addonblue.com     Initial Version
**/
public class AttachmentTriggerHandler extends TriggerHandler {
    
    /**
    * @description: Constructor
    * @author: kchavda@addonblue.com
    **/
    public AttachmentTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Attachment');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    
    /**
    * @description: After insert event of trigger
    * @author: kchavda@addonblue.com
    * @return: void 
    **/
    public override void afterInsert() {
        AttachmentTriggerHelper objAttachmentTriggerHelper = new AttachmentTriggerHelper();
    }
    
    
}