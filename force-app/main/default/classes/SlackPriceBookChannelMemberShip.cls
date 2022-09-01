/**
 * @description       : 
 * @author            : fsuraitawala@addonblue.com
 * @group             : 
 * @last modified on  : 03-22-2021
 * @last modified by  : fsuraitawala@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   03-22-2021   fsuraitawala@addonblue.com   Initial Version
 * 1.1    3/25/2021   kchavda@addonblue.com      #879 Slack channel not being created through code
**/
public class SlackPriceBookChannelMemberShip implements Queueable,Database.AllowsCallouts {
  public List<Id> userIds;
    public SlackPriceBookChannelMemberShip(List<Id> userIds){
        this.userIds = userIds;
    }
    public void execute(QueueableContext context){
        System.debug('Query-->'+[Select Id, IsActive, Slack_User_Id__c, Profile.Name from User where Id In :userIds AND Slack_User_Id__c != null]);
        List<User> lstMembers = new List<User>([Select Id, IsActive, Slack_User_Id__c, Profile.Name from User
                                                where Slack_User_Id__c != null and Id In :userIds]);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        List<Pricebook2> pricebookDetails = new List<Pricebook2>([Select Slack_Channel_Id__c FROM Pricebook2 where Slack_Channel_Id__c != null AND
                                                                        End_Date__c > Today]);
        for(User memb : lstMembers) {
            String channelAction = '';
            if(memb.IsActive && (memb.Profile.Name == 'QE360 - Sales Admin' || memb.Profile.Name == 'QE360 - Sales'|| memb.Profile.Name == 'Sales Team Lead' || memb.Profile.Name == 'QE360 - Operations' || memb.Profile.Name == 'QE360 - GPE Sales Team' || memb.Profile.Name == 'QE360 - Exclusive GP Sales Team')) {
                channelAction = 'invite';
            } else if(!memb.IsActive || (memb.Profile.Name != 'QE360 - Sales Admin' && memb.Profile.Name != 'QE360 - Sales' && memb.Profile.Name != 'Sales Team Lead' && memb.Profile.Name != 'QE360 - Operations' && memb.Profile.Name != 'QE360 - GPE Sales Team' && memb.Profile.Name == 'QE360 - Exclusive GP Sales Team')) {
                channelAction = 'kick';
            }
            
            for(Pricebook2 qePriceBook : pricebookDetails) {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://slack.com/api/conversations.' + channelAction + '?token=' + slackAPI.Slack_API_Token__c + '&channel=' +
                                qePriceBook.Slack_Channel_Id__c + '&user=' + memb.Slack_User_Id__c);
                System.debug(req.getEndpoint());
                req.setMethod('POST');
                req.setHeader('Content-type','application/json');
                Http http = new Http();
                HttpResponse res;
                if(!Test.isRunningTest()) {
                    res = http.send(req);
                    System.debug('response plain: ' + res);
                    System.debug('@@Add Member response Body: ' + res.getBody());
                }
            }
        }
    }
}