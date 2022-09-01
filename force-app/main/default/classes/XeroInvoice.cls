/**
* @File Name          : XeroInvoice.cls
* @Description        : Wrapper class to hold details for a Xero Invoice
* @Author             : kchavda@addonblue.com

* @Last Modified By   : kchavda@addonblue.com
* @Last Modified On   : 03/30/2020
* @Modification Log   : 
* Ver       Date            Author               Modification
* 1.0       03/30/2020      kchavda              Initial Version
* 1.1       09/08/2020   kchavda@addonblue.com      #519 Xero Related Changes
**/
public class XeroInvoice {

    public String Type {get; set;}  //ACCREC
    public String InvoiceID {get; set;} //920cce71-7495-4c93-a2d3-e4cf9b91a781
    public String InvoiceNumber {get; set;} //INV-0002
    public String Reference {get; set;}
    public Payment[] Payments {get; set;}   
    public Decimal AmountDue {get; set;}    //600
    public Decimal AmountPaid {get; set;}   //0
    public Boolean SentToContact {get; set;}
    public Decimal CurrencyRate {get; set;} //1
    public Boolean HasErrors {get; set;}
    public Boolean IsDiscounted {get; set;}
    public XeroContact Contact {get; set;}
    public String Date_x {get; set;}    //2015-12-01T00:00:00
    public String DueDate {get; set;}   //2015-12-31T00:00:00
    public String FullyPaidOnDate {get; set;}
    public String Status {get; set;}    //DRAFT
    public String LineAmountTypes {get; set;}   //Exclusive
    public LineItem[] LineItems {get; set;}
    public Decimal SubTotal {get; set;} //600
    public Decimal TotalTax {get; set;} //0
    public Decimal Total {get; set;}    //600
    public String UpdatedDateUTC {get; set;}    ///Date(1447665863507+1300)/
    public String CurrencyCode {get; set;}  //NZD    
    public String xeroInvoiceStatus{get;set;}
    public String xeroInvoiceFailureReason{get;set;}
    public String xeroResponse{get;set;}    
    public RequestResponse_Log__c[] lstreqresLogs{get; set;}
    public Integer ErrorNumber; //10    
    public String Message;  //A validation exception occurred
    public cls_Elements[] Elements;
    
    public class cls_Elements {        
        public ValidationErrors[] ValidationErrors;        
        public XeroContact Contact;        
        public LineItem[] LineItems;
    }
      
    public class Payment {
        public string PaymentID{get; set;}
        public string Date_x{get; set;}
    }
    
    public class LineItem {
        public String ItemCode {get; set;}
        public String Description {get; set;}   //Consulting services as agreed
        public Decimal UnitAmount {get; set;}   //120
        public String TaxType {get; set;}   //NONE
        public Decimal TaxAmount {get; set;}    //0
        public Decimal LineAmount {get; set;}   //600
        public String AccountCode {get; set;}   //200
        public cls_Tracking[] Tracking {get; set;}
        public Decimal Quantity {get; set;} //5
        public String LineItemID {get; set;}    //0d129d0d-4b3a-4567-afc5-0453f3457175
        public ValidationErrors[] ValidationErrors{get; set;}
    }
    public class cls_Tracking {
        public ValidationErrors[] ValidationErrors{get; set;}
    }
    public class ValidationErrors{
        public string Message{get;set;}
    }
  
}