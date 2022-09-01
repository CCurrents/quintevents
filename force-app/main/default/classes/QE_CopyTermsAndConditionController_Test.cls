/* **************************************************************************
* Controller Class: QE_CopyTermsAndConditionController
* Created by Jakin Prajapati: 01/01/2019
*
* Purpose/Methods:
* - Test class for QE_CopyTermsAndConditionController
************************************************************************** */
@isTest
public class QE_CopyTermsAndConditionController_Test {
    static testmethod void testCopyTermsAndConditionToOpp(){
        Test.startTest();
        QE360_Event__c eventTest = new QE360_Event__c();
        eventTest.Name = 'test';
        Insert eventTest;
        
        // Insert Test Account
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'lgaID';
        lead.Google_Analytics_Site_Id__c = 'lgaSiteId';
        lead.FirstName = 'testNamelead';
        lead.LastName = 'test';
        lead.Status = 'Converted';
        lead.Source__c = 'call cotaexperiences.com';
        lead.Email = 'testemails@quintevents.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        
        Lead lead1 = new Lead();
        lead1.Google_Analytics_ID__c = 'gaID';
        lead1.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead1.FirstName = 'testNameabc';
        lead1.LastName = 'test';
        lead1.Status = 'Converted';
        lead1.Source__c = 'call Virtuoso';
        lead1.Email = 'testemail12@quintevents.com';
        insert lead1;
        
        Database.LeadConvert lc1 = new database.LeadConvert();
        lc1.setLeadId(lead1.id);
        lc1.setDoNotCreateOpportunity(true);
        lc1.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr1 = Database.convertLead(lc1);
        
        Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        Lead testLead1 = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead1.Id];
        
        //Account accTest = new Account();
        //accTest.Name = 'testAccount';
        //accTest.RecordTypeId = accountRcdTypeId1.Id;
        //insert accTest;
        //
        
        Reseller__c testReseller = new Reseller__c(Default_Commission__c =1.00);
        Insert testReseller;
        
        Promoter__c testPromoter = new Promoter__c(Online_Sales_Commission__c=1.00, A_La_Carte_Commission__c=2.00, 
            Package_with_Hotel_Commission__c=3.00, Package_without_Hotel_Commission__c=4.00);
        Insert testPromoter;
        
        Account acct = new Account();
        acct.id = testLead.ConvertedAccountId;
        acct.Visitor_Country__c = 'test visitor country';
        acct.Resellers_Name__c = testReseller.Id;
        acct.Promoters_Name__c = testPromoter.Id;
        acct.PersonEmail = 'testEmail@gmail.com';
        update acct;
        
         // Products to be inserted
        List<Product2> productsToBeInserted = new List<Product2>();
        
        Parent_Package__c parentPakg = new Parent_Package__c(Event__c = eventTest.Id, Name='Test Parent pkg');
        insert parentPakg;
        // Package
        Product2 testPackage = new Product2(Name='BXCD11', Price__c=1.00, Type__c='Package', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(), Parent_Package__c = parentPakg.Id);
        productsToBeInserted.add(testPackage);
        
        // Products
        Product2 testProduct = new Product2(Name='BXCD22',Brandfuel_Points__c = 55, Price__c=1.00, Type__c='Giftbag', isActive=true,Event__c = eventTest.Id,RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),
                                            A_La_Carte__c = true, Available__c=true,Quantity_Per_Order_Threshold__c=1);
        productsToBeInserted.add(testProduct);
        
        insert productsToBeInserted;      
       
        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'oppName';
        oppTest.AccountId = testLead.ConvertedAccountId;
        oppTest.Event__c = eventTest.Id;
        oppTest.StageName = 'Value Proposition';
        oppTest.CloseDate = System.today();
        oppTest.Contact_Site__c = 'quintevents.com';
        oppTest.Payment_Method__c = 'Check';
        oppTest.email__c = 'abcedgft@gmail.com';
        oppTest.Amount = 1;
        try{
        insert oppTest;
        }
        catch(dmlException e) {
        }
        
        
        Apexpages.currentPage().getParameters().put('id', oppTest.id);
        QE_CopyTermsAndConditionController copyTermsAndConditionController = new QE_CopyTermsAndConditionController ();
        copyTermsAndConditionController.copyTermsAndConditionToOpportunity();
        system.assertEquals(oppTest.Terms_And_Conditions__c, eventTest.Terms_And_Conditions__c);
        eventTest.Terms_And_Conditions__c = 'Copy terms and condition to Opportunity!!!';
        update eventTest;
        copyTermsAndConditionController.copyTermsAndConditionToOpportunity();
        Test.stopTest();
        
    }
}