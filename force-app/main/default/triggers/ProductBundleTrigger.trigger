/**
 * @File Name          : ProductBundleTrigger.trigger
 * @Description        : Trigger for Product Bundle object
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/15/2020, 12:03:34 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/15/2020   jagrawal@addonblue.com     Initial Version
**/
trigger ProductBundleTrigger on Products_Bundle__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Products_Bundle__c');
    if(!triggerSetting.Deactivate__c){
        new ProductBundleTriggerHandler().run();
    }
}