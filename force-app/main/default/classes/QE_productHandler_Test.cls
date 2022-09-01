@isTest(seeAllData=true)
public class QE_productHandler_Test {
   
   static testMethod void AfterInsert1() { 
        Test.startTest(); 

        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;
        
        Pricebook2 customPB = new Pricebook2(Name='Standard Price Book1', isActive=true);
        List<Pricebook2> lstpb = new List<Pricebook2>();
        lstpb.add(customPB);
        insert lstpb;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Product2; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = AccountRecordTypeInfo .get('Products').getRecordTypeId();        
        
        
        List<Product2> lstProduct2 = new List<Product2>();
        Product2 prod = new Product2(Name = 'Standard Price Book',RecordTypeId = rtId,Family = 'Hardware',Price__c=200,Type__c='Ticket');
        lstProduct2.add(prod);
        //insert prod;    
        insert lstProduct2;

        //Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = lstProduct2[0].Id,

            UnitPrice = 100, IsActive = true);
        insert standardPrice;
        
        
                
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = lstpb[0].Id, Product2Id = lstProduct2[0].Id,
            UnitPrice = 1002, IsActive = true);
        insert customPrice;
        
        QE360_Event__c eventRec = new QE360_Event__c(Name='Test_Event' );    
        insert eventRec; 
        
        prod.event__c = eventRec.Id;
        
        Update prod;
        
        QE_productHandler.InsertMethod(lstProduct2);
        Test.stopTest();
        
    }
    /*
    static testMethod void AfterInsert2() { 
        Test.startTest();  
        QE360_Event__c eventRec = new QE360_Event__c(Name='Test_Event' );    
        insert eventRec; 
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Product2; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = AccountRecordTypeInfo .get('Products').getRecordTypeId();        
        
        
        List<Product2> lstProduct2 = new List<Product2>();
        Product2 prod = new Product2(Name = 'Standard Price Book',Family = 'Hardware',Price__c=200,Event__c=eventRec.Id);
        
        lstProduct2.add(prod);
        
        insert lstProduct2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = lstproduct2[0].id,
            UnitPrice = 500, IsActive = true);
        insert standardPrice;
        
        
       
        Pricebook2 customPB = new Pricebook2(Name='Standard Price Book2', isActive=true);
        List<Pricebook2> lstpb = new List<Pricebook2>();
        lstpb.add(customPB);
        insert lstpb;
        //insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = lstpb[0].Id, Product2Id = lstproduct2[0].id,
            UnitPrice = 100, IsActive = true);
        insert customPrice;
       
        
        QE_productHandler.InsertMethod(lstProduct2);
        Test.stopTest();
        
    }
    
   */ 
    
    static testMethod void AfterUpdate() { 
        Test.startTest();  
        User objeUser = [Select Id, ProfileId from User where Id=: '0051Y000009gr3E'];    
        system.runAs(objeUser){
            QE360_Event__c eventRec = new QE360_Event__c(Name='Test_Event',GPE_Event__c = true);    
            insert eventRec;     
            update eventRec;
            List<Product2> lstProduct2 = new List<Product2>();

            Parent_Package__c parentPackage= new Parent_Package__c();
            parentPackage.Event__c = eventRec.Id;
            insert parentPackage;
            Product2 prod = new Product2(Name='Test Prod',Event__c=eventRec.Id,Price__c=50,Parent_Package__c = parentPackage.Id,Auto_Generated_Product__c = true);
            lstProduct2.add(prod);
            //insert prod;    
            insert lstProduct2;
            update lstProduct2;
            Map<id,product2> mapProd2 = new Map<id,product2>();
            mapProd2.put(lstProduct2[0].id,prod);
            Id pricebookId = Test.getStandardPricebookId();
        
            //PricebookEntry standardPrice=[select Id,pricebookId,Product2Id from PricebookEntry where Pricebook2Id=:pricebookId and IsActive=true limit 1];
            
            //PricebookEntry standardPrice = new PricebookEntry(
            // Pricebook2Id = pricebookId, Product2Id = prod.Id,
            // UnitPrice = 10000, IsActive = true);
            //insert standardPrice;
            
            Pricebook2 customPB = new Pricebook2(Name='Standard Price Book1', isActive=true);
            List<Pricebook2> lstpb = new List<Pricebook2>();
            lstpb.add(customPB);
            insert lstpb;
            //insert customPB;
            
            //PricebookEntry customPrice=[select Id,pricebookId,Product2Id from PricebookEntry where Pricebook2Id=:lstpb[0].Id and IsActive=true limit 1];
            
            /*PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = lstpb[0].Id, Product2Id = prod.Id,
                UnitPrice = 12000, IsActive = true);
            insert customPrice;*/
            
            
            QE_productHandler.UpdateMethod( lstProduct2, mapProd2);
        }
        Test.stopTest();
    }
    static testMethod void AfterUpdate2() { 
        Test.startTest();               
        Id prodRecType = [Select Id,Name From RecordType Where sObjectType='Product2' and Name='Hotels'].Id;
        QE360_Event__c eventRec = new QE360_Event__c(Name='Test_Event');    
        insert eventRec;     
        update eventRec;
        List<Product2> lstProduct2 = new List<Product2>();
        //Product2 prod = new Product2(Name='Test Prod1',Event__c=eventRec.Id,Price__c=200, isActive=true);
        //lstProduct2.add(prod);
        Product2 prod = new Product2(Name='Test Prod',Price__c=100,Inventory__c=100,Cost__c=100,Type__c='Hotel',Event__c=eventRec.Id,RecordTypeId=prodRecType,isActive=true,Available__c=true,Quantity_Per_Order_Threshold__c=0);
        lstProduct2.add(prod);
        //insert prod;    
        insert lstProduct2;
        update lstProduct2;
        //insert prod;   
        // update prod;   
        //Product2 prod1 = new Product2(Name='Test Prod2',Event__c=eventRec.Id,Price__c=200, isActive=true);  
        //insert prod1; 
        Product2 prod1 = new Product2(Name='Test Prod1',Price__c=100,Inventory__c=100,Cost__c=100,Type__c='Hotel',Event__c=eventRec.Id,RecordTypeId=prodRecType,isActive=true,Available__c=true,Quantity_Per_Order_Threshold__c=0);
        insert prod1;  
        update prod1;
        Map<id,product2> mapProd2 = new Map<id,product2>();
        mapProd2.put(lstProduct2[0].id,prod);
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=prod.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        
        //Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
        //List<Pricebook2> lstpb = new List<Pricebook2>();
        //lstpb.add(customPB);
        //insert lstpb;
        
        QE_productHandler.UpdateMethod( lstProduct2, mapProd2);
        Test.stopTest();
    }
    
    static testMethod void AfterUpdate3() { 
        Test.startTest();               
        QE360_Event__c eventRec = new QE360_Event__c(Name='Test_Event');    
        insert eventRec;     
        update eventRec;
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Product2; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = AccountRecordTypeInfo .get('Products').getRecordTypeId();  
        Id rtId2 = AccountRecordTypeInfo .get('Hotels').getRecordTypeId();   
        List<Product2> lstProduct2 = new List<Product2>();
        Product2 prod = new Product2(Name='Test Prod',Event__c=eventRec.Id,Price__c=200,recordTypeId = rtId,Type__c='Discount');
        Product2 prod2 = new Product2(Name='Test Prod2',Event__c=eventRec.Id,Price__c=200,recordTypeId = rtId2,Type__c='Hotel');
        lstProduct2.add(prod);
        lstProduct2.add(prod2);
        //insert prod;    
        insert lstProduct2;
        update lstProduct2;
        //insert prod;   
        // update prod;   
       
        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = eventRec.Id;
        insert parentPackage;
        Product2 prod1 = new Product2(Name='Test Prod4',Event__c=eventRec.Id,Price__c=200,Parent_Package__c = parentPackage.Id);  
        insert prod1;  
        Map<id,product2> mapProd2 = new Map<id,product2>();
        mapProd2.put(lstProduct2[0].id,prod);
        Id pricebookId = Test.getStandardPricebookId();
        
        //Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
        //List<Pricebook2> lstpb = new List<Pricebook2>();
        //lstpb.add(customPB);
        //insert lstpb;
        
        QE_productHandler.UpdateMethod( lstProduct2, mapProd2);
        QE_productHandler.beforedeleteMethod(lstProduct2);
        delete prod2;
        Test.stopTest();
    }
    
    static testMethod void AfterUpdate4() { 
        Test.startTest();               
        QE360_Event__c eventRec = new QE360_Event__c(Name='Test_Event',International_Stripe__c = true);    
        insert eventRec;     
        update eventRec;
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Product2; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = AccountRecordTypeInfo .get('Products').getRecordTypeId();  
        Id rtId2 = AccountRecordTypeInfo .get('Hotels').getRecordTypeId();   
        List<Product2> lstProduct2 = new List<Product2>();
        Product2 prod = new Product2(Name='Test Prod',Event__c=eventRec.Id,Price__c=200,recordTypeId = rtId,Type__c='Giftbag');
        Product2 prod2 = new Product2(Name='Test Prod2',Event__c=eventRec.Id,Price__c=200,recordTypeId = rtId2,Type__c='Hotel');
        lstProduct2.add(prod);
        lstProduct2.add(prod2);
        //insert prod;    
        insert lstProduct2;
        update lstProduct2;
        //insert prod;   
        // update prod; 
        
        Parent_Package__c parentPackage= new Parent_Package__c();
        parentPackage.Event__c = eventRec.Id;
        insert parentPackage;  
        Product2 prod1 = new Product2(Name='Test Prod4',Event__c=eventRec.Id,Price__c=300,Parent_Package__c = parentPackage.Id);  
        insert prod1;  
        Map<id,product2> mapProd2 = new Map<id,product2>();
        mapProd2.put(lstProduct2[0].id,prod);
        
        lstProduct2[0].price__c = 300;
        update lstProduct2[0];
        
        Map<id,product2> mapProd3 = new Map<id,product2>();
        mapProd3.put(lstProduct2[0].id,prod);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        //Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
        //List<Pricebook2> lstpb = new List<Pricebook2>();
        //lstpb.add(customPB);
        //insert lstpb;
        
        QE_productHandler.updatePBEntrykUnitPrice( mapProd3, mapProd2);
        
        Test.stopTest();
    }
}