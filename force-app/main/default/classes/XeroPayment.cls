/**
* @File Name          : XeroPayment.cls
* @Description        : Wrapper class to hold details for a Xero Payment
* @Author             : kchavda@addonblue.com

* @Last Modified By   : kchavda@addonblue.com
* @Last Modified On   : 03/30/2020
* @Modification Log   : 
* Ver       Date            Author               Modification
* 1.0       03/30/2020      kchavda              Initial Version
**/
public class XeroPayment{

    public String PaymentID{get; set;}
    public Date Dates{get; set;}
    public Decimal BankAmount {get; set;}
    public Decimal Amount{get; set;}
    public String Reference{get; set;}
    public Decimal CurrencyRate{get; set;}
    public String PaymentType{get; set;}
    public String Status{get; set;}
    public xeroAccount[] Accounts{get; set;}
    public XeroInvoice[] Invoices{get; set;}
    public String UpdatedDateUTC{get; set;}
    public Boolean HasAccount{get; set;}
    public Boolean IsCustomer {get; set;}
    public xeroContact[] Contacts{get;set;}
    public String xeroPaymentStatus{get; set;}
    public String xeroPaymentFailureReason{get; set;}
    public String xeroResponse{get;set;}
    public ValidationErrors[] ValidationErrors{get;set;}
    public RequestResponse_Log__c[] lstreqresLogs{get; set;}
    public Integer ErrorNumber{get; set;} //10
    public String Type{get; set;} //ValidationException
    public String Message{get; set;}  //A validation exception occurred
    public cls_Elements[] Elements{get; set;}
    public String Id{get; set;}  //714e6ace-7e6f-4e67-872e-2b150398d52c   
    public String ProviderName{get; set;} //QE360 Cleanup App
    public String DateTimeUTC{get; set;}  ///Date(1588247665575)/
    public cls_Payments[] Payments;
    
    public class cls_Payments {
        public String PaymentID;    //f24bfe62-6268-4f3d-a113-7826d52aac60        
        public Double BankAmount;   //14171.11
        public Double Amount;   //188.83
        public Double CurrencyRate; //0.013325
        public String PaymentType;  //ACCRECPAYMENT
        public String Status;   //AUTHORISED
        public String UpdatedDateUTC;   ///Date(1588249895667+0000)/
        public boolean HasAccount;
        public boolean IsReconciled;
        public xeroAccount Account;
        public XeroInvoice Invoice;
        public boolean HasValidationErrors;
    }
    
    public class cls_Elements {        
        public Double Amount{get; set;}   //239.5
        public boolean HasAccount{get; set;}        
        public XeroInvoice Invoice{get; set;}
        public boolean HasValidationErrors{get; set;}
        public ValidationErrors[] ValidationErrors{get; set;}
    }  
     
    public class xeroAccount{

        public String AccountID{get; set;}
        public String Code{get; set;}
    }

    public class xeroContact{

        public String ContactID{get; set;}
        public String Name{get; set;}
    }

    public class XeroInvoice{

        public String Type{get; set;}
        public String InvoiceID{get; set;}
        public String InvoiceNumber{get; set;}
        public xeroContact Contact{get; set;}
        public Integer ContentLength {get; set;}
        public boolean HasErrors{get; set;}
        public cls_LineItems[] LineItems{get; set;}
    }
    
    public class ValidationErrors{
        public string Message{get;set;}
    }
    
    public class cls_LineItems {        
        public ValidationErrors[] ValidationErrors{get; set;}
    } 
   
   
    
}