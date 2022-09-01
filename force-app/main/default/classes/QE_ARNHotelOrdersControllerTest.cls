@isTest
private class QE_ARNHotelOrdersControllerTest {
    
    
    @isTest static void testMethodOne() {
        Test.startTest();
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);        
        Update standardPricebook;
        
        QE_ARNHotelOrdersController.create();        
        Test.stopTest();
    }
    
    
}