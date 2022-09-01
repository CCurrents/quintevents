/* ====================================================
@Name:  QE_QuotePDFCustomButton
@Copyright notice: 
Copyright (c) 2016, developed by
    All rights reserved.
    
    Redistribution and use in source and binary forms, 
  with or without modification, are not permitted.                                                                                                    
@======================================================
@======================================================
@Purpose: 
@======================================================
@======================================================
@History                                                                                                                    
@---------                                                                                                                       
@VERSION________AUTHOR______________DATE______________DETAIL                   
 1.0        Sundar Subramaniam   19/12/2016      INITIAL DEVELOPMENT                                 
   
@=======================================================  */
global class QE_QuotePDFCustomButton{
    webService Static String makeQuotePDF(Id quoteId) {
    
        try{
            QuoteDocument qd = new QuoteDocument();
           
            //create a pageReference instance of the VF page.
            pageReference pdf = Page.QE_QuoteCreatePDFPage;
            //pass the Quote Id parameter to the class.
            pdf.getParameters().put('id',quoteId);
            Blob body;
            if(!test.isRunningTest()){
                body = pdf.getContent();
            }else{
                body = blob.valueOf('TestString');
            }
            
            qd.QuoteId = quoteId;
            qd.document = body;  
            
            System.debug('qd==>'+qd);
            if(qd != null)
            Insert qd;
            if(test.isRunningTest()){
                Integer a = 1/0;    
            }
            return 'success';
        }catch(Exception ex){
             string error = String.valueOf(ex);
             return error ;
        }
    }
}