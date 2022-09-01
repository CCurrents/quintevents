/**
 * @File Name          : ProgramTriggerHelper.cls
 * @Description        : Helper class for ProgramTriggerHelper
 * @Author             : vaibhav.khopade@addonblue.com
 * @Group              : 
 * @Last Modified By   : vaibhav.khopadea@addonblue.com
 * @Last Modified On   : 05-23-2022
 * @Modification Log   : 
 * Ver       Date            Author                  		Modification
 * 1.0    05/23/2022   vaibhav.khopade@addonblue.com     	Initial Version, created for issue 1194

**/

public with sharing class ProgramTriggerHelper {
    Private Map<Id, Program__c> newProgramMap;
    Private Map<Id, Program__c> oldProgramMap;
    Private List<Program__c> newProgramList;
    Private List<Program__c> oldProgramList;
    
    public ProgramTriggerHelper() {
        
        this.newProgramMap = (Map<Id, Program__c>) Trigger.newMap;
        this.oldProgramMap = (Map<Id, Program__c>) Trigger.oldMap;
        this.newProgramList = (List<Program__c>) Trigger.new;
        this.oldProgramList = (List<Program__c>) Trigger.old;
        Set<Id> updatedProgIDs = new Set<Id>();
        List<Program__c> updatedProgs = new List<Program__c>();
        
         switch on Trigger.operationType {
             
            when AFTER_UPDATE {
                System.debug('*** In Program AFTER_UPDATE!');
                for(Program__c prog : newProgramList){
                    if((string)prog.Terms_Conditions__c != (string)oldProgramMap.get(prog.Id).Terms_Conditions__c || (string)prog.Terms_And_Conditions_AR__c != (string)oldProgramMap.get(prog.Id).Terms_And_Conditions_AR__c
                    || (string)prog.Terms_And_Conditions_DE__c != (string)oldProgramMap.get(prog.Id).Terms_And_Conditions_DE__c || (string)prog.Terms_And_Conditions_ES__c != (string)oldProgramMap.get(prog.Id).Terms_And_Conditions_ES__c
                    || (string)prog.Terms_And_Conditions_FR__c != (string)oldProgramMap.get(prog.Id).Terms_And_Conditions_FR__c || (string)prog.Terms_And_Conditions_IT__c != (string)oldProgramMap.get(prog.Id).Terms_And_Conditions_IT__c
                    || (string)prog.Terms_And_Conditions_JA__c != (string)oldProgramMap.get(prog.Id).Terms_And_Conditions_JA__c || (string)prog.Terms_And_Conditions_ZH__c != (string)oldProgramMap.get(prog.Id).Terms_And_Conditions_ZH__c 
                    || (string)prog.Addendum_A_Waiver__c != (string)oldProgramMap.get(prog.Id).Addendum_A_Waiver__c || (string)prog.Addendum_A_Waiver_AR__c != (string)oldProgramMap.get(prog.Id).Addendum_A_Waiver_AR__c  
                    || (string)prog.Addendum_A_Waiver_DE__c != (string)oldProgramMap.get(prog.Id).Addendum_A_Waiver_DE__c || (string)prog.Addendum_A_Waiver_ES__c != (string)oldProgramMap.get(prog.Id).Addendum_A_Waiver_ES__c 
                    || (string)prog.Addendum_A_Waiver_FR__c != (string)oldProgramMap.get(prog.Id).Addendum_A_Waiver_FR__c || (string)prog.Addendum_A_Waiver_IT__c != (string)oldProgramMap.get(prog.Id).Addendum_A_Waiver_IT__c 
                    || (string)prog.Addendum_A_Waiver_JA__c != (string)oldProgramMap.get(prog.Id).Addendum_A_Waiver_JA__c || (string)prog.Addendum_A_Waiver_ZH__c != (string)oldProgramMap.get(prog.Id).Addendum_A_Waiver_ZH__c)
                    {
                        system.debug('*** inside if...terms & Conditions updated on program ');
                        updatedProgIDs.add(prog.Id);
                        updatedProgs.add(prog);
                    }
                }
                if(updatedProgIDs.size() > 0){
                    system.debug(' *** before calling updateTermsNConditions ');
                	List<Pricebook2> pricebooksForUpdatedProgs = [Select Id,Name,Post_to_Slack_Channel__c,Slack_Channel_Id__c,Slack_Channel_Name__c,IsActive,TOPOS__c,Program__c,
                                                                  Terms_And_Conditions__c,Terms_And_Conditions_AR__c, Terms_And_Conditions_DE__c, Terms_And_Conditions_ES__c, Terms_And_Conditions_FR__c, Terms_And_Conditions_IT__c, Terms_And_Conditions_JA__c, Terms_And_Conditions_ZH__c, 
                                                                  Addendum_A_Waiver__c, Addendum_A_Waiver_AR__c	, Addendum_A_Waiver_DE__c, Addendum_A_Waiver_ES__c, Addendum_A_Waiver_FR__c, Addendum_A_Waiver_IT__c, Addendum_A_Waiver_JA__c, Addendum_A_Waiver_ZH__c
                                                                  from Pricebook2 Where Program__c IN :updatedProgIDs AND IsActive = true];
                    system.debug(' *** number of pricebooks to update for terms & conditions = ' + pricebooksForUpdatedProgs.size());
                    updateTermsNConditions(pricebooksForUpdatedProgs, updatedProgIDs, updatedProgs);
                }
            }
         }
    }
    
    
    //VKHOPADE - issue 1194
    /**
    * @description  : Method to update Terms & COnditions on Pricebooks
    * @author       : vaibhav.khopade@addonblue.com
    * @return       : void
    **/
    public void updateTermsNConditions(List<Pricebook2> newPricebookList, Set<Id> programIDs,List<Program__c> programsList){
        List<Pricebook2> lstPriceBookToUpdate = new List<Pricebook2>();
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
        
        system.debug(' *** programIDs = ' + programIDs);
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
        system.debug(' ***** programTermsConditionsMap = ' + programTermsConditionsMap);

        for(Pricebook2 objPB: newPricebookList){
            Pricebook2 PB = new Pricebook2(Id = objPB.Id);
            Boolean UpdatePricebook = False;
            
            if(objPB.Program__c != null){
                if(programTermsConditionsMap.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Terms_Conditions__c != (string)newProgramMap.get(objPB.Program__c).Terms_Conditions__c)){
                    String termsNConditions = programTermsConditionsMap.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** added pricebook to update = ' + PB);
                }
                
                //AR
                if(programTermsConditions_AR_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Terms_And_Conditions_AR__c != (string)newProgramMap.get(objPB.Program__c).Terms_And_Conditions_AR__c)){
                    String termsNConditions = programTermsConditions_AR_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_AR__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** AR... added pricebook to update = ' + PB);
                }
                
                //DE
                if(programTermsConditions_DE_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Terms_And_Conditions_DE__c != (string)newProgramMap.get(objPB.Program__c).Terms_And_Conditions_DE__c)){
                    String termsNConditions = programTermsConditions_DE_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_DE__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** DE...added pricebook to update = ' + PB);
                }
                
                //ES
                if(programTermsConditions_ES_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Terms_And_Conditions_ES__c != (string)newProgramMap.get(objPB.Program__c).Terms_And_Conditions_ES__c)){
                    String termsNConditions = programTermsConditions_ES_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_ES__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** ES...added pricebook to update = ' + PB);
                }
                
                //FR
                if(programTermsConditions_FR_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Terms_And_Conditions_FR__c != (string)newProgramMap.get(objPB.Program__c).Terms_And_Conditions_FR__c)){
                    String termsNConditions = programTermsConditions_FR_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_FR__c = termsNConditions;
                    //lstPriceBookToUpdate.add(PB);
                    UpdatePricebook = True;
                    system.debug('*** FR...added pricebook to update = ' + PB);
                }
                
                //IT
                if(programTermsConditions_IT_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Terms_And_Conditions_IT__c != (string)newProgramMap.get(objPB.Program__c).Terms_And_Conditions_IT__c)){
                    String termsNConditions = programTermsConditions_IT_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_IT__c = termsNConditions;
                    //lstPriceBookToUpdate.add(PB);
                    UpdatePricebook = True;
                    system.debug('*** IT...added pricebook to update = ' + PB);
                }
                
                //JA
                if(programTermsConditions_JA_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Terms_And_Conditions_JA__c != (string)newProgramMap.get(objPB.Program__c).Terms_And_Conditions_JA__c)){
                    String termsNConditions = programTermsConditions_JA_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_JA__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** JA...added pricebook to update = ' + PB);
                }
                
                //ZH
                if(programTermsConditions_ZH_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Terms_And_Conditions_ZH__c != (string)newProgramMap.get(objPB.Program__c).Terms_And_Conditions_ZH__c)){
                    String termsNConditions = programTermsConditions_ZH_Map.get(objPB.Program__c);
                    termsNConditions = termsNConditions.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    termsNConditions = termsNConditions.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Terms_And_Conditions_ZH__c = termsNConditions;
                    UpdatePricebook = True;
                    system.debug('*** ZH...added pricebook to update = ' + PB);
                }
                
                
                //Addendum Waiver
                if(programAddendumWaiverMap.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Addendum_A_Waiver__c != (string)newProgramMap.get(objPB.Program__c).Addendum_A_Waiver__c)){
                    String AddendumAWaiver = programAddendumWaiverMap.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //AR
                if(programAddendumWaiver_AR_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Addendum_A_Waiver_AR__c != (string)newProgramMap.get(objPB.Program__c).Addendum_A_Waiver_AR__c)){
                    String AddendumAWaiver = programAddendumWaiver_AR_Map.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver_AR__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //DE
                if(programAddendumWaiver_DE_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Addendum_A_Waiver_DE__c != (string)newProgramMap.get(objPB.Program__c).Addendum_A_Waiver_DE__c)){
                    String AddendumAWaiver = programAddendumWaiver_DE_Map.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver_DE__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //ES
                if(programAddendumWaiver_ES_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Addendum_A_Waiver_ES__c != (string)newProgramMap.get(objPB.Program__c).Addendum_A_Waiver_ES__c)){
                    String AddendumAWaiver = programAddendumWaiver_ES_Map.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver_ES__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //FR
                if(programAddendumWaiver_FR_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Addendum_A_Waiver_FR__c != (string)newProgramMap.get(objPB.Program__c).Addendum_A_Waiver_FR__c)){
                    String AddendumAWaiver = programAddendumWaiver_FR_Map.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver_FR__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //IT
                if(programAddendumWaiver_IT_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Addendum_A_Waiver_IT__c != (string)newProgramMap.get(objPB.Program__c).Addendum_A_Waiver_IT__c)){
                    String AddendumAWaiver = programAddendumWaiver_IT_Map.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver_IT__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //JA
                if(programAddendumWaiver_JA_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Addendum_A_Waiver_JA__c != (string)newProgramMap.get(objPB.Program__c).Addendum_A_Waiver_JA__c)){
                    String AddendumAWaiver = programAddendumWaiver_JA_Map.get(objPB.Program__c);
                    AddendumAWaiver = AddendumAWaiver.replace('Event_Name', '<b>' + objPB.Name + '</b>');
                    AddendumAWaiver = AddendumAWaiver.replace('EVENT_NAME', '<b>' + objPB.Name + '</b>');
                    PB.Addendum_A_Waiver_JA__c = AddendumAWaiver;
                    UpdatePricebook = True;
                }
                
                //ZH
                if(programAddendumWaiver_ZH_Map.get(objPB.Program__c) != null && ((string)oldProgramMap.get(objPB.Program__c).Addendum_A_Waiver_ZH__c != (string)newProgramMap.get(objPB.Program__c).Addendum_A_Waiver_ZH__c)){
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
            update lstPriceBookToUpdate;
        }
    }
    
}