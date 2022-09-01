// Created by : vaibhav.khopade@addonblue.com
//Created on : 26 Apr 2022
// Desc : for fix of issue 1204


@isTest
public class CSVLeadBatch_LasVegasLeadsS3Test {
@TestSetup
    static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }


    static testMethod void testMethods3()
    {
    
    List<QE360_Event__c> LasVegasEvents = new List<QE360_Event__c> ();
      LasVegasEvents =  [Select Id from QE360_Event__c where Name LIKE '%Las Vegas%'];
        
    Test.startTest();
        
        Lead lead = new Lead();
       
        lead.FirstName = 'abc1&1';
        lead.LastName = 'abcg2';
        lead.Visitor_country__c = 'usa';
        lead.Google_Analytics_ID__c = 'lgaaID';
        lead.Google_Analytics_Site_Id__c = 'lgaaSiteId';
        lead.Status = 'Qualified';
        lead.Source__c = 'f1experiences';
        if(LasVegasEvents.size() > 0)
        	lead.Event_Interest_Picklist__c = LasVegasEvents[0].Id != null ?  LasVegasEvents[0].Id : '';
        lead.country = 'United States of America';
        lead.state = 'Florida';
        lead.PostalCode = '1234';
        lead.Rating = 'warm';
        lead.From_Lead_Convert__c = true;
        lead.Email = 'testemailids@quintevents.com';
        insert lead;

        AWS_S3_Settings__c s3settings = new AWS_S3_Settings__c();
        s3settings.S3_Key__c = 'dgve436ycksdsgjdfhd';
        s3settings.S3_Secret__c = 'dngdfuh35496y8298403509jfkdfdmjjghsdkj';
        insert s3settings;
        
        CSVLeadBatch_LasVegasLeadsS3 S3UpdateLeads = new CSVLeadBatch_LasVegasLeadsS3();
        
        Id batchId = DataBase.executeBatch(S3UpdateLeads);
        
        Test.StopTest();
    }
    
    
    static testMethod void testMethods2()
    {
    
    List<QE360_Event__c> LasVegasEvents = new List<QE360_Event__c> ();
      LasVegasEvents =  [Select Id from QE360_Event__c where Name LIKE '%Las Vegas%'];
        
    Test.startTest();
        
        Lead lead = new Lead();
       
        lead.FirstName = 'abc1&1';
        lead.LastName = 'abcg2';
        lead.Visitor_country__c = 'usa';
        lead.Google_Analytics_ID__c = 'lgaaID';
        lead.Google_Analytics_Site_Id__c = 'lgaaSiteId';
        lead.Status = 'Qualified';
        lead.Source__c = 'f1experiences';
        if(LasVegasEvents.size() > 0)
        	lead.Event_Interest_Picklist__c = LasVegasEvents[0].Id != null ?  LasVegasEvents[0].Id : '';
        lead.country = 'United States of America';
        lead.state = 'Florida';
        lead.PostalCode = '1234';
        lead.Rating = 'warm';
        lead.From_Lead_Convert__c = true;
        lead.Email = 'testemailids@quintevents.com';
        insert lead;

        AWS_S3_Settings__c s3settings = new AWS_S3_Settings__c();
        s3settings.S3_Key__c = 'dgve436ycksdsgjdfhd';
        s3settings.S3_Secret__c = 'dngdfuh35496y8298403509jfkdfdmjjghsdkj';
        insert s3settings;
        
        CSVLeadBatch_LasVegasLeadsS3 S3UpdateLeads = new CSVLeadBatch_LasVegasLeadsS3(system.today() - 2);
        
        Id batchId = DataBase.executeBatch(S3UpdateLeads);
        
        Test.StopTest();
    }
}