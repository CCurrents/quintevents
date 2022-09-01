/**
 * @File Name          : InventoryHoldBatchClass.cls
 * @Description        : This class use for sending email to the inventory hold's owner and it's quote's owner
 * @Author             : sagarj@addonblue.com
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    01/10/2021   sagarj@addonblue.com     Initial Version
**/
global class InventoryHoldBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    Map<String,List<Inventory_Transaction__c>> autoinventoryhold = new Map<String,List<Inventory_Transaction__c>> ();
    Map<String,Inventory_Transaction__c> manualinventoryhold = new Map<String,Inventory_Transaction__c> ();
 
    //Start Method to query the data
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date toDate = System.today();
        String recordtypeName = 'Inventory_Hold';
        String query = 'SELECT id,ownerid,Hold_Release_Date_Prior_3_days__c,Hold_Release_Date__c,recordtype.name,owner.email,quote__c,quote__r.owner.email,';
        query = query + 'quote__r.pricebook2.name,Product__c,quote__r.account.name,quote__r.name,product__r.Primary_Price_Book__r.Name,product__r.Name ';
        query = query + 'from Inventory_Transaction__c where ';
        if(!Test.isrunningTest()) {
            query = query + ' Hold_Release_Date_Prior_3_days__c =:toDate AND ';
        }
        query = query + ' RecordType.Developername =:recordtypeName order by Product__c ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Inventory_Transaction__c> scope){
        for(Inventory_Transaction__c itr : scope) {
            
            //Block for auto inventory hold
            if(itr.quote__c != null) {
                List<Inventory_Transaction__c> itrlist = new List<Inventory_Transaction__c> ();
                if(autoinventoryhold.containskey(itr.quote__c)) {
                    itrlist = autoinventoryhold.get(itr.quote__c);
                }
                itrlist.add(itr);
                autoinventoryhold.put(itr.quote__c,itrlist);
            } else { //Block for manual inventory hold
                List<Inventory_Transaction__c> itrlist = new List<Inventory_Transaction__c> ();
                if(!manualinventoryhold.containskey(itr.product__c)) {
                    manualinventoryhold.put(itr.product__c, itr);
                }
                
            }
        }
    }

    global void finish(Database.BatchableContext BC){

        //Calling batch class for sending email to auto inventory hold
        if(autoinventoryhold != null && autoinventoryhold.size() > 0) {
            SendEmailforInventoryHoldBatchAuto obj = new SendEmailforInventoryHoldBatchAuto(autoinventoryhold);
            Database.executebatch(obj,200);
        }

        //Calling batch class for sending email to manual inventory hold
        if(manualinventoryhold != null && manualinventoryhold.size() > 0) {
            SendEmailforInventoryHoldBatchManual obj = new SendEmailforInventoryHoldBatchManual(manualinventoryhold);
            Database.executebatch(obj,200);
        }
    }
}