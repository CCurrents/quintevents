/**
* @description       : 
* @author            : ratiksinghal@addonblue.com
* @group             : 
* @last modified on  : 08-08-2022
* @last modified by  : ratiksinghal@addonblue.com
**/
@isTest public class OutReachLeadProcessBatchTest{
    
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry(); 
        User testEventManagerUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'QE360 - Sales Admin'].Id,
            LastName = 'last',
            Email = 'testEventManagerUser@quintevents.com',
            Username = 'testEventManagerUser@quintevents.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',user_alias__c='testAddon',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Slack_User_Id__c = 'U60CJ1YT1',
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
            Post_to_Slack_Channel__c = true,
            sequence_id__c='2031',
            Slack_Channel_Id__c = 'CLZM020EL',
            End_Date__c = System.today()+2);
        utility.processRecords(pricebook, 'insert');
        IntegrationTokens__c tok= new IntegrationTokens__c();
        tok.client_id__c='GgXGfuLjCS9ouJ7956oeQ_rvXjECNSLgGPqxMrrd4Ys';
        tok.client_secret__c = 'h0K8mgFRaJGXPm2OUVpqvbSreNcVFj_2EUuz3rCRZwU';
        tok.refresh_token__c='QyKEeRSgUxkmip33UzMjH_3_bGVKPbbUW0CXGrtMJSA';
        tok.endpoint__c='https://api.outreach.io/oauth/token?';
        tok.name='Outreach';
        tok.Redirect_Uri__c='https://quintevents.com/oauth/outreach';
        tok.service_Endpoint__c='https://api.outreach.io/api/v2/';
        tok.grant_type__c='refresh_token';
        tok.Access_Token__c ='tokenddd';        
        insert tok;
        User u =[select id,name from user where email ='testEventManagerUser@quintevents.com' ];
        Pricebook2 pb = [Select id from Pricebook2 where name='PricbookName+qwerwqq-'];
        
        List<Lead> lstLeads = new List<Lead>();
        for(integer i= 0; i<1; i++){   
            Lead objLead = new Lead();
            objLead.Google_Analytics_ID__c = 'gaID';
            objLead.OwnerId = u.id;
            objLead.Google_Analytics_Site_Id__c = 'gaSiteId';
            objLead.FirstName = 'Addon';
            objLead.LastName = 'Blue'+ Utility.getRandomNumber().SubString(0,8) + i;
            objLead.Status = 'delivered';
            objLead.OutReach_Id__c = '12131344';
            objLead.Lead_Type__c = 'Person'; // Create two type of lead 
            objLead.Event_Interest_Picklist_PB__c=pb.id;
            //objLead.Event_Interest_Picklist_PB__r.Program__r.contact_site__c = 'f1experiences.com';
            objLead.Email = 'addonblue'+Utility.getRandomNumber().SubString(0,8)+'@quintevnts.com';
            lstLeads.add(objLead);
        }
        lstLeads = Utility.processRecords(lstLeads, 'insert');
    }
    
    @isTest static void test1(){
        Test.startTest();	
        OutReachLeadProcessBatch calloutObj1 = new OutReachLeadProcessBatch('Select Id, OutReach_Id__c, ownerId, Event_Interest_Picklist_PB__r.Program__r.contact_site__c,Event_Interest_Picklist_PB__r.Sequence_ID__c from lead where Sequence_Status__c NOT IN (\'Sequence Added\', \'Sequence Finished\')');
        ID batchprocessid2 = Database.executeBatch(calloutObj1,2);
        Test.stopTest();
    }
    
    @isTest static void test2(){
        List<Id> leadIds = new List<Id>();
        for(Lead ld: [select id from Lead]){
            leadIds.add(ld.Id);
        }
        Test.startTest();
        String str='select id,ownerid,outreach_id__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,Event_Interest_Picklist_PB__r.Sequence_ID__c from lead';
        OutReachLeadProcessBatch calloutObj1 = new OutReachLeadProcessBatch(leadIds);
        ID batchprocessid2 = Database.executeBatch(calloutObj1,2);
        Test.stopTest();
    }
    
    
    @isTest static void test3(){
        Test.startTest();
        String str='select id,ownerid,outreach_id__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,Event_Interest_Picklist_PB__r.Sequence_ID__c from lead';
        OutReachLeadProcessBatch calloutObj1 = new OutReachLeadProcessBatch('str','2031');
        ID batchprocessid2 = Database.executeBatch(calloutObj1,2);
        Test.stopTest();
    }
    
    
    @isTest static void test4(){
        Test.startTest();
        String str='select id,ownerid,outreach_id__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,Event_Interest_Picklist_PB__r.Sequence_ID__c from lead';
        OutReachLeadProcessBatch calloutObj1 = new OutReachLeadProcessBatch(str);
        ID batchprocessid2 = Database.executeBatch(calloutObj1,2);
        Test.stopTest();
    }
    
    
}