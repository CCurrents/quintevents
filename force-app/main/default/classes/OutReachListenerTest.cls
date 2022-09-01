/**
* @description       : 
* @author            : ratiksinghal@addonblue.com
* @group             : 
* @last modified on  : 08-02-2022
* @last modified by  : ratiksinghal@addonblue.com
**/
@isTest public class OutReachListenerTest{
    
    @isTest static void test1(){ 
        TestDataFactory.createTriggerSettingsEntry(); 
        User testEventManagerUser = new User(
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'QE360 - Sales Admin'].Id,
        LastName = 'last1',
        firstname='First1',
        Email = 'test123@quintevents.com',
        Username = 'test123@quintevents.com1' + System.currentTimeMillis(),
        CompanyName = 'TEST123',
        Title = 'title123',
        Alias = 'ali123',user_alias__c='testAddon123',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8', 
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        Slack_User_Id__c = 'U60CJ1YT111',
        IsActive = true
    );
                                
                                utility.processRecords(testEventManagerUser, 'insert');
                                Program__c prog = new Program__c(name='qe Program',Contact_Site__c='grandprixevents.com');
                                insert prog;
                                
                                Pricebook2 pricebook = new Pricebook2(
                                    //Name = PricbookName+'-'+ Utility.getRandomNumber() +i,
                                    Name = 'PricbookName+qwerwqq-',
                                    IsActive = true,program__c = prog.id,
                                    GPE_Event__c = false,
                                    Shipping_and_Handling_Fee__c = 200,
                                    Shipping_and_Handling_Fee_Outside_US__c = 100,
                                    H4H_Site_Id__c = '51745',
                                    Slack_Channel_Name__c = 'UFC 243',
                                    Sequence_ID__c = '1234567890',
                                    Post_to_Slack_Channel__c = true,
                                    Slack_Channel_Id__c = 'CLZM020EL',
                                    End_Date__c = System.today()+2);
                                utility.processRecords(pricebook, 'insert');
                                User u =[select id,name from user where email ='test123@quintevents.com' ];
                                Pricebook2 pb = [Select id,Sequence_ID__c,Program__r.contact_site__c,  program__C from Pricebook2 where name='PricbookName+qwerwqq-'];
                                
                                Lead objLead = new Lead();
                                objLead.Google_Analytics_ID__c = 'gaID';
                                objLead.Sequence_Status__c = 'Sequence Added';
                                objLead.Google_Analytics_Site_Id__c = 'gaSiteId';
                                objLead.FirstName = 'Addon';
                                objLead.OwnerId = u.id;
                                objLead.LastName = 'Blue'+ Utility.getRandomNumber().SubString(0,8);
                                objLead.Status = 'converted';
                                objLead.OutReach_Id__c = '12321342';
                                objLead.Lead_Type__c = 'Person'; // Create two type of lead 
                                objLead.Event_Interest_Picklist_PB__c=pb.id;
                                //objLead.Event_Interest_Picklist_PB__r.Program__r.contact_site__c = 'f1experiences.com';
                                objLead.Email = 'addonblue'+Utility.getRandomNumber().SubString(0,8)+'@quintevnts.com';
                                insert objLead;
                                OutReachListener.addSequenceState(12123,2072,34,objLead.Id);
                               }
    
    @isTest static void test2(){ 
        String jsonBody = '{"data":{"type":"sequenceState","relationships":{"prospect":{"data":{"type":"prospect","id":9494848}},"sequence":{"data":{"type":"sequence","id":2072}},"mailbox":{"data":{"type":"mailbox","id":55}}}}}';
        OutReachListener.executeCallout('POST','sequenceStates', jsonBody);
    }
}