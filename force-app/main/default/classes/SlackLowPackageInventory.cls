/**
 * @description       : 
 * @author            : Jheel Agrawal
 * @group             : 
 * @last modified on  : 07-06-2021
 * @last modified by  : fsuraitawala@addonblue.com
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   11-19-2020   Jheel Agrawal   Initial Version
**/
public class SlackLowPackageInventory implements Queueable,Database.AllowsCallouts {
    public List<Id> productIds;
    
    public SlackLowPackageInventory(List<Id> productIds){
        this.productIds = productIds;
    }

    @invocableMethod(label='SlackLowPackageInventory' description='Send Slack message for Low Inventory for Package type Products.')
    public static void invocableMethod(List<Id> productIds) {
        System.debug('productIds@@'+productIds);
        System.enqueueJob(new SlackLowPackageInventory(productIds));
    }
    
    public void execute(QueueableContext context) {
        List<Product2> lstProduct = new List<Product2>([Select Id, Primary_Price_Book__c, Primary_Price_Book__r.Name, Primary_Price_Book__r.Slack_Channel_Id__c, Name, Package_Inventory__c from Product2 where Id In :productIds]);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        for(Product2 prod : lstProduct){
            String strPost = 'Inventory is running low for following Package,\n' +
                             'PriceBook: ' + prod.Primary_Price_Book__r.Name + '\n' +
                             'Package: <'+System.URL.getSalesforceBaseURL().toExternalForm()+'/'+prod.Id+'|'+prod.Name+'>\n' +
                             'Current Inventory: ' + prod.Package_Inventory__c;
                                
            strPost = EncodingUtil.urlEncode(strPost, 'UTF-8');
			System.debug('slackAPI-->'+slackAPI);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/chat.postMessage?token='+ slackAPI.Slack_API_Token__c + '&pretty=1&channel=' + prod.Primary_Price_Book__r.Slack_Channel_Id__c + '&text=' + strPost);
            req.setMethod('POST');
            req.setHeader('Content-type','application/json');
            Http http = new Http();
            if(!Test.isRunningTest()){ HttpResponse res = http.send(req);
                System.debug('response plain: ' + res);
                System.debug('response Body: ' + res.getBody());
            }
        }
     }
}