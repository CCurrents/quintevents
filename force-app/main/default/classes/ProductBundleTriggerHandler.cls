/**
 * @File Name          : ProductBundleTriggerHandler.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/15/2020, 12:03:34 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/15/2020   jagrawal@addonblue.com     Initial Version
**/
global class ProductBundleTriggerHandler extends TriggerHandler{
    
    /**
    * @description Constructor
    * @author jagrawal@addonblue.com | 5/15/2020 
    * @return void 
    **/
	public ProductBundleTriggerHandler() {
        //For stopping the recursion
        Trigger_Settings__c triggerSetting = Trigger_Settings__c.getInstance('Products_Bundle__c');
        this.setMaxLoopCount((Integer)triggerSetting.Max_Loop_Count__c);
    }
    
    /**
    * @description After Insert Trigger Event Handling method
    * @author jagrawal@addonblue.com | 5/15/2020 
    * @return void 
    **/
    public override void afterInsert() {
        ProductBundleTriggerHelper objProductBundleTriggerHelper = new ProductBundleTriggerHelper();
    }
    
    /**
    * @description After Delete Trigger Event Handling method
    * @author jagrawal@addonblue.com | 5/15/2020 
    * @return void 
    **/
    public override void afterDelete() {
        ProductBundleTriggerHelper objProductBundleTriggerHelper = new ProductBundleTriggerHelper();
    }
}