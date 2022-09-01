/**
 * @File Name          : QuoteTrigger.trigger
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/18/2020, 3:18:40 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/3/2020   jagrawal@addonblue.com     Initial Version
 * 1.1    8/3/2020   lpanchal@addonblue.com     Code Reviewed and added Comments 
 * 1.2    9/3/2020   jagrawal@addonblue.com     Updated the code and implemented the Existing logic into proper place as per the Trigger Framework
 * 1.3    6/18/2020  jagrawal@addonblue.com     Added Trigger Context events like after delete and after undelete
**/
trigger QuoteTrigger on Quote (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Quote');
    if(!triggerSetting.Deactivate__c){
        new QuoteTriggerHandler().run();
    }
}