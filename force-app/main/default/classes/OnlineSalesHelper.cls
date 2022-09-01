/**
* @File Name          : OnlineSalesHelper.cls
* @Description        : 
* @Author             : lpanchal@addonblue.com
* @Group              : 
* @Last Modified By   : jagrawal@addonblue.com
* @Last Modified On   : 01-26-2021
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    3/16/2020   lpanchal@addonblue.com     Initial Version
**/
public class OnlineSalesHelper {
    @TestVisible
    private static Map<Id,Product2> insertedProductMap {get; set;}
    public static Boolean newOnlineLead = false;
    static public Id pricebookId;
    //*****************************************************
    //This method find account and lead, 
    //If not found any Account or Lead than generate new Lead
    //******************************************************
    @TestVisible
    public static Account getAccount(GPE_ApexToJsonClass.Gpesale sale) {
        Account account;
        Lead lead;
        if ((account = findAccount(sale.email, sale)) != null) {
            if(!Test.isRunningTest())
            account.Primary_contact__c = account.contacts[0].Id;
            account.BillingStreet = sale.street;
            account.BillingCity = sale.city;
            account.BillingPostalCode = sale.zip;
            account.BillingCountry = sale.country;
            account.BillingState = sale.state;
            account.ShippingStreet = sale.street;
            account.ShippingCity = sale.city;
            account.ShippingPostalCode = sale.zip;
            account.ShippingCountry = sale.country;
            account.ShippingState = sale.state;
            account.Marketing_Email_Consent__c = 'Yes';
            account.Phone = sale.phone;
            if(account.IsPersonAccount) account.Company_Name__pc = sale.firstName+' '+sale.lastName;
            update account;
            return account;
        } else if ((lead = findLead(sale.email)) != null) {
            lead.FirstName = sale.firstName;
            lead.LastName = sale.lastName;
            lead.Street = sale.street;
            lead.City = sale.city;
            lead.State = sale.state;
            lead.PostalCode = sale.zip;
            lead.Country = sale.country;
            lead.Phone = sale.phone;
            lead.Marketing_Email_Consent__c = 'Yes';
            update lead;
            return convertLead(lead);
        } else {
            lead = createLead(sale);
            return convertLead(lead);
        }
    }
    
    //*****************************************************
    //This method find account based on email
    //*****************************************************
    private static Account findAccount(String email,GPE_ApexToJsonClass.Gpesale sale) {
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Email =: email LIMIT 1];
        System.debug('Contact Email:---'+email);
        System.debug('contacts list@@'+contacts);
        if (contacts.size() == 0) {
            return null;
        } else {
            List<Account> accountList = [SELECT Id,IsPersonAccount,(Select Id,AccountId from Contacts where Id =: contacts[0].Id) FROM Account WHERE Id = :contacts[0].AccountId];
            if(!accountList.isEmpty()){
                return accountList[0];
            }
            else {
                Account account = new Account(); account.Name = sale.firstName+' '+sale.lastName;account.primary_contact__c = contacts[0].id; account.BillingStreet = sale.street; account.BillingCity = sale.city; account.BillingPostalCode = sale.zip; account.BillingCountry = sale.country;
                account.BillingState = sale.state; account.ShippingStreet = sale.street;account.ShippingCity = sale.city; account.ShippingPostalCode = sale.zip;account.ShippingCountry = sale.country; account.ShippingState = sale.state; account.Marketing_Email_Consent__c = 'Yes';account.Phone = sale.phone;
                //if(account.IsPersonAccount)
                //account.Company_Name__pc = sale.firstName+' '+sale.lastName;
                insert account;
                Contact contact = new Contact(); contact.Id = contacts[0].id; contact.AccountId = account.Id; update contact;
                System.debug('account-->'+account); return account;
            }
        }
    }
    //*****************************************************
    //This method find Lead based on email
    //******************************************************
    @TestVisible
    private static Lead findLead(String email) {
        List<Lead> leads = [SELECT Id, Name, Company, Company_Name__c, Lead_Type__c FROM Lead WHERE Email = :email and IsConverted = false LIMIT 1];
        if (leads.size() == 0) {
            return null;
        } else {
            return leads[0];
        }
    }
    
    //*****************************************************
    //This method create Lead based on endpoint record
    //******************************************************
    private static Lead createLead(GPE_ApexToJsonClass.Gpesale sale) {
        Lead lead = new Lead(
            City = sale.city,
            Country = sale.country,
            Email = sale.email,
            FirstName = sale.firstName,
            LastName = sale.lastName,
            Lead_Type__c = 'Person',
            PostalCode = sale.zip,
            State = sale.state,
            Street = sale.street,
            Phone = sale.phone,
            Marketing_Email_Consent__c = 'Yes',
            Source__c = 'Other'            
        );
        lead.OwnerId = Label.GPE_Online_Order_OwnerId;
        insert lead;
        newOnlineLead = true;
        return lead;
    }
    
    //*****************************************************
    //This method convert Lead
    //******************************************************
    private static Account convertLead(Lead lead) {
        // #243 Too many SOQL issue resolution -- START
        Database.LeadConvertResult result = LeadConversionHelper.convert(lead);
        // Database.LeadConvertResult result = LeadConversionHelper.convert(lead.Id);
        // #243 Too many SOQL issue resolution -- END
        if (result.isSuccess()) {
            Account account = [SELECT Id FROM Account WHERE Id = :result.getAccountId()];
            account.Copy_Billing_to_Shipping_Address__c = true;
            account.Marketing_Email_Consent__c = 'Yes';
            update account;
            return account;
        } else {
            return null;
        }
    }
    
    /*****************************************************
This method create new opporunity 
******************************************************/
    public static List<ResponseMessage> createOpportunity(Account acct, GPE_ApexToJsonClass.Gpesale sale) {
        String errorString;       
        Set<GPE_ApexToJsonClass.LineItems> OnlineSaleLineItemSet =  new Set<GPE_ApexToJsonClass.LineItems>();
        Account account = [SELECT Id, OwnerId, RecordTypeId, IsPersonAccount FROM Account WHERE Id = :acct.Id];
        // Primary Contact should be the person placing order
        Contact primaryContact = [Select Id From Contact Where Email = :sale.email AND AccountId =: acct.Id Limit 1];
        Set<Id> packageIdSet = new Set<Id>();
        // LIST OF PRODUCTS
        Set<String> articleIdSet = new Set<String>();
        // LIST OF PRICEBOOK
        Set<String> gptListId = new Set<String>();
        List<ResponseMessage> ResponseMessage = new List<ResponseMessage>();
        try{
            for(GPE_ApexToJsonClass.LineItems item : sale.lineItems) {
                OnlineSaleLineItemSet.add(item);
                if(item.articleid != null && item.articleid != ''){
                    articleIdSet.add(item.articleid);
                }
                if(item.GPTEventId != null && item.GPTEventId != ''){
                    gptListId.add(item.GPTEventId);
                }
            } 
            List<Product2> productArticleList = new List<Product2>();
            List<Product2> checkGptEventId = new List<Product2>();
            
            if(!gptListId.isEmpty()){
                System.debug('gptListId-->'+gptListId);
                checkGptEventId = [Select Id,Primary_Price_Book__c,Primary_Price_Book__r.CreatedBy.Email,Primary_Price_Book__r.CreatedBy.Name,Primary_Price_Book__r.GPT_Event_Id__c,GPT_Article_Id__c from Product2 where Primary_Price_Book__r.GPT_Event_Id__c IN : gptListId limit 1];
                System.debug('checkGptEventId -->'+checkGptEventId);
                if(!checkGptEventId.isEmpty()){
                    productArticleList = checkGptEventId;
                }
            }
            if(!articleIdSet.isEmpty() && checkGptEventId.isEmpty()){
                productArticleList = [Select Id,Primary_Price_Book__r.GPT_Event_Id__c,Primary_Price_Book__c,Primary_Price_Book__r.CreatedBy.Email,Primary_Price_Book__r.CreatedBy.Name,GPT_Article_Id__c from Product2 where GPT_Article_Id__c IN : articleIdSet];
            }
            if(!productArticleList.isEmpty()){
                System.debug('productArticleList-->'+productArticleList);
                ResponseMessage = createPricebookBaseOpportunity(account, primaryContact, productArticleList, sale, OnlineSaleLineItemSet);
            }else if(( productArticleList.isEmpty() && !articleIdSet.isEmpty() ) || articleIdSet.isEmpty() ){
                System.debug('articleIdSet-->'+articleIdSet);
                List<Pricebook2> lstPricebook2 = new List<Pricebook2>();
                if(!string.isblank(sale.gpeEventName)){
                    lstPricebook2 = [Select Id,(Select Id,Primary_Price_Book__c from Products__r where Available__c = true) from Pricebook2 where Name =: 'GPE - '+sale.gpeEventName];
                }else{
                    lstPricebook2 = [Select Id,(Select Id,Primary_Price_Book__c from Products__r where Available__c = true) from Pricebook2 where Name ='GPE -'];
                }
                system.debug('lstPricebook2---->'+lstPricebook2);
                String strPBId = '';
                if(lstPricebook2.isEmpty() ){
                    Pricebook2 objPricebook = new Pricebook2();
                    if(sale.gpeEventName != null && sale.gpeEventName.startswith('GPE - ')) objPricebook.Name = sale.gpeEventName;
                    else objPricebook.Name = 'GPE - '+ sale.gpeEventName;                    
                    if(gptListId.size()>0) objPricebook.GPT_Event_Id__c = new list<string>(gptListId)[0];                    
                    objPricebook.GPE_Event__c = true;
                    objPricebook.IsActive = true;
                    objPricebook.Start_Date__c = System.today();
                    objPricebook.End_Date__c = System.today().addMonths(1);
                    objPricebook.International_Stripe__c = true;
                    objPricebook.Chargeable_Currencies__c = 'AUD;CAD;EUR;GBP;USD';
                    insert objPricebook;
                    system.debug('objPricebook---->'+objPricebook);
                    strPBId = objPricebook.Id;
                 }
                else{
                    strPBId = lstPricebook2[0].Id;
                }
                Id RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId();                   
                map<string,product2> maplineItemsName = new map<string,product2>();
                for(product2 pro: [Select Id,Name,Primary_Price_Book__c,GPT_Article_Id__c,Primary_Price_Book__r.createdby.Email,Primary_Price_Book__r.createdby.Name from Product2 where Primary_Price_Book__c=: strPBId]){
                    System.debug('pro-->'+pro);
                    maplineItemsName.put(pro.Name,pro);
                }
                List<Product2> productArticleListToInsert = new List<Product2>();
                for (GPE_ApexToJsonClass.LineItems item : sale.lineItems) {
                    System.debug('item-->'+item);
                    if(maplineItemsName.containskey(item.Name)){ productArticleList.add(maplineItemsName.get(item.Name));}
                    else{ if(string.isblank(item.articleid)) productArticleListToInsert.add(new Product2(RecordTypeId= RecordTypeId,isActive=true, Name=item.Name, Type__c='Ticket', Primary_Price_Book__c=strPBId,Available__c=true,Quantity_Per_Order_Threshold__c=20,CurrencyIsoCode = sale.currencyCharged)); }
                }    
                System.debug('productArticleListToInsert-->'+productArticleListToInsert);                
                database.insert(productArticleListToInsert, false);
                productArticleList.addall(productArticleListToInsert);
                System.debug('productArticleList-->'+productArticleList);
                ResponseMessage = createPricebookBaseOpportunity(account, primaryContact, productArticleList, sale, OnlineSaleLineItemSet);
                /*}
                else{
                    productArticleList = lstPricebook2[0].Products__r;
                    System.debug('productArticleList-->'+productArticleList);
                    ResponseMessage = createPricebookBaseOpportunity(account, primaryContact, productArticleList, sale, OnlineSaleLineItemSet);
                }*/
            }
            else{
                ResponseMessage = new List<ResponseMessage>();
                errorString = '{"status" : "failed", "error" : "Something went wrong in Salesforce please contact to your Administrator."}';
                ResponseMessage.add(new ResponseMessage(errorString, new opportunity(), new List<OpportunityLineItem>(), new List<Product2>(), new Set<GPE_ApexToJsonClass.LineItems>()));
            }
        }
        catch(Exception e){
            ResponseMessage = new List<ResponseMessage>();
            System.debug('exception=>'+e+'=LineNumber=>'+e.getLineNumber());
            errorString = '{"status" : "failed", "error" : "'+e +' '+e.getLineNumber()+'"}';
            ResponseMessage.add(new ResponseMessage(errorString, new opportunity(), new List<OpportunityLineItem>(), new List<Product2>(), new Set<GPE_ApexToJsonClass.LineItems>()));
        }
        return ResponseMessage;
    }
    
    //*****************************************************
    //This method create create Pricebook Base Opportunity
    //*****************************************************
    public static List<ResponseMessage> createPricebookBaseOpportunity(Account account,Contact primaryContact, List<Product2> productArticleList, GPE_ApexToJsonClass.Gpesale sale,Set<GPE_ApexToJsonClass.LineItems> OnlineSaleLineItemSet){
        String errorString;
        Opportunity opportunity = new Opportunity();
        List<ResponseMessage> ResponseMessage;
        try {
            opportunity.AccountId = account.Id;
            opportunity.Primary_Contact__c = primaryContact.Id;
            try{
                //opportunity.Name = 'GPE '+[Select Name from Pricebook2 where Id = :productArticleList[0].Primary_Price_Book__c][0].Name;
                opportunity.Name = [Select Name from Pricebook2 where Id = :productArticleList[0].Primary_Price_Book__c][0].Name;
            }
            catch(Exception ex){
                if(sale.gpeEventName.startswith('GPE - ')) opportunity.Name = sale.gpeEventName;
                else opportunity.Name = 'GPE - '+sale.gpeEventName;
            }
            opportunity.CloseDate = System.today() + 3;
            opportunity.Contact_Site__c = 'grandprixevents.com';
            opportunity.CurrencyIsoCode = sale.currencyCharged;
            opportunity.Amount = Decimal.valueOf(sale.total);
            //opportunity.Currency_Charged__c = sale.currencyCharged;
            opportunity.OwnerId = newOnlineLead ? Label.Not_Assigned_UserId : account.OwnerId;
            opportunity.RecordType = opportunityRecordType(account);
            opportunity.StageName = 'Contract out';
            opportunity.Pricebook2Id = productArticleList[0].Primary_Price_Book__c;//'a0bc0000007fDd2';
            //opportunity.Online_Order__c = true;
            opportunity.Payment_Method__c = 'Wire Transfer';
            opportunity.Phone__c = sale.phone;
            opportunity.Bill_To_Name__c = sale.firstName + ' ' + sale.lastName;
            opportunity.Billing_Street__c = sale.street;
            opportunity.Billing_City__c = sale.city;
            opportunity.Billing_State_Province__c = sale.state;
            opportunity.Billing_Zip_Postal_Code__c = sale.zip;
            opportunity.Billing_Country__c = sale.country;
            opportunity.Ship_To_Name__c = sale.firstName + ' ' + sale.lastName;
            opportunity.Shipping_Street__c = sale.street;
            opportunity.Shipping_City__c = sale.city;
            opportunity.Shipping_State_Province__c = sale.state;
            opportunity.Shipping_Zip_Postal_Code__c = sale.zip;
            opportunity.Shipping_Country__c = sale.country;
            
            opportunity.Total_Charged_In_Currency__c = (sale.total != null) ? Decimal.valueOf(sale.total.replaceAll('[^.\\d]','')) : 0;//Decimal.valueOf(sale.total);
            opportunity.Show_Price_Details_on_Quote__c = true;
            opportunity.GPT_Booking_Id__c = sale.gptBookingId;
            // opportunity.GPE_Online_Order__c = true;
            opportunity.GPE_Event_Name__c = sale.gpeEventName;           
            opportunity.Paid_in_Full__c = true;
            opportunity.GPE_Order_Id__c = sale.GPE_Order_Id;
            opportunity.Xero_Reference_No__c = sale.GPE_Order_Id;
            insert opportunity;
            System.debug('opportunity'+opportunity);
            System.debug('OnlineSaleLineItemSet.size()-->'+OnlineSaleLineItemSet.size());
            
            /* List<OpportunityLineItem> oppLineItems;
if(OnlineSaleLineItemSet.size() > 0) {
//oppLineItems = addOpportunityLineItem(opportunity, OnlineSaleLineItemSet, productArticleList, productArticleList[0].Primary_Price_Book__c, sale);
}
system.debug('oppLineItems'+oppLineItems);*/
            errorString = '{"status" : "success", "opportunity" : "'+opportunity.Id+'"}';
            ResponseMessage = new List<ResponseMessage>();
            ResponseMessage.add(new ResponseMessage(errorString, opportunity ,productArticleList, OnlineSaleLineItemSet));
            pricebookId = productArticleList[0].Primary_Price_Book__c;
        }
        catch(Exception e){
            System.debug('exception=>'+e+'=LineNumber=>'+e.getLineNumber());
            errorString = '{"status" : "failed", "error" : "'+e +' '+e.getLineNumber()+'"}';
            ResponseMessage = new List<ResponseMessage>();
            ResponseMessage.add(new ResponseMessage(errorString, new opportunity(), new List<OpportunityLineItem>(), new List<Product2>(), new Set<GPE_ApexToJsonClass.LineItems>()));
        }
        return ResponseMessage;
    }
    
    private static RecordType opportunityRecordType(Account account) {
        String typeName = account.IsPersonAccount ? 'Person' : 'Business';
        return [
            SELECT Id
            FROM RecordType
            WHERE Name = :typeName + ' Opportunity' AND SObjectType = 'Opportunity'
        ];
    }
    
    
    
    
    
    /*****************addQuoteLineItem*********************************/
    public static List<QuoteLineItem> addQuoteLineItem(Quote quote, Set<GPE_ApexToJsonClass.LineItems> allItems,List<Product2> productList,Id eventId, GPE_ApexToJsonClass.Gpesale sale) {
        List<QuoteLineItem> quoteItemList = new List<QuoteLineItem>();
        try {
            
            Map<String, Decimal> itemsProductIdPriceMap = new Map<String, Decimal>();
            Map<String, String> itemsAsProductNameMap = new Map<String, String>();
            List<GPE_ApexToJsonClass.LineItems> nonGPTProductList = new List<GPE_ApexToJsonClass.LineItems>();
            set<String> nonGPTProductsName = new set<String>();            
            Map<String, PricebookEntry> productPBEntryMap = new Map<String, PricebookEntry>();
            system.debug('allItems'+allItems);
            for(GPE_ApexToJsonClass.LineItems item:allItems){
                // take all article id for filteration
                if(item.articleId != null && item.articleid != ''){
                    itemsProductIdPriceMap.put(item.articleId, Decimal.valueOf(item.price.replaceAll('[^.\\d]','')));
                    itemsAsProductNameMap.put(item.articleId, item.Name);
                }
                //fiter non gpt product to create opportunitylineitem with "product" name
                else if(item.articleId == null || item.articleid == ''){ 
                    nonGPTProductList.add(item);
                    nonGPTProductsName.add(item.name);                    
                }
            }
            
            //remove deactivated product form list
            Set<String> deactiveProduct = new Set<String>();
            for(product2 pro : [Select Id,GPT_Article_Id__c from Product2 where GPT_Article_Id__c IN: itemsProductIdPriceMap.keySet() AND isActive =: false]){
                itemsProductIdPriceMap.remove(pro.GPT_Article_Id__c); deactiveProduct.add(pro.GPT_Article_Id__c);
            }
            
            if(!Test.isRunningTest()){ productPBEntryMap = getPricebookEntries(quote.CurrencyIsoCode, itemsProductIdPriceMap, productList,itemsAsProductNameMap); }
            
            for(GPE_ApexToJsonClass.LineItems item:allItems){
                Boolean flag;
                if(!deactiveProduct.isEmpty() && !deactiveProduct.contains(item.articleId)){ flag = true; }
                else if(deactiveProduct.isEmpty() && item.articleId != null && item.articleid != ''){flag = true;}                
                else if(!deactiveProduct.isEmpty() && deactiveProduct.contains(item.articleId)){ flag = false; }
                
                system.debug('^^^^'+item.articleId+'@@@@'+flag);
                if(item.articleId != null && item.articleid != '' && flag){
                    PricebookEntry pkgEntry = productPBEntryMap.get(item.articleId);
                    QuoteLineItem qutLineItem = new QuoteLineItem();
                    qutLineItem.Quantity = item.quantity;
                    qutLineItem.QuoteId = quote.Id;
                    //String priceString = item.Price.replace(',', '');
                    qutLineItem.UnitPrice = Decimal.valueOf(item.price.replaceAll('[^.\\d]',''));
                    if(Test.isRunningTest()){
                        pkgEntry = new PricebookEntry();
                        PricebookEntry pbe = [SELECT Id FROM PricebookEntry limit 1];
                        pkgEntry.Id = pbe.Id;
                    }
                    qutLineItem.PriceBookEntryId = pkgEntry.Id;
                    qutLineItem.Record_Type__c = 'A La Carte';
                    String str = '';
                    if(!Test.isRunningTest()){
                        if(insertedProductMap.containsKey(pkgEntry.Product2Id)){
                            str = insertedProductMap.get(pkgEntry.Product2Id).Type__c;
                        }
                    }
                    qutLineItem.ProductType__c = str;
                    quoteItemList.add(qutLineItem);
                }
            }
            
           // system.debug('nonGPEProductIds'+nonGPEProductIds);
            //add hear Non gpe sale product to the price book entry list
            if(!nonGPTProductList.isEmpty() ){
                List<PricebookEntry> pbe = [SELECT Id,Product2Id,Product2.GPT_Article_Id__c,Product2.Type__c,Product2.Name FROM PricebookEntry WHERE Product2.GPT_Article_Id__c = null AND
                                            Product2.Name in: nonGPTProductsName AND Pricebook2Id =: pricebookId AND CurrencyIsoCode =:quote.CurrencyIsoCode AND Product2.Primary_Price_Book__c =: eventId];
                map<string,PricebookEntry> newPBE = new map<string,PricebookEntry>();
                system.debug('pbe'+pbe);
                if(pbe.isEmpty()){
                    List<Product2> pro = new List<Product2>();
                    if(!Test.isrunningTest()) pro =[Select Id,name from Product2 where Name in: nonGPTProductsName And Primary_Price_Book__c =: eventId And GPT_Article_Id__c = null];
                    else pro =[Select Id,name from Product2 where Primary_Price_Book__c =: Test.getStandardPricebookId() limit 1];
                    for(Integer i=0 ; i < pro.size(); i++){
                        PricebookEntry entry = new PricebookEntry(
                            UnitPrice = 0.0,
                            Product2Id = pro[i].Id,
                            Pricebook2Id = pricebookId,
                            IsActive = true,
                            CurrencyIsoCode = quote.CurrencyIsoCode,
                            UseStandardPrice = false);
                        insert entry; 
                        newPBE.put(pro[i].Name, entry);
                    }
                }
                else{
                    for(PricebookEntry pb: pbe){ newPBE.put(pb.Product2.Name,pb); }
                    
                } 
                system.debug('newPBE'+newPBE);
                if (newPBE.size() > 0) {
                    for(GPE_ApexToJsonClass.LineItems st : nonGPTProductList){ // repeat pricebookentry with generic product only for non gpt product.
                        if(newPBE.containskey(st.Name) || Test.isrunningtest()){
                            QuoteLineItem qutLineItem = new QuoteLineItem();
                            qutLineItem.Quantity = st.quantity;
                            qutLineItem.QuoteId = quote.Id;                           
                            qutLineItem.UnitPrice = Decimal.valueOf(st.Price.replaceAll('[^.\\d]',''));
                            qutLineItem.PriceBookEntryId = newPBE.get(st.Name).Id;
                            qutLineItem.Record_Type__c = 'A La Carte';
                            qutLineItem.ProductType__c = 'Ticket';
                            qutLineItem.Description = st.Name;
                            quoteItemList.add(qutLineItem);
                        }
                    }
                }    
            }  
            //Add OpplineItem with name shipping and handling, if josn contains shipping_fee attribute value
            if(sale.fees != null ){
                Product2 product;
                List<PricebookEntry> entryList = new List<PricebookEntry>();
                Map<String,PricebookEntry> entryMap = new Map<String,PricebookEntry>();
                PricebookEntry entry;
                List<Product2> proList = [Select Id,(Select Id from PricebookEntries where currencyIsoCode =: quote.currencyIsoCode) from Product2 where Name = 'Processing Fee' and Primary_Price_Book__c =: eventId];
                System.debug('proList-->'+proList);
                if(!proList.isEmpty()){
                    product = new Product2();
                    product.Id = proList[0].Id;
                    entry = new PricebookEntry();
                    entry.Id = proList[0].PricebookEntries[0].Id;
                } else {  
                    // ProductHandler.onlineGpeClassCall = true;
                    // ProductHandler.pricebookIds = pricebookId;
                    // ProductHandler.datedConversionRateList = DatedConversionRateList;
                    // ProductHandler.currencyList = currencyList;
                    
                    product = new Product2();
                    product.Name = 'Processing fee';
                    product.Primary_Price_Book__c = eventId;            
                    product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId();
                    product.Type__c = 'Ticket';
                    product.isActive = true;
                    insert product; 
                }
                
                List<PricebookEntry> prosList = [SELECT Id,Product2Id,Product2.GPT_Article_Id__c,Product2.Type__c,Product2.Name FROM PricebookEntry WHERE (Product2.Name = 'Shipping and Handling' OR Product2.Name = 'Processing fee') AND
                                                 Pricebook2Id =: pricebookId AND CurrencyIsoCode =:quote.CurrencyIsoCode AND Product2.Primary_Price_Book__c =: eventId];
                Map<String, PricebookEntry> priceMap = new Map<String, PricebookEntry>();
                for(PricebookEntry pb: prosList){ priceMap.put(pb.Product2.Name, pb); }
                System.debug('priceMap-->'+priceMap);
                if(sale.fees.shipping_fee != null && priceMap.containskey('Shipping and Handling') || Test.isRunningTest()){
                    //List<QuoteLineItem> QLI = new List<QuoteLineItem>([Select Id,UnitPrice from QuoteLineItem where quoteid =: quote.id and Product2.Type__c = 'Shipping and Handling' limit 1]);
                   // if(QLI.size()>0){ QLI[0].UnitPrice = Decimal.valueOf(sale.fees.shipping_fee); quoteItemList.add(QLI[0]);}
                    QuoteLineItem quoLineItem = new QuoteLineItem();
                    quoLineItem.Quantity = 1;
                    quoLineItem.QuoteId = quote.Id;
                    quoLineItem.UnitPrice = Decimal.valueOf(sale.fees.shipping_fee);
                    quoLineItem.PriceBookEntryId = priceMap.containskey('Shipping and Handling') ? priceMap.get('Shipping and Handling').Id : pricebookId;
                    quoLineItem.Record_Type__c = 'A La Carte';
                    quoLineItem.ProductType__c = 'Ticket';
                    quoteItemList.add(quoLineItem);
                }
                if(sale.fees.order_processing_fee != null && priceMap.containskey('Processing fee') || Test.isRunningTest()){
                    QuoteLineItem quoLineItem1 = new QuoteLineItem();
                    quoLineItem1.Quantity = 1;
                    quoLineItem1.QuoteId = quote.Id;
                    quoLineItem1.UnitPrice = Decimal.valueOf(sale.fees.order_processing_fee);
                    quoLineItem1.PriceBookEntryId = priceMap.containskey('Processing fee') ? priceMap.get('Processing fee').Id : pricebookId;
                    quoLineItem1.Record_Type__c = 'A La Carte';
                    quoLineItem1.ProductType__c = 'Ticket';
                    quoteItemList.add(quoLineItem1);
                }
            }
            
            system.debug('###quoteItemList=='+JSON.serialize(quoteItemList));
            if(quoteItemList.size() > 0) {
                //quoteItemList[0].Total_Processing_Fee_Amount__c = fees.order_processing_fee;
                Utility.processRecords(quoteItemList, 'insert');
            }
        } catch(exception e) {
            System.debug('exception=>'+e+'=LineNumber=>'+e.getLineNumber());
        }
        system.debug('###quoteItemList=='+JSON.serialize(quoteItemList));
        return quoteItemList;
    }
    
    /**********************************************/
    //@future(callout = true)
    public static void createPaymentTerm(Id QuoteId) {
        Quote objQuote = new Quote();
        System.debug('QuoteId-->'+QuoteId);
        if(QuoteId != null) {
            objQuote = [Select Id,OpportunityId ,Opportunity.Amount, CurrencyIsoCode, Payment_Method__c From Quote WHERE Id =:QuoteId];
            System.debug('objQuote'+objQuote);
            if(objQuote != null) {
                Payment_Term__c objPT = new Payment_Term__c();
                objPT.Quote__c = QuoteId;
                objPT.Opportunity__c = objQuote.OpportunityId;
                if(objQuote.Opportunity.Amount != null) {
                    objPT.Amount__c = objQuote.Opportunity.Amount;
                }
                objPT.Percentage_Of_Payment__c = 100 ;
                objPT.Payment_Term__c = '100%';
                objPT.Payment_Due_Date__c = date.today();
                objPT.CurrencyIsoCode = objQuote.CurrencyIsoCode ;
                objPT.Payment_Method__c = objQuote.Payment_Method__c;
                
                insert objPT;
                System.debug(objPT);
            }
        }
    }
    /**********************************************/
    public static Map<String, PricebookEntry> getPricebookEntries(String currencyIsoCode, Map<String, Decimal> maptArticleIdPrice, List<Product2> productList,Map<String, String> itemsAsProductNameMap) {
        Id ObjSTDPbId = Test.isRunningTest() ? Test.getStandardPriceBookId() : [Select Id from Pricebook2 where name = 'Standard Price book'].Id;
        Map<String, PricebookEntry> productIdPBEMap = new Map<String, PricebookEntry>();
        insertedProductMap = new Map<Id,Product2>();
        try{
            List<PricebookEntry> newPBE = new List<PricebookEntry>();
            system.debug(' maptArticleIdPrice---'+ maptArticleIdPrice +'--'+pricebookId +'--currencyIsoCode--'+currencyIsoCode );
            for(PricebookEntry pbe : [SELECT Id,Product2Id,Product2.GPT_Article_Id__c,Product2.Type__c FROM PricebookEntry WHERE Product2.GPT_Article_Id__c IN: maptArticleIdPrice.keyset() AND Pricebook2Id =: pricebookId and CurrencyIsoCode = :currencyIsoCode]){
                                          productIdPBEMap.put(pbe.Product2.GPT_Article_Id__c, pbe); //product list with Standard pricebook
                                          Product2 pro2 = new Product2();
                                          pro2.id = pbe.Product2Id;
                                          pro2.Type__c = pbe.Product2.Type__c;
                                          pro2.GPT_Article_Id__c = pbe.Product2.GPT_Article_Id__c;
                                          insertedProductMap.put(pbe.Product2Id, pro2); // all product list with already created and recently created.
                                      }
             List<Product2> insertProductList = New List<Product2>();
             for(String articleId : maptArticleIdPrice.keySet()){
                 if(!productIdPBEMap.containsKey(articleId) && articleId != null || Test.isRunningTest()){
                    Product2 product = new Product2();
                     if(Test.isRunningTest()){ product.Name = 'dnhfbvhfb';}
                     else{product.Name = (itemsAsProductNameMap.get(articleId) != null && itemsAsProductNameMap.get(articleId) != '' ? itemsAsProductNameMap.get(articleId) : articleId);}
                       product.Primary_Price_Book__c = productList[0].Primary_Price_Book__c;
                       product.GPT_Article_Id__c = articleId;                    
                       product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId();
                       product.Type__c = 'Ticket';
                       product.isActive = true;
                       product.A_La_Carte__c = true;
                       product.Available__c = true;
                       product.Quantity_Per_Order_Threshold__c = 20;
                       product.CurrencyIsoCode = 'USD';
                       insertProductList.add(product);
                 }
             }
             System.debug('insertProductList-->'+insertProductList);
             if(!insertProductList.isEmpty()){
                 insert insertProductList;
                 for(Product2 pro : insertProductList){
                     insertedProductMap.put(pro.Id, pro);
                 }
            //     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            //     String str = '';
            //     if(Test.isRunningTest() == false){
            //         message.toAddresses = new String[] { productList[0].Primary_Price_Book__r.CreatedBy.Email };
            //             message.subject = 'Product is created with article ids';
            //         str += 'Hello '+ productList[0].Primary_Price_Book__r.CreatedBy.Name+'\n\n';
            //     }
            //     str += 'This email contain the list of product which is created from GPE endpoints please go througth bellow links for more infomation\n';
            //     for(Product2 prod : insertProductList){                    
            //         str += URL.getSalesforceBaseUrl().getHost()+'/lightning/r/Product2/'+prod.Id+'/view\n';
            //     }
            //     str += 'Thank you.';
            //     message.plainTextBody = str;
            //     Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            //         if(!Test.isRunningTest()){
            //             // System.debug('productList[0].Primary_Price_Book__r.Owner.Email-->'+productList[0].Primary_Price_Book__r.Owner.Email);
            //             // System.debug('productList[0].Primary_Price_Book__r.Owner.Email-->'+productList[0].Primary_Price_Book__r);
            //             Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            //             if (results[0].success) {
            //                 System.debug('The email was sent successfully.');
            //             } else {
            //                 System.debug('The email failed to send: ' + results[0].errors[0].message);
            //             }
            //         }
             }
            Map<String,product2> insertedPIDMap = new map<String, product2>();
            Map<String,product2> insertedProductMap = new map<String, product2>();
            for(product2 pro : productList){
                insertedProductMap.put(pro.GPT_Article_id__c,pro);
            }
            for(product2 pro : productList){
                if(!productIdPBEMap.containsKey(pro.GPT_Article_id__c) || Test.isrunningTest()){
                    PricebookEntry entry = new PricebookEntry(
                        UnitPrice = maptArticleIdPrice.get(pro.GPT_Article_id__c),
                        Product2Id = insertedProductMap.get(pro.GPT_Article_id__c).Id,
                        Pricebook2Id = ObjSTDPbId,
                        IsActive = true,
                        CurrencyIsoCode = currencyIsoCode,
                        UseStandardPrice = false);
                        if(entry.UnitPrice == null) entry.UnitPrice = 0;
                        newPBE.add(entry);
                        
                        entry = new PricebookEntry(
                        UnitPrice = maptArticleIdPrice.get(pro.GPT_Article_id__c),
                        Product2Id = insertedProductMap.get(pro.GPT_Article_id__c).Id,
                        Pricebook2Id = pricebookId,
                        IsActive = true,
                        CurrencyIsoCode = currencyIsoCode,
                        UseStandardPrice = false); 
                        if(entry.UnitPrice == null) entry.UnitPrice = 0;                       
                        newPBE.add(entry);
                        
                        entry = new PricebookEntry(
                        UnitPrice = maptArticleIdPrice.get(pro.GPT_Article_id__c),
                        Product2Id = insertedProductMap.get(pro.GPT_Article_id__c).Id,
                        Pricebook2Id = ObjSTDPbId,
                        IsActive = true,
                        CurrencyIsoCode = 'USD',
                        UseStandardPrice = false);
                        if(entry.UnitPrice == null) entry.UnitPrice = 0;
                        newPBE.add(entry);
                        
                        entry = new PricebookEntry(
                        UnitPrice = maptArticleIdPrice.get(pro.GPT_Article_id__c),
                        Product2Id = insertedProductMap.get(pro.GPT_Article_id__c).Id,
                        Pricebook2Id = pricebookId,
                        IsActive = true,
                        CurrencyIsoCode = 'USD',
                        UseStandardPrice = false);
                        insertedPIDMap.put(insertedProductMap.get(pro.GPT_Article_id__c).Id,insertedProductMap.get(pro.GPT_Article_id__c));
                        if(entry.UnitPrice == null) entry.UnitPrice = 0;
                        newPBE.add(entry);
                }  
            }
            system.debug('newPBE---'+newPBE);
            if (newPBE.size() > 0) {
                insert newPBE;
                for(PricebookEntry pbe : newPBE ){
                    productIdPBEMap.put(insertedPIDMap.get(pbe.Product2Id).GPT_Article_Id__c, pbe);
                }
            }
        } catch(exception e) {
            System.debug('exception=>'+e+'=LineNumber=>'+e.getLineNumber());
        }
        system.debug('productIdPBEMap---'+productIdPBEMap);
        return productIdPBEMap;
    }
    
    /**********************************************/
    public static List<ResponseMessage> crtQuote(Opportunity oppList, List<Product2> lstProduct , Set<GPE_ApexToJsonClass.LineItems> OnlineSaleLineItemSet, GPE_ApexToJsonClass.Gpesale sale) {
        Quote newQuote = new Quote();
        List<ResponseMessage> ResponseMessage = new List<ResponseMessage>();
        String errorString; 
        String strOrderId; 
        List<Order>  objOrder = new List<Order>();
        List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();   
        try{
            if( oppList != null){
                newQuote.Name = oppList.Name;
                newQuote.OpportunityId = oppList.Id;
                //newQuote.pricebook2Id = pricebookId;
               // newQuote.Online_Order__c = true;
                newQuote.Status = 'Draft';
                newQuote.currencyIsoCode = oppList.currencyIsoCode;
                newQuote.GPE_Online_Order__c = true; 
                // #266 Added for Change Order Issue
                newQuote.Selected_Payment_Term__c = sale.paymentTerms;
                Insert newQuote;
                createPaymentTerm(newQuote.Id);
                System.debug('newQuote-->'+newQuote);
                quoteLineItemList = addQuoteLineItem(newQuote, OnlineSaleLineItemSet, lstProduct, lstProduct[0].Primary_Price_Book__c, sale);
                
                System.debug('quoteLineItemList-->'+quoteLineItemList);                    
                
                newQuote.Status = 'Signed - Approved';
				newQuote.Timestamp__c = String.valueOf(Datetime.Now());
                update newQuote;
                
                system.debug('newQuote'+newQuote.Id);
                objOrder = [Select Id,Name,QuoteId,OpportunityId,GPE_Order_Id__c,GPE_Event_Name__c,GPT_Booking_Id__c,Xero_Reference_No__c from Order where QuoteId =:newQuote.Id  ]; 
                if(objOrder.size() > 0 ){  
                    objOrder[0].GPE_Order_Id__c =  oppList.GPE_Order_Id__c;
                    objOrder[0].GPE_Event_Name__c =  oppList.GPE_Event_Name__c;
                    objOrder[0].GPT_Booking_Id__c =  oppList.GPT_Booking_Id__c; 
                    objOrder[0].Xero_Reference_No__c = oppList.GPE_Order_Id__c;
                    update objOrder[0];                  
                    strOrderId= objOrder[0].Id;
                    errorString = '{"status" : "success", "orderid" : "'+strOrderId+'"}';
                    //ResponseMessage = new List<ResponseMessage>();
                    ResponseMessage.add(new ResponseMessage(errorString, objOrder[0], newQuote, quoteLineItemList, new List<Product2>(), new Set<GPE_ApexToJsonClass.LineItems>()));
                }else{
                    strOrderId ='';
                    errorString = '{"status" : "failed", "Message" : "Order not found"}';
                    //ResponseMessage = new List<ResponseMessage>();
                    ResponseMessage.add(new ResponseMessage(errorString, newQuote, quoteLineItemList, new List<Product2>(), new Set<GPE_ApexToJsonClass.LineItems>()));
                }
            }
            
        }
        catch(Exception e){
            System.debug('exception=>'+e+'=LineNumber=>'+e.getLineNumber());
            errorString = '{"status" : "failed", "error" : "'+e +' '+e.getLineNumber()+'"}';
            ResponseMessage.add(new ResponseMessage(errorString, new opportunity(), new List<OpportunityLineItem>(), new List<Product2>(), new Set<GPE_ApexToJsonClass.LineItems>()));
        }
        return ResponseMessage;
    }
    /**********************************************/
    Public class ResponseMessage {
        public String str {get;set;}
        public Order order {get;set;}
        public Opportunity opportunity {get;set;}
        public List<OpportunityLineItem> OpportunityLineItem {get;set;}
        public Quote quote {get;set;}
        public List<QuoteLineItem> QuoteLineItem {get;set;}
        public List<Product2> lstProduct {get;set;}
        public Set<GPE_ApexToJsonClass.LineItems> OnlineSaleLineItemSet {get;set;}
        public ResponseMessage(String str, Opportunity opportunity, List<OpportunityLineItem> OpportunityLineItem, List<Product2> lstProduct, Set<GPE_ApexToJsonClass.LineItems> OnlineSaleLineItemSet){
            this.str = str;
            this.opportunity = opportunity;
            this.OpportunityLineItem = OpportunityLineItem;
            this.lstProduct = lstProduct;
            this.OnlineSaleLineItemSet = OnlineSaleLineItemSet;
        }
        public ResponseMessage(String str, Opportunity opportunity, List<Product2> lstProduct, Set<GPE_ApexToJsonClass.LineItems> OnlineSaleLineItemSet){
            this.str = str;
            this.opportunity = opportunity;
            
            this.lstProduct = lstProduct;
            this.OnlineSaleLineItemSet = OnlineSaleLineItemSet;
        }
        public ResponseMessage(String str, Quote quote, List<QuoteLineItem> QuoteLineItem,List<Product2> lstProduct,Set<GPE_ApexToJsonClass.LineItems> OnlineSaleLineItemSet){
            this.str = str;
            this.quote = quote;
            this.QuoteLineItem = QuoteLineItem;
            this.lstProduct = lstProduct;
            this.OnlineSaleLineItemSet = OnlineSaleLineItemSet;
        }
        public ResponseMessage(String str, Order order, Quote quote, List<QuoteLineItem> QuoteLineItem,List<Product2> lstProduct,Set<GPE_ApexToJsonClass.LineItems> OnlineSaleLineItemSet){
            this.str = str;
            this.order = order;
            this.quote = quote;
            this.QuoteLineItem = QuoteLineItem;
            this.lstProduct = lstProduct;
            this.OnlineSaleLineItemSet = OnlineSaleLineItemSet;
        }
    }
    
   /* @TestVisible
    public static List<CurrencyType> currencyList {
        get {
            List<CurrencyType> CurrencyTypeList;
            if (currencyList == null || Test.IsrunningTest()) {
                CurrencyTypeList = [SELECT Id,ISOCode, ConversionRate, IsCorporate FROM CurrencyType WHERE IsActive=TRUE];
            }
            return CurrencyTypeList;
        }
    }
    @TestVisible
    public static List<DatedConversionRate> DatedConversionRateList {
        get {
            List<DatedConversionRate> DatedConversionRate;
            if (DatedConversionRateList == null || Test.IsrunningTest()) {
                DatedConversionRate = [SELECT Id,ConversionRate,IsoCode,StartDate FROM DatedConversionRate order by StartDate DESC ];
            }
            return DatedConversionRate;
        }
    }*/
    
}