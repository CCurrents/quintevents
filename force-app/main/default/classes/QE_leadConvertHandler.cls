/* ====================================================
@Name:  QE_leadConvertHandler 
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
 1.0        Sundar Subramaniam   21/12/2016      INITIAL DEVELOPMENT                                 

@=======================================================  */
global class QE_leadConvertHandler {
    webService static String convertLeadBasedOnLeadType(Id leadId){
        List<Lead> leadLst = [Select Id,Name,Company,Company_Name__c,Lead_Type__c From Lead Where Id=:leadId];   

        if(leadLst.size()>0){
            Lead ld = leadLst[0];
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(ld.id);
            lc.setConvertedStatus('Converted');
            lc.setDoNotCreateOpportunity(true);
            if(ld.Lead_Type__c == 'Business'){
                if(ld.Company == null || ld.Company == ''){
                    if(ld.Company_Name__c != null || ld.Company_Name__c != ''){
                        ld.Company = ld.Company_Name__c;
                    }else {
                        ld.Company = ld.Name;
                    }
                }
            }
            else if(ld.Lead_Type__c == 'Person'){
                ld.Company = null;
            }            
            
            update ld;
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            
            if(lcr.isSuccess()){
                return String.valueOf(lcr.getAccountId());
            }
            else{
                return lcr.getErrors()[0].getMessage();
            }
        }
        else{
            return 'Did not find a lead for conversion.';
        }
    }
}