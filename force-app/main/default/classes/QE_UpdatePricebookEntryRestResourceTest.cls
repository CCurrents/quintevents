@IsTest
private class QE_UpdatePricebookEntryRestResourceTest
{
    
    static testMethod void testPostMethod(){
    RestRequest request = new RestRequest();
    request.requestUri = '/runUpdatePricebookEntryRestBatch';
    request.httpMethod = 'POST';
    RestContext.request = request;
    String strId = QE_UpdatePricebookEntryRestResource.UpdatePricebookEntryMethod();
    }
   
}