public class QE_SlackEventChannelPost {

    public static void postMessageInChannel(QE360_Event__c qeEvent) {
        if(qeEvent.Post_to_Slack_Channel__c) {
            Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
            HttpRequest req = new HttpRequest();
            String message = EncodingUtil.urlEncode('Event: ' + qeEvent.Name + '\n' + 'Status: ' + (qeEvent.Active__c ? 'Active' : 'Inactive'), 'UTF-8');
            req.setEndpoint('https://slack.com/api/chat.postMessage?token='+ slackAPI.Slack_API_Token__c + '&pretty=1&text=' +
                            message + '&channel=' + qeEvent.Slack_Channel_Id__c);
            System.debug(req.getEndpoint());
            req.setMethod('POST');
            req.setHeader('Content-type','application/json');
            Http http = new Http();
            if(!Test.isRunningTest()){
                HttpResponse res = http.send(req);
                System.debug('response plain: ' + res);
            }
        }
        
        //Map<String, Object> createResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        //System.debug('response: ' + createResponse);
    }
    /*******************************************************************************/
    @InvocableMethod(label='SlackEventChannel' description='Low Inventory Message.')
    Public static void postToSlackforLowInventory(List<Id> productIds) {
        postToSlack(productIds);
    }
    
    @Future(callout=true)
    Public static void postToSlack(List<Id> productIds) {
        List<Product2> productsDetail = new List<Product2>([Select Id,Event__c,Event__r.Name,Event__r.Slack_Channel_Id__c, Name,Inventory__c
                                                                from Product2 where Id In :productIds and Send_Slack_Notifications__c = true]);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        for(Product2 prod : productsDetail) {
            String strPost = 'Inventory is running low for following product,\n' +
                                'Event: ' + prod.Event__r.Name + '\n' +
                                'Product: ' + prod.Name + '\n' +
                                'Current Inventory:' + prod.Inventory__c;// + '\n' +
                                //'Product Link: ' + prod.Name;

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
            //Map<String, Object> createResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            //System.debug('response: ' + createResponse);
        }
    }
    /*******************************************************************************/
    
}