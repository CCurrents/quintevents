/* **************************************************************************
* Controller Class: QE_CopyTermsAndConditionController
* Created by Jakin Prajapati: 01/01/2019
*
* Purpose/Methods:
* - Test class for QE_CopyTermsAndConditionController
************************************************************************** */
@isTest
public class QE_CopyAddendumAWaiverController_Test  {
    static testmethod void testCopyTermsAndConditionToOpp(){
        Test.startTest();
        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Interested';
        lead.Source__c = 'call Virtuoso';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        Program__c testProgram = new Program__c(Name = 'F1E');
        insert testProgram;
        
        QE360_Event__c testEvent = new QE360_Event__c(Name='Test Event', Program__c = testProgram.Id);
        insert testEvent;
        
        Account testLeadConvertedAccount = new Account();
        
        testLeadConvertedAccount.Id = testLead.ConvertedAccountId;
        testLeadConvertedAccount.PersonEmail = 'test@tets.com';
        testLeadConvertedAccount.ShippingStreet = 'test';
        testLeadConvertedAccount.ShippingState= 'Iowa';
        testLeadConvertedAccount.ShippingPostalCode = 'test';
        testLeadConvertedAccount.ShippingCountry = 'United States of America';
        testLeadConvertedAccount.ShippingCity = 'test';
        
        testLeadConvertedAccount.BillingStreet = 'test';
        testLeadConvertedAccount.BillingState= 'Iowa';
        testLeadConvertedAccount.BillingPostalCode = 'test';
        testLeadConvertedAccount.BillingCountry = 'United States of America';
        testLeadConvertedAccount.BillingCity = 'test';
        
        update testLeadConvertedAccount;
        
        Account account = new Account();
        account.RecordTypeId = '012i00000015Y4x';
        account.Name = 'Test Account';
        account.CurrencyIsoCode = 'USD';
        insert account;     
        
        Contact contact = new Contact();
        contact.LastName = 'Test Last Name';
        contact.AccountId = account.Id;
        contact.CurrencyIsoCode = 'USD';
        contact.Email = 'test@gmail.com';
        insert contact;
        
        
        //INSERT OPPORTUNITY RECORD
        Opportunity opp = new Opportunity();
        opp.AccountId = account.Id;
        opp.Name = 'test record'; 
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today();
        opp.Event__c = testEvent.Id;
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Primary_Contact__c = contact.Id;
        opp.Phone__c = '123456789';
        opp.Email__c = 'test@gamil.com';
        opp.Shipping_City__c = 'Ahmedabad1';
        opp.Shipping_Country__c = 'India';
        opp.Shipping_Street__c = 'Bili';
        opp.Shipping_Zip_Postal_Code__c = '456768';
        opp.Payment_Method__c = 'check';
        insert opp;
        
        
        Apexpages.currentPage().getParameters().put('id', opp.id);
        QE_CopyAddendumAWaiverController objApex = new QE_CopyAddendumAWaiverController();
        objApex.copyAddendumAWaiverController();
        system.assertEquals(opp.Terms_And_Conditions__c, testEvent.Terms_And_Conditions__c);
        testEvent.Addendum_A_Waiver__c = 'Copy terms and condition to Opportunity!!!';
        update testEvent;
        objApex.copyAddendumAWaiverController();
        Test.stopTest();
        
    }
}