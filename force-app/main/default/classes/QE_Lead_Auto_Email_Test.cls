@isTest(seeAllData=false)
public class QE_Lead_Auto_Email_Test {
    public static void init(){
        
    }
    
    @isTest static void test_method_one() {
        Test.startTest();
        init();
        
        // administrator, then populate a map with them.  
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 
                            'Standard User' or name = 'System Administrator'];
        
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        // Create the users to be used in this test.  
        
        // First make a new user.  
        
        
        User standard = new User(alias = 'standt', 
                                 email='standarduser@testorg.com', 
                                 emailencodingkey='UTF-8', 
                                 lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', 
                                 profileid = profiles.get('Standard User'), 
                                 timezonesidkey='America/Los_Angeles', 
                                 username='Quintstandarduser@testorg.com');
        
        insert standard;
        
        // Then instantiate a user from an existing profile  
        
        
        User admin = [SELECT Id FROM user WHERE profileid = 
                      :profiles.get('System Administrator') Limit 1];
        
        Lead_Not_Assigned_User__c setting = new Lead_Not_Assigned_User__c();
        //setting.Name = 'Test Setting';
        setting.UserId__c = standard.Id;
        insert setting;
        
        //EmailTemplate emTemp = new EmailTemplate(Name='Test Email Template');
        //insert emTemp;
        
        system.runas(standard){
            Lead newTestLead = new Lead();
            newTestLead.LastName = 'TestLead';
            newTestLead.Status = 'Open';
            newTestLead.Source__c = 'call collegefootballexperiences.com';
            insert newTestLead; 
            
            newTestLead.Email = 'test@TEST.COM';
            newTestLead.form_type__c = 'Info Request';
            newTestLead.Source__c = 'web derbyexperiences.com';
            newTestLead.Email_Sent__c = False;
            newTestLead.OwnerId = admin.Id;
            Update newTestLead;
        }
        
        Test.stopTest();
    }
}