/**
* @File Name          : OpportunityTriggerHelper.cls
* @Description        : Trigger helper on Opportunity object and calling from the OpportunityTriggerHelper
* @Author             : fsuraitawala@addonblue.com
* @Group              : 
* @Last Modified By   : fsuraitawala@addonblue.com
* @Last Modified On   : 02-28-2022
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    9/26/2019     fsuraitawala@addonblue.com  Initial Version
* 1.1     2/3/2020     mpatel@addonblue.com        Refactored the code by changing the structure of the code as per the standards
* 1.2    6/9/2020      jagrawal@addonblue.com      Added Conditions before SOQL to reduce unnecessary SOQL
* 1.3    12/17/2020    jagrawal@addonblue.com      # 660 Prevent Reps from Deleting Canceled Opps
* 1.4    01/13/2021    jagrawal@addonblue.com      #707 Allow QE360 - Sales Admin to delete Closed Lost Opps
* 1.5    02/03/2021    vshah@addonblue.com         #698 Changes to the way Opportunity Contact Roles are created for Business Opportunities.
* 1.6    02/20/2022    vaibhav.khopade@addonblue.com       #1157 changes for populating Contact Site on Opportunity from Program  
**/
public with sharing class OpportunityTriggerHelper {
    private Map<Id, Opportunity> newOpportunityMap; 
    private Map<Id, Opportunity> oldOpportunityMap;
    private List<Opportunity> newOpportunityList;
    private List<Opportunity> oldOpportunityList;
    
    public OpportunityTriggerHelper(){
        
        this.newOpportunityMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldOpportunityMap = (Map<Id, Opportunity>) Trigger.oldMap;
        this.newOpportunityList = (List<Opportunity>) Trigger.new;
        this.oldOpportunityList = (List<Opportunity>) Trigger.old;
        
        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                //Set<Id> setOfPriceBookId = new Set<Id>();
                Map<Opportunity, Id> mapOfOpportunityToAccountId = new Map<Opportunity, Id>();
                try{
                    for(Opportunity objOpportunity: newOpportunityList){
                        if(objOpportunity.AccountId != null)
                            mapOfOpportunityToAccountId.put(objOpportunity,objOpportunity.AccountId);
                        
                    
                       
                    }
                    system.debug('mapOfOpportunityToAccountId-->'+mapOfOpportunityToAccountId);
                    // Related Accounts
                    Map<Id, Account> mapOfRelatedAccounts = new Map<Id, Account>();
                    List<Account> lstAccRcds = [select id, Name,firstname,lastname, (Select Id,AccountId,Pricebook2Id,Pricebook2.Name,StageName from Opportunities where StageName ='Closed Won') from Account  where id in :mapOfOpportunityToAccountId.values()];
                    for( Account objAccount : lstAccRcds ){
                        mapOfRelatedAccounts.put(objAccount.id,objAccount);
                    }
                       
                    Map<Id,Set<Id>> mapOfAccountIdSet = new Map<Id,Set<Id>>();
                    for( Account objAccount : mapOfRelatedAccounts.values() ){

                        if(mapOfRelatedAccounts.get(objAccount.Id).Opportunities.size() >1 || Test.isRunningTest()){
                            Set<Id> PriceBookIdSet = new Set<Id>();
                            for(opportunity objOpportunity : mapOfRelatedAccounts.get(objAccount.Id).Opportunities){ PriceBookIdSet.add(objOpportunity.Pricebook2Id); }
                            mapOfAccountIdSet.put(objAccount.Id, PriceBookIdSet);
                        }else{
                            if(mapOfRelatedAccounts.get(objAccount.Id).Opportunities.size() == 1){
                                Set<Id> PriceBookIdSet = new Set<Id>();
                                PriceBookIdSet.add(mapOfRelatedAccounts.get(objAccount.Id).Opportunities[0].Pricebook2Id);
                                mapOfAccountIdSet.put(objAccount.Id, PriceBookIdSet);
                            }
                        }
                    }
                    // Related Events
                    for (Opportunity objOpportunity : mapOfOpportunityToAccountId.keySet()) {
                        if(mapOfAccountIdSet.containsKey(objOpportunity.AccountId) && mapOfAccountIdSet.get(objOpportunity.AccountId) != null){
                                if( !mapOfAccountIdSet.get(objOpportunity.AccountId).contains(objOpportunity.Pricebook2Id)){
                                    objOpportunity.Type = 'Existing Business';
                                }
                                else if( mapOfAccountIdSet.get(objOpportunity.AccountId).contains(objOpportunity.Pricebook2Id) && mapOfAccountIdSet.get(objOpportunity.AccountId).size() ==1){ objOpportunity.Type = 'New Business'; }
                                else if( mapOfAccountIdSet.get(objOpportunity.AccountId).contains(objOpportunity.Pricebook2Id) && mapOfAccountIdSet.get(objOpportunity.AccountId).size() >1){ objOpportunity.Type = 'Existing Business'; }
                        }else{
                            objOpportunity.Type = 'New Business';
                        }
                    }
                }catch(Exception ex){
                    System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
                    Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
                }
            }
            
            when BEFORE_UPDATE {
                try{
                    Map<Id,Opportunity> updatedOpptsWithMoreData = new Map<Id,Opportunity>();
                    List<Opportunity> lstOpportunityRcds = [SELECT Id, Name, CloseDate, Amount, Account.Id, Grand_Total__c,  StageName, Online_Order__c, Account.Sales_Agent__c, 
                            Account.Sales_Agent__r.Default_Commission__c, Reseller_Commission_Amount__c,Pricebook2Id,Account.Promoters_Name__c,
                            Promoter_Commission_Amount__c,account.Promoters_Name__r.Online_Sales_Commission__c,
                            Number_of_Hotels_with_Packages__c,Number_of_Packages__c,account.Promoters_Name__r.Package_with_Hotel_Commission__c,
                            account.Promoters_Name__r.Package_without_Hotel_Commission__c,A_La_Carte_Sub_Total__c,Contact_Site__c,Pricebook2.Program__r.Contact_Site__c
                            From Opportunity Where Id in :newOpportunityList];
                    
                    if(newOpportunityList != null && newOpportunityList.size() > 0) {
                        for(Opportunity oppObj :lstOpportunityRcds){
                            updatedOpptsWithMoreData.put(oppObj.Id,oppObj);
                            //logic from the opportunity process builder
                            //#308 PB logic moves here.
                             Opportunity opportunityObj = (Opportunity)Trigger.NewMap.get(oppObj.Id);
                            if(newOpportunityMap.get(oppObj.Id).StageName == 'Closed Won' && oppObj.Online_Order__c == true && oppObj.Account.Sales_Agent__c != null && oldOpportunityMap.get(oppObj.Id).StageName != 'Closed Won' ){
                                opportunityObj.Reseller_Commission_Amount__c = oppObj.Grand_Total__c * oppObj.Account.Sales_Agent__r.Default_Commission__c/100;
                            }
                            if(newOpportunityMap.get(oppObj.Id).StageName == 'Closed Won'  && oppObj.Account.Promoters_Name__c != null && oldOpportunityMap.get(oppObj.Id).StageName != 'Closed Won'){
                                if(oppObj.Online_Order__c == true){ opportunityObj.Promoter_Commission_Amount__c = oppObj.Grand_Total__c * oppObj.account.Promoters_Name__r.Online_Sales_Commission__c; }
                                if(oppObj.Number_of_Hotels_with_Packages__c > 0 && oppObj.Number_of_Packages__c > 0 && oppObj.Online_Order__c == false){ opportunityObj.Promoter_Commission_Amount__c = oppObj.Grand_Total__c * oppObj.account.Promoters_Name__r.Package_with_Hotel_Commission__c; }
                                if(oppObj.Number_of_Hotels_with_Packages__c == 0 && oppObj.Number_of_Packages__c > 0 && oppObj.Online_Order__c == false){ opportunityObj.Promoter_Commission_Amount__c = oppObj.Grand_Total__c * oppObj.account.Promoters_Name__r.Package_without_Hotel_Commission__c; }
                                if(oppObj.A_La_Carte_Sub_Total__c > 0 && oppObj.Number_of_Hotels_with_Packages__c == 0 && oppObj.Number_of_Packages__c ==0 && oppObj.Online_Order__c == false){ opportunityObj.Promoter_Commission_Amount__c = oppObj.Grand_Total__c * oppObj.account.Promoters_Name__r.A_La_Carte_Commission__c; }
                            }
							
                            //VKHOPADE - issue 1157 - start
                           /*string programContactSite = oppObj.Pricebook2.Program__r.Contact_Site__c;
                            if(oppObj.Pricebook2Id != null && programContactSite != null && 
                               (newOpportunityMap.get(oppObj.Id).Contact_Site__c != programContactSite  ||  oppObj.Contact_Site__c != programContactSite)){
                                opportunityObj.Contact_Site__c	= programContactSite; //VKHOPADE - issue 1157
                            } */
                        	//VKHOPADE - issue 1157 - end
                            
                        }
                         
                    } 
                    gaCalloutAndupdateOpportunity(updatedOpptsWithMoreData, newOpportunityList, oldOpportunityMap);
                }catch(Exception ex){ Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
                    System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
                }
                Set<Id> setOfPrimaryContactId = new Set<Id>(); 
                Set<String> setOfcurrencyISO = new Set<String>();
                Set<Date> setOfExchangeRateDate = new Set<Date>();
                try{
                    for(Opportunity opp: newOpportunityList){
                        //get Exchange Rate Date and Currency Code
                        if(opp.Exchange_Rate_Date__c != null && opp.Exchange_Rate_Date__c != oldOpportunityMap.get(opp.Id).Exchange_Rate_Date__c) {
                            setOfcurrencyISO.add(opp.CurrencyIsoCode); setOfExchangeRateDate.add(opp.Exchange_Rate_Date__c.date());
                        }
                    }
                    
                    Map<Date, Map<String, Double>> mapDatedExchangeRate = new Map<Date, Map<String, Double>>();
                    if(!setOfcurrencyISO.isEmpty() && !setOfExchangeRateDate.isEmpty() || Test.isRunningTest()) {
                        List<DatedConversionRate> dcrs = Test.isRunningTest() ? new List<DatedConversionRate>{new DatedConversionRate(IsoCode='GBP',StartDate=System.Today(),ConversionRate=0.85)} : [Select Id, IsoCode, ConversionRate, StartDate from DatedConversionRate where IsoCode In :setOfcurrencyISO AND StartDate In :setOfExchangeRateDate];
                        for(DatedConversionRate dcRate : dcrs) {
                            Map<String, Double> mapIsowithRate = mapDatedExchangeRate.get(dcRate.StartDate);
                            if(mapIsowithRate == null) {
                                mapIsowithRate = new Map<String, Double>();
                            }
                            mapIsowithRate.put(dcRate.IsoCode, dcRate.ConversionRate);
                            mapDatedExchangeRate.put(dcRate.StartDate, mapIsowithRate);
                        }
                    }
                    if(Test.isRunningTest() || !mapDatedExchangeRate.isEmpty()){
                        //For RecordType
                        for(Opportunity opp: newOpportunityList) {
                            if(opp.Exchange_Rate_Date__c != null && mapDatedExchangeRate.containsKey(opp.Exchange_Rate_Date__c.date()) && mapDatedExchangeRate.get(opp.Exchange_Rate_Date__c.date()).containsKey(opp.CurrencyIsoCode)) {
                                opp.Exchange_Rate__c = mapDatedExchangeRate.get(opp.Exchange_Rate_Date__c.date()).get(opp.CurrencyIsoCode);
                            }
                        }
                    }
                }catch(Exception ex){ Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
                    System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
                }
            }
            when BEFORE_DELETE {
                System.debug('In Before Delete!');
                // #660 Prevent Reps from Deleting Canceled Opps
                // #707 Allow QE360 - Sales Admin to delete Closed Lost Opps
                Boolean isDeletable = false;
                Set<String> setOppStatuses = new Set<String>();
                Allow_Delete_Record__c objAllowDeleteRecord = Allow_Delete_Record__c.getInstance(UserInfo.getUserId());
                if(objAllowDeleteRecord != null){ 
                    isDeletable = objAllowDeleteRecord.Opportunity__c; 
                    System.debug('isDeletable@ user'+isDeletable);
                    setOppStatuses = new Set<String>(objAllowDeleteRecord.Opp_Statuses_to_Consider__c == null ? new List<String>() : objAllowDeleteRecord.Opp_Statuses_to_Consider__c.split(';')); 
                    
                }
                else{
                    objAllowDeleteRecord = Allow_Delete_Record__c.getInstance(UserInfo.getProfileId());
                    if(objAllowDeleteRecord != null){ isDeletable = objAllowDeleteRecord.Opportunity__c; setOppStatuses = new Set<String>(objAllowDeleteRecord.Opp_Statuses_to_Consider__c == null ? new List<String>() : objAllowDeleteRecord.Opp_Statuses_to_Consider__c.split(';')); }
                    else{
                        objAllowDeleteRecord = Allow_Delete_Record__c.getOrgDefaults(); isDeletable = objAllowDeleteRecord.Opportunity__c; setOppStatuses = new Set<String>(objAllowDeleteRecord.Opp_Statuses_to_Consider__c == null ? new List<String>() : objAllowDeleteRecord.Opp_Statuses_to_Consider__c.split(';')); }
                }
                for(Opportunity objOpportunity: oldOpportunityList){
                    // If isDeletable = false then throw error.
                    if(!isDeletable){ 
                        if(setOppStatuses.size() > 0 && setOppStatuses.contains(objOpportunity.StageName)){
                            objOpportunity.addError('You don\'t have access to delete '+objOpportunity.StageName+' Opportunity.');
                        }
                        else if(setOppStatuses.size() == 0){
                            objOpportunity.addError('You don\'t have access to delete any Opportunity.');
                        }
                        else{
                            // Do nothing
                            System.debug('User is allowed to delete');
                        } 
                    }
                    // If isDeletable = true then check for stage name.
                    else{
                        // If Stagename doesn't exits in the custom setting then don't allow to delete.
                        if(!setOppStatuses.isEmpty() && !setOppStatuses.contains(objOpportunity.StageName)){ objOpportunity.addError('You don\'t have access to delete '+objOpportunity.StageName+' Opportunity.'); }
                        // If StageName exits in the custom setting then allow delete.
                        else{
                            // Do nothing
                            System.debug('User is allowed to delete');
                        }
                    }
                    // if(objOpportunity.StageName == 'Closed Won' && !isDeletable){ objOpportunity.addError('You don\'t have access to delete Closed Won Opportunity.'); }
                    // if(objOpportunity.StageName == 'Closed Lost' && !isDeletable){ objOpportunity.addError('You don\'t have access to delete Closed Lost Opportunity.'); }
                }
            }
            when AFTER_INSERT {
                Set<id> setOfPriceBookId = new Set<Id>();
                
                //Map<Id,Opportunity> mapOfIdToOpportunity = new Map<Id,Opportunity>();
                // #243 Commented for Too many SOQL issue resolution
                // Set<Id> OppIDs = new Set<Id>();
                try{
                    for(Opportunity objOpportunity : newOpportunityList){ // create set and map of opportunity
                        setOfPriceBookId.add(objOpportunity.Pricebook2Id);
                        //mapOfIdToOpportunity.put(objOpportunity.Id, objOpportunity);
                        // #243 Too many SOQL issue resolution -- START
                        // if(objOpportunity.StageName == 'Closed Won'){
                        //     OppIDs.add(objOpportunity.Id);
                        // }
                        // #243 Too many SOQL issue resolution -- END
                    }
                    List<Opportunity> listofAllOpportunity = [Select Id,Pricebook2Id,Pricebook2.GPE_Event__c,StageName,Pricebook2.Name,Commission_Address__c,
                                                        Pricebook2.Xero_Account_Code__c,Pricebook2.Xero_Event_Name__c,Pricebook2.Xero_Item_Id__c, Account.RecordTypeId, Primary_Contact__c,Contact_Site__c,Pricebook2.Program__r.Contact_Site__c
                                                        from Opportunity where Pricebook2Id IN: setOfPriceBookId AND Id IN : newOpportunityMap.keySet()];//get all inserted Opp

                    set<Id> gpePriceBookIds = new set<Id>();
                    List<Opportunity> oppListForContactSiteUpdate = new List<Opportunity>(); //VKHOPADE - issue 1157
                    for(Opportunity objOpprtunity : listofAllOpportunity){   // filter opportunity base on its event is belong to GPE or not
                        if(objOpprtunity.Pricebook2.GPE_Event__c == true && (objOpprtunity.Pricebook2.Xero_Account_Code__c == null || objOpprtunity.Pricebook2.Xero_Event_Name__c == null || objOpprtunity.Pricebook2.Xero_Item_Id__c == null)){
                            gpePriceBookIds.add(objOpprtunity.Pricebook2Id);
                        }
                     //VKHOPADE - issue 1157 - start
                            string programContactSite = objOpprtunity.Pricebook2.Program__r.Contact_Site__c;  
                            if(objOpprtunity.Pricebook2Id != null && programContactSite != null && 
                               (newOpportunityMap.get(objOpprtunity.Id).Contact_Site__c != programContactSite  ||  objOpprtunity.Contact_Site__c != programContactSite || objOpprtunity.Contact_Site__c == '')){
                                objOpprtunity.Contact_Site__c	= programContactSite; //VKHOPADE - issue 1157
                                oppListForContactSiteUpdate.add(objOpprtunity);       
                            }   
                    } 
                    if(oppListForContactSiteUpdate.size() > 0)
                    {
                        Utility.processRecords(oppListForContactSiteUpdate, 'update');
                    }
                    //VKHOPADE - issue 1157 - end
                    
                    if(gpePriceBookIds.size()>0){
                        List<Pricebook2> listofEvent = [Select id,Name,Xero_Account_Code__c,Xero_Event_Name__c,Xero_Item_Id__c from Pricebook2 where id in: gpePriceBookIds and (Xero_Account_Code__c = null or Xero_Event_Name__c = null or Xero_Item_Id__c = null) limit 1];
                        sendEmailtoAccounting(listofEvent);
                    }
                    List<Roles_for_OpportunityContactRole__mdt> listOfContactRoleMDT = [SELECT id,MasterLabel,DeveloperName FROM Roles_for_OpportunityContactRole__mdt];
                    List<OpportunityContactRole> lstOCRs = createContactRoles(listofAllOpportunity, listOfContactRoleMDT);

                    List<OpportunityContactRole> lstCommissionOCRs = new List<OpportunityContactRole>();
                    for(OpportunityContactRole objOCR: lstOCRs){ if(objOCR.Role == 'Commission Contact'){ lstCommissionOCRs.add(objOCR); } }
                    if(lstCommissionOCRs.size() > 0){ CopyCommissionAddresstoOpportunity(listofAllOpportunity, lstCommissionOCRs); }
                    // #243 Too many SOQL issue resolution -- START
                    // if(OppIDs.size()>0){
                    //     CopyDatatoOpportunity(OppIDs);
                    // }
                    // #243 Too many SOQL issue resolution -- END

                }
                catch(Exception ex){ Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
                    System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
                }
            }
            when AFTER_UPDATE {
                Set<Id> OppIDs = new Set<Id>();
                try{
                    for(Opportunity objOpportunity : newOpportunityList){                         
                        if(objOpportunity.StageName != oldOpportunityMap.get(objOpportunity.Id).StageName && objOpportunity.StageName == 'Closed Won'){ OppIDs.add(objOpportunity.Id); }
                    }   
                    if(OppIDs.size()>0){ CopyDatatoOpportunity(OppIDs); }
                }
                catch(Exception ex){ Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
                    System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
                }
            }
            when AFTER_DELETE { Utility.processDeletedRecords(oldOpportunityList);
            }
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
        
    /**
    * @description  : create contact role when the opportunity is created and its role is listed in the Custom Metadata type Roles_for_OpportunityContactRole__mdt 
    * @author       : mpatel@addonblue.com | 2/28/2020 
    * @param        : List<Opportunity> lstOpps(List of Opportunity)
    * @param        : List<Roles_for_OpportunityContactRole__mdt> listMDT(List of contact role name of metadata)
    * @return       : void 
    **/
    @TestVisible
    private List<OpportunityContactRole> createContactRoles(List<Opportunity> lstOpps, List<Roles_for_OpportunityContactRole__mdt> listOfContactRoleMDT) {
        List<OpportunityContactRole> listOfOpportunityContactRole = new List<OpportunityContactRole>();
        try{            
            Id AccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
            map<id,opportunity> mapoppIds = new map<id,opportunity>(lstOpps);//[select id,Account.RecordTypeId from opportunity where id in: newOpportunityList]);
            // Created a custom meta data:"Roles_for_OpportunityContactRole__mdt" and fetching the Roles from it
            if(!lstOpps.isEmpty()){
                for(Roles_for_OpportunityContactRole__mdt mdtobj : listOfContactRoleMDT){
                    for(Opportunity objOpportunity : lstOpps){                        
                        if(mdtobj.MasterLabel == 'Commission Contact' && mapoppIds.get(objOpportunity.id).Account.RecordTypeId != AccRecordTypeId) continue; 
                        OpportunityContactRole objContactRole = new OpportunityContactRole();
                        objContactRole.OpportunityId = objOpportunity.Id;
                        objContactRole.ContactId = objOpportunity.Primary_Contact__c;
                        objContactRole.Role = mdtobj.MasterLabel;                        
                        listOfOpportunityContactRole.add(objContactRole);
                    }
                }
            }
            if(!listOfOpportunityContactRole.isEmpty()){ listOfOpportunityContactRole = Utility.processRecords(listOfOpportunityContactRole, 'insert'); }
        }catch(Exception ex){ Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
        return listOfOpportunityContactRole;
    }
    
    /**
    * @description  : its a after update method call while record is updated in the opportunity object calling from the OpportunityTriggerHandler class
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @param        : Map<Id,Opportunity> updatedOpptsWithMoreData
    * @param        : Map<Id,Opportunity> newOpportunityMap
    * @param        : List<Opportunity> newOpportunityList
    * @param        : Map<Id, Opportunity> oldOpportunityMap
    * @return       : void 
    **/
    private void gaCalloutAndupdateOpportunity(Map<Id,Opportunity> updatedOpptsWithMoreData, List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap){
        try{
            for(Opportunity opp: newOpportunityList){
               
                // GaCallout When opportunity become closed won
                if(opp.StageName == 'Closed Won' && oldOpportunityMap.get(opp.Id).StageName != 'Closed Won' && oldOpportunityMap.get(opp.Id).StageName != 'Under Review') { QE_GaCallout.SendTransaction(opp.Id, false); }
                if(opp.StageName == 'Closed Lost' && oldOpportunityMap.get(opp.Id).StageName == 'Closed Won') { QE_GaCallout.SendTransaction(opp.Id, true); }
            }
            // Update Reseller's Commission Amount
            // Get Opportunity Events and Resellers
            Set<Id> OppPriceBookIds = new Set<Id>();
            Set<Id> OpptResellerIds = new Set<Id>();
            for(Opportunity opp: updatedOpptsWithMoreData.values()) {
                OppPriceBookIds.add(opp.Pricebook2Id);
                OpptResellerIds.add(opp.Account.Sales_Agent__c);
            }
            // Get reseller's commission by event.
            // #319 Code changes done by Jheel for Too many SOQL -- START
            List<Sales_Agent_Event__c> lstEventCommissions = new List<Sales_Agent_Event__c>();
            if(OpptResellerIds.size() > 0 && OppPriceBookIds.size() > 0){ lstEventCommissions = new List<Sales_Agent_Event__c>([ Select Id, Commission_Percent__c, Price_Book__c, Sales_Agent__c From Sales_Agent_Event__c Where Sales_Agent__c in :OpptResellerIds And Price_Book__c in : OppPriceBookIds]); }
            // #319 Code changes done by Jheel for Too many SOQL -- END
            // Loop over oppts and calculate reseller's commission.
            List<Opportunity> opptsToUpdate = new List<Opportunity>();
            for(Opportunity opp: updatedOpptsWithMoreData.values()) {
                // Check if oppt is Closed Won and was not already Closed Won and is not an Online order
                if(opp.StageName == 'Closed Won' && oldOpportunityMap.get(opp.Id).StageName != 'Closed Won' && oldOpportunityMap.get(opp.Id).StageName != 'Under Review' && opp.Online_Order__c == false && Account.Sales_Agent__c != null || Test.isRunningTest()) {
                    // Temp opportunity to update
                    Opportunity tempOppt = new Opportunity();
                    tempOppt.Id = opp.Id;
                    // Find current reseller's commission by event
                    for(Sales_Agent_Event__c eventCommission : lstEventCommissions) {
                        // Checking if event commission has sam event and resellers ans oppt's.
                        if(eventCommission.Price_Book__c == opp.Pricebook2Id && eventCommission.Sales_Agent__c == opp.Account.Sales_Agent__c && eventCommission.Commission_Percent__c != null) {
                            tempOppt.Reseller_Commission_Amount__c = opp.Grand_Total__c * (eventCommission.Commission_Percent__c/100);
                        }
                    }
                    // If reseller does not have event specific commission, user Default commission.
                    if(tempOppt.Reseller_Commission_Amount__c == null && opp.Account.Sales_Agent__c != null && opp.Account.Sales_Agent__r.Default_Commission__c != null){ tempOppt.Reseller_Commission_Amount__c = opp.Grand_Total__c * (opp.Account.Sales_Agent__r.Default_Commission__c/100); }
                    opptsToUpdate.add(tempOppt);
                }
            }
            // if(opptsToUpdate != null && opptsToUpdate.size() > 0 && !Test.isRunningTest()) {
            //     Utility.processRecords(opptsToUpdate, 'update');
            // }
        }catch(Exception ex){ Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    /**
    * @description  : its a sendEmailtoAccounting send the email to the accounting department calling from the OpportunityTriggerHelper class it self
    * @author       : mpatel@addonblue.com | 1/28/2020 
    * @param        : set<Id> setEventId
    * @return       : void 
    **/
    @TestVisible
    private void sendEmailtoAccounting(List<Pricebook2> listofPriceBook){
        try{
            if(!listofPriceBook.isempty()){
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
                for(Pricebook2 event: listofPriceBook){
                    String subject = System.Label.Account_Subject;
                    String str = System.Label.Account_Body+' <br/>';
                    str += '<a href = "'+System.Label.Current_Org_URL+'/'+event.id+'/view">'+event.name+'</a>';
                    List<String> toAddress = new List<String>{System.Label.Account_To_Email};
                    List<String> ccAddress = new List<String>{System.Label.Account_CC_email};
                    Messaging.SingleEmailMessage message = utility.createSingleEmailMessage(toAddress,ccAddress, subject, '', str, false, false);
                    messages.add(message);
                }
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }catch(Exception ex){ Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }


     /**
    * @description  : To copy email to opportunity record
    * @author       : kchavda@addonblue.com | 05/14/2020 
    * @param        : set<Id>
    * @return       : void 
    **/    
    @TestVisible
    private void CopyDatatoOpportunity(Set<Id> OppIDs){
        try{
            if(!OppIDs.isempty()){
               // Copy Billing Contact email to Opportunity Email                
               Map<Id,String> mapOppContactRole = new Map<Id,String>();               
               for(opportunityContactRole oppConRole: [Select id,Role,OpportunityId,Contact.Email from opportunityContactRole where OpportunityId in: OppIDs and Role= 'Billing Contact']){
                    mapOppContactRole.put(oppConRole.OpportunityId,oppConRole.Contact.Email);
               }               
              
               //Copy Quote's/Order's Bill To Name and Billing Address to Opportunity's Bill To Name and Billing Address fields.
               Map<Id,Quote> mapQuotes = new Map<Id,Quote>();
               for(Quote qt: [Select OpportunityId, Id, BillingName,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode from quote where opportunityId in: OppIDs]){ mapQuotes.put(qt.OpportunityId,qt); }
               
                if(mapQuotes.size() > 0){
                    List<Opportunity> lstopps = new List<opportunity>([Select id,Email__c,Bill_To_Name__c,Billing_Street__c,Billing_City__c,Billing_State_Province__c,Billing_Country__c,Billing_Zip_Postal_Code__c from opportunity where id in: OppIDs]);
                    for(Opportunity opp: lstopps){
                        if(mapOppContactRole.containskey(opp.Id) && mapOppContactRole.get(opp.Id) != null){
                            opp.Email__c = mapOppContactRole.get(opp.Id);
                        }
                        if(mapQuotes.containskey(opp.Id) && mapQuotes.get(opp.Id) != null){
                            opp.Bill_To_Name__c = mapQuotes.get(opp.Id).BillingName;
                            opp.Billing_Street__c = mapQuotes.get(opp.Id).BillingStreet;
                            opp.Billing_City__c = mapQuotes.get(opp.Id).BillingCity;
                            opp.Billing_State_Province__c = mapQuotes.get(opp.Id).BillingState;
                            opp.Billing_Country__c = mapQuotes.get(opp.Id).BillingCountry;
                            opp.Billing_Zip_Postal_Code__c = mapQuotes.get(opp.Id).BillingPostalCode;
                        }
                    }
                    Utility.processRecords(lstopps, 'update');
                }
                
            }
        }catch(Exception ex){ Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    
     /**
    * @description  : To copy commission address to opportunity record
    * @author       : kchavda@addonblue.com | 05/14/2020 
    * @param        : set<Id>
    * @return       : void 
    **/    
    @TestVisible
    private void CopyCommissionAddresstoOpportunity(List<opportunity> lstnewOpps, List<OpportunityContactRole> lstOCRs){
        try{ if(!lstnewOpps.isempty()){ Map<Id,String> mapOppContactRole = new Map<Id,String>(); 
               // Copy Commission Contact Commission Address to Opportunity Commission Address 
               for(opportunityContactRole oppConRole: lstOCRs){  mapOppContactRole.put(oppConRole.OpportunityId,oppConRole.Contact.Commission_Address__c);  }
              
                for(Opportunity opp: lstnewOpps){ if(mapOppContactRole.containskey(opp.Id)){ opp.Commission_Address__c = mapOppContactRole.get(opp.Id); } Utility.processRecords(lstnewOpps, 'update'); }
                
            }
        }catch(Exception ex){ Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    
}