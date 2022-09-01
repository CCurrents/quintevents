@isTest
public class Test_OutReachSequenceFinishUpdate {
    @testSetup static void setup() {
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
        User u =[select id,name from user where email ='test123@quintevents.com' ];
        Pricebook2 pb = [Select id,Sequence_ID__c,Program__r.contact_site__c,  program__C from Pricebook2 where name='PricbookName+qwerwqq-'];
        
        List<Lead> lstLeads = new List<Lead>();
        for(integer i= 0; i<2; i++){   
            Lead objLead = new Lead();
            objLead.Google_Analytics_ID__c = 'gaID';
            objLead.Sequence_Status__c = 'Sequence Added';
            objLead.Google_Analytics_Site_Id__c = 'gaSiteId';
            objLead.FirstName = 'Addon';
            objLead.OwnerId = u.id;
            objLead.LastName = 'Blue'+ Utility.getRandomNumber().SubString(0,8) + i;
            objLead.Status = 'converted';
            objLead.OutReach_Id__c = '12321342'+i;
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
         Test.setMock(HttpCalloutMock.class, new MailBoxMockClass());
        //List<Lead> leadlist = [select id,Event_Interest_Picklist_PB__r.sequence_id__c,OwnerId,Outreach_ID__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,status from lead where status ='converted'];
        OutReachSequenceFinishUpdate calloutObj2 = new OutReachSequenceFinishUpdate('select id,Event_Interest_Picklist_PB__r.sequence_id__c,OwnerId,Outreach_ID__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,status from lead where status = \'converted\' and owner.name !=\'Quinton Escobar\' and Sequence_Status__c=\'Sequence Added\'');
        DataBase.executeBatch(calloutObj2);
        
        Test.stopTest();
    }
    
     @isTest static void exceptiontest(){
        Test.startTest();	
          Test.setMock(HttpCalloutMock.class, new MailBoxMockClass());
        //List<Lead> leadlist = [select id,Event_Interest_Picklist_PB__r.sequence_id__c,OwnerId,Outreach_ID__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,status from lead where status ='converted'];
       Lead ld =[select id from lead limit 1];
         OutReachSequenceFinishUpdate oc = new OutReachSequenceFinishUpdate('select id from lead');
         RequestResponse_Log__c res = oc.createrrLog('request','response','endpoint',ld.Id);
         OutReachSequenceFinishUpdate calloutObj2 = new OutReachSequenceFinishUpdate('select id,Event_Interest_Picklist_PB__r.sequence_id__c,OwnerId,Outreach_ID__c,status from lead where status = \'converted\'','2072');
        DataBase.executeBatch(calloutObj2);
        
        Test.stopTest();
    }
    
    static testMethod void testParsemethod() {
		String json=		'{'+
		'    "data": ['+
		'        {'+
		'            "type": "sequenceState",'+
		'            "id": 908854,'+
		'            "attributes": {'+
		'                "activeAt": null,'+
		'                "bounceCount": 0,'+
		'                "callCompletedAt": null,'+
		'                "clickCount": 0,'+
		'                "createdAt": "2022-08-01T12:35:30.000Z",'+
		'                "deliverCount": 0,'+
		'                "errorReason": null,'+
		'                "failureCount": 0,'+
		'                "negativeReplyCount": 0,'+
		'                "neutralReplyCount": 0,'+
		'                "openCount": 0,'+
		'                "optOutCount": 0,'+
		'                "pauseReason": null,'+
		'                "positiveReplyCount": 0,'+
		'                "repliedAt": null,'+
		'                "replyCount": 0,'+
		'                "scheduleCount": 0,'+
		'                "state": "finished",'+
		'                "stateChangedAt": "2022-08-02T15:39:13.000Z",'+
		'                "updatedAt": "2022-08-02T15:39:13.000Z"'+
		'            },'+
		'            "relationships": {'+
		'                "account": {'+
		'                    "data": {'+
		'                        "type": "account",'+
		'                        "id": 1061782'+
		'                    }'+
		'                },'+
		'                "activeStepMailings": {'+
		'                    "data": [],'+
		'                    "links": {'+
		'                        "related": "https://api.outreach.io/api/v2/mailings?filter%5BsequenceState%5D%5Bid%5D=908854"'+
		'                    },'+
		'                    "meta": {'+
		'                        "count": 0'+
		'                    }'+
		'                },'+
		'                "activeStepTasks": {'+
		'                    "data": [],'+
		'                    "links": {'+
		'                        "related": "https://api.outreach.io/api/v2/tasks?filter%5BsequenceState%5D%5Bid%5D=908854"'+
		'                    },'+
		'                    "meta": {'+
		'                        "count": 0'+
		'                    }'+
		'                },'+
		'                "batchItemCreator": {'+
		'                    "data": null'+
		'                },'+
		'                "calls": {'+
		'                    "links": {'+
		'                        "related": "https://api.outreach.io/api/v2/calls?filter%5BsequenceState%5D%5Bid%5D=908854"'+
		'                    }'+
		'                },'+
		'                "creator": {'+
		'                    "data": {'+
		'                        "type": "user",'+
		'                        "id": 354'+
		'                    }'+
		'                },'+
		'                "mailbox": {'+
		'                    "data": {'+
		'                        "type": "mailbox",'+
		'                        "id": 31'+
		'                    }'+
		'                },'+
		'                "mailings": {'+
		'                    "links": {'+
		'                        "related": "https://api.outreach.io/api/v2/mailings?filter%5BsequenceState%5D%5Bid%5D=908854"'+
		'                    }'+
		'                },'+
		'                "opportunity": {'+
		'                    "data": null'+
		'                },'+
		'                "prospect": {'+
		'                    "data": {'+
		'                        "type": "prospect",'+
		'                        "id": 1058121'+
		'                    }'+
		'                },'+
		'                "sequence": {'+
		'                    "data": {'+
		'                        "type": "sequence",'+
		'                        "id": 2072'+
		'                    }'+
		'                },'+
		'                "sequenceStateRecipients": {'+
		'                    "data": ['+
		'                        {'+
		'                            "type": "sequenceStateRecipient",'+
		'                            "id": 892660'+
		'                        }'+
		'                    ],'+
		'                    "links": {'+
		'                        "related": "https://api.outreach.io/api/v2/sequenceStateRecipients?filter%5BsequenceState%5D%5Bid%5D=908854"'+
		'                    },'+
		'                    "meta": {'+
		'                        "count": 1'+
		'                    }'+
		'                },'+
		'                "sequenceStep": {'+
		'                    "data": null'+
		'                },'+
		'                "tasks": {'+
		'                    "links": {'+
		'                        "related": "https://api.outreach.io/api/v2/tasks?filter%5BsequenceState%5D%5Bid%5D=908854"'+
		'                    }'+
		'                }'+
		'            },'+
		'            "links": {'+
		'                "self": "https://api.outreach.io/api/v2/sequenceStates/908854"'+
		'            }'+
		'        }'+
		'    ],'+
		'    "meta": {'+
		'        "count": 1,'+
		'        "count_truncated": false'+
		'    }'+
		'}';
		SequenceStateResponse obj = SequenceStateResponse.parse(json);
		System.assert(obj != null);
	}
}