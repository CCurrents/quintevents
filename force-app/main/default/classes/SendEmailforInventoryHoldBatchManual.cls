/**
 * @File Name          : InventoryHoldBatchClass.cls
 * @Description        : This class use for sending email to the manual inventory hold's owner 
 * @Author             : sagarj@addonblue.com
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    01/10/2021   sagarj@addonblue.com     Initial Version
**/
public with sharing class SendEmailforInventoryHoldBatchManual implements Database.Batchable<String> , Database.Stateful{

    public Map<String,Inventory_Transaction__c>  inventoryholdMap;
    public string htmlbody ='';
    public String baseUrl;
    //Constructor
    public SendEmailforInventoryHoldBatchManual ( Map<String,Inventory_Transaction__c> inventoryholdMap) {
        
        this.inventoryholdMap = inventoryholdMap;
        this.baseurl = URL.getSalesforceBaseUrl().toExternalForm();
       
    }

    //Start
    public Iterable<String> start(Database.BatchableContext BC) {
        List<String> alldata = new List<String> ();
        alldata.addall(this.inventoryholdMap.keyset());
        return alldata;
        
    }

    public void execute(Database.BatchableContext info, List<String> strings) {

        if(htmlbody == '') {
            htmlbody = 'Hello, <br/><br/> The following products have inventory holds that are set to expire on '+string.valueOf( inventoryholdMap.get(strings[0]).Hold_Release_Date__c);
            htmlbody = htmlbody  + ' . Please take appropriate action if necessary. <br/> <br/>';
        }
        for(String productid : strings) {
            Inventory_Transaction__c itr = inventoryholdMap.get(productid);
            htmlbody = htmlbody + itr.Product__r.Primary_Price_Book__r.name+' - '+itr.product__r.Name+ ' - '+'<a href="'+baseurl+'/'+itr.product__c+'">'+itr.product__r.Name+'</a> <br/>';   
        }
    }

    public void finish(Database.BatchableContext info) {
        if(htmlbody != '') {
            string [] toaddress= new String [] {};
            toaddress.addall(system.label.inventoryholdemailnotification.split(';'));
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Expiring Inventory Holds');
            email.setHtmlBody(htmlbody);
            email.setToAddresses(toaddress);
            Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
        }

    }
}