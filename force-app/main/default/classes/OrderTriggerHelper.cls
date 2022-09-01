/**
* @File Name          : OrderTriggerHelper.cls
* @Description        : 
* @Author             : jagrawal@addonblue.com
* @Group              : 
* @Last Modified By   : ratiksinghal@addonblue.com
* @Last Modified On   : 06-27-2022
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    6/3/2020   jagrawal@addonblue.com     Initial Version
* 1.1    18/3/2020  mpatel@addonblue.com       adding reference of the BrandFuel class
* 1.2    7/3/2020   jagrawal@addonblue.com     Removed redundant code and added logice to add the Inventory for Canceled Orders
* 1.3    7/31/2020  jagrawal@addonblue.com     #370 Added and commented code for Brandfuel Integration Refactoring
* 1.4    8/10/2020  fsuraitawala@addonblue.com #470 New Status on Order - Defaulted
* 1.5    8/28/2020  jagrawal@addonblue.com     #476 Added logic to consider GPE Orders as well for Exchange Rate Date
* 1.6    10/06/2020  kchavda@addonblue.com     #575 Create Order in GPT when Order Payment Term is Fully Paid
* 1.7   12/06/2020  fsuraitawala@addonblue.com #563 Allow Sales User to Edit Activated Orders
* 1.8   12/23/2020 jagrawal@addonblue.com     #685 Reduced unnecessary SOQL
* 1.9   12/28/2020   kchavda@addonblue.com      #627 Get the exchange rate date from the JSON for Online Orders
* 1.10  02/18/2021  vshah@addonblue.com         #745 Remove email notifications for Insufficient Memento Gift Codes.
* 2.0   04/08/2021   kchavda@addonblue.com    #892 "First Time Buyer" checkbox on Order and Payment Term
* 2.1   04/22/2021  cshah@addonblue.com      #922 Change Order - Copy certain field values from active order 
**/
public with sharing class OrderTriggerHelper {
    
    private Map<Id, Order> newOrderMap; 
    private Map<Id, Order> oldOrderMap;
    private List<Order> newOrderList;
    private List<Order> oldOrderList;
    
    /**
    * @description Constructor
    * @author jagrawal@addonblue.com | 6/3/2020 
    * @return void 
    **/
    public OrderTriggerHelper() {
        Utility.getSOQLCount();
        this.newOrderMap = (Map<Id, Order>) Trigger.newMap;
        this.oldOrderMap = (Map<Id, Order>) Trigger.oldMap;
        this.newOrderList = (List<Order>) Trigger.new;
        this.oldOrderList = (List<Order>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Before Insert!');
                processOrdersOnInsert(newOrderList);
            }
            
            when BEFORE_UPDATE {
                //#1039 - Comment order validation code -- START
                /*//#563 Allow Sales User to update Comment and Shipping address fields on Activated Orders -- START
                String profileName = [Select Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
                
                //Retrive Profile name from custom metadata 
                Set<String> setProfileName = new Set<String>();
                
                for(Profile_Setting__mdt objProfileSetting: [Select Id, Label FROM Profile_Setting__mdt]){
                    setProfileName.add(objProfileSetting.Label);
                }
                
                //#861 Create new profile named 'Sales Team Lead'
                if(setProfileName.contains(profileName)){
                    validateOrder(newOrderList, oldOrderMap, profileName);
                }
                //#563 Allow Sales User to update Comment and Shipping address fields on Activated Orders -- End*/
                //#1039 - Comment order validation code -- END
                
                Set<Id> lstOppIds = new set<Id>();
                Set<Id> setQuoteId = new Set<Id>();
                Set<String> currencyISOset = new Set<String>();
                Set<Date> exchangeRateDateset = new Set<Date>();
                Set<Id> ordersForShippingAddressError = new Set<Id>();
                
                Map<Id, Date> mapOfQuoteIdVsDate = new Map<Id, Date>();
                List<Order> lstOrders = [Select Id, Status, Order_Payment_Status__c,Exchange_Rate_Date_Editable__c,CurrencyIsoCode, BillToContactId, BillToContact.Name, BillToContact.Email, Email__c, Opportunity.Ship_To_Name__c, Opportunity.Email__c, 
                                         Opportunity.Paid_in_Full__c, Opportunity.Pricebook2.Name, Opportunity.Pricebook2.End_Date__c, Opportunity.Pricebook2.Brandfuel_End_Date__c,
                                         Opportunity.Pricebook2.Brandfuel_Category_Id__c,QuoteId, Withhold_Percentage__c, AccountId, totalAmount, Quote.Createddate, Quote.Online_Order__c,Quote.GPE_Online_Order__c,
                                         ShippingAddress, Pick_Up_Requested__c, Opportunity.Pricebook2.Order_Notifications_Start_Date__c, Opportunity.Pricebook2.Dont_Allow_Order_Changes_After__c, Comment__c, //VKHOPADE - issue 1219
                                         (SELECT Id,OrderId,Product2Id,OrderItemNumber,Quantity,Description,UnitPrice,Product2.Name,Product2.Type__c,Product2.Brandfuel_Points__c,ProductType__c FROM OrderItems) 
                                         from Order where Id IN :newOrderMap.keyset()];
                for(Order ord: lstOrders) {
                    lstOppIds.add(ord.OpportunityId);
                    setQuoteId.add(ord.QuoteId);
                    system.debug('###ord=='+ord);
                    system.debug('###oldOrderMap=='+oldOrderMap.get(ord.Id).status);                    
                    if(!String.isblank(ord.CurrencyIsoCode) || Test.isrunningTest()) {
                        if(ord.CurrencyIsoCode != 'USD'){ currencyISOset.add(ord.CurrencyIsoCode); }
                        // #476 Added logic to consider GPE Orders as well for Exchange Rate Date
                        if(ord.CurrencyIsoCode != 'USD' && (ord.Quote.Online_Order__c == true || ord.Quote.GPE_Online_Order__c)){ exchangeRateDateset.add(ord.Quote.Createddate.date()); mapOfQuoteIdVsDate.put(ord.QuoteId, ord.Quote.Createddate.date()); }
                    }
                    
                    //VKHOPADE - issue 1219 & 1236- start
                    //system.debug('*** old ShippingStreet = ' + oldOrderMap.get(ord.Id).ShippingStreet + ' *** new ShippingStreet = ' + newOrderMap.get(ord.Id).ShippingStreet);
                    if(newOrderMap.get(ord.Id).ShippingStreet != oldOrderMap.get(ord.Id).ShippingStreet || newOrderMap.get(ord.Id).ShippingCity != oldOrderMap.get(ord.Id).ShippingCity ||
                       newOrderMap.get(ord.Id).ShippingState != oldOrderMap.get(ord.Id).ShippingState || newOrderMap.get(ord.Id).ShippingPostalCode != oldOrderMap.get(ord.Id).ShippingPostalCode ||
                       newOrderMap.get(ord.Id).Pick_Up_Requested__c != oldOrderMap.get(ord.Id).Pick_Up_Requested__c || newOrderMap.get(ord.Id).Primary_Attendee_Contact__c != oldOrderMap.get(ord.Id).Primary_Attendee_Contact__c){
                        Date todayDate = system.today();
                       // system.debug('*** inside if,  todayDate = ' + todayDate + ' Dont_Allow_Order_Changes_After__c = ' + ord.Opportunity.Pricebook2.Dont_Allow_Order_Changes_After__c);
                        
                        if(todayDate > ord.Opportunity.Pricebook2.Dont_Allow_Order_Changes_After__c){
                            ordersForShippingAddressError.add(ord.Id);
                        }
                        //1236
                        if(todayDate > ord.Opportunity.Pricebook2.Order_Notifications_Start_Date__c){
                            newOrderMap.get(ord.Id).Order_Modified_After_Notification_date__c = true;
                        }
                    } //VKHOPADE - issue 1219 - end
                }
                
                for(Order objOrder : newOrderList){
                    if(ordersForShippingAddressError.contains(objOrder.Id)){
                        objOrder.adderror('Cannot update Shipping Address OR Pickup Requested OR Primary Attendee Contact after date specified on Pricebook field "Dont Allow Order Changes After" ');
                    }
                }
                
                
                List<Payment_Term__c> lstPT =  new List<Payment_Term__c>();
                List<Attachment> lstQuoteAttachment = new List<Attachment>();                
                // #319 Code changes done by Jheel for Too many SOQL -- START
                if(setQuoteId.size() > 0){
                    lstPT = [Select Id,Order__c,Quote__c,Quote__r.Opportunity.PriceBook2Id,Quote__r.Opportunity.PriceBook2.Start_Date__c,Quote__r.Opportunity.PriceBook2.End_Date__c, Status__c from Payment_Term__c where Quote__c in :setQuoteId];
                    lstQuoteAttachment = [SELECT Id, CreatedDate, ParentId FROM Attachment WHERE ParentId IN : setQuoteId];                    
                }
                if(lstQuoteAttachment.size() > 0){ for(Attachment obj : lstQuoteAttachment){ exchangeRateDateset.add(obj.CreatedDate.date()); mapOfQuoteIdVsDate.put(obj.ParentId, obj.CreatedDate.date()); } }
                // #319 Code changes done by Jheel for Too many SOQL -- END
                system.debug('###lstPT =='+lstPT);
                processApprovalCall(lstPT);
                system.debug('###currencyISOset=='+currencyISOset);
                system.debug('###exchangeRateDateset=='+exchangeRateDateset);
                if((!currencyISOset.isEmpty() && !exchangeRateDateset.isEmpty()) || Test.isrunningTest()) {                
                    populateExchangeRate(currencyISOset,exchangeRateDateset, mapOfQuoteIdVsDate);
                }                 
            }
            
            when BEFORE_DELETE {
                System.debug('In Before Delete!');
                deleteRelatedInventories();
            }
            
            when AFTER_INSERT {
                System.debug('In After Insert!');
                List<Order> lstActivatedOrders = new List<Order>();
                Set<Id> quoteSet = new Set<Id>();                
                List<Order> lstOrders = [Select Id, ContractId, AccountId, Pricebook2Id,Pricebook2.GPE_Event__c, OriginalOrderId, OpportunityId, QuoteId, Quote.Original_Quote__c,Quote.Original_Quote__r.TotalPrice, EffectiveDate, EndDate, IsReductionOrder, Opportunity.Pricebook2.GPE_Event__c,
                                         Status, Description, Type, BillingStreet, BillingCity, BillingState, BillingPostalCode, Original_Order__r.Order_Payment_Status__c,
                                         BillingCountry, BillingStateCode, BillingCountryCode, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, 
                                         ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStateCode, ShippingCountryCode, ShippingLatitude, 
                                         ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Name, PoDate, BillToContactId, ShipToContactId, ActivatedDate, ActivatedById, 
                                         CurrencyIsoCode, OrderNumber, TotalAmount, AR_Notes__c, Brandfuel_Customer_Link__c, Brandfuel_End_Date__c, Cancellation_Reasons_For_Review_Oper__c, 
                                         Comment__c, Customer_ID__c, F1_Access_Code_Assignment_Pending__c, Fanatics_Gift_Code_Assignment_Pending__c, GPE_Event_Name__c, GPE_Online_Order__c,
                                         GPE_Order_Id__c, GPT_Booking_Id__c, Intacct_Employee_Id__c, Intacct_Failure_Reason__c, Intacct_Id__c, Intacct_Record_URL__c, Intacct_Status__c,
                                         Memento_Premium_Assignment_Pending__c, Memento_Ultimate_Assignment_Pending__c, No_Show_No_Pickup__c, Order_Payment_Status__c, PO_Number__c,
                                         Payment_Terms__c, Phone__c, Pick_Up_Requested__c, Product_Listing__c, Reason_For_Cancellation__c, Record_Id__c, Subject_to_Cancellation__c,
                                         Tracking_Number__c, Xero_Reference_No__c, Xero_Response__c, Exchange_Rate_Date_Editable__c, Event_15_digit_Id__c, Original_Order__c, Awaiting_Approval_From__c,
                                         Approver_Name__c, Approved_Canceled_From_Closed_Won__c, Reward_Points_Pending__c, Ship_To_Name__c, Addendum_A_Waiver__c, Terms_And_Conditions__c, Sales_Reporting__c,
                                         Cancellation_Reasons_For_Review_Acc__c,Opportunity.Pricebook2Id, Refund_Requested__c, Date_Shipped__c, Fulfillment_Notes__c, Discount_Code__c, Google_Analytics_Source__c, Visitor_Country__c, 
                                         Sales_Agent__c, Send_Outbound_Message__c, User_Email__c,Refund_Reconciliation__c, (SELECT Id, OrderId, Product2Id, OrderItemNumber, Quantity FROM OrderItems) 
                                         from Order where Id IN :newOrderMap.keyset()];
                Map<Id, Date> mapOfOrderIdAndStartDate = new Map<Id, Date>();
                for(Order objOrd : lstOrders) {
                    quoteSet.add(objOrd.QuoteId);
                    //#1027
                    if(objOrd.Original_Order__c != null && objOrd.status.contains('Sales Adjustment')){ 
                        mapOfOrderIdAndStartDate.put(objOrd.Original_Order__c, objOrd.EffectiveDate);
                    }
                }
                processOrdersOnInsert(lstOrders);
                //Condition added by Jheel for #233
                if(System.isBatch() == false && System.isFuture() == false){
                    createHold(quoteSet);
                    H4HRewardPointBatch h4hrewardbatch = new H4HRewardPointBatch(newOrderMap.keySet());
                    Database.executeBatch(h4hrewardbatch);
                }
                //OrderRequestCancellationController.processRefund((List<Order>)Trigger.new);
                //#1027
                if(mapOfOrderIdAndStartDate.size() > 0){
                    updateSalesAdjDateOnOriginOrder(mapOfOrderIdAndStartDate);
                }
            }
            
            when AFTER_UPDATE {
                System.debug('In Order After Update!');
                Set<Id> lstquoteIds = new Set<Id>();
                Set<id> orderIds = new Set<Id>();
                Set<Id> setOrderIdsBF = new Set<Id>();
                Set<Id> setOrderItemIdsBF = new Set<Id>();
                List<Order> lstOpportunityOrders = new List<Order>();
                Set<Id> orderIDsForShippingAddressUpdate = new Set<Id>();
                
                Set<String> setOrderId = new Set<String>();
                //#855 - Resolve "Email Alert on change of "Seating Request" or "Comment" field value on Order.
                List<Messaging.SingleEmailMessage> emailBox = new List<Messaging.SingleEmailMessage>();
                for(Order objOrder : newOrderList){
                
                    if((objOrder.EffectiveDate != oldOrderMap.get(objOrder.Id).EffectiveDate) && objOrder.Status == 'Draft') { // #966
                        lstOpportunityOrders.add(objOrder);
                    }
                    
                    //VKHOPADE - issue 1219 - start
                    if(newOrderMap.get(objOrder.Id).ShippingStreet != oldOrderMap.get(objOrder.Id).ShippingStreet || newOrderMap.get(objOrder.Id).ShippingCity != oldOrderMap.get(objOrder.Id).ShippingCity ||
                       newOrderMap.get(objOrder.Id).ShippingState != oldOrderMap.get(objOrder.Id).ShippingState || newOrderMap.get(objOrder.Id).ShippingPostalCode != oldOrderMap.get(objOrder.Id).ShippingPostalCode ||
                       newOrderMap.get(objOrder.Id).Pick_Up_Requested__c != oldOrderMap.get(objOrder.Id).Pick_Up_Requested__c || 
                       newOrderMap.get(objOrder.Id).Primary_Attendee_Contact__c != oldOrderMap.get(objOrder.Id).Primary_Attendee_Contact__c || 
                       newOrderMap.get(objOrder.Id).Comment__c != oldOrderMap.get(objOrder.Id).Comment__c){
                        	orderIDsForShippingAddressUpdate.add(objOrder.Id);
                    }
         			//VKHOPADE - issue 1219 - end
         			
                    if(objOrder.Seating_Request__c != oldOrderMap.get(objOrder.Id).Seating_Request__c || objOrder.Comment__c != oldOrderMap.get(objOrder.Id).Comment__c){
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        List<String> emailAdd= new List<String>();
                        emailAdd.add(Label.Events_Team);
                        String emailBody = '';
                        message.setSaveAsActivity(false);
                        emailBody += '<html><body><ul><li>Order : <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+objOrder.ID+'">'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+objOrder.ID+'</a></li>';
                        if(objOrder.Comment__c != oldOrderMap.get(objOrder.Id).Comment__c && objOrder.Seating_Request__c != oldOrderMap.get(objOrder.Id).Seating_Request__c){
                        message.subject = 'Order Comments and Seating Requests Updated';
                        emailBody += '<li>Comments and Seating Requests Updated</li>';
                        }
                        else if(objOrder.Comment__c != oldOrderMap.get(objOrder.Id).Comment__c){
                        message.subject = 'Order Comments Updated';
                        emailBody += '<li>Comments Updated</li>';
                        }
                        else if(objOrder.Seating_Request__c != oldOrderMap.get(objOrder.Id).Seating_Request__c){
                        message.subject = 'Order Seating Requests Updated';
                        emailBody += '<li>Seating Request Updated</li>';
                        } 
                        emailBody += '</ul></body></html>';
                        message.setHtmlBody(emailBody);
                        message.setToAddresses(emailAdd);
                        emailBox.add(message);
                    }
                }
                if(!emailBox.isEmpty()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailBox);
                }
                List<Order> lstOrders = [Select Id, OrderNumber, Status, Order_Payment_Status__c, BillToContactId, BillToContact.Name, BillToContact.Email, Email__c, Opportunity.Ship_To_Name__c, Opportunity.Email__c, 
                                         Opportunity.Paid_in_Full__c, Opportunity.Pricebook2.Name, Opportunity.Pricebook2.End_Date__c, Opportunity.Pricebook2.Brandfuel_End_Date__c, Pricebook2.GPE_Event__c,Refund_Reconciliation__c,ShipToContactId,
                                         Pricebook2.Brandfuel_Category_Id__c,QuoteId,Quote_to_Online_Order__c,Quote_Online_Order__c,OpportunityId,Withhold_Percentage__c, AccountId, totalAmount,Pricebook2Id,CurrencyIsoCode,EffectiveDate,Original_Order__c, Quote.Original_Quote__c, Quote.Original_Quote__r.TotalPrice,
                                         ShippingAddress, Pick_Up_Requested__c, Opportunity.Pricebook2.Order_Notifications_Start_Date__c, Opportunity.Pricebook2.Dont_Allow_Order_Changes_After__c,
                                         (SELECT Id,OrderId,Product2Id,OrderItemNumber,Quantity,Description,UnitPrice,Product2.Name,Product2.Type__c,Product2.Brandfuel_Points__c,ProductType__c FROM OrderItems) 
                                         from Order where Id IN :newOrderMap.keyset()];

                processOrdersOnInsert(lstOrders);
                //VKHOPADE - issue 1219 - START
                if(orderIDsForShippingAddressUpdate.size() > 0)
                	processOrdersForShippingAddressEmail(lstOrders, orderIDsForShippingAddressUpdate);
                //VKHOPADE - issue 1219 - END
                
                Map<Id,Order> mapApproveOrders = new Map<Id,Order>();
                Map<Id, Date> mapOfOrderIdAndStartDate = new Map<Id, Date>();
                for(Order objOrds : lstOrders){
                    System.debug('objOrds.Status@@@'+objOrds.Status);
                    System.debug('objOrds.Original_Order__c@@@'+objOrds.Original_Order__c);
                    if(oldOrderMap.get(objOrds.Id).Status == 'Credit Adjustment Pending' && (objOrds.Status == 'Active' || objOrds.Status == 'Inactive - Credit Issued')){ 
                        mapApproveOrders.put(objOrds.id,objOrds); 
                    }
                    //#1027 - On changing the Start Date of order
                    if(objOrds.Original_Order__c != null && objOrds.status.contains('Sales Adjustment') && isStartDateChanged(objOrds.Id)){ 
                        mapOfOrderIdAndStartDate.put(objOrds.Original_Order__c, objOrds.EffectiveDate);
                    }
                }
                System.debug('lstApproveOrders@@@'+mapApproveOrders);
                if(mapApproveOrders.size() > 0){ OrderRequestCancellationController.processCreditRefund(mapApproveOrders); }
                List<Opportunity> lstOpptoUpdate = new List<Opportunity>();
                for(Order ord: lstOrders){
                    if((ord.Status != null && ord.Status == 'Canceled' && ord.Status != oldOrderMap.get(ord.Id).Status) || Test.IsrunningTest()){
                        Opportunity oppUpdate = new Opportunity();
                        oppUpdate.Id = ord.OpportunityId;
                        System.debug('opp id:@@'+ord.OpportunityId);
                        oppUpdate.StageName = 'Canceled';
                        lstOpptoUpdate.add(oppUpdate);
                    }
                    System.debug('lstOpptoUpdate@@@@'+lstOpptoUpdate);
                }
                if(lstOpptoUpdate.size() > 0 && !Test.IsrunningTest()){ Utility.processRecords(lstOpptoUpdate, 'update'); }
                List<Order> lstNewActiveOrders = new List<Order>();
                List<Order> lstCreditAdjustmentOrders = new List<Order>();
                List<Order> lstDefaultedOrders = new List<Order>();
                List<Order> lstUpdatingOriginalOrders = new List<Order>();
                Set<Id> setModifiedOrder = new Set<Id>();
                Set<id> setNewActiveOrderAccs = new set<id>();                
                List<Id> lstReverseArPaymentOrder = new List<Id>();
                Set<Id> onlineorderActivated = new set<Id>(); //29/07/2022-101 query fix
                for(Order objOrder: lstOrders) {
                    System.debug('objOrder.Status-->'+objOrder.Status);
                    System.debug('oldOrderMap.get(objOrder.Id).Status-->'+oldOrderMap.get(objOrder.Id).Status);
                    // #226 Condition Added by Jheel -- START
                    if(objOrder.Status == 'Active' && oldOrderMap.get(objOrder.Id).Status == 'Creation'){ 
                         //29/07/2022-101 query fix
                        if(objOrder.Quote_to_Online_Order__c || objOrder.Quote_Online_Order__c){
                            onlineorderActivated.add(objOrder.Id);
                        } //29/07/2022-101 query fix
                        else{
                        lstNewActiveOrders.add(objOrder); 
                        }
                         setNewActiveOrderAccs.add(objOrder.AccountId);
                         }
                    if(objOrder.Status == 'Inactive - Credit Issued' && oldOrderMap.get(objOrder.Id).Status == 'Credit Adjustment Pending'){ lstCreditAdjustmentOrders.add(objOrder); }
                    if(objOrder.Status == 'Canceled' && oldOrderMap.get(objOrder.Id).Status == 'Cancellation Pending'){ lstCreditAdjustmentOrders.add(objOrder); lstReverseArPaymentOrder.add(objOrder.Id);} //Adding to lsCreditAdujmentOrders list since it adds back the Inventory to the Product.
                    if(objOrder.Status == 'Modified' && oldOrderMap.get(objOrder.Id).Status == 'Active'){ setModifiedOrder.add(objOrder.id); lstCreditAdjustmentOrders.add(objOrder); lstReverseArPaymentOrder.add(objOrder.Id);}
                    if(objOrder.Status == 'Inactive - Refunded' && oldOrderMap.get(objOrder.Id).Status == 'Active'){ lstCreditAdjustmentOrders.add(objOrder); }
                    //#470 change added by Fesal -- START
                    if(objOrder.Status == 'Defaulted' && oldOrderMap.get(objOrder.Id).Status == 'Defaulted - Pending') { 
                        lstCreditAdjustmentOrders.add(objOrder);
                        //Created Defaulted - Sales Adjustment Order
                        lstDefaultedOrders.add(objOrder);
                    }
                    //#470 change added by Fesal -- END
                    // #226 Condition Added by Jheel -- END
                    System.debug('lstNewActiveOrders-->'+lstNewActiveOrders);
                    System.debug('lstCreditAdjustmentOrders-->'+lstCreditAdjustmentOrders);
                    /*if(objOrder.Order_Payment_Status__c != oldOrderMap.get(objOrder.Id).Order_Payment_Status__c && (objOrder.Order_Payment_Status__c == 'Partially Paid' || objOrder.Order_Payment_Status__c == 'Fully Paid')){
                        if((objOrder.Order_Payment_Status__c == 'Fully Paid' && objOrder.Status == 'Active' && objOrder.PriceBook2.Brandfuel_Category_Id__c != null) || Test.isRunningTest()){
                            for(OrderItem oitems: objOrder.OrderItems) { if(oitems.Product2.Type__c == 'Giftbag' && oitems.product2.Brandfuel_Points__c != null) { setOrderItemIdsBF.add(oitems.Id); setOrderIdsBF.add(objOrder.Id);
                                    System.debug('setOrderItemIdsBF-->'+setOrderItemIdsBF); 
                                }
                            }
                        }
                        lstquoteIds.add(objOrder.QuoteId);
                        system.debug('lstquoteIds'+lstquoteIds);    
                    }*/
                }
                System.debug('lstReverseArPaymentOrder-->'+lstReverseArPaymentOrder);
                
                if(lstNewActiveOrders.size() > 0 || lstCreditAdjustmentOrders.size() > 0){ createInventoryRecords(lstNewActiveOrders, lstCreditAdjustmentOrders); }
                 //29/07/2022-101 query fix
                if(!onlineorderActivated.isEmpty()){createInventoryRecords(onlineorderActivated);}
                if(setNewActiveOrderAccs.size() > 0) updateFirstBuyerOrders(setNewActiveOrderAccs);
                //#470 New Status on Order - Defaulted added by Fesal
                if(lstDefaultedOrders.size() > 0) { createDefaultedAdjustmentOrder(lstDefaultedOrders); }

                //#1027
                if(mapOfOrderIdAndStartDate.size() > 0){
                    updateSalesAdjDateOnOriginOrder(mapOfOrderIdAndStartDate);
                }

                /*if(setOrderIdsBF.size() > 0){
                    String query = 'Select Id, Status, Order_Payment_Status__c, OpportunityId, PriceBook2Id, PriceBook2.End_Date__c, PriceBook2.Name, PriceBook2.Brandfuel_End_Date__c, Brandfuel_Customer_Link__c from Order where Id IN :setOrderIdsBF';
                    BrandFuelBatch objBFBatch = new BrandFuelBatch(query, setOrderIdsBF, setOrderItemIdsBF); Database.executeBatch(objBFBatch, 1);
                }*/
                
                //#735 Add "Original Order Item" field to gift code object, add logic for this field.
                System.debug('@@@@setModifiedOrder: '+setModifiedOrder);
                if(setModifiedOrder.size() > 0) {
                    updateGiftCode(setModifiedOrder);
                }
                System.debug('**map values**'+newOrderMap.size()); 
                if(newOrderMap != null && newOrderMap.size()>0){
                    for(Order orderObj: newOrderMap.Values()){
                        if((orderObj.Order_Payment_Status__c == 'Partially Paid' || orderObj.Order_Payment_Status__c == 'Fully Paid') && oldOrderMap.get(orderObj.Id).Order_Payment_Status__c != orderObj.Order_Payment_Status__c){
                            orderIds.add(orderObj.Id);
                        }
                    }
                }
                if(!orderIds.isEmpty()){
                    Set<Id> setOrdIds = New set<Id>();
                    for(Payment_Term__c opt: [select id,Order__c from Payment_Term__c where Order__c in: orderIds AND Status__c = 'Passed' order by Payment_Due_Date__c]){
                        setOrdIds.add(opt.Order__c);
                    }
                    List<Order> lstOrds = [Select Id,Name,OrderNumber,QuoteId,F1_Access_Code_Assignment_Pending__c,Fanatics_Gift_Code_Assignment_Pending__c,Memento_Premium_Assignment_Pending__c,Memento_Ultimate_Assignment_Pending__c,Memento_Fan_Assignment_Pending__c
                                                                                    From Order Where Id in :setOrdIds];
                    system.debug('###'+lstOrds);
                    Map<Id, Order> mapOfOrder = new Map<Id, Order>();
                    for(Order obj : lstOrds){
                        mapOfOrder.put(obj.Id, obj);
                    }
                    system.debug('###mapOfOrder=='+mapOfOrder);
                    List<OrderItem> lstOrderItem = new List<OrderItem>();
                    if(!Test.isrunningTest()){ lstOrderItem = [SELECT Id,Quantity,OrderId,ProductType__c FROM OrderItem where OrderId IN : mapOfOrder.keyset() AND (ProductType__c = 'F1 Access Code' OR ProductType__c = 'Fanatics Gift Code' OR ProductType__c = 'Memento Premium' OR ProductType__c = 'Memento Ultimate' OR ProductType__c = 'Memento Fan') ]; }
                    else{                         
                        lstOrderItem = [SELECT Id,Quantity,OrderId,ProductType__c FROM OrderItem];

                    }
                    system.debug('###lstOrderItem=='+lstOrderItem);
                    Map<Id, List<OrderItem>> updatedOrdersWithMoreData = new Map<Id, List<OrderItem>>();
                    for(OrderItem obj : lstOrderItem){
                        if(!updatedOrdersWithMoreData.containskey(obj.OrderId)){ 
                            updatedOrdersWithMoreData.put(obj.OrderId, new List<OrderItem> {obj});    
                        }else{
                            updatedOrdersWithMoreData.get(obj.OrderId).add(obj);        
                        }                        
                    }
                    system.debug('mapOfOrder-->'+mapOfOrder);
                    system.debug('updatedOrdersWithMoreData-->'+updatedOrdersWithMoreData);
                    //#735 code move to batch class
                    //OrderPopulation(newOrderMap, oldOrderMap, updatedOrdersWithMoreData, mapOfOrder);
                    
                }
                List<Charge__c> lstCharge = [Select Id, Order__r.Status, Order_Status__c, Order__c from Charge__c where Order__c in :newOrderMap.keyset()];
                List<Charge__c> lstChargeToUpdate = new List<Charge__c>();
                for(Charge__c objCharge: lstCharge){
                    if(objCharge.Order__r.Status == 'Modified'){
                        Charge__c objNewCharge = new Charge__c(); objNewCharge.Id = objCharge.Id; lstChargeToUpdate.add(objNewCharge);
                    }
                }
                OrderRequestCancellationController.processCancelOrder(Trigger.newMap,Trigger.oldMap, lstCharge);
                if(!lstChargeToUpdate.isEmpty()){ utility.processRecords(lstChargeToUpdate,'update'); }
                
                //#922 change - START
                List<Order> lstNeworder = new List<Order>();
                List<Id> lstOrderId = new List<Id>();
                for(Order objorder: newOrderList) {
                    if(objorder.ShipToContactId != oldOrderMap.get(objorder.Id).ShipToContactId
                       || objorder.BillToContactId != oldOrderMap.get(objorder.Id).BillToContactId  
                          || objorder.Primary_Attendee_Contact__c != oldOrderMap.get(objorder.Id).Primary_Attendee_Contact__c) {
                      lstNeworder.add(objorder);
                    }
                    if(objorder.PO_Number__c != oldOrderMap.get(objorder.Id).PO_Number__c){
                        lstOrderId.add(objorder.Id);
                    }
                }
                system.debug('@@lstNeworder=='+lstNeworder);
                if(lstNeworder.size() > 0) {
                    system.debug('@@setOpportunityContactRole called');
                    setOpportunityContactRole(lstNeworder);
                } //#922 change - END
                if(lstOrderId.size() > 0){updatePONumberInIntacct(lstOrderId);}
                if(lstReverseArPaymentOrder.size() > 0){reverseARPaymentInIntacct(lstReverseArPaymentOrder);}
            }
            
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }

    @future(callout=true)
    public static void updatePONumberInIntacct(List<Id> orderIds) {
        System.debug('@@ updating PONumber InIntacct for OrderIds.'+orderIds);
        IntacctOrderSyncBatchHelper intactBatchHelper = new IntacctOrderSyncBatchHelper();
        List<Payment_Term__c> listOfPT = [Select Id, Intacct_Id__c, Order__c, Order__r.PO_Number__c from Payment_Term__c where Order__c in :orderIds and Status__c != 'Passed'];
        System.debug('@@....listOfPT.size().........'+listOfPT.size());
        for(Payment_Term__c pt: listOfPT){
            String invoiceNumber = pt.Intacct_Id__c.substringAfter('-');
            System.debug('@@ Got invoice number from PT: '+invoiceNumber+' for Order ID: '+pt.Order__c);
            System.debug('@@ Updating invoice in intacct');
            intactBatchHelper.updateInvoiceCallout(pt.Order__c, invoiceNumber, pt.Order__r.PO_Number__c);
        }
    }

    @future(callout=true)
    public static void reverseARPaymentInIntacct(List<Id> orderIds) {
        IntacctOrderSyncBatchHelper intactBatchHelper = new IntacctOrderSyncBatchHelper();
        List<Payment_Term__c> listOfPT = [Select Id, Intacct_Apply_Adjustment_Id__c,Order__c from Payment_Term__c where Order__c in :orderIds and Intacct_Apply_Adjustment_Id__c != null];
        System.debug('@@....listOfPT.size().........'+listOfPT.size());
        Map<Id, Payment_Term__c> orderAndAdjustmentMap = new Map<Id, Payment_Term__c>();
        
        for(Payment_Term__c pt: listOfPT){
            orderAndAdjustmentMap.put(pt.Order__c,pt);
             intactBatchHelper = new IntacctOrderSyncBatchHelper(pt.Order__c, 'Reverse_arpayment');
             System.debug('@@ reversing ar payment for paymentTerm'+pt);
             intactBatchHelper.applyReverseAdujusment(pt);
        }
    }

    @future
    public static void updateGiftCode(Set<Id> setModifiedOrder) {
        Map<Id,Id> mapOldNewOrder = new Map<Id,Id>();
        Map<Id,List<OrderItem>> mapOrderItems = new Map<Id,List<OrderItem>>();
        Map<Id,Integer> mapCountOrderItem = new Map<Id,Integer>();
        
        for(Order objOrder: [Select Id, Original_Order__c, (Select Id, ProductType__c, Quantity FROM OrderItems) FROM Order WHERE Original_Order__c IN :setModifiedOrder]) {
            System.debug('Original_Order__c: '+objOrder.Original_Order__c);
            mapOldNewOrder.put(objOrder.Original_Order__c, objOrder.Id);
            if(objOrder.OrderItems.size() > 0) {
                mapOrderItems.put(objOrder.Id, objOrder.OrderItems);
                for(OrderItem objOI: objOrder.OrderItems){
                    mapCountOrderItem.put(objOI.Id, Integer.valueOf(objOI.Quantity));
                }
            }
        }
        System.debug('@@@mapOldNewOrder: '+mapOldNewOrder);
        List<Gift_Code__c> updateGiftCode = new List<Gift_Code__c>();
        for(Gift_Code__c objGiftCode: [Select Id, Order__c, Order_Item__c, RecordTypeId, RecordType.Name FROM Gift_Code__c WHERE Order__c IN :setModifiedOrder]) {
            Id OriginalOrderItem = objGiftCode.Order_Item__c;
            Id newOrderId = mapOldNewOrder.get(objGiftCode.Order__c);
            objGiftCode.Original_Order_Item__c = OriginalOrderItem;
            objGiftCode.Order__c = null;
            objGiftCode.Order_Item__c = null;
            if(newOrderId != null && mapOrderItems.containskey(newOrderId)){
                for(OrderItem objOI: mapOrderItems.get(newOrderId)){
                    Integer temp = mapCountOrderItem.get(objOI.Id);
                    if(temp > 0 && ((objGiftCode.RecordType.Name == 'F1 Access Code' && objOI.ProductType__c == 'F1 Access Code') ||
                       (objGiftCode.RecordType.Name == 'Fanatics Gift Code' && objOI.ProductType__c == 'Fanatics Gift Code') || 
                       (objGiftCode.RecordType.Name == 'Memento Fan' && objOI.ProductType__c == 'Memento Fan') ||
                       (objGiftCode.RecordType.Name == 'Memento Premium' && objOI.ProductType__c == 'Memento Premium') || 
                       (objGiftCode.RecordType.Name == 'Memento Ultimate' && objOI.ProductType__c == 'Memento Ultimate'))){
                        objGiftCode.Order__c = newOrderId;
                        objGiftCode.Order_Item__c = objOI.Id;
                        
                        mapCountOrderItem.put(objOI.Id, temp - 1);
                        break;
                    }
                }
            }
            
            
            updateGiftCode.add(objGiftCode);
        }
        if(updateGiftCode.size() > 0){
            update updateGiftCode;
        }
    }
    /**
    * @description  : Approval for Cancel Order 
    * @author       : jagrawal@addonblue.com
    * @param        : Map<OrdId, QuoteId>
    * @return       : 
    **/ 
    public static void processApprovalCall(List<Payment_Term__c> lstPT){
        
        String strReasonReviewAccounting = '';
        String strReasonReviewOperations = '';
        Map<Id,Payment_Term__c> mapPTPassed = new Map<Id,Payment_Term__c>();
        Map<Id,Payment_Term__c> mapPT = new Map<Id,Payment_Term__c>();
        for(Payment_Term__c objPT : lstPT){
            mapPT.put(objPT.Order__c,objPT);
            if(objPT.Status__c == 'Passed')
                mapPTPassed.put(objPT.Order__c,objPT);
        }
        system.debug('###'+mapPTPassed);
        for(Order objOrder : (List<Order>)Trigger.New){
            system.debug('###objOrder.Status=='+objOrder.Status);
            system.debug('###objOrder.Refund_Requested__c=='+objOrder.Refund_Requested__c);
            if((objOrder.Status).equals('Cancellation Pending')){ 
                system.debug('###Inif');
                if(mapPTPassed.get(objOrder.Id) != null) {
                    strReasonReviewAccounting  += 'Cancellation request for order which has paid payment term'+'<br>';
                    strReasonReviewOperations  += 'Cancellation request for order which has paid payment term'+'<br>';
                }
                if(objOrder.Tracking_Number__c != null) { strReasonReviewAccounting += 'Cancellation request for order which has been shipped'+'<br>'; strReasonReviewOperations += 'Cancellation request for order which has been shipped'+'<br>'; } 
                //if((mapPT.get(objOrder.Id).Quote__r.Opportunity.PriceBook2.Start_Date__c != null && mapPT.get(objOrder.Id).Quote__r.Opportunity.PriceBook2.Start_Date__c.daysbetween(system.today())<=30) || Test.IsrunningTest()){{
                Date eventStartDate = mapPT.get(objOrder.Id).Quote__r.Opportunity.PriceBook2.Start_Date__c;
                if(eventStartDate != null || Test.IsrunningTest()){
                    Date todayDate = system.today();
                    Integer daysbetween = todayDate.daysbetween(eventStartDate);
                    if(daysbetween>=0 && daysbetween<=30){
                        strReasonReviewOperations += 'Event start date is within a month'+'<br>';
                    }
                }                
                if(objOrder.Refund_Requested__c == true){ strReasonReviewAccounting +='Refund Requested.'; }
                system.debug('###strReasonReviewAccounting =='+strReasonReviewAccounting );
                objOrder.Cancellation_Reasons_For_Review_Acc__c = strReasonReviewAccounting;
                objOrder.Cancellation_Reasons_For_Review_Oper__c =  strReasonReviewOperations;
               // }            
            }
        }
    }
    
    /**
    * @description: gift code assignment on order status change.
    * @author jagrawal@addonblue.com | 2/28/2020 
    * @param Map<Id Order> MapObjectMap 
    * @param Map<Id Order> oldObjectMap 
    * @param set<Id> setoprderIds 
    * @return void 
    **/
    public static void OrderPopulation(Map<Id,Order> MapObjectMap,Map<Id,Order> oldObjectMap, Map<Id, List<OrderItem>> updatedOrdersWithMoreData, Map<Id, Order> mapOfOrder){
        /*Set<id> orderIds = new Set<Id>();
        Map<Id,Integer> mapofOrderIDToQuantityF1AccessCode = new Map<Id,Integer>();
        Map<Id,Integer> mapofOrderIDToQuantityFanatics = new Map<Id,Integer>();
        Map<Id,Integer> mapofOrderIDToQuantityMementoPremium = new Map<Id,Integer>();
        Map<Id,Integer> mapofOrderIDToQuantityMementoUltimate = new Map<Id,Integer>();
        Map<Id,Integer> mapofOrderIDToQuantityMementoFan = new Map<Id,Integer>();
        Integer totalNumberOfF1AccessReq = 0;
        Integer totalNumberOfFanaticsReq = 0;
        Integer totalNumberOfMementoPremiumReq = 0;
        Integer totalNumberOfMementoUltimateReq = 0;
        Integer totalNumberOfMementoFanReq = 0;

        //#735 Add "Original Order Item" field to gift code object, add logic for this field.
        Map<Id,List<OrderItem>> mapofOrderIDToListF1AccessCode = new Map<Id,List<OrderItem>>();
        Map<Id,List<OrderItem>> mapofOrderIDToListFanatics = new Map<Id,List<OrderItem>>();
        Map<Id,List<OrderItem>> mapofOrderIDToListMementoPremium = new Map<Id,List<OrderItem>>();
        Map<Id,List<OrderItem>> mapofOrderIDToListMementoUltimate = new Map<Id,List<OrderItem>>();
        Map<Id,List<OrderItem>> mapofOrderIDToListMementoFan = new Map<Id,List<OrderItem>>();
        Map<Id,Integer> mapOrderItemWithUnAssignedQuantity = new Map<Id,Integer>();
        
        //if(!orderIds.isEmpty()){
            List<Order> orderList = new List<Order>();
            Map<Id,Order> mapOrderF1AccessCode = new Map<Id,Order>();
            Map<Id,Order> mapOrderFanaticsCode = new Map<Id,Order>();
            Map<Id,Order> mapOrderMementoPremiumCode = new Map<Id,Order>();
            Map<Id,Order> mapOrderMementoUltimateCode = new Map<Id,Order>();
            Map<Id,Order> mapOrderMementoFanCode = new Map<Id,Order>();
            
            for(Id orderId : updatedOrdersWithMoreData.keyset()){
                Integer quantityvalF1AccessCode = 0;
                Integer quantityvalFanatics = 0;
                Integer quantityvalMementoPremium = 0;
                Integer quantityvalMementoUltimate = 0;
                Integer quantityvalMementoFan = 0;
                
                for(OrderItem ordLineItem: updatedOrdersWithMoreData.get(orderId)) {
                    System.debug('***opp line item**' +ordLineItem.id);
                    mapOrderItemWithUnAssignedQuantity.put(ordLineItem.Id, Integer.valueOf(ordLineItem.Quantity));
                    if((ordLineItem.ProductType__c =='F1 Access Code' && ordLineItem.Quantity != null)){ 
                        quantityvalF1AccessCode = quantityvalF1AccessCode + Integer.valueOf(ordLineItem.Quantity);
                        //#735 Add "Original Order Item" field to gift code object, add logic for this field.
                        List<OrderItem> tempItems = new List<OrderItem>();
                        if(mapofOrderIDToListF1AccessCode != null && mapofOrderIDToListF1AccessCode.containskey(ordLineItem.OrderId)){
                            tempItems = mapofOrderIDToListF1AccessCode.get(ordLineItem.OrderId);
                        }
                        tempItems.add(ordLineItem);
                        mapofOrderIDToListF1AccessCode.put(ordLineItem.OrderId, tempItems);
                        System.debug('***line item quantity**'+Integer.valueOf(ordLineItem.Quantity));
                        System.debug('***quantity total**'+quantityvalF1AccessCode);
                    }
                    else if((ordLineItem.ProductType__c =='Fanatics Gift Code' && ordLineItem.Quantity != null)){ 
                        quantityvalFanatics  = quantityvalFanatics + Integer.valueOf(ordLineItem.Quantity);
                        //#735 Add "Original Order Item" field to gift code object, add logic for this field.
                        List<OrderItem> tempItems = new List<OrderItem>();
                        if(mapofOrderIDToListFanatics != null && mapofOrderIDToListFanatics.containskey(ordLineItem.OrderId)){
                            tempItems = mapofOrderIDToListFanatics.get(ordLineItem.OrderId);
                        }
                        tempItems.add(ordLineItem);
                        mapofOrderIDToListFanatics.put(ordLineItem.OrderId, tempItems);
                        System.debug('***quantity total**'+quantityvalFanatics);
                    }
                    else if((ordLineItem.ProductType__c =='Memento Premium' && ordLineItem.Quantity != null)){ 
                        quantityvalMementoPremium  = quantityvalMementoPremium + Integer.valueOf(ordLineItem.Quantity);
                        //#735 Add "Original Order Item" field to gift code object, add logic for this field.
                        List<OrderItem> tempItems = new List<OrderItem>();
                        if(mapofOrderIDToListMementoPremium != null && mapofOrderIDToListMementoPremium.containskey(ordLineItem.OrderId)){
                            tempItems = mapofOrderIDToListMementoPremium.get(ordLineItem.OrderId);
                        }
                        tempItems.add(ordLineItem);
                        mapofOrderIDToListMementoPremium.put(ordLineItem.OrderId, tempItems);
                        System.debug('***quantity total**'+quantityvalMementoPremium);
                    }
                    else if((ordLineItem.ProductType__c =='Memento Ultimate' && ordLineItem.Quantity != null)){ 
                        quantityvalMementoUltimate  = quantityvalMementoUltimate + Integer.valueOf(ordLineItem.Quantity);
                        //#735 Add "Original Order Item" field to gift code object, add logic for this field.
                        List<OrderItem> tempItems = new List<OrderItem>();
                        if(mapofOrderIDToListMementoUltimate != null && mapofOrderIDToListMementoUltimate.containskey(ordLineItem.OrderId)){
                            tempItems = mapofOrderIDToListMementoUltimate.get(ordLineItem.OrderId);
                        }
                        tempItems.add(ordLineItem);
                        mapofOrderIDToListMementoUltimate.put(ordLineItem.OrderId, tempItems);
                        System.debug('***quantity total**'+ quantityvalMementoUltimate);
                    }
                    else if((ordLineItem.ProductType__c =='Memento Fan' && ordLineItem.Quantity != null)){ 
                        quantityvalMementoFan  = quantityvalMementoFan + Integer.valueOf(ordLineItem.Quantity);
                        //#735 Add "Original Order Item" field to gift code object, add logic for this field.
                        List<OrderItem> tempItems = new List<OrderItem>();
                        if(mapofOrderIDToListMementoFan != null && mapofOrderIDToListMementoFan.containskey(ordLineItem.OrderId)){
                            tempItems = mapofOrderIDToListMementoFan.get(ordLineItem.OrderId);
                        }
                        tempItems.add(ordLineItem);
                        mapofOrderIDToListMementoFan.put(ordLineItem.OrderId, tempItems);
                        System.debug('***quantity total**'+ quantityvalMementoFan);
                    }
                }
                
                if(quantityvalF1AccessCode != 0 || Test.isRunningTest()){
                    mapOrderF1AccessCode.put(orderId,mapOfOrder.get(orderId));
                    mapofOrderIDToQuantityF1AccessCode.put(orderId,quantityvalF1AccessCode);
                    totalNumberOfF1AccessReq = totalNumberOfF1AccessReq + quantityvalF1AccessCode;
                }
                
                if(quantityvalFanatics != 0 || Test.isRunningTest()){
                    mapOrderFanaticsCode.put(orderId,mapOfOrder.get(orderId));
                    mapofOrderIDToQuantityFanatics.put(orderId,quantityvalFanatics);
                    totalNumberOfFanaticsReq = totalNumberOfFanaticsReq + quantityvalFanatics;
                }
                if(quantityvalMementoPremium != 0 || Test.isRunningTest()){
                    mapOrderMementoPremiumCode.put(orderId,mapOfOrder.get(orderId));
                    mapofOrderIDToQuantityMementoPremium.put(orderId,quantityvalMementoPremium);
                    totalNumberOfMementoPremiumReq = totalNumberOfMementoPremiumReq + quantityvalMementoPremium;
                }
                if(quantityvalMementoUltimate != 0 || Test.isRunningTest()){
                    mapOrderMementoUltimateCode.put(orderId,mapOfOrder.get(orderId));
                    mapofOrderIDToQuantityMementoUltimate.put(orderId,quantityvalMementoUltimate);
                    totalNumberOfMementoUltimateReq = totalNumberOfMementoUltimateReq + quantityvalMementoUltimate;
                }
                if(quantityvalMementoFan != 0 || Test.isRunningTest()){
                    mapOrderMementoFanCode.put(orderId,mapOfOrder.get(orderId));
                    mapofOrderIDToQuantityMementoFan.put(orderId,quantityvalMementoFan);
                    totalNumberOfMementoFanReq = totalNumberOfMementoFanReq + quantityvalMementoFan;
                }
            }
            
            
            Map<Id,Map<String,Integer>> mapassignedOrderGiftCodes = new Map<Id,Map<String,Integer>>();            
            Integer intcount = 0;
            //Removed unused fields from the SOQL:- Id,
            String strgc = 'Select RecordTypeName__c, Order__c, , Order_Item__c, Original_Order_Item__c from Gift_Code__c where Order__c != null';
            String strfilter = '';
            if(totalNumberOfF1AccessReq>0){ if(!String.Isblank(strfilter)) strfilter += ', \'F1 Access Code\'';
                else strfilter += '\'F1 Access Code\'';
            } 
            if(totalNumberOfFanaticsReq>0 || Test.isRunningTest()){
                if(!String.Isblank(strfilter)) strfilter += ', \'Fanatics Gift Code\'';
                else strfilter += '\'Fanatics Gift Code\'';
            } 
            if(totalNumberOfMementoPremiumReq>0 || Test.isRunningTest()){
                if(!String.Isblank(strfilter)) strfilter += ', \'Memento Premium\'';
                else strfilter += '\'Memento Premium\'';
            } 
            if(totalNumberOfMementoUltimateReq>0 || Test.isRunningTest()){
                if(!String.Isblank(strfilter)) strfilter += ', \'Memento Ultimate\'';
                else strfilter += '\'Memento Ultimate\'';
            } 
            if(totalNumberOfMementoUltimateReq>0 || Test.isRunningTest()){
                if(!String.Isblank(strfilter)) strfilter += ', \'Memento Fan\'';
                else strfilter += '\'Memento Fan\'';
            } 
            If(!String.Isblank(strfilter)){
                strgc += ' and RecordTypeName__c in (' + strfilter + ')';
            }
            
            strgc += ' order by RecordTypeName__c';
            
            system.debug('@@@strgc ==='+strgc );
            
            if(totalNumberOfF1AccessReq >0 || totalNumberOfFanaticsReq>0 || totalNumberOfMementoPremiumReq>0 || totalNumberOfMementoUltimateReq>0 || totalNumberOfMementoFanReq>0){
                for(Gift_Code__c  giftcode:database.query(strgc)){
                    if(giftcode.Order_Item__c != null && mapOrderItemWithUnAssignedQuantity.containskey(giftcode.Order_Item__c)){
                        Integer intQnty = mapOrderItemWithUnAssignedQuantity.get(giftcode.Order_Item__c);
                        mapOrderItemWithUnAssignedQuantity.put(giftcode.Order_Item__c, intQnty-1);
                    }
                    if(!mapassignedOrderGiftCodes.containskey(giftcode.Order__c)){ 
                        intcount = 1; 
                        mapassignedOrderGiftCodes.put(giftcode.Order__c,New Map<String,Integer>{giftcode.RecordTypeName__c=>intcount});
                    }else{
                        Map<String,Integer> mapassignedCount = New Map<String,Integer>(); if(mapassignedOrderGiftCodes.get(giftcode.Order__c).containskey(giftcode.RecordTypeName__c)){
                            intcount = mapassignedOrderGiftCodes.get(giftcode.Order__c).get(giftcode.RecordTypeName__c)+1; mapassignedOrderGiftCodes.get(giftcode.Order__c).put(giftcode.RecordTypeName__c, intcount);
                        }else{
                            intcount = 1; mapassignedOrderGiftCodes.get(giftcode.Order__c).put(giftcode.RecordTypeName__c, intcount);
                        }
                    }
                }
            }
            
            Map<Id,Order> ordMap = new Map<Id,Order>();
            if(totalNumberOfF1AccessReq > 0){
                //Removed unused fields from the SOQL:- Order__c,Gift_Code__c,RecordTypeName__c
                List<Gift_Code__c> codelist = [SELECT Id FROM Gift_Code__c WHERE Order__c = null and Opportunity__c = null and RecordTypeName__c = 'F1 Access Code' LIMIT :totalNumberOfF1AccessReq];
                system.debug('totalNumberOfF1AccessReq'+totalNumberOfF1AccessReq+'codelist'+codelist.Size());
                if(!codelist.isEmpty() && codelist.Size() == totalNumberOfF1AccessReq){ //) || Test.isRunningTest()
                    
                    Integer i=0; Integer diffAssignedCode = 0;   
                    System.debug('mapofOrderIDToQuantityF1AccessCode.get(ordId)-->'+mapofOrderIDToQuantityF1AccessCode);    
                    System.debug('mapassignedOrderGiftCodes.get(ordId).get(F1 Access Code)-->'+mapassignedOrderGiftCodes);
                    for(Id ordId: mapofOrderIDToQuantityF1AccessCode.keySet()){
                        if(mapassignedOrderGiftCodes.containskey(ordId) && mapassignedOrderGiftCodes.get(ordId) != null && mapassignedOrderGiftCodes.get(ordId).get('F1 Access Code') != null){ diffAssignedCode = mapofOrderIDToQuantityF1AccessCode.get(ordId) - mapassignedOrderGiftCodes.get(ordId).get('F1 Access Code');
                        }else{
                            diffAssignedCode = mapofOrderIDToQuantityF1AccessCode.get(ordId);
                        }
                        for(Integer j=0;j < diffAssignedCode;j++){ 
                            codelist[i].Order__c = ordId; 
                            if(mapofOrderIDToListF1AccessCode != null && mapofOrderIDToListF1AccessCode.containsKey(OrdId)){
                                List<OrderItem> lstTempOrderItem = mapofOrderIDToListF1AccessCode.get(OrdId);
                                if(lstTempOrderItem.size() == 1){
                                    codelist[i].Order_Item__c = lstTempOrderItem[0].Id;
                                } else if(lstTempOrderItem.size() > 1) {
                                    for(OrderItem objOI: lstTempOrderItem){
                                        if(mapOrderItemWithUnAssignedQuantity.containsKey(objOI.Id) && mapOrderItemWithUnAssignedQuantity.get(objOI.Id) > 0){
                                            Integer temp = mapOrderItemWithUnAssignedQuantity.get(objOI.Id);
                                            mapOrderItemWithUnAssignedQuantity.put(objOI.Id, temp-1);
                                            codelist[i].Order_Item__c = objOI.Id;
                                        }
                                    }
                                }
                            }
                            i++; 
                        }
                        
                        if(i != 0 && diffAssignedCode != 0 && i == diffAssignedCode){ Order odrObj = new Order(Id=ordId);
                            if(ordMap.containskey(ordId)){ odrObj = ordMap.get(ordId); }
                            odrObj.F1_Access_Code_Assignment_Pending__c = false; ordMap.put(ordId,odrObj);
                        }
                    }
                    if (codelist.size() > 0) { Utility.processRecords(codelist, 'update'); }
                    
                }
                if(codelist.size() < totalNumberOfF1AccessReq || Test.isRunningTest()) {
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    for(Order orderObj : mapOrderF1AccessCode.values()){
                        
                        String[] toAddresses = Label.Email_to_Aaron.split(',');
                        String body = 'Order : ' + orderObj.OrderNumber+'\n';
                        body += 'F1 Access Codes needed :'+totalNumberOfF1AccessReq+'\n';
                        body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderObj.Id+'\n';
                        body +='Please Note: F1 Access Codes insufficient to be add to above Order.';
                        
                        mails.add(Utility.createSingleEmailMessage(toAddresses,'F1 Access Codes Insufficient','Not Sufficient',body,false,false));

                        if(!mapassignedOrderGiftCodes.containskey(orderObj.Id) || (mapassignedOrderGiftCodes.containskey(orderObj.Id) && !mapassignedOrderGiftCodes.get(orderObj.Id).containskey('F1 Access Code')) || (mapassignedOrderGiftCodes.containskey(orderObj.Id) && mapassignedOrderGiftCodes.get(orderObj.Id).containskey('F1 Access Code') &&
                                                                                                                                                                                                                        mapassignedOrderGiftCodes.get(orderObj.Id).get('F1 Access Code') != totalNumberOfF1AccessReq)){
                                                                                                                                                                                                                            if(!ordMap.containskey(orderObj.Id)){ orderObj.F1_Access_Code_Assignment_Pending__c = true; ordMap.put(orderObj.Id,orderObj);
                                                                                                                                                                                                                            }else{
                                                                                                                                                                                                                                orderObj = ordMap.get(orderObj.Id); orderObj.F1_Access_Code_Assignment_Pending__c = true; ordMap.put(orderObj.Id,orderObj);
                                                                                                                                                                                                                            }
                                                                                                                                                                                                                        }
                    }
                    Messaging.sendEmail(mails);
                }
            }
            if(totalNumberOfFanaticsReq > 0 || Test.isRunningTest()){
                //Removed unused fields from the SOQL:- Order__c,Gift_Code__c,RecordTypeName__c
                List<Gift_Code__c> fanaticsList = [SELECT Id FROM Gift_Code__c WHERE Order__c = null and Opportunity__c = null and RecordTypeName__c = 'Fanatics Gift Code' LIMIT :totalNumberOfFanaticsReq];
                if(!fanaticsList.isEmpty() && fanaticsList.Size() == totalNumberOfFanaticsReq || Test.isRunningTest()){ //) || Test.isRunningTest()
                    Integer i=0;
                    Integer diffAssignedCode = 0;   
                    for(Id ordId: mapofOrderIDToQuantityFanatics.keySet()){
                        if(mapassignedOrderGiftCodes.containskey(ordId) && mapassignedOrderGiftCodes.get(ordId) != null && mapassignedOrderGiftCodes.get(ordId).get('Fanatics Gift Code') != null){ diffAssignedCode = mapofOrderIDToQuantityFanatics.get(ordId) - mapassignedOrderGiftCodes.get(ordId).get('Fanatics Gift Code');
                        }else{
                            diffAssignedCode = mapofOrderIDToQuantityFanatics.get(ordId);
                        }
                        for(Integer j=0;j < diffAssignedCode;j++){ 
                            fanaticsList[i].Order__c = ordId; 
                             if(mapofOrderIDToListFanatics != null && mapofOrderIDToListFanatics.containsKey(OrdId)){
                                List<OrderItem> lstTempOrderItem = mapofOrderIDToListFanatics.get(OrdId);
                                if(lstTempOrderItem.size() == 1) {
                                    fanaticsList[i].Order_Item__c = lstTempOrderItem[0].Id;
                                } else if(lstTempOrderItem.size() > 1) {
                                    for(OrderItem objOI: lstTempOrderItem) {
                                        if(mapOrderItemWithUnAssignedQuantity.containsKey(objOI.Id) && mapOrderItemWithUnAssignedQuantity.get(objOI.Id) > 0){
                                            Integer temp = mapOrderItemWithUnAssignedQuantity.get(objOI.Id);
                                            mapOrderItemWithUnAssignedQuantity.put(objOI.Id, temp-1);
                                            fanaticsList[i].Order_Item__c = objOI.Id;
                                        }
                                    }
                                }
                            }
                            i++; 
                        }
                        
                        if(i != 0 && diffAssignedCode != 0 && i == diffAssignedCode){ Order orderObj = new Order(Id=ordId);
                            if(ordMap.containskey(ordId)){ orderObj = ordMap.get(ordId); }
                            orderObj.Fanatics_Gift_Code_Assignment_Pending__c = false; ordMap.put(ordId,orderObj);
                        }
                    }
                    
                    if (fanaticsList.size() > 0) { Utility.processRecords(fanaticsList, 'update'); }
                }
                if(fanaticsList.size() < totalNumberOfFanaticsReq || Test.isRunningTest()) {
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    for(Order orderObj : mapOrderFanaticsCode.values()){
                                            
                        String[] toAddresses = Label.Email_to_Aaron.split(',');
                        String body = 'Order : ' + (orderObj != null ? orderObj.OrderNumber: '')+'\n';
                        body += 'Fanatics Gift Codes needed :'+totalNumberOfFanaticsReq+'\n';
                        if(orderObj != null) body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderObj.Id+'\n';
                        body +='Please Note: Fanatics Gift Codes insufficient to be add to above Order.';
                        
                        mails.add(Utility.createSingleEmailMessage(toAddresses,'Fanatics Gift Codes Insufficient','Not Sufficient',body,false,false));
                        if(orderObj != null && (!mapassignedOrderGiftCodes.containskey(orderObj.Id) || (mapassignedOrderGiftCodes.containskey(orderObj.Id) && !mapassignedOrderGiftCodes.get(orderObj.Id).containskey('Fanatics Gift Code')) || (mapassignedOrderGiftCodes.containskey(orderObj.Id) && mapassignedOrderGiftCodes.get(orderObj.Id).containskey('Fanatics Gift Code') &&
                                                                                                                                                                                                                            mapassignedOrderGiftCodes.get(orderObj.Id).get('Fanatics Gift Code') != totalNumberOfFanaticsReq ))){
                                                                                                                                                                                                                                if(!ordMap.containskey(orderObj.Id)){
                                                                                                                                                                                                                                    orderObj.Fanatics_Gift_Code_Assignment_Pending__c = true;
                                                                                                                                                                                                                                    ordMap.put(orderObj.Id,orderObj);
                                                                                                                                                                                                                                }else{
                                                                                                                                                                                                                                    orderObj = ordMap.get(orderObj.Id);
                                                                                                                                                                                                                                    orderObj.Fanatics_Gift_Code_Assignment_Pending__c = true;
                                                                                                                                                                                                                                    ordMap.put(orderObj.Id,orderObj);
                                                                                                                                                                                                                                }
                                                                                                                                                                                                                            }
                    }
                    if(!Test.isRunningTest()) Messaging.sendEmail(mails);
                }
            }
            if(totalNumberOfMementoPremiumReq > 0 || Test.isRunningTest()){
                //Removed unused fields from the SOQL:- Order__c,Gift_Code__c,RecordTypeName__c
                List<Gift_Code__c> fanaticsList = [SELECT Id FROM Gift_Code__c WHERE Order__c = null and Opportunity__c = null and RecordTypeName__c = 'Memento Premium' LIMIT :totalNumberOfMementoPremiumReq];
                if((!fanaticsList.isEmpty() && fanaticsList.Size() == totalNumberOfMementoPremiumReq) || Test.isRunningTest()){
                    Integer i=0;
                    Integer diffAssignedCode = 0;
                    for(Id ordId: mapofOrderIDToQuantityMementoPremium.keySet()){
                        if(mapassignedOrderGiftCodes.containskey(ordId) && mapassignedOrderGiftCodes.get(ordId) != null && mapassignedOrderGiftCodes.get(ordId).get('Memento Premium') != null){ diffAssignedCode = mapofOrderIDToQuantityMementoPremium.get(ordId) - mapassignedOrderGiftCodes.get(ordId).get('Memento Premium');
                        }else{
                            diffAssignedCode = mapofOrderIDToQuantityMementoPremium.get(ordId);
                        }
                        for(Integer j=0;j < diffAssignedCode;j++){ 
                            fanaticsList[i].Order__c = ordId;
                            if(mapofOrderIDToListMementoPremium != null && mapofOrderIDToListMementoPremium.containsKey(OrdId)){
                                List<OrderItem> lstTempOrderItem = mapofOrderIDToListMementoPremium.get(OrdId);
                                if(lstTempOrderItem.size() == 1){
                                    fanaticsList[i].Order_Item__c = lstTempOrderItem[0].Id;
                                }  else if(lstTempOrderItem.size() > 1) {
                                    for(OrderItem objOI: lstTempOrderItem){
                                        if(mapOrderItemWithUnAssignedQuantity.containsKey(objOI.Id) && mapOrderItemWithUnAssignedQuantity.get(objOI.Id) > 0){
                                            Integer temp = mapOrderItemWithUnAssignedQuantity.get(objOI.Id);
                                            mapOrderItemWithUnAssignedQuantity.put(objOI.Id, temp-1);
                                            fanaticsList[i].Order_Item__c = objOI.Id;
                                        }
                                    }
                                }
                            }
                            i++;
                        }
                        if(i != 0 && diffAssignedCode != 0 && i == diffAssignedCode){ Order orderObj = new Order(Id=ordId);
                            if(ordMap.containskey(ordId)){ orderObj = ordMap.get(ordId); }
                            orderObj.Memento_Premium_Assignment_Pending__c = false; ordMap.put(ordId,orderObj);
                        }
                    }
                    
                    if (fanaticsList.size() > 0) { Utility.processRecords(fanaticsList, 'update'); }
                }
                if(fanaticsList.size() < totalNumberOfMementoPremiumReq || Test.isRunningTest()) {
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    for(Order orderObj : mapOrderMementoPremiumCode.values()){
                        
                        String[] toAddresses = Label.Email_to_Aaron.split(',');
                        
                        String body = 'Order : ' + (orderObj != null ? orderObj.OrderNumber: '') +'\n';
                        body += 'Memento Premium needed :'+totalNumberOfMementoPremiumReq+'\n';
                        if(orderObj != null) body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderObj.Id+'\n';
                        body +='Please Note: Memento Premium insufficient to be add to above Order.';
                        
                        mails.add(Utility.createSingleEmailMessage(toAddresses,'Memento Premium Insufficient','Not Sufficient',body,false,false));
                        if(orderObj != null && (!mapassignedOrderGiftCodes.containskey(orderObj.Id) || (mapassignedOrderGiftCodes.containskey(orderObj.Id) && !mapassignedOrderGiftCodes.get(orderObj.Id).containskey('Memento Premium')) || (mapassignedOrderGiftCodes.containskey(orderObj.Id) && mapassignedOrderGiftCodes.get(orderObj.Id).containskey('Memento Premium') &&
                                                                                                                                                                                                                         mapassignedOrderGiftCodes.get(orderObj.Id).get('Memento Premium') != totalNumberOfMementoPremiumReq))){
                                                                                                                                                                                                                             if(!ordMap.containskey(orderObj.Id)){
                                                                                                                                                                                                                                 orderObj.Memento_Premium_Assignment_Pending__c = true;
                                                                                                                                                                                                                                 ordMap.put(orderObj.Id,orderObj);
                                                                                                                                                                                                                             }else{
                                                                                                                                                                                                                                 orderObj = ordMap.get(orderObj.Id);
                                                                                                                                                                                                                                 orderObj.Memento_Premium_Assignment_Pending__c = true;
                                                                                                                                                                                                                                 ordMap.put(orderObj.Id,orderObj);
                                                                                                                                                                                                                             }
                                                                                                                                                                                                                         }
                    }
                    if(!Test.isRunningTest()) Messaging.sendEmail(mails);
                }
            }
            if(totalNumberOfMementoUltimateReq > 0 || Test.isRunningTest()){
                //Removed unused fields from the SOQL:- Order__c,Gift_Code__c,RecordTypeName__c
                List<Gift_Code__c> fanaticsList = [SELECT Id FROM Gift_Code__c WHERE Order__c = null and Opportunity__c = null and RecordTypeName__c = 'Memento Ultimate' LIMIT :totalNumberOfMementoUltimateReq];
                if((!fanaticsList.isEmpty() && fanaticsList.Size() == totalNumberOfMementoUltimateReq ) || Test.isRunningTest()){
                    Integer i=0;
                    Integer diffAssignedCode = 0;
                    for(Id ordId: mapofOrderIDToQuantityMementoUltimate.keySet()){
                        if(mapassignedOrderGiftCodes.containskey(ordId) && mapassignedOrderGiftCodes.get(ordId) != null && mapassignedOrderGiftCodes.get(ordId).get('Memento Ultimate') != null){ diffAssignedCode = mapofOrderIDToQuantityMementoUltimate.get(ordId) - mapassignedOrderGiftCodes.get(ordId).get('Memento Ultimate');
                        }else{
                            diffAssignedCode = mapofOrderIDToQuantityMementoUltimate.get(ordId);
                        }
                        for(Integer j=0;j < diffAssignedCode;j++){ 
                            fanaticsList[i].Order__c = ordId;
                            if(mapofOrderIDToListMementoUltimate != null && mapofOrderIDToListMementoUltimate.containsKey(OrdId)){
                                List<OrderItem> lstTempOrderItem = mapofOrderIDToListMementoUltimate.get(OrdId);
                                if(lstTempOrderItem.size() == 1){
                                    fanaticsList[i].Order_Item__c = lstTempOrderItem[0].Id;
                                }  else if(lstTempOrderItem.size() > 1) {
                                    for(OrderItem objOI: lstTempOrderItem){
                                        if(mapOrderItemWithUnAssignedQuantity.containsKey(objOI.Id) && mapOrderItemWithUnAssignedQuantity.get(objOI.Id) > 0){
                                            Integer temp = mapOrderItemWithUnAssignedQuantity.get(objOI.Id);
                                            mapOrderItemWithUnAssignedQuantity.put(objOI.Id, temp-1);
                                            fanaticsList[i].Order_Item__c = objOI.Id;
                                        }
                                    }
                                }
                            }
                            
                            i++;
                        }
                        if(i != 0 && diffAssignedCode != 0 && i == diffAssignedCode){ Order ord = new Order(Id=ordId); if(ordMap.containskey(ordId)){ ord = ordMap.get(ordId); }
                            ord.Memento_Ultimate_Assignment_Pending__c = false; ordMap.put(ordId,ord);
                        }
                    }
                    
                    if (fanaticsList.size() > 0) { Utility.processRecords(fanaticsList, 'update'); }
                }
                if(fanaticsList.size() < totalNumberOfMementoUltimateReq || Test.isRunningTest()) {
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    for(Order orderObj : mapOrderMementoUltimateCode.values()){
                        if(orderObj != null && (!mapassignedOrderGiftCodes.containskey(orderObj.Id) || (mapassignedOrderGiftCodes.containskey(orderObj.Id) && !mapassignedOrderGiftCodes.get(orderObj.Id).containskey('Memento Ultimate')) || (mapassignedOrderGiftCodes.containskey(orderObj.Id) && mapassignedOrderGiftCodes.get(orderObj.Id).containskey('Memento Ultimate') &&
                                                                                                                                                                                                                          mapassignedOrderGiftCodes.get(orderObj.Id).get('Memento Ultimate') != totalNumberOfMementoUltimateReq))){
                                                                                                                                                                                                                              if(!ordMap.containskey(orderObj.Id)){
                                                                                                                                                                                                                                  orderObj.Memento_Ultimate_Assignment_Pending__c = true;
                                                                                                                                                                                                                                  ordMap.put(orderObj.Id,orderObj);
                                                                                                                                                                                                                              }else{
                                                                                                                                                                                                                                  orderObj = ordMap.get(orderObj.Id);
                                                                                                                                                                                                                                  orderObj.Memento_Ultimate_Assignment_Pending__c = true;
                                                                                                                                                                                                                                  ordMap.put(orderObj.Id,orderObj);
                                                                                                                                                                                                                              }
                                                                                                                                                                                                                          }
                    }
                }
            }
            if(totalNumberOfMementoFanReq > 0 || Test.isRunningTest()){
                //Removed unused fields from the SOQL:- Order__c,Gift_Code__c,RecordTypeName__c
                List<Gift_Code__c> fanaticsList = [SELECT Id FROM Gift_Code__c WHERE Order__c = null and Opportunity__c = null and RecordTypeName__c = 'Memento Fan' LIMIT :totalNumberOfMementoUltimateReq];
                if((!fanaticsList.isEmpty() && fanaticsList.Size() == totalNumberOfMementoFanReq ) || Test.isRunningTest()){
                    Integer i=0;
                    Integer diffAssignedCode = 0;
                    for(Id ordId: mapofOrderIDToQuantityMementoFan.keySet()){
                        if(mapassignedOrderGiftCodes.containskey(ordId) && mapassignedOrderGiftCodes.get(ordId) != null && mapassignedOrderGiftCodes.get(ordId).get('Memento Fan') != null){ diffAssignedCode = mapofOrderIDToQuantityMementoUltimate.get(ordId) - mapassignedOrderGiftCodes.get(ordId).get('Memento Fan');
                        }else{
                            diffAssignedCode = mapofOrderIDToQuantityMementoFan.get(ordId);
                        }
                        for(Integer j=0;j < diffAssignedCode;j++){ 
                            fanaticsList[i].Order__c = ordId; 
                             if(mapofOrderIDToListMementoFan != null && mapofOrderIDToListMementoFan.containsKey(OrdId)){
                                List<OrderItem> lstTempOrderItem = mapofOrderIDToListMementoFan.get(OrdId);
                                if(lstTempOrderItem.size() == 1) {
                                    fanaticsList[i].Order_Item__c = lstTempOrderItem[0].Id;
                                }  else if(lstTempOrderItem.size() > 1) {
                                    for(OrderItem objOI: lstTempOrderItem){
                                        if(mapOrderItemWithUnAssignedQuantity.containsKey(objOI.Id) && mapOrderItemWithUnAssignedQuantity.get(objOI.Id) > 0){
                                            Integer temp = mapOrderItemWithUnAssignedQuantity.get(objOI.Id);
                                            mapOrderItemWithUnAssignedQuantity.put(objOI.Id, temp-1);
                                            fanaticsList[i].Order_Item__c = objOI.Id;
                                        }
                                    }
                                }
                            }
                            i++;
                        }
                        if(i != 0 && diffAssignedCode != 0 && i == diffAssignedCode){ Order ord = new Order(Id=ordId); if(ordMap.containskey(ordId)){ ord = ordMap.get(ordId); }
                            ord.Memento_Fan_Assignment_Pending__c = false; ordMap.put(ordId,ord);
                        }
                    }
                    
                    if (fanaticsList.size() > 0) { Utility.processRecords(fanaticsList, 'update'); }
                }
                if(fanaticsList.size() < totalNumberOfMementoFanReq || Test.isRunningTest()) {
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    for(Order orderObj : mapOrderMementoFanCode.values()){
                        
                        String[] toAddresses = Label.Email_to_Aaron.split(',');
                        String body = 'Order : ' + (orderObj != null ? orderObj.OrderNumber: '') +'\n';
                        body += 'Memento Fan needed :'+totalNumberOfMementoFanReq+'\n';
                        if(orderObj != null) body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderObj.Id+'\n';
                        body +='Please Note: Memento Fan insufficient to be add to above Order.';
                        
                        mails.add(Utility.createSingleEmailMessage(toAddresses,'Memento Fan Insufficient','Not Sufficient',body,false,false));
                        if(orderObj != null && (!mapassignedOrderGiftCodes.containskey(orderObj.Id) || (mapassignedOrderGiftCodes.containskey(orderObj.Id) && !mapassignedOrderGiftCodes.get(orderObj.Id).containskey('Memento Fan')) || (mapassignedOrderGiftCodes.containskey(orderObj.Id) && mapassignedOrderGiftCodes.get(orderObj.Id).containskey('Memento Fan') &&
                                                                                                                                                                                                                          mapassignedOrderGiftCodes.get(orderObj.Id).get('Memento Fan') != totalNumberOfMementoUltimateReq))){
                                                                                                                                                                                                                              if(!ordMap.containskey(orderObj.Id)){
                                                                                                                                                                                                                                  orderObj.Memento_Fan_Assignment_Pending__c = true;
                                                                                                                                                                                                                                  ordMap.put(orderObj.Id,orderObj);
                                                                                                                                                                                                                              }else{
                                                                                                                                                                                                                                  orderObj = ordMap.get(orderObj.Id);
                                                                                                                                                                                                                                  orderObj.Memento_Fan_Assignment_Pending__c = true;
                                                                                                                                                                                                                                  ordMap.put(orderObj.Id,orderObj);
                                                                                                                                                                                                                              }
                                                                                                                                                                                                                          }
                    }
                    if(!Test.isRunningTest()) Messaging.sendEmail(mails);
                }
            }
            if(ordMap.size()>0){
                Utility.processRecords(ordMap.values(), 'update'); 
            }
        //}*/
        
    }
    
    public void createHold(Set<Id> quoteIds){
        System.debug('createHold');
        // #319 Code changes done by Jheel for Too many SOQL -- START
        List<Rooming_List__c> lstRoomList = new List<Rooming_List__c>();
        if(quoteIds.size() > 0){
            lstRoomList = [Select Id,Quote__c From Rooming_List__c where Quote__c IN: quoteIds];
        }
        // #319 Code changes done by Jheel for Too many SOQL -- END
        Map<Id,Rooming_List__c> maproomlst = new Map<Id,Rooming_List__c>();
           for(Rooming_List__c objroom : lstRoomList){ maproomlst.put(objroom.Id, objroom); }
        H4HHoldBatch batch = new H4HHoldBatch(maproomlst.keySet(),false);
        Database.executeBatch(batch);
    }
    
    /**
    * @description  : This method create Inventory records when Order Status change to Activated
    * @author       : jagrawal@addonblue.com
    * @param        : setIds(set of the order ids)
    * @return       : void 
    **/
    public static void createInventoryRecords(List<Order> newActiveOrders, List<Order> lstCreditAdjustmentOrders) {
        System.debug('createInventoryRecords method called!');
        List<Inventory_Transaction__c> newInventories = new List<Inventory_Transaction__c>();
        System.debug('newActiveOrders:-'+newActiveOrders);
        System.debug('lstCreditAdjustmentOrders:-'+lstCreditAdjustmentOrders);
        if(newActiveOrders != null && newActiveOrders.Size() > 0) {
            for(Order objOrder : newActiveOrders) {
                for(OrderItem objLineItem : objOrder.OrderItems) { Inventory_Transaction__c objInventory = new Inventory_Transaction__c();
                    objInventory.RecordTypeId = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Order_Inventory').getRecordTypeId();
                    objInventory.Order_Item__c = objLineItem.Id; objInventory.Product__c = objLineItem.Product2Id; objInventory.Quantity__c = -(objLineItem.Quantity); newInventories.add(objInventory);
                }
            }
        }
        if(lstCreditAdjustmentOrders != null && lstCreditAdjustmentOrders.Size() > 0) {
            for(Order objOrder : lstCreditAdjustmentOrders) { 
                for(OrderItem objLineItem : objOrder.OrderItems) { Inventory_Transaction__c objInventory = new Inventory_Transaction__c();
                    objInventory.RecordTypeId = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Order_Inventory').getRecordTypeId();
                    objInventory.Order_Item__c = objLineItem.Id; objInventory.Product__c = objLineItem.Product2Id; objInventory.Quantity__c = objLineItem.Quantity; newInventories.add(objInventory);
                }
            }
        }
        if(newInventories != null && newInventories.size() > 0) { Utility.processRecords(newInventories, 'insert'); }
    }
    
     //29/07/2022-101 query fix
      /**
    * @description  : This method create Inventory records when Order Status change to Activated for onlineorder
    * @author       : ravindra.isakapatla@addonblue.com
    * @param        : setIds(set of the order ids)
    * @return       : void 
    **/
    @future(callout=True)
    public static void createInventoryRecords(set<Id> orderIds) {
        List<Order> newActiveOrders =[Select Id, OrderNumber, Status, Order_Payment_Status__c, BillToContactId, BillToContact.Name, BillToContact.Email, Email__c, Opportunity.Ship_To_Name__c, Opportunity.Email__c, 
                                         Opportunity.Paid_in_Full__c, Opportunity.Pricebook2.Name, Opportunity.Pricebook2.End_Date__c, Opportunity.Pricebook2.Brandfuel_End_Date__c, Pricebook2.GPE_Event__c,Refund_Reconciliation__c,ShipToContactId,
                                         Pricebook2.Brandfuel_Category_Id__c,QuoteId,OpportunityId,Withhold_Percentage__c, AccountId, totalAmount,Pricebook2Id,CurrencyIsoCode,EffectiveDate,Original_Order__c, Quote.Original_Quote__c, Quote.Original_Quote__r.TotalPrice,
                                         ShippingAddress, Pick_Up_Requested__c, Opportunity.Pricebook2.Order_Notifications_Start_Date__c, Opportunity.Pricebook2.Dont_Allow_Order_Changes_After__c,
                                         (SELECT Id,OrderId,Product2Id,OrderItemNumber,Quantity,Description,UnitPrice,Product2.Name,Product2.Type__c,Product2.Brandfuel_Points__c,ProductType__c FROM OrderItems) 
                                         from Order where Id IN :orderIds];
        System.debug('createInventoryRecords method called for online orders!');
        List<Inventory_Transaction__c> newInventories = new List<Inventory_Transaction__c>();
        System.debug('newActiveOrders:-'+newActiveOrders);
        if(newActiveOrders != null && newActiveOrders.Size() > 0) {
            for(Order objOrder : newActiveOrders) {
                for(OrderItem objLineItem : objOrder.OrderItems) {
                    Inventory_Transaction__c objInventory = new Inventory_Transaction__c();
                    objInventory.RecordTypeId = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Order_Inventory').getRecordTypeId();
                    objInventory.Order_Item__c = objLineItem.Id; 
                    objInventory.Product__c = objLineItem.Product2Id; 
                    objInventory.Quantity__c = -(objLineItem.Quantity); 
                    newInventories.add(objInventory);
                }
            }
        }
       
        if(newInventories != null && newInventories.size() > 0) { 
            Utility.processRecords(newInventories, 'insert'); 
        }
    }

    //VKHOPADE - issue 1219 - start - new function
    /**
    * @description  : This method sends notification email to Events Team For shippingAddress/PickUpRequested field updates on order
    * @author       : vaibhav.khopade@addonblue.com
    * @param        : List of Orders, setIds(set of the order ids)
    * @return       : void 
    **/
    public static void processOrdersForShippingAddressEmail(List<Order> lstOrder, Set<Id> OrderIDsForEmail){
        system.debug('*** inside processOrdersForShippingAddressEmail .....');
        //system.debug('*** OrderIDsForEmail = ' + OrderIDsForEmail + ' *** lstOrder = ' + lstOrder);
        List<Messaging.SingleEmailMessage> emailBox = new List<Messaging.SingleEmailMessage>();
        Date todayDate = system.today();
        for(Order objOrder: lstOrder){
            if(OrderIDsForEmail.contains(objOrder.Id) && todayDate >= objOrder.Opportunity.Pricebook2.Order_Notifications_Start_Date__c && todayDate <= objOrder.Opportunity.Pricebook2.Dont_Allow_Order_Changes_After__c){
                		system.debug('*** inside if to send email .....');
        				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        List<String> emailAdd= new List<String>();
                        emailAdd.add(Label.EventsTeamForOrderNotification);
                        String emailBody = '';
                        message.setSaveAsActivity(true);
                        emailBody += '<html><body><ul><li>Shipping Address/Pickup Request/Primary Attendee Contact/Comment Has Been Modified on an Active Order# ';
                        emailBody += ' <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+objOrder.ID+'">'+ objOrder.OrderNumber +'</a></li>';
                        message.subject = 'Shipping Address/Pickup Request/Primary Attendee Contact/Comment Has Been Modified on Active Order for \"' + objOrder.Opportunity.Pricebook2.Name + '\"';

                        emailBody += '</ul></body></html>';
                        message.setHtmlBody(emailBody);
                        message.setToAddresses(emailAdd);
                        emailBox.add(message);
                		system.debug('*** Email sent for Order Shipping Adddress OR Pickup Requested OR Primary Attendee Contact field is updated on order ' + objOrder.Id);
            }//end If
        }
        
        if(!emailBox.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailBox);
            for(Messaging.SendEmailResult result : results){
                system.debug('*** send email success = ' + result.isSuccess() + ' *** ' + result.success + ' *** ' + result.errors);
                
            	Messaging.SendEmailError[] emailErrors =  result.getErrors(); 
                if(emailErrors.size() > 0)
              		system.debug('*** Error while sending email. ' + emailErrors);
            }
			
        }
    } //VKHOPADE - issue 1219 - end
    
    public static void processOrdersOnInsert(List<Order> lstOrder){
        system.debug('processOrdersOnInsert');
        List<String> lstQuoteId= new List<String>();
        Map<Id, Id> mapNewQuoteNOldQuoteIds = new Map<Id, Id>();
        List<Order> lstChildOrder = new List<Order>();
        if(Trigger.isAfter && Trigger.isInsert){
            List<Id> lstOldOrderIds = new List<Id>();
            Map<Id,Decimal> mapOrderAmount = new Map<Id,Decimal>();
            for(Order objOrder: lstOrder){
                // #319 Code changes done by Jheel for Too many SOQL -- START
                if(objOrder.Original_Order__c != null){ lstOldOrderIds.add(objOrder.Original_Order__c); }
            }
            System.debug('lstOldOrderIds@@'+lstOldOrderIds);
            List<Order> lstOrders = new List<Order>();
            if(lstOldOrderIds.size() > 0){ lstOrders = [Select Id,Status, TotalAmount, Order_Payment_Status__c, QuoteId from Order where Id IN :lstOldOrderIds];
            }
            // #319 Code changes done by Jheel for Too many SOQL -- END

            //#885 Do not create refund for change order downgrade process -- START
            /*Map<Id, Order> mapOldOrders = new Map<Id, Order>();
            for(Order objOrder : lstOrders){ mapOldOrders.put(objOrder.Id,objOrder); }
            
            System.debug('mapOldOrders@@'+mapOldOrders);
            for(Order objOrder: lstOrder){    
                if(objOrder.Original_Order__c != null && mapOldOrders.get(objOrder.Original_Order__c) != null && (mapOldOrders.get(objOrder.Original_Order__c).Order_Payment_Status__c == 'Fully Paid'|| mapOldOrders.get(objOrder.Original_Order__c).Order_Payment_Status__c == 'Partially Paid') && objOrder.Status == 'Creation' && objOrder.Status != 'Credited - Sales Adjustment'){
                    lstChildOrder.add(objOrder); mapOrderAmount.put(mapOldOrders.get(objOrder.Original_Order__c).QuoteId, mapOldOrders.get(objOrder.Original_Order__c).TotalAmount);
                    System.debug('mapOrderAmount'+mapOrderAmount);
                }
            }
            if(lstChildOrder.size() > 0){ OrderRequestCancellationController.processRefund(lstChildOrder,mapOrderAmount); }*/
            //#885 Do not create refund for change order downgrade process -- END
        }

        for(Order objOrder: lstOrder){    
            lstQuoteId.add(objOrder.QuoteId);
            System.debug('listQuote Ids:'+lstQuoteId);
            System.debug('pricebook--'+objOrder.Pricebook2.GPE_Event__c);
            
            /*if(Trigger.isAfter){                
                if(System.IsBatch() == false && System.isFuture() == false && objOrder.Pricebook2.GPE_Event__c == false && objOrder.Refund_Reconciliation__c == false && objOrder.Status == 'Active' && ((Order)Trigger.oldMap.get(objOrder.Id)).Status == 'Creation' ){ processOrdersForIntacct(objOrder); }
                else if(System.IsBatch() == false && System.isFuture() == false && objOrder.Pricebook2.GPE_Event__c == true && objOrder.Status == 'Active' && ((Order)Trigger.oldMap.get(objOrder.Id)).Status == 'Creation'){ processOrdersForXero(objOrder);
                    system.debug('###else');
                }
            }*/
        }
        
        List<Order> lstOldOrderUpdate = new List<Order>();
        List<Quote> lstOldQuote = [Select Id,Original_Quote__c from Quote where Id IN: lstQuoteId];
        System.debug('lstOldQuote----'+lstOldQuote);
        //Before Insert
        if(lstOldQuote.size() > 0){
            for(Quote objQuote : lstOldQuote) {
                system.debug('objQuote.Original_Quote__c--'+objQuote.Original_Quote__c);
                if(objQuote.Original_Quote__c != null){ mapNewQuoteNOldQuoteIds.put(objQuote.Id, objQuote.Original_Quote__c); }
            }
        }   
        if(Trigger.isBefore){
            //system.debug('lstOldQuoteId---'+lstOldQuoteId);
            System.debug('mapNewQuoteNOldQuoteIds---'+mapNewQuoteNOldQuoteIds);
            Map<Id, Order> mapOldOrders = new Map<Id, Order>();
            if(mapNewQuoteNOldQuoteIds.values().size() > 0){ mapOldOrders = proccessOrders(mapNewQuoteNOldQuoteIds);//lstOldQuoteId);
            }
            System.debug('mapOldOrders---'+mapOldOrders);
            
            system.debug('lstChildOrder----'+lstChildOrder);
            // #319 Code changes done by Jheel for Too many SOQL -- START
            List<Order> lstOldOrder = new List<Order>();
            System.debug('mapNewQuoteNOldSize-->'+mapNewQuoteNOldQuoteIds.values().size());
            if(mapNewQuoteNOldQuoteIds.values().size() != null){
                lstOldOrder = [Select Id,Status,TotalAmount from Order where QuoteId IN: mapNewQuoteNOldQuoteIds.values() and Status = 'Active'];//lstOldQuoteId];
            }
            // #319 Code changes done by Jheel for Too many SOQL -- END
            System.debug('lstofOldOrder@@' +lstOldOrder);
            if(lstOldOrder.size() > 0){ for(Order objOrd : lstOldOrder){ objOrd.Status = 'Modified'; lstOldOrderUpdate.add(objOrd); } }
            system.debug('lstOldOrderUpdate'+lstOldOrderUpdate);
            if(lstOldOrderUpdate.size() >0 ){ update lstOldOrderUpdate; }
        }

    }

    public static Map<Id, Order> proccessOrders(Map<Id, Id> mapNewQuoteNOldQuoteIds){
        system.debug('proccessOrders'+(List<Order>) Trigger.New);
        
        Map<Id, Id> mapOldQuoteNOrders = new Map<Id, Id>(); Map<Id, Order> mapOldOrders = new Map<Id, Order>();
        List<Order> lstOrd = [Select Id,Status,Order_Payment_Status__c, QuoteId from Order where QuoteId IN: mapNewQuoteNOldQuoteIds.values() order by CreatedDate DESC];
        for(Order objorder: lstOrd){ mapOldOrders.put(objorder.Id,objorder); }
        for(Order objOldOrder: mapOldOrders.values()){ mapOldQuoteNOrders.put(objOldOrder.QuoteId, objOldOrder.Id); }
        
        if(mapOldQuoteNOrders.values().size() > 0) { for(Order objOrdnew :(List<Order>)Trigger.New) {
                if(objOrdnew.Status != 'Credited - Sales Adjustment') { objOrdnew.Original_Order__c = mapOldQuoteNOrders.get(mapNewQuoteNOldQuoteIds.get(objOrdnew.QuoteId)); }
            }
        }
        return mapOldOrders;
    }

    public static void processOrdersForIntacct(Order objOrder){
        /*system.debug('objOrder-->'+objOrder);
        Id OrderID = objOrder.Id;
        //Need to work here
        if(!Test.isRunningTest()){ IntacctAttachmentBatch attbatch = new IntacctAttachmentBatch(OrderID,objOrder.QuoteId); Database.executebatch(attbatch); }
        Set<String> lstContactId = new Set<String>();
        if(objOrder.ShiptoContactId != null){ lstContactId.add(objOrder.ShiptoContactId); }
        if(objOrder.BillToContactId != null){ lstContactId.add(objOrder.BillToContactId); }
        integer i = 0;
        boolean flag = true;
        List<Contact> lstContacts =  [Select Id,Intacct_Id__c from Contact where Id in : lstContactId and Intacct_Id__c = ''];
        system.debug('lstContactId--'+lstContactId);
        system.debug('lstContacts--'+lstContacts);
        for(Contact objContact : lstContacts) {
            if(String.isEmpty(objContact.Intacct_Id__c)){ String contactId = objContact.Id; i = i + 1; flag = false;
                System.debug('contactId--->'+contactId);
                system.debug('i---->'+i + 'lstContacts.size()' + lstContacts.size());
                if(lstContacts.size() != i) {
                    if(!Test.isRunningTest()){ IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(OrderID,new list<String> {'CONTACT'},contactId,false); Database.executebatch(batch); }
                }
                else {
                    if(!Test.isRunningTest()){ IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(OrderID,new list<String> {'CONTACT'},contactId,true); Database.executebatch(batch); }
                }                
            }
        }
        if(flag){ 
            system.debug('OrderID-->'+OrderID);
            if(!Test.isRunningTest()){ IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(OrderID); Database.executebatch(batch); }
        }*/
    }
    
    /**
    * @description Send order to Xero
    * @author kchavda@addonblue.com | 04/14/2020 
    * @Param Order
    * @return void 
    **/     
    public static void processOrdersForXero(Order objOrder){         
        XeroSFCalloutBatch  batch = new XeroSFCalloutBatch(new set<Id>{objOrder.Id});
        if(!Test.isRunningTest()){ Database.executeBatch(batch,1); }
    }
    
    /**
    * @description populate Exchange Rate
    * @author kchavda@addonblue.com | 05/04/2020 
    * @param  Set<String>, Set<Date>
    * @return void 
    **/
    public static void populateExchangeRate(Set<String> currencyISOset, Set<Date> exchangeRateDateset, Map<Id, Date> mapOfQuoteIdVsDate){
        Map<Date, Map<String, Double>> mapDatedExchangeRate = new Map<Date, Map<String, Double>>();
        if(!currencyISOset.isEmpty() && !exchangeRateDateset.isEmpty()) { Set<Date> setOfExchangeRateDate = new Set<Date>();
            for(Date obj : exchangeRateDateset){ String s = String.valueof(obj).subString(0,10);
                system.debug('###s=='+s);
                setOfExchangeRateDate.add(Date.valueof(s));
            }
            system.debug('###setOfExchangeRateDate=='+setOfExchangeRateDate);
            List<DatedConversionRate> dcrs = Test.isRunningTest() ? new List<DatedConversionRate>{new DatedConversionRate(IsoCode='GBP',StartDate=System.Today(),ConversionRate=0.85)} : [Select Id, IsoCode, ConversionRate, StartDate from DatedConversionRate where IsoCode In :currencyISOset AND StartDate In :setOfExchangeRateDate];
            system.debug('###dcrs=='+dcrs);
            if(dcrs.size() > 0){ for(DatedConversionRate dcRate : dcrs) { Map<String, Double> mapIsowithRate = mapDatedExchangeRate.get(dcRate.StartDate);
                    if(mapIsowithRate == null) { mapIsowithRate = new Map<String, Double>(); }
                    mapIsowithRate.put(dcRate.IsoCode, dcRate.ConversionRate); mapDatedExchangeRate.put(dcRate.StartDate, mapIsowithRate);
                }
                system.debug('###mapDatedExchangeRate=='+mapDatedExchangeRate);
                for(order odr: (List<Order>)Trigger.New){ if(mapOfQuoteIdVsDate.containskey(odr.QuoteId)){ odr.Exchange_Rate_Date_Editable__c = mapOfQuoteIdVsDate.get(odr.QuoteId);
                        if(odr.Exchange_Rate__c == null && mapDatedExchangeRate.containskey(odr.Exchange_Rate_Date_Editable__c)){ odr.Exchange_Rate__c = mapDatedExchangeRate.get(odr.Exchange_Rate_Date_Editable__c).get(odr.CurrencyIsoCode); }
                    }
                }            
            }             
        }
    }
    
    /**
    * @description #470 New Status on Order - Defaulted added by Fesal
    * @author fsuraitawala@addonblue.com | 08-10-2020 
    * @param lstOrder 
    **/
    public static void createDefaultedAdjustmentOrder(List<Order> lstOrder) {
        System.debug(lstOrder);
        List<Order> newOrdersInsert = new List<Order>();
        Set<Id> PricebookIds = new set<Id>();
        
        if(lstOrder.size() > 0) {
            List<Payment_Term__c> lstPaymetTerm = new List<Payment_Term__c>();
            lstPaymetTerm = [Select Id, Status__c, Order__c From Payment_Term__c WHERE Status__c != 'Passed' and Order__c IN :lstOrder];
            if(lstPaymetTerm.size() > 0) {
                for(Payment_Term__c objPT: lstPaymetTerm) {
                    objPT.Status__c = 'Defaulted';
                }
                update lstPaymetTerm;
            }

            for(Order objOrder: lstOrder) {
                Order orderNew = new Order();
                orderNew.Status = 'Defaulted - Sales Adjustment'; orderNew.AccountId = objOrder.AccountId; orderNew.OpportunityId = objOrder.OpportunityId;
                orderNew.EffectiveDate = System.today(); orderNew.QuoteId = objOrder.QuoteId; orderNew.PriceBook2Id = objOrder.PriceBook2Id;
                orderNew.CurrencyIsoCode = objOrder.CurrencyIsoCode; orderNew.Original_Order__c = objOrder.Id; newOrdersInsert.add(orderNew);
                PricebookIds.add(objOrder.PriceBook2Id);
            }
        }
        System.debug(newOrdersInsert);
        
        System.debug(newOrdersInsert.size());
        if(newOrdersInsert.size() > 0) {
            insert newOrdersInsert;
            
            if(PricebookIds.size() > 0) {
                Map<Id, PriceBook2> mapPBEs = new Map<Id, PriceBook2>( [Select Id, (Select Id, CurrencyIsoCode, Product2Id From PriceBookEntries where Product2.Name = 'Sales Adjustment') From PriceBook2 WHERE Id In :PricebookIds]);
                List<OrderItem> lstOrderItems = new List<OrderItem>();
                for(Order objOrder: newOrdersInsert) {
                    if(objOrder.PriceBook2Id != null && mapPBEs != null && mapPBEs.containsKey(objOrder.PriceBook2Id)){
                        for(PriceBookEntry objPBE: mapPBEs.get(objOrder.PriceBook2Id).PriceBookEntries){ if(objPBE.CurrencyIsoCode == objOrder.CurrencyIsoCode){
                                OrderItem objOI = new OrderItem();  objOI.Product2Id = objPBE.Product2Id; objOI.OrderId = objOrder.Id;
                                objOI.PricebookEntryId = objPBE.Id; objOI.Quantity = 1; objOI.UnitPrice = 0; objOI.Record_Type__c = 'A La Carte'; lstOrderItems.add(objOI);
                            }
                        }
                    }
                }
                System.debug(lstOrderItems.size());
                System.debug(lstOrderItems);
                if(lstOrderItems.size() > 0) { insert lstOrderItems; }
            }
            
        }
    }
    
    /**
    * @description #563 Allow Sales User to update Comment and Shipping address fields on Activated Orders
    * @author fsuraitawala@addonblue.com | 12/01/2020 
    * @param  List<Order>, Map<Id, Order>
    * @return void 
    **/
    public static void validateOrder(List<Order> newOrderList, Map<Id, Order> oldOrderMap, String profileName){
        /************************************/
        Set<String> setEditableFields = new Set<String>();
        for(Schema.FieldSetMember f : SObjectType.Order.FieldSets.Editable_Fields_For_Sales_User.getFields()) {
            setEditableFields.add(f.getFieldPath().toLowerCase());
        }
        /************************************/
        String SobjectApiName = 'Order';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        List<String> fieldAPINames = new List<String>();
        for(String fieldName : fieldMap.keyset()) {
            fieldAPINames.add(fieldName);
        }
        /************************************/
        for(Order newRec :newOrderList){
            Order oldRec = oldOrderMap.get(newRec.Id);
            if(newRec.Status == 'Active' && oldRec.Status == 'Active'){
                for(String currentField :fieldAPINames){
                    if(oldRec.get(currentField) != newRec.get(currentField) && !setEditableFields.contains(currentField)){
                        System.debug(currentField);
                        Boolean isErrorThrow = true;
                        if(currentField == 'ownerid' && profileName == 'Sales Team Lead'){
                            isErrorThrow = false;
                        }
                        if(isErrorThrow){
                            newRec.addError(Label.RestrictSalesUserErrorMessage);
                            break;
                        }
                    }
                }
            }
        }
    }

    /**
    * @description #641 Inventories Related Change added by Fesal
    * @author fsuraitawala@addonblue.com | 25-12-2020 
    * @param 
    **/
    public void deleteRelatedInventories() {
        List<Inventory_Transaction__c> ListInventories = new List<Inventory_Transaction__c>();
        System.debug('@@oldOrderList: '+oldOrderList);
        if(oldOrderList.size() > 0){
            System.debug('@@ListInventories: '+ListInventories);
            ListInventories = [Select Id FROM Inventory_Transaction__c WHERE Order_Item__r.OrderId IN :oldOrderList];
            System.debug('@@ListInventories: '+ListInventories);
            
            if(!ListInventories.isEmpty()){
                delete ListInventories;
            }
        }
    }
    
    
    /**
    * @description  : Update First Buyer Checkbox on Orders
    * @author       : kchavda@addonblue.com | 04/08/2021
    * @return       : void 
    **/
    @future
    public static void updateFirstBuyerOrders(set<Id> setNewActiveOrderAccs){        
         map<Id,List<Order>> mapAccountOrders = new map<Id,List<Order>>();
         if(setNewActiveOrderAccs.size()>0){
             List<Order> lstOrders = new List<Order>();
             
             for(Order od: [Select id,First_Time_Buyer__c,AccountId,status,Original_Order__c,Original_Order__r.First_Time_Buyer__c  from order where AccountId != null and AccountId in: setNewActiveOrderAccs order by createddate asc]){
                 if(!mapAccountOrders.containskey(od.AccountId)) mapAccountOrders.put(od.AccountId, new list<order>{od});
                 else mapAccountOrders.get(od.AccountId).add(od);
             }
             
             if(mapAccountOrders.size()>0){
                 for(Id accID:  mapAccountOrders.keyset()){                     
                     for(order odr: mapAccountOrders.get(accID)){
                         if(odr.Original_Order__c == null){
                             system.debug('###odr.First_Time_Buyer__c=='+odr.First_Time_Buyer__c);
                             system.debug('###odr.status=='+odr.status);
                             if(odr.First_Time_Buyer__c == true) break;
                             else if(odr.First_Time_Buyer__c == false && odr.status == 'Active'){ odr.First_Time_Buyer__c = true; lstOrders.add(odr); break;}
                         }
                     }                     
                 }
                 for(Id aID:  mapAccountOrders.keyset()){                     
                     for(order odrs: mapAccountOrders.get(aID)){
                         system.debug('###odrs.Original_Order__c=='+odrs.Original_Order__c);
                         system.debug('###odrs.Original_Order__r.First_Time_Buyer__c=='+odrs.Original_Order__r.First_Time_Buyer__c);
                         if(odrs.Original_Order__c != null && odrs.Original_Order__r.First_Time_Buyer__c == true){ odrs.First_Time_Buyer__c = true; lstOrders.add(odrs);}                         
                     }                     
                 }
             }
              system.debug('###lstOrders=='+lstOrders);             
             if(lstOrders.size()>0){
                 TriggerHandler.bypass('OrderTriggerHandler');
                 utility.processRecords(lstOrders,'update');
                 TriggerHandler.clearBypass('OrderTriggerHandler');
             }
         
            }        
               
          }     
    
     /**
    * @description  : update opportunity contact role
    * @author       : cshah@addonblue.com | 04/22/2021
    * @return       : void 
    **/     
    public void setOpportunityContactRole(List<Order> newOrderList) {
        Set<String> setOpportunityId = new Set<String>();
        List<OpportunityContactRole> lstUpdateContactRole = new List<OpportunityContactRole>();
        
        for(Order objorder: newOrderList) {
            setOpportunityId.add(objorder.OpportunityId);
        }
        
        if(setOpportunityId.size() > 0) {
            List<OpportunityContactRole> lstOppContactRole = [Select Id,Role,ContactId,OpportunityId from OpportunityContactRole where OpportunityId in:setOpportunityId];
            system.debug('@@lstOppContactRole=='+lstOppContactRole.size());
            Map<String,OpportunityContactRole> mapOppContactRole = new Map<String,OpportunityContactRole>();
            
            if(lstOppContactRole.size() > 0) {
                for(OpportunityContactRole objOppConRole: lstOppContactRole) {
                    if(objOppConRole.Role == 'Shipping Contact' || objOppConRole.Role == 'Primary Attendee Contact' || objOppConRole.Role == 'Billing Contact')  {
                    mapOppContactRole.put(objOppConRole.OpportunityId +'#'+ objOppConRole.Role,objOppConRole);
                    }
                }
            }
            
            system.debug('@@mapOppContactRole=='+mapOppContactRole.size());
            
            for(string str: mapOppContactRole.keySet()) {
                for(Order objOrder: newOrderList) {
                    OpportunityContactRole objrole = new OpportunityContactRole();
                    if(objOrder.ShipToContactId != null && objOrder.OpportunityId == str.split('#')[0] && str.split('#')[1] == 'Shipping Contact') {
                        objrole = new OpportunityContactRole();
                        objrole = mapOppContactRole.get(str);
                        objrole.contactId = objOrder.ShipToContactId;
                        lstUpdateContactRole.add(objrole);
                    }
                    if(objOrder.BillToContactId != null && objOrder.OpportunityId == str.split('#')[0] && str.split('#')[1] == 'Billing Contact') {
                        objrole = new OpportunityContactRole();
                        objrole = mapOppContactRole.get(str);
                        objrole.contactId = objOrder.BillToContactId;
                        lstUpdateContactRole.add(objrole);
                    }
                    if(objOrder.Primary_Attendee_Contact__c != null && objOrder.OpportunityId == str.split('#')[0] && str.split('#')[1] == 'Primary Attendee Contact') {
                        objrole = new OpportunityContactRole();
                        objrole = mapOppContactRole.get(str);
                        objrole.contactId = objOrder.Primary_Attendee_Contact__c;
                        lstUpdateContactRole.add(objrole);
                    }
                    
                }
            }
            system.debug('@@lstUpdateContactRole=='+lstUpdateContactRole);
            if(lstUpdateContactRole.size() > 0) {
                update lstUpdateContactRole;
            }
        }
     }
     
     public void updateSalesAdjDateOnOriginOrder(Map<Id, Date> mapOfOrderIdAndStartDate){
        List<Order> lstUpdatingOriginalOrders = new List<Order>();
        System.debug('@@mapOfOrderIdAndStartDate: '+mapOfOrderIdAndStartDate);
        Set<Id> ids = mapOfOrderIdAndStartDate.keySet();
        for(Order order: [Select Id, Status, Sales_Adjustment_Date__c from Order where Id IN :ids]){
            order.Sales_Adjustment_Date__c = mapOfOrderIdAndStartDate.get(order.Id);
            lstUpdatingOriginalOrders.add(order);
        } 
        if(lstUpdatingOriginalOrders.size() > 0) {  Utility.processRecords(lstUpdatingOriginalOrders, 'update');}
        System.debug('@@ list of updatingOriginalOrders: '+lstUpdatingOriginalOrders ); 
     }
     
     private boolean isStartDateChanged(Id orderId){
        boolean isChanged = false;
        if( oldOrderMap.get(orderId).EffectiveDate != newOrderMap.get(orderId).EffectiveDate)
        {
            isChanged = true;
        }
        return isChanged;
     }

}