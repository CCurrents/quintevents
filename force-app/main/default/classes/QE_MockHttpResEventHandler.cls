@isTest
global class QE_MockHttpResEventHandler implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
       // System.assertEquals('https://viptest.shoppingcartfulfillment.com/api/categories', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','image/jpeg');
        //res.setBody('{"example":"test"}');
        res.setBody('{"dstId":"577","dstFirstName":"fuel test2","dstEmailAddress":"bfueltest2@gmail.com","dstActive":1,"dstKey":"d53841487970ce9b91a2929cb8b82ac2"}');
        res.setStatusCode(200);
        return res;
    }
   
    
}