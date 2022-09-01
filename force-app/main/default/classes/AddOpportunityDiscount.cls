public class AddOpportunityDiscount {

    @AuraEnabled
    public Static List<String> getDiscountType() {
       List<string> lstDiscountTypes = new  List<string>();
       Schema.DescribeFieldResult fieldResult = OpportunityLineitem.Discount_Type__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple){
           lstDiscountTypes.add(f.getValue());
       }   
       return lstDiscountTypes;  
    }
    
    @AuraEnabled
    public Static String getcreateDiscountItem (String oppId, Decimal discountAmount, String discountDescription, String discountType) {
        String result = '';
        Opportunity opp = [Select Id,Event__c,CurrencyIsoCode from Opportunity where Id = :oppId];
        List<OpportunityLineItem> lstOLI = new List<OpportunityLineItem>([Select Id from OpportunityLineItem
                                                    where OpportunityId = :opp.Id and Product2.Event__c = :opp.Event__c 
                                                    and Product2.Name = 'Discount' and ProductType__c = 'Opportunity Discount']);
        if(lstOLI.size () > 0) {
            result = 'Discount already added on this Opportunity.';
        } else {
            List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>([Select Id,Product2Id,CurrencyIsoCode from PricebookEntry 
                                                        where Product2.Event__c = :opp.Event__c and CurrencyIsoCode = :opp.CurrencyIsoCode and
                                                        Product2.Name='Discount' Order By CreatedDate desc Limit 1]);
            if(lstPricebookEntry.size() > 0 /*|| Test.IsRunningTest()*/) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = oppId;
                /*if(Test.IsRunningTest()){
                    Boolean blSandbox = [SELECT Id, IsSandbox, Name FROM Organization LIMIT 1].IsSandbox;
                    oli.PricebookEntryId = blSandbox ? '01u4D000000QddxQAC':'01u1Y000010ym0tQAA';
                    oli.Product2Id = blSandbox ? '01t4D0000007uqd': '01t1Y000007jFCZ';
                }else{*/
                    oli.PricebookEntryId = lstPricebookEntry[0].Id;
                    oli.Product2Id = lstPricebookEntry[0].Product2Id;
                //}
                
                oli.Quantity = 1;
                oli.Discount_Description__c = discountDescription;
                oli.Record_Type__c = 'A La Carte';
                oli.ProductType__c = 'Opportunity Discount';
                //oli.UnitPrice = discountAmount > 0 ? discountAmount : discountAmount * -1;   
                oli.UnitPrice = discountAmount > 0 ? discountAmount * -1: discountAmount;   
                oli.ListPrice_Used__c = oli.UnitPrice;  
                oli.Discount_Type__c = discountType;
                System.debug(oli.UnitPrice);
                insert oli;
                result = 'Discount successfully added on this Opportunity.';
            }
        }
        return result;
    }
}