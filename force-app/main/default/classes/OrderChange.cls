/**
* @File Name          : QE360V3_OrderChange.cls
* @Description        : 
* @Author             : jagrawal@addonblue.com
* @Group              : 
* @Last Modified By   : fsuraitawala@addonblue.com
* @Last Modified On   : 10-01-2021
* @Modification Log   : 
* Ver       Date            Author                  Modification
* 1.0    2/28/2020   lpanchal@addonblue.com     Initial Version
* 1.1    7/16/2020   jagrawal@addonblue.com     Added code for checking PB status on Order before Change order
* 1.2    7/30/2020   jagrawal@addonblue.com     #463 Added code to make Quote Owner same as Opportunity Owner
* 1.3    9/16/2020   fsuraitawala@addonblue.com #541 Added code to link Hotel Stay and Transportation Product with Hotel
* 1.4    9/24/2020   fsuraitawala@addonblue.com #545 Order change
* 1.5    2/01/2020   fsuraitawala@addonblue.com #731 Extra Rooming List records related to change orders
* 1.6    3/05/2021   fsuraitawala@addonblue.com #839 change order issue
* 1.6    04/22/2021  kchavda@addonblue.com      #925 "Commission Paid" checkbox field on Payment Term
* 1.7    4/21/2021   cshah@addonblue.com        #922 Change Order - Copy certain field values from active order
* 1.8   06/16/2021   fsuraitawala@addonblue.com #992 - Allow change orders for orders that were originally just a deposit orders
**/
public with sharing class OrderChange {
    /**
    * @description 
    * @author lpanchal@addonblue.com | 2/28/2020 
    * @param String currentRecordId 
    * @param List<Payment_Term__c> lstterms 
    * @param String check 
    * @return string 
    **/
    @AuraEnabled
    public static string createQuotePaymentTerms(String currentRecordId, String check,String checkForHoldRes){
        String strQuoteId='';
        String AccountId ='';
        try{
            //List<String> lstPTIds = new List<String>();
            if(currentRecordId != null){

                Order objOrder = [Select QuoteId,Id,OpportunityId,ShipToContactId,ShipToContact.Name,ShippingAddress,Seating_Request__c,Comment__c,
                                   Ops_Notes_and_Comments__c,Fulfillment_Notes__c,Pick_Up_Requested__c,Ops_Order_Status__c,
                                   Primary_Attendee_Contact__c,ShippingCountry, ShippingCountryCode,ShippingStreet,ShippingCity,ShippingState,ShippingStateCode, ShippingPostalCode,BillToContactId
                                   from Order where Id =: currentRecordId];

                // #922 - change order v6
                //#929 Copy all fields of Quote to change Order Quote -- START
                String originalQuoteId = objOrder.QuoteId;
                String strOpportunityId = objOrder.OpportunityId;
                
                Map<String, Schema.SObjectField> fieldMap = Quote.sObjectType.getDescribe().fields.getMap();
                Set<String> setFieldName = new Set<String> {'ownerid', 'isdeleted', 'currencyisocode', 'recordtypeid', 'createddate', 'createdbyid', 'lastmodifieddate', 'lastmodifiedbyid', 'systemmodstamp', 'lastvieweddate', 'lastreferenceddate'};
                List<String> fieldNames = new List<String>();
                for(String strFieldName : fieldMap.keySet()){
                    if(!setFieldName.contains(strFieldName)) {
                        fieldNames.add(strFieldName);
                    }
                }
                Quote objQuote = Database.query('SELECT ' + string.join(fieldNames, ', ') + ', Opportunity.OwnerId ' + ' FROM Quote WHERE Id =: originalQuoteId LIMIT 1');
                //#929 Copy all fields of Quote to change Order Quote -- END
                AccountId = objQuote.AccountId;
                Map<Id, Payment_Term__c> mappaymentTerms = new Map<Id, Payment_Term__c>([Select RecordTypeId,Commission_Paid__c,Initial_Payment_Term__c, Opportunity__c, Status__c, Payment_Term__c, Payment_Method__c, Amount__c, Percentage_Of_Payment__c, Payment_Due_Date__c, Charge_Date__c, Exchange_Rate_Date__c, CurrencyIsoCode, Credit__c FROM Payment_Term__c WHERE Quote__c = :objOrder.QuoteId]);
                if(Test.isRunningTest()){
                    mappaymentTerms = new Map<Id,Payment_Term__c>([Select Opportunity__c, Commission_Paid__c, Initial_Payment_Term__c, Status__c,Payment_Term__c,Payment_Method__c,Amount__c,Percentage_Of_Payment__c, Payment_Due_Date__c, Charge_Date__c, Exchange_Rate_Date__c, CurrencyIsoCode, Credit__c from Payment_Term__c]);
                }
                
                List<Charge__c> lstOldcharges = [Select Amount__c, Account__c, Status__c, RecordTypeId, Payment_Terms__c, Credit_Used__c 
                                                 FROM Charge__c WHERE (Order__c = :currentRecordId OR Payment_Terms__c IN :mappaymentTerms.keyset())];
                ///clone Quote
                Quote quotedata = new Quote();
                quotedata = objQuote;
                // #463 Added OwnerId Field of Opportunity to populate on new quote
                quotedata.OwnerId = objQuote.Opportunity.OwnerId;
                quotedata.Id = null;
                quotedata.Status = 'Draft';
                quotedata.Original_Quote__c = objOrder.QuoteId;
                quotedata.Comment__c = objOrder.Comment__c;
                //#1016 Do not copy Purchase date on change order Quote
                quotedata.Purchase_Date__c = null;

                //#922 change - START
                quotedata.Ops_Notes_and_Comments__c = objOrder.Ops_Notes_and_Comments__c;
                quotedata.Fulfillment_Notes__c = objOrder.Fulfillment_Notes__c;
                quotedata.Ops_Order_Status__c = objOrder.Ops_Order_Status__c;
                
                quotedata.ShippingCountry = objOrder.ShippingCountry;
                quotedata.ShippingCountryCode = objOrder.ShippingCountryCode;
                quotedata.ShippingStreet = objOrder.ShippingStreet;
                quotedata.ShippingCity = objOrder.ShippingCity;
                quotedata.ShippingStateCode = objOrder.ShippingStateCode;
                quotedata.ShippingState = objOrder.ShippingState;
                quotedata.ShippingPostalCode = objOrder.ShippingPostalCode;
                
                quotedata.Seating_Request__c = objOrder.Seating_Request__c;
                quotedata.PickUp_Requested__c = objOrder.Pick_Up_Requested__c;                
                // #922 change - END
                system.debug('quotedata----'+quotedata);
                insert quotedata;
                
                strQuoteId = quotedata.Id;
                
                if(check == 'yes') {        
                    system.debug('lstterms--'+mappaymentTerms.values());
                    List<Payment_Term__c> lstInsertPT = new List<Payment_Term__c>();
                    List<Charge__c> lstcharge = new List<Charge__c>();
                    
                    for(Payment_Term__c objPaymentTerm : mappaymentTerms.values()) {
                        Payment_Term__c pTdata = new Payment_Term__c();
                        pTdata.Opportunity__c = objPaymentTerm.Opportunity__c;
                        pTdata.Status__c = objPaymentTerm.Status__c;
                        pTdata.Payment_Term__c = objPaymentTerm.Payment_Term__c;
                        pTdata.Payment_Method__c = objPaymentTerm.Payment_Method__c;
                        pTdata.Amount__c = objPaymentTerm.Amount__c;
                        pTdata.Percentage_Of_Payment__c = objPaymentTerm.Percentage_Of_Payment__c;
                        pTdata.Payment_Due_Date__c = objPaymentTerm.Payment_Due_Date__c;
                        pTdata.Charge_Date__c = objPaymentTerm.Charge_Date__c;
                        pTdata.Exchange_Rate_Date__c = objPaymentTerm.Exchange_Rate_Date__c;
                        pTdata.CurrencyIsoCode = objPaymentTerm.CurrencyIsoCode;                        
                        pTdata.Quote__c = quotedata.Id;
                        pTdata.Credit__c = objPaymentTerm.Credit__c;
                        if(!Test.isRunningTest()) pTdata.RecordTypeId = objPaymentTerm.RecordTypeId;
                        pTdata.Original_Payment_Term__c= objPaymentTerm.Id;
                        pTdata.Initial_Payment_Term__c = objPaymentTerm.Initial_Payment_Term__c;
                        pTdata.Commission_Paid__c = objPaymentTerm.Commission_Paid__c;
                        lstInsertPT.add(pTdata);
                    }
                    system.debug('lstInsertPT----'+lstInsertPT);
                    Utility.processRecords(lstInsertPT,'insert');
                    //map for get new payment term Id
                    Map<String,String >  mpPTids = new Map<String,String > ();
                    for(Payment_Term__c objPaymentTerm : lstInsertPT){ mpPTids.put(objPaymentTerm.Original_Payment_Term__c,objPaymentTerm.id); }
                    Id creditRecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
                    Id chargeRecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Debit').getRecordTypeId();
                    
                    Set<Id> setChargeCreateBasedOnPT = new Set<Id>();
                    //charge object clone
                    for(Payment_Term__c objPaymentTerm : lstInsertPT) {
                        if(objPaymentTerm.Status__c == 'Passed' && objPaymentTerm.RecordTypeId != Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId()) {
                            Charge__c chargeObj = new Charge__c();
                            chargeObj.Amount__c = objPaymentTerm.Amount__c;
                            chargeObj.Payment_Terms__c = mpPTids.get(objPaymentTerm.Original_Payment_Term__c);
                            chargeObj.RecordTypeId  = creditRecordTypeId;
                            chargeObj.Status__c  = 'pending';
                            chargeObj.Account__c  = AccountId;
                            //#591 Set the Status of Charge to Passed
                            chargeObj.Status__c  = 'Passed';
                            lstcharge.add(chargeObj);
                            setChargeCreateBasedOnPT.add(objPaymentTerm.Original_Payment_Term__c);
                        }
                    }
                    for(Charge__c ObjOldCharge : lstOldcharges){
                        if(ObjOldCharge.Payment_Terms__c != null && !setChargeCreateBasedOnPT.contains(ObjOldCharge.Payment_Terms__c)) {
                            Charge__c chargeObj = new Charge__c();
                            chargeObj = ObjOldCharge;
                            chargeObj.Id = null;
                            chargeObj.Payment_Terms__c = mpPTids.get(ObjOldCharge.Payment_Terms__c);
                            lstcharge.add(chargeObj);
                        }
                    }
                    Utility.processRecords(lstcharge,'insert');
                    system.debug('lstcharge'+lstcharge);
                    //update charge id on payment term
                    Map<Id,Payment_Term__c> mapPT = new Map<Id,Payment_Term__c>();
                    for(Charge__c objCharge : lstcharge){
                        Payment_Term__c objpT = new Payment_Term__c();
                        objpT.id = objCharge.Payment_Terms__c;
                        objpT.Charge_Id__c = objCharge.id;
                        mapPT.put(objpT.id,objpT);
                    }
                    Utility.processRecords(mapPT.values(),'update');
                    
                    //get all QuoteLineItem
                    List<QuoteLineItem> lstQLI = [SELECT A_LA_Cart__c,ApexHotelTotalPrice__c,Check_In_Date__c,
                                                  Check_Out_Date__c,Cost__c,CreatedById,CreatedDate,CurrencyIsoCode,
                                                  Description,Discount,Discount_Description__c,Event_Shipping_And_Handling__c,
                                                  Event_Shipping_And_Handling_Outside_US__c,Event_Tax_Percentage__c,
                                                  Grand_Total__c,Hotel_Id__c,Hotel_Package_Id__c,Id,LineNumber,ListPrice,
                                                  ListPrice_Used__c,ListPrice_With_Discount__c,OpportunityLineItemId,Package__c,
                                                  Price__c,PricebookEntry_Name__c,PricebookEntryId,Processing_Fee_Amount__c,
                                                  Processing_Fee_Percentage_Used__c,Product_Shipping_And_Handling__c,
                                                  Product_Shipping_And_Handling_OutsideUS__c,Product_Tax_Percentage__c,Product_Type__c,
                                                  Product_Types__c,Product2Id,ProductType__c,Quantity,Quote_Package__c,Quote_Product_Package_Hotel__c,
                                                  Record_Type__c,Room_Quantity__c,Room_Type__c,Room_Type_Hotel__c,Roomtype_Id__c,
                                                  ServiceDate,Shipping_And_Handling__c,Shipping_Outside_US__c,SortOrder,Subtotal,SystemModstamp,
                                                  Tax_Amount__c,Tax_Percentage__c,Tax_Percentage_Used__c,Total_CC_Fee__c,Total_Processing_Fee_Amount__c,
                                                  Total_Shipping_and_Handling__c,Total_Tax__c,Total_Tax_Amount__c,Total_VAT_Tax__c,TotalPrice,
                                                  Transportation_As_Part_Of_Hotel__c,UnitPrice,VAT_Tax__c,VAT_Tax_Amount__c,  
                                                  Product2.Name, Product2.Type__c, Original_Total_Price__c
                                                  FROM QuoteLineItem 
                                                  WHERE QuoteId=: objOrder.QuoteId and Product_Type__c != 'Shipping and Handling'
                                                  Order By CreatedDate ASC];
                    
                    //#541 Added logic for Populate Hotel_Package_Id__c in Stay and Transportation Product
                    List<QuoteLineItem> lstQLICHO = new List<QuoteLineItem>();
                    List<QuoteLineItem> lstChildQLI = new List<QuoteLineItem>();
                    Map<Id, QuoteLineItem> mapQuoteItem = new Map<Id, QuoteLineItem>();
                    
                    for(QuoteLineItem objQLI: lstQLI) {
                        String tempId = objQLI.Id;
                        QuoteLineItem QLIdata =  new QuoteLineItem();
                        QLIdata = objQLI;
                        QLIdata.Id = null;
                        QLIdata.QuoteId = quotedata.Id;
                        QLIdata.CreatedDate = System.now();
                        //#667 - Exclude OrderItem which are already send to AWS on Change Order --START
                        QLIdata.Original_Quantity__c = QLIdata.Quantity;
                        //#667 - Exclude OrderItem which are already send to AWS on Change Order --END

                        //#992 - Allow change orders for orders that were originally just a deposit orders --START
                        if(objQLI.Product2.Name.Contains('Deposit') && objQLI.Product2.Type__c == 'Deposit' && objQLI.UnitPrice >=0){
                            if(objQLI.UnitPrice != 0){
                                objQLI.Original_Total_Price__c = objQLI.TotalPrice;
                                objQLI.UnitPrice = 0;
                                objQLI.ListPrice_Used__c = 0;
                            } else {
                                objQLI.Original_Total_Price__c = objQLI.Original_Total_Price__c;
                            }
                        }
                        //#992 - Allow change orders for orders that were originally just a deposit orders --END
                        
                        //#839 Change Order Issue
                        mapQuoteItem.put(tempId, QLIdata);
                    }
                    
                    if(mapQuoteItem.size() > 0) {
                        lstQLICHO = (List<QuoteLineItem>)Utility.processRecords(mapQuoteItem.values(),'insert');
                        
                        for(QuoteLineItem objQLI : lstQLICHO) {
                            if(objQLI.Quote_Package__c != null || objQLI.Hotel_Package_Id__c != null) {
                                if(objQLI.Quote_Package__c != null && mapQuoteItem.containskey(objQLI.Quote_Package__c)) {
                                    objQLI.Quote_Package__c = mapQuoteItem.get(objQLI.Quote_Package__c).Id;
                                }
                                if(objQLI.Hotel_Package_Id__c != null && mapQuoteItem.containskey(objQLI.Hotel_Package_Id__c)) {
                                    objQLI.Hotel_Package_Id__c = mapQuoteItem.get(objQLI.Hotel_Package_Id__c).Id;
                                }
                                lstChildQLI.add(objQLI);
                            }
                        }
                        if(lstChildQLI.size() > 0) {
                            Utility.processRecords(lstChildQLI, 'update');
                        }
                    }
                    //#731 Extra Rooming List records related to change orders
                    List<Rooming_List__c> lstRoominglist = [SELECT Id, Guest_Name__c, H4H_Itinerary_Id__c, H4H_RatePlan_Code__c, H4H_Reservation_Id__c, H4H_Room_Code__c, H4H_Roomtype_Id__c, OpportunityLineItem_Id__c, Opportunity__c, Number_of_Adults__c, QNG_Rooming_List_Id__c, Stay_Id__c, Hotel_Id__c, Check_In_Date__c, Check_Out_Date__c, H4H_Hold_Created__c, H4H_Hotel_Id__c, H4H_Reservation_Created__c, H4H_RoomCode__c, Hotel_Package_Id__c, Product__c, QuoteLineItem_Id__c, Quote_Package__c, Quote__c, Quantity__c, Order__c, RoomType__c, Retail_Check_In_date__c, Retail_Check_Out_date__c, Retail_Hotel_Name__c, No_of_Stay_from_Order__c 
                                                            FROM Rooming_List__c WHERE Quote__c = :objOrder.QuoteId Order By CreatedDate];
                    if(lstRoominglist.size() > 0) {
                        List<Rooming_List__c> lstnewRoomlst = new List<Rooming_List__c>();
                        for(Rooming_List__c objRoominglist : lstRoominglist){
                            objRoominglist.Id = null;
                            objRoominglist.Quote__c = quotedata.Id;
                            objRoominglist.Order__c = null;
                            if(objRoominglist.QuoteLineItem_Id__c != null && mapQuoteItem.containskey(objRoominglist.QuoteLineItem_Id__c)) {
                                objRoominglist.QuoteLineItem_Id__c = mapQuoteItem.get(objRoominglist.QuoteLineItem_Id__c).Id;
                            }
                            if(objRoominglist.Quote_Package__c != null && mapQuoteItem.containskey(objRoominglist.Quote_Package__c)) {
                                objRoominglist.Quote_Package__c = mapQuoteItem.get(objRoominglist.Quote_Package__c).Id;
                            }
                            if(objRoominglist.Hotel_Package_Id__c != null && mapQuoteItem.containskey(objRoominglist.Hotel_Package_Id__c)) {
                                objRoominglist.Hotel_Package_Id__c = mapQuoteItem.get(objRoominglist.Hotel_Package_Id__c).Id;
                            }
                            lstnewRoomlst.add(objRoominglist);
                        }
                        if(lstnewRoomlst.size() > 0) {
                            insert lstnewRoomlst;
                        }
                        if(checkForHoldRes == 'no') {
                            set<Id> lstRoominglstIds =  new set<Id>();
                            for(Rooming_List__c objlist : lstRoominglist) {
                                if(objlist.H4H_Hold_Created__c == true) {
                                    lstRoominglstIds.add(objlist.Id);
                                }
                            }
                            if(lstRoominglstIds.size() > 0) {
                                H4HCancelHoldBatch objbt = new H4HCancelHoldBatch(lstRoominglstIds);
                                Database.executeBatch(objbt);
                            }
                        }
                    }
                } else {
                    ///old Quote
                    Quote oldquotedata = new Quote();
                    oldquotedata.Id = objOrder.QuoteId;
                    oldquotedata.Status = 'Draft - Denied';
                    Utility.processRecords(oldquotedata,'update');
                }
            }
        } catch(Exception ex) {
            System.debug('Exception --- Order Change -- createQuotePaymentTerms'+ ex.getStackTraceString()+'----'+ex.getMessage());
        }
        return strQuoteId;
    }
    
    @AuraEnabled
    public static Boolean fetchRoominglst(String currentRecordId){
        Boolean resCreated = false;
        try{
            if(currentRecordId != null){
                Order objOrder = [select Id, QuoteId from Order where Id =: currentRecordId ];
                if(objOrder != null) {
                    List<Rooming_List__c> lstRoominglist = [select Id,name,H4H_Hold_Created__c,H4H_Reservation_Created__c from Rooming_List__c where Quote__c=:objOrder.QuoteId ];
                    if(lstRoominglist.size() > 0) {
                        for(Rooming_List__c objroom :lstRoominglist) {
                            if(objroom.H4H_Reservation_Created__c == true) resCreated = true;
                            else resCreated = false;
                        }
                    }
                }
            }
        } catch(Exception ex) {
            system.debug('Exception : ---'+ex.getMessage());
        }
        system.debug('resCreated'+resCreated);
        return resCreated;
    }
    
    @AuraEnabled
    public static Boolean fetchHoldRoominglist(String currentRecordId) {
        Boolean resCreated = false;
        try {
            if(currentRecordId != null){
                Order objOrder = [select Id, QuoteId from Order where Id =: currentRecordId ];
                if(objOrder != null) {
                    List<Rooming_List__c> lstRoominglist = [select Id,name,H4H_Hold_Created__c,H4H_Reservation_Created__c from Rooming_List__c where Quote__c=:objOrder.QuoteId ];
                    if(lstRoominglist.size() > 0) {
                        for(Rooming_List__c objroom :lstRoominglist) {
                            if(objroom.H4H_Hold_Created__c == true) resCreated = true;
                            else resCreated = false;
                        }
                    }
                }
            }
        } catch(Exception ex) {
            system.debug('Exception : --- '+ex.getMessage());
        }
        system.debug('resholdCreated'+resCreated);
        return resCreated;
    }
    
    /**
    * @description Method to check Pricebook on Order is Active or not
    * @author Jheel Agrawal | 07-16-2020 
    * @param String currentRecordId 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean checkPriceBookStatus(String currentRecordId){
        try {
            List<Order> lstOrders = [Select Id, Opportunity.PriceBook2.isActive FROM Order WHERE Id = :currentRecordId];
            if(lstOrders.size() > 0){
                return lstOrders[0].Opportunity.PriceBook2.isActive;
            }
        }
        catch(Exception ex) {
            system.debug('Exception : ---'+ex.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static Order getOrderDetails(String currentRecordId) {
        Order order = new Order();
        //Updated SOQL for #545 Order change
        order = [SELECT Id, Status, Pricebook2Id, Pricebook2.Name, Pricebook2.GPE_Event__c, Pricebook2.IsActive, 
                 Opportunity.Pricebook2Id, Opportunity.Pricebook2.IsActive, Order_Payment_Status__c,
                 (SELECT Id, Product2Id, Product2.Name, Product2.IsActive FROM OrderItems) FROM Order WHERE Id =: currentRecordId];
        return order;
    }
}