@isTest
public class QE_CSVLeadBatchUpdateS3Test
{
    @TestSetup
    static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }


    static testMethod void testMethods3()
    {
    
    Test.startTest();
        
        Lead lead = new Lead();
       
        lead.FirstName = 'abc1&1';
        lead.LastName = 'abcg2';
        lead.Visitor_country__c = 'usa';
        lead.Google_Analytics_ID__c = 'lgaaID';
        lead.Google_Analytics_Site_Id__c = 'lgaaSiteId';
        lead.Status = 'Qualified';
        lead.Source__c = 'f1experiences';
        lead.country = 'United States of America';
        lead.state = 'Florida';
        lead.PostalCode = '1234';
        lead.Rating = 'warm';
        lead.From_Lead_Convert__c = true;
        lead.Email = 'testemailids@quintevents.com';
        insert lead;

        AWS_S3_Settings__c s3settings = new AWS_S3_Settings__c();
        s3settings.S3_Key__c = 'dgve436ycksdsgjdfhdo';
        s3settings.S3_Secret__c = 'dngdfuh35496y8298403509jfkdfdmjjghsdkjf';
        insert s3settings;
        
        QE_CSVLeadBatchUpdateS3 S3UpdateLeads = new QE_CSVLeadBatchUpdateS3();
        
        Id batchId = DataBase.executeBatch(S3UpdateLeads);
        
        Test.StopTest();
    }
}