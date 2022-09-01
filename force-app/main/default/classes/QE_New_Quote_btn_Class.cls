/**
 * @File Name          : QE_New_Quote_btn_Class.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 12:16:17 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
public class QE_New_Quote_btn_Class {

    public Id opp_ID;
    public boolean displayPopup {get;set;}
    public String displayMsg {get;set;}
    public string page_URL{get;set;}
    public Opportunity oppRec {get;set;}

    public QE_New_Quote_btn_Class(ApexPages.StandardController stdController) {
        RedirectMethod();
        closePopup();
    }
    
    public pageReference closePopup() {
       displayPopup=false;
       displayMsg = '';
       page_URL = '';
       oppRec = new Opportunity();
       pageReference ref=new pageReference('/'+opp_ID);
       ref.setRedirect(true);
       return ref;
    }
    
    public pageReference RedirectMethod() {
    //     List<Opportunity> lstOpportunity=new List<Opportunity>();
    //     List<Quote> quoteList = new List<Quote>();
    //     List<Quote> quoteList2 = new List<Quote>();
    //     List<dsfs__DocuSign_Status__c> DocuSignStatusRecords = new List<dsfs__DocuSign_Status__c>();
    //     Set<Id> quoteSet = new Set<Id>();
    //     opp_ID = ApexPages.currentPage().getParameters().get('Oppid');
    //     Boolean isParentIncluded = false;
    //     Boolean isParkingPass = false;
        
    //     system.debug('opportunity ID' +opp_ID);
    //     //if(opp_ID != null)
    //     oppRec = [SELECT Id, Name, Phone__c, Email__c, Shipping_City__c,Total_Amount__c, Payment_Method__c,
    //               Shipping_Country__c, Shipping_Street__c, Shipping_State_Province__c, Shipping_Zip_Postal_Code__c,
    //               Billing_City__c, Billing_Country__c, Billing_State_Province__c, Billing_Street__c, Billing_Zip_Postal_Code__c,
    //               Payment_Terms__c,Event__r.Start_Date__c, Event__r.Program__c, Event__r.Program__r.Name,Createddate,Event__c,
    //               (SELECT Id, OpportunityId, Product2Id, Product2.Parent_Package__c, Product2.Type__c, Product2.Parent_Package__r.Name,
    //                  Record_Type__c, PricebookEntryId, Name, Quantity FROM OpportunityLineItems)
    //               FROM Opportunity WHERE Id =: opp_ID];
        
    //     if(Test.isRunningTest()) {
    //         oppRec.Phone__c = '123456789';
    //         oppRec.Email__c = 'test@gamil.com';
    //         oppRec.Shipping_City__c = 'Ahmedabad1';
    //         oppRec.Shipping_Country__c = 'India';
    //         oppRec.Shipping_Street__c = 'Bili';
    //         oppRec.Shipping_Zip_Postal_Code__c = '456768';
    //         oppRec.Payment_Method__c = 'check';
    //     }
        
    //     if(oppRec != null && oppRec.OpportunityLineItems != null) {
    //         if(oppRec.Event__r.Program__c != null && oppRec.Event__r.Program__r.Name.equals('F1E')) {
    //             for(OpportunityLineItem oli : oppRec.OpportunityLineItems) {
    //                 if(!isParentIncluded && oli.Record_Type__c == 'Package' && oli.Product2.Parent_Package__c != null && (oli.Product2.Parent_Package__r.Name.contains('Paddock Club') || oli.Product2.Parent_Package__r.Name.contains('Legend') || oli.Product2.Parent_Package__r.Name.contains('Champion'))) {
    //                     isParentIncluded = true;
    //                 }
    //                 if(!isParkingPass && (oli.Product2.Type__c == 'Parking Pass' || oli.Product2.Type__c == 'Parking Pass Not Included')){
    //                     isParkingPass = true;
    //                 }
    //             }
    //         }
    //     }
    //     System.debug('---isParentIncluded -----'+isParentIncluded );
    //     System.debug('---isParkingPass-----'+isParkingPass);
        
    //     if(isParentIncluded && !isParkingPass){
    //         displayPopup=true;
    //         displayMsg = 'Paddock, Legend, and Champion orders must contain a <b>Parking Pass</b> or a <b>Parking Pass Not Included</b> product';
    //         return null;
    //     }
    //     System.debug('---oppRec-----'+oppRec);
        
    //     quoteList = [select Id from Quote where Status != 'Signed - Approved' and OpportunityId =: opp_ID];
    //     if(quoteList.size() > 0) {
    //         for(Quote qrec : quoteList) {
    //             quoteSet.add(qrec.Id);
    //         }
    //     }
        
    //     if(quoteSet.size() > 0) {
    //         DocuSignStatusRecords = [SELECT Id, dsfs__DocuSign_Envelope_ID__c,Standard_Quote__c,dsfs__Envelope_Status__c from dsfs__DocuSign_Status__c where (dsfs__Envelope_Status__c = 'Sent' or dsfs__Envelope_Status__c = 'Delivered') and Standard_Quote__c IN: quoteSet]; 
    //     }
        
    //     quoteList2 = [select Id,Status,OpportunityId from Quote where Status = 'Signed - Approved' and OpportunityId =: opp_ID];
                
    //     // Recalculate opportunity line items before creating quotes.
    //     List<OpportunityLineItem> olisToRecalculate = new List<OpportunityLineItem>([
    //         Select Id
    //         From OpportunityLineItem
    //         Where OpportunityId = :opp_ID
    //     ]);
    //     QE_OpportunityLineItemHelper oliHelper = new QE_OpportunityLineItemHelper(); 
    //     oliHelper.calculateOpportunityLineItems(olisToRecalculate);
        
    //     // Get updated opportunity line items
    //     Set<Id> packId = new Set<Id>();
    //     Set<Id> proId = new Set<Id>();
    //     boolean allGood = true;
    //     List<Package_Products__c> packPro = new List<Package_Products__c>();        
    //     List<OpportunityLineItem> opLine = new List<OpportunityLineItem>([SELECT Id,Opportunity_Product_Package_Hotel__c,Package__c, Name, Product2.Name, Product2.IsActive, PriceBookEntry.Product2Id, PricebookEntryId, Quantity, UnitPrice, Product_Type__c, Product2Id, OpportunityId, ApexHotelTotalPrice__c, Total_Tax__c, Transportation_As_Part_Of_Hotel__c FROM OpportunityLineItem WHERE OpportunityId =: opp_ID]);
    //    system.debug('opLine' +opLine); 
    //    //List<Opportunity_Product_Package_Hotel__c> opProductPackageHotels = new List<Opportunity_Product_Package_Hotel__c>([select Id, Hotel__r.Name, Hotel__r.IsActive from Opportunity_Product_Package_Hotel__c where Opportunity__c = :opp_ID]);
        
    //     if(opLine.size() > 0 ){
    //         for(OpportunityLineItem opli: opLine){
    //             if(opli.Product_Type__c == 'Package'){
    //                 packId.add(opli.Product2Id);
    //             }else{
    //                 proId.add(opli.Product2Id);
    //             }
    //         }
    //     }
        
    //     if(packId.size() > 0 ){
    //         packPro = [SELECT Id, Package__c, Products_and_Hotels__c, Product_Type__c, Inventory__c 
    //                 FROM Package_Products__c WHERE Package__c IN: packId ];
    //     }
        
    //     if(packPro.size() > 0){
    //         for(Package_Products__c papro: packPro){
    //             proId.add(papro.Products_and_Hotels__c);
    //         }
    //     }
        
    //     if(proId.size() > 0){
    //         for(Product2 pro: [SELECT Id, Inventory__c, Name FROM Product2 WHERE Id IN: proId]){
    //             System.debug('pro=>'+pro);
    //             if(pro.Inventory__c < 0){
    //                 allGood = false;
    //             }
    //         }
    //     }
        
    //     String namesOfInActiveItems = '';
    //     // Oppt line items are active? (Packages and A La Cartes)
    //     Boolean IsActiveOppPackagesAndALaCartes = true;
    //     if (opLine.size() > 0 ) {
    //             for(OpportunityLineItem opli: opLine){
    //                 if(!opli.Product2.IsActive){
    //                     IsActiveOppPackagesAndALaCartes = false;
    //                     namesOfInActiveItems += opli.Product2.Name + '<br>';
    //                 }
    //             }
    //     }
        
    //     // Oppt hotels are active? (Product Package Hotels)
    //   //  Boolean IsActiveOppHotels = true;
    //    /* if (opProductPackageHotels.size() > 0) {
    //         for(Opportunity_Product_Package_Hotel__c opHotel: opProductPackageHotels){
    //             if(!opHotel.Hotel__r.IsActive){
    //                 IsActiveOppHotels = false;
    //                 namesOfInActiveItems += opHotel.Hotel__r.Name + '<br>';
    //             }
    //         }
    //     }*/
    //     Integer datediff = 0;
    //     if(oppRec.Event__c != null && oppRec.Event__r.Start_Date__c != null){
    //         datediff = oppRec.CreatedDate.date().daysbetween(oppRec.Event__r.Start_Date__c);
    //     }
               
    //     if(quoteList2.size()>0) {
    //         displayPopup=true;
    //         displayMsg = 'An Opportunity can only have one quote with status "Signed - Approved"';
            return null;
    //     }else if(DocuSignStatusRecords.size() > 0){
    //         displayPopup=true;
    //         if(String.isNotBlank(SITE.getPathPrefix())) {
    //             displayMsg = 'Previously sent DocuSign envelope found, this envelope must be voided before creating new quote. Please <a href="'+SITE.getPathPrefix()+'/dsfs__DocuSignVoidEnvelopeStandAlone?e='+DocuSignStatusRecords.get(0).dsfs__DocuSign_Envelope_ID__c+'" target="_blank">click here</a> to continue.';
    //         } else {
    //             displayMsg = 'Previously sent DocuSign envelope found, this envelope must be voided before creating new quote. Please <a href="/apex/dsfs__DocuSignVoidEnvelopeStandAlone?e='+DocuSignStatusRecords.get(0).dsfs__DocuSign_Envelope_ID__c+'" target="_blank">click here</a> to continue.';
    //         }
    //         return null;
    //     }else if(oppRec.Phone__c == null || oppRec.Email__c == null || oppRec.Shipping_City__c == null || oppRec.Shipping_Country__c == null || oppRec.Shipping_Street__c == null || oppRec.Shipping_Zip_Postal_Code__c == null || oppRec.Payment_Method__c == null){ // oppRec.Shipping_State_Province__c == null || <- temporarly removed this part to disable validation for state
    //         displayPopup=true;
    //         displayMsg = 'Please Enter values to Phone,Email,Payment Method, Shipping Address and Billing Address are Required';
    //         return null;
    //     /*}else if(oppRec.Payment_Method__c == 'Credit Card' && oppRec.Total_Amount__c > decThresholdAmt &&
    //             (oppRec.Shipping_City__c != oppRec.Billing_City__c || oppRec.Shipping_Country__c != oppRec.Billing_Country__c 
    //             || oppRec.Shipping_State_Province__c != oppRec.Billing_State_Province__c 
    //             || oppRec.Shipping_Street__c != oppRec.Billing_Street__c 
    //             || oppRec.Shipping_Zip_Postal_Code__c != oppRec.Billing_Zip_Postal_Code__c)){
    //         displayPopup=true;
    //         //displayMsg = 'Shipping and Billing Address should be same when selected Payment Method as "Credit Card"';
    //         displayMsg = 'Shipping and Billing Address should be same when Total amount is greater than threshhold amount and require approval from sales.';
    //         return null;
    //     */
    //     }else if(!IsActiveOppPackagesAndALaCartes){ // Check for Package and A La Carte IsActive
    //         displayPopup=true;
    //         displayMsg = 'InActive products found, Please remove following products before creating quote:'+'<br>'+namesOfInActiveItems;
    //         return null;
    //     /*}else if(!allGood){
    //         displayPopup=true;
    //         displayMsg = 'Quote cannot be created Limited inventory is available.';
    //         return null;*/
    //     } else if(oppRec.Payment_Terms__c == 'Net 30' && datediff <= 45){
    //         displayPopup=true;
    //         displayMsg = 'Net 30 is not allowed within 45 days of event start date';
    //         return null; 
    //     }
    //     else {
        
    //         Opportunity oppRec = [select id, name, pricebook2Id from Opportunity where Id =: opp_ID limit 1];
    //         Quote Qe = new Quote();
    //         try{
            
    //         Qe.Name = 'QuoteFromOppty';
    //         Qe.OpportunityId = opp_ID;
    //         Qe.pricebook2Id = oppRec.pricebook2Id;
    //         Insert Qe;
            
    //         System.debug('Qe==>'+Qe);
            
    //         List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
    //         System.debug('opLine: '+opLine);
    //         for(OpportunityLineItem qli: opLine){
    //             QuoteLineItem quotLineRec = new QuoteLineItem();
    //             quotLineRec.Product2Id = qli.PriceBookEntry.Product2Id;
    //             quotLineRec.PriceBookEntryId = qli.PricebookEntryId;
    //             quotLineRec.QuoteId = Qe.Id;
    //             quotLineRec.OpportunityLineItemId = qli.Id;
    //             quotLineRec.Quote_Product_Package_Hotel__c = qli.Opportunity_Product_Package_Hotel__c;
    //             quotLineRec.Package__c = qli.Package__c;
    //             quotLineRec.Quantity = qli.Quantity;
    //             quotLineRec.UnitPrice = qli.UnitPrice;
    //             quotLineRec.ApexHotelTotalPrice__c = qli.ApexHotelTotalPrice__c;
    //             if (qli.Transportation_As_Part_Of_Hotel__c != null) {
    //                 quotLineRec.Transportation_As_Part_Of_Hotel__c = qli.Transportation_As_Part_Of_Hotel__c;
    //             }
    //             quoteLineItemList.add(quotLineRec);
    //         }
            
    //         if(quoteLineItemList.size() > 0){
    //             Insert quoteLineItemList;
    //         }
    //         system.debug('quoteLineItemList'+quoteLineItemList);
            
    //         // List<Opportunity_Payment_Terms__c> lstOppPaymentTerms = New List<Opportunity_Payment_Terms__c>([Select Id,Payment_Due_Date__c,Payment_Term__c from Opportunity_Payment_Terms__c where Opportunity__c =: opp_ID and (Payment_Term__c = 'Net 30')]);
    //         // if(!lstOppPaymentTerms.Isempty()){
    //         //     for(Opportunity_Payment_Terms__c opt: lstOppPaymentTerms){
    //         //         if(opt.Payment_Term__c == 'Net 30'){
    //         //             opt.Payment_Due_Date__c = date.today().adddays(30);
    //         //         }
    //         //     }
    //         //     Update lstOppPaymentTerms;
    //         // }
    //         } catch(exception e) {
    //             System.debug('exception=>'+e+'=LineNumber=>'+e.getLineNumber());
    //         }
            
    //         Map<Id, Id> opportunityIdsAndQuoteIds = new Map<Id, Id>();
    //         QE_Quote_Helper quoteHelper = new QE_Quote_Helper();
    //         opportunityIdsAndQuoteIds.put(Qe.OpportunityId,Qe.Id);
    //         //quoteHelper.copyProductDataToOpportunityField(opportunityIdsAndQuoteIds); // giving error on deploy, don't need this anyway.
            
    //         //pageReference ref=new pageReference('/0Q0/e?retURL='+opp_ID+'&oppid='+opp_ID);
    //         pageReference ref=new pageReference('/'+Qe.Id);
    //         ref.setRedirect(true);
    //         return ref;
    //     }
   }
}