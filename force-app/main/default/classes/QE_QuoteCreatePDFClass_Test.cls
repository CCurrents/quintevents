/**
 * @File Name          : QE_QuoteCreatePDFClass_Test.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/11/2020, 9:25:38 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest(seeAllData=false)
public class QE_QuoteCreatePDFClass_Test {
    @isTest static void test_method_one() {
        // QE360_Event__c eventTest = new QE360_Event__c(Name = 'test1', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        // Insert eventTest;
        
        //  Lead lead = new Lead();
        // lead.Google_Analytics_ID__c = 'gaID';
        // lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        // lead.FirstName = 'testName';
        // lead.LastName = 'testName';
        // lead.Status = 'Converted';
        // lead.Source__c = 'call Virtuoso';
        // lead.Company = 'test business';
        // lead.Email = 'abc@gmail.com';
        // insert lead;
        
        // Database.LeadConvert lc = new database.LeadConvert();
        // lc.setLeadId(lead.id);
        // lc.setDoNotCreateOpportunity(true);
        // lc.setConvertedStatus('Converted');
        // Database.LeadConvertResult lcr = Database.convertLead(lc);
        // System.assert(lcr.isSuccess());

        // Lead testLead = [select Id, IsConverted, ConvertedAccountId from Lead where Id = :lead.Id];
        
        // Contact contact = new Contact();
        // contact.accountid = testLead.ConvertedAccountId;
        // contact.lastname='test'; 
        // contact.email='test@quintevents.com';
        // contact.Primary_Contact__c  = true;
        // insert contact;
        
        // Opportunity oppTest = new Opportunity(Contact_Site__c = 'quintevents.com', Name = 'oppName',Payment_Method__c = 'Credit Card',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(), Primary_Contact__c = contact.Id);
        // insert oppTest;
        
        // Pricebook2 pb22 = new Pricebook2(Name='testDIE');
        // insert pb22;
        
        // Parent_Package__c  pp1 = new Parent_Package__c(Name = 'Parent Package 1 Demo', Event__c = eventTest.Id);
        // Insert pp1; 
        
        // Product2 proPack = new Product2(Name='BXCD1111', isActive=true, Type__c='Package',
        //                                 Event__c = eventTest.Id,Inventory__c=5,
        //                                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1,Parent_Package__c = pp1.Id);
        // insert proPack ;
        // Product2 proPro = new Product2(Name='BXCD2222', isActive=true, Type__c='Ticket',
        //                                Event__c = eventTest.Id,Inventory__c=5,
        //                                A_La_Carte__c = true,
        //                               RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        // insert proPro;
        // Product2 proHotel = new Product2(Name='BXCD3333', isActive=true,
        //                                Event__c = eventTest.Id,
        //                                  A_La_Carte__c = true,Inventory__c=5,Type__c='Hotel',
        //                               RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        // insert proHotel;
        // Product2 proPack1 = new Product2(Name='BXCD4444', isActive=true, Type__c='Package',
        //                                 Event__c = eventTest.Id,Inventory__c=5,
        //                                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1,Parent_Package__c = pp1.Id);
        // insert proPack1 ;
        // Product2 proPro2 = new Product2(Name='BXCD5555', isActive=true, Type__c='Ticket',
        //                                Event__c = eventTest.Id,Inventory__c=5,
        //                                A_La_Carte__c = true,
        //                               RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        // insert proPro2;
        // Product2 proHotel2 = new Product2(Name='BXCD6666', isActive=true,
        //                                Event__c = eventTest.Id,Inventory__c=5,
        //                                  A_La_Carte__c = true, Type__c='Hotel',
        //                               RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        // insert proHotel2;
        // Test.startTest();
        // Package_Products__c packPro1 = new Package_Products__c(Package__c = proPack.Id, Products_and_Hotels__c = proPro.Id);
        // insert packPro1;
        // Package_Products__c packPro2 = new Package_Products__c(Package__c = proPack.Id, Products_and_Hotels__c = proHotel.Id);
        // insert packPro2;
        
        // PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
        //                                         isActive=true,UseStandardPrice = false);
        // insert pbe2;
        // PricebookEntry pbe3 =new PricebookEntry(unitprice=0.01,Product2Id=proPro.Id,Pricebook2Id=Test.getStandardPricebookId(),
        //                                         isActive=true,UseStandardPrice = false);
        // insert pbe3;
        // PricebookEntry pbe4 =new PricebookEntry(unitprice=0.01,Product2Id=proHotel.Id,Pricebook2Id=Test.getStandardPricebookId(),
        //                                         isActive=true,UseStandardPrice = false);
        // insert pbe4;
        // PricebookEntry pbe5 =new PricebookEntry(unitprice=0.01,Product2Id=proPro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
        //                                         isActive=true,UseStandardPrice = false);
        // insert pbe5;
        // PricebookEntry pbe6 =new PricebookEntry(unitprice=0.01,Product2Id=proHotel2.Id,Pricebook2Id=Test.getStandardPricebookId(),
        //                                         isActive=true,UseStandardPrice = false);
        // insert pbe6;
        // PricebookEntry pbe7 =new PricebookEntry(unitprice=0.01,Product2Id=proPack1.Id,Pricebook2Id=Test.getStandardPricebookId(),
        //                                         isActive=true,UseStandardPrice = false);
        // insert pbe7;
        
        
        // OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id);
        // //insert OPplineitem2;
        // /*
        // OpportunityLineItem OPplineitem1 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe3.Id);
        // insert OPplineitem1;
        // OpportunityLineItem OPplineitem3 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id);
        // insert OPplineitem3;
        // OpportunityLineItem OPplineitem4 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id);
        // insert OPplineitem4;
        // */
        
        // Quote quoteTest = new Quote(Name = 'test',Payment_Method__c = 'Credit Card',OpportunityId = oppTest.Id,Pricebook2Id = Test.getStandardPricebookId(),createdDate = system.today());
        // insert quoteTest;
        
        // List<QuoteLineItem> lstQuoteLineItem  = new List<QuoteLineItem>();
        // QuoteLineItem Quolineitem2 = new QuoteLineItem (Record_Type__c='Package Product',Quantity=2,Product2Id=proPro.Id, QuoteId=quoteTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id,ProductType__c = 'Package');
        // lstQuoteLineItem.add(Quolineitem2);
        // QuoteLineItem Quolineitem1 = new QuoteLineItem (Record_Type__c='A La Carte', Quantity=2, Product2Id=proPro.Id,QuoteId=quoteTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe3.Id,ProductType__c = 'Hospitality');
        // lstQuoteLineItem.add(Quolineitem1);
        // QuoteLineItem Quolineitem3 = new QuoteLineItem (Record_Type__c='Package Product', Quantity=2,Product2Id=proPro2.Id, QuoteId=quoteTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id,Quote_Package__c = packPro1.id,ProductType__c = 'Ticket');
        // lstQuoteLineItem.add(Quolineitem3);
        // QuoteLineItem Quolineitem4 = new QuoteLineItem (Record_Type__c='Optional Package Product', Quantity=2,Product2Id=proPro2.Id,Quote_Product_Package_Hotel__c=true, QuoteId=quoteTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id,ProductType__c = 'Transportation');
        // lstQuoteLineItem.add(Quolineitem4);
        
        // insert lstQuoteLineItem;
        
        // Quote_Product_Package_Hotel__c qpph = new Quote_Product_Package_Hotel__c(Quote__c=quoteTest.Id, Hotel__c=proHotel2.Id,Package__c=proPack1.Id,Quantity__c=2);
        // insert qpph;
        // Test.stopTest();
        
        // ApexPages.StandardController stdPro = new ApexPages.StandardController(quoteTest );
        // ApexPages.currentPage().getParameters().put('id',quoteTest.id);
        
        // QE_QuoteCreatePDFClass QEClass = new QE_QuoteCreatePDFClass(stdPro);
        
        // QEClass.getQuotePackageList();
        // QEClass.getQuotePackageAndPackageIdMap();
        // QEClass.getQuotePackageCount();
        // QEClass.getQuotePackageProductMap();
        // QEClass.getQuoteALaCarteList();
        // QEClass.getQuoteALaCarteCount();
        // QEClass.getQuotePackageHotels();
        // QEClass.getHotelTransportationFromQuote();
        // QEClass.getTotalTax();
        // QEClass.getTotalShippingAndHandling();
        // QEClass.getCCFeeAmount();
        // QEClass.getQuoteAdditionalSignees();
        // QEClass.getAmountPortionForMainClient();        
        // // QEClass.getOpportunityPaymentTerms();
        
    }
}