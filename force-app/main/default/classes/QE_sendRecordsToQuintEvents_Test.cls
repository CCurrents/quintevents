//This class also covers QE_Event_Trigger,QE_Product2_Trigger triggers and QE_sendDeletedRecordsToQuintEvents,QE_callOutToQuintEvents classes
@isTest
public class QE_sendRecordsToQuintEvents_Test{
    
    @testSetup static void dataSetUp() {
        List<QE_SF_API_Details__c> settLst = new List<QE_SF_API_Details__c>(); 
        settLst.add(new QE_SF_API_Details__c(Name='Hotels',Endpoint__c='Test EndPoint',Object_Name__c='Product2',Token__c='123455'));
        settLst.add(new QE_SF_API_Details__c(Name='Package',Endpoint__c='Test EndPoint',Object_Name__c='Product2',Token__c='123455'));
        settLst.add(new QE_SF_API_Details__c(Name='Products',Endpoint__c='Test EndPoint',Object_Name__c='Product2',Token__c='123455'));
        settLst.add(new QE_SF_API_Details__c(Name='QE360_Event__c',Endpoint__c='Test EndPoint',Object_Name__c='QE360_Event__c',Token__c='123455'));
        settLst.add(new QE_SF_API_Details__c(Name='Package_Products',Endpoint__c='Test EndPoint',Object_Name__c='Package_Products__c',Token__c='123455'));
        settLst.add(new QE_SF_API_Details__c(Name='Package_Hotels',Endpoint__c='Test EndPoint',Object_Name__c='Package_Products__c',Token__c='123455'));
        insert settLst;
    }
    
    static testMethod void AfterInsert() { 
        Test.startTest();               
        String productRecordTypeId = [Select Id From RecordType Where SobjectType = 'Product2' and Name = 'Products'].Id;
        String hotelRecordTypeId = [Select Id From RecordType Where SobjectType = 'Product2' and Name = 'Hotels'].Id;
 
        QE360_Event__c eventRec = new QE360_Event__c(Name='Test_Event');    
        insert eventRec;        
        
        Product2 prod = new Product2(Name='Test Prod',Event__c=eventRec.Id,IsActive=True);
        insert prod;
        system.debug('prod id '+prod.Id);
         
        Product2 prodHotel = new Product2(Name='Test Prod1',Event__c=eventRec.Id,recordtypeId=hotelRecordTypeId,IsActive=True );
        insert prodHotel;
        system.debug('prodHotel id '+prodHotel.Id);
        
        Product2 prodProducts = new Product2(Name='Test Prod2',Event__c=eventRec.Id,recordtypeId=productRecordTypeId, IsActive=True);
        insert prodProducts ;  
        system.debug('prodProducts Id '+prodProducts.Id);
        
        Package_Products__c packageProd = new Package_Products__c ();
        packageProd.Amount__c= 1000;
        packageProd.Package__c = prod.id;
        system.debug('prod Id for package product '+prod.Id);
        packageProd.Products_and_Hotels__c=prodProducts.id ;
        system.debug('Products hotel id value '+packageProd.Products_and_Hotels__c);
        //packageProd.Products_and_Hotels__r.IsActive = prodProducts.IsActive;
        insert packageProd;
        
        
        Package_Products__c packageProd1 = new Package_Products__c ();
        packageProd1.Amount__c= 1000;
        packageProd1.Package__c = prod.id;
        packageProd1.Products_and_Hotels__c=prodHotel.id ;
        //packageProd.Products_and_Hotels__r.IsActive = prodHotel.IsActive;
        insert packageProd1;
        Test.stopTest();
    }
    static testMethod void AfterUpdate() { 
        Test.startTest();               
        QE360_Event__c eventRec = new QE360_Event__c(Name='Test_Event');    
        insert eventRec;     
        update eventRec;
        
        Product2 prod = new Product2(Name='Test Prod',Event__c=eventRec.Id);
        insert prod;   
        update prod;
        
        String productRecordTypeId = [Select Id From RecordType Where SobjectType = 'Product2' and Name = 'Products'].Id;
        String hotelRecordTypeId = [Select Id From RecordType Where SobjectType = 'Product2' and Name = 'Hotels'].Id;
 
        Product2 prodHotel = new Product2(Name='Test Prod1',Event__c=eventRec.Id, recordtypeId=hotelRecordTypeId, IsActive=true);
        insert prodHotel;
        
        Product2 prodProducts = new Product2(Name='Test Prod2',Event__c=eventRec.Id,recordtypeId=productRecordTypeId, IsActive=true);
        insert prodProducts ;        
        
        Package_Products__c packageProd = new Package_Products__c ();
        packageProd.Amount__c= 1000;
        packageProd.Package__c = prod.id;
        packageProd.Products_and_Hotels__c=prodProducts.id ;
        insert packageProd;
        update packageProd;
        
        Package_Products__c packageProd1 = new Package_Products__c ();
        packageProd1.Amount__c= 1000;
        packageProd1.Package__c = prod.id;
        packageProd1.Products_and_Hotels__c=prodHotel.id ;
        insert packageProd1;
        update packageProd1;
        
            
        
        Test.stopTest();
    }
    static testMethod void BeforeDelete() { 
        Test.startTest();  
        List<QE360_Event__c> eventLst = new List<QE360_Event__c>();
        for(Integer i=1;i<=200;i++){
            eventLst.add(new QE360_Event__c(Name='Test_Event'+i));
        }        
        insert eventLst[0];         
        
        List<Product2> prodLst = new List<Product2>(); 
        for(Integer i=1;i<=150;i++){
            prodLst.add(new Product2(Name='Test Prod'+i,Event__c=eventLst[0].Id));
        }       
        insert prodLst;
        
        delete prodLst;
        
        //delete eventLst;  

        Test.stopTest();
    }
        
}