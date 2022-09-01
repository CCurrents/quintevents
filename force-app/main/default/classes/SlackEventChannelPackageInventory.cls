public class SlackEventChannelPackageInventory implements Queueable,Database.AllowsCallouts {
    public List<Id> productIds;
    Slack_API_Detail__c slackAPI;
    public SlackEventChannelPackageInventory(List<Id> productIds){
        this.productIds = productIds;
        slackAPI = Slack_API_Detail__c.getOrgDefaults();
    }
    public void execute(QueueableContext context) {
        List<Product2> lstProduct = new List<Product2>([Select Id, Primary_Price_Book__c, Primary_Price_Book__r.Name, Primary_Price_Book__r.Slack_Channel_Id__c, Name, Package_Inventory__c from Product2 where Id In :productIds and Send_Slack_Notifications__c = true]);
        for(Product2 prod : lstProduct){
            String strPost = 'Inventory is running low for following Package,\n' +
                                'PriceBook: ' + prod.Primary_Price_Book__r.Name + '\n' +
                                'Package: ' + prod.Name + '\n' +
                                'Current Inventory:' + prod.Package_Inventory__c;
                                
            strPost = EncodingUtil.urlEncode(strPost, 'UTF-8');
			System.debug('slackAPI-->'+slackAPI);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/chat.postMessage?token='+ slackAPI.Slack_API_Token__c + '&pretty=1&channel=' + prod.Primary_Price_Book__r.Slack_Channel_Id__c + '&text=' + strPost);
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