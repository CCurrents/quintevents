/**
 * @File Name          : XeroSFCalloutBatch.cls
 * @Description        : To send order to xero from trigger
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 04/03/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    04/03/2020   kchavda@addonblue.com      Initial Version
 * 1.1    09/07/2020   kchavda@addonblue.com      #519 Xero Related Changes
**/
public class XeroSFCalloutBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{ 

    set<Id> setorderId;
    string str;
    Order objOrder = new Order();
    string type;
    string ContactId;
    
    /**
    * @description Constructor
    * @author kchavda@addonblue.com | 04/03/2020
    * @param  set<Id>
    * @return
    **/        
    public XeroSFCalloutBatch(set<Id> setorderId){
        this.setorderId = setorderId;
        this.type = 'Contact';
    }
    
    /**
    * @description Constructor
    * @author kchavda@addonblue.com | 04/03/2020
    * @param  string,set<Id>,String 
    * @return
    **/  
    public XeroSFCalloutBatch(string type,set<Id> setorderId, String ContactID){
        this.type = type;
        this.ContactId = ContactId;
        this.setorderId = setorderId;
    }
    
     /**
    * @description Start method
    * @author kchavda@addonblue.com | 04/03/2020
    * @param  Database.BatchableContext
    * @return Database.QueryLocator
    **/  
    public Database.QueryLocator start(Database.BatchableContext BC){
        string  query = 'Select Id,OpportunityId,CurrencyIsoCode,Xero_Invoice_ID__c,BillToContactId,BillToContact.Name,BillToContact.FirstName,BillToContact.LastName,BillToContact.Phone,BillToContact.Email,BillingCity,BillingState,Status, BillingCountry,BillingPostalCode,BillingStreet,'+
                                     'BillToContact.Xero_Contact_Id__c,Pricebook2Id,Pricebook2.GPE_Event__c,Xero_Reference_No__c,Pricebook2.Xero_Item_Id__c,Pricebook2.Apply_20_VAT_Tax__c,Pricebook2.Xero_Event_Name__c,GPE_Online_Order__c,Pricebook2.Xero_Account_Code__c,'+ 
                                     '(Select Id,RecordTypeId,RecordType.Name,Xero_Payment_Id__c,Order__r.Xero_Invoice_ID__c,Order__r.PriceBook2.Xero_Account_Code__c,order__r.Pricebook2.Apply_20_VAT_Tax__c,Order__c, Xero_Invoice_ID__c,Status__c,CreatedDate,Payment_Due_Date__c,Amount__c,Order__r.BillToContact.Xero_Contact_ID__c,Order__r.CurrencyIsoCode,order__r.AccountId,order__r.GPE_Online_Order__c from Payment_Terms__r),'+
                                     '(Select Id,Quantity,Description,UnitPrice,Product2.Name from OrderItems) From Order where Id in: setorderId';
        
        return Database.getQueryLocator(query);
    }
    
    /**
    * @description Execute method
    * @author kchavda@addonblue.com | 04/03/2020
    * @param  Database.BatchableContext, List<sObject>
    * @return void
    **/  
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            System.debug('type--'+type);
            objOrder = ((List<Order>) scope)[0];
            if(type == 'Contact' && objOrder.BillToContact.Xero_Contact_Id__c == null){
                str = XeroCallout.createContactJson(objOrder);
            }
            else if(type == 'Invoice' || (objOrder.BillToContact.Xero_Contact_Id__c != null && objOrder.Xero_Invoice_Id__c == null)) {                 
                if(objOrder.BillToContact.Xero_Contact_Id__c != null){
                    ContactID = objOrder.BillToContact.Xero_Contact_Id__c;
                    type = 'Invoice';
                }
                str =  XeroCallout.createInvoiceJSON(objOrder, ContactID);                   
                
            }else if(objOrder.BillToContact.Xero_Contact_Id__c != null && objOrder.Xero_Invoice_Id__c != null){
                type = 'Invoice';
            }
            
        }
        catch(exception ex){
            System.debug('Exception :'+ex.getlinenumber()+'--'+ex.getmessage());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
       
    }
    
    /**
    * @description Finish method
    * @author kchavda@addonblue.com | 04/03/2020
    * @param  Database.BatchableContext
    * @return void
    **/  
    public void finish(Database.BatchableContext BC){
        try{
            if(type == 'Contact') {
                XeroContact xeroContact = new xeroContact();
                if(!Test.isRunningTest()){
                    xeroContact = XeroCallout.createContact(str,objOrder); 
                }else{
                    xeroContact.ContactId = '234566ryhfjg';
                    xeroContact.xeroResponse = 'success';
                } 
                     
                if(xeroContact!= null)  {          
                    Contact contact = new Contact();
                    contact.Id = objOrder.BillToContactId;
                    contact.Xero_Contact_ID__c = xeroContact.contactID;   
                    contact.Xero_Response__c = xeroContact.xeroResponse;
                    objOrder.Xero_Response__c = xeroContact.xeroResponse; 
                    if(xeroContact.contactID != null){       
                        XeroSFCalloutBatch batch = new XeroSFCalloutBatch('Invoice',new set<Id>{objOrder.Id}, xeroContact.contactID); 
                        Database.executeBatch(batch,1); 
                    }
                    if(objOrder.Id != null && xeroContact.contactID == null){
                         Utility.processRecords(objOrder, 'update'); 
                    }
                    if(contact.Id != null){
                        Utility.processRecords(contact, 'update');
                    }
                }
                    
            }  
            if(type == 'Invoice'){
                
                List<RequestResponse_Log__c> lstreqresLogs = new List<RequestResponse_Log__c>();
                List<Payment_Term__c> PaymentTermList = objOrder.Payment_Terms__r;
                List<OrderItem> orderLineItems = objOrder.orderItems;
                List<Payment_Term__c> PaymentTermListToUpdate = new List<Payment_Term__c>();
                
                List<XeroInvoice> xeroInvoiceList = new List<XeroInvoice>();
                if(!Test.isRunningTest()){
                    if(objOrder.Xero_Invoice_Id__c == null){
                        xeroInvoiceList = XeroCallout.createInvoice(str,objOrder.Id);
                    }
                }else{
                    XeroInvoice xInvoice = new XeroInvoice();
                    xInvoice.InvoiceID = '356fhg';
                    xInvoice.xeroResponse = 'success';
                    xInvoice.lstreqresLogs = new List<RequestResponse_Log__c>();
                    xInvoice.lstreqresLogs.add(new RequestResponse_Log__c());
                    xeroInvoiceList.add(xInvoice);  
                    PaymentTermList = new List<Payment_Term__c>();
                    Payment_Term__c pt = new Payment_Term__c();
                    PaymentTermList.add(pt);
                                      
                }
                
                Id PayTermRecordId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
                List<Payment_Term__c> lstPT = new List<Payment_Term__c>();  
                if(!Test.isrunningTest()) lstPT = [Select id,order__r.GPE_Online_Order__c,RecordType.Name,Xero_Payment_Id__c,Order__r.Xero_Invoice_ID__c,Order__r.PriceBook2.Xero_Account_Code__c,order__r.Pricebook2.Apply_20_VAT_Tax__c,Order__c, Xero_Invoice_ID__c,Status__c,CreatedDate,Payment_Due_Date__c,Amount__c,Order__r.BillToContact.Xero_Contact_ID__c,Order__r.CurrencyIsoCode,order__r.AccountId from Payment_Term__c where Order__c =: objOrder.Id and RecordTypeId =:PayTermRecordId limit 1];             
                else lstPT = [Select id,order__r.GPE_Online_Order__c,RecordType.Name,Xero_Payment_Id__c,Order__r.Xero_Invoice_ID__c,Order__r.PriceBook2.Xero_Account_Code__c,order__r.Pricebook2.Apply_20_VAT_Tax__c,Order__c, Xero_Invoice_ID__c,Status__c,CreatedDate,Payment_Due_Date__c,Amount__c,Order__r.BillToContact.Xero_Contact_ID__c,Order__r.CurrencyIsoCode,order__r.AccountId from Payment_Term__c limit 1];
                list<charge__c> lstCharges= new list<charge__c>();               
                if(!xeroInvoiceList.isEmpty() || objOrder.Xero_Invoice_Id__c != null){
                    for(integer i=0; i<(!xeroInvoiceList.isEmpty()?xeroInvoiceList.size():1); i++){
                        if(!xeroInvoiceList.isEmpty() && xeroInvoiceList[i].lstreqresLogs != null){
                            lstreqresLogs.addall(xeroInvoiceList[i].lstreqresLogs);
                        }                        
                      
                        if(!xeroInvoiceList.isEmpty()) objOrder.Xero_Invoice_ID__c = xeroInvoiceList[i].InvoiceID;    
                        //PaymentTermList[i].Xero_Response__c = xeroInvoiceList[i].xeroResponse;                 
                        if(!xeroInvoiceList.isEmpty()) objOrder.Xero_Response__c = xeroInvoiceList[i].xeroResponse;                    
                        if(objOrder.Xero_Invoice_ID__c != null){                             
                            if(objOrder.GPE_Online_Order__c == false){
                                XeroCallout.EmailInvoice(objOrder.Xero_Invoice_ID__c);
                                if(!lstPT.isempty()){ 
                                    XeroCallout.wrpPayments objpay = new XeroCallout.wrpPayments();  
                                    objpay = XeroCallout.createPaymentJSON(lstPT[0],objOrder.Xero_Invoice_ID__c); 
                                    if(objpay.PaymentTerm != null && objpay.PaymentTerm.Xero_Response__c != null) PaymentTermListToUpdate.add(objpay.PaymentTerm);
                                    if(objpay.odr.Xero_Response__c != null)  objOrder.Xero_Response__c = objpay.odr.Xero_Response__c; 
                                    if(objpay.lstreqresLogs != null &&  objpay.lstreqresLogs.size()>0) lstreqresLogs.addall(objpay.lstreqresLogs);                            
                                }                             
                            }
                            else if(objOrder.GPE_Online_Order__c == true){
                                for(Payment_Term__c pterm: PaymentTermList){
                                    XeroCallout.wrpPayments objpay = new XeroCallout.wrpPayments(); 
                                    objpay = XeroCallout.createPaymentJSON(pterm,objOrder.Xero_Invoice_ID__c);
                                    if(objpay.PaymentTerm != null && objpay.PaymentTerm.Xero_Response__c != null) PaymentTermListToUpdate.add(objpay.PaymentTerm);
                                    if(objpay.odr.Xero_Response__c != null)  objOrder.Xero_Response__c = objpay.odr.Xero_Response__c;  
                                    if(objpay.lstreqresLogs != null &&  objpay.lstreqresLogs.size()>0) lstreqresLogs.addall(objpay.lstreqresLogs); 
                                    //if(pterm.RecordTypeId != PayTermRecordId){
                                        //objpay.objCharge.CurrencyIsoCode = objOrder.CurrencyIsoCode;
                                        if(objpay.objCharge.Xero_Payment_Id__c != null){
                                            lstCharges.add(objpay.objCharge);
                                        }
                                    //}
                                }
                            }
                        }
                    }
                }
                if(!lstreqresLogs.isempty()){
                     Utility.processRecords(lstreqresLogs, 'insert');                    
                }                
                if(objOrder.Id != null){                    
                     Utility.processRecords(objOrder, 'update'); 
                }                               
                if(PaymentTermListToUpdate.size()>0){
                    Utility.processRecords(PaymentTermListToUpdate, 'update');
                }
                if(lstCharges.size()>0){
                    Utility.processRecords(lstCharges, 'update');
                }
            }            
           
        }
        catch(exception ex){
            System.debug('Exception :'+ex.getlinenumber()+'--'+ex.getmessage());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
}