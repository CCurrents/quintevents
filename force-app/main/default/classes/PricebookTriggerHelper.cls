/**
 * @File Name          : PricebookTriggerHelper.cls
 * @Description        : Helper class for PricebookTriggerHandler
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : ratiksinghal@addonblue.com
 * @Last Modified On   : 07-12-2022
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    05/03/2020   fsuraitawala@addonblue.com     Initial Version
 * 1.1    11/13/2020   jagrawal@addonblue.com        #451 Protectgroup Integration
 * 1.2    06/29/2021   cshah@addonblue.com           #1005 Email Alert to Accounting with new Pricebook is created in SF
 * 1.3    02/21/2022   vaibhav.khopade@addonblue.com changes for issue 1169
**/
public with sharing class PricebookTriggerHelper {
    
    private Map<Id, Pricebook2> newPricebookMap; 
    private Map<Id, Pricebook2> oldPricebookMap;
    private List<Pricebook2> newPricebookList;
    private List<Pricebook2> oldPricebookList;
    
    /**
    * @description: Constructor
    * @author: fsuraitawala@addonblue.com
    **/
    public PricebookTriggerHelper() {
        
        this.newPricebookMap = (Map<Id, Pricebook2>) Trigger.newMap;
        this.oldPricebookMap = (Map<Id, Pricebook2>) Trigger.oldMap;
        this.newPricebookList = (List<Pricebook2>) Trigger.new;
        this.oldPricebookList = (List<Pricebook2>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Before Insert!');
                Program__c GPEProgram = [select Id from Program__c where Name = 'Grand Prix Events'];
                for(Pricebook2 objPB: newPricebookList){
                    if(objPB.GPE_Event__c == false && objPB.Name.startswith('GPE - ')){
                        objPB.GPE_Event__c = true;
                    }
                    if(objPB.GPE_Event__c == true){
                        objPB.X100__c = true;
                        objPB.Program__c = GPEProgram.Id;
                    }
                }
            }
            
            when BEFORE_UPDATE {
                System.debug('In Before Update!');
                Program__c GPEProgram = [select Id from Program__c where Name = 'Grand Prix Events'];
                for(Pricebook2 objPB: newPricebookList){
                    if(objPB.GPE_Event__c == True && oldPricebookMap.get(objPB.Id).GPE_Event__c != True){
                        objPB.Program__c = GPEProgram.Id;
                    }
                }
            }
            
            when BEFORE_DELETE {
                System.debug('In Before Delete!');
            }
            
            when AFTER_INSERT {
                System.debug('In After Insert!');
                List<Pricebook2> lstPriceBook = [Select Id,Name,Post_to_Slack_Channel__c,Slack_Channel_Id__c,Slack_Channel_Name__c,IsActive,TOPOS__c,Program__c from Pricebook2 Where Id IN: newPricebookMap.keySet()];
                createSlackChannel(lstPriceBook);
                onAfterInsertPricebook();
                insertSalesAgentEvent(newPricebookList);
                notifyPricebookOncreation(newPricebookList);
                updateTermsNConditions(newPricebookList); //VKHOPADE - issue 1194
            }
            
            when AFTER_UPDATE {
                System.debug('In After Update!');
                List<Pricebook2> lstPriceBook = [Select Id,Post_to_Slack_Channel__c,Slack_Channel_Id__c,Slack_Channel_Name__c,End_Date__c,IsActive,TOPOS__c from Pricebook2 Where Id IN: newPricebookMap.keySet()];
                createSlackChannel(lstPriceBook);
                checkforChannelRename(lstPriceBook,oldPricebookMap);
                //setarchiveChannel(lstPriceBook);
                sendPostActivationMessage(lstPriceBook,oldPricebookMap);
                changedTOPOS(lstPriceBook,oldPricebookMap);
                updateRelatedCustomPB(lstPriceBook);
                insertSalesAgentEvent(newPricebookList);
                sendleadsToOutreach();
            }
            
            when AFTER_DELETE {
                System.debug('In After Delete!');
            }
            
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            
            when else {
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    
    //VKHOPADE - issue 1194
    /**
    * @description  : Method to update Terms & COnditions and AddendumAWaiver on Pricebook
    * @author       : vaibhav.khopade@addonblue.com
    * @return       : void
    **/
    public void updateTermsNConditions(List<Pricebook2> newPricebookList){
        //VKHOPADE - 1194 - start
        //List<Pricebook2> lstPriceBook = [Select Id,Name,Post_to_Slack_Channel__c,Slack_Channel_Id__c,Slack_Channel_Name__c,IsActive,TOPOS__c,Program__c, Program__r.Terms_Conditions__c from Pricebook2 Where Id IN: newPricebookMap.keySet()];
        List<Pricebook2> lstPriceBookToUpdate = new List<Pricebook2>();
        Set<Id> programIDs = new Set<Id>();
        Map<Id, String> programTermsConditionsMap = new Map<Id, String>();
        Map<Id, String> programTermsConditions_AR_Map = new Map<Id, String>();
        Map<Id, String> programTermsConditions_DE_Map = new Map<Id, String>();
        Map<Id, String> programTermsConditions_ES_Map = new Map<Id, String>();
        Map<Id, String> programTermsConditions_FR_Map = new Map<Id, String>();
        Map<Id, String> programTermsConditions_IT_Map = new Map<Id, String>();
        Map<Id, String> programTermsConditions_JA_Map = new Map<Id, String>();
        Map<Id, String> programTermsConditions_ZH_Map = new Map<Id, String>();
        
        Map<Id, String> programAddendumWaiverMap = new Map<Id, String>();
        Map<Id, String> programAddendumWaiver_AR_Map = new Map<Id, String>();
        Map<Id, String> programAddendumWaiver_DE_Map = new Map<Id, String>();
        Map<Id, String> programAddendumWaiver_ES_Map = new Map<Id, String>();
        Map<Id, String> programAddendumWaiver_FR_Map = new Map<Id, String>();
        Map<Id, String> programAddendumWaiver_IT_Map = new Map<Id, String>();
        Map<Id, String> programAddendumWaiver_JA_Map = new Map<Id, String>();
        Map<Id, String> programAddendumWaiver_ZH_Map = new Map<Id, String>();
        
        for(Pricebook2 objPB: newPricebookList){
            system.debug(' *** objPB.Terms_And_Conditions__c = ' + objPB.Terms_And_Conditions__c);
            //if(objPB.Terms_And_Conditions__c == null || objPB.Terms_And_Conditions__c == ''){
                programIDs.add(objPB.Program__c);
            //}
        }
        system.debug(' *** programIDs = ' + programIDs);
        List<Program__c> programsList = [Select Id, Name, Terms_Conditions__c,Terms_And_Conditions_AR__c,Terms_And_Conditions_DE__c,Terms_And_Conditions_ES__c,Terms_And_Conditions_FR__c,Terms_And_Conditions_IT__c,Terms_And_Conditions_JA__c,Terms_And_Conditions_ZH__c, 
                                         Addendum_A_Waiver__c, Addendum_A_Waiver_AR__c	, Addendum_A_Waiver_DE__c, Addendum_A_Waiver_ES__c, Addendum_A_Waiver_FR__c, Addendum_A_Waiver_IT__c, Addendum_A_Waiver_JA__c, Addendum_A_Waiver_ZH__c
                                         from Program__c where Id IN :programIDs];
        system.debug('*** programsList = ' + programsList);
        
        for(Program__c prog : programsList){
            programTermsConditionsMap.put(prog.Id, prog.Terms_Conditions__c);
            programTermsConditions_AR_Map.put(prog.Id, prog.Terms_And_Conditions_AR__c);
            programTermsConditions_DE_Map.put(prog.Id, prog.Terms_And_Conditions_DE__c);
            programTermsConditions_ES_Map.put(prog.Id, prog.Terms_And_Conditions_ES__c);
            programTermsConditions_FR_Map.put(prog.Id, prog.Terms_And_Conditions_FR__c);
            programTermsConditions_IT_Map.put(prog.Id, prog.Terms_And_Conditions_IT__c);
            programTermsConditions_JA_Map.put(prog.Id, prog.Terms_And_Conditions_JA__c);
            programTermsConditions_ZH_Map.put(prog.Id, prog.Terms_And_Conditions_ZH__c);
            
            programAddendumWaiverMap.put(prog.Id, prog.Addendum_A_Waiver__c);
            programAddendumWaiver_AR_Map.put(prog.Id, prog.Addendum_A_Waiver_AR__c);
            programAddendumWaiver_DE_Map.put(prog.Id, prog.Addendum_A_Waiver_DE__c);
            programAddendumWaiver_ES_Map.put(prog.Id, prog.Addendum_A_Waiver_ES__c);
            programAddendumWaiver_FR_Map.put(prog.Id, prog.Addendum_A_Waiver_FR__c);
            programAddendumWaiver_IT_Map.put(prog.Id, prog.Addendum_A_Waiver_IT__c);
            programAddendumWaiver_JA_Map.put(prog.Id, prog.Addendum_A_Waiver_JA__c);
            programAddendumWaiver_ZH_Map.put(prog.Id, prog.Addendum_A_Waiver_ZH__c);
        }
        
        for(Pricebook2 objPB: newPricebookList){
            Pricebook2 PB = new Pricebook2(Id = objPB.Id);
            Boolean UpdatePricebook = False;
                
            if(objPB.Program__c != null){
                system.debug('*** inside For-IF1, objPB.Program__r.Terms_Conditions__c = ' + objPB.Program__r.Terms_Conditions__c);
                if((objPB.Terms_And_Conditions__c == null || objPB.Terms_And_Conditions__c == '') && programTermsConditionsMap.get(objPB.Program__c) != null){        
                    String termsNConditions = programTermsConditionsMap.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** added pricebook to update = ' + PB);
                }
                
                //AR
                if((objPB.Terms_And_Conditions_AR__c == null || objPB.Terms_And_Conditions_AR__c == '') && programTermsConditions_AR_Map.get(objPB.Program__c) != null){
                    String termsNConditions = programTermsConditions_AR_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_AR__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** AR... added pricebook to update = ' + PB);
                }
            
            	//DE
            	if((objPB.Terms_And_Conditions_DE__c == null || objPB.Terms_And_Conditions_DE__c == '') && programTermsConditions_DE_Map.get(objPB.Program__c) != null){
                    String termsNConditions = programTermsConditions_DE_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_DE__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** DE... added pricebook to update = ' + PB);
                }
            
            	//ES
            	if((objPB.Terms_And_Conditions_ES__c == null || objPB.Terms_And_Conditions_ES__c == '') && programTermsConditions_ES_Map.get(objPB.Program__c) != null){
                    String termsNConditions = programTermsConditions_ES_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_ES__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** ES... added pricebook to update = ' + PB);
                }
            
            	//FR
            	if((objPB.Terms_And_Conditions_FR__c == null || objPB.Terms_And_Conditions_FR__c == '') && programTermsConditions_FR_Map.get(objPB.Program__c) != null){
                    String termsNConditions = programTermsConditions_FR_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_FR__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** FR... added pricebook to update = ' + PB);
                }
            
            	//IT
            	if((objPB.Terms_And_Conditions_IT__c == null || objPB.Terms_And_Conditions_IT__c == '') && programTermsConditions_IT_Map.get(objPB.Program__c) != null){
                    String termsNConditions = programTermsConditions_IT_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_IT__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** IT... added pricebook to update = ' + PB);
                }
            
            	//JA
            	if((objPB.Terms_And_Conditions_JA__c == null || objPB.Terms_And_Conditions_JA__c == '') && programTermsConditions_JA_Map.get(objPB.Program__c) != null){
                    String termsNConditions = programTermsConditions_JA_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_JA__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** JA... added pricebook to update = ' + PB);
                }
            
            	//ZH
            	if((objPB.Terms_And_Conditions_ZH__c == null || objPB.Terms_And_Conditions_ZH__c == '') && programTermsConditions_ZH_Map.get(objPB.Program__c) != null){
                    String termsNConditions = programTermsConditions_ZH_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_ZH__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** ZH... added pricebook to update = ' + PB);
                }
                
                //Addendum Waiver
                if(programAddendumWaiverMap.get(objPB.Program__c) != null && objPB.Addendum_A_Waiver__c == null){
                    String AddendumAWaiver = programAddendumWaiverMap.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //AR
                if(programAddendumWaiver_AR_Map.get(objPB.Program__c) != null && objPB.Addendum_A_Waiver_AR__c == null){
                    String AddendumAWaiver = programAddendumWaiver_AR_Map.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver_AR__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //DE
                if(programAddendumWaiver_DE_Map.get(objPB.Program__c) != null && objPB.Addendum_A_Waiver_DE__c == null){
                    String AddendumAWaiver = programAddendumWaiver_DE_Map.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver_DE__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //ES
                if(programAddendumWaiver_ES_Map.get(objPB.Program__c) != null && objPB.Addendum_A_Waiver_ES__c == null){
                    String AddendumAWaiver = programAddendumWaiver_ES_Map.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver_ES__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //FR
                if(programAddendumWaiver_FR_Map.get(objPB.Program__c) != null && objPB.Addendum_A_Waiver_FR__c == null){
                    String AddendumAWaiver = programAddendumWaiver_FR_Map.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver_FR__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //IT
                if(programAddendumWaiver_IT_Map.get(objPB.Program__c) != null && objPB.Addendum_A_Waiver_IT__c == null){
                    String AddendumAWaiver = programAddendumWaiver_IT_Map.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver_IT__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //JA
                if(programAddendumWaiver_JA_Map.get(objPB.Program__c) != null && objPB.Addendum_A_Waiver_JA__c == null){
                    String AddendumAWaiver = programAddendumWaiver_JA_Map.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver_JA__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //ZH
                if(programAddendumWaiver_ZH_Map.get(objPB.Program__c) != null && objPB.Addendum_A_Waiver_ZH__c == null){
                    String AddendumAWaiver = programAddendumWaiver_ZH_Map.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver_ZH__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                if(UpdatePricebook == True){
                    lstPriceBookToUpdate.add(PB);
                }
            }
        } 
        if(lstPriceBookToUpdate.size() > 0){
            Utility.processRecords(lstPriceBookToUpdate, 'update');
        }
        
    }
    //VKHOPADE - 1194 - end
    
    
    /**
    * @description  : Method for handle after insert event
    * @author       : fsuraitawala@addonblue.com
    * @return       : void
    **/
    public void onAfterInsertPricebook() {
        List<Product2> autoGeneratedProducts = new List<Product2>();
        List<Price_Book_Custom__c> customPricebooks = new List<Price_Book_Custom__c>();
        
        try {
            for(Pricebook2 objPB: newPricebookList) {
                //Setup Custom Pricebook Records
                customPricebooks.add(new Price_Book_Custom__c(Price_Book2__c = objPB.Id, Name = objPB.Name));
                
                autoGeneratedProducts.add(ProductRecord(objPB.Id, 'Discount', 'Discount'));
                autoGeneratedProducts.add(ProductRecord(objPB.Id, 'Reward Discount', 'Reward Discount'));
                autoGeneratedProducts.add(ProductRecord(objPB.Id, 'Shipping and Handling', 'Shipping and Handling'));
                autoGeneratedProducts.add(ProductRecord(objPB.Id, 'Retail Hotel', 'Retail Hotel'));
                autoGeneratedProducts.add(ProductRecord(objPB.Id, 'Sales Adjustment', 'Sales Adjustment'));
                //#460 Parking Pass change added by Fesal
                autoGeneratedProducts.add(ProductRecord(objPB.Id, 'Parking Pass Not Included', 'Parking Pass Not Included'));
                // #451 Protectgroup Integration
                autoGeneratedProducts.add(ProductRecord(objPB.Id, 'Protect Group', 'Protect Group'));
            }
            if(autoGeneratedProducts.size() > 0) {
                Utility.processRecords(autoGeneratedProducts, 'insert');
            }
            if(!customPricebooks.isEmpty()){
                Utility.processRecords(customPricebooks, 'insert');
            }
        } catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    
    /**
    * @description  : Method for create sample Product Record
    * @author       : fsuraitawala@addonblue.com
    * @param        : PriceBookId(Pricebook Id)
    * @param        : Name(Name Of product)
    * @param        : ProductType(Procuct's Type)
    * @return       : Product2 
    **/
    public static Product2 ProductRecord(String PriceBookId, String Name, String ProductType) {
        Product2 objProduct = new Product2();
        objProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId();
        objProduct.Auto_Generated_Product__c = true;
        objProduct.IsActive = true;
        objProduct.Name = Name;
        objProduct.Type__c = ProductType;
        objProduct.Primary_Price_Book__c = PriceBookId;
        objProduct.Available__c = true;
        objProduct.Quantity_Per_Order_Threshold__c = 5;
        //#460 Parking Pass change added by Fesal
        if(objProduct.Name == 'Parking Pass Not Included') {
            objProduct.A_La_Carte__c = true;
        }
        // #994 - Update Product price as null/blank in test class
        objProduct.Price__c = 0;
        return objProduct;
    }

    public static void createSlackChannel(List<Pricebook2> lstPriceBook){
        List<Id> lstIds = new List<Id>();
        for(Pricebook2 objPrice : lstPriceBook){
            if(objPrice.Post_to_Slack_Channel__c == true && objPrice.Slack_Channel_Id__c == null && objPrice.Slack_Channel_Name__c != null){
                lstIds.add(objPrice.Id);
            }
        }
        if(lstIds.size() > 0){
            //SlackPriceBookChannel.createChannel(lstIds);
            System.enqueueJob(new SlackPriceBookChannel(lstIds));
        }
    }

    public static void checkforChannelRename(List<Pricebook2> lstPriceBook, Map<Id,Pricebook2> oldPricebookMap){
        List<Id> lstIds = new List<Id>();
        for(Pricebook2 objPrice : lstPriceBook){
            if(objPrice.Slack_Channel_Name__c != oldPricebookMap.get(objPrice.Id).Slack_Channel_Name__c && objPrice.Slack_Channel_Id__c != null && objPrice.Post_to_Slack_Channel__c == true && objPrice.Slack_Channel_Name__c != null){
                lstIds.add(objPrice.Id);
            }
        }
        if(lstIds.size() > 0){
            //RenameSlackPriceBookChannel.renameChannel(lstIds);
            System.enqueueJob(new RenameSlackPriceBookChannel(lstIds));
        }
    }

    /*public static void setarchiveChannel(List<Pricebook2> lstPriceBook){
        List<Pricebook2> lstPrice = new List<Pricebook2>();
        for(Pricebook2 objPrice : lstPriceBook){
            if( objPrice.End_Date__c != null && objPrice.Slack_Channel_Id__c != null){
                //lstPrice.add(objPrice);
                scheduleForArchivechannel.scheduleThis(objPrice.End_Date__c,objPrice.Id);
            }
        }  
    }*/

    public static void sendPostActivationMessage(List<Pricebook2> lstPriceBook, Map<Id,Pricebook2> oldPricebookMap){
        List<Id> lstIds = new List<Id>();
        for(Pricebook2 objPrice : lstPriceBook){
            if(objPrice.IsActive != oldPricebookMap.get(objPrice.Id).IsActive){
                lstIds.add(objPrice.Id);
            }
        }
        if(lstIds.size() > 0){
            //SlackPriceBookActivation.postActivation(lstIds);
            System.enqueueJob(new SlackPriceBookActivation(lstIds));
        }
    }

    public static void changedTOPOS(List<Pricebook2> lstPriceBook,Map<Id,Pricebook2> oldPricebookMap){
        List<Product2> listProducts = new List<Product2>();
        List<Id> lstPriceIds = new List<Id>();
        for(Pricebook2 objPrice : lstPriceBook){
            if(objPrice.TOPOS__c != oldPricebookMap.get(objPrice.Id).TOPOS__c){
                List<Product2> objProduct = updateProduct(objPrice.Id,objPrice.TOPOS__c);
                listProducts.addAll(objProduct);
            }
        }
        if(listProducts.size() > 0){
            Utility.processRecords(listProducts, 'update');
        }
    }

    public static List<Product2> updateProduct(Id priceIds, Date TOPOSDate){
        List<Product2> listProduct = [Select Id,TOPOS__c,Primary_Price_Book__c from Product2 where Primary_Price_Book__c =: priceIds];
        for(Product2 objProduct : listProduct){
            objProduct.TOPOS__c = TOPOSDate;
        }
        return listProduct;
    }
    
    /**
    * @description  : Method for update Custom Price Book Record
    * @author       : fsuraitawala@addonblue.com
    * @param        : lstPriceBook(List<Pricebook2>)
    * @return       : void
    **/
    public static void updateRelatedCustomPB(List<Pricebook2> lstPriceBook) {
        List<Price_Book_Custom__c> lstCustomPriceBook = new List<Price_Book_Custom__c>();
        
        if(lstPriceBook != null && lstPriceBook.size() > 0) {
            lstCustomPriceBook = [SELECT Id, Name, Price_Book2__c FROM Price_Book_Custom__c Where Price_Book2__c IN : lstPriceBook];
            if(lstCustomPriceBook != null && lstCustomPriceBook.size() > 0) {
                update lstCustomPriceBook;
            }
        }
    }
    
    /**
    * @description  : Create sales agent event when price book is created/updated with any program field.
    * @author       : mpatel@addonblue.com
    * @return       : void
    **/
    public static void insertSalesAgentEvent(List<Pricebook2> newPricebookList){
        Set<id> programId = new Set<Id>();
        for(Pricebook2 objPB: newPricebookList){
            programId.add(objPB.Program__c);
        }
        
        List<Sales_Agent__c> salesAgentList = [select id,Program__c,(Select id,Price_Book__r.id, Sales_Agent__c,Price_Book__c from Sales_Agent_Events__r)
                                                 from Sales_Agent__c where Program__c in: programId];
        System.debug('salesAgentList-->'+salesAgentList);
        Map<Id,Set<Id>> salesAgentEventMap = new Map<Id,Set<Id>>();
        Set<Id> agentIdSet = new Set<Id>();
        for(Sales_Agent__c saObj : salesAgentList){
            salesAgentEventMap.put(saObj.Id, new Set<Id>{});
            agentIdSet.add(saObj.Id);
            if(!saObj.Sales_Agent_Events__r.isEmpty()){
                for(Sales_Agent_Event__c  salesAgentEvent : saObj.Sales_Agent_Events__r){
                    if(salesAgentEventMap.get(salesAgentEvent.Sales_Agent__c).isEmpty()){
                        salesAgentEventMap.put(salesAgentEvent.Sales_Agent__c,new Set<Id>{salesAgentEvent.Price_Book__r.id});
                    }else{
                        salesAgentEventMap.get(salesAgentEvent.Sales_Agent__c).add(salesAgentEvent.Price_Book__c);  
                    }  
                }
            }
        }
        List<Sales_Agent_Event__c> salesAgentEvList = new List<Sales_Agent_Event__c>();
        for(Pricebook2 priceBook: newPricebookList){
            for(Sales_Agent__c salesAgent : salesAgentList){
                if(salesAgent.Program__c == priceBook.Program__c && salesAgentEventMap.containsKey(salesAgent.Id) && !salesAgentEventMap.get(salesAgent.Id).contains(priceBook.id)){
                    
                        Sales_Agent_Event__c salesAgentEv = new Sales_Agent_Event__c();
                        salesAgentEv.Sales_Agent__c = salesAgent.Id;
                        salesAgentEv.Price_Book__c = priceBook.id;
                        salesAgentEvList.add(salesAgentEv);
                } 
            }
        }
        if(!salesAgentEvList.isEmpty()) {
            insert salesAgentEvList;
            System.debug('salesAgentEvList-->'+salesAgentEvList);
        }
    }
    
    /**
    * @description  : Email Alert to Accounting with new Pricebook is created in SF
    * @author       : cshah@addonblue.com
    * @return       : void
    **/
    public static void notifyPricebookOncreation(List<Pricebook2> newPricebookList) {
        try {
            List<String> sendTo = new List<String>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(Pricebook2 objpb: [Select Id,Name,Start_Date__c,End_Date__c, GPE_Event__c,Program_Name__c from Pricebook2 where Id IN :newPricebookList]) {
                boolean isExculdeGPEEmailNotification = false;
                if((objpb.Name != null && objpb.Name.startswith('GPE')) || objpb.Program_Name__c.equals('Grand Prix Events') || objpb.GPE_Event__c == true ){
                    isExculdeGPEEmailNotification = true;
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                sendTo.add(Label.Accounting_Email);
                mail.setToAddresses(sendTo);
                    
                mail.setSubject('New Event Added to Salesforce');
                
                String emailbody = '<b>' + 'Event Name: ' +'</b>'+ objpb.Name + '<br/>'; 
                emailbody += '<b>' + 'Event Id: '+'</b>' + string.valueof(objpb.Id).substring(0, 15) + '<br/>';
                
                if(objpb.Start_Date__c != null) {
                    Datetime sdt = datetime.newInstance(objpb.Start_Date__c.year(),objpb.Start_Date__c.month(),objpb.Start_Date__c.day());
                    String formattedStartDate = sdt.format('YYYY-MM-dd');
                    emailbody += '<b>' + 'Event Start Date: '+'</b>' + formattedStartDate + '<br/>';
                }
                
                if(objpb.End_Date__c != null) {
                    Datetime edt = datetime.newInstance(objpb.End_Date__c.year(),objpb.End_Date__c.month(),objpb.End_Date__c.day());
                    String formattedEndDate = edt.format('YYYY-MM-dd');
                    emailbody += '<b>' + 'Event End Date: '+'</b>' + formattedEndDate;
                }
                
                mail.setHtmlBody(emailbody);
                if(!isExculdeGPEEmailNotification){
                    mails.add(mail);
                }               
            }
            System.debug('@@@mails.size....'+mails.size());
            if(mails.size() > 0) {
                 Messaging.sendEmail(mails);
            }
        }
        catch(Exception ex) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        }
    }

     /**
    * @description  : Send leads to outreach when sequenceid on Pricebook is updaed in SF
    * @author       : ravindra.isakapatla@addonblue.com
    * @return       : void
    **/
    public void sendleadsToOutreach(){
        set<Id> pricebookIds = new set<Id>();
        List<Id> LeadIds = new List<Id>();
        
        for(Pricebook2 pb : newPricebookList ){
            if(pb.Sequence_ID__c!=null && pb.Program__c!=null
               && pb.Sequence_ID__c!= oldPriceBookMap.get(pb.Id).Sequence_ID__c){
                pricebookIds.add(pb.Id);
                Database.executeBatch(new OutReachLeadProcessBatch('LeadIds',pb.Sequence_ID__c),3);   
            }
        }
        
       /* for(Lead ld : [select id,outreach_Id__c,Event_Interest_Picklist_PB__c,Event_Interest_Picklist_PB__r.Program__r.contact_site__c,
                       owner.name,Event_Interest_Picklist_PB__r.Sequence_ID__c,ownerid from lead 
                       where IsConverted = false and outreach_Id__c != null 
                       and Event_Interest_Picklist_PB__r.Program__c!=null and Actively_being_Sequenced__c=false and
                       Event_Interest_Picklist_PB__c In:pricebookIds and owner.name !='Quinton Escobar' and status!='In Sequence'
                       and Sequence_Status__c NOT IN ('Sequence Added', 'Sequence Finished') ]){
                        LeadIds.add(ld.id);   
                       }
        if(!LeadIds.isEmpty()){
             Database.executeBatch(new OutReachLeadProcessBatch(LeadIds),5);
        }*/
    }
}