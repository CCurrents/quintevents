/**
 * @File Name          : SlackPriceBookActivation.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 4/27/2020, 3:45:06 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/23/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class SlackPriceBookActivation implements Queueable, Database.AllowsCallouts {
    public List<Id> lstPriceIds = new List<Id>();
    
    public SlackPriceBookActivation(List<Id> lstPriceIds){
        this.lstPriceIds = lstPriceIds;
    }

    public void execute(QueueableContext context) {
        List<Pricebook2> priceDetails = new List<Pricebook2>([Select Id, Name, IsActive, Slack_Channel_Id__c, Post_to_Slack_Channel__c
                                                                         FROM Pricebook2 where Id In :lstPriceIds]);
        for(Pricebook2 qePrice : priceDetails) {
            if(qePrice.Post_to_Slack_Channel__c) {
                Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
                HttpRequest req = new HttpRequest();
                String message = EncodingUtil.urlEncode('Event: ' + qePrice.Name + '\n' + 'Status: ' + (qePrice.IsActive ? 'Active' : 'Inactive'), 'UTF-8');
                req.setEndpoint('https://slack.com/api/chat.postMessage?token='+ slackAPI.Slack_API_Token__c + '&pretty=1&text=' +
                                message + '&channel=' + qePrice.Slack_Channel_Id__c);
                System.debug(req.getEndpoint());
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
}