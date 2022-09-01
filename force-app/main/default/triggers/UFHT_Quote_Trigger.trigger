trigger UFHT_Quote_Trigger on Quote (Before Update,After Update){
    	AB_UFHT.UFHT_TrigggerHandler.handleTrigger();
}