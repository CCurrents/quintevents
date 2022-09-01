global class createOrderOpportunity implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, CloseDate, OwnerId, Owner.isActive, Event__c, Event__r.Price_Book_Event__c, AccountId, (select Id, Name, Pricebook2Id FROM Quotes), Approver_Name__c, AR_Notes__c, Awaiting_Approval_From__c,'+
                                        ' Brandfuel_Customer_Link__c, Brandfuel_End_Date__c, Cancellation_Reasons_For_Review_Oper__c, Comment__c, '+
                                        'Contact_Site__c, Days_Since_First_Late_Payment_Date__c, Delivery_Method__c, Exchange_rate__c, Exchange_Rate_Date__c,'+
                                        ' F1_Access_Code_Assignment_Pending__c, Fanatics_Gift_Code_Assignment_Pending__c, First_Late_Payment_Date__c, '+
                                        'GPE_Event_Name__c, GPE_Order_Id__c, GPT_Booking_Id__c, Intacct_Employee_Id__c, '+
                                        'Intacct_Id__c, Intacct_Record_URL__c, Intacct_Status__c, International_Stripe__c, Location_Id__c, '+
                                        'Memento_Premium_Assignment_Pending__c, Memento_Ultimate_Assignment_Pending__c, No_Show_No_Pickup__c, '+
                                        'Online_Order__c, Ops_Notes_and_Comments__c, Order_Payment_Status__c, Payment_Method__c, PO_Number__c, '+
                                        'Promoter__c, Reason_For_Cancellation__c, Record_Id__c, Reseller__c, SA_API_Order__c, Site__c, Discount_Code__c, '+
                                        'Subject_to_Cancellation__c, Tracking_Number__c, Xero_Reference_No__c, Date_Shipped__c, Fulfillment_Notes__c, '+
                                        'Billing_City__c, Billing_Country__c, Billing_State_Province__c, Billing_Street__c, Billing_Zip_Postal_Code__c,'+
                                        'Bill_To_Name__c, Shipping_City__c, Shipping_Country__c, Shipping_State_Province__c, '+
                                        'Shipping_Street__c, Shipping_Zip_Postal_Code__c, Ship_To_Name__c, Client_Event_Change_Preference__c, '+
                                        '(Select Id FROM Orders)'+
                                        'FROM Opportunity Where StageName = \'Canceled\' AND PriceBook2.Name = \'Standard Price Book\''); // GPE_Online_Order__c,
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity > scope){
        List<Order> lstOrder = new List<Order>();
        for(Opportunity objOpp : scope) {
            if(objOpp.Orders.size() <= 0 ){
                Order objOrder = new Order();
                if(objOpp.Quotes.size() > 0) {
                    objOrder.QuoteId = objOpp.Quotes[0].Id;
                    objOrder.PriceBook2Id = objOpp.Quotes[0].PriceBook2Id;
                }
                if(objOpp.Event__c != null && objOpp.Event__r.Price_Book_Event__c != null){
                    objOrder.Pricebook_Reporting__c = objOpp.Event__r.Price_Book_Event__c;
                }
                objOrder.AccountId = objOpp.AccountId;
                objOrder.Status = 'Canceled';
                objOrder.OpportunityId = objOpp.Id;
                if(objOpp.Owner.isActive) {
                    objOrder.OwnerId = objOpp.OwnerId;
                } else {
                    objOrder.OwnerId = '005i0000001u1PAAAY';
                }
                objOrder.Name = objOpp.Name.length() > 80 ? objOpp.Name.substring(0, 80) : objOpp.Name;
                
                objOrder.EffectiveDate = objOpp.Closedate;
                objOrder.Approver_Name__c = objOpp.Approver_Name__c;
                objOrder.AR_Notes__c = objOpp.AR_Notes__c;
                objOrder.Awaiting_Approval_From__c = objOpp.Awaiting_Approval_From__c;
                objOrder.Brandfuel_Customer_Link__c = objOpp.Brandfuel_Customer_Link__c;
                //objOrder.Brandfuel_End_Date__c = objOpp.Brandfuel_End_Date__c;
                objOrder.Cancellation_Reasons_For_Review_Oper__c = objOpp.Cancellation_Reasons_For_Review_Oper__c;
                objOrder.Comment__c = objOpp.Comment__c;
                //objOrder.Contact_Site__c = objOpp.Contact_Site__c;
                //objOrder.Days_Since_First_Late_Payment_Date__c = objOpp.Days_Since_First_Late_Payment_Date__c;
                objOrder.Exchange_Rate__c = objOpp.Exchange_Rate__c;
                //objOrder.Exchange_Rate_Date__c = objOpp.Exchange_Rate_Date__c;
                objOrder.F1_Access_Code_Assignment_Pending__c = objOpp.F1_Access_Code_Assignment_Pending__c;
                objOrder.Fanatics_Gift_Code_Assignment_Pending__c = objOpp.Fanatics_Gift_Code_Assignment_Pending__c;
                objOrder.GPE_Event_Name__c = objOpp.GPE_Event_Name__c;
                //objOrder.GPE_Online_Order__c = objOpp.GPE_Online_Order__c;
                objOrder.GPE_Order_Id__c = objOpp.GPE_Order_Id__c;
                objOrder.GPT_Booking_Id__c = objOpp.GPT_Booking_Id__c;
                //objOrder.Intacct_Employee_Id__c = objOpp.Intacct_Employee_Id__c;
                objOrder.Intacct_Id__c = objOpp.Intacct_Id__c;
                objOrder.Intacct_Record_URL__c = objOpp.Intacct_Record_URL__c;
                objOrder.Intacct_Status__c = objOpp.Intacct_Status__c;
                //objOrder.International_Stripe__c = objOpp.International_Stripe__c;
                //objOrder.Location_Id__c = objOpp.Location_Id__c;
                objOrder.Memento_Premium_Assignment_Pending__c = objOpp.Memento_Premium_Assignment_Pending__c;
                objOrder.Memento_Ultimate_Assignment_Pending__c = objOpp.Memento_Ultimate_Assignment_Pending__c;
                objOrder.No_Show_No_Pickup__c = objOpp.No_Show_No_Pickup__c;
                objOrder.Online_Order__c = objOpp.Online_Order__c;
                objOrder.Ops_Notes_and_Comments__c = objOpp.Ops_Notes_and_Comments__c;
                objOrder.Order_Payment_Status__c = objOpp.Order_Payment_Status__c;
                objOrder.PO_Number__c = objOpp.PO_Number__c;
                //objOrder.Promoter__c = objOpp.Promoter__c;
                objOrder.Reason_For_Cancellation__c = objOpp.Reason_For_Cancellation__c;
                objOrder.Record_Id__c = objOpp.Record_Id__c;
                //objOrder.Reseller__c = objOpp.Reseller__c;
                objOrder.SA_API_Order__c = objOpp.SA_API_Order__c;
                objOrder.Site__c = objOpp.Site__c;
                objOrder.Subject_to_Cancellation__c = objOpp.Subject_to_Cancellation__c;
                objOrder.Tracking_Number__c = objOpp.Tracking_Number__c;
                objOrder.Xero_Reference_No__c = objOpp.Xero_Reference_No__c;
                objOrder.Date_Shipped__c = objOpp.Date_Shipped__c;
                objOrder.Fulfillment_Notes__c = objOpp.Fulfillment_Notes__c;
                objOrder.Discount_Code__c = objOpp.Discount_Code__c;
                objOrder.BillingCity = objOpp.Billing_City__c;
                objOrder.BillingCountry = objOpp.Billing_Country__c;
                objOrder.BillingState = objOpp.Billing_State_Province__c;
                objOrder.BillingStreet = objOpp.Billing_Street__c;
                objOrder.BillingPostalCode = objOpp.Billing_Zip_Postal_Code__c;
                //objOrder.Bill_To_Name__c = ;
                objOrder.ShippingCity = objOpp.Shipping_City__c;
                objOrder.ShippingCountry = objOpp.Shipping_Country__c;
                objOrder.ShippingState = objOpp.Shipping_State_Province__c;
                objOrder.ShippingStreet = objOpp.Shipping_Street__c;
                objOrder.ShippingPostalCode = objOpp.Shipping_Zip_Postal_Code__c;
                objOrder.Ship_To_Name__c = objOpp.Ship_To_Name__c;
                objOrder.Client_Event_Change_Preference__c = objOpp.Client_Event_Change_Preference__c;
                
                lstOrder.add(objOrder);
            }
        }
        
        Database.SaveResult[] srList = Database.insert(lstOrder, false);
        Integer i = 0;
        List<Failed_Record__c> lstFailedOpportunity = new List<Failed_Record__c>();
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted opportunity OppoID: ' + sr.getId());
            } else {
                String ErrorMessage = '';
                
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                    System.debug('@@err: ' + err);
                    
                    ErrorMessage = ErrorMessage + ' --> ' + err.getMessage();
                }
                
                lstFailedOpportunity.add( new Failed_Record__c( Opportunity_Id__c = lstOrder.get(i).OpportunityId, Error_Message__c = ErrorMessage));
            }
            
            i++;
        }
        
        if(lstFailedOpportunity != null && lstFailedOpportunity.size() > 0) {
            insert lstFailedOpportunity;
        }
    
    }    
    global void finish(Database.BatchableContext bc) {
        System.debug('Records processed. Shazam!');
    }    
}