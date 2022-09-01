@isTest
public class OutReachBatchTest {
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
                GPE_Event__c = false,sequence_id__c='2044',
                Shipping_and_Handling_Fee__c = 200,
                Shipping_and_Handling_Fee_Outside_US__c = 100,
                H4H_Site_Id__c = '51745',
                Slack_Channel_Name__c = 'UFC 243',
                Post_to_Slack_Channel__c = true,
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
        for(integer i= 0; i<2; i++){   
            Lead objLead = new Lead();
            objLead.Google_Analytics_ID__c = 'gaID';
            objLead.OwnerId = u.id;
            objLead.Google_Analytics_Site_Id__c = 'gaSiteId';
            objLead.FirstName = 'Addon';
            objLead.LastName = 'Blue'+ Utility.getRandomNumber().SubString(0,8) + i;
            objLead.Status = 'delivered';
            objLead.OutReach_Id__c = Utility.getRandomNumber().SubString(0,8) + i;
            objLead.Lead_Type__c = 'Person'; // Create two type of lead 
            objLead.Event_Interest_Picklist_PB__c=pb.id;
            //objLead.Event_Interest_Picklist_PB__r.Program__r.contact_site__c = 'f1experiences.com';
            objLead.Email = 'addonblue'+Utility.getRandomNumber().SubString(0,8)+'@quintevnts.com';
            lstLeads.add(objLead);
        }
        lstLeads = Utility.processRecords(lstLeads, 'insert');
    }
    
    @isTest static void mailBoxtest(){
        Test.setMock(HttpCalloutMock.class, new MailBoxMockClass());
        List<lead> leadsToProcess =[select id,ownerid,Event_Interest_Picklist_PB__r.Program__r.contact_site__c
                                   from lead];
        Test.starttest();
        Map<Id,Integer> mailboxMap = OutReachMailBoxesController.fetchMailBoxdetails(leadsToProcess);
        Test.stopTest();
    }
    
    @isTest static void outReachTokentest(){
        Test.setMock(HttpCalloutMock.class, new OutReachAccessTokenMockClass());
        Test.starttest();
        Id jobId = Database.ExecuteBatch(new OutReachAuthTokenBatch(),1);
        Test.stopTest();
    }
    
     @isTest static void outReachTokenDeletetest(){
         Delete [select id from IntegrationTokens__c where name='Outreach'];
           IntegrationTokens__c tok= new IntegrationTokens__c();
       // tok.client_id__c='GgXGfuLjCS9ouJ7956oeQ_rvXjECNSLgGPqxMrrd4Ys';
       // tok.client_secret__c = 'h0K8mgFRaJGXPm2OUVpqvbSreNcVFj_2EUuz3rCRZwU';
        tok.refresh_token__c='QyKEeRSgUxkmip33UzMjH_3_bGVKPbbUW0CXGrtMJSA';
        tok.endpoint__c='https://api.outreach.io/oauth/token?';
        tok.name='Outreach';
        tok.Redirect_Uri__c='https://quintevents.com/oauth/outreach';
        tok.service_Endpoint__c='https://api.outreach.io/api/v2/';
        tok.grant_type__c='refresh_token';
        tok.Access_Token__c ='tokenddd';        
        insert tok;
        //Test.setMock(HttpCalloutMock.class, new OutReachAccessTokenMockClass());
        Test.starttest();
        Id jobId = Database.ExecuteBatch(new OutReachAuthTokenBatch(),1);
        Test.stopTest();
    }
    /*
    @isTest static void outreacScheduletest(){
        String CRON_EXP = '0 0 * * * ?';
        Test.startTest();
        ScheduleOutReach sch = new ScheduleOutReach();
        system.schedule('OutReachTokenBatch Schedule job', CRON_EXP, sch);
        Test.stoptest();
    }*/
    
    @istest static void addleadsequenceCallout(){
        Test.setMock(HttpCalloutMock.class, new MailBoxMockClass());
        User u =[select id,name from user where email ='testEventManagerUser@quintevents.com' ];
        Pricebook2 pb = [Select id from Pricebook2 where name='PricbookName+qwerwqq-'];
        Program__c p = [select id from Program__c where name='qe Program'];
         List<Lead> lstLeads = new List<Lead>();
        for(integer i= 0; i<2; i++){   
            Lead objLead = new Lead();
            objLead.Google_Analytics_ID__c = 'gaID';
            objLead.OwnerId = u.id;
            objLead.Google_Analytics_Site_Id__c = 'gaSiteId';
            objLead.FirstName = 'Addon';
            objLead.LastName = 'Blue'+ Utility.getRandomNumber().SubString(0,8) + i;
            objLead.Status = 'delivered';
            //objLead.OutReach_Id__c = Utility.getRandomNumber().SubString(0,8) + i;
            objLead.Lead_Type__c = 'Person'; // Create two type of lead 
            objLead.Event_Interest_Picklist_PB__c=pb.id;
           
            //objLead.Event_Interest_Picklist_PB__r.Program__r.contact_site__c = 'f1experiences.com';
            objLead.Email = 'addonblue'+Utility.getRandomNumber().SubString(0,8)+'@quintevnts.com';
            lstLeads.add(objLead);
        }
        lstLeads = Utility.processRecords(lstLeads, 'insert');
        List<Id> leadids = new List<Id>();
        List<Lead> ledsToUpdate = new List<Lead>();
        for(Lead l: [select id,outreach_Id__c from Lead]){
            l.outreach_id__c = '1234567';
            ledsToUpdate.add(l);
            leadids.add(l.id);
        }
        update ledsToUpdate;
        
        Test.startTest();
        OutReachMailBoxesController.addLeadsToSequence(leadids);
        Test.stopTest();
    }
    
     @istest static void FinishleadsequenceCallout(){
        Test.setMock(HttpCalloutMock.class, new MailBoxMockClass());
        User u =[select id,name from user where email ='testEventManagerUser@quintevents.com' ];
        Pricebook2 pb = [Select id from Pricebook2 where name='PricbookName+qwerwqq-'];
        Program__c p = [select id from Program__c where name='qe Program'];
         List<Lead> lstLeads = new List<Lead>();
        for(integer i= 0; i<2; i++){   
            Lead objLead = new Lead();
            objLead.Google_Analytics_ID__c = 'gaID';
            objLead.OwnerId = u.id;
            objLead.Google_Analytics_Site_Id__c = 'gaSiteId';
            objLead.FirstName = 'Addon';
            objLead.LastName = 'Blue'+ Utility.getRandomNumber().SubString(0,8) + i;
            objLead.Status = 'delivered';
            //objLead.OutReach_Id__c = Utility.getRandomNumber().SubString(0,8) + i;
            objLead.Lead_Type__c = 'Person'; // Create two type of lead 
            objLead.Event_Interest_Picklist_PB__c=pb.id;
           
            //objLead.Event_Interest_Picklist_PB__r.Program__r.contact_site__c = 'f1experiences.com';
            objLead.Email = 'addonblue'+Utility.getRandomNumber().SubString(0,8)+'@quintevnts.com';
            lstLeads.add(objLead);
        }
        lstLeads = Utility.processRecords(lstLeads, 'insert');
        List<Id> leadids = new List<Id>();
        List<Lead> ledsToUpdate = new List<Lead>();
        for(Lead l: [select id,outreach_Id__c from Lead]){
            l.outreach_id__c = '1234567';
            l.Status='Converted';
            l.Sequence_Status__c='Sequence Added';
            ledsToUpdate.add(l);
            leadids.add(l.id);
        }
        update ledsToUpdate;
        
        Test.startTest();
        OutReachMailBoxesController.sendClosedLeads(leadids);
        Test.stopTest();
    }
}