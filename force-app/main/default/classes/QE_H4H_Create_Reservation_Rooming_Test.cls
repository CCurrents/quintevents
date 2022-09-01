/**
 * @File Name          : QE_H4H_Create_Reservation_Rooming_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/11/2020, 9:22:41 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
public class QE_H4H_Create_Reservation_Rooming_Test{
    
    @isTest static void reservationButtonTesting1234() {
        // QE_H4H_Create_Reservation_Rooming_CNTRL objCtrl = new QE_H4H_Create_Reservation_Rooming_CNTRL(new Rooming_List__c());
        // objCtrl.closePopup();
        // objCtrl.createReservationAndRedirect();
    }

    @isTest static void reservationButtonTesting() {
        // Event
        // QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        // Insert eventTest;
        
        // // Lead
        // Lead lead = new Lead();
        // lead.Google_Analytics_ID__c = 'gaID';
        // lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        // lead.FirstName = 'testName';
        // lead.LastName = 'testName';
        // lead.Status = 'Interested';
        // lead.Source__c = 'call Virtuoso';
        // lead.Email = 'test@test.com';
        // lead.Company = 'test business';
        // insert lead;
        
        // // Convert Lead        
        // Database.LeadConvert lc = new database.LeadConvert();
        // lc.setLeadId(lead.id);
        // lc.setDoNotCreateOpportunity(true);
        // lc.setConvertedStatus('Converted');
        // Database.LeadConvertResult lcr = Database.convertLead(lc);
        // System.assert(lcr.isSuccess());
        
        // // Converted Lead
        // Lead testLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :lead.Id];
        
        // // Opportunity
        // Opportunity oppTest = new Opportunity(Name = 'oppName',Primary_Contact__c = testLead.convertedContactId,Contact_Site__c='quintevents.com',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(),is_Applied_Rewards__c=true);
        // insert oppTest;
        
        // Product2 proStay = new Product2(Name='ARN Hotel Stay 1', isActive=true, 
        //                                     Event__c = eventTest.Id,
        //                                     A_La_Carte__c = true, Type__c = 'Hotel',Hotel_Id__c='111222133344',
        //                                     Check_In_Date__c=System.Today().addDays(2),Check_Out_Date__c=System.Today().addDays(4),
        //                                     RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Stay').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        // insert proStay;
        
        // PricebookEntry pbe7 = new PricebookEntry(unitprice=0.01,Product2Id=proStay.Id,Pricebook2Id=Test.getStandardPricebookId(),
        //                                         isActive=true,UseStandardPrice = false);
        // insert pbe7;
        
        // Test.StartTest(); 
        // OpportunityLineItem OPplineitem = new OpportunityLineItem(Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe7.Id,
        //                                                             ApexProductType__c = 'Hotel',Opportunity_Product_Package_Hotel__c=true,
        //                                                             H4H_Client_Name__c='Testing Method', H4H_Hold_Created__c=true,H4H_Adult_Quantity__c=2,
        //                                                             H4H_RatePlan_Code__c='ARN5575',H4H_Room_Code__c='5575',Roomtype_Id__c='451278');
        
        // insert OPplineitem;
        // // List<Opportunity_Payment_Terms__c> oppPayTerms = new List<Opportunity_Payment_Terms__c>([Select Id from Opportunity_Payment_Terms__c where Opportunity__c = :OPplineitem.OpportunityId AND Status__c != 'Passed']);
        // // for(Opportunity_Payment_Terms__c oppPayment : oppPayTerms) {
        // //     oppPayment.Status__c = 'Passed';
        // // }
        // // update oppPayTerms;
        
        // Rooming_List__c rlist = new Rooming_List__c(Guest_Name__c='Test', Opportunity__c=oppTest.Id, OpportunityLineItem_Id__c= OPplineitem.Id,H4H_Roomtype_Id__c='1243',Number_of_Adults__c=2);
        // insert rlist;
        
        // ApexPages.StandardController stdPro = new ApexPages.StandardController(rlist);
        // ApexPages.currentPage().getParameters().put('id',rlist.id);
        
        // QE_H4H_Create_Reservation_Rooming_CNTRL QEH4HReserv = new QE_H4H_Create_Reservation_Rooming_CNTRL(stdPro);
        // QEH4HReserv.createReservationAndRedirect();

        // Test.StopTest();
    }
}