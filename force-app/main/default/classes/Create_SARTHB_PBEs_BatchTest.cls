@isTest
public class Create_SARTHB_PBEs_BatchTest {
@TestSetup
    static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }


    static testMethod void testMethods2()
    { 
    
    //******* Pricebook *******//
        Pricebook2 testPricebook = TestDataFactory.createPricebook();
        List<Pricebook2> StdPricebook = TestDataFactory.createPricebook(1,'Standard Price Book');
        //******* Parent Package *******//
        List<Parent_Package__c> lstParentPackage = TestDataFactory.createParentPackage(1, true, testPricebook.Id);
        
        //******* Product *******//
        List<Product2> lstProduct = new List<Product2>();
        Product2 objProduct = TestDataFactory.createProduct('Test Package Product', 'Package', 'Package', lstParentPackage[0].Id, testPricebook.Id);
        lstProduct.add(objProduct);
        
        Product2 objProduct1 = TestDataFactory.createProduct('Test Product', 'Product', 'Transportation', null, testPricebook.Id);
        lstProduct.add(objProduct1);
        
        Product2 objProduct2 = TestDataFactory.createProduct('Test Hotel', 'Hotel', 'Hospitality', null, testPricebook.Id);
        lstProduct.add(objProduct2);
        
        Product2 objProduct3 = TestDataFactory.createProduct('Test Hotel Stay', 'Hotel Stay', 'Stay', null, testPricebook.Id);
        lstProduct.add(objProduct3);
        
        lstProduct = Utility.processRecords(lstProduct, 'insert');
        
		List<PricebookEntry> ProductStdPBE = [Select Id from PricebookEntry where Product2Id = :lstProduct[0].Id and CurrencyIsoCode = 'SAR' and Pricebook2Id = :testPricebook.Id and IsActive = true];
        List<PricebookEntry> ProductPrimPBE = [Select Id from PricebookEntry where Product2Id = :lstProduct[0].Id and CurrencyIsoCode = 'SAR' and Pricebook2Id = :testPricebook.Id and IsActive = true];
        
        delete ProductStdPBE;
        delete ProductPrimPBE;
        
    List<Id> PBIds = new List<Id>();
    PBIds.add(testPricebook.Id);
    Test.startTest();
        
    Create_SARTHB_PBEs_Batch batchJob = new Create_SARTHB_PBEs_Batch(PBIds);
    ID batchprocessid = Database.executeBatch(batchJob,200);         
    Test.StopTest();
	}
    
}