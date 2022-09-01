/**
 * @File Name          : PriceBookInline_LEX.cls
 * @Description        : Creating the event payment term as per the user input and calling from the PriceBook_Inline.cmp
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/21/2020, 3:11:00 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/21/2020    maptel@addonblue.com      Initial Version
**/
public class PriceBookInline_LEX {
    /**
    * @description  : get the pricebook records by id
    * @author       : mpatel@addonblue.com | 4/21/2020 
    * @param        : Id priceBookId
    * @return       : Pricebook2 
    **/
    @AuraEnabled
    public static Pricebook2 getPriceBookRecords(Id priceBookId) {
        Pricebook2 objPricebook = [SELECT X1_2__c, X1_3__c, X100__c,Id FROM Pricebook2 WHERE Id =: priceBookId];
        return objPricebook ;
    }
    /**
    * @description  : get the list of the event payment term
    * @author       : mpatel@addonblue.com | 4/21/2020 
    * @param        : Pricebook2 currentRecord
    * @return       : List<wrapperClass> 
    **/
    @AuraEnabled
	public static List<wrapperClass> paymentList(Pricebook2 currentRecord){
        List<Event_Payment_Terms__c> evePayTermsList = new List<Event_Payment_Terms__c>();
        List<Event_Payment_Terms__c> eveInPayTermsList = new List<Event_Payment_Terms__c>();
        List<wrapperClass> allListWrapperList = new List<wrapperClass>();
        
        if(currentRecord.Id != null)
        evePayTermsList = [SELECT Id, Payment_Due_Date__c, Start_Date__c, End_Date__c, Payment_Term__c, Payment_Term_Flag__c FROM Event_Payment_Terms__c WHERE Price_Book__c =: currentRecord.Id ORDER By Payment_Term__c ASC];
        if(evePayTermsList.size() > 0){
            for(Event_Payment_Terms__c oppPay: evePayTermsList ){
                eveInPayTermsList.add(oppPay);
            }
        }
        if(currentRecord.X1_2__c == true){
            
            Integer due2Count = 0;
            for(Event_Payment_Terms__c evePay: eveInPayTermsList){
                if(evePay.Payment_Term__c == '1/2')
                due2Count = due2Count+1;
            }
            
            if(due2Count != 2){
                for(integer i = 0; i<2; i++){
                    Event_Payment_Terms__c opt = new Event_Payment_Terms__c();
                    opt.Event__c = currentRecord.Id;
                    opt.Payment_Term__c = '1/2';
                    eveInPayTermsList.add(opt);
                }
            }
        }
        
        if(currentRecord.X1_3__c == true){
            Integer due3Count = 0;
            for(Event_Payment_Terms__c evePay: eveInPayTermsList){
                if(evePay.Payment_Term__c == '1/3')
                due3Count = due3Count+1;
            }
            
            if(due3Count != 3){
                for(integer i = 0; i<3; i++){
                    Event_Payment_Terms__c opt = new Event_Payment_Terms__c();
                    opt.Event__c = currentRecord.Id;
                    opt.Payment_Term__c = '1/3';
                    eveInPayTermsList.add(opt);
                }
            }
        }
        
        if(eveInPayTermsList.size() > 0){
            Integer j = 0;
            while (j < eveInPayTermsList.size() ){
              if(currentRecord.X1_2__c == false && eveInPayTermsList.get(j).Payment_Term__c == '1/2'){
                eveInPayTermsList.remove(j);
              }else if(currentRecord.X1_3__c == false && eveInPayTermsList.get(j).Payment_Term__c == '1/3'){
                eveInPayTermsList.remove(j);
              }else{
                j++;
              }
            }
        }
        
        allListWrapperList.add(new wrapperClass(evePayTermsList,eveInPayTermsList));
        return allListWrapperList;
    }

    public class wrapperClass{
        @AuraEnabled public List<Event_Payment_Terms__c> evePayTermsList {get;set;}
        @AuraEnabled public List<Event_Payment_Terms__c> eveInPayTermsList{get;set;}
        public wrapperClass(List<Event_Payment_Terms__c> evePayTermsList, List<Event_Payment_Terms__c> eveInPayTermsList){
        	this.evePayTermsList = evePayTermsList;
            this.eveInPayTermsList = eveInPayTermsList;
        }
    }
    /**
    * @description  : save the list of the event payment term
    * @author       : mpatel@addonblue.com | 4/21/2020 
    * @param        : Pricebook2 currentRecord
    * @param        : String evePayTermsLists
    * @param        : String eveInPayTermsLists
    * @return       : String
    **/
    @AuraEnabled
    public static String savePaymentTerm(Pricebook2 currentRecord, String evePayTermsLists, String eveInPayTermsLists){
        String message ='';
        try{
        List<Event_Payment_Terms__c> evePayTermsList = (List<Event_Payment_Terms__c>)JSON.deserialize(evePayTermsLists,List<Event_Payment_Terms__c>.class);
        List<Event_Payment_Terms__c> eveInPayTermsList = (List<Event_Payment_Terms__c>)JSON.deserialize(eveInPayTermsLists,List<Event_Payment_Terms__c>.class);
       
        Double amount =0;
        Double percent =0;
        Boolean errorflag = false;
        List<Event_Payment_Terms__c> eveDelPayTermsList = new List<Event_Payment_Terms__c>();
        if(!errorflag){
            
            for(Event_Payment_Terms__c evePayRec: evePayTermsList){
                if(currentRecord.X1_2__c == false && evePayRec.Payment_Term__c == '1/2')
                    eveDelPayTermsList.add(evePayRec);
                if(currentRecord.X1_3__c == false && evePayRec.Payment_Term__c == '1/3')
                    eveDelPayTermsList.add(evePayRec);
            }
            
            Integer custCount = 0; 
            if(eveInPayTermsList.size() > 0 ){
                for(Event_Payment_Terms__c evePay: eveInPayTermsList){
                    if(evePay.Event__c != null){
                        evePay.Price_Book__c = evePay.Event__c;
                        evePay.Event__c =null;
                    }
                }
            }
        
            if(eveInPayTermsList.size() > 0){
                Utility.processRecords(eveInPayTermsList, 'upsert');
            }
            if(eveDelPayTermsList.size() > 0){
                Utility.processRecords(eveDelPayTermsList, 'delete');
            }            
            Utility.processRecords(currentRecord, 'update');
        }
            message = 'success';
        }
        catch(Exception e){
            message = e.getMessage()+' Please Contact System Administrator';
             System.debug('Exception-->'+e.getMessage()+'-->'+e.getLineNumber());
        }
        return message;
    }
}