/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 02-17-2022
 * @last modified by  : fsuraitawala@addonblue.com
**/
public class IntacctSendInvoiceEmailToCustomer {
    
    @AuraEnabled
    public static Map<String,String> getPaymentTerm(String invId) {
        System.debug('invId  for callVFpage *** '+ invId);
        Map<String,String> mapObj = new Map<String,String>();

        Payment_Term__c pt = [Select id, Intacct_Id__c, Payment_Due_Date__c, Amount__c, Balance_Due__c, Order__r.International_Stripe__c, Opportunity__c, Order__c, Customer_Email__c, CurrencyIsoCode from Payment_Term__c where id=: invId];
        String invoiceNo = pt.Intacct_Id__c;
        String subjectSufix = (pt.Order__r.International_Stripe__c == true) ? ' International, LLC' : ', LLC';
        Date dueDate = pt.Payment_Due_Date__c;
     	String dueDateString = dueDate.format();
        String currSymbol = getCurrencySymbol(pt.CurrencyIsoCode);
       	String amount = String.valueOf(pt.Balance_Due__c);
        String message = 'QuintEvents'+subjectSufix+'<BR /><BR />' 
            + invoiceNo+ '- Due: '+dueDateString+' (mm/dd/yyyy)'+'<BR />' 
            +'Amount Due: '+currSymbol+amount+'<BR /><BR />' 
            +'Dear Customer:'+'<BR />'
            +'Please see attached is your invoice. If you have any questions please don\'t hesitate to contact us.'+'<BR /><BR />'
            +'Thank you for your business.'+'<BR /><BR />'
            +'Sincerely,'+'<BR />'
            +'QuintEvents Accounting Team';
        
        mapObj.put('stripe', String.valueOf(pt.Order__r.International_Stripe__c));
        mapObj.put('crmail', pt.Customer_Email__c);
        if(pt.Intacct_Id__c != null) {
            mapObj.put('invoiceNo', pt.Intacct_Id__c + ' from QuintEvents'+ subjectSufix);
        } else {
            mapObj.put('invoiceNo', pt.Intacct_Id__c);
        }
        mapObj.put('InvOrder', pt.Order__c);
        mapObj.put('OptId', pt.Opportunity__c);
        mapObj.put('emailBody', message);
        return mapObj;
    }
    
    @AuraEnabled
    public static string processEmail(String email, String Subject, String Message, String cc, String invId) {
        List<String> toMails = new List<String>();
        List<String> ccTo = new List<String>();
        Attachment atm = new AttachMent();
        Blob b;
        String sMessage='';
        system.debug('ex message-->'+sMessage);
        Payment_Term__c ptm = new Payment_Term__c();
        pageReference pdf;
        
        try {
            ptm = [SELECT Id, Name, Intacct_Id__c, Order__c, International_Stripe__c, Invoice_Send__c, Invoice_Send_By__c FROM Payment_Term__c WHERE Id =:invId];
            pdf = page.IntacctSalesInvoice;
            pdf.getParameters().put('id',invId);
            pdf.setRedirect(true);
            b = pdf.getContent();
            b = pdf.getContentAsPDF();
            atm.body = b;
            atm.Name = 'Details of Sale Order';
            toMails = email.split(',');
            if(String.isNotBlank(cc))
                ccTo = cc.split(',');
            
            sendEmail(ptm, b, toMails, subject, Message, ccTo);  
            
            ptm.Invoice_Send__c = true;
            ptm.Invoice_Send_By__c = String.isBlank(ptm.Invoice_Send_By__c) ? UserInfo.getName() : ptm.Invoice_Send_By__c+', '+UserInfo.getName();
            Update ptm;

            sMessage='Success'; 
        }
        catch(Exception ex){
            sMessage=ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString();
            System.debug('Exception Message **'+ ex.getMessage());
            System.debug('Exception Line Number **'+ ex.getLineNumber());
        }
        return sMessage;
    }

    public static void sendEmail(Payment_Term__c ptm, Blob b, List<String> toMails, String Subject, String Message, List<String> ccTo){
        List<Messaging.SingleEmailMessage> listOfEmail = new list<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage emailOne = new Messaging.SingleEmailMessage();
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(ptm.Intacct_Id__c+'.pdf');
        efa.setBody(b);

        if(Label.Intacct_Accounts_Receivable != 'dummy'){
            emailOne.setOrgWideEmailAddressId(Label.Intacct_Accounts_Receivable);
        }
        
        emailOne.setSubject(subject);
        emailOne.setToAddresses(toMails);
        if(!ccTo.isEmpty())
            emailOne.setCcAddresses(ccTo);
        emailOne.setHtmlBody(Message); 
        emailOne.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailOne});  
    }

    private static String getCurrencySymbol(String currencyString){
        String currencySymbol = '$';
        if(currencyString == 'EUR'){
            currencySymbol = '€';
        }else if(currencyString == 'GBP'){
            currencySymbol = '£';
        }else{
           currencySymbol = '$';
        }
        return currencySymbol;
    }
}