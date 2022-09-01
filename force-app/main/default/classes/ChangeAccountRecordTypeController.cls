Public class ChangeAccountRecordTypeController{
        
    public Account accountRec{get; set;} 
    public Boolean displayPopUp{get; set;}
    public String validationMessage{get; set;}
    
    public ChangeAccountRecordTypeController(ApexPages.StandardController controller) {
        accountRec= new Account();
    }
    
    /*****************************************************************************
    Purpose : This method is used to change the account record type and redirect to record page.
    Parameter : 
    ReturnValue :       
    *****************************************************************************/
    public pageReference upadateAccountRecordType(){
        accountRec= [ select id,Company_Name__pc,Name from Account where id =: Apexpages.currentPage().getParameters().get('id')];
        if(/*test.isRunningTest() ||*/ (accountRec.Company_Name__pc != null && accountRec.Company_Name__pc != '')){
            displayPopUp = false;
            Account objAccount = new Account();
            Id businessAccountRecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            objAccount = new Account(Id = accountRec.id, RecordTypeId = businessAccountRecordTypeId);
            update objAccount;
            //different update call because more fields can not be changed in recordtype change
            objAccount.Name = accountRec.Company_Name__pc;
            update objAccount;
            return redirectAccountDetailPage();
        } else {
            validationMessage = 'Company name is required to convert business account.';
            displayPopUp = true;
            return null;
        }
        
    }
    /*****************************************************************************
    Purpose : This method is used to redirect to the account detail page.
    Parameter : 
    ReturnValue :       
    *****************************************************************************/
    public pageReference redirectAccountDetailPage(){
        
        // Updating account if user click on "OK" button    
        pageReference ref=new pageReference('/'+accountRec.Id);
        ref.setRedirect(true);
        return ref;
    }
    
}