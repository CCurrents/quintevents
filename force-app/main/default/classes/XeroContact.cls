/**
* @File Name          : XeroContact.cls
* @Description        : Wrapper class to hold details for a Xero Contact
* @Author             : kchavda@addonblue.com

* @Last Modified By   : kchavda@addonblue.com
* @Last Modified On   : 03/30/2020
* @Modification Log   : 
* Ver       Date            Author               Modification
* 1.0       03/30/2020      kchavda              Initial Version
**/
public class XeroContact {

    public String ContactID {get; set;}
    public String ContactStatus {get; set;}
    public String Name {get; set;}
    public String FirstName {get; set;}
    public String LastName {get; set;}
    public String EmailAddress {get; set;}
    public String BankAccountDetails {get; set;}
    public String SkypeUserName {get; set;}
    public XeroAddress[] Addresses {get; set;}
    public XeroPhone[] Phones {get; set;}
    public String UpdatedDateUTC {get; set;}    
    public Boolean IsSupplier {get; set;}
    public Boolean IsCustomer {get; set;}
    public String DefaultCurrency {get; set;}     
    public Boolean HasAttachments {get; set;}   
    public Boolean HasValidationErrors {get; set;}
    public String xeroContactStatus{get;set;}
    public String xeroContactFailureReason{get;set;}
    public String xeroResponse{get;set;}
    public ValidationErrors[] ValidationErrors{get;set;}
    
    
    public class XeroAddress {    
        public String AddressType {get; set;}
        public String AddressLine1 {get; set;}
        public String AddressLine2 {get; set;}
        public String AddressLine3 {get; set;}
        public String AddressLine4 {get; set;}
        public String City {get; set;}
        public String Region {get; set;}
        public String PostalCode {get; set;}
        public String Country {get; set;}
        public String AttentionTo {get; set;}
    
    }
    public class XeroPhone {
        public String PhoneType {get; set;}
        public String PhoneNumber {get; set;}
        public String PhoneAreaCode {get; set;}
        public String PhoneCountryCode {get; set;}
    
    }
    
    public class ValidationErrors{
        public string Message{get;set;}
    }
}