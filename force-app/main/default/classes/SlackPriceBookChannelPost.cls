/**
 * @File Name          : SlackPriceBookChannelPost.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 07-06-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/23/2020   jagrawal@addonblue.com     Initial Version
 * 1.1    11/19/2020   jagrawal@addonblue.com     #624 Fixed Inventory field for slack message issue
 * 1.2    03/04/2021   cshah@addonblue.com        #815 Slack Message for Low Inventory should include "Room Type" field value as well for "Hotel Stay" products.
 * 1.3    07/06/2021   fsuraitawala@addonblue.com #1012 Slack Notifications Change
**/
public with sharing class SlackPriceBookChannelPost implements Queueable,Database.AllowsCallouts {
    public List<Id> productIds = new List<Id>();

    public SlackPriceBookChannelPost(List<Id> productIds){
        this.productIds = productIds;
    }

    @invocableMethod(label='SlackPriceBookChannelPost' description='Send Slack message for Low Inventory for Product not Package type.')
    public static void invocableMethod(List<Id> productIds) {
        System.enqueueJob(new SlackPriceBookChannelPost(productIds));
    }

    public void execute(QueueableContext context) {
        List<Product2> productsDetail = new List<Product2>([Select Id,Primary_Price_Book__c,Primary_Price_Book__r.Name,Primary_Price_Book__r.Slack_Channel_Id__c, Name,Inventory__c,Current_Inventory__c,
                                                             RecordType.Name,Room_Type__c from Product2 where Id In :productIds]);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        for(Product2 prod : productsDetail) {
            String strPost = 'Inventory is running low for following product,\n' +
                             'PriceBook: ' + prod.Primary_Price_Book__r.Name + ',\n' +
                             'Product: <'+System.URL.getSalesforceBaseURL().toExternalForm()+'/'+prod.Id+'|'+prod.Name+'>\n' +
                             'Current Inventory: ' + prod.Current_Inventory__c;
            if(prod.RecordType.Name == 'Hotel Stay') { //#815
                strPost +=  ',\n' + 'Room Type:' + prod.Room_Type__c;
            }
            
            strPost = EncodingUtil.urlEncode(strPost, 'UTF-8');
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/chat.postMessage?token='+ slackAPI.Slack_API_Token__c + '&pretty=1&channel=' + prod.Primary_Price_Book__r.Slack_Channel_Id__c + '&text=' + strPost);
            req.setMethod('POST');
            req.setHeader('Content-type','application/json');
            Http http = new Http();
            if(!Test.isRunningTest()){ HttpResponse res = http.send(req);
                System.debug('response plain: ' + res);
            }
        }
    }
}