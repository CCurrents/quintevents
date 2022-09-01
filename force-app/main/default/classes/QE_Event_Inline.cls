/* ====================================================
@Name:  QE_Event_Inline
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
public class QE_Event_Inline{
    
    public List<SelectOption> payTerm {get;set;}
    public String selectedPayTerm {get;set;}
    public QE360_Event__c currentRecord {get;set;}
    public List<Event_Payment_Terms__c> evePayTermsList {get;set;}
    public List<Event_Payment_Terms__c> eveInPayTermsList {get;set;}
    public boolean showChPay {get;set;}
    public boolean desableRadio {get;set;}
    public boolean saveBtn {get;set;}
    public boolean errorflag {get;set;}
    public boolean addButton {get;set;}
    public boolean customSec {get;set;}

    public QE_Event_Inline(ApexPages.StandardController controller) {
        this.currentRecord = (QE360_Event__c)controller.getRecord();
        currentRecord = [SELECT Id, Name, X100__c, X1_3__c, X1_2__c, Custom__c FROM QE360_Event__c WHERE Id = :currentRecord.Id];
        payTerm = new List<SelectOption>();
        evePayTermsList = new List<Event_Payment_Terms__c>();
        showChPay = false;
        desableRadio = false;
        errorflag = false;
        addButton = false;
        saveBtn = true;
        customSec = false;
        
        if(currentRecord.X100__c == true || currentRecord.X1_3__c == true || currentRecord.X1_2__c == true || (currentRecord.Custom__c != null && currentRecord.Custom__c != 0)){
            showChPay = true;
            desableRadio = true;
            saveBtn = false;
        }
        
        paymentList();
        
    }
    
    public void paymentList(){
        addButton = false;
        evePayTermsList = new List<Event_Payment_Terms__c>();
        eveInPayTermsList = new List<Event_Payment_Terms__c>();
        
        if(currentRecord.Id != null)
        evePayTermsList = [SELECT Id, Payment_Due_Date__c, Start_Date__c, End_Date__c, Event__c, Payment_Term__c FROM Event_Payment_Terms__c WHERE Event__c =: currentRecord.Id];
        
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
        
        if(currentRecord.Custom__c != null && currentRecord.Custom__c > 0){
            Integer due3Count = 0;
            for(Event_Payment_Terms__c evePay: eveInPayTermsList){
                if(evePay.Payment_Term__c == 'Custom')
                due3Count = due3Count+1;
            }
            
            System.debug('due3Count=>'+due3Count);
            System.debug('currentRecord.Custom__c=>'+currentRecord.Custom__c);
            if(due3Count != currentRecord.Custom__c && due3Count != null){
                if(due3Count < currentRecord.Custom__c){
                    for(integer i = 0; i<(currentRecord.Custom__c - due3Count); i++){
                        Event_Payment_Terms__c opt = new Event_Payment_Terms__c();
                        opt.Event__c = currentRecord.Id;
                        opt.Payment_Term__c = 'Custom';
                        eveInPayTermsList.add(opt);
                    }
                }//else if(due3Count > currentRecord.Custom__c){
                    //IF the record count is grater and the selected count is less
                //}
            }
        }
        
        if(eveInPayTermsList.size() > 0){
            Integer j = 0;
            while (j < eveInPayTermsList.size() ){
              if(currentRecord.X1_2__c == false && eveInPayTermsList.get(j).Payment_Term__c == '1/2'){
                eveInPayTermsList.remove(j);
              }else if(currentRecord.X1_3__c == false && eveInPayTermsList.get(j).Payment_Term__c == '1/3'){
                eveInPayTermsList.remove(j);
              }else if(currentRecord.Custom__c == null && eveInPayTermsList.get(j).Payment_Term__c == 'Custom'){
                eveInPayTermsList.remove(j);
              }else{
                j++;
              }
            }
        }
            
    }
    
    List<Event_Payment_Terms__c> eveDelPayTermsList = new List<Event_Payment_Terms__c>();
    public PageReference savePaymentTerm(){
        Double amount =0;
        Double percent =0;
        errorflag = false;
        
        
        //Validation
        /*if(selectedPayTerm != '100%' && selectedPayTerm != 'Custom'){
            if(oppInPayTermsList.size() > 0){
                for(Opportunity_Payment_Terms__c opPayVal: oppInPayTermsList){
                    amount = amount + opPayVal.Amount__c;
                    percent = percent + opPayVal.Percentage_Of_Payment__c ;
                }
            }
            System.debug('amount=>'+amount );
            System.debug('percent=>'+percent );
            System.debug('currentRecord.Amount=>'+currentRecord.Amount);
            System.debug('100=>'+percent );
            if(amount != currentRecord.Amount){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Total Payment amount didnt match with Opportuntiy Amount'));//| Opportunity Amount= '+{!currentRecord.Amount}+' : Total Payment Amount= '+{!amount} ));
                errorflag = true;
                return null;
            }
            if(percent != 100){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Total Payment Percentage miss matched, Please review the payment percentage'));//| Opportunity Percentage= 100 : Total Payment Amount= {!percent}'  ));
                errorflag = true;
                return null;
            }
            
        }*/
        
        if(!errorflag){
            showChPay = true;
            desableRadio = true;
            saveBtn = false;
            
            for(Event_Payment_Terms__c evePayRec: evePayTermsList){
                if(currentRecord.X1_2__c == false && evePayRec.Payment_Term__c == '1/2')
                    eveDelPayTermsList.add(evePayRec);
                    
                if(currentRecord.X1_3__c == false && evePayRec.Payment_Term__c == '1/3')
                    eveDelPayTermsList.add(evePayRec);
                    
                if(currentRecord.Custom__c == null && evePayRec.Payment_Term__c == 'Custom')
                    eveDelPayTermsList.add(evePayRec);

            }
            
            Integer custCount = 0; 
            if(eveInPayTermsList.size() > 0 ){
                currentRecord.Custom__c = 0;
                for(Event_Payment_Terms__c evePay: eveInPayTermsList){
                    if(evePay.Payment_Term__c == 'Custom'){
                        currentRecord.Custom__c = currentRecord.Custom__c + 1;
                    }
                }
            }
            
            System.debug('eveInPayTermsList=>'+eveInPayTermsList);
            if(eveInPayTermsList.size() > 0){
                upsert eveInPayTermsList;
            }
            
            System.debug('eveDelPayTermsList=>'+eveDelPayTermsList);
            if(eveDelPayTermsList.size() > 0){
                delete eveDelPayTermsList;
            }
            
            update currentRecord;
            paymentList();
            return null;
        }
        return null;
        
    }
    
    /*public Event_Payment_Terms__c evePayRec{set;get;} 
    public void deleteButton(){
        Event_Payment_Terms__c evePayRec = null;
        for(Integer i = eveInPayTermsList.size() - 1; i >= 0; i--) {
            if(eveInPayTermsList[i] == evePayRec) {
                eveInPayTermsList.remove(i);
                if(eveInPayTermsList[i].Id != null)
                eveDelPayTermsList.add(eveInPayTermsList[i]); 
            }
        }
    }*/
    
    public Integer rowNum{get;set;}
    public void delRow()
    {
        System.debug('rowNum=>'+rowNum);
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        System.debug('rowNum2=>'+rowNum);
        if(eveInPayTermsList[rowNum].Id != null)
        delete eveInPayTermsList[rowNum];
        eveInPayTermsList.remove(rowNum); 
            
        Integer custCount = 0; 
        if(eveInPayTermsList.size() > 0 ){
            currentRecord.Custom__c = 0;
            for(Event_Payment_Terms__c evePay: eveInPayTermsList){
                if(evePay.Payment_Term__c == 'Custom'){
                    currentRecord.Custom__c = currentRecord.Custom__c + 1;
                }
            }
        }
        update currentRecord;
    }  
    
    public void cangePaymentTerm(){
        showChPay = false;
        desableRadio = false;
        saveBtn = true;
    }
    
    
}