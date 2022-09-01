/**
 * @File Name          : InventoryHoldBatchClass.cls
 * @Description        : This class use for sending email to the Auto inventory hold's owner 
 * @Author             : sagarj@addonblue.com
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    01/10/2021   sagarj@addonblue.com     Initial Version
**/
public with sharing class SendEmailforInventoryHoldBatchAuto implements Database.Batchable<String> {

    public Map<String,List<Inventory_Transaction__c>> inventoryholdMap;

    //Constructor
    public SendEmailforInventoryHoldBatchAuto ( Map<String,List<Inventory_Transaction__c>> inventoryholdMap) {
        
        this.inventoryholdMap = inventoryholdMap;
       
    }

    //Start Method
    public Iterable<String> start(Database.BatchableContext BC) {
        List<String> alldata = new List<String> ();
        alldata.addall(this.inventoryholdMap.keyset());
        return alldata;
        
    }

    public void execute(Database.BatchableContext info, List<String> strings) {

        for(String quoteID : strings) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            string [] toaddress= new String [] {};
            Inventory_Transaction__c itr = inventoryholdMap.get(quoteid)[0];
            toaddress.add(itr.quote__r.owner.email);
            
        
            email.setSubject('Inventory Hold Expiring Soon');
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            String htmlbody = 'Hello, <br/><br/> Your quote for '+itr.quote__r.account.name +' for ';
            htmlbody = htmlbody  + itr.quote__r.Pricebook2.name + ' has an inventory hold that will be expiring on ';
            htmlbody = htmlbody + string.valueOf(itr.Hold_Release_Date__c);
            htmlbody = htmlbody + ' .If you need to extend this hold, you’ll need to do a change order and adjust the hold expiration date. Any requested extensions will require approval.';
            htmlbody = htmlbody + ' <br/> <br/> Quote Link : '+'<a href="'+baseurl+'/'+itr.quote__c+'">'+itr.quote__r.Name+'</a>';
            
            email.setHtmlBody(htmlbody);
        
            if(Test.isrunningTest()) {
                toaddress= new String [] {};
                toaddress.add('sagar.jogi@addonblue.com');
            }
            email.setToAddresses(toaddress);
        
            
            Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});

        }
    }

    public void finish(Database.BatchableContext info) {}
}