public class QE_SlackEventChannelPackageInventory {
    
    /*******************************************************************************/
    @InvocableMethod(label='Send Low Package Inventory Message' description='Low Package Inventory Message.')
    Public static void postToSlackforLowPackageInventory(List<Id> productIds) {
        postToSlackForPackageInventory(productIds);
    }
    /*******************************************************************************/
    @Future(callout=true)
    Public static void postToSlackForPackageInventory(List<Id> productIds) {
        List<Product2> productsDetail = new List<Product2>([Select Id, Event__c, Event__r.Name, Event__r.Slack_Channel_Id__c, Name, Package_Inventory__c
                                                                from Product2 where Id In :productIds and Send_Slack_Notifications__c = true]);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        for(Product2 prod : productsDetail) {
            String strPost = 'Inventory is running low for following Package,\n' +
                                'Event: ' + prod.Event__r.Name + '\n' +
                                'Package: ' + prod.Name + '\n' +
                                'Current Inventory:' + prod.Package_Inventory__c;
                                
            strPost = EncodingUtil.urlEncode(strPost, 'UTF-8');

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/chat.postMessage?token='+ slackAPI.Slack_API_Token__c + '&pretty=1&channel=' + prod.Event__r.Slack_Channel_Id__c + '&text=' + strPost);
            req.setMethod('POST');
            req.setHeader('Content-type','application/json');
            Http http = new Http();
            if(!Test.isRunningTest()){
                HttpResponse res = http.send(req);
                System.debug('response plain: ' + res);
                System.debug('response Body: ' + res.getBody());
            }
        }
    }
}