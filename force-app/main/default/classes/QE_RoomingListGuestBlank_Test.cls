/*************************************
** Class Name: QE_H4HHotelProcess_Test
** Created Date: 03/05/2020
** Created By: Vishal Agrawal
** Purpose: Test class for QE_RoomingListGuestBlank
** ** ** ** ** ** ** **
*******Modification Logs************
**Modifier Name ***** Modified Date ***** Description
**
*************************************/
@isTest
public class QE_RoomingListGuestBlank_Test {
    
    @testSetup
    public static void createData() {
        
        program__c pro = new program__c();
        pro.Name = 'F1E';
        insert pro;

        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        eventTest.program__c =pro.id;
        eventTest.H4H_Site_Id__c = '123456';
        eventTest.Event_Manager__c = UserInfo.getUserId();
        Insert eventTest;
        
        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = eventTest.Id;
        insert parentPackage;
        
        product2 product =new product2();
        Product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();
        product.Name = 'Test Product';
        product.Event__c = eventTest.Id;
        product.Type__c = 'Package';
        product.CurrencyIsoCode = 'USD';
        product.Price__c = 120.00;
        product.A_La_Carte__c = true;
        product.isActive = true;
        product.Parent_Package__c = parentPackage.Id;
        product.Check_In_Date__c = System.today().addDays(7);
        product.Check_Out_Date__c = System.today().addDays(9);
        product.Room_Type__c = 'Queen';
        product.Hotel_Id__c = '1234';
        insert product;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = product.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 0.00;
        pbe.IsActive = True;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;

        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'lgaID';
        lead.Google_Analytics_Site_Id__c = 'lgaSiteId';
        lead.FirstName = 'testNamelead';
        lead.LastName = 'test';
        lead.Status = 'Qualified';
        lead.Source__c = 'call cotaexperiences.com';
        lead.Email = 'testemails@quintevents.com';
        insert lead;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Lead testLead = [select Id, IsConverted, ConvertedAccountId,ConvertedContactId from Lead where Id = :lead.Id];

        Account acct = new Account();
        acct.id = testLead.ConvertedAccountId;
        acct.personEmail ='testmails@quintevents.com';
        update acct;

        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'oppName';
        oppTest.AccountId = testLead.ConvertedAccountId;
        oppTest.Primary_Contact__c = testLead.ConvertedContactId;
        oppTest.Communications_Contact__c = testLead.ConvertedContactId;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Closed Won';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.ship_to_Name__c = 'Test abc Test1';
        oppTest.Payment_Method__c = 'Check';
        oppTest.email__c = 'abcedgft@gmail.com';
        oppTest.Amount = 1;
        insert oppTest;
        System.debug('@@@Test class Opp: ' + oppTest);

        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = oppTest.Id;
        oppLineItem.PricebookEntryId = pbe.Id;
        oppLineItem.Quantity = 100;
        oppLineItem.UnitPrice = 10;
        oppLineItem.Product2Id = product.Id;
        oppLineItem.ApexProductType__c = 'Hotel';
        oppLineItem.ApexProductName__c = Product.Name;
        oppLineItem.ApexCost__c = 120;
        oppLineItem.Opportunity_Product_Package_Hotel__c = true;
        oppLineItem.Package__c = product.Id;
        insert oppLineItem;
    }
    
    static testMethod void testRoomingGuestBlank() {
        OpportunityLineItem oppLineItem = [Select Id, opportunityId from OpportunityLineItem Limit 1];
        
        Rooming_List__c roomList = new Rooming_List__c();
        roomList.H4H_RatePlan_Code__c = 'ARN540643';
        roomList.H4H_Room_Code__c = '540643';
        roomList.Number_of_Adults__c = 2;
        //roomList.Guest_Name__c = 'test guest';
        roomList.Opportunity__c = oppLineItem.OpportunityId;
        roomList.OpportunityLineItem_Id__c = oppLineItem.Id;
        insert roomList;
        
        Test.StartTest();
        String CRON_EXP = '0 59 18 * * ?';
        QE_ScheduleRoomingListGuestBlank scheduleRooming = new QE_ScheduleRoomingListGuestBlank();
        String jobId = System.schedule('Rooming Guest', CRON_EXP, scheduleRooming);
        
        Test.StopTest();
    }
}