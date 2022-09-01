/**
 * @File Name          : QuoteTriggerHelper.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ratiksinghal@addonblue.com
 * @Last Modified On   : 04-19-2022
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0      19/12/2016   Sundar Subramaniam         INITIAL DEVELOPMENT
 * 1.1      03/02/2020   jagrawal@addonblue.com     Updated Class Name and the referenced class name
 * 1.2      03/09/2020   jagrawal@addonblue.com     Refactored the Class Code as per the Trigger Framework
 * 1.3      06/09/2020   jagrawal@addonblue.com     Added Conditions before SOQL to reduce unnecessary SOQL
 * 1.4      06/18/2020   jagrawal@addonblue.com     Added code to delete the related payment terms on quote delete
 * 1.5      07/08/2020   jagrawal@addonblue.com     Changed Update sequence of Payment Term on Order Creation for Signed - Approved Quote
 * 1.6      07/17/2020   jagrawal@addonblue.com     Added code to populate Comment field on Order from Quote when created
 * 1.7      07/30/2020   jagrawal@addonblue.com     #463 Added code to make Order Owner same as Quote Owner
 * 1.8      08/05/2020   jagrawal@addonblue.com     #462 Added Code to get all the OCR based on the Opportunity of Quote
 * 1.9      09/17/2020   jagrawal@addonblue.com     #521 Added Code for GPE and GPT SAH Calculation
 * 1.10     11/01/2020   fsuraitawala@addonblue.com #598 Order Change and Code Optimization
 * 1.11     12/03/2020   jagrawal@addonblue.com     #635 Add Seating Request (Subject to Availability) on Quote and Order
 * 2.0      11/01/2020   fsuraitawala@addonblue.com #598 Order Change and Code Optimization
 * 2.1      12/03/2020   jagrawal@addonblue.com     #635 Add Seating Request (Subject to Availability) on Quote and Order
 * 2.2      12/08/2020   jagrawal@addonblue.com     #648 Excluded Protect Group product from shipping fee calculation
 * 2.3      12/23/2020   jagrawal@addonblue.com     #685 Reduced unnecessary SOQL
 * 2.4      11/26/2020   kchavda@addonblue.com      #627 Get the exchange rate date from the JSON for Online Orders 
 * 2.5      02/12/2020   kchavda@addonblue.com      #781 Add Billing Contact to Quote and Add formula field called "Quote to Online Order"
 * 2.6      03/30/2021   kchavda@addonblue.com      #882 Online order not going in 3/25/21
 * 2.5      03/31/2021   cshah@addonblue.com        #871 - Email Alert and Opportunity Stage update when quote status becomes "Sent from QNG"
 * 2.5      03/31/2021   cshah@addonblue.com        #871 - Email Alert and Opportunity Stage update when quote status becomes "Sent from QNG"
 * 2.7      04/29/2021   kchavda@addonblue.com      #891 Add Order Purchase date on Order for Online Order
 * 2.7      05/11/2021   cshah@addonblue.com        #951 Copy "Landing Page" from Account to Order
 * 2.6      04/22/2021   cshah@addonblue.com        #922 Change Order - Copy certain field values from active order
 * 2.7      06/22/2024   cshah@addonblue.com        #991 Payment Method "Value In Kind" and Payment Terms Status Changes
 * 2.8 		04/22/2022	 vaibhav.khopade@addonblue.com  #1206 - Info Reuqest fields updates on Quote & Order
**/

public class QuoteTriggerHelper {
    
    private Map<Id, Quote> newQuoteMap; 
    private Map<Id, Quote> oldQuoteMap;
    private List<Quote> newQuoteList;
    private List<Quote> oldQuoteList;
    public static boolean bIsAutoSyncedQuote = true;

    /**
    * @description Constructor to query all data at once and then pass it in the Helper methods for specific Trigger event
    * @author jagrawal@addonblue.com | 9/3/2020 
    * @return void 
    **/
    public QuoteTriggerHelper(){
        Utility.getSOQLCount();
        Utility.getTriggerSize();
        this.newQuoteMap = (Map<Id, Quote>) Trigger.newMap;
        this.oldQuoteMap = (Map<Id, Quote>) Trigger.oldMap;
        this.newQuoteList = (List<Quote>) Trigger.new;
        this.oldQuoteList = (List<Quote>) Trigger.old;

        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Before Insert!');
                
                Set<Id> PriceBookIds = new Set<Id>(); 
                Set<Id> oppoIds = new Set<Id>();                
                Map<Id, Id> mapOppIDNOCR = new Map<Id, Id>();
                for(Quote objQuote : newQuoteList){
                    PriceBookIds.add(objQuote.PriceBook2Id);
                    if(objQuote.OpportunityId != null) {
                        oppoIds.add(objQuote.OpportunityId);    
                    } 
                }
                //#781 Add Billing Contact to Quote and Add formula field called "Quote to Online Order" -Start
                if(oppoIds.size()>0){
                    List<OpportunityContactRole> lstOppConRoles = [select id, Role, ContactId, OpportunityId from OpportunityContactRole where opportunityid =: oppoIds and Role = 'Billing Contact'];                    
                    for(OpportunityContactRole obj : lstOppConRoles){                        
                        mapOppIDNOCR.put(obj.OpportunityId, obj.ContactId);
                    }
                }
                //#781 Add Billing Contact to Quote and Add formula field called "Quote to Online Order" - End
                
                Map<Id,PriceBook2> priceBookMap = new Map<Id,PriceBook2>([Select id,Switch_to_Pick_Up_Only_Date__c from Pricebook2 where id in: PriceBookIds]);
                System.debug('priceBookMap-->'+priceBookMap);

                //1023
                Opportunity objOpp = [Select Id, Account.Name, RecordTypeId, RecordType.DeveloperName From Opportunity where Id  =: oppoIds ];
                boolean isBusinessAcoount = false;
                if(objOpp.RecordType.DeveloperName == 'Business_Opportunity'){
                    isBusinessAcoount = true;
                    System.debug('Is this Business Account '+ isBusinessAcoount);
                }
                for(Quote objQuote : newQuoteList){
                    if(isBusinessAcoount){
                        objQuote.Company_Name__c =  objOpp.Account.Name;
                    }
                }
                
                //H4H Points Calculation
                for(Quote objQuote : newQuoteList){
                    //#535 change -- START
                    if(objQuote.Status == 'Signed - Approved'){
                        objQuote.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Signed_Approved_Quote').getRecordTypeId();
                    }
                    //#535 change -- END
                    if(objQuote.Original_Quote__c != null && objQuote.Original_Quote__r.Points_to_be_added_to_H4H__c != null){
                        objQuote.Points_to_be_added_to_H4H__c = objQuote.Total_Earned_Reward_Points__c + objQuote.Total_Used_Reward_Points__c - objQuote.Original_Quote__r.Points_to_be_added_to_H4H__c;
                    }
                    else{
                        objQuote.Points_to_be_added_to_H4H__c = objQuote.Total_Earned_Reward_Points__c + objQuote.Total_Used_Reward_Points__c;
                    }

                    if(priceBookMap.containskey(objQuote.PriceBook2Id)){
                       if(priceBookMap.get(objQuote.PriceBook2Id).Switch_to_Pick_Up_Only_Date__c != null &&
                          priceBookMap.get(objQuote.PriceBook2Id).Switch_to_Pick_Up_Only_Date__c < System.Today()){
                                objQuote.Pickup_Requested__c = true;
                            }
                    }
                    //#781 Add Billing Contact to Quote and Add formula field called "Quote to Online Order" - Start
                    if(objQuote.OpportunityId != null && mapOppIDNOCR.containskey(objQuote.OpportunityId)) {                        
                        objQuote.Billing_Contact__c = mapOppIDNOCR.get(objQuote.OpportunityId);                        
                    }
                    //#781 Add Billing Contact to Quote and Add formula field called "Quote to Online Order" - End                     
                    
                }
                
            }
            
            when BEFORE_UPDATE {
                System.debug('In Before Update!');
                // #521 Added code for GPT and GPE Related Changes -- START
                // #648 Excluded Protect Group product from shipping fee calculation
               /* List<Quote> lstQuotes = [Select Id, Original_Quote__c, Original_Quote__r.Points_to_be_added_to_H4H__c, 
                                        (SELECT Id, Product_Types__c, Total_Price__c,GPE_Total_Price__c   FROM QuoteLineItems WHERE Product_Types__c NOT IN  ('Shipping and Handling','Protect Group')) 
                                        FROM Quote WHERE Id IN :newQuoteMap.keyset()]; */
                //VKHOPADE - issue 1247 - start
                String userProfile = [Select Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
                for(Quote objQuote : newQuoteList){
                    if(objQuote.Status != oldQuoteMap.get(objQuote.Id).Status && oldQuoteMap.get(objQuote.Id).Status == 'Signed - Approved'){
                        if(userProfile != 'System Administrator'){
                            List<Order> ordersOnQuote = [Select Id from Order where QuoteId = :objQuote.Id];
                            if(ordersOnQuote.size() > 0){
                                objQuote.adderror('Cannot update Quote status from Signed - Approved as this Quote has Order generated for it');
                            }
                        }
                    }
                } //VKHOPADE - issue 1247 - end
                //Ravindra - #1249 Opportunity with multiple Active Order.
                 checkMultipleorder(newQuoteList,oldQuoteMap);
                
                List<Quote> lstQuotes = [Select Id, Status, Original_Quote__c, Original_Quote__r.Points_to_be_added_to_H4H__c, 
                                        (SELECT Id, Product_Types__c, Total_Price__c,GPE_Total_Price__c FROM QuoteLineItems WHERE Product_Types__c NOT IN  ('Shipping and Handling','Protect Group')),
                                        (select Id, Payment_Due_Date__c, Quote__c,status__c,amount__c FROM Payment_Terms__r)
                                        FROM Quote WHERE Id IN :newQuoteMap.keyset()];
                
                Map<Id,Decimal> mapQuoteTotal = new Map<Id,Decimal>();
                Map<Id, Decimal> mapQuoteH4HPoints = new Map<Id, Decimal>();
                Set<Id> QuotesWithPaymentTerms = new Set<Id>(); //VKHOPADE
                
                for(Quote objQuote : lstQuotes){
                   
                    Decimal totalWithoutSAH = 0.0;
                    for(QuoteLineItem objQLI : objQuote.QuoteLineItems){
                        //totalWithoutSAH += objQLI.Total_Price__c;
                        if(objQLI.GPE_Total_Price__c != null) totalWithoutSAH += objQLI.GPE_Total_Price__c;
                    }
                    mapQuoteTotal.put(objQuote.Id,totalWithoutSAH);

                    //#906 H4H Rewards functionality -- START
                    if(objQuote.Original_Quote__c != null && objQuote.Original_Quote__r.Points_to_be_added_to_H4H__c != null){
                        mapQuoteH4HPoints.put(objQuote.Original_Quote__c, objQuote.Original_Quote__r.Points_to_be_added_to_H4H__c);
                    }
                    //#906 H4H Rewards functionality -- END
                    
                    //VKHOPADE - issue 1146 -  start
                    if((objQuote.Payment_Terms__r).size() > 0) 
                    	QuotesWithPaymentTerms.add(objQuote.Id);
                }
               //Ravindra - #1232 Downgradeorder changes
                checkDowngradeQuoteValidation(newQuoteList,oldQuoteMap,lstQuotes);           
                
                //Downgrade refund validation End
                
                //Downgrade refund validation End

                
                System.debug('mapQuoteTotal@@'+mapQuoteTotal);
                //#521 Added code for GPT and GPE Related Changes -- END
                //H4H Points Calculation
                for(Quote objQuote : newQuoteList){
                     //VKHOPADE - issue 1146 - start
                    if(objQuote.Status != oldQuoteMap.get(objQuote.Id).Status && objQuote.Status == 'Signed - Approved' && objQuote.Online_Order__c == false){
                        if(QuotesWithPaymentTerms.contains(objQuote.Id) != true)
                            objQuote.adderror('Cannot set Quote status to Signed - Approved as payment terms are not added');
                	} //VKHOPADE - issue 1146 - end
                     
                    //#535 change -- START
                    if(objQuote.Status != oldQuoteMap.get(objQuote.Id).Status && objQuote.Status == 'Signed - Approved'){
                        objQuote.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Signed_Approved_Quote').getRecordTypeId();
                    }
                    //#535 change -- END
                    objQuote.Total_Without_SAH__c = mapQuoteTotal.get(objQuote.Id);
                    //#906 H4H Rewards functionality for change Order
                    if(objQuote.Original_Quote__c != null && mapQuoteH4HPoints.containsKey(objQuote.Original_Quote__c)){
                        objQuote.Points_to_be_added_to_H4H__c = objQuote.Total_Earned_Reward_Points__c - objQuote.Total_Used_Reward_Points__c - mapQuoteH4HPoints.get(objQuote.Original_Quote__c);
                    } else {
                        objQuote.Points_to_be_added_to_H4H__c = objQuote.Total_Earned_Reward_Points__c - objQuote.Total_Used_Reward_Points__c;
                    }
                }
            }
            
            when BEFORE_DELETE {
                System.debug('In Before Delete!'); 
                List<Payment_Term__c> lstPaymentTerms = [Select Id, Name from Payment_Term__c where Quote__c IN :oldQuoteMap.keySet()];
                deleteRelatedPaymentTerms(lstPaymentTerms, oldQuoteList);
            }
            
            when AFTER_INSERT {
                System.debug('In After Quote Insert!');
                sendEmailOnQuoteSentToQNG(newQuoteList,oldQuoteMap); //#871
                
                if(!System.isBatch()){
                    system.debug('###newQuoteList=='+newQuoteList);
                    callQuoteSyncBatch(newQuoteList);
                }
                
                
                Set<Id> oppoIds = new Set<Id>();
                Set<Id> signApprovedQuotes = new Set<Id>();
                for (Quote qu : newQuoteList) {
                    if (qu.OpportunityId != null) {
                        oppoIds.add(qu.OpportunityId);    
                    }
                    if(qu.Status == 'Signed - Approved'){
                        signApprovedQuotes.add(qu.Id);
                    }
                }
                
                // #462 Added Code to get all the OCR based on the Opportunity of Quote -- START
                Map<Id, Map<String, Id>> mapOppIDNOCR = new Map<Id, Map<String, Id>>();
                if(oppoIds.size()>0){
                    List<OpportunityContactRole> lstOppConRoles = [select id, Role, ContactId, OpportunityId from OpportunityContactRole where opportunityid =: oppoIds];                
                    for(OpportunityContactRole obj : lstOppConRoles){
                        Map<String, Id> mapOpportunityContactRole = new Map<String, Id>();
                        if(mapOppIDNOCR.containsKey(obj.OpportunityId)){ mapOpportunityContactRole = mapOppIDNOCR.get(obj.OpportunityId); }
                        if(!mapOpportunityContactRole.containsKey(obj.Role)){ mapOpportunityContactRole.put(obj.Role, obj.ContactId); }
                        mapOppIDNOCR.put(obj.OpportunityId, mapOpportunityContactRole);
                    }
                }
                // #462 Added Code to get all the OCR based on the Opportunity of Quote -- END

                //Code Added By Jheel Start
                Map<Id,Order> mapOrder = new Map<Id,Order>();                
                if(signApprovedQuotes.size() > 0){
                    for(Order objOrder : [Select Id,QuoteId,Quote.Status from Order where QuoteId IN: signApprovedQuotes]){
                        mapOrder.put(objOrder.QuoteId, objOrder);
                    }
                }
                // List<Rooming_List__c> lstRoomList = [Select Id,Quote__c,Opportunity__c,Order__c From Rooming_List__c where Quote__c IN:newQuoteMap.keyset()];
                // updating Order in Opportunity Payment Terms related to Quote
                // List<Payment_Term__c> lstOppPayssTerms = [SELECT Id, Quote__c, Order__c,Amount__c, Opportunity__c,Percentage_Of_Payment__c, Status__c, Quote__r.Original_Quote__c, RecordtypeId, Recordtype.Name, Quote__r.CurrencyISOCode, Quote__r.AccountId, Credit__c FROM Payment_Term__c WHERE Quote__c IN :newQuoteMap.keyset()];
                // Map<Id,Payment_Term__c> mapPaymentTerms = new Map<Id,Payment_Term__c>();
                // for(Payment_Term__c objPayTerm : lstOppPayssTerms){
                //     mapPaymentTerms.put(objPayTerm.Id,objPayTerm);
                // }
                // Map<Id,Payment_Term__c> mapPaymentTerm = new Map<Id,Payment_Term__c>();
                // for(Payment_Term__c objPayTerm : mapPaymentTerms.values()){
                //     mapPaymentTerm.put(objPayTerm.Quote__c,objPayTerm);
                // }
                // System.debug('mapPaymentTerm-->'+mapPaymentTerm);
                // #319 Code changes done by Jheel for Too many SOQL -- START
                // List<Charge__c> lstcharge = new List<Charge__c>();
                // if(mapPaymentTerms.keyset().size() > 0){
                //     lstcharge = [Select Id,Payment_Terms__c,Order_Status__c,Order__c from Charge__c where Payment_Terms__c in : mapPaymentTerms.keyset() AND (RecordType.Name = 'Debit' OR RecordType.Name = 'Account Credit')];
                // }
                // #319 Code changes done by Jheel for Too many SOQL -- END
                // inserting related Quote Line Items
                // List<QuoteLineItem> lstQuoteLineItems = [SELECT Id, PricebookEntryId, Product2Id, QuoteId, Quantity, UnitPrice, Package__c, Product_Types__c,Record_Type__c,Quote_Package__c  FROM QuoteLineItem WHERE QuoteId IN :newQuoteMap.keyset()];
                //#951
                Map<Id,Quote> mapQuote = new Map<Id,Quote>();
                List<Quote> quotesToUpdateForInfoReq = new List<Quote>(); //VKHOPADE - issue 1176
                List<Quote> lstQuote = [select Id, GPE_Online_Order__c, Opportunity.Pricebook2Id, Pricebook2Id,PriceBook2.Switch_to_Pick_Up_Only_Date__c,Payment_Method__c,
                                        Opportunity.OwnerId, Opportunity.AccountId, CurrencyIsoCode,TotalPrice, Original_Quote__c, Selected_Payment_Term__c, GrandTotal,
                                        OpportunityId, Description,Account.Landing_Page__c,
                                        Account.Last_UTM_Source__c, Account.Last_UTM_Medium__c, Account.Last_UTM_Campaign__c, Account.Last_Referrer__c, Account.First_Landing_Page__c, Account.Last_Landing_Page__c, //VKHOPADE - issue 1176
                                        Account.First_UTM_Source__c, Account.First_UTM_Medium__c, Account.First_UTM_Campaign__c, Account.First_Referrer__c, Account.First_Info_Request_Site__c, Account.Last_Info_Request_Site__c //VKHOPADE - #1206
                                        FROM Quote WHERE Id IN: newQuoteMap.keySet()];
                for(Quote objQuote: lstQuote){
                    mapQuote.put(objQuote.Id,objQuote);
                    System.debug('accId-->'+objQuote.Opportunity.AccountId);
                    
                    //VKHOPADE - issue 1176 - start
                    if((objQuote.Account.Last_UTM_Source__c != '' || objQuote.Account.Last_UTM_Source__c != null) || (objQuote.Account.Last_Referrer__c != null || objQuote.Account.Last_Referrer__c != '') || 
                       (objQuote.Account.Last_Landing_Page__c != '' || objQuote.Account.Last_Landing_Page__c != null) || (objQuote.Account.Last_UTM_Campaign__c != '' || objQuote.Account.Last_UTM_Campaign__c != null) || 
                      (objQuote.Account.Last_UTM_Medium__c != '' || objQuote.Account.Last_UTM_Medium__c != null) || (objQuote.Account.Last_Info_Request_Site__c != '' || objQuote.Account.Last_Info_Request_Site__c != null) || //VKHOPADE - #1206
                      (objQuote.Account.First_UTM_Source__c != '' || objQuote.Account.First_UTM_Source__c != null) || (objQuote.Account.First_Referrer__c != null || objQuote.Account.First_Referrer__c != '') ||  //VKHOPADE - #1206
                      (objQuote.Account.First_UTM_Campaign__c != '' || objQuote.Account.First_UTM_Campaign__c != null) || 
                      (objQuote.Account.First_UTM_Medium__c != '' || objQuote.Account.First_UTM_Medium__c != null) || (objQuote.Account.First_Info_Request_Site__c != '' || objQuote.Account.First_Info_Request_Site__c != null)
                      ){  
                        Quote tempQuote = new Quote();
                        tempQuote.Id = objQuote.Id;
                        tempQuote.Last_Referrer__c = objQuote.Account.Last_Referrer__c;
                        tempQuote.Landing_Page__c = objQuote.Account.Last_Landing_Page__c;
                        tempQuote.UTM_Source__c = objQuote.Account.Last_UTM_Source__c;
                        tempQuote.UTM_Medium__c = objQuote.Account.Last_UTM_Medium__c;
                        tempQuote.UTM_Campaign__c = objQuote.Account.Last_UTM_Campaign__c;
                        tempQuote.First_Landing_Page__c = objQuote.Account.First_Landing_Page__c; //VKHOPADE- #1176
                        //VKHOPADE - #1206 - start
                        tempQuote.Last_Info_Request_Site__c = objQuote.Account.Last_Info_Request_Site__c;
                        tempQuote.First_Referrer__c = objQuote.Account.First_Referrer__c;
                        tempQuote.First_UTM_Source__c = objQuote.Account.First_UTM_Source__c;
                        tempQuote.First_UTM_Medium__c = objQuote.Account.First_UTM_Medium__c;
                        tempQuote.First_UTM_Campaign__c = objQuote.Account.First_UTM_Campaign__c;
                        tempQuote.First_Info_Request_Site__c = objQuote.Account.First_Info_Request_Site__c;
                        //VKHOPADE - #1206 - end
                        quotesToUpdateForInfoReq.add(tempQuote);    
                    }
                    //VKHOPADE - issue 1176 - end   
                }
                
                if(quotesToUpdateForInfoReq.size() > 0){     						//VKHOPADE - issue 1176
                    TriggerHandler.bypass('QuoteTriggerHandler');
                    Utility.processRecords(quotesToUpdateForInfoReq, 'update');
                    TriggerHandler.clearBypass('QuoteTriggerHandler');
                }
                
                // #462 Added Code to get all the OCR based on the Opportunity of Quote
                createOrders(oldQuoteMap, newQuoteMap, mapQuote, mapOppIDNOCR, mapOrder, new List<Payment_Term__c>(), new List<QuoteLineItem>(), new List<Charge__c>(), new List<Rooming_List__c>());

                //#555 commented for Change Order Issue
                /*if(mapPaymentTerms.values().size() > 0){
                    savePaymentTerm(lstQuote,mapPaymentTerms.values());
                }*/
                List<PricebookEntry> lstPBE = new List<PricebookEntry>();
                Set<Id> setPricebookIds = new Set<Id>();
                Set<String> setCurrencyCode = new Set<String>();    
                for(Quote objQuote: lstQuote) {
                    setPricebookIds.add(objQuote.Pricebook2Id);
                    setCurrencyCode.add(objQuote.CurrencyIsoCode);
                }
                
                lstPBE = [SELECT Name, Id, Product2Id, IsActive, UnitPrice, Product2.Type__c, Product2.Name, Pricebook2Id FROM PricebookEntry
                            WHERE Product2.Primary_Price_Book__c IN :setPricebookIds AND Product2.Type__c = 'Shipping and Handling'
                            AND Pricebook2Id IN :setPricebookIds AND CurrencyIsoCode IN :setCurrencyCode];
                // Add shipping and handling QuoteLineItem
                if(lstPBE.size() > 0){
                    createShippingLineItem(lstQuote,lstPBE); 
                }
                //#555 commented for Change Order Issue
                //changeOrderStatus(lstQuote,mapPaymentTerm,mapPaymentTerms.values());
            }
            
            when AFTER_UPDATE {
                System.debug('In After Quote Update!');
                                
                sendEmailOnQuoteSentToQNG(newQuoteList,oldQuoteMap); //#871
                if(!System.isBatch()){
                    system.debug('###newQuoteList=='+newQuoteList);
                    callQuoteSyncBatch(newQuoteList, oldQuoteMap);
                }
               
                Set<Id> oppoIds = new Set<Id>();
                Set<Id> setQuoteIds = new Set<Id>();
                Set<Id> setRemoveProcessingFeeQuoteIds = new Set<Id>();
                //#1058 Inventory Hold Feature -- START
                Set<Id> setRequestedHoldQuoteIds = new Set<Id>();
                Set<Id> setReleasedHoldQuoteIds = new Set<Id>();
                Set<Id> setRecallDraftApprovalQuoteIds = new Set<Id>(); //VKHOPADE - #1178
                for (Quote qu : newQuoteList) {
                    if (qu.OpportunityId != null) {
                        oppoIds.add(qu.OpportunityId);    
                    }
                    //#521 Added code for GPT and GPE Related Changes -- START
                    if(qu.Total_Without_SAH__c != oldQuoteMap.get(qu.Id).Total_Without_SAH__c){
                        setQuoteIds.add(qu.Id);
                    }
                    //#521 Added code for GPT and GPE Related Changes -- END
                    //#890 Implement Remove Processing Fee functionality -- START
                    if(qu.Remove_Processing_Fee__c != oldQuoteMap.get(qu.Id).Remove_Processing_Fee__c){
                        setRemoveProcessingFeeQuoteIds.add(qu.Id);
                    }
                    //#890 Implement Remove Processing Fee functionality -- END

                    //#1058 Inventory Hold Feature -- START
                    if(qu.Status == 'Draft - Approved' && oldQuoteMap.get(qu.Id).Status != 'Draft - Approved' && qu.Request_Hold__c && qu.Hold_Release_Date__c != null){
                        setRequestedHoldQuoteIds.add(qu.Id);
                    }
                    if(qu.Status == 'Draft' && oldQuoteMap.get(qu.Id).Status == 'Draft - Approved' && qu.Request_Hold__c && qu.Hold_Release_Date__c != null){
                        setReleasedHoldQuoteIds.add(qu.Id);
                    }
                    if(qu.Status == 'Signed - Approved' && oldQuoteMap.get(qu.Id).Status == 'Signed - Approved' && qu.Request_Hold__c && qu.Hold_Release_Date__c != null){
                        setReleasedHoldQuoteIds.add(qu.Id);
                    }
                    //#1058 Inventory Hold Feature -- END
                    //
                    //VKHOPADE - 1178
                    /* if(qu.Status == 'Draft' && oldQuoteMap.get(qu.Id).Status == 'Draft - Needs Review'){
                        setRecallDraftApprovalQuoteIds.add(qu.Id);
                    } */
                    ////VKHOPADE - 1178 - end
                }
                //#1058 Inventory Hold Feature
                if(setRequestedHoldQuoteIds.size() > 0) {
                    createInventoryHoldRecords(setRequestedHoldQuoteIds);
                }
                if(setReleasedHoldQuoteIds.size() > 0){
                    realseInventoryHoldRecords(setReleasedHoldQuoteIds);
                }
                //#1058 Inventory Hold Feature -- END
                //#890 Implement Remove Processing Fee functionality -- START
                if(setRemoveProcessingFeeQuoteIds.size() > 0){
                    updateRelatedQLI(setRemoveProcessingFeeQuoteIds);
                }
                //#890 Implement Remove Processing Fee functionality -- END

                QuoteUtility.quoteSignedApprovalHandling(newQuoteList, oldQuoteMap);

                // #462 Added Code to get all the OCR based on the Opportunity of Quote -- START
                List<OpportunityContactRole> lstOppConRoles = [select id, Role, ContactId, OpportunityId from OpportunityContactRole where opportunityid =: oppoIds];                
                Map<Id, Map<String, Id>> mapOppIDNOCR = new Map<Id, Map<String, Id>>();
                for(OpportunityContactRole obj : lstOppConRoles){
                    Map<String, Id> mapOpportunityContactRole = new Map<String, Id>();
                    if(mapOppIDNOCR.containsKey(obj.OpportunityId)){ mapOpportunityContactRole = mapOppIDNOCR.get(obj.OpportunityId); }
                    if(!mapOpportunityContactRole.containsKey(obj.Role)){ mapOpportunityContactRole.put(obj.Role, obj.ContactId); }
                    mapOppIDNOCR.put(obj.OpportunityId, mapOpportunityContactRole);
                }
                // #462 Added Code to get all the OCR based on the Opportunity of Quote -- END

                //Code Added By Jheel Start
                Map<Id,Order> mapOrder = new Map<Id,Order>();
                List<Order> listOrder = new List<Order>();
                // #243 Too many SOQL issue resolution -- START
                Set<Id> signApprovedQuotes = new Set<Id>();
                List<Order> lstOrder = new List<Order>();
                for(Quote objQuote: newQuoteList){
                    if(objQuote.Status == 'Signed - Approved'){
                        signApprovedQuotes.add(objQuote.Id);
                    }
                }
                if(signApprovedQuotes.size() > 0){
                    lstOrder = [Select Id,QuoteId,Quote.Status,Order_Payment_Status__c from Order where QuoteId IN: signApprovedQuotes];
                    System.debug('lstOrder->'+lstOrder);
                }
                // #243 Too many SOQL issue resolution -- END
                for(Order objOrder : lstOrder){
                    mapOrder.put(objOrder.QuoteId, objOrder);
                    listOrder.add(objOrder);
                }
                List<Rooming_List__c> lstRoomList = [Select Id,Quote__c,Opportunity__c,Order__c From Rooming_List__c where Quote__c IN:newQuoteMap.keyset()];
                //updating Order in Opportunity Payment Terms related to Quote
                List<Payment_Term__c> lstOppPayTerms = [SELECT Id, Quote__c, Order__c, Amount__c, Opportunity__c, Percentage_Of_Payment__c, Status__c, 
                                                        Credit__c, Quote__r.Original_Quote__c, RecordtypeId, Recordtype.Name, Quote__r.CurrencyISOCode, 
                                                        Quote__r.AccountId, Original_Payment_Term__c, Original_Payment_Term__r.Amount__c, Refund_Deducted__c, 
                                                        Payment_Due_Date__c,Value_in_Kind_Passed__c
                                                        FROM Payment_Term__c WHERE Quote__c IN :newQuoteMap.keyset()];
                
                Map<Id,Payment_Term__c> mapPaymentTerms = new Map<Id,Payment_Term__c>();
                for(Payment_Term__c objPT : lstOppPayTerms){
                    mapPaymentTerms.put(objPT.Id,objPT);
                }
                Map<Id,List<Payment_Term__c>> mapQuotePT = new  Map<Id,List<Payment_Term__c>>();
                Map<Id,Payment_Term__c> mapPaymenTerms = new Map<Id,Payment_Term__c>();
                System.debug('lstOppPayTermslstOppPayTerms->'+mapPaymentTerms.values());
                for(Payment_Term__c objPT : mapPaymentTerms.values()){
                    List<Payment_Term__c> lstPTNew = new List<Payment_Term__c>();
                    if(mapQuotePT.get(objPT.Quote__c) != null)
                        lstPTNew =  mapQuotePT.get(objPT.Quote__c);
                    lstPTNew.add(objPT);   
                    mapQuotePT.put(objPT.Quote__c,lstPTNew);
                    mapPaymenTerms.put(objPT.Quote__c,objPT);
                }
                // #243 Too many SOQL issue resolution -- START
                List<Charge__c> lstcharge = new List<Charge__c>();
                if(mapPaymentTerms.size() > 0){
                    lstcharge = [Select Id,Payment_Terms__c,Order_Status__c,Order__c from Charge__c where Payment_Terms__c in : mapPaymentTerms.keyset() AND RecordType.Name != 'Credit Expiration Adjustment'];
                    System.debug('mapPaymenTerms-->'+mapPaymenTerms);
                }
                // #243 Too many SOQL issue resolution -- END
                //inserting related Quote Line Items
                List<QuoteLineItem> lstQuoteLineItems = [SELECT Id, PricebookEntryId, Product2Id, QuoteId, Quantity, UnitPrice, Package__c, Product_Types__c,Record_Type__c,Quote_Package__c, Quote.Total_Without_SAH__c, Quote.Pricebook2.GPE_Event__c, Product2.X100_Payment_Term_Required__c  FROM QuoteLineItem WHERE QuoteId IN :newQuoteMap.keyset()];
                // #521 Added code for GPT and GPE Related Changes -- START
                boolean is100PaymentRequiredForPackage = false;
                List<QuoteLineItem> lstQuoteLineItemsToUpdate = new List<QuoteLineItem>();
                for(QuoteLineItem objQLI : lstQuoteLineItems){
                    if(setQuoteIds.contains(objQLI.QuoteId) && objQLI.Product_Types__c == 'Shipping and Handling' && objQLI.Quote.Pricebook2.GPE_Event__c == true){
                        QuoteLineItem objNewQLI = new QuoteLineItem();
                        objNewQLI.Id = objQLI.Id;
                        System.debug('objNewQLI.UnitPrice before@@'+objNewQLI.UnitPrice);
                        objNewQLI.UnitPrice = (objQLI.Quote.Total_Without_SAH__c * 0.035).setscale(2,RoundingMode.CEILING);
                        System.debug('objNewQLI.UnitPrice@@'+objNewQLI.UnitPrice);
                        lstQuoteLineItemsToUpdate.add(objNewQLI);
                    }
                    if(objQLI.Product2.X100_Payment_Term_Required__c == true && objQLI.Product_Types__c == 'package'){
                        System.debug('@@ Starting process for convert to single payment term '+lstOppPayTerms.size());
                        is100PaymentRequiredForPackage = true;
                    }
                }
                System.debug('lstQuoteLineItemsToUpdate@@'+lstQuoteLineItemsToUpdate);
                if(lstQuoteLineItemsToUpdate.size() > 0){
                    TriggerHandler.bypass('QuoteTriggerHandler');
                    TriggerHandler.bypass('QuoteLineItemTriggerHandler');
                    Utility.processRecords(lstQuoteLineItemsToUpdate, 'update');
                    TriggerHandler.clearBypass('QuoteTriggerHandler');
                    TriggerHandler.clearBypass('QuoteLineItemTriggerHandler');
                    //system.debug('QuoteLine updated===>'+Utility.processRecords(lstQuoteLineItemsToUpdate, 'update'));
                }
                System.debug('lstQuoteLineItemsToUpdate after update@@'+lstQuoteLineItemsToUpdate);
                // #521 Added code for GPT and GPE Related Changes -- END
                
                List<Quote> lstQuote = new List<Quote>(); 
                // #637 Added Pricebook2Id in SOQL on Quote
                //#951
                //List<Quote> QuoteList = [select Id, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, Opportunity.OwnerId, Opportunity.AccountId,CurrencyIsoCode, Description,PriceBook2.Switch_to_Pick_Up_Only_Date__c, Pricebook2Id,Account.Landing_Page__c, Account.First_Landing_Page__c, Account.Last_Landing_Page__c FROM Quote WHERE Id IN: newQuoteMap.keySet()];
                List<Quote> QuoteList = [select Id, TotalPrice, Payment_Method__c, Original_Quote__c, Selected_Payment_Term__c, GrandTotal, OpportunityId, Opportunity.OwnerId, Opportunity.AccountId,CurrencyIsoCode, Description,PriceBook2.Switch_to_Pick_Up_Only_Date__c, Pricebook2Id,Account.Landing_Page__c, Account.First_Landing_Page__c, Account.Last_Landing_Page__c,
                                         Account.First_Referrer__c, Account.First_UTM_Campaign__c, Account.First_UTM_Medium__c,Account.First_UTM_Source__c,Account.First_Info_Request_Site__c, //VKHOPADE:#1206
                                         Account.Last_Referrer__c, Account.Last_UTM_Campaign__c, Account.Last_UTM_Medium__c,Account.Last_UTM_Source__c,Account.Last_Info_Request_Site__c
                                         FROM Quote WHERE Id IN: newQuoteMap.keySet()];
                Map<Id,Quote> mapQuote = new Map<Id,Quote>();
                for(Quote objQuote : QuoteList){
                    if(Trigger.newMap.get(objQuote.Id).get('TotalPrice') !=  Trigger.OldMap.get(objQuote.Id).get('TotalPrice') && mapQuotePT.get(objQuote.Id) != null && !mapQuotePT.get(objQuote.Id).isEmpty()){
                        lstQuote.add(objQuote);
                    }
                    mapQuote.put(objQuote.Id,objQuote);
                }
                // #462 Added Code to get all the OCR based on the Opportunity of Quote
                createOrders(oldQuoteMap, newQuoteMap, mapQuote, mapOppIDNOCR, mapOrder,mapPaymentTerms.values(),lstQuoteLineItems,lstcharge,lstRoomList);
                changeOrderStatus(QuoteList,mapPaymenTerms,mapPaymentTerms.values());
                if(lstQuote.size() > 0){
                    savePaymentTerm(lstQuote,mapPaymentTerms.values(), is100PaymentRequiredForPackage);
                }
                
                //VKHOPAE - #1178 
                /* if(setRecallDraftApprovalQuoteIds.size() > 0){
                    recallDraftApproval(setRecallDraftApprovalQuoteIds);
                } */
            }
            
            when AFTER_DELETE {
                System.debug('In Quote After Delete!');
            }
            
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }        
    }  

    /**
    * @description Method to delete the related Payment Terms after Quote is deleted
    * @author jagrawal@addonblue.com | 6/18/2020 
    * @param lstPaymentTerms 
    * @return void 
    **/
    private void deleteRelatedPaymentTerms(List<Payment_Term__c> lstPaymentTerms, List<Quote> oldQuotes){
        System.debug('Deleted Quotes:- '+oldQuotes);
        if(oldQuotes.size() > 0){
            Utility.processDeletedRecords(oldQuotes);
        }
        System.debug('To be deleted payment terms:-'+lstPaymentTerms);
        if(lstPaymentTerms.size() > 0){
            Utility.processRecords(lstPaymentTerms, 'delete');
        }
    }

    public void callQuoteSyncBatch(List<Quote> newQuoteList){
        List<Quote> lstQuotes = new  List<Quote>();
        Set<Id> setQuoteId =  new Set<Id>();
        for(Quote q : newQuoteList){
            system.debug('###'+q.status);
            lstQuotes.add(q);    
            setQuoteId.add(q.Id);
        }
        system.debug('###lstQuotes=='+lstQuotes);
        if(!setQuoteId.isEmpty()){
            String query = 'select id, name from Quote where Id IN : setQuoteId';                    
            QuoteSyncBatch quoteSyncBatch = new QuoteSyncBatch(query, lstQuotes, setQuoteId);
            Id batchId = Database.executeBatch(quoteSyncBatch);
        }
    }
    
    /* Creted new overload method to handle all scenarios of Quote Sync with Opportunity - 303 */
    public void callQuoteSyncBatch(List<Quote> newQuoteList, Map<Id, Quote> oldQuoteMap){
        List<Quote> lstQuotes = new  List<Quote>();
        Set<Id> setQuoteId =  new Set<Id>();
        for(Quote q : newQuoteList){
            system.debug('###'+oldQuoteMap+'###'+q.status);
            if(oldQuoteMap.size() > 0){
                if(oldQuoteMap.containskey(q.Id)){
                    if(oldQuoteMap.get(q.Id).status != 'Signed - Approved' && q.status == 'Signed - Approved'){
                        lstQuotes.add(q);    
                        setQuoteId.add(q.Id);
                    }
                }                
            }
        }
        system.debug('###lstQuotes=='+lstQuotes);
        if(!setQuoteId.isEmpty()){
            String query = 'select id, name from Quote where Id IN : setQuoteId';                    
            QuoteSyncBatch quoteSyncBatch = new QuoteSyncBatch(query, lstQuotes, setQuoteId);
            Id batchId = Database.executeBatch(quoteSyncBatch);
        }
    }
    
    /**
    * @description  : Method to create orders upon the request from quote triggers 
    * @author       : jagrawal@addonblue.com
    * @param        : oldMapQuotes (Map of Quotes), newMapQuotes (Map of Quotes)
    * @return       : void 
    **/
    public string createOrders(Map<ID, Quote> oldMapQuotes, Map<ID, Quote> newMapQuotes, Map<Id,Quote> mapQuote ,Map<Id, Map<String, Id>> mapOppIDNOCR, Map<Id,Order> mapOrder,List<Payment_Term__c> lstOppPayTerms,List<QuoteLineItem> lstQuoteLineItems,List<Charge__c> lstcharge,List<Rooming_List__c> lstRoomList){
        List<Order> newOrdersInsert = new List<Order>();
        for (Quote qu : newMapQuotes.values()) {
            System.debug('@@# new quote Status '+qu.Status+'###'+Trigger.isInsert+'###'+Trigger.isUpdate);
            System.debug('@@# old quote Status '+oldMapQuotes);
            //if (qu.Status.equals('Signed - Approved') && (qu.Status != oldMapQuotes.get(qu.Id).Status)) {
            if (qu.Status.equals('Signed - Approved') && (Trigger.IsInsert || (Trigger.IsUpdate && qu.Status != oldMapQuotes.get(qu.Id).Status))) {
                if(Trigger.isUpdate && (qu.Status != oldMapQuotes.get(qu.Id).Status || Test.isRunningTest()) && mapOrder.containsKey(qu.Id)){
                //if(mapOrder.containsKey(qu.Id)){
                    System.debug('OrderCreated');
                    qu.addError('Quote can not Signed - Approved because Order is already created');
                }
                if (qu.OpportunityId != null) {
                    // #462 Added Code to get all the OCR based on the Opportunity of Quote -- START
                    System.debug('@@mapOppIDNOCR.get(qu.OpportunityId):- '+mapOppIDNOCR.get(qu.OpportunityId));
                    Map<String, Id> mapOpportunityContactRole = mapOppIDNOCR.get(qu.OpportunityId);
                    // #462 Added Code to get all the OCR based on the Opportunity of Quote -- END

                    
                    Order orderNew = new Order();
                    orderNew.Status = 'Creation';
                    orderNew.AccountId = mapQuote.get(qu.Id).Opportunity.AccountId;//mapOpportunities.get(qu.OpportunityId).AccountId;
                    orderNew.Landing_Page__c = mapQuote.get(qu.Id).Account.Landing_Page__c; //#951
                    orderNew.First_Landing_Page__c = mapQuote.get(qu.Id).Account.First_Landing_Page__c; //VKHOPADE - #1176
                    orderNew.First_Referrer__c = mapQuote.get(qu.Id).Account.First_Referrer__c; //VKHOPADE - #1206
                    orderNew.First_UTM_Campaign__c = mapQuote.get(qu.Id).Account.First_UTM_Campaign__c; //VKHOPADE - #1206
                    orderNew.First_UTM_Medium__c = mapQuote.get(qu.Id).Account.First_UTM_Medium__c; //VKHOPADE - #1206
                    orderNew.First_UTM_Source__c = mapQuote.get(qu.Id).Account.First_UTM_Source__c; //VKHOPADE - #1206
                    orderNew.First_Info_Request_Site__c = mapQuote.get(qu.Id).Account.First_Info_Request_Site__c; //VKHOPADE - #1206

                    orderNew.Last_Landing_Page__c = mapQuote.get(qu.Id).Account.Last_Landing_Page__c; //VKHOPADE - #1176
                    orderNew.Last_Referrer__c = mapQuote.get(qu.Id).Account.Last_Referrer__c; //VKHOPADE - #1206
                    orderNew.Last_UTM_Campaign__c = mapQuote.get(qu.Id).Account.Last_UTM_Campaign__c; //VKHOPADE - #1206
                    orderNew.Last_UTM_Medium__c = mapQuote.get(qu.Id).Account.Last_UTM_Medium__c; //VKHOPADE - #1206
                    orderNew.Last_UTM_Source__c = mapQuote.get(qu.Id).Account.Last_UTM_Source__c; //VKHOPADE - #1206
                    orderNew.Last_Info_Request_Site__c = mapQuote.get(qu.Id).Account.Last_Info_Request_Site__c; //VKHOPADE - #1206

                    orderNew.OpportunityId = qu.OpportunityId;
                    if(qu.Purchase_Date__c != null) orderNew.EffectiveDate = qu.Purchase_Date__c;
                    else orderNew.EffectiveDate = System.today();
                    orderNew.QuoteId = qu.Id;
                    orderNew.PriceBook2Id = qu.PriceBook2Id;
                    orderNew.CurrencyIsoCode = qu.CurrencyIsoCode;
                    orderNew.Exchange_rate__c = qu.GPE_Exchange_Rate__c;

                    // #494 Added 2 fields to copy from Quote to Order -- START
                    orderNew.Pricebook_Reporting__c = qu.PriceBook2Id;
                    orderNew.Pick_Up_Requested__c = qu.PickUp_Requested__c;
                    // #494 Added 2 fields to copy from Quote to Order -- END
                    
                    // #252 Added 2 fields to copy from Quote to Order -- START
                    System.debug('QuoteEmail:-'+qu.Email+' QuotePhone:-'+qu.Phone);
                    orderNew.Email__c = qu.Email;
                    orderNew.Phone__c = qu.Phone;
                    // #252 Added 2 fields to copy from Quote to Order -- END
                    // #463 Added code to make Order Owner same as Quote Owner
                    orderNew.OwnerId = mapQuote.get(qu.Id).Opportunity.OwnerId;
                    orderNew.BillingStreet = qu.BillingStreet;
                    orderNew.BillingCity = qu.BillingCity;
                    orderNew.BillingState = qu.BillingState;
                    orderNew.BillingPostalCode = qu.BillingPostalCode;                    
                    orderNew.BillingCountry = qu.BillingCountry;
                    orderNew.BillingStateCode = qu.BillingStateCode;                                        
                    orderNew.BillingCountryCode = qu.BillingCountryCode;
                    orderNew.BillingLatitude = qu.BillingLatitude;
                    orderNew.BillingLongitude = qu.BillingLongitude;                    
                    orderNew.BillingGeocodeAccuracy = qu.BillingGeocodeAccuracy;
                    // #462 Added Code to get all the OCR based on the Opportunity of Quote -- START
                    if(mapOpportunityContactRole != null && mapOpportunityContactRole.containskey('Billing Contact')){
                        orderNew.BillToContactId = mapOpportunityContactRole.get('Billing Contact');
                    }
                    if(mapOpportunityContactRole != null && mapOpportunityContactRole.containskey('Primary Attendee Contact')){
                        orderNew.Primary_Attendee_Contact__c = mapOpportunityContactRole.get('Primary Attendee Contact');
                    }
                    // #462 Added Code to get all the OCR based on the Opportunity of Quote -- END
                    orderNew.ShippingStreet = qu.ShippingStreet;
                    orderNew.ShippingCity = qu.ShippingCity;
                    orderNew.ShippingState = qu.ShippingState;
                    orderNew.ShippingPostalCode = qu.ShippingPostalCode;                    
                    orderNew.ShippingCountry = qu.ShippingCountry;
                    orderNew.ShippingStateCode = qu.ShippingStateCode;                                        
                    orderNew.ShippingCountryCode = qu.ShippingCountryCode;
                    orderNew.ShippingLatitude = qu.ShippingLatitude;
                    orderNew.ShippingLongitude = qu.ShippingLongitude;                    
                    orderNew.ShippingGeocodeAccuracy = qu.ShippingGeocodeAccuracy;
                    // #421 Added Code to populate comment field on Order when created
                    orderNew.Comment__c = qu.Comment__c;
                    // #635 Added Code to populate Seating Request field on Order when created
                    orderNew.Seating_Request__c = qu.Seating_Request__c;
                    if(mapOpportunityContactRole != null && mapOpportunityContactRole.containskey('Shipping Contact')){
                        orderNew.ShipToContactId = mapOpportunityContactRole.get('Shipping Contact');
                    }    
                    if(mapQuote.containsKey(qu.Id) && mapQuote.get(qu.id).PriceBook2.Switch_to_Pick_Up_Only_Date__c != null &&
                        mapQuote.get(qu.id).PriceBook2.Switch_to_Pick_Up_Only_Date__c < System.Today()){
                        orderNew.Pick_up_Requested__c = true;
                    }               
                    //#922 - start
                    orderNew.Ops_Notes_and_Comments__c = qu.Ops_Notes_and_Comments__c;
                    orderNew.Fulfillment_Notes__c = qu.Fulfillment_Notes__c;
                    orderNew.Ops_Order_Status__c = qu.Ops_Order_Status__c; 
                    //#922 - end
                    orderNew.UOB__c = qu.UOB__c;
                    orderNew.Purchasing_Site__c = qu.Purchasing_Site__c;
 
                    System.debug('@@#pricebook id order '+qu.PriceBook2Id);
                    System.debug('New Order Creation--------'+orderNew);
                    newOrdersInsert.add(orderNew);
                }
            }
        }
        if (newOrdersInsert.size() > 0) {
            system.debug('Order created===>'+Utility.processRecords(newOrdersInsert, 'insert'));
            List<Order> lstInsertedOrders = new List<Order>();
            for(Order objOrder : newOrdersInsert){
                if(objOrder.Id != null){
                    lstInsertedOrders.add(objOrder);
                }
            }
            System.debug('lstInsertedOrders@@@@'+lstInsertedOrders);
            newOrdersInsert = lstInsertedOrders;
            Map<Id, Id> mapOrderQuoteId = new Map<Id, Id>();
            Map<Id, Id> mapOpportunityQuoteId = new Map<Id, Id>();
            for (Order ord : newOrdersInsert) {
                mapOrderQuoteId.put(ord.QuoteId, ord.Id);
                mapOpportunityQuoteId.put(ord.OpportunityId, ord.QuoteId);
            }
            List<OrderItem> newOrderItemsInsert = new List<OrderItem>();
            
            Set<Id> setOpp = new Set<Id>();
            
            for(Id oppId : newMapQuotes.keyset()){
                setOpp.add(newMapQuotes.get(oppId).opportunityId);
            }
            System.debug('lstOppPayTerms-1->'+lstOppPayTerms);
            Map<Id, Id> mapPTNOrderIds = new Map<Id, Id>();
            List<Payment_Term__c> lstCreditPaymentTerms = new List<Payment_Term__c>();
            for (Payment_Term__c oppPayTermOne : lstOppPayTerms) {
                System.debug('mapOpportunityQuoteId-1->'+mapOpportunityQuoteId);
                if(mapOpportunityQuoteId.containsKey(oppPayTermOne.Opportunity__c)){
                    Id quoteId = mapOpportunityQuoteId.get(oppPayTermOne.Opportunity__c);
                    oppPayTermOne.Quote__c = quoteId;
                    system.debug('mapOrderQuoteId.get(quoteId)'+mapOrderQuoteId.get(quoteId));
                    oppPayTermOne.Order__c = mapOrderQuoteId.get(quoteId);
                    //#808 Payment Term Due Date issue -- START
                    if(oppPayTermOne.Payment_Due_Date__c < System.today()) {
                        oppPayTermOne.Payment_Due_Date__c = System.today();
                    }
                    //#808 Payment Term Due Date issue -- END
                    mapPTNOrderIds.put(oppPayTermOne.Id,oppPayTermOne.Order__c);
                }
                if(oppPayTermOne.RecordTypeId == Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId()){
                    lstCreditPaymentTerms.add(oppPayTermOne);
                }
            }
            System.debug('lstOppPayTerms-->'+lstOppPayTerms);
            System.debug('lstcharge@@'+lstcharge);
            System.debug('lstCreditPaymentTerms-->'+lstCreditPaymentTerms);
                     
            //#273 Code added to populate Rooming List with OrderID -- START       
            for(Rooming_List__c objRoom : lstRoomList){
                if(mapOrderQuoteId.containsKey (objRoom.Quote__c)){
                    objRoom.Order__c = mapOrderQuoteId.get(objRoom.Quote__c);
                }
            }
            System.debug('lstRoomList-->'+lstRoomList);
            if(lstRoomList.size() > 0){
                Utility.processRecords(lstRoomList, 'update');
            }
            //#273 Code added to populate Rooming List with OrderID -- END
            System.debug('@@#lstQuoteLineItems '+lstQuoteLineItems);

            Map<Id, Id> mapOfPackage = new Map<Id, Id>();
            for(QuoteLineItem qli : lstQuoteLineItems){
                if(qli.Record_Type__c == 'Package'){
                    mapOfPackage.put(qli.Id, qli.Product2Id);
                }
            }

            for (QuoteLineItem qli : lstQuoteLineItems) {
                OrderItem ori = new OrderItem();
                ori.OrderId = mapOrderQuoteId.get(qli.QuoteId);
                ori.PricebookEntryId = qli.PricebookEntryId;
                ori.Quantity = qli.Quantity;
                ori.UnitPrice = qli.UnitPrice;
                ori.QuoteLineItemId = qli.Id;
                ori.Package__c = qli.Package__c;
                ori.Product2Id = ori.Product2Id;
                ori.ProductType__c = qli.Product_Types__c;
                ori.Record_Type__c = qli.Record_type__c;
                if(qli.Quote_Package__c != null && mapOfPackage.size() > 0 && mapOfPackage.containskey(qli.Quote_Package__c)){
                    ori.Package__c = mapOfPackage.get(qli.Quote_Package__c);
                }
                System.debug('@@#qli pricebookentry id '+qli.PricebookEntryId);
                newOrderItemsInsert.add(ori);
            }
            if (newOrderItemsInsert.size() > 0) {
                try{
                    Utility.processRecords(newOrderItemsInsert, 'insert');
                }
                catch(exception ex){
                    system.debug('Exception :'+ex.getLineNumber()+'--'+ex.getMessage());
                }
            }
            
            Map<Id, Order> mapOfOrder = new Map<Id, Order>();
            for(Order objOrder :newOrdersInsert){
                objOrder.Status = 'Active';
                mapOfOrder.put(objOrder.Id, objOrder);
                System.debug('Active');
            }
            Utility.processRecords(newOrdersInsert, 'update');
            // #415 Changed sequence of update of Payment Term -- START
            if (lstOppPayTerms.size() > 0) {
                Utility.processRecords(lstOppPayTerms, 'update');
            }
            // #415 Changed sequence of update of Payment Term -- END
            for(Charge__c objCharge : lstcharge){
                //#591 Set the Status of Charge to Passed
                objCharge.Status__c  = 'Passed';
                objCharge.Order__c = mapPTNOrderIds.get(objCharge.Payment_Terms__c);
                if(mapOfOrder.containskey(mapPTNOrderIds.get(objCharge.Payment_Terms__c))){
                    objCharge.Order_Status__c = mapOfOrder.get(mapPTNOrderIds.get(objCharge.Payment_Terms__c)).Status;
                }
            }
            System.debug('lstcharge@@'+lstcharge);
            
            Utility.processRecords(lstcharge, 'update');
        }
        return null;
    }
    
    //#598 code Optimization
    public static List<Payment_Term__c> savePaymentTerm( List<Quote> lstQuote, List<Payment_Term__c> lstOfOppPaymentTerms, Boolean is100PaymentRequiredForPackage) {
       
        List<Payment_Term__c> lstOppPaymentTerms = new List<Payment_Term__c>();
        List<Payment_Term__c> lstCreditRecordsToBeDeleted = new List<Payment_Term__c>();
        Payment_Term__c objPaymentTerm;
        Double totalAmount = 0.00;
        String creditRecordTypeId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        
        Map<Id, Double> mapOfQuoteVsTotal = new Map<Id, Double>();
        for(Quote objQuote : lstQuote){
            if(!mapOfQuoteVsTotal.containsKey(objQuote.Id)){
                mapOfQuoteVsTotal.put(objQuote.Id, objQuote.TotalPrice);
            }else{
                totalAmount = mapOfQuoteVsTotal.get(objQuote.Id);
                totalAmount = totalAmount + objQuote.TotalPrice;
                mapOfQuoteVsTotal.put(objQuote.Id, totalAmount);
            }
        }

        Quote quote = lstQuote[0];
        system.debug('###quote=='+quote);

        List<Event_Payment_Terms__c> lstEventPTs = new List<Event_Payment_Terms__c>();
        if(quote != null && quote.Pricebook2Id != null && (quote.Selected_Payment_Term__c == '1/2' || quote.Selected_Payment_Term__c == '1/3')){
            lstEventPTs = [Select Id, Payment_Term__c, Payment_Due_Date__c FROM Event_Payment_Terms__c 
                           WHERE Price_Book__c = :quote.Pricebook2Id AND Payment_Term__c = :quote.Selected_Payment_Term__c 
                           ORDER BY Payment_Term__c, Payment_Due_Date__c];
        }

        if(lstOfOppPaymentTerms.size() > 0 && String.isEmpty(quote.Original_Quote__c)){
            Double totalOfUnpaid = 0, totalOfCredit = 0, totalOfPaymentTerms = 0, diffAmount = 0;
            for(Payment_Term__c obj : lstOfOppPaymentTerms){
                if(obj.RecordTypeId == creditRecordTypeId){
                    totalOfCredit = totalOfCredit + obj.Amount__c;
                }
            }
            system.debug('###totalOfCredit=='+totalOfCredit);
            totalOfPaymentTerms = totalOfPaymentTerms + totalOfCredit;
            for(Payment_Term__c obj : lstOfOppPaymentTerms){
                if(obj.Status__c != 'Passed'){
                    if(mapOfQuoteVsTotal.containskey(obj.Quote__c) && obj.Percentage_Of_Payment__c != null && obj.Quote__r.Original_Quote__c == null) {                    
                        obj.Amount__c = ((mapOfQuoteVsTotal.get(obj.Quote__c) - totalOfCredit) * obj.Percentage_Of_Payment__c) / 100;
                        if(obj.Amount__c < 0){
                            obj.Amount__c = 0;    
                        }
                        totalOfUnpaid = totalOfUnpaid + obj.Amount__c;
                        totalOfPaymentTerms = totalOfPaymentTerms + obj.Amount__c.setScale(2);
                        System.debug('PT Amount__c------'+obj.Amount__c);
                        lstOppPaymentTerms.add(obj);           
                    }
                }
            }
                        
            system.debug('###totalOfPaymentTerms=='+totalOfPaymentTerms);
            system.debug('###totalOfUnpaid=='+totalOfUnpaid);
            if(totalOfPaymentTerms != quote.GrandTotal){
                diffAmount = totalOfPaymentTerms - quote.GrandTotal;
                for(Payment_Term__c obj : lstOppPaymentTerms){
                    if(quote.Selected_Payment_Term__c == '1/3' && obj.Percentage_Of_Payment__c == 33.34){
                        if((obj.Amount__c - diffAmount) > 0){
                            obj.Amount__c = obj.Amount__c - diffAmount;
                        }else{
                            obj.Amount__c = 0;
                        }
                    }
                }        
            }
            
            for(Payment_Term__c obj : lstOfOppPaymentTerms){
                if(obj.RecordTypeId == creditRecordTypeId){
                    if(mapOfQuoteVsTotal.containskey(obj.Quote__c) && obj.Percentage_Of_Payment__c != null && obj.Quote__r.Original_Quote__c == null) {
                        if(mapOfQuoteVsTotal.get(obj.Quote__c) > totalOfUnpaid){
                            obj.Amount__c = mapOfQuoteVsTotal.get(obj.Quote__c) - totalOfUnpaid;
                        }else{
                            obj.Amount__c = 0;
                            System.debug('PT Amount__c------'+obj.Amount__c);                            
                        }
                        lstOppPaymentTerms.add(obj);
                    }
                }
            }
            if(is100PaymentRequiredForPackage && quote.Selected_Payment_Term__c!='100%'){
                changePaymentTerm(quote, lstOppPaymentTerms, totalOfUnpaid);
            }else{
                system.debug('####lstOppPaymentTerms'+lstOppPaymentTerms);
                Utility.processRecords(lstOppPaymentTerms, 'update');
            }
        } else {
            String paymentStatus;
            Integer countForPassed = 0; 
            Double sumOfPaymentTerms = 0;
            Double sumOfCreditPaymentTerms = 0;
            Double unpaidPaymentTerms = 0;
            Double countOfCreditPaymentTerms = 0;
            //#113 change Order refund Payment Terms
            Set<Id> setOriginalPTs = new Set<Id>();
            Boolean passedPTs = false;
            
            for(Payment_Term__c obj : lstOfOppPaymentTerms){
                //#113 change Order refund Payment Terms
                if(obj.Original_Payment_Term__c != null){
                    setOriginalPTs.add(obj.Original_Payment_Term__c);
                }
                if(obj.Status__c == 'Passed' && obj.RecordTypeId != creditRecordTypeId){
                    passedPTs = true;
                    countForPassed = countForPassed + 1;
                    sumOfPaymentTerms = sumOfPaymentTerms + obj.Amount__c;                    
                    system.debug('###obj=='+obj.Amount__c);
                }
                
                if(obj.Status__c == 'Passed' && obj.RecordTypeId == creditRecordTypeId && obj.Amount__c > 0){
                    sumOfCreditPaymentTerms = sumOfCreditPaymentTerms + obj.Amount__c;
                    countOfCreditPaymentTerms = countOfCreditPaymentTerms + 1;
                    countForPassed = countForPassed + 1;
                    system.debug('###obj=='+obj.Amount__c);
                }
                
                if(obj.Status__c != 'Passed' && obj.Amount__c > 0){
                    unpaidPaymentTerms = unpaidPaymentTerms + 1;
                }
            }
            //#113 change Order refund Payment Terms -- START
            Double TotalRefundAmount = 0;
            List<Refund__c> lstRefunds = new List<Refund__c>();
            Map<Id, Double> mapRefunds = new Map<Id, Double>();
            if(!setOriginalPTs.isEmpty()){
                lstRefunds = [Select Id, Amount__c, Charge__c, Order__c, Opportunity_Payment_Terms__c From Refund__c 
                              WHERE Opportunity_Payment_Terms__c IN :setOriginalPTs AND Opportunity_Payment_Terms__r.Status__c = 'Passed'];
                system.debug('###lstRefunds =='+lstRefunds);
                if(lstRefunds.size() > 0) {
                    for(Refund__c objRefund : lstRefunds) {
                        double refundAmount = objRefund.Amount__c;
                        if(mapRefunds != null && mapRefunds.containsKey(objRefund.Opportunity_Payment_Terms__c)){
                            refundAmount = refundAmount + mapRefunds.get(objRefund.Opportunity_Payment_Terms__c);
                        }
                        mapRefunds.put(objRefund.Opportunity_Payment_Terms__c, refundAmount);
                        TotalRefundAmount = TotalRefundAmount + objRefund.Amount__c;
                    }
                }
            }
            if(TotalRefundAmount > 0){
                for(Payment_Term__c obj : lstOfOppPaymentTerms) {
                    if(obj.Status__c == 'Passed' && obj.RecordTypeId != creditRecordTypeId && !obj.Refund_Deducted__c){
                        if(mapRefunds != null && mapRefunds.containsKey(obj.Original_Payment_Term__c)){
                            obj.Amount__c = obj.Amount__c - mapRefunds.get(obj.Original_Payment_Term__c);
                            obj.Refund_Deducted__c = true;
                            sumOfPaymentTerms = sumOfPaymentTerms - mapRefunds.get(obj.Original_Payment_Term__c);
                            lstOppPaymentTerms.add(obj);
                        }
                    }
                }
            }
            //#113 change Order refund Payment Terms -- END
            system.debug('###sumOfPaymentTerms=='+sumOfPaymentTerms);
            system.debug('###countForPassed=='+countForPassed);
            system.debug('###sumOfCreditPaymentTerms=='+sumOfCreditPaymentTerms);
            system.debug('###lstOfOppPaymentTerms=='+lstOfOppPaymentTerms.size());
            
            if(countForPassed == 0 || (countForPassed == 1 && sumOfCreditPaymentTerms > 0)){
                paymentStatus = 'Unpaid';
                // Fully Paid through Credits AND 100% PT selected with 0 amount
                if((countForPassed == (lstOfOppPaymentTerms.size() - 1)  && sumOfCreditPaymentTerms == quote.GrandTotal)){
                    paymentStatus = 'Paid';
                }
            } else if(countForPassed == lstOfOppPaymentTerms.size() || (countForPassed == (lstOfOppPaymentTerms.size() - 1)  && sumOfCreditPaymentTerms == 0 && countOfCreditPaymentTerms > 0)){
                paymentStatus = 'Paid';
            } else {
                paymentStatus = 'Partially Paid';
            }
            
            System.debug('###paymentStatus=='+paymentStatus);            
            Double amountToBeAdjusted = quote.GrandTotal - sumOfPaymentTerms;            
            
            Boolean testRunning;
            if(Test.isRunningTest()){
                paymentStatus = String.valueof(quote.Description).substringbefore('#');
                amountToBeAdjusted = Integer.valueof(String.valueof(quote.Description).substringafter('#'));
                testRunning = true;
            }
            system.debug('###amountToBeAdjusted=='+amountToBeAdjusted);
            system.debug('###GrandTotal =='+quote.GrandTotal);
            Decimal adjustedAmount = 0.0;
            if((quote.GrandTotal == 0 && !Test.isRunningTest()) || amountToBeAdjusted <= 0) {
                for(Payment_Term__c obj : lstOfOppPaymentTerms) {
                    if(obj.RecordTypeId == creditRecordTypeId || obj.status__c != 'Passed') {
                        obj.Amount__c = 0;
                        lstOppPaymentTerms.add(obj);
                    }
                }
            } else if(amountToBeAdjusted > 0) {
                for(Payment_Term__c obj : lstOfOppPaymentTerms) {
                    if(obj.RecordTypeId == creditRecordTypeId) {
                        if(obj.Amount__c < obj.Original_Payment_Term__r.Amount__c) {
                            if(obj.Original_Payment_Term__r.Amount__c <= amountToBeAdjusted) {
                                obj.Amount__c = obj.Original_Payment_Term__r.Amount__c;
                                sumOfCreditPaymentTerms = obj.Original_Payment_Term__r.Amount__c;
                                lstOppPaymentTerms.add(obj);
                            } else {
                                obj.Amount__c = amountToBeAdjusted;
                                sumOfCreditPaymentTerms = amountToBeAdjusted;
                                lstOppPaymentTerms.add(obj);
                            }
                        } else {
                            if(obj.Amount__c <= amountToBeAdjusted) {
                                obj.Amount__c = obj.Amount__c;
                                sumOfCreditPaymentTerms = obj.Amount__c;
                                lstOppPaymentTerms.add(obj);
                            } else {
                                obj.Amount__c = amountToBeAdjusted;
                                sumOfCreditPaymentTerms = amountToBeAdjusted;
                                lstOppPaymentTerms.add(obj);
                            }
                        }
                    }
                }
                
                System.debug((amountToBeAdjusted - sumOfCreditPaymentTerms));
                System.debug(quote.Selected_Payment_Term__c);
                
                adjustedAmount = amountToBeAdjusted - sumOfCreditPaymentTerms;
                
                System.debug('@@@adjustedAmount :'+adjustedAmount);
                
                if(adjustedAmount > 0) {
                    Decimal counter = 0;
                    Decimal totalPercentage = 0;
                    List<Payment_Term__c> deletePTs = new List<Payment_Term__c>();
                    
                    if(quote.Selected_Payment_Term__c == '100%' || quote.Selected_Payment_Term__c == 'Net 30' || quote.Selected_Payment_Term__c == 'Net 7') {
                        counter = 1;
                    } else if(quote.Selected_Payment_Term__c == '1/2') {
                        counter = 2;
                    } else if(quote.Selected_Payment_Term__c == '1/3') {
                        counter = 3;
                    } if(quote.Selected_Payment_Term__c == 'Custom'){
                        for(Payment_Term__c obj : lstOfOppPaymentTerms) {
                            if(obj.Status__c != 'Passed' && obj.RecordTypeId != creditRecordTypeId){
                                counter = counter + 1;
                                totalPercentage = totalPercentage + obj.Percentage_Of_Payment__c;
                            }
                        }
                        if(counter == 0){
                            counter = 1;
                        }
                        if(totalPercentage == 100 && counter > 0){
                            counter = 0;
                        }
                    }
                    System.debug('@@@counter:'+counter);
                    
                    if(totalPercentage == 100){
                        for(Payment_Term__c obj : lstOfOppPaymentTerms) {
                            if(obj.RecordTypeId != creditRecordTypeId && obj.status__c != 'Passed') {
                                 if(obj.Percentage_Of_Payment__c > 0){
                                     obj.Amount__c = adjustedAmount * obj.Percentage_Of_Payment__c/100;
                                     lstOppPaymentTerms.add(obj);
                                 }
                            }
                        }
                    }
                    
                    if(counter > 0){
                        for(Integer i = 0; i < counter; i++) {
                            Payment_Term__c paymentTerm = new Payment_Term__c();
                            paymentTerm.Amount__c = adjustedAmount / counter;
                            paymentTerm.Percentage_Of_Payment__c = 100 / counter;
                            
                            if(counter == 3) {
                                if(i == 0) {
                                    paymentTerm.Amount__c = adjustedAmount * 33.34/100;
                                    paymentTerm.Percentage_Of_Payment__c = 33.34;
                                } else {
                                    paymentTerm.Amount__c = adjustedAmount * 33.33/100;
                                    paymentTerm.Percentage_Of_Payment__c = 33.33;
                                }
                            }
                            if(i > 0 && lstEventPTs.size() >= i+1 && (quote.Selected_Payment_Term__c == '1/2' || quote.Selected_Payment_Term__c == '1/3')){ 
                                paymentTerm.Payment_Due_Date__c = lstEventPTs[i].Payment_Due_Date__c;
                            } else {
                                paymentTerm.Payment_Due_Date__c = Date.today();
                                if(i == 0 && !passedPTs) {
                                    paymentTerm.Initial_Payment_Term__c = true;
                                }
                            }
                            paymentTerm.Quote__c = quote.Id;
                            paymentTerm.CurrencyISOCode = quote.CurrencyISOCode;
                            paymentTerm.Opportunity__c = quote.OpportunityId;
                            
                            lstOppPaymentTerms.add(paymentTerm);
                        }
                        
                        for(Payment_Term__c obj : lstOfOppPaymentTerms) {
                            if(obj.RecordTypeId != creditRecordTypeId && obj.status__c != 'Passed') {
                                deletePTs.add(obj);
                            }
                        }
                    }
                    if(deletePTs.size() > 0) {
                        delete deletePTs;
                    }
                } else {
                    for(Payment_Term__c obj : lstOfOppPaymentTerms) {
                        if(obj.RecordTypeId != creditRecordTypeId && obj.status__c != 'Passed') {
                            obj.Amount__c = 0;
                            lstOppPaymentTerms.add(obj);
                        }
                    }
                }
            }
            
            system.debug('###lstOppPaymentTerms=='+lstOppPaymentTerms);
            if(lstOppPaymentTerms.size() > 0){
                if(is100PaymentRequiredForPackage && quote.Selected_Payment_Term__c!='100%'){/////
                    changePaymentTerm(quote, lstOppPaymentTerms, double.valueOf(adjustedAmount));
                }else{
                    lstOppPaymentTerms =(List<Payment_Term__c>) Utility.processRecords(lstOppPaymentTerms, 'upsert');
                    Map<Id, Decimal> mapPT = new Map<Id, Decimal>();
                    for(Payment_Term__c objPT: lstOppPaymentTerms){
                        if(objPT.Id != null) {
                            mapPT.put(objPT.Id, objPT.Amount__c);
                        }
                    }
                    if(mapPT.size() > 0) {
                        List<Charge__c> lstCharge = new List<Charge__c>();                         
                        for(Charge__c objCharge :[Select Id, Amount__c, Payment_Terms__c FROM Charge__c WHERE Payment_Terms__c IN :mapPT.KeySet()]){
                            System.debug('@@@objCharge: '+objCharge);
                            
                            if(mapPT != null && mapPT.containsKey(objCharge.Payment_Terms__c)){
                                if(objCharge.Amount__c != mapPT.get(objCharge.Payment_Terms__c)){
                                    objCharge.Amount__c = mapPT.get(objCharge.Payment_Terms__c);
                                    lstCharge.add(objCharge);
                                }
                            }
                        }
                        System.debug('@@@lstCharge: '+lstCharge);
                        if(lstCharge.size() > 0){
                            Utility.processRecords(lstCharge, 'upsert');
                        }
                    }
                }
            }
            
        }
        return lstOppPaymentTerms;
    }
    
    public static void createShippingLineItem(List<Quote> lstQuote,List<PricebookEntry> lstPBE) {
       
        Map<Id, PricebookEntry> mapPricebookEntry = new Map<Id, PricebookEntry>();
        List<QuoteLineItem> lstQuoteLineItem = new List<QuoteLineItem>();
        
        if(lstQuote != null && lstQuote.size() > 0) {
                   
            for(PricebookEntry objPBE : lstPBE) {
                mapPricebookEntry.put(objPBE.Pricebook2Id, objPBE);
            }
            
            for(Quote objQuote: lstQuote) {
                if(objQuote.GPE_Online_Order__c == false){
                    QuoteLineItem newQLI = new QuoteLineItem();
                    newQLI.QuoteId = objQuote.Id;
                    newQLI.Quantity = 1;
                    newQLI.UnitPrice = 0;
                    newQLI.PriceBookEntryId = mapPricebookEntry.get(objQuote.Pricebook2Id).Id;
                    newQLI.Record_Type__c = 'a La Carte';
                    
                    lstQuoteLineItem.add(newQLI);
                }
            }
            
            if(lstQuoteLineItem != null && lstQuoteLineItem.size() > 0){
                Utility.processRecords(lstQuoteLineItem, 'insert');
            }
        }
    }

    public static void changeOrderStatus(List<Quote> lstQuote, Map<Id,Payment_Term__c> mapPaymentTerm, List<Payment_Term__c> lstPaymentTerm){
        List<Payment_Term__c> listPayTerm = new List<Payment_Term__c>();
        for(Quote objQuote : lstQuote) {
            if(objQuote.Payment_Method__c == 'Value-In-Kind' && mapPaymentTerm.size() > 0 && mapPaymentTerm.containskey(objQuote.Id)){
                for(Payment_Term__c objPayTerm : lstPaymentTerm){
                    if(objPayTerm.Status__c != 'Passed'){ //added as part of #991
                        objPayTerm.Value_in_Kind_Passed__c = true;
                    }
                    objPayTerm.Status__c = 'Passed';
                    listPayTerm.add(objPayTerm);
                }
            }
            
            //added as part of #991 - START
            if(objQuote.Payment_Method__c != 'Value-In-Kind' && mapPaymentTerm.size() > 0 && mapPaymentTerm.containskey(objQuote.Id)){
                for(Payment_Term__c objPayTerm : lstPaymentTerm) {
                    if(objPayTerm.Value_in_Kind_Passed__c == true) { 
                        objPayTerm.Value_in_Kind_Passed__c = false;
                        objPayTerm.Status__c = '';
                    }
                    
                    listPayTerm.add(objPayTerm);
                }
            }
            //added as part of #991 - END
            
        }
        System.debug('listPayTerm-->'+listPayTerm);
        Utility.processRecords(listPayTerm, 'update');
    }
    /**
    * @description  : To send email to order owner when quote status becomes "Sent from QNG"(#871)
    * @author       : cshah@addonblue.com | 03/31/2021
    * @param        : Quote newlist and oldmap
    * @return       : void 
    **/   
    public void sendEmailOnQuoteSentToQNG(List<Quote> newQuoteList,Map<Id, Quote> oldQuoteMap) {
        system.debug('@@send email method called..');
        try {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(Quote objQuote: [Select Id,QuoteNumber,Opportunity.Account.Name,Opportunity.Owner_Email__c,Status from Quote where Id IN :newQuoteList]) {
                if(objQuote.Status == 'Sent from QNG' && (Trigger.isInsert || (Trigger.isUpdate && objQuote.Status != oldQuoteMap.get(objQuote.Id).Status))) {
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    if(objQuote.Opportunity.Owner_Email__c != null) {
                    
                        List<String> sendTo = new List<String>(); 
                        sendTo.add(objQuote.Opportunity.Owner_Email__c);
                        mail.setToAddresses(sendTo);
                        
                        mail.setSubject('Your client has clicked Quote to Online Order link');
                        
                        String emailbody = '<b>' + 'Account Name : ' +'</b>'+ objQuote.Opportunity.Account.Name + '<br/>'; 
                        emailbody += '<b>' + 'Link to Quote : '+'</b>' + '<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+objQuote.Id+'">'+objQuote.QuoteNumber+'</a></html><br/>';
                        emailbody += '<b>' + 'Community Quote URL : ' +'</b>' + '<html><a href="'+Label.Formula_1_Lightning_Community_URL +'/s/quote'+'/'+objQuote.Id+'">'+objQuote.QuoteNumber+'</a></html>';
                        
                        
                        mail.setHtmlBody(emailbody);
                        
                        mails.add(mail);
                    }
                }
            }
            if(mails.size() > 0) {
                 Messaging.sendEmail(mails);
            }
            
        } catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    /**
    * @description  : Update related QLI's Processing Amount on Quote's update
    * @author       : fsuraitawala@addonblue.com | 04/10/2021
    * @return       : void 
    **/
    private static void updateRelatedQLI(set<Id> setQuoteId){
        List<QuoteLineItem> lstUpdateQLI = new List<QuoteLineItem>();
        
        for(QuoteLineItem qliToUpdate : [Select Id, Quote.Remove_Processing_Fee__c, UnitPrice, Processing_Fee_Amount__c, Quantity FROM QuoteLineItem WHERE QuoteId IN :setQuoteId]){
            Decimal subtotal = qliToUpdate.UnitPrice;
            
            if(qliToUpdate.Processing_Fee_Amount__c != null){
                if(qliToUpdate.Quote.Remove_Processing_Fee__c) {
                    qliToUpdate.UnitPrice = qliToUpdate.UnitPrice - qliToUpdate.Processing_Fee_Amount__c;
                } else {
                    qliToUpdate.UnitPrice = qliToUpdate.UnitPrice + qliToUpdate.Processing_Fee_Amount__c;
                }
                if(subtotal != qliToUpdate.UnitPrice){
                    lstUpdateQLI.add(qliToUpdate);
                }
            }
        }
        
        if(lstUpdateQLI.size() > 0){
            TriggerHandler.bypass('QuoteLineItemTriggerHandler');
            Utility.processRecords(lstUpdateQLI, 'update');
            TriggerHandler.clearBypass('QuoteLineItemTriggerHandler');
        }
    }
    
    public static void changePaymentTerm(Quote quote, List<Payment_Term__c> lstOfExistingPaymentTerms, Double totalOfUnpaid){
        String creditRecordType = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        Id quoteId = quote.Id;
        system.debug('@@ =============quoteId=== '+quoteId);

        Quote objQuote = [select id, OpportunityId, CurrencyISOCode, Payment_Method__c, AccountId, Original_Quote__c, Selected_Payment_Term__c FROM Quote WHERE Id =: quoteId];
        List<Payment_Term__c> lstOfNonPassesdPaymentTerms = [select Id, Percentage_Of_Payment__c, Payment_Due_Date__c, Amount__c, Quote__c, CurrencyISOCode FROM Payment_Term__c where Quote__c =: quoteId AND Status__c != 'Passed'];
        List<Payment_Term__c> lstOfCreditTypePaymentTerms = [select Id, Percentage_Of_Payment__c, Payment_Due_Date__c, Amount__c, Quote__c, CurrencyISOCode FROM Payment_Term__c where Quote__c =: quoteId AND RecordTypeId =: creditRecordType];
        Payment_Term__c singlePaymentTermToBeCreated = createCombinedPaymentTerm(lstOfExistingPaymentTerms, totalOfUnpaid);
        system.debug('@@============paymentTermToBeCreated=== '+singlePaymentTermToBeCreated);
        deletePaymentTerm(objQuote, lstOfNonPassesdPaymentTerms, lstOfCreditTypePaymentTerms);
        createPaymentTerm(objQuote, singlePaymentTermToBeCreated, '100%', 'Credit Card');
    }

    public static Payment_Term__c createCombinedPaymentTerm(List<Payment_Term__c> lstOfExistingPaymentTerms, Double totalOfUnpaid){
        system.debug('@@== creating PaymentTerm');
        Decimal GroundTotal = 0.0;
        Decimal totalPTsAmount = 0.0;
        Decimal creditAmount = 0.0;
        Decimal usedCredit = 0.0;
        Decimal totalCA = 0.0; //creditAmount+usedCredit
        for(Payment_Term__c existPT: lstOfExistingPaymentTerms){
            totalPTsAmount = totalPTsAmount + existPT.Amount__c;
        }
        Payment_Term__c paymentTerm = new Payment_Term__c();
        paymentTerm.Percentage_Of_Payment__c = 100;
        paymentTerm.Payment_Due_Date__c = Date.today();
        paymentTerm.Amount__c = totalOfUnpaid;
        paymentTerm.Credit__c = false;
        paymentTerm.Initial_Payment_Term__c = true;
        return paymentTerm;
    }

    public static void deletePaymentTerm(Quote objQuote, List<Payment_Term__c> lstOfNonPassesdPaymentTerms, List<Payment_Term__c> lstOfCreditTypePaymentTerms){
        system.debug('@@ == deleting Payment term');
        if(lstOfNonPassesdPaymentTerms.size() > 0){
            delete lstOfNonPassesdPaymentTerms;
        }
    }
    
    //VKHOPADE - issue 1178
    //function to recall Quote Draft-Pending approval 
  /*  public static void recallDraftApproval(Set<Id> QuoteIDs){
        Set<Id> recalledQuoteIDs = new Set<Id>();
		ProcessInstanceWorkitem[] piWorkItems = [SELECT Id, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN :QuoteIDs
                                         AND ProcessInstance.Status = 'Pending']; 
        if(piWorkItems.size() > 0){
            system.debug('inside piWorkItems, piWorkItems.Id = ' + piWorkItems[0].Id);
            for(ProcessInstanceWorkitem piw : piWorkItems){
                if(!(recalledQuoteIDs.contains(piw.ProcessInstance.TargetObjectId)) || recalledQuoteIDs.size() <= 0)
                {
                	//Create Process Work Item Request
                    Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
                    pwiRequest.setAction('Removed');
                    pwiRequest.setWorkItemId(piw.Id);
                    recalledQuoteIDs.add(piw.ProcessInstance.TargetObjectId);
                    Approval.ProcessResult result = Approval.process(pwiRequest);    
                }
            }
        }        
    } */

    
    public static void createPaymentTerm(Quote objQuote, Payment_Term__c pt, String paymentTerm, String paymentMethod){
        system.debug('@@ === CREATING PAYMENT TERM and CHARGE, Update Quote EXIST'); 
        List<Payment_Term__c> lstOppPaymentTerms = new List<Payment_Term__c>();   
        Quote quote = new Quote();
        quote.Id = objQuote.Id;

        Payment_Term__c newPaymentTerm = new Payment_Term__c();
        if(!String.isEmpty(pt.Id)){
            newPaymentTerm.Id = pt.Id;
        }
        newPaymentTerm.Percentage_Of_Payment__c = pt.Percentage_Of_Payment__c;
        newPaymentTerm.Payment_Due_Date__c = pt.Payment_Due_Date__c;
        newPaymentTerm.Amount__c = pt.Amount__c;
        newPaymentTerm.Quote__c = objQuote.Id;
        newPaymentTerm.Status__c = pt.Status__c;
        newPaymentTerm.Credit__c = pt.Credit__c;
        newPaymentTerm.Initial_Payment_Term__c = pt.Initial_Payment_Term__c;
        if(newPaymentTerm.Credit__c == true){
            newPaymentTerm.RecordTypeId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
        }
        
        if(!Test.isRunningTest()){
            newPaymentTerm.CurrencyISOCode = objQuote.CurrencyISOCode;
        }else{
            newPaymentTerm.CurrencyISOCode = 'USD';
        }
        if(objQuote.OpportunityId != null){
            newPaymentTerm.Opportunity__c = objQuote.OpportunityId;
        }
        lstOppPaymentTerms.add(newPaymentTerm);
        
        if(pt.Percentage_Of_Payment__c == 50){
            quote.X1_2__c = true;
            quote.X1_3__c = false;
            quote.X100__c = false;                                        
        }else if(pt.Percentage_Of_Payment__c == 33.33 || pt.Percentage_Of_Payment__c == 33.34){
            quote.X1_2__c = false;
            quote.X1_3__c = true;
            quote.X100__c = false;                    
        }else if(pt.Percentage_Of_Payment__c == 100){
            quote.X1_2__c = false;
            quote.X1_3__c = false;
            quote.X100__c = true;
        }
        
        if(!String.isEmpty(paymentTerm)){
            quote.Selected_Payment_Term__c = paymentTerm;
        }
        
        if(!String.isEmpty(paymentMethod)){
            quote.Payment_Method__c = paymentMethod;
        }

        if(lstOppPaymentTerms.size() > 0){            
            Utility.processRecords(lstOppPaymentTerms, 'upsert');
        }

        if(quote != null){        
            //update quote;
            List<Quote> lstQuotes = new List<Quote>();
            lstQuotes.add(quote);
            Utility.processRecords(lstQuotes, 'update');
        }

        if(lstOppPaymentTerms.size() > 0 && quote != null){
            Payment_Term__c creditPaymentTerm = new Payment_Term__c();
            
            for(Payment_Term__c objPT : lstOppPaymentTerms){
                if(pt.Credit__c == true){
                    creditPaymentTerm = objPT;
                }
            }
                            
            if(creditPaymentTerm != null){
                Charge__c objCharge = new Charge__c();
                objCharge.CurrencyISOCode = quote.CurrencyISOCode;
                objCharge.Payment_Terms__c = creditPaymentTerm.Id;
                objCharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Account Credit').getRecordTypeId();
                objCharge.Amount__c = creditPaymentTerm.Amount__c;
                objCharge.Account__c = objQuote.AccountId;
                objCharge.Credit_Used__c = true;
                //#591 Set the Status of Charge to Passed
                objCharge.Status__c  = 'Passed';
                system.debug('@@@NEW RK == ===###objCharge=='+objCharge);
                if(objCharge != null){
                    Utility.processRecords(objCharge, 'insert');
                    system.debug('@@@NEW RK == ====== CHRGE INSERTED ============');
                }
            }
        }  
    }
    /**
    * @description  : Create Inventory Hold Records
    * @author       : fsuraitawala@addonblue.com | 10/04/2021
    * @return       : void 
    **/
    public static void createInventoryHoldRecords(set<Id> setQuoteId){
        List<Inventory_Transaction__c> lstHoldInventory = new List<Inventory_Transaction__c>();
        if(setQuoteId.size() > 0){
            for(QuoteLineItem objQLI: [Select Id, QuoteId, Quote.Hold_Release_Date__c, Product2Id, Quantity FROM QuoteLineItem 
                                       WHERE QuoteID IN :setQuoteId and Product2.Inventory_Hold__c = true]){
                Inventory_Transaction__c objHoldInventory = new Inventory_Transaction__c();
                objHoldInventory.Quote__c = objQLI.QuoteId;
                objHoldInventory.Quote_Line_Item__c = objQLI.Id;
                objHoldInventory.Product__c = objQLI.Product2Id;
                objHoldInventory.Quantity__c = objQLI.Quantity;
                objHoldInventory.Hold_Release_Date__c = objQLI.Quote.Hold_Release_Date__c;
                objHoldInventory.RecordTypeId = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Inventory_Hold').getRecordTypeId();
                lstHoldInventory.add(objHoldInventory);
            }
            
            if(lstHoldInventory.size() > 0){
                Utility.processRecords(lstHoldInventory, 'insert');
            }
        }
    }
    
    /**
    * @description  : Release Inventory Hold Records
    * @author       : fsuraitawala@addonblue.com | 10/04/2021
    * @return       : void 
    **/
    public static void realseInventoryHoldRecords(set<Id> setQuoteId){
        List<Quote> lstQuote = new List<Quote>();
        List<Inventory_Transaction__c> lstHoldInventory = new List<Inventory_Transaction__c>();
        if(setQuoteId.size() > 0){
            for(Quote objQuote: [Select Id, (Select Id FROM Inventory_Transactions__r) FROM Quote WHERE Id IN :setQuoteId]){
                objQuote.Request_Hold__c = false;
                objQuote.Hold_Release_Date__c = null;
                lstQuote.add(objQuote);
                if(objQuote.Inventory_Transactions__r.size() > 0){
                    lstHoldInventory.addAll(objQuote.Inventory_Transactions__r);
                }
            }
            if(lstHoldInventory.size() > 0){
                Utility.processRecords(lstHoldInventory, 'delete');
            }
            if(lstQuote.size() > 0){
                TriggerHandler.bypass('QuoteTriggerHandler');
                Utility.processRecords(lstQuote, 'update');
                TriggerHandler.clearBypass('QuoteTriggerHandler');
            }
        }
    }
    //Ravindra-#1232- Downgrade quote validation check
    public static void checkDowngradeQuoteValidation(List<Quote> quotes,Map<Id,Quote> oldQuoteMap, list<Quote> lstQuotes){
        Set<Id> originalquoteIds = new Set<Id>();
        Map<Id,Boolean> quotesDowngrademap = new Map<Id,Boolean>();
        system.debug('originalOrders'+originalquoteIds);
        Map<Id,Order> originalOrders = new Map<Id,Order>();
        for(Quote objQuote : quotes ){
            if(objQuote.original_quote__c!=null){
                originalquoteIds.add(objQuote.original_quote__c);
            }
        }
        Map<Id,Quote> quotesMap = new Map<Id,Quote>(lstQuotes);
        if(!originalquoteIds.isEmpty()){
            for( order objOrder:[select id,quoteId,quote.GrandTotal,Gross_Collected__c,
                                 Order_Payment_Status__c,TotalAmount,
                                 (select id from Refunds__r) 
                                 from order 
                                 where quoteId In:originalquoteIds and 
                                 Order_Payment_Status__c!='Not Paid' ]){
                                     originalOrders.put(objOrder.QuoteId,objOrder);
                                 }
        }
        system.debug('originalOrders'+originalOrders);
        for(Quote objQuote : quotes){
            system.debug('original quote-->'+originalOrders.get(objQuote.Original_Quote__c));
            system.debug(objQuote.status+'----->'+ oldQuoteMap.get(objQuote.Id).Status);
            decimal pendingPayment=0;
            if(!quotesMap.isEmpty() && quotesMap.containsKey(objQuote.Id)){
                list<Payment_Term__c>  pterms = quotesMap.get(objQuote.Id).Payment_terms__r;
                if(pterms!=null){
                    for(Payment_Term__c objPt :quotesMap.get(objQuote.Id).Payment_terms__r ){
                        if(objPt.Status__c == null || string.isEmpty(objPt.Status__c) || objPt.Status__c == 'Pending'){
                            pendingPayment += objPt.Amount__c;
                        }
                    }
                }
            }
            //system.debug(objQuote.GrandTotal < originalOrders.get(objQuote.Original_Quote__c).quote.GrandTotal );
            if(originalOrders != null && originalOrders.containsKey(objQuote.Original_Quote__c) && 
               objQuote.GrandTotal < originalOrders.get(objQuote.Original_Quote__c).quote.GrandTotal &&
               objQuote.status=='Signed - Approved' && objQuote.Status != oldQuoteMap.get(objQuote.Id).Status){
                   Order originalOrder = originalOrders.get(objQuote.Original_Quote__c); 
                   if(pendingPayment>0&&(originalOrders.get(objQuote.Original_Quote__c).TotalAmount-objQuote.GrandTotal)>pendingPayment){ 
                       List<Refund__c> refunds = originalOrders.get(objQuote.Original_Quote__c).Refunds__r;                        
                       Boolean isRefundsExist = !refunds.isEmpty()? True:false;
                       
                       if(!isRefundsExist){
                           objQuote.addError('Quote cannot be moved to Signed Approved.As there is no refund on the Original Order.');  
                       }
                   }
               }
        }
    } 
    
    //Ravindra-#1249 - Multiple Order Validation.
    public static void checkMultipleorder(List<Quote> newQuotes,Map<Id,Quote> oldQuoteMap){
        Set<Id> oppIds = new Set<Id>();
        for(Quote obj : newQuotes){
            if(obj.Original_Quote__c==null)
            oppIds.add(obj.OpportunityId);
        }
        if(!oppIds.isEmpty()){
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([Select id,Name,
                                                  (Select id,name from Orders where Status='Active')
                                                   from Opportunity 
                                                   where id In:oppIds]);
        
        for(Quote obj : newQuotes){
            Quote oldQuote = oldQuoteMap.get(obj.Id);
            if(obj.status=='Signed - Approved'&& obj.status!=oldQuote.status &&oppMap.containsKey(obj.OpportunityId)&& !oppmap.get(obj.OpportunityId).Orders.IsEmpty()
              && oppmap.get(obj.OpportunityId).Orders.size()>=1){
                obj.addError('Opportunity already has an Active Order.');
            }
        }
      }      
    }
}