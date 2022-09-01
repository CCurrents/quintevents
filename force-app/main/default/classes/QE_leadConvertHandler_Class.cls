public class QE_leadConvertHandler_Class{
public  Id leadId;
public string status{get;set;}
public  boolean displayPopUp{get;set;}
public QE_leadConvertHandler_Class(ApexPages.StandardController stdController)
{
//status=convertLeadBasedOnLeadType();
}
public pageReference convertLeadBasedOnLeadType(){
try{
leadId=ApexPages.currentPage().getParameters().get('id');
        List<Lead> leadLst = [Select Id,Name,Company,Company_Name__c,Lead_Type__c From Lead Where Id=:leadId];   
        
        if(leadLst.size()>0){
            Lead ld = leadLst[0];
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(ld.id);
            lc.setConvertedStatus('Converted');
            lc.setDoNotCreateOpportunity(true);
            if(ld.Lead_Type__c == 'Business'){
                if(ld.Company == null || ld.Company == ''){
                    if(ld.Company_Name__c != null ){
                        ld.Company = ld.Company_Name__c;
                    }else {
                        ld.Company = ld.Name;
                    }
                }
                //displayPopup=true;
            }
            else if(ld.Lead_Type__c == 'Person'){
                ld.Company = null;
                //displayPopup=true;
            }            
            ld.From_Lead_Convert__c = true;
            update ld;
            
            try {
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                if(lcr.isSuccess()){
                    //displayPopup=true;
                    pageReference ref=new pageReference('/'+String.valueOf(lcr.getAccountId()));
                    ref.setRedirect(true);
                    return ref;
                    
                }
                else{
                    displayPopup=true;
                    status=lcr.getErrors()[0].getMessage();
                    return null;
                    
                }
            } Catch (DMLException dmlEx) {
                displayPopup = true;
                status = dmlEx.getdmlMessage(0);
                return null;
            }
            
            
        }
        else{
            displayPopup=true;
            status='Did not find a lead for conversion.';
            return null;
            
        }
     
}Catch(exception ex)
{
system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
return null;
}
}    
public pageReference closePopup()
{
    displayPopup=false;
    if(leadId!=null)
    {
    pageReference ref=new pageReference('/'+leadId);
    ref.setRedirect(true);
    return ref;
    }
    else
    {
    pageReference ref=new pageReference('/00Q/o');
    ref.setRedirect(true);
    return ref;
    }
}
    }