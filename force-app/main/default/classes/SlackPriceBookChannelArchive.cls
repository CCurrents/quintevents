/**
 * @File Name          : SlackPriceBookChannelArchive.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/12/2020, 2:04:45 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/23/2020   jagrawal@addonblue.com     Initial Version
 * 1.1    3/25/2021   kchavda@addonblue.com      #879 Slack channel not being created through code
**/
public with sharing class SlackPriceBookChannelArchive implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{

    public List<Id> lstPriceIds = new List<Id>();
    public Date objdate;
    public SlackPriceBookChannelArchive(){
        //this.lstPriceIds = lstPriceIds;
        objdate = System.today().addDays(-7);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id,Slack_Channel_Id__c,End_Date__c from Pricebook2 where End_Date__c =: objdate');
    }
    
    public void execute(Database.BatchableContext BC, List<Pricebook2> scope) {
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        
        for(Pricebook2 qePrice : scope) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://slack.com/api/conversations.archive?token='+ slackAPI.Slack_API_Token__c + '&channel=' + qePrice.Slack_Channel_Id__c);
            System.debug(req.getEndpoint());
            req.setMethod('POST');
            req.setHeader('Content-type','application/json');
            Http http = new Http();
            if(!Test.isRunningTest()){
                HttpResponse res = http.send(req);
                System.debug('response plain: ' + res);
                System.debug('response Bofdy: ' + res.getBody());
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}