trigger QE_QuoteLineItemTrigger on QuoteLineItem  (before insert, before update, after insert, after update, Before Delete) {

    QE_QuoteLineItemHandler quoteLineItemHandler = new QE_QuoteLineItemHandler();

    // Before
    if (Trigger.isBefore) {
    
        // Insert
        if (Trigger.isInsert) {
                              
            quoteLineItemHandler.onBeforeInsert(Trigger.new);           
         
        }
                      
    }
         
}