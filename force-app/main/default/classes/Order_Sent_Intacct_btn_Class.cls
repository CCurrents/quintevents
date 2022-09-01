/**
 * @description       : 
 * @author            : fsuraitawala@addonblue.com
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : fsuraitawala@addonblue.com
**/
public class Order_Sent_Intacct_btn_Class {

public Id order_ID;
public boolean displayPopup {get;set;}
public String displayMsg {get;set;}
public Opportunity oppRec {get;set;}
public Order_Sent_Intacct_btn_Class(ApexPages.StandardController stdController)
{
//RedirectMethod();
}
   public pageReference closePopup() {
       displayPopup=false;
       pageReference ref=new pageReference('/'+order_ID);
       ref.setRedirect(true);
       return ref;
   }
   public pageReference RedirectMethod() {
       order_ID = ApexPages.currentPage().getParameters().get('Orderid');
       system.debug('order_ID'+order_ID);
        if(order_ID != null){
            DELETE [Select Id,Order__c from RequestResponse_Log__c where Order__c =:order_ID and API_URL__c = 'https://api.intacct.com/ia/xml/xmlgw.phtml' ];
            List<Order> lstOrders = [Select Id, TotalAmount, QuoteId, Intacct_id__c, OpportunityId, Status, ShiptoContactId, BillToContactId, 
                                     Opportunity.Pricebook2.GPE_Event__c, Opportunity.Pricebook2Id, Refund_Reconciliation__c, 
                                     BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode, 
                                     ShippingStreet, ShippingCity, ShippingCountry, ShippingState, ShippingPostalCode
                                     FROM Order WHERE Id = :order_ID];
            Map<Id,Quote> mapQuote = new Map<Id,Quote>([Select id,(Select Id from attachments) from Quote where id in (select quoteid from order where id in:lstOrders)]);
            system.debug('mapQuote: '+mapQuote);           
            Order objOrder = lstOrders[0];
            if(objOrder.Refund_Reconciliation__c == false) { 
                List<String> requiredFields = new List<String>();
                if(String.isBlank(objOrder.BillingStreet)) requiredFields.add('BillingStreet');
                if(String.isBlank(objOrder.BillingCity)) requiredFields.add('BillingCity');
                if(String.isBlank(objOrder.BillingCountry)) requiredFields.add('BillingCountry');
                if(String.isBlank(objOrder.BillingState)) requiredFields.add('BillingState');
                if(String.isBlank(objOrder.BillingPostalCode)) requiredFields.add('BillingPostalCode');
                if(String.isBlank(objOrder.ShippingStreet)) requiredFields.add('ShippingStreet');
                if(String.isBlank(objOrder.ShippingCity)) requiredFields.add('ShippingCity');
                if(String.isBlank(objOrder.ShippingCountry)) requiredFields.add('ShippingCountry');
                if(String.isBlank(objOrder.ShippingState)) requiredFields.add('ShippingState');
                if(String.isBlank(objOrder.ShippingPostalCode)) requiredFields.add('ShippingPostalCode');
                
                if(objOrder.Intacct_id__c != null) {
                    displayPopup = true;
                    displayMsg = 'The Sales Order already sent to Intacct';
                    return null;       
                } else if(objOrder.TotalAmount == 0) {
                    displayPopup=true;
                    displayMsg = system.label.IntacctOrderAmount;
                    return null; 
                } else if(requiredFields.size() > 0 && !test.isRunningTest()) {
                    displayPopup = true;
                    displayMsg = 'Please fill mandatory fields: <br/>'+ String.join( requiredFields, '<br/>' );
                    objOrder.Intacct_Failure_Reason__c = 'Please fill mandatory fields: '+ String.join( requiredFields, ', ' );
                    update objOrder;
                    return null;
                } else {
                    Id OrderID = order_ID;                       
                    if(mapQuote.containskey(objOrder.QuoteId) && !mapQuote.get(objOrder.QuoteId).attachments.isempty() && mapQuote.get(objOrder.QuoteId).attachments.size()>0){                        
                        system.debug('IntacctAttachmentBatch: ');
                        IntacctAttachmentBatch attbatch = new IntacctAttachmentBatch(OrderID,objOrder.QuoteId);
                        Database.executebatch(attbatch);
                        system.debug('@@Executed: attbatch: '+attbatch);
                    }
                    Set<String> lstContactsIds = new Set<String>();
                    if(objOrder.ShiptoContactId != null ){
                        lstContactsIds.add(objOrder.ShiptoContactId);
                    }
                    if(objOrder.BillToContactId != null){
                        lstContactsIds.add(objOrder.BillToContactId);
                    }
                    integer i = 0;
                    boolean flag = true;
                    List<Contact> lstContacts =  [Select Id,Intacct_Id__c from Contact where Id in :lstContactsIds and Intacct_Id__c = ''];
                    for(Contact objContact : lstContacts) {
                        i = i + 1;
                        if(String.isEmpty(objContact.Intacct_Id__c)) {
                            String contactId = objContact.Id;
                            flag = false;
                            if(lstContacts.size() != i) {
                                IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(OrderID,new list<String> {'CONTACT'},contactId,false);
                                Database.executebatch(batch);
                            } else {
                                IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(OrderID,new list<String> {'CONTACT'},contactId,true);
                                Database.executebatch(batch);
                            }
                        }
                    }
                    if(flag){
                        IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(OrderID);
                        Database.executebatch(batch);
                    }
                }
            }
            pageReference ref=new pageReference('/'+order_ID);
            ref.setRedirect(true);
            return ref;
        } else {
            pageReference ref=new pageReference('/'+order_ID);
            ref.setRedirect(true);
            return ref;
        }
   }
}