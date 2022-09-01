/* ====================================================
@Name:  QE_Opportunity_Inline
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
public class QE_Opportunity_Inline {
    /*public List<SelectOption> payTerm {get;set;}
    public String selectedPayTerm {get;set;}
    //public Integer paymentTermsAvailable = 0;
    //public Decimal totPerPay = 0;
    //public  Decimal totPayAmo = 0;
    public Opportunity currentRecord {get;set;}
    // public List<Opportunity_Payment_Terms__c> oppPayTermsList {get;set;}
    public List<Event_Payment_Terms__c> eventPayTermsList {get;set;}
    // public List<Opportunity_Payment_Terms__c> oppInPayTermsList {get;set;}
    public QE360_Event__c QEEvent = new QE360_Event__c();
    public boolean showChPay {get;set;}
    public boolean desableRadio {get;set;}
    public boolean saveBtn {get;set;}
    public boolean errorflag {get;set;}
    public Integer numOfCustomTerms {get; set;}
    public Id chosenPaymentTermIdForDelete {get; set;}
    public Integer chosenPaymentTermRowForDelete {get; set;}*/
    public QE_Opportunity_Inline(ApexPages.StandardController stdController) {
        // this.currentRecord = (Opportunity)controller.getRecord();
        // currentRecord = [SELECT Id, Name, Amount, Grand_Total__c, Event__c, 
        //                  Payment_Terms__c, Payment_Method__c, RecordType.DeveloperName, CreatedDate, CurrencyIsoCode
        //                  FROM Opportunity WHERE Id = :currentRecord.Id];
        // payTerm = new List<SelectOption>();
        // // oppPayTermsList = new List<Opportunity_Payment_Terms__c>();
        // showChPay = false;
        // desableRadio = false;
        // errorflag = false;
        // saveBtn = true;
        // if(currentRecord.Event__c != null) {
        //     QEEvent = [SELECT Id, X100__c, X1_3__c, X1_2__c, Custom__c,Start_Date__c,Last_Payment_Due_Date__c FROM QE360_Event__c WHERE Id =: currentRecord.Event__c];
        // }
        
        // system.debug('@@@@QEEvent.Last_Payment_Due_Date__c==='+QEEvent.Last_Payment_Due_Date__c);
        
        // if(QEEvent != null) {
        //     if(currentRecord.RecordType.DeveloperName == 'Business_Opportunity'){
        //         if(QEEvent.X100__c == true) {
        //             payTerm.add(new SelectOption('100%','100% (Due within 5 days from signed contract date)'));
        //         }
        //     }
            
        //     if(currentRecord.RecordType.DeveloperName != 'Business_Opportunity'){                
        //         if(QEEvent.X1_3__c == true) {
        //             payTerm.add(new SelectOption('1/3','1/3'));
        //         }
        //         if(QEEvent.X1_2__c == true) {
        //             payTerm.add(new SelectOption('1/2','1/2'));
        //         }
        //         if(QEEvent.Custom__c != null && QEEvent.Custom__c > 0) {
        //             payTerm.add(new SelectOption('Custom','Custom'));
        //         }
        //         if(true) {
        //             payTerm.add(new SelectOption('Custom Terms','Custom Payment Terms'));
        //         }
        //     }            
            
            
        //     if(currentRecord.RecordType.DeveloperName == 'Business_Opportunity' && QEEvent.Start_Date__c != null){
        //         Integer datediff = currentRecord.CreatedDate.date().daysbetween(QEEvent.Start_Date__c);
        //         system.debug('###datediff =='+datediff);
        //         if(datediff > 45) {
        //             payTerm.add(new SelectOption('Net 30','Net 30'));
        //             payTerm.add(new SelectOption('Custom Terms','Custom Payment Terms'));
        //         }                
                
        //         if(datediff <= 45) {
        //             payTerm = new List<SelectOption>();
        //             if(QEEvent.X100__c == true) {
        //                 payTerm.add(new SelectOption('100%','100% (Due within 5 days from signed contract date)'));
        //             }
        //             payTerm.add(new SelectOption('Custom Terms','Custom Payment Terms')); 
                                    
        //         }
        //     }
        // }
        // //payTerm.add(new SelectOption('Custom','Custom'));
        // if(currentRecord.Payment_Terms__c != null) {
        //     if(QEEvent != null) {
        //         if(currentRecord.RecordType.DeveloperName == 'Business_Opportunity'){
        //             if(currentRecord.Payment_Terms__c != null){
        //                 selectedPayTerm = currentRecord.Payment_Terms__c;
        //             }else{
        //                 Integer datediffnum = currentRecord.CreatedDate.date().daysbetween(QEEvent.Start_Date__c);
        //                 system.debug('###datediffnum =='+datediffnum);
        //                 if(datediffnum > 45) {
        //                     selectedPayTerm = 'Net 30';
        //                 } else {
        //                     selectedPayTerm = 'Custom Terms';
        //                 }
        //             }
        //         }else{
        //             selectedPayTerm = currentRecord.Payment_Terms__c;
        //         }
        //     } else {
        //         selectedPayTerm = currentRecord.Payment_Terms__c;
        //     }
            
        //     showChPay = true;
        //     desableRadio = true;
        //     saveBtn = false;
        // }
        paymentList();
        saveCustomOpptTerms();
        delOpportuntiyCustomTerm();
        delOpportuntiyCustomTermRow();
        savePaymentTerm();
        cangePaymentTerm();
        populateIntacctRecordURLs();
        getIntcctData('','',null,null);
        SendHttpRequest(null,null,'','');
    }
    public void paymentList() {
        // oppPayTermsList = new List<Opportunity_Payment_Terms__c>();
        // oppInPayTermsList = new List<Opportunity_Payment_Terms__c>();
        // System.debug('oppPayTermsList=>'+oppPayTermsList);
        // if(currentRecord.Id != null)
        // oppPayTermsList = [SELECT Id, Payment_Due_Date__c, Event_Payment_Term__c, Event_Payment_Term__r.Payment_Due_Date__c,Event_Payment_Term__r.End_Date__c, Opportunity__c, Payment_Term__c, Amount__c, Percentage_Of_Payment__c, Status__c FROM Opportunity_Payment_Terms__c WHERE Opportunity__c =: currentRecord.Id];
        // if(currentRecord.Event__c != null)
        // eventPayTermsList = [SELECT Id,Payment_Term__c,Payment_Due_Date__c,Start_Date__c,End_Date__c FROM Event_Payment_Terms__c WHERE Event__c =: currentRecord.Event__c And  Start_Date__c <= TODAY and End_Date__c >= TODAY];
        // System.debug('eventPayTermsList=>'+eventPayTermsList);
        // if(selectedPayTerm == '100%'){
        //     If(selectedPayTerm == currentRecord.Payment_Terms__c && oppPayTermsList.size() > 0){
        //         oppInPayTermsList.addAll(oppPayTermsList);
        //     } else {
        //         Opportunity_Payment_Terms__c opp = new Opportunity_Payment_Terms__c();
        //         opp.Opportunity__c = currentRecord.Id;
        //         if(currentRecord.Amount != null)
        //         opp.Amount__c = currentRecord.Amount;
        //         opp.Percentage_Of_Payment__c = 100 ;
        //         opp.Payment_Term__c = '100%';
        //         opp.Payment_Due_Date__c = date.today();
        //         oppInPayTermsList.add(opp);
        //         System.debug('oppInPayTermsList 100%'+oppInPayTermsList);
        //     }
        // }else if(selectedPayTerm == '1/2'){
        //     If(selectedPayTerm == currentRecord.Payment_Terms__c){
        //         oppInPayTermsList.addAll(oppPayTermsList);
        //     }else{
        //         Integer paymentTermsAvailable = 0;
        //         Decimal totPayAmo = 0;
        //         for(Event_Payment_Terms__c evePay: eventPayTermsList){
        //             if(evePay.Payment_Term__c == '1/2'){
        //                 paymentTermsAvailable++;
        //                 Opportunity_Payment_Terms__c opp = new Opportunity_Payment_Terms__c();
        //                 opp.Opportunity__c = currentRecord.Id;
        //                 Decimal perVal = (100/2.00).setScale(2,System.RoundingMode.HALF_UP);
        //                 if(currentRecord.Amount != null)
        //                 opp.Amount__c = (currentRecord.Amount*(perVal/100)).setScale(2,System.RoundingMode.HALF_UP);
        //                 //opp.Amount__c = currentRecord.Amount/2 ;
        //                 opp.Percentage_Of_Payment__c = 100/2 ;
        //                 opp.Payment_Term__c = '1/2';
        //                 opp.Payment_Due_Date__c = evePay.Payment_Due_Date__c;
        //                 opp.Event_Payment_Term__c = evePay.Id;
        //                 opp.Event_Payment_Term__r = new Event_Payment_Terms__c(Id =evePay.Id, Payment_Due_Date__c = evePay.Payment_Due_Date__c);
        //                 oppInPayTermsList.add(opp);
        //                 totPayAmo = totPayAmo + (opp.Amount__c != null ? opp.Amount__c : 0);
        //             }
        //         }
        //         if(currentRecord.Amount != null && totPayAmo != currentRecord.Amount && paymentTermsAvailable > 0){
        //             oppInPayTermsList[oppInPayTermsList.size()-1].Amount__c = oppInPayTermsList[oppInPayTermsList.size()-1].Amount__c + (currentRecord.Amount-totPayAmo);
        //         }
        //     }
        // } else if(selectedPayTerm == '1/3'){
        //     If(selectedPayTerm == currentRecord.Payment_Terms__c){
        //         oppInPayTermsList.addAll(oppPayTermsList);
        //     }else{
        //         Integer paymentTermsAvailable = 0;
        //         Decimal totPerPay = 0;
        //         Decimal totPayAmo = 0;
        //         for(Event_Payment_Terms__c evePay: eventPayTermsList){
        //             if(evePay.Payment_Term__c == '1/3'){
        //                 paymentTermsAvailable++;
        //                 Opportunity_Payment_Terms__c opp = new Opportunity_Payment_Terms__c();
        //                 opp.Opportunity__c = currentRecord.Id;
        //                 Decimal perVal = (100/3.00).setScale(2,System.RoundingMode.HALF_UP);
        //                 if(currentRecord.Amount != null)
        //                 opp.Amount__c = (currentRecord.Amount*(perVal/100)).setScale(2,System.RoundingMode.HALF_UP);
        //                 opp.Percentage_Of_Payment__c = (100/3.00).setScale(2,System.RoundingMode.HALF_UP);
        //                 opp.Payment_Term__c = '1/3';
        //                 opp.Payment_Due_Date__c = evePay.Payment_Due_Date__c;
        //                 opp.Event_Payment_Term__c = evePay.Id;
        //                 opp.Event_Payment_Term__r = new Event_Payment_Terms__c(Id =evePay.Id, Payment_Due_Date__c = evePay.Payment_Due_Date__c);
        //                 oppInPayTermsList.add(opp);
        //                 totPerPay = totPerPay + (opp.Percentage_Of_Payment__c != null ? opp.Percentage_Of_Payment__c : 0);
        //                 totPayAmo = totPayAmo + (opp.Amount__c != null ? opp.Amount__c : 0);
        //             }
        //         }
        //         if(totPerPay != 100 && paymentTermsAvailable > 0){
        //             oppInPayTermsList[oppInPayTermsList.size()-1].Percentage_Of_Payment__c = oppInPayTermsList[oppInPayTermsList.size()-1].Percentage_Of_Payment__c + (100-totPerPay);
        //         }
        //         if(currentRecord.Amount != null && totPayAmo != currentRecord.Amount && paymentTermsAvailable > 0){
        //             oppInPayTermsList[oppInPayTermsList.size()-1].Amount__c = oppInPayTermsList[oppInPayTermsList.size()-1].Amount__c + (currentRecord.Amount-totPayAmo); // Error amounts not matching for 1/3
        //         }
        //     }
        // }else if(selectedPayTerm == 'Custom'){
        //     If(selectedPayTerm == currentRecord.Payment_Terms__c){
        //         oppInPayTermsList.addAll(oppPayTermsList);
        //     }else{
        //        @Testvisible Integer paymentTermsAvailable = 0;
        //        @Testvisible Decimal totPerPay = 0;
        //        @Testvisible Decimal totPayAmo = 0;
        //         for(Event_Payment_Terms__c evePay: eventPayTermsList){
        //             if(evePay.Payment_Term__c == 'Custom'){
        //                 paymentTermsAvailable++;
        //                 Opportunity_Payment_Terms__c opp = new Opportunity_Payment_Terms__c();
        //                 opp.Opportunity__c = currentRecord.Id;
        //                 Decimal perVal = (100/QEEvent.Custom__c).setScale(2,System.RoundingMode.HALF_UP);
        //                 //opp.Amount__c = currentRecord.Amount/QEEvent.Custom__c;
        //                 if(currentRecord.Amount != null)
        //                 opp.Amount__c = (currentRecord.Amount*(perVal/100)).setScale(2,System.RoundingMode.HALF_UP);
        //                 opp.Percentage_Of_Payment__c = (100/QEEvent.Custom__c).setScale(2,System.RoundingMode.HALF_UP);
        //                 opp.Payment_Term__c = 'Custom';
        //                 opp.Payment_Due_Date__c = evePay.Payment_Due_Date__c;
        //                 oppInPayTermsList.add(opp);
        //                 totPerPay = totPerPay + (opp.Percentage_Of_Payment__c != null ? opp.Percentage_Of_Payment__c : 0);
        //                 totPayAmo = totPayAmo + (opp.Amount__c != null ? opp.Amount__c : 0);
        //             }
        //         }
        //         if(totPerPay != 100 && paymentTermsAvailable > 0){
        //             oppInPayTermsList[oppInPayTermsList.size()-1].Percentage_Of_Payment__c = oppInPayTermsList[oppInPayTermsList.size()-1].Percentage_Of_Payment__c + (100-totPerPay);
        //         }
        //         if(currentRecord.Amount != null && totPayAmo != currentRecord.Amount && paymentTermsAvailable > 0){
        //             oppInPayTermsList[oppInPayTermsList.size()-1].Amount__c = oppInPayTermsList[oppInPayTermsList.size()-1].Amount__c + (currentRecord.Amount-totPayAmo); // error amount not matching for 'custom' terms
        //         }
        //     }
        // } 
        // else if(selectedPayTerm == 'Net 30'){
        //     if(selectedPayTerm == currentRecord.Payment_Terms__c){                
        //         oppInPayTermsList.addAll(oppPayTermsList);
        //     } else {
        //         Opportunity_Payment_Terms__c opp = new Opportunity_Payment_Terms__c();
        //         opp.Opportunity__c = currentRecord.Id;
        //         opp.Amount__c = currentRecord.Amount;
        //         opp.Payment_Term__c = 'Net 30';
        //         opp.Payment_Due_Date__c = date.today().adddays(30);
        //         opp.Percentage_Of_Payment__c  = 100;
        //         oppInPayTermsList.add(opp);
        //     }
        // } else if(selectedPayTerm == 'Custom Terms'){
        //     If(selectedPayTerm == currentRecord.Payment_Terms__c){
        //     system.debug('******205 lin******'+oppPayTermsList.size());
        //         oppInPayTermsList.addAll(oppPayTermsList);
        //     }
        // }
        // //oppPayTermsList.addAll(oppInPayTermsList);
        // System.debug('oppInPayTermsList1=>'+oppInPayTermsList);
    }
    public void saveCustomOpptTerms() {
    // List<Opportunity_Payment_Terms__c> oldOppPaymentList = new List<Opportunity_Payment_Terms__c>();
    //     for (Integer i=0; i<numOfCustomTerms; i++) {
    //         Opportunity_Payment_Terms__c opp = new Opportunity_Payment_Terms__c();
    //         Decimal singleTermPercentage = (100.00/numOfCustomTerms).setScale(2,System.RoundingMode.HALF_UP);
    //         Decimal leftoverPercentagesAfterRounding = (100.00 - (singleTermPercentage*numOfCustomTerms));
    //         opp.Opportunity__c = currentRecord.Id;
    //         opp.Payment_Term__c = 'Custom Terms';
    //         // If percentage becomes decimal and first term
    //         if (i == 0) {
    //            opp.Percentage_Of_Payment__c = singleTermPercentage + leftoverPercentagesAfterRounding;
    //         } else {
    //             opp.Percentage_Of_Payment__c = singleTermPercentage;
    //         }
    //         if(currentRecord.Amount != null) {
    //             opp.Amount__c = currentRecord.Amount * (opp.Percentage_Of_Payment__c/100);
    //         }
    //         oldOppPaymentList.add(opp);
    //        // oppInPayTermsList.add(opp);
    //     }
    //     oppInPayTermsList.clear();
    //     oppInPayTermsList.addAll(oldOppPaymentList);
    //     system.debug('***oppPayTermsList******'+oppPayTermsList);
    //     try{
    //     if(oppPayTermsList.size()>0 && selectedPayTerm == 'Custom Terms') {
    //        delete oppPayTermsList;
    //        }
    //        }
    //        catch(DMLException e) {
    //        }
    }
    public void delOpportuntiyCustomTerm() {
        // Opportunity_Payment_Terms__c paymentTermToDelete = new Opportunity_Payment_Terms__c(id = chosenPaymentTermIdForDelete);
        // delete paymentTermToDelete;
        // paymentList();
    }
    public void delOpportuntiyCustomTermRow() {
        // oppInPayTermsList.remove(chosenPaymentTermRowForDelete);
    }    
    
    public PageReference savePaymentTerm(){
        // Double amount =0;
        // Double percent =0;
        // errorflag = false;
        // if(currentRecord.Amount == null) {
        //     currentRecord.Amount = 0;
        // }
        
        // /*Date Add45DaysToCreatedDate = Date.ValueOf(currentRecord.CreatedDate.adddays(45));
        // if(currentRecord.RecordType.DeveloperName == 'Business_Opportunity' && Add45DaysToCreatedDate > QEEvent.Start_Date__c) {
        //     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Choose Custom Payment Terms.'));
        //     errorflag= true;
        //     return null;
        // }*/
        
        // if((numOfCustomTerms == 0 || numOfCustomTerms == null) && selectedPayTerm == 'Custom Terms' && oppInPayTermsList.size() == 0){
        //     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter some value other than Zero.'));
        //     errorflag= true;
        //     return null;
        // }
        // if(oppInPayTermsList.size() == 0  && selectedPayTerm == 'Custom Terms' && numOfCustomTerms > 0) {
        //     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please create payment terms by clicking on GO.'));
        //     errorflag= true;
        //     return null;
        // }
        // if(oppInPayTermsList.size() > 0 &&  oppInPayTermsList.size() != numOfCustomTerms && selectedPayTerm == 'Custom Terms' && numOfCustomTerms != 0) {
        //     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Create Payment terms by clicking on GO and save.'));
        //     errorflag= true;
        //     return null;
        // }        
        
        // List<Opportunity_Payment_Terms__c> oppDelPayTermsList = new List<Opportunity_Payment_Terms__c>();
        // //Validation
        // if(selectedPayTerm != '100%' && selectedPayTerm != 'Custom' && selectedPayTerm != 'Custom Terms'){
        //     if(oppInPayTermsList.size() > 0){
        //         String termError = '';
        //         integer idx = 0;
        //         for(Opportunity_Payment_Terms__c opPayVal: oppInPayTermsList){
        //             system.debug('********' + opPayVal.Amount__c);
        //             if(opPayVal.Amount__c == null){
        //                 opPayVal.Amount__c = 0;
        //             }
        //             if(idx != 0) {
        //                 if(opPayVal.Payment_Due_Date__c == null) {
        //                     termError = 'Payment Due Date is Required.';
        //                     break;
        //                 } else if(opPayVal.Payment_Due_Date__c < System.Today() ||
        //                          (opPayVal.Event_Payment_Term__c != null &&
        //                          opPayVal.Event_Payment_Term__r.Payment_Due_Date__c != null &&
        //                          opPayVal.Payment_Due_Date__c > opPayVal.Event_Payment_Term__r.Payment_Due_Date__c)) {
        //                     termError = 'Payment Due Date is Invalid.';
        //                     break;
        //                 }
        //             }
                    
        //             amount = amount + opPayVal.Amount__c;
        //             percent = percent + opPayVal.Percentage_Of_Payment__c ;
        //             system.debug('********'+opPayVal.Amount__c);
        //             System.debug('**Am**' +amount);
        //             System.debug('**currnt**' +currentRecord.Amount);
        //             System.debug('**per**' +percent);
        //             System.debug('**per Payment**' +opPayVal.Percentage_Of_Payment__c);
        //             idx++;
        //         }
        //         if(String.isNotBlank(termError)) {
        //             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,termError));
        //             errorflag = true;
        //             return null;
        //         }
        //     } else if(Label.Payment_Term_Not_Valid != 'false') {
        //         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.Payment_Term_Not_Valid));
        //         errorflag = true;
        //         return null;
        //     }
        //     if(amount != currentRecord.Amount && Label.Amount_Mismatched != 'false'){
        //         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.Amount_Mismatched));//| Opportunity Amount= '+{!currentRecord.Amount}+' : Total Payment Amount= '+{!amount} ));
        //         errorflag = true;
        //         return null;
        //     }
        //     if(percent != 100 && Label.Percentage_Mismatched != 'false') {
        //         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.Percentage_Mismatched));//| Opportunity Percentage= 100 : Total Payment Amount= {!percent}'  ));
        //         errorflag = true;
        //         return null;
        //     }
        // }
        // if(!errorflag){
        //     showChPay = true;
        //     desableRadio = true;
        //     saveBtn = false;
        //     boolean upsertflag = true;
        //     for(Opportunity_Payment_Terms__c oppPayRec: oppPayTermsList) {
        //         if(selectedPayTerm != '100%' && oppPayRec.Payment_Term__c == '100%') {
        //             oppDelPayTermsList.add(oppPayRec);
        //         }
        //         if(selectedPayTerm != '1/2' && oppPayRec.Payment_Term__c == '1/2') {
        //             oppDelPayTermsList.add(oppPayRec);
        //         }
        //         if(selectedPayTerm != '1/3' && oppPayRec.Payment_Term__c == '1/3') {
        //             oppDelPayTermsList.add(oppPayRec);
        //         }
        //         if(selectedPayTerm != 'Custom' && oppPayRec.Payment_Term__c == 'Custom') {
        //             oppDelPayTermsList.add(oppPayRec);
        //         }
        //         if(selectedPayTerm != 'Custom Terms' && oppPayRec.Payment_Term__c == 'Custom Terms') {
        //             oppDelPayTermsList.add(oppPayRec);
        //         }
        //         if(selectedPayTerm != 'Net 30' && oppPayRec.Payment_Term__c == 'Net 30') {
        //             oppDelPayTermsList.add(oppPayRec);
        //         }
        //         if(selectedPayTerm == oppPayRec.Payment_Term__c){
        //             //upsertflag = false;
        //         }
        //     }
        //     // This was adding/removing extra penny, because it was recalculating the payment term amount here!
        //     integer count = 0;
        //     for(Opportunity_Payment_Terms__c opPayVal: oppInPayTermsList){
        //         if(selectedPayTerm == 'Custom Terms' || selectedPayTerm == 'Custom'){
        //             system.debug('@@@@QEEvent.Last_Payment_Due_Date__c==='+QEEvent.Last_Payment_Due_Date__c);
        //             system.debug('@@@@opPayVal.Payment_Due_Date__c==='+opPayVal.Payment_Due_Date__c);
                    
        //             if(QEEvent.Last_Payment_Due_Date__c != null && opPayVal.Payment_Due_Date__c > QEEvent.Last_Payment_Due_Date__c){
        //                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Last payment due date must be before '+QEEvent.Last_Payment_Due_Date__c.format()));
        //                 errorflag= true;
        //                 cangePaymentTerm();
        //                 return null;
        //                 break;
        //             }
                    
        //             if(count==0 && opPayVal.Payment_Due_Date__c > system.today().adddays(30)){
        //                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'First payment term due date must be within 30 days.'));
        //                 errorflag= true;
        //                 cangePaymentTerm();
        //                 return null; 
        //                 break;                      
        //             }  
        //             count++;                 
                    
        //         }
        //         if(selectedPayTerm == 'Custom Terms'){                    
        //             if(currentRecord.Amount != null) {
        //                 opPayVal.Amount__c = currentRecord.Amount * (opPayVal.Percentage_Of_Payment__c/100);
        //             }
        //         }
        //         opPayVal.Payment_Method__c = currentRecord.Payment_Method__c;
        //         opPayVal.CurrencyIsoCode = currentRecord.CurrencyIsoCode;
        //     }
        //     oppPayTermsList = new List<Opportunity_Payment_Terms__c>();
        //     currentRecord.Payment_Terms__c = selectedPayTerm;
        //     System.debug('oppInPayTermsList=>'+oppInPayTermsList);
        //     if(oppInPayTermsList.size() > 0){
        //         if(upsertflag)
        //         try {
        //             upsert oppInPayTermsList;
        //         } catch (DMLException dmlEx) {
        //             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, dmlEx.getdmlMessage(0)));
        //             return null;
        //         }
        //     }
        //     if(oppPayTermsList.size() > 0){
        //         update oppPayTermsList;
        //     }
        //     System.debug('oppDelPayTermsList=>'+oppDelPayTermsList);
        //     if(oppDelPayTermsList.size() > 0){
        //         //delete oppDelPayTermsList;
        //         Database.delete(oppDelPayTermsList, false);
        //     }
        //     update currentRecord;
        //     paymentList();
        //     return null;
        // }
        return null;
    }
    public void cangePaymentTerm(){
        /*showChPay = false;
        desableRadio = false;
        saveBtn = true;*/
    }
    
    public void populateIntacctRecordURLs(){
        // String opportunityId= Apexpages.Currentpage().getparameters().get('id');
        // Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        
        // Boolean UpdateOpp = false;
        // Boolean UpdateAcc = false;
        // Boolean UpdateOppPayTerm = false;
        // String RecordURL = '';
        
        // List<Opportunity> opps = New List<Opportunity>([Select Id,Intacct_Id__c,Intacct_Status__c,Sandbox_Intacct_Id__c,Sandbox_Intacct_Status__c,
        //     Sandbox_Intacct_Record_URL__c,Intacct_Record_URL__c,AccountId from Opportunity where Id =: opportunityId and (Intacct_Status__c = 'Success' or Sandbox_Intacct_Status__c = 'Success') and (Intacct_Id__c != null or Sandbox_Intacct_Id__c != null)]);
            
      
        // if(!opps.isEmpty()){
        //     Dom.Document xmlDoc = new Dom.Document();
        //     if(cs.Production__c && opps[0].Intacct_Id__c != null && opps[0].Intacct_Record_URL__c == null){
        //        getIntcctData('SODOCUMENT',opps[0].Intacct_Id__c,cs,xmlDoc); 
        //        RecordURL = SendHttpRequest(cs,xmlDoc,'Sales Order','SODOCUMENT');
        //        if(!string.isblank(RecordURL)){
        //            opps[0].put('Intacct_Record_URL__c',RecordURL); 
        //            UpdateOpp = true;
        //        }
               
        //     }else if(!cs.Production__c && opps[0].Sandbox_Intacct_Id__c != null && opps[0].Sandbox_Intacct_Record_URL__c == null){            
        //         getIntcctData('SODOCUMENT',opps[0].Sandbox_Intacct_Id__c,cs,xmlDoc);                
        //         RecordURL = SendHttpRequest(cs,xmlDoc,'Sales Order','SODOCUMENT');
        //         if(!string.isblank(RecordURL)){
        //            opps[0].put('Sandbox_Intacct_Record_URL__c',RecordURL); 
        //            UpdateOpp = true;
        //         }
        //     } else{
        //         UpdateOpp = false;
        //     }          
        
        //     List<account> accs = New List<Account>([Select Id,Record_Id__c,Sandbox_Record_Id__c,Intacct_Record_URL__c,Sandbox_Intacct_Record_URL__c from Account where Id =: opps[0].AccountId]);
        //     if(!accs.isEmpty()){
        //         xmlDoc = new Dom.Document();
        //         if(cs.Production__c && accs[0].Record_Id__c != null && accs[0].Intacct_Record_URL__c == null){
        //             getIntcctData('CUSTOMER',accs[0].Record_Id__c,cs,xmlDoc);
        //             RecordURL = SendHttpRequest(cs,xmlDoc,'Customer','CUSTOMER');
        //             if(!string.isblank(RecordURL)){
        //                accs[0].put('Intacct_Record_URL__c',RecordURL); 
        //                UpdateAcc= true;
        //            }
                    
        //         }else if(!cs.Production__c && accs[0].Sandbox_Record_Id__c != null && accs[0].Sandbox_Intacct_Record_URL__c == null){
        //             getIntcctData('CUSTOMER',accs[0].Sandbox_Record_Id__c,cs,xmlDoc);
        //             RecordURL = SendHttpRequest(cs,xmlDoc,'Customer','CUSTOMER');
        //             if(!string.isblank(RecordURL)){
        //                accs[0].put('Sandbox_Intacct_Record_URL__c',RecordURL); 
        //                UpdateAcc = true;
        //             }                    
        //         }else{
        //             UpdateAcc = false;
        //         } 
        //     }    
            
            
        //     List<Opportunity_Payment_Terms__c> OpppaymentTerms = New List<Opportunity_Payment_Terms__c>([Select Id,Intacct_Id__c,Sandbox_Intacct_Id__c,Intacct_Record_URL__c,Sandbox_Intacct_Record_URL__c from Opportunity_Payment_Terms__c where Opportunity__c =: opportunityId]);
        //     for(Opportunity_Payment_Terms__c opt: OpppaymentTerms){
        //         xmlDoc = new Dom.Document();
        //         if(cs.Production__c && opt.Intacct_Id__c != null && opt.Intacct_Record_URL__c == null){
        //             getIntcctData('SODOCUMENT','Sales Invoice-'+opt.Intacct_Id__c,cs,xmlDoc);                     
        //             RecordURL = SendHttpRequest(cs,xmlDoc,'Sales Invoice','SODOCUMENT');
        //             if(!string.isblank(RecordURL)){
        //                opt.put('Intacct_Record_URL__c',RecordURL); 
        //                UpdateOppPayTerm = true;
        //             }   
        //         }else if(!cs.Production__c && opt.Sandbox_Intacct_Id__c != null && opt.Sandbox_Intacct_Record_URL__c == null){
        //             getIntcctData('SODOCUMENT','Sales Invoice-'+opt.Sandbox_Intacct_Id__c,cs,xmlDoc);                    
        //             RecordURL = SendHttpRequest(cs,xmlDoc,'Sales Invoice','SODOCUMENT');
        //             if(!string.isblank(RecordURL)){
        //                opt.put('Sandbox_Intacct_Record_URL__c',RecordURL); 
        //                UpdateOppPayTerm = true;
        //             }         
        //         }
        //     }
            
        //     if(UpdateOpp == true){        
        //         update opps;
        //     }
                
        //     if(accs.size()>0 && UpdateAcc == true){
        //         update accs;
        //     }
        //     if(OpppaymentTerms.size()>0 && UpdateOppPayTerm == true){
        //         update OpppaymentTerms;
        //     }
        // }
        
    }
    
    public void getIntcctData(String IntacctObj,String key,Intacct_API_Details__c cs,DOM.Document doc){
        // dom.XmlNode function = QE_Intacct_FutureCallout.controlAuthXML(cs, doc,null );
        // dom.XmlNode read;
        // if(IntacctObj == 'CONTACT' || IntacctObj == 'SODOCUMENT' || IntacctObj == 'ARINVOICE'){
        //     read = function.addChildElement('readByName', null, null);
        // }else{
        //     read = function.addChildElement('read', null, null);
        // }
        // read.addChildElement('object', null, null).addTextNode(IntacctObj);
        // read.addChildElement('keys', null, null).addTextNode(key);
        // read.addChildElement('fields', null, null).addTextNode('RECORD_URL');       
       
    }
    
    public string SendHttpRequest(Intacct_API_Details__c cs,Dom.Document xmlDoc,String IntacctObject, String IntacctTableName){
        // HttpRequest req = new HttpRequest();
        // req.setMethod('POST');
        // req.setEndpoint(cs.Production__c? cs.EndpointURL__c: cs.Sandbox_EndpointURL__c);
        // req.setHeader('Content-Type', 'text/xml');
        // req.setBodyDocument(xmlDoc);
        // System.debug('Request: '+xmlDoc.toXmlString());
        // String RecordURL = '';
        // Http http = new Http();
        // if(!Test.IsrunningTest()){
        //     HttpResponse res = http.send(req);
        //     Dom.Document resDoc = res.getBodyDocument();
        //     System.debug('Responce: '+resDoc.toXmlString());
        //     dom.Xmlnode vxroot = resdoc.getRootElement().getChildElement('operation', null);            
        //     if((IntacctObject == 'Sales Order' || IntacctObject == 'Sales Invoice') && vxroot.getChildElement('result', null).getChildElement('data', null).getChildElement(IntacctTableName, null) != null){
        //         RecordURL = vxroot.getChildElement('result', null).getChildElement('data', null).getChildElement(IntacctTableName, null).getChildElement('RECORD_URL', null).getText();
        //     }else if(IntacctObject == 'Customer' && vxroot.getChildElement('result', null).getChildElement('data', null).getChildElement(IntacctTableName, null) != null){
        //         RecordURL = vxroot.getChildElement('result', null).getChildElement('data', null).getChildElement(IntacctTableName, null).getChildElement('RECORD_URL', null).getText();
        //     }
        // }else{
            // RecordURL = 'https://www.intacct.com/ia/acct/ur.phtml?.r=irkfxpThHu2P6nZr1L8dFg';
        // }
        // return RecordURL;
        return '';
    }
}