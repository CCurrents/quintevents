public class QE_productMessagetoSlack {
    
    @InvocableMethod(label='Sold out product to Slack' description='Send message in channel')
    public static void postProductSoldOutMessage(List<Id> productIds) {
        //#510 resolve too many callout issue
        //postMessageInChannel(productIds);
        if(System.isBatch()){
            postMessageInChannel(productIds);
        }else{
            FutureMethodForMessageInChannel(productIds);
        }
    }  
    
    @Future(callout=true)
    Public static void FutureMethodForMessageInChannel(List<Id> productIds) {
        postMessageInChannel(productIds);
    }
    //@Future(callout=true)    
    public static void postMessageInChannel(List<Id> productIds) {
        system.debug('@@productIds=='+productIds);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        for(Product2 prod : [Select Id, Name,RecordType.Name,Package_Inventory__c,Current_Inventory__c from Product2 where Id In :productIds and Send_Slack_Notifications__c = true]) {
            HttpRequest req = new HttpRequest();
            String str = prod.RecordType.Name == 'Package' ? '\n' + 'Package Inventory:' + prod.Package_Inventory__c : '\n' + 'Current Inventory:' + prod.Current_Inventory__c;
            system.debug('@@str=='+str);
            String message = EncodingUtil.urlEncode('Product: ' + prod.Name + '\n' + 'Status: InActive (Sold out).' + str, 'UTF-8');
            system.debug('@@message=='+message);
            req.setEndpoint('https://slack.com/api/chat.postMessage?token='+ slackAPI.Slack_API_Token__c + '&pretty=1&text=' +
                            message + '&channel=' + slackAPI.Sales_Channel__c);
            System.debug(req.getEndpoint());
            req.setMethod('POST');
            req.setHeader('Content-type','application/json');
            if(!Test.isRunningTest()){
                HttpResponse res = new Http().send(req);
                System.debug('response plain: ' + res);
            }
            //Map<String, Object> createResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            //System.debug('response: ' + createResponse);
        }
    }
}