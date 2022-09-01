/**
 * @File Name          : QE_XeroListener.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 6:38:53 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@RestResource(urlMapping='/webhooks/*')
global class QE_XeroListener {
     @HttpPost
    global static void doPost() {
        getInvoice (null); 
        //  // Retrieve the Xero signature from the headers
        // String xeroSignature = RestContext.request.headers.get('x-xero-signature');

        // // Retrieve the Xero payload body
        // String xeroPayload = RestContext.request.requestBody.toString();        
        // if(!Test.isRunningTest()){
        // // Verify the signature using 'hmacSHA256'. I have the Webhook key stored in a Custom Setting
        // Blob signedPayload = Crypto.generateMac('hmacSHA256', Blob.valueOf(xeroPayload), Blob.valueOf(Xero_Settings__c.getOrgDefaults().Webhook_Key__c));

        // // Once we have the signed payload, encode it using base64 to convert back to a string
        // String encodedPayload = EncodingUtil.base64Encode(signedPayload);

        // // Return status code based on whether signed payload matches or not
        // RestContext.response.statusCode = encodedPayload == xeroSignature ? 200 : 401;
        
        // RestResponse response = RestContext.response;
        // response.addHeader('Content-type','application/json');
        // System.debug(System.LoggingLevel.INFO, '\n**** '+RestContext.request.requestBody.toString());
        // }
        
        // System.debug('xeroPayload-->'+xeroPayload);
        // JSONParser parser = JSON.createParser(RestContext.request.requestBody.toString());
        // Set<String> xeroInvoiceId = new Set<String>();
        // while (parser.nextToken() != null) {
        //     if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
        //         xeroWebHookClass webHookobj = (xeroWebHookClass)parser.readValueAs(xeroWebHookClass.class);
        //         for(Events ewc :  webHookobj.events){
        //             String str = ewc.resourceUrl;
        //             String strStatus = '';
        //             if(!Test.isRunningTest()){
        //                 XeroInvoice inv = getInvoice(ewc.resourceId);                    
        //                 strStatus = (inv != null && inv.status != null? inv.status: '');
        //             }else{
        //                 strStatus = 'PAID';
        //             }
        //             if(str.contains('https://api.xero.com') && ewc.eventType == 'UPDATE' && strStatus == 'PAID'){
        //                 xeroInvoiceId.add(ewc.resourceId);                        
        //             }
                     
        //         }
        //         List<Opportunity_Payment_Terms__c> optList = [Select id,opportunity__c,Xero_Invoice_ID__c from Opportunity_Payment_Terms__c where Xero_Invoice_ID__c IN : xeroInvoiceId AND opportunity__r.GPE_Online_Order__c = false];
        //         List<Opportunity_Payment_Terms__c> optUpdateList = new List<Opportunity_Payment_Terms__c>();
        //         Set<Id> setOppIds = New Set<Id>();
        //         for(Opportunity_Payment_Terms__c opt : optList){
        //           setOppIds.add(opt.opportunity__c);  
        //           Opportunity_Payment_Terms__c optUpdateObj= new Opportunity_Payment_Terms__c();  
        //           optUpdateObj.Id = opt.Id;
        //           optUpdateObj.Status__c = 'Passed';
        //           optUpdateObj.Xero_Payment_Status__c = 'Success';
        //           optUpdateList.add(optUpdateObj);                  
        //         }
                
        //         if(setOppIds.size()>0){
        //             for(Id oppid: setOppIds){
        //                 System.enqueueJob(new QE_GPEEndPointQueueCallOut(oppid));
        //             }
        //         }
                
        //         if(!optUpdateList.isEmpty()){
        //             update optUpdateList;
        //         }
        //     }
        // }
    }
    
    
    
    public static XeroInvoice getInvoice (String invoiceId) {

        XeroInvoice xeroInvoice = new XeroInvoice();

        // Execute the callout to the Invoice resource        
        // if(!Test.isrunningtest()){
        //     HttpResponse  response = XeroCalloutUtility.executeCallout('GET', 'Invoices/' + invoiceId, null);       
        //     // If successful response
        //     if (response.getStatusCode() == 200 || Test.isrunningtest()) {
        //         // Use the parser to convert the response into Xero objects
        //         xeroInvoice = XeroCalloutResponseParser.parseInvoices(response.getBody())[0];
        //     }   
        //  }
     
        
        return xeroInvoice;
    }
    
    public class xeroWebHookClass{
        public List<Events> events;
        public Integer firstEventSequence;
        public Integer lastEventSequence;
        public String entropy;  
    }
    public class Events {
        public String resourceUrl;
        public String resourceId;
        public String eventDateUtc;
        public String eventType;
        public String eventCategory;
        public String tenantId;
        public String tenantType;
    }
}