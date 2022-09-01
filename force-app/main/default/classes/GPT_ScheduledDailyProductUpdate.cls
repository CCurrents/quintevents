global class GPT_ScheduledDailyProductUpdate implements Schedulable {
   global void execute(SchedulableContext sc) {
      List<Product2> productList =[Select Id,GPT_Article_Id__c,Event__r.GPT_Event_Id__c,Event__r.GPT_Price_Markup_Percentage__c,GPT_Gross_Price__c,Price__c,Name from Product2 where Event__r.GPT_Event_Id__c != null and GPT_Article_Id__c != null];
      Map<String, Product2> productMap = new Map<String, Product2>();
      for(Product2 product : productList){
          
          if(!productMap.containsKey(product.GPT_Article_Id__c)){
              productMap.put(product.GPT_Article_Id__c, product);
          }
      }
      
      GPT_ProductUpdateBatchClass  batch = new GPT_ProductUpdateBatchClass(productMap);
      database.executebatch(batch);
   }
}