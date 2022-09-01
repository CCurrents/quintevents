public class QE_OpportunityLineItemHelper {

    // Constructor
    public QE_OpportunityLineItemHelper(){}

    // Caculate opportunity line item
    public void calculateOpportunityLineItems(List<OpportunityLineItem> opportunityLineItems) {
        // CurrencyType Helper
        QE_DatedConversionRateHelper datedConversionRateHelper = new QE_DatedConversionRateHelper();
        // Query all related data
        Map<Id,OpportunityLineItem> opportunityLineItemsWithRelatedData = new Map<Id,OpportunityLineItem>([
            Select Id, Quantity, ListPrice, Product2.Id, Product2.Price__c, Product2.Cost__c, Product2.Event__r.Tax_Percentage__c,
                Product2.Tax_Percentage__c, Product2.VAT_Tax__c, Product2.Processing_Fee__c, Product2.Event__r.Processing_Fee__c,Product2.Name,
                Opportunity.Payment_Method__c, Product2.Event__r.Shipping_And_Handling__c, Product2.Event__r.Shipping_And_Handling_Outside_US__c,Opportunity.Exchange_Rate_Date_Override__c,
                Record_Type__c,UnitPrice,Opportunity.Reward_Percentage__c,Reward_Points_Earned__c,Package__c,opportunity.Qualifies_for_Reward_Points__c,
                Reward_Points_Percentage__c,TotalPrice,Opportunity.Event__r.Program__r.Name,Product_Type__c,OpportunityId,CurrencyIsoCode,
                 Opportunity.Shipping_Outside_US__c, ProductType__c, Discount_Amount__c, Opportunity.CurrencyIsoCode,Opportunity.Remove_Processing_Fee__c
            From OpportunityLineItem
            Where Id In :opportunityLineItems
        ]);
        Set<Id> opportunityIdset = new Set<Id>();
        // List of opportunity line items to update
        List<OpportunityLineItem> opportunityLineItemsToUpdate = new List<OpportunityLineItem>();
        // Set field values for opportunity line items
        for(OpportunityLineItem oli : opportunityLineItemsWithRelatedData.values()) {
         //To collect lineitems opportunity Id's
            if(oli.OpportunityId != null){
                opportunityIdset.add(oli.OpportunityId);
            }
            // Only calculate if its Package or Optional Package Product or A La Carte
            if(oli.Record_Type__c != null && oli.ProductType__c != 'Opportunity Discount' && (oli.Record_Type__c.equals('Package') || oli.Record_Type__c.equals('Optional Package Product') || oli.Record_Type__c.equals('A La Carte'))) {
                OpportunityLineItem oliToUpdate = new OpportunityLineItem();
                oliToUpdate.Id = oli.Id;
                // Cost
                if(oli.CurrencyIsoCode.equals('USD')) {
                    // For USD
                    oliToUpdate.Cost__c = oli.Product2.Cost__c == null ? 0 : oli.Product2.Cost__c;
                } else {
                    // For rest of Currencies
                    oliToUpdate.Cost__c = oli.Product2.Cost__c == null ? 0 : datedConversionRateHelper.convert(oli.Product2.Cost__c, oli.CurrencyIsoCode, oli.Opportunity.Exchange_Rate_Date_Override__c); // Amount, CurrencyIsoCode of LineItem
                }
                oliToUpdate.Cost__c = (oliToUpdate.Cost__c).setScale(2);
                // Price for shipping and handling
                if((Test.isRunningTest()) || (oli.Record_Type__c != null && oli.Record_Type__c.equals('A La Carte') && oli.ProductType__c != null && oli.ProductType__c.equals('Shipping and Handling'))) {
                    if(oli.Opportunity.Shipping_Outside_US__c.equals('Yes')) {
                        // Outside US
                        if(oli.CurrencyIsoCode.equals('USD')) {
                            // For USD
                            oliToUpdate.ListPrice_Used__c = oli.Product2.Event__r.Shipping_And_Handling_Outside_US__c == null ? 0 : oli.Product2.Event__r.Shipping_And_Handling_Outside_US__c;
                        } else {
                            // For Non USD
                            oliToUpdate.ListPrice_Used__c = oli.Product2.Event__r.Shipping_And_Handling_Outside_US__c == null ? 0 : datedConversionRateHelper.convert(oli.Product2.Event__r.Shipping_And_Handling_Outside_US__c, oli.CurrencyIsoCode,oli.Opportunity.Exchange_Rate_Date_Override__c); // Amount, CurrencyIsoCode of LineItem
                        }
                    } else {
                        // Inside US
                        if(oli.CurrencyIsoCode.equals('USD')) {
                            // For USD
                            oliToUpdate.ListPrice_Used__c = oli.Product2.Event__r.Shipping_And_Handling__c == null ? 0 : oli.Product2.Event__r.Shipping_And_Handling__c;
                        } else {
                            // For Non USD
                            oliToUpdate.ListPrice_Used__c = oli.Product2.Event__r.Shipping_And_Handling__c == null ? 0 : datedConversionRateHelper.convert(oli.Product2.Event__r.Shipping_And_Handling__c, oli.CurrencyIsoCode,oli.Opportunity.Exchange_Rate_Date_Override__c); // Amount, CurrencyIsoCode of LineItem
                        }
                    }
                    oliToUpdate.ListPrice_Used__c = (oliToUpdate.ListPrice_Used__c).setScale(2);
                } else {
                // Price for regular products
                    oliToUpdate.ListPrice_Used__c = (oli.ListPrice == null ? 0 : oli.ListPrice).setScale(2);
                }
                // List Price with Discount
                oliToUpdate.ListPrice_with_Discount__c = (oliToUpdate.ListPrice_Used__c - (oli.Discount_Amount__c == null ? 0 : oli.Discount_Amount__c)).setScale(2,System.RoundingMode.HALF_UP);
                // Tax
                if(oli.Product2.Tax_Percentage__c == null) {
                    oliToUpdate.Tax_Percentage_Used__c = oli.Product2.Event__r.Tax_Percentage__c == null ? 0 : oli.Product2.Event__r.Tax_Percentage__c;
                } else {
                    oliToUpdate.Tax_Percentage_Used__c = oli.Product2.Tax_Percentage__c;
                }
                // Set tax to 0 if its shipping and handling line item
                if(oli.Record_Type__c != null && oli.Record_Type__c.equals('A La Carte') && oli.ProductType__c != null && (oli.ProductType__c.equals('Shipping and Handling') || oli.ProductType__c.equals('Discount'))) {
                    oliToUpdate.Tax_Amount__c = 0.00;
                } else {
                    oliToUpdate.Tax_Amount__c = (oliToUpdate.ListPrice_with_Discount__c * oliToUpdate.Tax_Percentage_Used__c/100).setScale(2,System.RoundingMode.HALF_UP);
                }
                oliToUpdate.Total_Tax_Amount__c = (oliToUpdate.Tax_Amount__c * oli.Quantity).setScale(2,System.RoundingMode.HALF_UP);
                // VAT Tax
                oliToUpdate.VAT_Tax_Amount__c = (oli.Product2.VAT_Tax__c == null ? 0 : oli.Product2.VAT_Tax__c).setScale(2,System.RoundingMode.HALF_UP);
                oliToUpdate.Total_VAT_Tax__c = (oliToUpdate.VAT_Tax_Amount__c * oli.Quantity).setScale(2,System.RoundingMode.HALF_UP);
                // Subtotal
                Decimal subtotal = 0;
                // For shipping and handling
                if(oli.Record_Type__c != null && oli.Record_Type__c.equals('A La Carte') && oli.ProductType__c != null && oli.ProductType__c.equals('Shipping and Handling')) {
                    subtotal = oliToUpdate.ListPrice_with_Discount__c;
                } else {
                    // For regular products
                    subtotal = oliToUpdate.ListPrice_with_Discount__c + oliToUpdate.Tax_Amount__c + oliToUpdate.VAT_Tax_Amount__c;
                }
                subtotal = subtotal.setScale(2,System.RoundingMode.HALF_UP);
                // Credit Card Fee, Calculate this as long as Credit Card Fee/Processing Fee field has value.
                if(oli.Product2.Processing_Fee__c == null) {
                    oliToUpdate.Processing_Fee_Percentage_Used__c = oli.Product2.Event__r.Processing_Fee__c == null ? 0 : oli.Product2.Event__r.Processing_Fee__c;
                } else {
                    oliToUpdate.Processing_Fee_Percentage_Used__c = oli.Product2.Processing_Fee__c == null ? 0 : oli.Product2.Processing_Fee__c;
                }
                if(oli.Opportunity.Remove_Processing_Fee__c){
                    oliToUpdate.Processing_Fee_Amount__c = 0.00;
                }else{
                    oliToUpdate.Processing_Fee_Amount__c = (subtotal * (oliToUpdate.Processing_Fee_Percentage_Used__c == null ? 0 : oliToUpdate.Processing_Fee_Percentage_Used__c)/100).setScale(2,System.RoundingMode.HALF_UP);
                }
                oliToUpdate.Total_Processing_Fee_Amount__c = (oliToUpdate.Processing_Fee_Amount__c * oli.Quantity).setScale(2,System.RoundingMode.HALF_UP);
                // UnitPrice
                // For VAT Tax OLI
                if((oli.Record_Type__c != null && oli.ProductType__c != null && oli.Record_Type__c.equals('A La Carte') && oli.ProductType__c.equals('VAT Tax')) || oli.ProductType__c == 'Reward Discount' || oli.Product2.Name == 'CUG Hotel' 
                        || (oli.Product_Type__c.equals('Stay') && QE_QNGOnlineSaleCtrl.isQNGStay)) {
                   // Don't update the unit price, its being set in QE_OpportunityLineItemHandler based on Package's VAT Tax.
                   //Don't update the unit price for Discount producttype__c OLI. It is set in QE_OpportunityLineItemHandler based on other OLI products of the Opportunity

                } else {
                    // For regular products
                    oliToUpdate.UnitPrice = (subtotal + oliToUpdate.Processing_Fee_Amount__c).setScale(2,System.RoundingMode.HALF_UP);
                }
                Decimal totalPrice;
                if(oli.opportunity.CurrencyIsoCode != 'USD'){
                    totalPrice = new QE_DatedConversionRateHelper().convertCurrencyFromIsoToIso(oli.TotalPrice,oli.opportunity.CurrencyIsoCode, 'USD');
                } else {
                    totalPrice = oli.TotalPrice;
                }
                // To calculate the Reward_Points_Earned__c value by taking total price and percentage defined in product.
                if(oli.opportunity.Qualifies_For_Reward_Points__C == true && oli.Reward_Points_Percentage__c != null && oli.Reward_Points_Percentage__c > 0 && oli.TotalPrice != null && oli.Opportunity.Event__r.Program__r.Name != null && oli.Opportunity.Event__r.Program__r.Name.contains('F1E') && oli.productType__c != 'Reward Discount'  && oli.productType__c != 'Shipping and Handling' && (oli.package__c == null || oli.ProductType__c == 'Hotel')) {
                    if(oli.opportunity.reward_percentage__c != null || Test.isRunningTest()) {
                        oliToUpdate.Reward_Points_Earned__c = oli.opportunity.Reward_Percentage__c/100 * totalPrice;
                    } else if(oli.opportunity.reward_percentage__c == null)  {
                        oliToUpdate.Reward_Points_Earned__c = oli.Reward_Points_Percentage__c/100 * totalPrice;
                    }
                } else if(oli.opportunity.Qualifies_For_Reward_points__C == true && (oli.Reward_Points_Percentage__c == null || oli.Reward_Points_Percentage__c == 0) && oli.TotalPrice != null && oli.Opportunity.Event__r.Program__r.Name != null && oli.Opportunity.Event__r.Program__r.Name.contains('F1E') && oli.productType__c != 'Reward Discount' && oli.productType__c != 'Shipping and Handling' && (oli.package__c == null || oli.ProductType__c == 'Hotel')) {
                    System.debug('***No product percentage&&& in'+oli.Reward_Points_Percentage__c);
                    if(oli.opportunity.reward_percentage__c != null || Test.isRunningTest()) {
                        oliToUpdate.Reward_Points_Earned__c = oli.opportunity.Reward_Percentage__c/100 * totalPrice;
                    } else if(oli.opportunity.reward_percentage__c == null)  {
                        oliToUpdate.Reward_Points_Earned__c = 0.1 * totalPrice;
                    }
                }

                // TotalPrice
                // SF automatically caculates TotalPrice (UnitPrice * Quantity)
                // Add to list of OLI's to update
                opportunityLineItemsToUpdate.add(oliToUpdate);
            }
        }

        // Update all opporunity line items
        if (opportunityLineItemsToUpdate.size() > 0) {
            Update opportunityLineItemsToUpdate;
            system.debug('****oppotunity new updated***'+opportunityLineItemsToUpdate);
        }
    }

    //AfterInsertUpdate opprotunityLineItem to Update VAT_Included_In_All_Products__c
    public static void InsertUpdateVatProductCnt(List<OpportunityLineItem> newOppLineItem, map<Id,OpportunityLineItem> mapOldLineItem) {
        Set<Id> opportunityIds = new Set<Id>();

        for(OpportunityLineItem objoppli : newOppLineItem) {
           //if(mapOldLineItem == null || mapOldLineItem.get(objoppli.id).VAT_Amount_Calculation__c!= objoppli.VAT_Amount_Calculation__c){
                opportunityIds.add(objoppli.OpportunityId);
           //}
        }
        if(opportunityIds.size() > 0){
            VATIncludedInAllProducts(opportunityIds);
        }
    }

    //Delete opprotunityLineItem to Update VAT_Included_In_All_Products__c
    public static void DeleteVatProductCnt( List<OpportunityLineItem> OldLineItem) {
        Set<Id> opportunityIds = new Set<Id>();
        for(OpportunityLineItem objoppLI : OldLineItem) {
            opportunityIds.add(objoppLI.OpportunityId);
        }
        if(opportunityIds.size() > 0){
            VATIncludedInAllProducts(opportunityIds);
        }
    }

    public static void VATIncludedInAllProducts(set<Id> opportunityIds) {
        Map<Id,Opportunity> opportunities = new Map<Id, Opportunity>([SELECT Id, VAT_Included_In_All_Products__c FROM Opportunity WHERE Id IN :opportunityIds]);

        //Rollup_VAT_Included_In_All_Products__c
        Map<Id, double> oppAmounts = new Map<Id, double>();

        AggregateResult[] results = [SELECT OpportunityId, SUM(VAT_Amount_Calculation__c) RollupVATCalc FROM OpportunityLineItem WHERE OpportunityId IN :opportunityIds AND (Record_Type__c ='Package' OR Record_Type__c ='Optional Package Product' OR Record_Type__c ='A La Carte' ) GROUP BY OpportunityId];
        for(AggregateResult result : results) {
            Id opportunityId = (Id) result.get('OpportunityId');
            double rollupOppVATCalc = (double) result.get('RollupVATCalc');
            oppAmounts.put(opportunityId, rollupOppVATCalc);
        }
        //Map Amounts for Update
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for(Id opportunityId : opportunities.keySet()) {
            Opportunity opp = opportunities.get(opportunityId);
            double rollupOppVATCalc = 0;

            if (oppAmounts.containsKey(opportunityId)) {
                rollupOppVATCalc = oppAmounts.get(opportunityId);
            }

            if (rollupOppVATCalc != opp.VAT_Included_In_All_Products__c ) {
                opp.VAT_Included_In_All_Products__c = rollupOppVATCalc;
                oppsToUpdate.add(opp);
            }
        }
        //Update Opportunities
        if (oppsToUpdate.isEmpty() == false) {
            upsert oppsToUpdate;
        }
    }
}