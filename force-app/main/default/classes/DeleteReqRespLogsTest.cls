/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 10-20-2021
 * @last modified by  : ratiksinghal@addonblue.com
**/
@isTest public class DeleteReqRespLogsTest {
    
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }

    @isTest static void testOne(){
        Test.startTest();
        
        PriceBook2 pbook = TestDataFactory.createPricebook(1,'Test PB '+ Utility.getRandomNumber().SubString(0,8))[0];
        
        RequestResponse_Log__c requestObj = new RequestResponse_Log__c();
		requestObj.Class_Name__c = 'ProductUpdateBatchClass';
        requestObj.Status_Code__c =  String.valueOf('200');
        requestObj.Response__c = '[{\"id\":116441,\"title\":\"W Hotel Hospitality Suite\",\"order\":{\"from\":\"2019-12-20\",\"to\":\"2021-12-10\",\"min\":1,\"max\":16},\"price\":{\"net\":3050,\"gross\":3416.0000000000005,\"tax\":0,\"currency\":\"EUR\"},\"isdelivery\":false,\"infotext\":\"Further information will be given in the corresponding PDF.\",\"group\":\"VIP Tickets\"},{\"id\":114054,\"title\":\"Main Grandstand (WE) - GPE\",\"order\":{\"from\":\"2021-06-21\",\"to\":\"2021-12-10\",\"min\":1,\"max\":0},\"price\":{\"net\":550,\"gross\":616.0000000000001,\"tax\":0,\"currency\":\"EUR\"},\"isdelivery\":false,\"infotext\":\"Covered grandstand \u2013 Numbered seat \u2013 Giant screen view\r\n\r\nLocated opposite the team garages with a great view of the entire start-finish straight, .\",\"group\":\"GPE\"}]';
        requestObj.Message_Type__c = 'Success';   
        requestObj.Price_Book_Event__c = pbook.ID;
        insert requestObj;
        
        DeleteReqRespLogs batch1 = new DeleteReqRespLogs();
        ID batchprocessid1 = Database.executeBatch(batch1);
        
        DeleteReqRespLogs batch2 = new DeleteReqRespLogs(0);
        ID batchprocessid2 = Database.executeBatch(batch2);

        DeleteReqRespLogs batch3 = new DeleteReqRespLogs(0, 'ProductUpdateBatchClass');
        ID batchprocessid3 = Database.executeBatch(batch3);
        Test.stopTest();
    }

   
}