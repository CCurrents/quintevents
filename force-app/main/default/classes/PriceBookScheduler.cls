/**
 * @File Name          : PriceBookScheduler.cls
 * @Description        : schedule class for the get the pricebook and update 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/20/2020, 10:46:31 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/20/2020     mpatel@addonblue.com      Initial Version
**/
global class PriceBookScheduler implements Schedulable{
    /**
    * @description  : call the class method from this execute method
    * @author       : mpatel@addonblue.com | 4/20/2020 
    * @return       : void 
    **/
    global void execute(SchedulableContext sc) {   
       PriceBookScheduler.retrievePBRecords();
    }
    /**
    * @description  : get the pricebook records
    * @author       : mpatel@addonblue.com | 4/20/2020 
    * @return       : void 
    **/
    global static void retrievePBRecords(){
        try{
            List<PriceBook2> lstPriceBook = New List<PriceBook2>([Select id,End_Date__c,IsActive from PriceBook2 where End_Date__c <: system.today() and IsActive = true]);
            if(!lstPriceBook.Isempty()){
                for(PriceBook2 objPriceBook : lstPriceBook){
                    objPriceBook.IsActive = false;
                }
                Utility.processRecords(lstPriceBook, 'update');
            }
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
}