/**
 * @File Name          : XeroListener.cls
 * @Description        : To handle invoice changes in xero
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 04/02/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/02/2020  kchavda@addonblue.com     Initial Version
 * 1.1    09/09/2020   kchavda@addonblue.com      #519 Xero Related Changes
**/
@RestResource(urlMapping='/xerowebhooks/*')
global class XeroListener {
     
    /**
    * @description To handle invoice changes in xero
    * @author kchavda@addonblue.com | 04/02/2020
    * @param  
    * @return void
    **/            
    @HttpPost
    global static void doPost() {
        try{
             // Retrieve the Xero signature from the headers
            String xeroSignature = RestContext.request.headers.get('x-xero-signature');
    
            // Retrieve the Xero payload body
            String xeroPayload = RestContext.request.requestBody.toString();      
            List<Xero_Configuration__c> xeroSettings = new List<Xero_Configuration__c>([select Id, Webhook_Key__c from Xero_Configuration__c where Active__c = true limit 1]);
      
            if(!Test.isRunningTest() && xeroSettings.size()>0){
                // Verify the signature using 'hmacSHA256'. I have the Webhook key stored in a Custom Setting
                Blob signedPayload = Crypto.generateMac('hmacSHA256', Blob.valueOf(xeroPayload), Blob.valueOf(xeroSettings[0].Webhook_Key__c));
        
                // Once we have the signed payload, encode it using base64 to convert back to a string
                String encodedPayload = EncodingUtil.base64Encode(signedPayload);
        
                // Return status code based on whether signed payload matches or not
                RestContext.response.statusCode = encodedPayload == xeroSignature ? 200 : 401;
                
                RestResponse response = RestContext.response;
                response.addHeader('Content-type','application/json');
                System.debug(System.LoggingLevel.INFO, '\n**** '+RestContext.request.requestBody.toString());
            }
            
            System.debug('xeroPayload-->'+xeroPayload);
            
            JSONParser parser = JSON.createParser(RestContext.request.requestBody.toString());
            map<String,Date> xeroInvoiceId = new map<String,Date>();
            map<String,String> xeroInvoicepayment = new map<String,String>();
            List<RequestResponse_Log__c> lstreqresLogs = new List<RequestResponse_Log__c>();
            XeroInvoice inv = new XeroInvoice();
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    xeroWebHookClass webHookobj = (xeroWebHookClass)parser.readValueAs(xeroWebHookClass.class);
                    for(Events ewc :  webHookobj.events){
                        String str = ewc.resourceUrl;
                        String strStatus = '';
                        Date paidonDate;   
                        String paymentId;                        
                        
                        inv = getInvoice(ewc.resourceId);        
                        strStatus = (inv != null && inv.status != null? inv.status: '');
                        String strPaidDate = (inv != null && inv.FullyPaidOnDate != null? inv.FullyPaidOnDate: '');
                        system.debug('###strPaidDate=='+strPaidDate);
                        if(Test.isRunningTest()){
                            strStatus = 'PAID';
                            paidonDate = system.today();
                            strPaidDate= '\\(1341828183000';
                            paymentId = 'bba46537-d195-47e9-bfd3-2a46554f03dd';
                        }
                        if(strPaidDate != null && strPaidDate != ''){
                            paidonDate = getpaidDate(strPaidDate);
                        }
                        if(!Test.isRunningTest()){
                            if(inv != null && inv.Payments != null && inv.Payments.size()>0){
                                for(integer i=0;i<inv.Payments.size();i++){
                                    system.debug('###inv.Payments[i].Date_x =='+inv.Payments[i].Date_x);
                                    system.debug('###inv.FullyPaidOnDate =='+inv.FullyPaidOnDate);
                                    system.debug('###inv.Payments[i].PaymentID =='+inv.Payments[i].PaymentID);
                                    if(inv.Payments[i].PaymentID != null && inv.Payments[i].Date_x == inv.FullyPaidOnDate){                                        
                                        paymentId = inv.Payments[i].PaymentID;
                                    }
                                }
                            }
                        }
                        
                        if(str.contains('https://api.xero.com') && ewc.eventType == 'UPDATE' && strStatus == 'PAID'){
                            xeroInvoiceId.put(ewc.resourceId,paidonDate); 
                            xeroInvoicepayment.put(ewc.resourceId,paymentId);                    
                        }                         
                    }                    
                }
            }
            
            List<Payment_Term__c> paymentTermsToUpdate = new List<Payment_Term__c>();
            List<Charge__c> chargeToInsert = new List<Charge__c>();
            //Set<Id> setOrderIds = New Set<Id>();
             Id PayTermRecordId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
            for(Payment_Term__c payterm: [Select id,order__c,Order__r.Xero_Invoice_ID__c,Amount__c,Order__r.AccountId from Payment_Term__c where Order__r.Xero_Invoice_ID__c IN : xeroInvoiceId.keyset() AND order__r.GPE_Online_Order__c = false and Xero_Payment_Id__c = null and RecordTypeId !=: PayTermRecordId]){ 
              if(xeroInvoicepayment.containskey(payterm.Order__r.Xero_Invoice_ID__c) && xeroInvoicepayment.get(payterm.Order__r.Xero_Invoice_ID__c) != null){  
                  //setOrderIds.add(payterm.order__c);  
                  Payment_Term__c objPayTerm= new Payment_Term__c();  
                  objPayTerm.Id = payterm.Id;
                  objPayTerm.Status__c = 'Passed';
                  objPayTerm.Charge_Date__c = xeroInvoiceId.get(payterm.Order__r.Xero_Invoice_ID__c);
                  objPayTerm.Xero_Payment_Id__c = xeroInvoicepayment.get(payterm.Order__r.Xero_Invoice_ID__c); 
                  objPayTerm.Xero_Response__c = 'Success';
                  paymentTermsToUpdate.add(objPayTerm);       
                  
                  
                  Charge__c objCharge= new Charge__c(); 
                  objCharge.account__c = payterm.Order__r.AccountId;
                  objCharge.Amount__c = payterm.Amount__c;
                  objCharge.Status__c = 'Succeed';
                  ObjCharge.recordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
                  objCharge.Payment_Terms__c = payterm.Id;
                  objCharge.Xero_Response__c = 'Success';
                  objCharge.Xero_Payment_Id__c = xeroInvoicepayment.get(payterm.Order__r.Xero_Invoice_ID__c); 
                  chargeToInsert.add(objCharge);    
                  
                  if(inv.InvoiceID == payterm.Order__r.Xero_Invoice_ID__c && inv.lstreqresLogs != null){
                      inv.lstreqresLogs.get(0).Payment_Terms__c  = payterm.id;
                      inv.lstreqresLogs.get(0).Order__c = payterm.order__c;
                      lstreqresLogs.addall(inv.lstreqresLogs);
                  }
              }                                 
            }
            
            if(lstreqresLogs.size() > 0){
                Utility.processRecords(lstreqresLogs, 'insert');
            }                    
            /*if(setOrderIds.size()>0){
                for(Id orderid: setOrderIds){
                    System.enqueueJob(new SendOrderToGPEQueueable(orderid));
                }
            }*/
            
            if(!paymentTermsToUpdate.isEmpty()){
                Utility.processRecords(paymentTermsToUpdate, 'update');
            }
            
            if(!chargeToInsert.isEmpty() && !Test.isrunningtest()){
                Utility.processRecords(chargeToInsert, 'insert');
            }
        }
        catch(exception ex){
            System.debug('Exception :'+ex.getlinenumber()+'--'+ex.getmessage());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
        
   
     /**
    * @description To get invoice from xero
    * @author kchavda@addonblue.com | 04/02/2020
    * @param  String
    * @return XeroInvoice
    **/     
    public static XeroInvoice getInvoice (String invoiceId) {
        
        XeroInvoice xeroInvoice = new XeroInvoice();
        String reqEndpoint = '';
        String responsebody = '';
        Integer responsecode;
        // Execute the callout to the Invoice resource        
        if(!Test.isrunningtest()){           
            HttpRequest request = XeroCalloutUtility.executeCallout('GET', 'Invoices/' + invoiceId,null);   
            HttpResponse response = new Http().send(request);   
            reqEndpoint = request.getEndpoint();
            responsebody = response.getBody();
            responsecode = response.getStatusCode();
            system.debug('###response.getBody()=='+response.getBody());             
        } else{
            reqEndpoint = 'https://api.xero.com/api.xro/2.0/Invoices/c82feac4-9495-4f1d-9108-b3943218901a';
            responsebody = '{"Id":"ab83d2b7-323f-4a4e-ba16-b4fa6729fa0c","Status":"OK","ProviderName":"QE360 QA APP","DateTimeUTC":"Date(1588946943032)","Invoices":[{"Type":"ACCREC","InvoiceID":"c82feac4-9495-4f1d-9108-b3943218901a","InvoiceNumber":"INV-0049","Reference":"","Payments":[{"PaymentID":"f661a4e5-3622-41d2-9874-af2f20d0782b","Date":"Date(1588896000000+0000)","Amount":130,"CurrencyRate":0.013233,"HasAccount":false,"HasValidationErrors":false}],"Prepayments":[],"Overpayments":[],"AmountDue":0,"AmountPaid":130,"SentToContact":true,"CurrencyRate":0.013233,"IsDiscounted":false,"HasAttachments":false,"HasErrors":false,"Attachments":[],"Contact":{"ContactID":"c40431cd-87dd-4d2c-921e-4d49b78e5f2e","ContactStatus":"ACTIVE","Name":"Demo Lead 1","FirstName":"Demo","LastName":"Lead 1","EmailAddress":"kchavda1@addonblue.com","BankAccountDetails":"","Addresses":[{"AddressType":"STREET","City":"","Region":"","PostalCode":"","Country":""},{"AddressType":"POBOX","AddressLine1":"Havanna Street","City":"Leesville","Region":"","PostalCode":"71446","Country":""}],"Phones":[{"PhoneType":"DEFAULT","PhoneNumber":"7412365890","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"DDI","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"FAX","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"MOBILE","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""}],"UpdatedDateUTC":"Date(1588940498057+0000)","ContactGroups":[],"IsSupplier":false,"IsCustomer":true,"DefaultCurrency":"USD","SalesTrackingCategories":[],"PurchasesTrackingCategories":[],"ContactPersons":[],"HasValidationErrors":false},"DateString":"2020-05-08T00:00:00","Date":"Date(1588896000000+0000)","DueDateString":"2020-05-08T00:00:00","DueDate":"Date(1588896000000+0000)","Status":"PAID","LineAmountTypes":"Exclusive","LineItems":[{"Description":"Test Product","UnitAmount":50,"TaxType":"OUTPUT","TaxAmount":0,"LineAmount":50,"AccountCode":"200","Tracking":[],"Quantity":1,"LineItemID":"310afad2-147b-4b88-8580-77c77a10459d","ValidationErrors":[]},{"Description":"Demo Package","UnitAmount":100,"TaxType":"OUTPUT","TaxAmount":0,"LineAmount":100,"AccountCode":"200","Tracking":[],"Quantity":1,"LineItemID":"ea783eb8-0226-4c9d-a33c-672107687f02","ValidationErrors":[]},{"Description":"Discount","UnitAmount":-20,"TaxType":"OUTPUT","TaxAmount":0,"LineAmount":-20,"AccountCode":"200","Tracking":[],"Quantity":1,"LineItemID":"2f78433a-3017-4dc0-a638-7b9e32f3fbc0","ValidationErrors":[]},{"Description":"Combined Service Fee","UnitAmount":0,"TaxAmount":0,"LineAmount":0,"Tracking":[],"Quantity":1,"LineItemID":"3e54fdc9-7ab0-4361-b04d-3581469ab3fe","ValidationErrors":[]}],"SubTotal":130,"TotalTax":0,"Total":130,"UpdatedDateUTC":"Date(1588946935177+0000)","CurrencyCode":"USD","FullyPaidOnDate":"Date(1588896000000+0000)"}]}';
            responsecode = 200;
        }  
        
        // If successful response
        if (responsecode == 200) {
            // Use the parser to convert the response into Xero objects
            xeroInvoice = XeroCalloutResponseParser.parseInvoices(responsebody)[0];
            Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responsebody);
            List<Object> lstObject = (List<Object>)jsonResponseMap.get('Invoices');   
            Map<String, Object> mapobj = (Map<String, Object>)lstObject[0];
            List<Object> lstpayObject = (List<Object>)mapobj.get('Payments');
            //.get('Payments')        
             for(integer i=0;i<lstpayObject.size();i++){
                 Map<String, Object> mapobjpay = (Map<String, Object>)lstpayObject[i]; 
                 xeroInvoice.Payments[i].Date_x = string.valueof(mapobjpay.get('Date'));
             }
        }
        xeroInvoice.lstreqresLogs = new List<RequestResponse_Log__c>();              
        xeroInvoice.lstreqresLogs.add(XeroCallout.reqResLog('XeroListener','getInvoice', reqEndpoint, '', responsebody,string.valueof(responsecode),null,null)); 
             
         return xeroInvoice;
    }
    
    
    
    
     /**
    * @description To get paid date of invoice from xero
    * @author kchavda@addonblue.com | 04/02/2020
    * @param  String
    * @return Date 
    **/   
    public static date getpaidDate(string strDate){  
        date paidonDate;        
        if(strDate != null){      
            string dstr = strDate.substring(1,strDate.length()-1);
            string secs = dstr.split('\\(')[1].split('\\+')[0]; 
            system.debug(secs);
            Datetime dt = Datetime.newInstance(Long.valueOf(secs));
            paidonDate = date.valueof(dt);
            system.debug('###'+paidonDate);
        }
        return paidonDate;        
    }
    
     /**
    * @description wrapper class for webhook
    * @author kchavda@addonblue.com | 04/02/2020
    * @param  
    * @return 
    **/   
    public class xeroWebHookClass{
        public List<Events> events;
        public Integer firstEventSequence;
        public Integer lastEventSequence;
        public String entropy;  
    }
        
   
    /**
    * @description wrapper class for webhook event
    * @author kchavda@addonblue.com | 04/02/2020
    * @param  
    * @return 
    **/   
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