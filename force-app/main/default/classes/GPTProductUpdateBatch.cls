global class GPTProductUpdateBatch implements Database.Batchable<sObject>{
    public Map<Id, Product2> productUpdateMap = new Map<Id, Product2>();
    
    global GPTProductUpdateBatch(Map<Id, Product2> productUpdateMap ){      
        this.productUpdateMap= productUpdateMap;
    }
    
    global Iterable<sObject> start(Database.batchableContext BC){
        return productUpdateMap.values();
    }   
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){  
        System.debug('scope.size()-->'+scope.size()); 
        List<Product2> productToUpdate= new List<Product2>();

        for(sObject s: scope){
            productToUpdate.add((Product2)s);
        }
        if(!productToUpdate.isEmpty()){
            Utility.processRecords(productToUpdate, 'update');
        }
        System.debug('productToUpdate--->'+productToUpdate);
    }
    
    global void finish(Database.BatchableContext BC){
    }
}