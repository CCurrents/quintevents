public class QE_SlackEventChannelInactiveProduct {

    /*******************************************************************************/
    @InvocableMethod(label='Send Message if Product goes to Inactive' description='Message for Product goes to Inactive.')
    Public static void postToSlackforInactiveProduct(List<Id> productIds) {
   System.debug('productIds.size()-->'+productIds.size());
        //#510 too many callout issue resolve
        //postToSlackChannelForInactiveProduct(productIds);
        if(System.isBatch()){
            postToSlackChannelForInactiveProduct(productIds);
        }else{
            FutureMethodForInactiveProduct(productIds);
        }
    }
    
    @Future(callout=true)
    Public static void FutureMethodForInactiveProduct(List<Id> productIds) {
        postToSlackChannelForInactiveProduct(productIds);
    }
    /*******************************************************************************/
    //@Future(callout=true)
    Public static void postToSlackChannelForInactiveProduct(List<Id> productIds) {
        List<Product2> productsDetail = new List<Product2>([Select Id, Event__c, Event__r.Name, IsActive, Event__r.Slack_Channel_Id__c, Name
                                                                from Product2 where Id In :productIds and Send_Slack_Notifications__c = true]);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        for(Product2 prod : productsDetail) {
            String strPost = 'Event: ' + prod.Event__r.Name + '\n' +
                             'Product: ' + prod.Name + '\n' + 
                             'Status: ' + (prod.IsActive ? 'Active' : 'InActive') + '\n';
                                
            strPost = EncodingUtil.urlEncode(strPost, 'UTF-8');

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/chat.postMessage?token='+ slackAPI.Slack_API_Token__c + '&pretty=1&channel=' + prod.Event__r.Slack_Channel_Id__c + '&text=' + strPost);
            req.setMethod('POST');
            req.setHeader('Content-type','application/json');
            Http http = new Http();
            if(!Test.isRunningTest()){
                HttpResponse res = http.send(req);
                System.debug('response plain: ' + res);
            }
        }
    }
}