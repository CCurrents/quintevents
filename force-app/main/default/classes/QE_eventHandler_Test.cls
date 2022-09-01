@isTest
public class QE_eventHandler_Test {    

    Static testMethod void testEventInsertUpdate() {
        QE360_Event__c testEvent1 = new QE360_Event__c(Name='test1');
        insert testEvent1;
        try {
            QE360_Event__c testEvent1_Dup = new QE360_Event__c(Name='test1');
            insert testEvent1_Dup;
        } catch (Exception e) {
            
        }
        QE360_Event__c testEvent2 = new QE360_Event__c(Name='test2');
        insert testEvent2;

        testEvent2.Name = 'test1';
        try {
            update testEvent2;
        } catch (Exception e) {
            
        }
    }
     
      static testMethod void testEventInternationStripeUpdate(){
        Test.startTest(); 
        //Test.setMock(HttpCalloutMock.class, new QE_MockHttpResEventHandler());
        //String str = QE_brandFuelDatainsert.dataInsert('<img alt="User-added image" src="https://c.cs13.content.force.com/servlet/rtaImage?eid=a0bW0000003tJcl&amp;feoid=00Ni000000GwynY&amp;refid=0EMW0000000DScD"></img>','Test_Eve2',system.today(),System.today(),true);
        List<QE360_Event__c> eveList = new List<QE360_Event__c>();
        List<PricebookEntry> pbeList = new List <PricebookEntry>();
        QE360_Event__c eventRec = new QE360_Event__c(Name='Test_Event', GPE_Event__c = true);    
        eveList.add(eventRec);
        
        QE360_Event__c eventRec1 = new QE360_Event__c(Name='Test_Event1');    
        eveList.add(eventRec1);
        
        QE360_Event__c eventRec2 = new QE360_Event__c(Name='Test_Event2');    
        eveList.add(eventRec2);
        
        QE360_Event__c eventRec3 = new QE360_Event__c(Name='Test_Event3');    
        eveList.add(eventRec3);
                      
        Insert eveList;
        
        
        Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Hotels'].Id;
        Product2 prod = new Product2(Name='Test Prod',Inventory__c=10,price__c=10,Type__c='Hotel',Event__c=eveList[0].Id,RecordTypeId=prodRecType,isActive=true,Available__c=true,Quantity_Per_Order_Threshold__c=0);
        insert prod;
        
        Product2 prod2 = new Product2(Name='Test Prod1',Inventory__c=10,price__c=10,Type__c='Hotel',Event__c=eveList[1].Id,RecordTypeId=prodRecType,isActive=true,Available__c=true,Quantity_Per_Order_Threshold__c=0);
        insert prod2;
        
        Product2 prod3 = new Product2(Name='Test Prod2',Inventory__c=10,price__c=10,Type__c='Hotel',Event__c=eveList[2].Id,RecordTypeId=prodRecType,isActive=true,Available__c=true,Quantity_Per_Order_Threshold__c=0);
        insert prod3;
        
        Product2 prod4 = new Product2(Name='Test Prod3',Inventory__c=10,price__c=10,Type__c='Hotel',Event__c=eveList[3].Id,RecordTypeId=prodRecType,isActive=true,Available__c=true,Quantity_Per_Order_Threshold__c=0);
        insert prod4;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Name='Standard Price Book',
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );        
        update standardPricebook;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice= 0.2,Product2Id=prod.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=prod.isActive,UseStandardPrice = false,CurrencyIsoCode = 'USD');
        pbeList.add(pbe2);
        
        PricebookEntry pbe3 =new PricebookEntry(unitprice=1.9,Product2Id=prod2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=prod2.isActive,UseStandardPrice = false,CurrencyIsoCode = 'USD');
        pbeList.add(pbe3);
        
         PricebookEntry pbe4 =new PricebookEntry(unitprice=50.2,Product2Id=prod3.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=prod3.isActive,UseStandardPrice = false,CurrencyIsoCode = 'USD');
        pbeList.add(pbe4);        
        insert pbeList;
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Standard Price Book3', isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
       insert customPrice;
              
        list<QE360_Event__c> newevents = [select id,name,International_Stripe__c,program__c from QE360_Event__c];
        Map<id,QE360_Event__c> oldeveMap = new Map<id,QE360_Event__c>();
        Map<id,QE360_Event__c> neweveMap = new Map<id,QE360_Event__c>();
        List<QE360_Event__c> eveListupdate = new List<QE360_Event__c>();
        Set<Id> ids = new Set<Id>();

        for( QE360_Event__c eve:newevents){
             oldeveMap.put(eve.id,eve);
             eve.International_Stripe__c = true;
             eveListupdate.add(eve);
             ids.add(eve.Id);
             }
        update eveListupdate;
         for( QE360_Event__c eve:[select id,name,International_Stripe__c,program__c from QE360_Event__c]){
             neweveMap.put(eve.id,eve);
             
             }
        QE_eventHandler.checkNameUniqueness(eveList);
        QE_eventHandler.captureDeletedEvents(eveList);        
        QE_eventHandler.chkIntrStripeAndcreatePBE(neweveMap,oldeveMap);
        QE_eventHandler.resellerEventCreate(neweveMap,oldeveMap);
        QE_eventHandler.insertPriceBookEntryonGPTEventUpdate(ids);
             }
             
     Static testMethod void EveLogoonAWS(){                 
        Test.startTest();
        Set<Id> eveIds = new Set<Id>();
        List<QE360_Event__c > eventsList = new List<QE360_Event__c>();   
        
            QE360_Event__c event1 = new QE360_Event__c(Name='Test_Eve1');    
            eventsList.add(event1);
        
            QE360_Event__c event2 = new QE360_Event__c(Name='Test_Eve2');    
            eventsList.add(event2); 
            insert eventsList;
        
            QE360_Event__c event3 = new QE360_Event__c(Name='Test',logo__c = '<img alt="User-added image" src="https://c.cs13.content.force.com/servlet/rtaImage?eid=a0bW0000003tJcl&amp;feoid=00Ni000000GwynY&amp;refid=0EMW0000000DScD"></img>',CreatedDate =system.today(),End_Date__c = system.today());    
            insert event3;       
            eveIds.add(event3.id);  
           //QE_eventHandler.sendImagetoAWS(eventsList);
           //QE_eventHandler.postImageToAWS(eveIds);  
           //String str = QE_brandFuelDatainsert.dataInsert('<img alt="User-added image" src="https://c.cs13.content.force.com/servlet/rtaImage?eid=a0bW0000003tJcl&amp;feoid=00Ni000000GwynY&amp;refid=0EMW0000000DScD"></img>','Test_Eve2',system.today(),System.today(),true);
          // HttpResponse res = QE_eventHandler.sendImagetoAWS(eventsList);
           Test.stopTest(); 
        
      }  
      
      Static testMethod void evntDataInsertBdFuel(){
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new QE_MockHttpResEventHandler());
        //QE_brandFuelDatainsert.dataUpdate('8856','<img alt="User-added image" src="https://c.cs13.content.force.com/servlet/rtaImage?eid=a0bW0000003tJcl&amp;feoid=00Ni000000GwynY&amp;refid=0EMW0000000DScD"></img>','Test_Eve2',system.today(),System.today());
        List<QE360_Event__c> eveListRecs = new List<QE360_Event__c>();
        List<PricebookEntry> pbeListRecs = new List <PricebookEntry>();
        QE360_Event__c eventRec = new QE360_Event__c(Name='Test_Event');    
        eveListRecs.add(eventRec);
        
        QE360_Event__c evRec1 = new QE360_Event__c(Name='Test Eve1');    
        eveListRecs.add(evRec1);
        
        QE360_Event__c evRec2 = new QE360_Event__c(Name='Test Eve2');    
        eveListRecs.add(evRec2);                      
        Insert eveListRecs;
        
        
         Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Hotels'].Id;
        Product2 prodRec = new Product2(Name='Test Prod',Inventory__c=10,price__c=10,Type__c='Hotel',Event__c=eveListRecs[0].Id,RecordTypeId=prodRecType,isActive=true,Available__c=true,Quantity_Per_Order_Threshold__c=0);
        insert prodRec;
        
        Product2 prodRec2 = new Product2(Name='Test Prod1',Inventory__c=10,price__c=10,Type__c='Hotel',Event__c=eveListRecs[1].Id,RecordTypeId=prodRecType,isActive=true,Available__c=true,Quantity_Per_Order_Threshold__c=0);
        insert prodRec2;
        
        /*Pricebook2 standardPricebook = new Pricebook2(
            Name='Standard Price Book',
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;
        */
       PricebookEntry pbe2 =new PricebookEntry(unitprice= 0.2,Product2Id=prodRec.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=prodRec.isActive,UseStandardPrice = false,CurrencyIsoCode = 'USD');
        pbeListRecs.add(pbe2);        
        insert pbeListRecs;       
        // Create a custom price book
        Pricebook2 customPB1 = new Pricebook2(Name='Standard Price Book3', isActive=true);
        insert customPB1;
        
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB1.Id, Product2Id = prodRec.Id,
            UnitPrice = 12000, IsActive = true);
       insert customPrice;
             
  }
  }