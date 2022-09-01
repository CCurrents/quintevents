global class createCustomPBE implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Pricebook2Id, Product2Id FROM PricebookEntry');
    }
    global void execute(Database.BatchableContext bc, List<PricebookEntry> scope){
        List<Price_Book_Entry_Custom__c> lstPBCustom = new List<Price_Book_Entry_Custom__c>();
        
        for(PricebookEntry objPBE: scope) {
            String PEBName = objPBE.Name.length() > 80 ? objPBE.Name.substring(0, 80) : objPBE.Name;
            lstPBCustom.add(new Price_Book_Entry_Custom__c(Name = PEBName, Price_Book_Entry_Id__c = objPBE.Id, Price_Book__c = objPBE.Pricebook2Id, Product__c = objPBE.Product2Id));
        }

        insert lstPBCustom;
    }    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
    }    
}