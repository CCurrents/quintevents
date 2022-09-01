/**
 * @description       : 
 * @author            : Jheel Agrawal
 * @group             : 
 * @last modified on  : 11-19-2020
 * @last modified by  : jagrawal@addonblue.com
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   11-19-2020   Jheel Agrawal   Initial Version
**/
public class SlackPricebookChannelInactiveProduct implements Queueable,Database.AllowsCallouts {
	public List<Id> productIds;
    public SlackPricebookChannelInactiveProduct(List<Id> productIds){
        this.productIds = productIds;
    }

    @invocableMethod(label='SlackPricebookChannelInactiveProduct' description='Send Slack message if Product goes to Inactive.')
    public static void invocableMethod(List<Id> productIds) {
        System.enqueueJob(new SlackPricebookChannelInactiveProduct(productIds));
    }

    public void execute(QueueableContext context) {
        List<Product2> productsDetail = new List<Product2>([Select Id, Primary_Price_Book__c, Primary_Price_Book__r.Name, IsActive, Primary_Price_Book__r.Slack_Channel_Id__c, Name
                                                                from Product2 where Id In :productIds]);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        for(Product2 prod : productsDetail) {
            String strPost = 'PriceBook: ' + prod.Primary_Price_Book__r.Name + '\n' +
                             'Product: ' + prod.Name + '\n' + 
                             'Status: ' + (prod.IsActive ? 'Active' : 'Inactive') + '\n';
                                
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