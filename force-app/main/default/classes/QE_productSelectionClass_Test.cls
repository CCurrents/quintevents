@isTest(seeAllData=false)
public class QE_productSelectionClass_Test {
    
    @isTest static void test_method_one() {
        // Event
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        
        // Lead
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Interested';
        lead.Source__c = 'call Virtuoso';
        lead.Email = 'test@test.com';
        lead.Company = 'test business';
        insert lead;
        
        // Convert Lead        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        // Converted Lead
        Lead testLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :lead.Id];
        
        // Opportunity
        Opportunity oppTest = new Opportunity(Name = 'oppName',Primary_Contact__c = testLead.convertedContactId,Contact_Site__c='quintevents.com',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(),is_Applied_Rewards__c=true);
        insert oppTest;
        
        Parent_Package__c  pp1 = new Parent_Package__c(Name = 'Legend', Event__c = eventTest.Id);
        Insert pp1;
        
        List<product2> lstProducttoInsert = New List<product2>();
        // Package
        Product2 proPack = new Product2(Name='BXCD111', isActive=true, 
                                        Event__c = eventTest.Id,
                                        Type__c = 'Package',
                                        Parent_Package__c = pp1.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proPack);
        
        // Product
        Product2 proPro = new Product2(Name='BXCD222', isActive=true, 
                                       Event__c = eventTest.Id,
                                       A_La_Carte__c = true,
                                       Type__c = 'Ticket',
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proPro);
        
        // Product (Hotel)
        Product2 proHotel = new Product2(Name='BXCD333', isActive=true, 
                                       Event__c = eventTest.Id,
                                         A_La_Carte__c = true, Type__c = 'Hotel',
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proHotel);
        
        // Product (Hotel)
        Product2 proHotel2 = new Product2(Name='BXCD666', isActive=true, 
                                       Event__c = eventTest.Id,
                                         A_La_Carte__c = true, Type__c = 'Hotel',
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proHotel2);
        
        // Product (ARN Hotel)
        Product2 proARNHotel = new Product2(Name='ARN Hotel', isActive=true, 
                                                Event__c = eventTest.Id,
                                                A_La_Carte__c = true, Type__c = 'Hotel',Hotel_Id__c='111222133344',
                                                Check_In_Date__c=System.Today().addDays(2),Check_Out_Date__c=System.Today().addDays(4),
                                                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proARNHotel);
        
        // Product (Stay)
        Product2 proStay = new Product2(Name='ARN Hotel Stay 1', isActive=true, 
                                                Event__c = eventTest.Id,Price__c=10,
                                                A_La_Carte__c = true, Type__c = 'Hotel',Hotel_Id__c='111222133344',
                                                Check_In_Date__c=System.Today().addDays(2),Check_Out_Date__c=System.Today().addDays(4),
                                                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Stay').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proStay);

        // Product
        Product2 proTransportation = new Product2(Name='BXCD1237', isActive=true, 
                                        Event__c = eventTest.Id, A_La_Carte__c = true, Inventory__c = 2, Type__c='Transportation',
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proTransportation);
        
        // Stay Transportation
        Product2 proStayTransportation = new Product2(Name='Stat Trans', isActive=true, 
                                        Event__c = eventTest.Id, A_La_Carte__c = true, Inventory__c = 2, Type__c='Transportation',
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proStayTransportation);
        
        insert lstProducttoInsert;
        
        // Hotel Tranportation
        Hotel_Transportation__c hotelTransportation = new Hotel_Transportation__c(Hotel__c=proHotel.Id,Transportation__c=proTransportation.Id);
        Hotel_Transportation__c hotelstayTransportation = new Hotel_Transportation__c(Hotel__c=proARNHotel.Id,Transportation__c=proStayTransportation.Id);
        insert new List<Hotel_Transportation__c>{hotelTransportation,hotelstayTransportation};
        
        List<Package_Products__c> lstpckgproducts = New List<Package_Products__c>();
        // Package Products
        Package_Products__c package_Product=new Package_Products__c(Package__c=proPack.Id,Products_and_Hotels__c=proPro.Id);
        //insert package_Product;
        lstpckgproducts.add(package_Product);
        
        Package_Products__c packProds = new Package_Products__c(Package__c=proPack.Id,Products_and_Hotels__c=proHotel.Id);
        //insert packProds;
        lstpckgproducts.add(packProds);
        
        Package_Products__c packARNProds = new Package_Products__c(Package__c=proPack.Id,Products_and_Hotels__c=proARNHotel.Id);
        //insert packProds;
        lstpckgproducts.add(packARNProds);
        
        insert lstpckgproducts;
        
        Hotel_Room_Package__c hotelRoomPackage = new Hotel_Room_Package__c(Hotel_Package_Product__c=proARNHotel.Id, ARN_Room_Product__c=proStay.Id);
        insert hotelRoomPackage;
       
        // Price book Entries
        // Package
        PricebookEntry pbe2 = new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        // Package Product
        PricebookEntry pbe3 = new PricebookEntry(unitprice=0.01,Product2Id=proPro.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        // Hotel
        PricebookEntry pbe4 = new PricebookEntry(unitprice=0.01,Product2Id=proHotel.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
                                                // Hotel
        // ARN Hotel
        PricebookEntry pbe5 = new PricebookEntry(unitprice=0.01,Product2Id=proStay.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
                                                
        // Hotel Transportation
        PricebookEntry pbe6 = new PricebookEntry(unitprice=0.01,Product2Id=proTransportation.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
                                                
                                                // Hotel Transportation
        PricebookEntry pbe7 = new PricebookEntry(unitprice=0.01,Product2Id=proStayTransportation.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert new List<PricebookEntry>{pbe2, pbe3, pbe4, pbe5, pbe6, pbe7};
        
        
        List<OpportunityLineItem> opplineItems = new List<OpportunityLineItem>();
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2,Record_Type__c='Package',Package__c = pbe4.Product2Id,Opportunity_Product_Package_Hotel__c =true, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id,ApexProductType__c = 'Package');
        opplineItems.add(OPplineitem2);
        
        OpportunityLineItem OPplineitem4 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id,ApexProductType__c = 'Package',Package__c = pbe4.Product2Id,Opportunity_Product_Package_Hotel__c =true);
        opplineItems.add(OPplineitem4);
        
        ApexPages.StandardController stdPro = new ApexPages.StandardController(oppTest);
        ApexPages.currentPage().getParameters().put('id',oppTest.id);
        
        Test.startTest();
        QE_productSelectionClass QEClass = new QE_productSelectionClass(stdPro);
        
        QEClass.selectedProduct = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId();
        QEClass.displayProduct();
        
        QEClass.selectedProduct = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();
        QEClass.displayProduct();
        
        QEClass.displayProductValues[0].selectBit = true;
        QEClass.displayProductValues[0].quantity = 1;
        QEClass.displayProductValues[0].objProduct = pbe2;
        
        QEClass.processSelected();
        
        QEClass.packId = pbe2.Id;
        QEClass.showPopup();

        QEClass.displayPackHotel[0].selectBit = true;
        QEClass.displayPackHotel[0].objProduct = packProds;
        QEClass.displayPackHotel[0].quantity = 1;
        QEClass.displayPackHotel[0].price = 1;
        QEClass.displayPackHotel[0].roomType = 'One Bed';
        QEClass.displayPackHotel[0].oliId = oppTest.id;
     
        QEClass.displayARNHotel[0].selectBit = true;
        QEClass.displayARNHotel[0].adultquantity = 2;
        QEClass.hotelTransportationByHotelList[0].selectBit = true;
        
        QEClass.arnHotelTransportationList[0].selectBit = true;

        QEClass.addHotelPopup();
        QEClass.HotelForHopeCallout();
        QE_productSelectionClass.dummyCoverage();

        Test.stopTest();
    }
    
    @isTest static void test_method1() {
        // Event
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', GPE_Event__c=true, X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        
        // Lead
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Interested';
        lead.Source__c = 'call Virtuoso';
        lead.Email = 'test@test.com';
        lead.Company = 'test business';
        insert lead;
        
        // Convert Lead        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        // Converted Lead
        Lead testLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :lead.Id];
        
        // Opportunity
        Opportunity oppTest = new Opportunity(Name = 'oppName',Primary_Contact__c = testLead.convertedContactId,Contact_Site__c='quintevents.com',Amount=1000,Payment_Terms__c= '1/2',AccountId = testLead.ConvertedAccountId,Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(),is_Applied_Rewards__c=true);
        insert oppTest;
        
        Parent_Package__c  pp1 = new Parent_Package__c(Name = 'Legend', Event__c = eventTest.Id);
        Insert pp1;
        
        List<product2> lstProducttoInsert = New List<product2>();
        // Package
        Product2 proPack = new Product2(Name='BXCD111', isActive=true, Visible_to_Sales_Rep__c=true,
                                        Event__c = eventTest.Id,
                                        Type__c = 'Package',
                                        Parent_Package__c = pp1.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proPack);
        
        // Product
        Product2 proPro = new Product2(Name='BXCD222', isActive=true, Visible_to_Sales_Rep__c=true,
                                       Event__c = eventTest.Id,
                                       A_La_Carte__c = true,
                                       Type__c = 'Ticket',
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proPro);
        
        // Product (Hotel)
        Product2 proHotel = new Product2(Name='BXCD333', isActive=true, Visible_to_Sales_Rep__c=true,
                                       Event__c = eventTest.Id,
                                         A_La_Carte__c = true, Type__c = 'Hotel',
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proHotel);
        
        // Product (Hotel)
        Product2 proHotel2 = new Product2(Name='BXCD666', isActive=true, Visible_to_Sales_Rep__c=true,
                                       Event__c = eventTest.Id,
                                         A_La_Carte__c = true, Type__c = 'Hotel',
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proHotel2);
        
        // Product (ARN Hotel)
        Product2 proARNHotel = new Product2(Name='ARN Hotel', isActive=true, Visible_to_Sales_Rep__c=true,
                                                Event__c = eventTest.Id,
                                                A_La_Carte__c = true, Type__c = 'Hotel',Hotel_Id__c='111222133344',
                                                Check_In_Date__c=System.Today().addDays(2),Check_Out_Date__c=System.Today().addDays(4),
                                                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proARNHotel);
        
        // Product (Stay)
        Product2 proStay = new Product2(Name='ARN Hotel Stay 1', isActive=true, Visible_to_Sales_Rep__c=true,
                                                Event__c = eventTest.Id,
                                                A_La_Carte__c = true, Type__c = 'Hotel',Hotel_Id__c='111222133344',
                                                Check_In_Date__c=System.Today().addDays(2),Check_Out_Date__c=System.Today().addDays(4),
                                                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Stay').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proStay);

        // Product
        Product2 proTransportation = new Product2(Name='BXCD1237', isActive=true, Visible_to_Sales_Rep__c=true,
                                        Event__c = eventTest.Id, A_La_Carte__c = true, Inventory__c = 2, Type__c='Transportation',
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proTransportation);
        
        // Stay Transportation
        Product2 proStayTransportation = new Product2(Name='Stat Trans', isActive=true, Visible_to_Sales_Rep__c=true,
                                        Event__c = eventTest.Id, A_La_Carte__c = true, Inventory__c = 2, Type__c='Transportation',
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proStayTransportation);
        
        insert lstProducttoInsert;
        
        List<Package_Products__c> lstpckgproducts = New List<Package_Products__c>();
        // Package Products
        Package_Products__c package_Product=new Package_Products__c(Package__c=proPack.Id,Products_and_Hotels__c=proPro.Id);
        //insert package_Product;
        lstpckgproducts.add(package_Product);
        
        Package_Products__c packProds = new Package_Products__c(Package__c=proPack.Id,Products_and_Hotels__c=proHotel.Id);
        //insert packProds;
        lstpckgproducts.add(packProds);
        
        Package_Products__c packARNProds = new Package_Products__c(Package__c=proPack.Id,Products_and_Hotels__c=proARNHotel.Id);
        //insert packProds;
        lstpckgproducts.add(packARNProds);
        
        insert lstpckgproducts;
        
        // Price book Entries
        // Package
        PricebookEntry pbe2 = new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        // Package Product
        PricebookEntry pbe3 = new PricebookEntry(unitprice=0.01,Product2Id=proPro.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        // Hotel
        PricebookEntry pbe4 = new PricebookEntry(unitprice=0.01,Product2Id=proHotel.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
                                                // Hotel
        // ARN Hotel
        PricebookEntry pbe5 = new PricebookEntry(unitprice=0.01,Product2Id=proStay.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
                                                
        // Hotel Transportation
        PricebookEntry pbe6 = new PricebookEntry(unitprice=0.01,Product2Id=proTransportation.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
                                                
                                                // Hotel Transportation
        PricebookEntry pbe7 = new PricebookEntry(unitprice=0.01,Product2Id=proStayTransportation.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        
        insert new List<PricebookEntry>{pbe2, pbe3, pbe4, pbe5, pbe6, pbe7};
        
        
        List<OpportunityLineItem> opplineItems = new List<OpportunityLineItem>();
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2,Record_Type__c='Package',Package__c = pbe4.Product2Id,Opportunity_Product_Package_Hotel__c =true, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id,ApexProductType__c = 'Package');
        opplineItems.add(OPplineitem2);
        
        OpportunityLineItem OPplineitem4 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id,ApexProductType__c = 'Package',Package__c = pbe4.Product2Id,Opportunity_Product_Package_Hotel__c =true);
        opplineItems.add(OPplineitem4);
        
        ApexPages.StandardController stdPro = new ApexPages.StandardController(oppTest);
        ApexPages.currentPage().getParameters().put('id',oppTest.id);
        
        Test.startTest();

        QE_productSelectionClass QEClass = new QE_productSelectionClass(stdPro);
        
        QEClass.selectedProduct = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId();
        QEClass.displayProduct();
        
        QEClass.selectedProduct = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId();
        QEClass.displayProduct();
        Test.stopTest();
    }
    
    @isTest static void test_method_two() {
        //Program
        Program__c program = new Program__c();
        program.Name = 'test prgram F1E';
        //insert program;

        // Event
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1/*,Program__c = program.Id*/);
        Insert eventTest;
        
        // Lead
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Interested';
        lead.Source__c = 'call Virtuoso';
        lead.Email = 'test@test.com';
        lead.Company = 'test business';
        insert lead;
        
        // Convert Lead        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        // Converted Lead
        //Lead testLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :lead.Id];
        
        // Opportunity
        Opportunity oppTest = new Opportunity(Name = 'oppName',Primary_Contact__c = lcr.getContactId(),Contact_Site__c='quintevents.com',Amount=1000,Payment_Terms__c= '1/2',AccountId = lcr.getAccountId(),Event__c = eventTest.Id,StageName = 'Prospecting',CloseDate = System.today(),is_Applied_Rewards__c=true);
        insert oppTest;
        
        Parent_Package__c  pp1 = new Parent_Package__c(Name = 'Legend', Event__c = eventTest.Id);
        Insert pp1;
        
        List<product2> lstProducttoInsert = New List<product2>();
        // Package
        Product2 proPack = new Product2(Name='BXCD111', isActive=true, 
                                        Event__c = eventTest.Id,
                                        Type__c = 'Package',
                                        Parent_Package__c = pp1.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proPack);
        
        // Product
        Product2 proPro = new Product2(Name='BXCD222', isActive=true, 
                                       Event__c = eventTest.Id,
                                       A_La_Carte__c = true,
                                       Type__c = 'Ticket',
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proPro);
        
        // Product (Hotel)
        Product2 proHotel = new Product2(Name='BXCD333', isActive=true, 
                                       Event__c = eventTest.Id,
                                         A_La_Carte__c = true, Type__c = 'Hotel',
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proHotel);
        
        // Product (Hotel)
        Product2 proHotel2 = new Product2(Name='BXCD666', isActive=true, 
                                            Event__c = eventTest.Id,
                                            A_La_Carte__c = true, Type__c = 'Hotel',
                                            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proHotel2);
      
        // Product
        Product2 proTransportation = new Product2(Name='BXCD1237', isActive=true, 
                                                    Event__c = eventTest.Id, A_La_Carte__c = true, Inventory__c = 2, Type__c='Transportation',
                                                    RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proTransportation);
        
        //delete [Select Id from Product2 where Name='Discount'];
        insert lstProducttoInsert;
        
        // Hotel Tranportation
        Hotel_Transportation__c hotelTransportation = new Hotel_Transportation__c(Hotel__c=proHotel.Id,Transportation__c=proTransportation.Id);
        insert hotelTransportation;
        
        List<Package_Products__c> lstpckgproducts = New List<Package_Products__c>();
        // Package Products
        Package_Products__c package_Product=new Package_Products__c(Package__c=proPack.Id,Products_and_Hotels__c=proPro.Id);
        lstpckgproducts.add(package_Product);

        Package_Products__c packProds = new Package_Products__c(Package__c=proPack.Id,Products_and_Hotels__c=proHotel.Id);
        lstpckgproducts.add(packProds);
        
        insert lstpckgproducts;

        // Price book Entries
        // Package
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=proPack.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        // Package Product
        PricebookEntry pbe3 =new PricebookEntry(unitprice=0.01,Product2Id=proPro.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        // Hotel
        PricebookEntry pbe4 =new PricebookEntry(unitprice=0.01,Product2Id=proHotel.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);

        insert new List<PricebookEntry>{pbe2, pbe3, pbe4/*, pbe5*/};

        List<OpportunityLineItem> opplineItems = new List<OpportunityLineItem>();
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2,Record_Type__c='Package',Package__c = pbe4.Product2Id,Opportunity_Product_Package_Hotel__c =true, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id,ApexProductType__c = 'Package');
        opplineItems.add(OPplineitem2);

        OpportunityLineItem OPplineitem4 = new OpportunityLineItem (Quantity=2, OpportunityId=oppTest.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id,ApexProductType__c = 'Package',Package__c = pbe4.Product2Id,Opportunity_Product_Package_Hotel__c =true);
        opplineItems.add(OPplineitem4);
        Test.startTest();

        insert opplineItems;

        ApexPages.StandardController stdPro = new ApexPages.StandardController(oppTest);
        ApexPages.currentPage().getParameters().put('id',oppTest.id);

        QE_productSelectionClass QEClass = new QE_productSelectionClass(stdPro);
        
        /*Product2 proDiscount1 = [Select Id from Product2 where Name='Discount' Limit 1];
        PricebookEntry pbe5 =new PricebookEntry(unitprice=0.01,Product2Id=proDiscount1.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe5;*/
        
        QEClass.addOppLineItem();
        QEClass.hotelError = true;
        QEClass.closePopup();
        QEClass.hotelError = false;
        QEClass.closePopup();        
        QEClass.CancelMethod();       
        QEClass.getRoomTypeOptions();
        Test.stopTest();
    }
}