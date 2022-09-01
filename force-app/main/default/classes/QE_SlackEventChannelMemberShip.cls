public class QE_SlackEventChannelMemberShip {

    @InvocableMethod(label='Slack Event Channel Member Manage' description='Event channel Membership check')
    public static void manageMember(List<Id> userIds) {
        addRemoveMembersInChannel(userIds);
    }

    @Future(callout=true)
    Public static void addRemoveMembersInChannel(List<Id> lstUserIds) {
        List<User> lstMembers = new List<User>([Select Id, IsActive, Slack_User_Id__c, Profile.Name from User
                                                where Slack_User_Id__c != null and Id In :lstUserIds]);
        Slack_API_Detail__c slackAPI = Slack_API_Detail__c.getOrgDefaults();
        List<QE360_Event__c> eventDetails = new List<QE360_Event__c>([Select Slack_Channel_Id__c FROM QE360_Event__c where Slack_Channel_Id__c != null AND
                                                                        End_Date__c > Today]);
        for(User memb : lstMembers) {
            String channelAction = '';
            if(memb.IsActive && (memb.Profile.Name == 'QE360 - Sales Admin' || memb.Profile.Name == 'QE360 - Sales' || memb.Profile.Name == 'QE360 - Operations' || memb.Profile.Name == 'QE360 - GPE Sales Team' ||
                                    memb.Profile.Name == 'QE360 - Exclusive GP Sales Team')) {
                channelAction = 'invite';
            } else if(!memb.IsActive || (memb.Profile.Name != 'QE360 - Sales Admin' && memb.Profile.Name != 'QE360 - Sales' && memb.Profile.Name != 'QE360 - Operations' && memb.Profile.Name != 'QE360 - GPE Sales Team' &&
                                    memb.Profile.Name == 'QE360 - Exclusive GP Sales Team')) {
                channelAction = 'kick';
            }
            
            for(QE360_Event__c qeEvent : eventDetails) {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://slack.com/api/channels.' + channelAction + '?token=' + slackAPI.Slack_API_Token__c + '&channel=' +
                                qeEvent.Slack_Channel_Id__c + '&user=' + memb.Slack_User_Id__c);
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