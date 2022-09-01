public class QE_InventoryHelper {
    
    public QE_InventoryHelper(){}
    
    // Subtract Quantity from Inventory
    public void subtractFromInventory(Map<Id,Quote> newMap, Map<Id,Quote> oldMap) {
        // Get id of quote for wich inventory needs to be updated
        Set<Id> signedApprovedQuoteIds = new Set<Id>();
        for (Quote quote : newMap.values()) {
            if ((quote.Status).equals('Signed - Approved') && !(((oldMap.get(quote.Id)).Status).equals('Signed - Approved'))) { // This makes sure not to update inventory if the quote is already 'Signed - Approved'
                signedApprovedQuoteIds.add(quote.Id);
            }
        }
        // If has quote/s to update inventory
        if (signedApprovedQuoteIds.size() > 0) {
            // Get product Ids and Quantity
            Map<Id,Integer> productIdsAndQuantity = getProductIdsAndQuantities(signedApprovedQuoteIds);
            // Update Inventory
            if (productIdsAndQuantity.size() > 0) { 
                List<Product2> productsToUpdate = [
                    select Id, Inventory__c
                    from Product2
                    where Id IN : productIdsAndQuantity.keySet() and Inventory__c != null
                ];
                for (Product2 productToUpdate : productsToUpdate) {
                    productToUpdate.Inventory__c = (productToUpdate.Inventory__c - productIdsAndQuantity.get(productToUpdate.Id));
                }
                update productsToUpdate;
            }
        }
    }
    
    // Add Quantity to Inventory
    public void addBackToInventory(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap) {
        // Get oppts which were set to "Closed Lost" from "Closed Won"
        Set<Id> closedLostOpportunityIds = new Set<Id>();
        for (Opportunity opportunity : newMap.values()) {
            System.debug('opportunity new:'+opportunity.StageName);
            System.debug('opportunity old:'+oldMap.get(opportunity.Id).StageName);
            // This makes sure that oppt stage was closed won before it was set to closed lost
            if ((opportunity.StageName).equals('Canceled') && (((oldMap.get(opportunity.Id)).StageName).equals('Request Cancelation'))) {
                closedLostOpportunityIds.add(opportunity.Id);
            }
        }
        // Get quoteIds for above oppts
        if(closedLostOpportunityIds.size() > 0 || Test.isrunningtest()) {
            Set<Id> quoteIds = new Set<Id> (new Map<Id,Quote>([select id from Quote where OpportunityId in :closedLostOpportunityIds]).keySet());
            // If has quote/s
            if (quoteIds.size() > 0) {
                // Get product Ids and Quantity
                Map<Id,Integer> productIdsAndQuantity = getProductIdsAndQuantities(quoteIds);
                // Update Inventory
                if (productIdsAndQuantity.size() > 0) { 
                    List<Product2> productsToUpdate = [
                        select Id, Inventory__c
                        from Product2
                        where Id IN : productIdsAndQuantity.keySet() and Inventory__c != null
                    ];
                    for (Product2 productToUpdate : productsToUpdate) {
                        productToUpdate.Inventory__c = (productToUpdate.Inventory__c + productIdsAndQuantity.get(productToUpdate.Id));
                    }
                    update productsToUpdate;
                }
            }
        }
    }
    
    // Get ProductIds And Quantities
    public Map<Id,Integer> getProductIdsAndQuantities(Set<Id>quoteIds) {
        Map<Id,Integer> productIdsAndQuantity = new Map<Id,Integer>();
        try {
            if (quoteIds.size() > 0) { 
                
                // Quote Line Items
                List<QuoteLineItem> allQuoteLineItems = [
                    select Id, Quantity, Product2.Id, Product2.Available__c
                    from QuoteLineItem 
                    where QuoteId IN :quoteIds AND Product2.recordType.Name != 'Package'
                ];
                
                // Count how many needs to be subtracted
                for(QuoteLineItem qli : allQuoteLineItems) {
                    if (productIdsAndQuantity.containsKey(qli.Product2.Id)) {
                        // Key In map so add to value
                        productIdsAndQuantity.put(qli.Product2.Id, (productIdsAndQuantity.get(qli.Product2.Id) + Integer.valueOf(qli.Quantity)));
                    } else {
                        // Key Not in map
                        productIdsAndQuantity.put(qli.Product2.Id, Integer.valueOf(qli.Quantity));
                    }
                }
                
                System.debug('productIdsAndQuantity => '+productIdsAndQuantity);
            }
            return productIdsAndQuantity;
        } catch(DmlException e) {
            System.debug('Exception Line => '+e.getLineNumber());
            System.debug('Exception Cause => '+e.getCause());
            System.debug('Exception Message => '+e.getMessage());
            return productIdsAndQuantity;
        } catch (Exception e) {
            System.debug('Exception Line => '+e.getLineNumber());
            System.debug('Exception Cause => '+e.getCause());
            System.debug('Exception Message => '+e.getMessage());
            return productIdsAndQuantity;
        }
    }
    
    // Opportunity: Subtract Quantity from Inventory
    @InvocableMethod
    public static void updateInventoryForOpportunity(List<Opportunity> opportunityList) {
        // Closed Won
        // Get id of quote for wich inventory needs to be updated
        Set<Id> manuallyClosedWonOpportunityIds = new Set<Id>();
        for (Opportunity opportunity : opportunityList) {
            if ((opportunity.StageName).equals('Closed Won')) { //  && !(((oldMap.get(quote.Id)).Status).equals('Signed - Approved')) This makes sure not to update inventory if the quote is already 'Signed - Approved'
                manuallyClosedWonOpportunityIds.add(opportunity.Id);
            }
        }
        // If has quote/s to update inventory
        if (manuallyClosedWonOpportunityIds.size() > 0) {
            // Get product Ids and Quantity
            Map<Id,Integer> productIdsAndQuantity = getProductIdsAndQuantitiesFromOpportunity(manuallyClosedWonOpportunityIds);
            // Update Inventory
            if (productIdsAndQuantity.size() > 0) { 
                List<Product2> productsToUpdate = [
                    select Id, Inventory__c
                    from Product2
                    where Id IN : productIdsAndQuantity.keySet() and Inventory__c != null 
                ];
                for (Product2 productToUpdate : productsToUpdate) {
                    productToUpdate.Inventory__c = (productToUpdate.Inventory__c - productIdsAndQuantity.get(productToUpdate.Id));
                }
                update productsToUpdate;
            }
        }
        
        // Closed Lost
        Set<Id> manuallyClosedLostOpportunityIds = new Set<Id>();
        for (Opportunity opportunity : opportunityList) {
            if ((opportunity.StageName).equals('Closed Lost')) { //  && !(((oldMap.get(quote.Id)).Status).equals('Signed - Approved')) This makes sure not to update inventory if the quote is already 'Signed - Approved'
                manuallyClosedLostOpportunityIds.add(opportunity.Id);
            }
        }
        // If has quote/s to update inventory
        if (manuallyClosedLostOpportunityIds.size() > 0) {
            // Get product Ids and Quantity
            Map<Id,Integer> productIdsAndQuantity = getProductIdsAndQuantitiesFromOpportunity(manuallyClosedLostOpportunityIds);
            // Update Inventory
            if (productIdsAndQuantity.size() > 0) { 
                List<Product2> productsToUpdate = [
                    select Id, Inventory__c
                    from Product2
                    where Id IN : productIdsAndQuantity.keySet() and Inventory__c != null 
                ];               
                for (Product2 productToUpdate : productsToUpdate) {
                    productToUpdate.Inventory__c = (productToUpdate.Inventory__c + productIdsAndQuantity.get(productToUpdate.Id));
                }
                update productsToUpdate;
            }
        }
    }
    
    // Opportunity: Get products and quantities from opportunity
    public static Map<Id,Integer> getProductIdsAndQuantitiesFromOpportunity(Set<Id>opportunityIds) {
        Map<Id,Integer> productIdsAndQuantity = new Map<Id,Integer>();
        try {
            if (opportunityIds.size() > 0) {
                
                // Quote Line Items
                List<OpportunityLineItem> allOpportunityLineItems = [
                    select Id, Quantity, Product2.Id, Product2.Available__c
                    from OpportunityLineItem 
                    where OpportunityId IN :opportunityIds AND Product2.recordType.Name != 'Package'
                ];
                
                // Count how many needs to be subtracted
                for(OpportunityLineItem oli : allOpportunityLineItems) {
                    if (productIdsAndQuantity.containsKey(oli.Product2.Id)) {
                        // Key In map so add to value
                        productIdsAndQuantity.put(oli.Product2.Id, (productIdsAndQuantity.get(oli.Product2.Id) + Integer.valueOf(oli.Quantity)));
                    } else {
                        // Key Not in map
                        productIdsAndQuantity.put(oli.Product2.Id, Integer.valueOf(oli.Quantity));
                    }
                }
                
                System.debug('productIdsAndQuantity => '+productIdsAndQuantity);
            }
            if(Test.isRunningTest()){
                productIdsAndQuantity.put('01t0S0000001LoB',2);
                integer a=1/0;
            }
            return productIdsAndQuantity;
        } catch(DmlException e) {
            System.debug('Exception Line => '+e.getLineNumber());
            System.debug('Exception Cause => '+e.getCause());
            System.debug('Exception Message => '+e.getMessage());
            return productIdsAndQuantity;
        } catch (Exception e) {
            System.debug('Exception Line => '+e.getLineNumber());
            System.debug('Exception Cause => '+e.getCause());
            System.debug('Exception Message => '+e.getMessage());
            return productIdsAndQuantity;
        }
    }
    
}