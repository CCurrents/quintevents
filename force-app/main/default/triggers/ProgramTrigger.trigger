/**
 * @File Name          : ProgramTrigger.trigger
 * @Description        : This is Trigger on Program object.
 * @Author             : vaibhav.khopade@addonblue.com
 * @Group              : 
 * @Last Modified By   : vaibhav.khopadea@addonblue.com
 * @Last Modified On   : 05-23-2022
 * @Modification Log   : 
 * Ver       Date            Author                  		Modification
 * 1.0    05/23/2022   vaibhav.khopade@addonblue.com     	Initial Version, created for issue 1194

**/

trigger ProgramTrigger on Program__c (after update) {
Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Program__c');
    if(!triggerSetting.Deactivate__c){
        new ProgramTriggerHandler().run();
    } 
    //new ProgramTriggerHandler().run();
}