/**
 * @description       : 
 * @author            : Jheel Agrawal
 * @group             : 
 * @last modified on  : 07-07-2021
 * @last modified by  : fsuraitawala@addonblue.com
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   11-18-2020  jagrawal@addonblue.com   Initial Version
 * 1.1   07-06-2021  fsuraitawala@addonblue.com #1012 Slack Notifications Change
**/
public class SlackProductZeroInventory implements Queueable, Database.AllowsCallouts {
    public List<Id> productIds = new List<Id>();
    
    public SlackProductZeroInventory(List<Id> p_productIds){
        this.productIds = p_productIds;    	    
    }
    
    @invocableMethod(label='SlackProductZeroInventory' description='Send Slack message for Zero Inventory for Product, Hotel Stay and Package.')
    public static void invocableMethod(List<Id> productIds) {
        System.enqueueJob(new SlackProductZeroInventory(productIds));
    }
    
    public void execute(QueueableContext context) {
        List<Product2> productsDetail = new List<Product2>([Select Name, Id, Primary_Price_Book__c, Primary_Price_Book__r.Name, Primary_Price_Book__r.Slack_Channel_Id__c, 
                                                            Current_Inventory__c, Package_Inventory__c, RecordType.Name, Room_Type__c
                                                            FROM Product2 WHERE Id In :this.productIds]);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        for(Product2 prod : productsDetail) {
            //#1012 Room Type on Slack Notifications - only shows on Low Inventory Not Sold Out -- START
            String strPost = 'Inventory is sold out for following Product,\n' +
                             'PriceBook: ' + prod.Primary_Price_Book__r.Name + '\n' +
                             'Product: <'+System.URL.getSalesforceBaseURL().toExternalForm()+'/'+prod.Id+'|'+prod.Name+'>\n';
            if(prod.RecordType.Name == 'Package') {
                strPost +=  'Package Inventory: ' + prod.Package_Inventory__c;
            } else {
                strPost +=  'Current Inventory: ' + prod.Current_Inventory__c;
            }
            if(prod.RecordType.Name == 'Hotel Stay') {
                strPost +=  ',\n' + 'Room Type:' + prod.Room_Type__c;
            }
            //#1012 Room Type on Slack Notifications - only shows on Low Inventory Not Sold Out -- END
            
            strPost = EncodingUtil.urlEncode(strPost, 'UTF-8');

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/chat.postMessage?token='+ slackAPI.Slack_API_Token__c + '&pretty=1&channel=' + prod.Primary_Price_Book__r.Slack_Channel_Id__c + '&text=' + strPost+'&type=mrkdwn');
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