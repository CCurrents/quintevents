/**
 * @File Name          : H4HCreateMemberWithPointsBatchTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 8:06:32 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/8/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest(seeAllData=false)
public class H4HCreateMemberWithPointsBatchTest {
    @TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    static testMethod void test_method_one() {
        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'formula';
        Insert eventTest;
    
        Opportunity oppTest = TestDataFactory.createOpportunity();
        oppTest.Ship_To_Name__c = 'Test User';
        Test.startTest();
        	H4HCreateMemberWithPointsBatch.strResponse = '{"MemberId": 54321,"Rewards": 0,"Points": 100,"RedemptionMultiplier": 1.0,"EarnMultiplier": 1.0,"Names": [{"FirstName": "Testme","LastName": "Tester","BirthDate": null,"Email": "mytestuser1@gmail.com","Address1": "123 Main Street","Address2": null,"City": null,"State": null,"Country": null,"Postal": null,"Longitude": null,"Latitude": null,"HomePhone": "5551231212","Referral": null,"ReferralId": "mytestuser1@gmail.com","Password": null,"IsActive": true,"DeleteMember": false,"UpdateMemberUsername": false,"FullName": "Testme Teste"}],"DebugData": " Successful creation of Member RT-12345-mytestuser1@gmail.com","Error": null,"CurrentToken": "E7MUlbdRdlq2RwSs8V4%2fhza25Xwca%2fZLodi%2faddmPl%2bJfpCU7VovYjoSKaMk34PvkSDpD1mqvezzQG0abXzuXP1%2baaiIKCLw7ehGaiI7BNI7Pb%2fYK%2fGJf4fCxKCz5EodA79iweA6gc2nCEOdWmkarTuy4Cd%2f5WtNkU043rF42sshCKGkg%2bIavKgJ6emdL7msPJRykM2hf%2fmHjdDOV%2b7jtuOHpk5bAVVIc5jhUqmqJMa5908EK0VoX1OUT60SkDcw2YLBeXEg6sYPu1Q7mTPc5VUhJ%2b6C6wHM08eOKMrKt6LNRxoB0kXcPyVS1azt1LR48yAegw%2fKXPbdgrCBycjsDedm0ItP9SmW1C6Byw4nt5zivxf%2f0ZIMF07wtZ4JhWVqGuhetKPDE3ddzOLRPyjNgetWddHqoq8Tba%2bKWDcIADYnqgH5NVdVSKvyH5VWY3vMHyhlZQiW23z1a6lZReASYfMMycNfDU2X4EhDOEa0tvUYajpsRlnDIkNcLjxT4KPyrZhl5tVsHECCY0Sasy%2f6zh9ce%2b3HE%2bOEtux%2bEHKfBWrkzwt1vpwyn%2fnXzVd%2bQumpQLw5DOZ2DltHZs%2bfmQ96MoMrBgSx8jS%2bQkR3NQjGAysUOqXK%2fAl38ryHzGe0nSeMkLo5BRYEgiEJK%2bftnZqsEQbZC98E8Fyt2zMGiofGQrR1i5v3gRoOCfqjNYJQAft4ru6GCR5kpm0CsvVvOnKmnA%3d%3d","TransactionResponse": "true","MetaTag": null,"MemberUsername": "RT-12345-mytestuser1@gmail.com","MemberProvider": null,"IsArnProvider": true,"MemberType": "Member"}';           Id batchJobId = Database.executeBatch(new H4HCreateMemberWithPointsBatch(), 1);  
            H4HCreateMemberWithPointsBatch.createRequestToH4H(oppTest,200,'abc');
        Test.stopTest();
    }
    
    static testMethod void test_method_two() {
        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test formula';
        Insert eventTest;
        
        Opportunity oppTest = TestDataFactory.createOpportunity();
        oppTest.Ship_To_Name__c = 'Test User';
        Test.startTest();
        	H4HCreateMemberWithPointsBatch.strResponse = '{"MemberId": 54321,"Rewards": 0,"Points": 100,"RedemptionMultiplier": 1.0,"EarnMultiplier": 1.0,"Names": [{"FirstName": "Testme","LastName": "Tester","BirthDate": null,"Email": "mytestuser1@gmail.com","Address1": "123 Main Street","Address2": null,"City": null,"State": null,"Country": null,"Postal": null,"Longitude": null,"Latitude": null,"HomePhone": "5551231212","Referral": null,"ReferralId": "mytestuser1@gmail.com","Password": null,"IsActive": true,"DeleteMember": false,"UpdateMemberUsername": false,"FullName": "Testme Teste"}],"DebugData": " Successful Existing Member RT-12345-mytestuser1@gmail.com","Error": null,"CurrentToken": "E7MUlbdRdlq2RwSs8V4%2fhza25Xwca%2fZLodi%2faddmPl%2bJfpCU7VovYjoSKaMk34PvkSDpD1mqvezzQG0abXzuXP1%2baaiIKCLw7ehGaiI7BNI7Pb%2fYK%2fGJf4fCxKCz5EodA79iweA6gc2nCEOdWmkarTuy4Cd%2f5WtNkU043rF42sshCKGkg%2bIavKgJ6emdL7msPJRykM2hf%2fmHjdDOV%2b7jtuOHpk5bAVVIc5jhUqmqJMa5908EK0VoX1OUT60SkDcw2YLBeXEg6sYPu1Q7mTPc5VUhJ%2b6C6wHM08eOKMrKt6LNRxoB0kXcPyVS1azt1LR48yAegw%2fKXPbdgrCBycjsDedm0ItP9SmW1C6Byw4nt5zivxf%2f0ZIMF07wtZ4JhWVqGuhetKPDE3ddzOLRPyjNgetWddHqoq8Tba%2bKWDcIADYnqgH5NVdVSKvyH5VWY3vMHyhlZQiW23z1a6lZReASYfMMycNfDU2X4EhDOEa0tvUYajpsRlnDIkNcLjxT4KPyrZhl5tVsHECCY0Sasy%2f6zh9ce%2b3HE%2bOEtux%2bEHKfBWrkzwt1vpwyn%2fnXzVd%2bQumpQLw5DOZ2DltHZs%2bfmQ96MoMrBgSx8jS%2bQkR3NQjGAysUOqXK%2fAl38ryHzGe0nSeMkLo5BRYEgiEJK%2bftnZqsEQbZC98E8Fyt2zMGiofGQrR1i5v3gRoOCfqjNYJQAft4ru6GCR5kpm0CsvVvOnKmnA%3d%3d","TransactionResponse": "true","MetaTag": null,"MemberUsername": "RT-12345-mytestuser1@gmail.com","MemberProvider": null,"IsArnProvider": true,"MemberType": "Member"}';           Id batchJobId = Database.executeBatch(new H4HCreateMemberWithPointsBatch(), 1);  
            H4HCreateMemberWithPointsBatch.createRequestToH4H(oppTest,200,'abc');
        Test.stopTest();
    }
}