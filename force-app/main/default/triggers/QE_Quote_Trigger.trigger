/**
 * @File Name          : QE_Quote_Trigger.trigger
 * @Description        : 
 * @Author             : Lovel Panchal
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/5/2020, 9:58:54 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/5/2020   Lovel Panchal     Initial Version
**/
trigger QE_Quote_Trigger on Quote (before insert, before update, after insert, after update, Before Delete) {

    // QE_Quote_Helper handler = new QE_Quote_Helper(); // rename QE_Quote_Helper to QE_QuoteHandler or QE_Quote_Hanlder
    // QE_QuoteHandler quoteHandler = new QE_QuoteHandler();

    // // Before
    // if (Trigger.isBefore) {
    
    //     // Insert
    //     if (Trigger.isInsert) {
    //         Map<Quote, Id> quotesAndOpportunityIds = new Map<Quote, Id>();
    //         for (Quote currentQuote : Trigger.new) {
    //             quotesAndOpportunityIds.put(currentQuote, currentQuote.OpportunityId);
    //         }
    //         QE_Quote_Helper quoteHelper = new QE_Quote_Helper();
    //         quoteHelper.deleteOldQuotes(quotesAndOpportunityIds);
    //         quoteHelper.updateFieldsBeforeInsert(quotesAndOpportunityIds);
    //     }
        
    // }
    
    // // After
    // if (Trigger.isAfter) {
    
    //     // Insert
    //     if (Trigger.isInsert) {
    //         // Opportunity Ids and Quote Ids
    //         Map<Id, Id> opportunityIdsAndQuoteIds = new Map<Id, Id>();
    //         Set<Id> oppIds = new Set<Id>();
    //         for (Quote currentQuote : Trigger.new) {
    //             opportunityIdsAndQuoteIds.put(currentQuote.OpportunityId,currentQuote.Id);
    //             oppIds.add(currentQuote.OpportunityId);
    //         }
                        
    //         // Quote Ids and Quotes
    //         List<Id> QuoteIds = new List<Id>();
    //         for (Quote currentQuote : Trigger.new) {
    //             QuoteIds.add(currentQuote.Id);
 
    //         }
    //         QE_Quote_Helper quoteHelper = new QE_Quote_Helper();
    //         // Check Inventory and other Conditions
    //         //QE_Quote_Helper.updateQuoteStatus(QuoteIds, 'Quote-Trigger-AfterInsert'); // commented so approval submittion can be managed with button.
    //         // Update Opportunity Stage
    //         quoteHelper.updateOpportunityStage(Trigger.new);
            
    //         //if(opportunityIdsAndQuoteIds.keyset().size() > 0)
    //         //QE_Quote_Helper.createStipCustomer(oppIds);
            
    //         Map<Id, Id> quoteMap = new Map<Id, Id>();
    //         for(Quote currentQuote : Trigger.New)
    //         {
    //             quoteMap.put(currentQuote.Id, currentQuote.OpportunityId);
    //         }
            
    //         //QE_Quote_Helper.syncQuote(quoteMap);
    //         //if(!system.isFuture())
    //         QE_Quote_Helper.createQuote(QuoteIds);
    //         QE_Quote_Helper.createQuoteContact(Trigger.New);
    //         quoteHelper.copyAdditionalSigneesToQuote(opportunityIdsAndQuoteIds);
    //      //   quoteHelper.copyOppProPack(opportunityIdsAndQuoteIds);
    //     }
        
    //     // Update
    //     if (Trigger.isUpdate) {
    //         // Update Opportunity Stage
    //        //if(QE_checkRecursiveQuote.runTwo())  {
    //         QE_Quote_Helper quoteHelper = new QE_Quote_Helper();
    //         quoteHelper.updateOpportunityStage(Trigger.new);
    //         set<Id> quoteId_Set=new set<Id>();
    //         set<Id> oppIds =new set<Id>();
    //         // Send Payment Emails
    //         /*** Added by Jeet ***/ 
    //         //QE_EmailHelper emailHelper = new QE_EmailHelper();
    //         //emailHelper.sendPaymentTokenEmails(Trigger.new,Trigger.oldMap);
    //         QE_InventoryHelper inventoryHelper = new QE_InventoryHelper();
    //         inventoryHelper.subtractFromInventory(Trigger.newMap,Trigger.oldMap);
    //         /*** Added by Jeet End ***/
    //         if(!QE_Quote_Helper.reEntry){
    //             QE_Quote_Helper.reEntry = true;
    //             for (Quote currentQuote : Trigger.new) {
    //                 quoteId_Set.add(currentQuote.Id);
    //             }
    //             Id userId=userInfo.getUserId();
    //             system.debug('userId==>'+userId);
    //             //List<Quote> lstQuote=[select Id,ProfileId from Quote where Id In : quoteId_Set];
    //             for (Quote currentQuote : Trigger.new) {
    //                 //system.debug('currentQuote.profileID==>'+currentQuote.profileID);
    //                 if ( currentQuote.Status == 'Draft - Needs Review' || currentQuote.Status == 'Signed - Needs Review' ) {
    //                     // create the new approval request to submit
    //                     Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    //                     req.setComments('Submitted for approval. Please approve.');
    //                     req.setObjectId(currentQuote.Id);
    //                     // submit the approval request for processing
    //                     if(!Approval.isLocked(currentQuote.Id)){
    //                         try{
    //                             Approval.ProcessResult result = Approval.process(req);
    //                             // display if the reqeust was successful
    //                             System.debug('Submitted for approval successfully: '+result.isSuccess());
    //                         }catch(Exception e){
    //                             currentQuote.addError('Approval Process ALREADY_IN_PROCESS, This Quote is currently in an approval process. A record can be in only one approval process at a time ');
    //                         }
    //                     }
    //                }
                   
    //                if(currentQuote.Status == 'Signed - Approved' && Trigger.oldMap.get(currentQuote.id).Status != Trigger.newMap.get(currentQuote.id).Status){
    //                     oppIds.add(currentQuote.opportunityId);
    //                }
    //             }
                
    //             if(oppIds.size()>0){
    //                 handler.updateDueDateonPaymentTerms(oppIds);
    //             }
    //         }
            
    //         // After Update
    //         quoteHandler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    //     //}
    //   }  
    // }
    
    // if(Trigger.isDelete && Trigger.isBefore) {
        
    //     // Before Delete
    //     handler.onBeforeDelete(Trigger.old, Trigger.oldMap);
    
    // }
    
}