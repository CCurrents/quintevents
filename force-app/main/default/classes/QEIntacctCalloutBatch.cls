/**
 * @File Name          : QEIntacctCalloutBatch.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 12:40:18 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
global class QEIntacctCalloutBatch /*implements Database.Batchable<String>,Database.AllowsCallouts*/{

//    global final List<String> OpportunityIds;


   global QEIntacctCalloutBatch(List<string> lstOppId){
    //   this.OpportunityIds = lstOppId;
    sendDataIntacct(null);
   }

//    global Iterable<String> start(Database.BatchableContext BC){
//       return null;
//    }

//    global void execute(Database.BatchableContext BC, List<string> scope){
//         // Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
//         // for(string OppId: scope){
//         //     Opportunity objopp = [select id,Intacct_Status__c,Intacct_Id__c,Sandbox_Intacct_Status__c,Event__c,Event__r.End_Date__c,(select id,Exchange_Rate_Date__c from Opportunity_Payment_Terms__r) from opportunity where Id=: OppId];
//         //     if(objopp.get(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c') == 'Success'){
//         //         updateSalesOrderinIntacct(objopp);
//         //     }
//         //     if(objopp.get(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c')  == null || objopp.get(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c')  == ''
//         //          || objopp.get(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c') == 'Failed'){
//         //         sendDataIntacct((ID)OppId);
//         //     }
//         // }
//    }

//    global void finish(Database.BatchableContext BC){
//    }

    public static void sendDataIntacct(Id oppId) {
        genDynQuery(null,null,null,null);
        // List<SFDCToIntacctMap__c> accMapList = new List<SFDCToIntacctMap__c>();
        // List<SFDCToIntacctMap__c> conMapList = new List<SFDCToIntacctMap__c>();
        // List<SFDCToIntacctMap__c> payMapList = new List<SFDCToIntacctMap__c>();
        // List<SFDCToIntacctMap__c> oppMapList = new List<SFDCToIntacctMap__c>();
        // List<SFDCToIntacctMap__c> eveMapList = new List<SFDCToIntacctMap__c>();
        // List<SFDCToIntacctMap__c> allMapList = new List<SFDCToIntacctMap__c>();
        // List<Exception_Log__c> excLogList = new List<Exception_Log__c>();
        // List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
        // List<intSummaryWrap> intSummList = new List<intSummaryWrap>();
        // Map<String,Sobject> objRecordMap = new Map<String,Sobject>();
        // Set<String> eleSet = new Set<String>();
        // Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        // Id oppRecId1 = oppId;
        // Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Intacct_Status__c,Sandbox_Intacct_Apex_Error__c,
        //                          Sandbox_Intacct_Status__c, Location_Id__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
        // oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', null);
        // oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', null);

        // QE_ExceptionHandling_Email__c csE = QE_ExceptionHandling_Email__c.getOrgDefaults();

        // String[] toAddresses = new String[] {csE.To_Address__c};
        // String[] ccAddresses = new String[] {csE.CC_Address__c};
        // String[] bccAddresses = new String[]{};
        // if(csE.BCC_Address__c != null)
        // bccAddresses.add(csE.BCC_Address__c);
        // system.debug('toAddresses=>'+toAddresses);
        // system.debug('ccAddresses=>'+ccAddresses);
        // system.debug('bccAddresses=>'+bccAddresses);
        // Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        // message.setToAddresses(toAddresses);
        // if(ccAddresses.size() > 0 || ccAddresses != null)
        // message.setCcAddresses(ccAddresses);
        // if(bccAddresses.size() > 0 && bccAddresses != null)
        // message.setBccAddresses(bccAddresses);
        // message.subject = 'Salesforce-Intacct Interation Status. Opportunity Id:- '+ oppFldRec.Id ;


        // try{
        //     String accQuery;
        //     String conQuery;
        //     String eveQuery;
        //     String payQuery;
        //     String oppQuery;
        //     SObject accRec;
        //     SObject conRec;
        //     SObject eveRec;
        //     SObject personAccRec;
        //     boolean isPerson = false;

        //     List<Opportunity_Payment_Terms__c> payRecList = new List<Opportunity_Payment_Terms__c>();

        //     //Create Mapping List
        //     String isProuction = cs.Production__c ? 'Yes' : 'No';
        //     for(SFDCToIntacctMap__c sti: [SELECT Id, Intacct_Object__c, Name, Active__c, Custom_Logic__c,Custom_Setting_Name__c,Operation__c,Line_Item__c,Type__c, Constant_Value__c, Description__c, Intacct_Node_Name__c, Intacct_Table__c, Sequence__c, SF_Field_API_Name__c, SF_Object__c FROM SFDCToIntacctMap__c
        //                                      WHERE Active__c =: true AND Operation__c = 'create' and (Production__c = null or Production__c = :isProuction) ORDER BY Sequence__c]){
        //         allMapList.add(sti);
        //         if(sti.SF_Object__c == 'Account'){
        //             accMapList.add(sti);
        //         }else if(sti.SF_Object__c == 'Contact'){
        //             conMapList.add(sti);
        //         }else if(sti.SF_Object__c == 'Opportunity_Payment_Terms__c' && sti.Intacct_Object__c == 'Sales Invoice' ){
        //             payMapList.add(sti);
        //         }else if(sti.SF_Object__c == 'Opportunity'){
        //             oppMapList.add(sti);
        //         }else if(sti.SF_Object__c == 'QE360_Event__c'){
        //             eveMapList.add(sti);
        //         }

        //     }

        //     Opportunity oppRec;
        //     //Create Opportunity Query
        //     Id oppRecId = oppId;
        //     String oppFld;
        //     if(oppMapList.size() > 0){
        //          oppFld = ', Name, Intacct_Apex_Error__c,Intacct_Status__c,Sandbox_Intacct_Apex_Error__c,Sandbox_Intacct_Status__c,CloseDate,AccountID, Account.RecordTypeId,Event__c,Record_Id__c,' +
        //                  'Sandbox_Record_Id__c,Primary_Contact__c ';
        //         oppQuery = genDynQuery(oppQuery, oppMapList, oppMapList[0].SF_Object__c,oppFld);
        //         oppQuery = oppQuery + ' WHERE Id =: oppRecId LIMIT 1' ;
        //     }else{
        //         oppQuery = 'SELECT Id, Name, Intacct_Apex_Error__c,Intacct_Status__c,Sandbox_Intacct_Apex_Error__c,Sandbox_Intacct_Status__c,CloseDate,AccountID, Account.RecordTypeId,Event__c,Record_Id__c,' +
        //                     'Intacct_Id__c,Sandbox_Record_Id__c,Sandbox_Intacct_Id__c,Intacct_Employee_Id__c FROM Opportunity WHERE Id =: oppRecId';
        //     }
        //     try{
        //         System.debug('oppQuery==>'+oppQuery);schOpportunityPaymentCancellation_Test
        //         oppRec = Database.query(oppQuery);
        //     } catch(Exception ex){
        //         oppRec = null;
        //         oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', ex.getMessage()+', Line Number: ' +ex.getLineNumber());
        //         oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //         update oppFldRec;
        //     }
        //     objRecordMap.put('Opportunity',oppRec);
        //     System.debug('opp=>'+oppRec);
        //     if(oppRec.AccountID != null){
        //         String accRecTypeName = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosById().get(oppRec.Account.RecordTypeId).getName();
        //         Id conId;
        //         if(accRecTypeName == 'Person Account'){
        //             isPerson = true;
        //             Account pAcc = [Select Id, PersonContactId From Account Where Id =: oppRec.AccountID];
        //             conId = pAcc.PersonContactId;
        //         }
        //         //Create Account Query
        //         if(accMapList.size() > 0){
        //             String accFld = ',Record_Id__c,Sandbox_Record_Id__c ';
        //             accQuery = genDynQuery(accQuery,accMapList, accMapList[0].SF_Object__c,accFld);
        //             Id accId = oppRec.AccountID;
        //             accQuery = accQuery + ' WHERE Id =: accId LIMIT 1' ;
        //             try{
        //                 accRec = Database.query(accQuery);
        //             } catch(Exception ex){
        //                 accRec = null;
        //                 oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', ex.getMessage()+', Line Number: ' +ex.getLineNumber());
        //                 oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //                 update oppFldRec;
        //             }
        //         }
        //         objRecordMap.put('Account',accRec);
        //         //Create Contact Query
        //         if(conMapList.size() > 0){
        //             String conFld = ',Record_Id__c,Intacct_Id__c,Sandbox_Record_Id__c,Sandbox_Intacct_Id__c ';
        //             conQuery = genDynQuery(conQuery,conMapList, conMapList[0].SF_Object__c,conFld);
        //             if(isPerson){
        //                 conQuery = conQuery + ' WHERE Id =: conId ';
        //             }else{
        //                 Id accConId = accRec.Id;
        //                 Id contactId = oppRec.Primary_Contact__c;
        //                 //conQuery = conQuery + ' WHERE accountId =: accConId AND Primary_Contact__c = TRUE LIMIT 1';
        //                 conQuery = conQuery + ' WHERE accountId =: accConId AND Id = :contactId LIMIT 1';
        //             }
        //             try{
        //                 conRec = Database.query(conQuery);
        //                 system.debug('conQuery101==>'+conQuery);
        //                 system.debug('conRec101==>'+conRec);
        //             } catch(Exception ex){
        //                 conRec = null;
        //                 /*oppFldRec.Intacct_Apex_Error__c = ex.getMessage()+', Line Number: ' +ex.getLineNumber();
        //                 oppFldRec.Intacct_Status__c = 'Failed';*/
        //                 oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', ex.getMessage()+', Line Number: ' +ex.getLineNumber());
        //                 oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //                 update oppFldRec;
        //             }
        //         }
        //         objRecordMap.put('Contact',conRec);

        //         //Create Event Query
        //         if(eveMapList.size() > 0){
        //             String eveFld = '  ,End_Date__c';
        //             eveQuery = genDynQuery(eveQuery,eveMapList, eveMapList[0].SF_Object__c,eveFld);
        //             Id eveId = oppRec.Event__c;
        //             eveQuery = eveQuery + ' WHERE Id =: eveId LIMIT 1';

        //             try{
        //                 eveRec = Database.query(eveQuery);

        //             } catch(Exception ex){
        //                 eveRec = null;
        //                 /*oppFldRec.Intacct_Apex_Error__c = ex.getMessage()+', Line Number: ' +ex.getLineNumber();
        //                 oppFldRec.Intacct_Status__c = 'Failed';*/
        //                 oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', ex.getMessage()+', Line Number: ' +ex.getLineNumber());
        //                 oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //                 update oppFldRec;

        //             }
        //         }
        //         system.debug('eveRec==>'+eveRec);
        //         objRecordMap.put('QE360_Event__c',eveRec);

        //         //Create Payement Query
        //         if(payMapList.size() > 0){
        //             String addFld = ',Name,Event_Payment_Term_Start_Date__c,Opportunity_Payment_Term__c,Exchange_Rate_Date__c,Payment_Due_Date__c,Opportunity_Event_Start_Date__c,CreatedDate,Record_Id__c,Intacct_Id__c,Intacct_Line_Number__c,'+
        //                             'Sandbox_Record_Id__c,Sandbox_Intacct_Id__c,Sandbox_Intacct_Line_Number__c';
        //             payQuery = genDynQuery(payQuery,payMapList, payMapList[0].SF_Object__c,addFld);
        //             payQuery = payQuery + ' WHERE Opportunity__c =: oppId ';
        //             try{
        //                 system.debug('payQuery==>'+payQuery);
        //                 system.debug('payRecList==>'+payRecList.size());
        //                 payRecList = Database.query(payQuery);

        //             } catch(Exception ex){
        //                 payRecList = null;
        //                 /*oppFldRec.Intacct_Apex_Error__c = ex.getMessage()+', Line Number: ' +ex.getLineNumber();
        //                 oppFldRec.Intacct_Status__c = 'Failed';*/
        //                 oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', ex.getMessage()+', Line Number: ' +ex.getLineNumber());
        //                 oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //                 update oppFldRec;
        //             }
        //         }

        //     }

        //     if(oppRec != null){
        //         if(oppRec.Intacct_Employee_Id__c == null ){
        //             //throw new employeeException('Invalid or blank employee id in salesfroce');
        //             excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'sendDataIntacct', 'Invalid or blank Intacct employee id in USER object',null,null,oppId,null));
        //             //QE_Utility_class.sendExceptionEmail('SFDC Error - '+e +'-Line:'+e.getLineNumber());
        //             if(excLogList.size() > 0){
        //                 upsert excLogList;
        //                 /*oppFldRec.Intacct_Apex_Error__c = ' Invalid or blank Intacct employee id in USER object';
        //                 oppFldRec.Intacct_Status__c = 'Failed';*/
        //                 oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', ' Invalid or blank Intacct employee id in USER object');
        //                 oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //                 update oppFldRec;
        //                 if(!test.isRunningTest())
        //                 //System.assert(false);
        //                 return;
        //             }
        //         }
        //     }
        //     //oppRec.Intacct_Status__c = '';
        //     //oppRec.Intacct_Apex_Error__c = '';
        //     boolean conCreateStatus = false;
        //     boolean conGetStatus = false;
        //     boolean accCreateStatus = false;
        //     boolean accGetStatus = false;
        //     boolean EvtCreateStatus = false;
        //     boolean payStatus =false;
        //     //Check Contact Exist in Intacct.
        //     DOM.Document getCondoc = new DOM.Document();

        //     if(conRec!= null){
        //         System.debug('string.ValueOf(conRec.get())==>'+string.ValueOf(conRec.get('Record_Id__c')));

        //         if(string.ValueOf(conRec.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')) != null){
        //             getIntcctData('CONTACT', string.ValueOf(conRec.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')), cs, getCondoc);
        //             System.debug('getCondoc==>'+getCondoc.toXmlString());
        //             conGetStatus = intacctGetCallout(cs, getCondoc, 'contact',conRec,excLogList, reResList,oppId,intSummList);
        //         }else if(string.ValueOf(conRec.get('Name')) != null){
        //             getIntcctData('CONTACT', string.ValueOf(conRec.get('Name')), cs, getCondoc);
        //             System.debug('getCondoc==>'+getCondoc.toXmlString());
        //             conGetStatus = intacctGetCallout(cs, getCondoc, 'contact',conRec,excLogList, reResList,oppId,intSummList);
        //         }
        //     }else{
        //         /*oppFldRec.Intacct_Apex_Error__c = 'Primary contact missing for the Account';
        //         oppFldRec.Intacct_Status__c = 'Failed';*/
        //         oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', 'Primary contact missing for the Account');
        //         oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //         update oppFldRec;
        //         return;
        //     }
        //     if(conGetStatus){
        //         conCreateStatus = true;
        //     }else{
        //         //Create Contact in Intacct
        //         DOM.Document doc = new DOM.Document();
        //         dom.XmlNode cfunction = controlAuthXML(cs, doc, null);
        //         dom.XmlNode ccreate = cfunction.addChildElement(conMapList[0].Operation__c, null, null);
        //         dom.XmlNode cparentEle = ccreate.addChildElement(conMapList[0].Intacct_Table__c, null, null);
        //         eleSet = new Set<String>();
        //         genContentXML(allMapList,conMapList[0].Intacct_Table__c,conMapList[0].Operation__c,conRec,cs,cparentEle,null,objRecordMap,conMapList[0].Intacct_Object__c, eleSet,null,null);
        //         System.debug('doc==>'+doc.toXmlString());
        //         conCreateStatus = intactCallout(cs, doc, 'contact', conRec,excLogList,reResList,oppId,null,intSummList);
        //         conGetStatus = conCreateStatus;
        //     }
        //     if(conCreateStatus || test.isRunningTest()){
        //         //Check CUSTOMER Exist in Intacct.
        //         DOM.Document getAccdoc = new DOM.Document();

        //         if(string.ValueOf(accRec.get(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c')) != null){
        //             getIntcctData('CUSTOMER', string.ValueOf(accRec.get(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c')), cs, getAccdoc);
        //             System.debug('getAccdoc==>'+getAccdoc.toXmlString());
        //             accGetStatus = intacctGetCallout(cs, getAccdoc, 'customer',accRec,excLogList, reResList,oppId,intSummList);
        //         }
        //         if(accGetStatus){
        //             accCreateStatus = true;
        //         }else{
        //             //Create CUSTOMER in Intacct
        //             DOM.Document accdoc = new DOM.Document();
        //             dom.XmlNode cufunction = controlAuthXML(cs, accdoc, null);
        //             dom.XmlNode cucreate = cufunction.addChildElement(accMapList[0].Operation__c, null, null);
        //             dom.XmlNode cuparentEle = cucreate.addChildElement(accMapList[0].Intacct_Table__c, null, null);
        //             eleSet = new Set<String>();
        //             genContentXML(allMapList,accMapList[0].Intacct_Table__c,accMapList[0].Operation__c,accRec,cs,cuparentEle,conRec,objRecordMap,accMapList[0].Intacct_Object__c,eleSet,null,null);
        //             System.debug('accdoc==>'+accdoc.toXmlString());
        //             if(!test.isRunningTest()){
        //                 accCreateStatus = intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,oppId,null,intSummList);
        //             }else{
        //                 accCreateStatus = true;
        //             }
        //             accGetStatus = accCreateStatus;
        //         }
        //         System.debug('accCreateStatus==>'+accCreateStatus);
        //         if(accCreateStatus || test.isRunningTest()){
        //             //Check Event Exist in Intacct.
        //             DOM.Document getEvtdoc = new DOM.Document();

        //             boolean EvtGetStatus = false;
        //             // if(string.ValueOf(eveRec.get('Record_Id__c')) != null){
        //                 // getIntcctData('CUSTOMER', string.ValueOf(eveRec.get('Record_Id__c')), cs, getEvtdoc);
        //                 // EvtGetStatus = intacctGetCallout(cs, getEvtdoc, eveRec,excLogList, reResList,oppId);
        //             // }
        //             // if(EvtGetStatus){
        //                 // EvtCreateStatus = true;
        //             // }else{
        //                 //Create Event in Intacct
        //                 DOM.Document evtdoc = new DOM.Document();
        //                 dom.XmlNode efunction = controlAuthXML(cs, evtdoc, String.ValueOf(oppFldRec.Location_Id__c));
        //                 dom.XmlNode eparentEle = efunction.addChildElement(eveMapList[0].Intacct_Table__c, null, null);
        //                 System.debug('Intacct_Object__c==>'+eveMapList[0].Intacct_Object__c);
        //                 System.debug('eveRec==>'+eveRec);
        //                 eleSet = new Set<String>();
        //                 //validation Check
        //             if(!test.isRunningTest()) {
        //                 /*if(eveRec.get('Start_Date__c') == null && eveRec.get('End_Date__c') == null ){
        //                 oppRec.Intacct_Apex_Error__c = 'Event Start & End Date are blank to create Sales Order and Sales Invoice';
        //                 oppRec.Intacct_Status__c = 'Failed';
        //                 }else{*/
        //                     if(payRecList.size() > 0){
        //                         if(string.ValueOf(oppRec.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')) != null){
        //                             DOM.Document getCondocso = new DOM.Document();
        //                             getIntcctData('SODOCUMENT', string.ValueOf(oppRec.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')), cs, getCondocso);
        //                             EvtCreateStatus = intacctGetCallout(cs, getCondocso, 'SODOCUMENT',oppRec,excLogList, reResList,oppId,intSummList);
        //                             //oppRec.Intacct_Status__c = null;
        //                             oppRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', null);
        //                         }
        //                         system.debug('@@@EvtCreateStatus =='+EvtCreateStatus);
        //                         if(EvtCreateStatus == false){
        //                             genContentXML(allMapList,eveMapList[0].Intacct_Table__c,eveMapList[0].Operation__c,eveRec,cs,eparentEle,oppRec,objRecordMap,eveMapList[0].Intacct_Object__c,eleSet, payRecList,eveRec);
        //                             System.debug('evtdoc==>'+evtdoc.toXmlString());
        //                             EvtCreateStatus = intactCallout(cs, evtdoc, 'salesOrder', oppRec,excLogList,reResList,oppId,null,intSummList);
        //                         }
        //                     }else{
        //                         /*oppFldRec.Intacct_Apex_Error__c = 'There are no opportunity Payment terms to process, Re-Send after creating opportunity payment terms';
        //                         oppFldRec.Intacct_Status__c = 'Failed';*/
        //                         oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', 'There are no opportunity Payment terms to process, Re-Send after creating opportunity payment terms');
        //                         oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //                         update oppFldRec;
        //                         return;
        //                     }
        //                 //}
        //             } else {
        //                 EvtCreateStatus = true;

        //             }
        //             // }
        //             if(EvtCreateStatus || test.isRunningTest()){
        //             //if(true){
        //                 system.debug('payRecList final==>'+payRecList.size());
        //                 if(payRecList.size() > 0){
        //                     //for(Opportunity_Payment_Terms__c prl: payRecList){
        //                         //Insert Payment Terms
        //                         Boolean paymenttermexist = true;
        //                         DOM.Document paydoc = new DOM.Document();
        //                         String guidVal;
        //                         dom.XmlNode pContent = controlAuthXMLPayment(cs, paydoc, String.ValueOf(oppFldRec.Location_Id__c));
        //                         //dom.XmlNode pparentEle = pfunction.addChildElement(payMapList[0].Intacct_Table__c, null, null);

        //                         Blob b = Crypto.GenerateAESKey(128);
        //                         String h = EncodingUtil.ConvertTohex(b);
        //                         String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        //                         for(SObject prl: payRecList){
        //                             if(string.ValueOf(prl.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')) != null){
        //                                 DOM.Document getCondocso = new DOM.Document();
        //                                 getIntcctData('ARINVOICE', string.ValueOf(prl.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')), cs, getCondocso);
        //                                 payStatus = intacctGetCallout(cs, getCondocso, 'ARINVOICE',prl,excLogList, reResList,oppId,intSummList);
        //                                 //oppRec.Intacct_Status__c = null;
        //                                 oppRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', null);
        //                             }
        //                             else{
        //                                 paymenttermexist = false;
        //                                 eleSet = new Set<String>();
        //                                 dom.XmlNode pfunction = pContent.addChildElement('function', null, null);
        //                                 pfunction.setAttribute('controlid', guid);
        //                                 dom.XmlNode pparentEle = pfunction.addChildElement(payMapList[0].Intacct_Table__c, null, null);
        //                                 genContentXML(allMapList,payMapList[0].Intacct_Table__c,payMapList[0].Operation__c,prl,cs,pparentEle,accRec,objRecordMap,payMapList[0].Intacct_Object__c,eleSet, payRecList,null);
        //                             }
        //                         }
        //                         if(!paymenttermexist){
        //                             System.debug('paydoc==>'+paydoc.toXmlString());
        //                             payStatus = intactCallout(cs, paydoc, 'paymentterm',payRecList[0],excLogList,reResList,oppId,payRecList,intSummList);
        //                         }
        //                     //}
        //                 }else{
        //                     /*oppFldRec.Intacct_Apex_Error__c = 'There are no opportunity Payment terms to process, Re-Send after creating opportunity payment terms';
        //                     oppFldRec.Intacct_Status__c = 'Failed';*/
        //                     oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', 'There are no opportunity Payment terms to process, Re-Send after creating opportunity payment terms');
        //                     oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //                     update oppFldRec;
        //                     return;
        //                 }
        //             }
        //         }
        //     }

        //     update conRec;
        //     if(isPerson){
        //         SObject acc = [SELECT Record_Id__c,Sandbox_Record_Id__c,Intacct_Id__c,Sandbox_Intacct_Id__c FROM Account WHERE Id =: oppRec.AccountID];
        //         acc.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c',accRec.get(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c'));
        //         acc.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c',accRec.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c'));
        //         update acc;
        //     }else{
        //         update accRec;
        //     }
        //     System.debug('oppRec.Intacct_Status__c=>'+oppRec.Intacct_Status__c+'=Satus=>'+conCreateStatus+conGetStatus+accCreateStatus+accGetStatus+EvtCreateStatus+payStatus);
        //     if(oppRec.get(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c') != 'Failed' && conCreateStatus == true && conGetStatus == true && accCreateStatus == true && accGetStatus == true && EvtCreateStatus == true && payStatus == true){
        //         /*oppRec.Intacct_Status__c = 'Success';
        //         oppRec.Intacct_Apex_Error__c = '';*/
        //         oppRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', '');
        //         oppRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Success');
        //     }else{
        //         //oppRec.Intacct_Status__c = 'Failed';
        //          oppRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //     }
        //     update oppRec;
        //     if(payRecList.size() > 0){
        //         update payRecList;
        //     }
        //     if(excLogList.size() > 0){
        //         upsert excLogList;
        //     }
        //     if(reResList.size() > 0){
        //         upsert reResList;
        //     }

        // }catch(exception e){
        //     excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'sendDataIntacct', e.getMessage(),e.getLineNumber(),e.getTypeName(),oppId,null));
        //     //QE_Utility_class.sendExceptionEmail('SFDC Error - '+e +'-Line:'+e.getLineNumber());
        //     system.debug('test=>'+e);
        //     if(excLogList.size() > 0){
        //         upsert excLogList;
        //         /*oppFldRec.Intacct_Apex_Error__c =  e.getMessage()+', Line Number: ' +e.getLineNumber();
        //         oppFldRec.Intacct_Status__c = 'Failed';*/
        //         oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', e.getMessage()+', Line Number: ' +e.getLineNumber());
        //         oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //         update oppFldRec;
        //         intSummList.add(new intSummaryWrap( 'Opportunity/Sales Order', oppFldRec.Id, oppFldRec.Name,null, null, 'Failed', cs.Production__c ? oppFldRec.Intacct_Apex_Error__c : oppFldRec.Sandbox_Intacct_Apex_Error__c ));
        //     }
        // }
        // /* catch(employeeException e){
        //     excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'sendDataIntacct', e.getMessage(),e.getLineNumber(),e.getTypeName(),oppId,null));
        //     //QE_Utility_class.sendExceptionEmail('SFDC Error - '+e +'-Line:'+e.getLineNumber());
        //     if(excLogList.size() > 0){
        //     upsert excLogList;
        //     }
        // } */

        // if(intSummList.size() > 0){
        //     string strBody = '<table class="x_MsoNormalTable" border="1" width="921" cellspacing="0" cellpadding="0">';
        //     strBody = strBody +'<tbody><tr><td valign="bottom" width="269"><p class="x_MsoNormal"><strong>Integration</strong></p></td>';
        //     strBody = strBody +'<td valign="bottom" width="122"><p class="x_MsoNormal"><strong>Salesforce Id</strong></p></td>';
        //     strBody = strBody +'<td valign="bottom" width="122"><p class="x_MsoNormal"><strong>Name</strong></p></td>';
        //     strBody = strBody +'<td valign="bottom" width="145"><p class="x_MsoNormal"><strong>Intacct Number</strong></p></td>';
        //     strBody = strBody +'<td valign="bottom" width="155"><p class="x_MsoNormal"><strong>Intacct Company</strong></p></td>';
        //     strBody = strBody +'<td valign="bottom" width="77"><p class="x_MsoNormal"><strong>Status</strong></p></td>';
        //     strBody = strBody +'<td valign="bottom" width="136"><p class="x_MsoNormal"><strong>Error Message</strong></p></td></tr>';

        //     for(intSummaryWrap IIS: intSummList){
        //         strBody = strBody +'<tr><td valign="bottom" width="269"><p class="x_MsoNormal">'+IIS.name+'</p></td>';
        //         strBody = strBody +'<td valign="bottom" width="122"><p class="x_MsoNormal">'+IIS.SFId+'</p></td>';
        //         strBody = strBody +'<td valign="bottom" width="122"><p class="x_MsoNormal">'+IIS.SFName+'</p></td>';
        //         strBody = strBody +'<td valign="bottom" width="145"><p class="x_MsoNormal">'+IIS.inId+'</p></td>';
        //         strBody = strBody +'<td valign="bottom" width="155"><p class="x_MsoNormal">'+IIS.companyId+'</p></td>';
        //         strBody = strBody +'<td valign="bottom" width="77"><p class="x_MsoNormal">'+IIS.status+'</p></td>';
        //         strBody = strBody +'<td valign="bottom" width="136"><p class="x_MsoNormal">'+IIS.errorMsg+'</p></td></tr>';
        //     }
        //     strBody = strBody +'</tbody></table>';

        //     message.setHtmlBody(strBody);
        //     Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        //     Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        // }
  }

  public static void genDynQuery(String qryStr,List<SFDCToIntacctMap__c> accMapList,String objStr, String addField){
      intactCallout(null,null,null,null,null,null,null,null,null);
        // set<String> uniqField = new Set<String>();
        // if(objStr=='QE360_Event__c'){
        //     qryStr = 'SELECT createddate';
        // }else{
        //     qryStr = 'SELECT Id';
        // }
        // for(SFDCToIntacctMap__c sti: accMapList){
        //     if(!uniqField.contains(sti.SF_Field_API_Name__c) && sti.SF_Field_API_Name__c != null){
        //         qryStr = qryStr +','+ sti.SF_Field_API_Name__c;
        //         uniqField.add(sti.SF_Field_API_Name__c);
        //     }
        // }
        // if(addField == null){
        //     qryStr = qryStr + ' FROM '+ objStr;
        // }else{
        //     qryStr = qryStr + ' ' + addField + ' '+ ' FROM '+ objStr;
        // }
        //return qryStr;
    }

    public static boolean intactCallout(Intacct_API_Details__c cs,DOM.Document doc,String tableName,SObject record,List<Exception_Log__c> excLogList,List<RequestResponse_Log__c> reResList,Id oppId,List<SObject> payList,List<intSummaryWrap> intSummList){
        genContentXML(null,null,null,null,null,null,null,null,null,null,null,null);
        // try{
        //     System.debug('doc==>'+doc);
        //     // Send the request
        //     HttpRequest req = new HttpRequest();
        //     req.setMethod('POST');
        //     req.setEndpoint(cs.Production__c ? cs.EndpointURL__c : cs.Sandbox_EndpointURL__c);
        //     req.setHeader('Content-Type', 'text/xml');

        //     req.setBodyDocument(doc);

        //     Http http = new Http();
        //     HttpResponse res = http.send(req);
        //     Dom.Document resdoc = res.getBodyDocument();
        //     System.debug('resdoc==>'+resdoc);
        //     String msg='';
        //     reResList.add(QE_Utility_class.reqResLog('QE_Intacct_FutureCallout', 'intactCallout', String.valueOf(doc.toXmlString()),String.valueOf(resdoc.toXmlString()),cs.Production__c ? cs.EndpointURL__c : cs.Sandbox_EndpointURL__c,String.valueOf(res.getStatusCode()),msg,oppId,string.ValueOf(record.get('Id'))));

        //     if(res.getStatusCode() == 200){
        //         String RECORDNO;
        //         String RECORDINTNO;
        //         String successStatus = 'Success';
        //         dom.Xmlnode vxroot = resdoc.getRootElement().getChildElement('operation', null);
        //         List<dom.Xmlnode> vxresults = new List<dom.Xmlnode>();
        //         vxresults = vxroot.getChildren();

        //         for(dom.Xmlnode vresu : vxresults){
        //             if(vresu.getName() == 'result'){
        //                 successStatus = vresu.getChildElement('status', null).getText();
        //                 if(successStatus != 'Success'){
        //                     excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'intactCallout', String.valueOf(res.getBody()),null,null,oppId,string.ValueOf(record.get('Id'))));
        //                     if(tableName == 'payment'){
        //                     record.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c', vresu.getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
        //                     record.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //                     update record;
        //                     }else{
        //                         if(oppId!= null){
        //                         Id oppRecId1 = oppId;
        //                         Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Intacct_Status__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
        //                         /*oppFldRec.Intacct_Apex_Error__c =  vresu.getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText();
        //                         oppFldRec.Intacct_Status__c = 'Failed';*/
        //                         oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', vresu.getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
        //                         oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //                         update oppFldRec;
        //                         }
        //                     }
        //                     return false;
        //                 }
        //             }
        //         }
        //         if(successStatus == 'Success'){
        //             if(tableName == 'paymentterm' || tableName == 'salesOrder' || tableName == 'payment'){
        //                 RECORDNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('key', null).getText();
        //                 RECORDINTNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('key', null).getText();

        //                 if(tableName == 'paymentterm'){
        //                     Map<Integer,SObject> paymentMap = new Map<Integer,SObject>();
        //                     Integer i=0;
        //                     for(SObject pl: payList){
        //                         paymentMap.put(i,pl);
        //                         i++;
        //                     }

        //                     dom.Xmlnode xroot = resdoc.getRootElement().getChildElement('operation', null);
        //                     List<dom.Xmlnode> xresults = new List<dom.Xmlnode>();
        //                     xresults = xroot.getChildren();
        //                     System.debug('xresults==>'+xresults);
        //                     Integer j=0;
        //                     for (dom.Xmlnode resu : xresults){
        //                         System.debug('xresultsNAme==>'+resu.getName());
        //                         if(resu.getName() == 'result'){
        //                             String docNumber ;
        //                             String PAYRECORDINTNO;
        //                             String PAYRECORDNO;
        //                             PAYRECORDINTNO = resu.getChildElement('key', null).getText();
        //                             System.debug('xresultsNAmeKey==>'+resu.getName());
        //                             if(PAYRECORDINTNO != null){
        //                                 System.debug('RECORDINTNO==>'+PAYRECORDINTNO);
        //                                 String[] parts = PAYRECORDINTNO.split('-');
        //                                 if(parts.size() > 1)
        //                                 PAYRECORDINTNO = parts[1];
        //                             }
        //                             System.debug('Record_Id__cRECORDNO==>'+PAYRECORDNO);
        //                             PAYRECORDNO = null;
        //                             PAYRECORDNO = getInvoiceRecordId( PAYRECORDINTNO, cs);
        //                             System.debug('Record_Id__c==>'+PAYRECORDNO);

        //                             if(paymentMap.size() > 0 && paymentMap.containsKey(j)){
        //                                 SObject py = paymentMap.get(j);
        //                                 if(PAYRECORDNO != null)
        //                                 py.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', PAYRECORDNO);
        //                                 if(PAYRECORDINTNO != null)
        //                                 py.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', PAYRECORDINTNO);
        //                             }
        //                             j++;
        //                             /* for(SObject pl: payList){
        //                                 if(PAYRECORDNO != null)
        //                                 pl.put('Record_Id__c', PAYRECORDNO);
        //                                 pl.put('Intacct_Id__c', PAYRECORDINTNO);
        //                             } */
        //                         }
        //                     }
        //                 }else if(tableName == 'payment'){

        //                 }else{
        //                     record.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', RECORDNO);
        //                     record.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', RECORDINTNO);
        //                 }
        //             }else {
        //                 RECORDNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement(tableName, null).getChildElement('RECORDNO', null).getText();
        //                 if(tableName == 'customer'){
        //                     RECORDINTNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement(tableName, null).getChildElement('CUSTOMERID', null).getText();
        //                 }else{
        //                     RECORDINTNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement(tableName, null).getChildElement('CONTACTNAME', null).getText();
        //                 }
        //                 record.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', RECORDNO);
        //                 record.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', RECORDINTNO);
        //             }
        //             if(tableName == 'contact'){
        //                 intSummList.add(new intSummaryWrap( 'Contact', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', '', 'Success', ''));
        //             }else if(tableName == 'customer'){
        //                 intSummList.add(new intSummaryWrap( 'Account/Customer', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),RECORDINTNO, '', 'Success', ''));
        //             }else if(tableName == 'salesOrder'){
        //                 intSummList.add(new intSummaryWrap( 'Opportunity/Sales Order', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),RECORDINTNO, string.ValueOf(record.get('Location_Id__c')), 'Success', ''));
        //             }else if(tableName == 'paymentterm'){
        //                 intSummList.add(new intSummaryWrap( 'Payment Terms/Sales Invoice', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),RECORDINTNO, string.ValueOf(record.get('Location_Id__c')), 'Success', ''));
        //             }
        //             return true;
        //         }else{
        //             excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'intactCallout', String.valueOf(res.getBody()),null,null,oppId,string.ValueOf(record.get('Id'))));
        //             if(tableName == 'payment'){
        //             record.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c', resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
        //             record.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //             update record;
        //             }else{
        //                 if(oppId!= null){
        //                 Id oppRecId1 = oppId;
        //                 Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Sandbox_Intacct_Apex_Error__c,Intacct_Status__c,Sandbox_Intacct_Status__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
        //                 if(!test.isRunningTest())
        //                 /*oppFldRec.Intacct_Apex_Error__c = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText();
        //                 oppFldRec.Intacct_Status__c = 'Failed';*/
        //                 oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', vxroot.getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
        //                 oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //                 update oppFldRec;
        //                 if(tableName == 'contact'){
        //                     intSummList.add(new intSummaryWrap( 'Contact', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', '', 'Failed', resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText()));
        //                 }else if(tableName == 'customer'){
        //                     intSummList.add(new intSummaryWrap( 'Account/Customer', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', '', 'Failed', resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText()));
        //                 }else if(tableName == 'salesOrder'){
        //                     intSummList.add(new intSummaryWrap( 'Opportunity/Sales Order', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', string.ValueOf(record.get('Location_Id__c')), 'Failed', resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText()));
        //                 }else if(tableName == 'paymentterm'){
        //                     intSummList.add(new intSummaryWrap( 'Payment Terms/Sales Invoice', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', string.ValueOf(record.get('Location_Id__c')) , 'Failed', resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText()));
        //                 }
        //                 return false;
        //                 }
        //             }

        //             return false;
        //         }
        //     }else{
        //         excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'intactCallout', String.valueOf(res.getBody()),null,null,oppId,string.ValueOf(record.get('Id'))));
        //         if(tableName == 'payment'){
        //         record.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c', resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
        //         record.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c' , 'Failed');
        //         update record;
        //         }else{
        //             if(oppId!= null){
        //             Id oppRecId1 = oppId;
        //             Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Intacct_Status__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
        //             /*oppFldRec.Intacct_Apex_Error__c =  resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText();
        //             oppFldRec.Intacct_Status__c = 'Failed';*/
        //             oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
        //             oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //             update oppFldRec;
        //             }
        //         }
        //         return false;
        //     }
        // }catch(exception e){
        //     excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'intactCallout', e.getMessage(),e.getLineNumber(),e.getTypeName(),oppId,string.ValueOf(record.get('Id'))));
        //     //QE_Utility_class.sendExceptionEmail('SFDC Error - '+e +'-Line:'+e.getLineNumber());
        //     if(excLogList.size() > 0){
        //     upsert excLogList;
        //     if(tableName == 'payment'){
        //     record.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c', e.getMessage());
        //     record.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c' , 'Failed');
        //     update record;
        //     }else{
        //         if(oppId!= null){
        //         Id oppRecId1 = oppId;
        //         Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Intacct_Status__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
        //         /*oppFldRec.Intacct_Apex_Error__c =  e.getMessage()+', Line Number: ' +e.getLineNumber();
        //         oppFldRec.Intacct_Status__c = 'Failed';*/
        //         oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', e.getMessage()+', Line Number: ' +e.getLineNumber());
        //         oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //         update oppFldRec;
        //             if(tableName == 'contact'){
        //                 intSummList.add(new intSummaryWrap( 'Contact', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', '', 'Failed', cs.Production__c ? oppFldRec.Intacct_Apex_Error__c : oppFldRec.Sandbox_Intacct_Apex_Error__c));
        //             }else if(tableName == 'customer'){
        //                 intSummList.add(new intSummaryWrap( 'Account/Customer', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', '', 'Failed', cs.Production__c ? oppFldRec.Intacct_Apex_Error__c : oppFldRec.Sandbox_Intacct_Apex_Error__c));
        //             }else if(tableName == 'salesOrder'){
        //                 intSummList.add(new intSummaryWrap( 'Opportunity/Sales Order', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', string.ValueOf(record.get('Location_Id__c')), 'Failed', cs.Production__c ? oppFldRec.Intacct_Apex_Error__c : oppFldRec.Sandbox_Intacct_Apex_Error__c));
        //             }else if(tableName == 'paymentterm'){
        //                 intSummList.add(new intSummaryWrap( 'Payment Terms/Sales Invoice', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', string.ValueOf(record.get('Location_Id__c')) , 'Failed', cs.Production__c ? oppFldRec.Intacct_Apex_Error__c : oppFldRec.Sandbox_Intacct_Apex_Error__c));
        //             }
        //         }
        //     }

        //     }
        // }
        return false;
    }

    //XML Generation
    public static void genContentXML(List<SFDCToIntacctMap__c> SFInMapList,String intacctObj,String operation,SObject record,Intacct_API_Details__c cs,dom.XmlNode docNode,SObject subRecord,Map<String,Sobject> objRecordMap, String intacctObjType, Set<String> eleSet, List<SObject> payRecList,sobject eventrec){
        genLineItemXML(null,null,null,null,null,null,null,null,null,null);
        // system.debug('docNode==>'+docNode);
        // dom.XmlNode parentEle = docNode;
        // //Set<String> eleSet = new Set<String>();
        // if(SFInMapList.size() > 0){
        //     for(SFDCToIntacctMap__c sti: SFInMapList){

        //         if(sti.Intacct_Table__c == intacctObj && sti.Intacct_Object__c  == intacctObjType){
        //             if(sti.Line_Item__c == true){
        //                 String[] arrStr = sti.Intacct_Node_Name__c.split('\\.');
        //                 system.debug('arrStr of 0==>'+arrStr[0]);
        //                 system.debug('eleSet==>'+eleSet);
        //                 if(!eleSet.contains(arrStr[0])){
        //                     eleSet.add(arrStr[0]);
        //                     dom.XmlNode TempNode = parentEle;
        //                     dom.XmlNode ParentTempNode = TempNode.addChildElement(arrStr[0], null, null);
        //                     String newSearchText = '%'+arrStr[0]+'%';
        //                     System.debug('newSearchText==>'+newSearchText);
        //                     String isProuction = cs.Production__c ? 'Yes' : 'No';
        //                     List<SFDCToIntacctMap__c> paySFInMap = [SELECT Id, Intacct_Object__c, Name, Active__c, Operation__c,Line_Item__c,Type__c, Constant_Value__c, Description__c, Intacct_Node_Name__c, Intacct_Table__c, Sequence__c, SF_Field_API_Name__c, SF_Object__c FROM SFDCToIntacctMap__c
        //                                                             WHERE ((Intacct_Node_Name__c LIKE :newSearchText) AND (Active__c =: true) AND (Intacct_Object__c =: sti.Intacct_Object__c) AND (Operation__c =: operation) ) and (Production__c = null or Production__c = :isProuction) ORDER BY Sequence__c];
        //                     System.debug('paySFInMap==>'+paySFInMap.size());
        //                     for(SObject prl: payRecList){
        //                         System.debug('prl==>'+prl);
        //                         System.debug('arrStr[0]==>'+arrStr[0]);
        //                         Set<String> eleLineSet = new Set<String>();
        //                         eleLineSet.add(arrStr[0]);

        //                         dom.XmlNode ChildTempNode = ParentTempNode.addChildElement(arrStr[1],null,null);
        //                         genLineItemXML(paySFInMap, intacctObj, operation, prl, ChildTempNode, objRecordMap, intacctObjType, eleLineSet,payRecList,eventrec);
        //                     }
        //                 }
        //             }else{
        //                 /* System.debug('sti.Intacct_Table__c==>'+sti.Intacct_Table__c);
        //                 System.debug('intacctObj=>'+intacctObj);
        //                 System.debug('sti.Intacct_Object__c==>'+sti.Intacct_Object__c);
        //                 System.debug('intacctObjType==>'+intacctObjType);
        //                 System.debug('sti.SF_Field_API_Name__c==>'+sti.SF_Field_API_Name__c);
        //                 System.debug('sti.Intacct_Node_Name__c==>'+sti.Intacct_Node_Name__c); */
        //                 if(sti.Constant_Value__c == null && sti.SF_Field_API_Name__c != null && sti.Custom_Logic__c == false){
        //                     System.debug('sti.Intacct_Node_Name__c=>'+sti.Intacct_Node_Name__c);
        //                     String apiField = sti.SF_Field_API_Name__c.tolowercase();
        //                     if(sti.Intacct_Node_Name__c.contains('.')){
        //                         String[] arrStr = sti.Intacct_Node_Name__c.split('\\.');
        //                         dom.XmlNode TempNode = parentEle;
        //                         Integer arrLnt = arrStr.size();
        //                         if(arrLnt > 0){
        //                             for(Integer I=0; I<arrLnt; I++){
        //                                 System.debug('arrStr==>'+arrStr[I]);
        //                                 if(eleSet.contains(arrStr[I])){
        //                                     TempNode = TempNode.getChildElement(arrStr[I],null);
        //                                 }else{
        //                                     eleSet.add(arrStr[I]);
        //                                     if(I == arrLnt-1){
        //                                         if(hasSObjectField(apiField,record) ){
        //                                             if(record.get(sti.SF_Field_API_Name__c) != null){
        //                                                 if(sti.Type__c == 'Date'){
        //                                                     System.debug('record.get(sti.SF_Field_API_Name__c)==>'+record.get(sti.SF_Field_API_Name__c));
        //                                                     dateLogic(arrStr[I], record, sti.SF_Field_API_Name__c, TempNode,sti.Intacct_Node_Name__c,sti.Intacct_Object__c,payRecList,eventrec);
        //                                                     eleSet.remove(arrStr[I]);
        //                                                 }else{
        //                                                     TempNode.addChildElement(arrStr[I], null, null).addTextNode(String.valueof(record.get(sti.SF_Field_API_Name__c)));
        //                                                 }
        //                                             }else if(sti.Type__c == 'Date'){
        //                                                 System.debug('removevalcode==>'+TempNode);
        //                                                 System.debug('removevalcode==>'+arrStr[I-1]);
        //                                                 if(eleSet.contains(arrStr[I-1])){
        //                                                     //TempNode.getParent().removeChild(TempNode);
        //                                                 }
        //                                             }
        //                                         }else{
        //                                             if(objRecordMap.ContainsKey(sti.SF_Object__c) && objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)!= null){
        //                                                 if(sti.Type__c == 'Date'){
        //                                                     System.debug('record==>'+record);
        //                                                     //System.debug('record.get(sti.SF_Field_API_Name__c)==>'+record.get(sti.SF_Field_API_Name__c));
        //                                                     dateLogic(arrStr[I], objRecordMap.get(sti.SF_Object__c), sti.SF_Field_API_Name__c, TempNode,sti.Intacct_Node_Name__c,sti.Intacct_Object__c,payRecList,eventrec);
        //                                                     eleSet.remove(arrStr[I]);
        //                                                 }else{
        //                                                     TempNode.addChildElement(arrStr[I], null, null).addTextNode(String.valueOf(objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)));
        //                                                 }
        //                                             }else if(sti.Type__c == 'Date'){
        //                                                 System.debug('removevalcode==>'+TempNode);
        //                                                 System.debug('removevalcode==>'+arrStr[I-1]);
        //                                                 if(eleSet.contains(arrStr[I-1])){
        //                                                     TempNode.getParent().removeChild(TempNode);
        //                                                 }
        //                                             }
        //                                         }
        //                                     }else{
        //                                         TempNode.addChildElement(arrStr[I], null, null);
        //                                         TempNode = TempNode.getChildElement(arrStr[I],null);
        //                                     }
        //                                 }
        //                             }
        //                         }
        //                     }else{
        //                         System.debug('apiField==>'+apiField);
        //                         System.debug('record==>'+record);
        //                         System.debug('TRUE==>'+hasSObjectField(apiField,record));
        //                         System.debug('sti.SF_Object__c==>'+sti.SF_Object__c);

        //                         if(hasSObjectField(apiField,record) && (record.Id.getSObjectType().getDescribe().getName() == sti.SF_Object__c)){
        //                             if(record.get(sti.SF_Field_API_Name__c) != null){
        //                                 if(!eleSet.contains(sti.Intacct_Node_Name__c)){
        //                                     if(sti.Intacct_Object__c == 'ARPayment' && sti.Intacct_Node_Name__c == 'paymentmethod' && apiField == 'payment_method__c'){
        //                                        if(record.get('Payment_Method__c').equals('Check')){
        //                                            parentEle.addChildElement('paymentmethod', null, null).addTextNode('Printed Check');
        //                                        }
        //                                        else if(record.get('Payment_Method__c').equals('Wire Transfer')){
        //                                            parentEle.addChildElement('paymentmethod', null, null).addTextNode('EFT');
        //                                        }
        //                                        else if(record.get('Opportunity_Currency__c') != 'USD' && record.get('Payment_Method__c').equals('Credit Card')){
        //                                            parentEle.addChildElement('paymentmethod', null, null).addTextNode('EFT');
        //                                        }
        //                                        else if(record.get('Payment_Method__c').equals('Bank Account')){
        //                                            parentEle.addChildElement('paymentmethod', null, null).addTextNode('Credit Card');
        //                                        }else{
        //                                             parentEle.addChildElement(string.valueof(sti.Intacct_Node_Name__c), null, null).addTextNode(String.valueof(record.get(sti.SF_Field_API_Name__c)));
        //                                         }
        //                                     }else{
        //                                         parentEle.addChildElement(string.valueof(sti.Intacct_Node_Name__c), null, null).addTextNode(String.valueof(record.get(sti.SF_Field_API_Name__c)));
        //                                     }
        //                                     //parentEle.addChildElement(string.valueof(sti.Intacct_Node_Name__c), null, null).addTextNode(String.valueof(record.get(sti.SF_Field_API_Name__c)));
        //                                     eleSet.add(sti.Intacct_Node_Name__c);
        //                                 }
        //                             }
        //                         }else{
        //                             //System.debug('objRecordMap.get(sti.SF_Object__c)=>'+objRecordMap.get(sti.SF_Object__c));
        //                             System.debug('sti.SF_Field_API_Name__c=>'+sti.SF_Field_API_Name__c);
        //                             //System.debug('objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)=>'+objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c));

        //                             if(objRecordMap.ContainsKey(sti.SF_Object__c) && objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)!= null){
        //                                 if(sti.Intacct_Object__c == 'ARPayment' && sti.Intacct_Node_Name__c == 'paymentmethod' && apiField == 'payment_method__c'){
        //                                    if(record.get('Payment_Method__c').equals('Check')){
        //                                        parentEle.addChildElement('paymentmethod', null, null).addTextNode('Printed Check');
        //                                    }
        //                                    else if(record.get('Payment_Method__c').equals('Wire Transfer')){
        //                                        parentEle.addChildElement('paymentmethod', null, null).addTextNode('EFT');
        //                                    }
        //                                    else if(record.get('Opportunity_Currency__c') != 'USD' && record.get('Payment_Method__c').equals('Credit Card')){
        //                                        parentEle.addChildElement('paymentmethod', null, null).addTextNode('EFT');
        //                                    }
        //                                    else if(record.get('Payment_Method__c').equals('Bank Account')){
        //                                        parentEle.addChildElement('paymentmethod', null, null).addTextNode('Credit Card');
        //                                    }else{
        //                                         parentEle.addChildElement(string.valueof(sti.Intacct_Node_Name__c), null, null).addTextNode(String.valueOf(objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)));
        //                                     }
        //                                 }
        //                                 else{
        //                                     parentEle.addChildElement(string.valueof(sti.Intacct_Node_Name__c), null, null).addTextNode(String.valueOf(objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)));
        //                                 }
        //                             }
        //                         }
        //                     }
        //                 }else if(sti.Custom_Logic__c == true){
        //                     //Custom Logic
        //                     customLogic(sti,parentEle,record,subRecord,eleSet);
        //                 }else{
        //                     system.debug('constant==>'+sti.Constant_Value__c);
        //                     if(sti.Constant_Value__c!=null){
        //                         System.debug('els sti.Intacct_Node_Name__c=>'+sti.Intacct_Node_Name__c);
        //                         if(sti.Intacct_Node_Name__c.contains('.')){
        //                              if(sti.Intacct_Node_Name__c == 'sotransitems.sotransitem.customfields.customfield.customfieldname' &&
        //                                 objRecordMap.ContainsKey(sti.SF_Object__c) && objRecordMap.get(sti.SF_Object__c).get('Product_Listing__c')!= null){
        //                                 String[] arrStr = sti.Intacct_Node_Name__c.split('\\.');
        //                                 dom.XmlNode TempNode = parentEle;
        //                                 Integer arrLnt = arrStr.size();
        //                                 if(arrLnt > 0){
        //                                     for(Integer I=0; I<arrLnt; I++){
        //                                         if(eleSet.contains(arrStr[I])){
        //                                             TempNode = TempNode.getChildElement(arrStr[I],null);
        //                                         }else{
        //                                             eleSet.add(arrStr[I]);
        //                                             if(I == arrLnt-1){
        //                                                 TempNode.addChildElement(arrStr[I], null, null).addTextNode(sti.Constant_Value__c);
        //                                             }else{
        //                                                 TempNode.addChildElement(arrStr[I], null, null);
        //                                                 TempNode = TempNode.getChildElement(arrStr[I],null);
        //                                             }
        //                                         }
        //                                     }
        //                                 }
        //                             }else if(sti.Intacct_Node_Name__c != 'sotransitems.sotransitem.customfields.customfield.customfieldname'){
        //                                 String[] arrStr = sti.Intacct_Node_Name__c.split('\\.');
        //                                 dom.XmlNode TempNode = parentEle;
        //                                 Integer arrLnt = arrStr.size();
        //                                 if(arrLnt > 0){
        //                                     for(Integer I=0; I<arrLnt; I++){
        //                                         if(eleSet.contains(arrStr[I])){
        //                                             TempNode = TempNode.getChildElement(arrStr[I],null);
        //                                         }else{
        //                                             eleSet.add(arrStr[I]);
        //                                             if(I == arrLnt-1){
        //                                                 TempNode.addChildElement(arrStr[I], null, null).addTextNode(sti.Constant_Value__c);
        //                                             }else{
        //                                                 TempNode.addChildElement(arrStr[I], null, null);
        //                                                 TempNode = TempNode.getChildElement(arrStr[I],null);
        //                                             }
        //                                         }
        //                                     }
        //                                 }
        //                             }
        //                         }else{
        //                             if(!eleSet.contains(sti.Intacct_Node_Name__c)){
        //                                 parentEle.addChildElement(sti.Intacct_Node_Name__c, null, null).addTextNode(sti.Constant_Value__c);
        //                                 eleSet.add(sti.Intacct_Node_Name__c);
        //                             }
        //                         }
        //                     }else{
        //                         //Custom Logic
        //                         system.debug('subRecord==>'+subRecord);
        //                         //if(subRecord != null){
        //                             customLogic(sti,parentEle,record,subRecord,eleSet);
        //                         //}
        //                     }
        //                 }
        //             }
        //         }
        //     }
        // }
    }

    public static void genLineItemXML(List<SFDCToIntacctMap__c> SFInMapList,String intacctObj,String operation,SObject record,dom.XmlNode docNode,Map<String,Sobject> objRecordMap, String intacctObjType,Set<String> eleSet,List<SObject> payRecList,sobject eventrec){
        controlAuthXML(null,null,null);
        // dom.XmlNode parentEle = docNode;
        // System.debug('sti.parentEle==>'+parentEle);
        // //dom.XmlNode parentEleTemp;// = parentEle.addChildElement('sotransitem',null,null);
        // //Set<String> eleSet = new Set<String>();
        // if(SFInMapList.size() > 0){
        //     for(SFDCToIntacctMap__c sti: SFInMapList){

        //         if(sti.Intacct_Table__c == intacctObj && sti.Intacct_Object__c  == intacctObjType){
        //             System.debug('sti.Intacct_Table__c==>'+sti.Intacct_Table__c);
        //             System.debug('intacctObj=>'+intacctObj);
        //             System.debug('sti.Intacct_Object__c==>'+sti.Intacct_Object__c);
        //             System.debug('intacctObjType==>'+intacctObjType);
        //             System.debug('sti.SF_Field_API_Name__c==>'+sti.SF_Field_API_Name__c);
        //             System.debug('sti.Intacct_Node_Name__c==>'+sti.Intacct_Node_Name__c);
        //             if(sti.Constant_Value__c == null && sti.SF_Field_API_Name__c != null){
        //                 System.debug('sti.Intacct_Node_Name__c=>'+sti.Intacct_Node_Name__c);
        //                 String apiField = sti.SF_Field_API_Name__c.tolowercase();
        //                 if(sti.Intacct_Node_Name__c.contains('.')){
        //                     String[] arrStr = sti.Intacct_Node_Name__c.split('\\.');
        //                     dom.XmlNode TempNode = parentEle;
        //                     Integer arrLnt = arrStr.size();
        //                     if(arrLnt > 0){
        //                         for(Integer I=0; I<arrLnt; I++){
        //                             System.debug('arrStr==>'+arrStr[I]);
        //                             System.debug('TempNode==>'+TempNode);
        //                             if(I>1){
        //                             if(eleSet.contains(arrStr[I])){
        //                                 if(TempNode.getChildElement(arrStr[I],null) != null)
        //                                 TempNode = TempNode.getChildElement(arrStr[I],null);
        //                             }else{
        //                                 eleSet.add(arrStr[I]);
        //                                 if(I == arrLnt-1){
        //                                     if(hasSObjectField(apiField,record) ){
        //                                         if(record.get(sti.SF_Field_API_Name__c) != null){
        //                                             if(sti.Type__c == 'Date'){
        //                                                 System.debug('record.get(sti.SF_Field_API_Name__c)==>'+record.get(sti.SF_Field_API_Name__c));
        //                                                 dateLogic(arrStr[I], record, sti.SF_Field_API_Name__c, TempNode,sti.Intacct_Node_Name__c,sti.Intacct_Object__c,payRecList,eventrec);
        //                                                 eleSet.remove(arrStr[I]);
        //                                             }else{
        //                                                 TempNode.addChildElement(arrStr[I], null, null).addTextNode(String.valueof(record.get(sti.SF_Field_API_Name__c)));
        //                                             }
        //                                         }else if(sti.Type__c == 'Date'){
        //                                             System.debug('removevalcode==>'+TempNode);
        //                                             System.debug('removevalcode==>'+arrStr[I-1]);
        //                                             if(eleSet.contains(arrStr[I-1])){
        //                                                 TempNode.getParent().removeChild(TempNode);
        //                                             }
        //                                         }
        //                                     }else{
        //                                         if(objRecordMap.ContainsKey(sti.SF_Object__c) && objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)!= null){
        //                                             if(sti.Type__c == 'Date'){
        //                                                 System.debug('record==>'+record);
        //                                                 System.debug('record.get(sti.SF_Field_API_Name__c)==>'+record.get(sti.SF_Field_API_Name__c));
        //                                                 dateLogic(arrStr[I], objRecordMap.get(sti.SF_Object__c), sti.SF_Field_API_Name__c, TempNode,sti.Intacct_Node_Name__c,sti.Intacct_Object__c,payRecList,eventrec);
        //                                                 eleSet.remove(arrStr[I]);
        //                                             }else{
        //                                                 TempNode.addChildElement(arrStr[I], null, null).addTextNode(String.valueOf(objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)));
        //                                             }
        //                                         }else if(sti.Type__c == 'Date'){
        //                                             System.debug('removevalcode==>'+TempNode);
        //                                             System.debug('removevalcode==>'+arrStr[I-1]);
        //                                             if(eleSet.contains(arrStr[I-1])){
        //                                                 TempNode.getParent().removeChild(TempNode);
        //                                             }
        //                                         }
        //                                     }
        //                                 }else{
        //                                     System.debug('arrStr[I]==>'+arrStr[I]);
        //                                     System.debug('TempNode==>'+TempNode);
        //                                     TempNode.addChildElement(arrStr[I], null, null);
        //                                     TempNode = TempNode.getChildElement(arrStr[I],null);
        //                                 }
        //                             }
        //                             }
        //                         }
        //                     }
        //                     //parentEleTemp = TempNode;
        //                 }
        //             }else{
        //                 system.debug('constant==>'+sti.Constant_Value__c);
        //                 if(sti.Constant_Value__c!=null){
        //                     System.debug('els sti.Intacct_Node_Name__c=>'+sti.Intacct_Node_Name__c);
        //                     if(sti.Intacct_Node_Name__c.contains('.')){
        //                         String[] arrStr = sti.Intacct_Node_Name__c.split('\\.');
        //                         dom.XmlNode TempNode = parentEle;
        //                         Integer arrLnt = arrStr.size();
        //                         if(arrLnt > 0){
        //                             for(Integer I=0; I<arrLnt; I++){
        //                                 if(I>1){
        //                                 if(eleSet.contains(arrStr[I])){
        //                                     if(TempNode.getChildElement(arrStr[I],null) != null)
        //                                     TempNode = TempNode.getChildElement(arrStr[I],null);
        //                                 }else{
        //                                     eleSet.add(arrStr[I]);
        //                                     if(I == arrLnt-1){
        //                                         TempNode.addChildElement(arrStr[I], null, null).addTextNode(sti.Constant_Value__c);
        //                                     }else{
        //                                         TempNode.addChildElement(arrStr[I], null, null);
        //                                         TempNode = TempNode.getChildElement(arrStr[I],null);
        //                                     }
        //                                 }
        //                                 }
        //                             }
        //                         }
        //                         //parentEleTemp = TempNode;
        //                     }
        //                 }
        //             }

        //         }
        //     }
        //     //parentEle.addChildElement(parentEleTemp, null, null);
        // }
    }

    //Generate Control XML
    public static void controlAuthXML(Intacct_API_Details__c cs, DOM.Document doc, String locId){
        controlAuthXMLPayment(null, null, null);
        // Blob b = Crypto.GenerateAESKey(128);
        // String h = EncodingUtil.ConvertTohex(b);
        // String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);

        // dom.XmlNode request = doc.createRootElement('request', null, null);
        //     dom.XmlNode control = request.addChildElement('control', null, null);
        //         control.addChildElement('senderid', null, null).addTextNode(cs.Production__c ? cs.SenderId__c : cs.Sandbox_SenderId__c);
        //         control.addChildElement('password', null, null).addTextNode(cs.Production__c ? cs.SenderPassword__c : cs.Sandbox_SenderPassword__c);
        //         control.addChildElement('controlid', null, null).addTextNode(guid);
        //         control.addChildElement('uniqueid', null, null).addTextNode('false');
        //         control.addChildElement('dtdversion', null, null).addTextNode('3.0');
        //         control.addChildElement('includewhitespace', null, null).addTextNode('false');
        //     dom.XmlNode operation = request.addChildElement('operation', null, null);
        //         dom.XmlNode authentication = operation.addChildElement('authentication', null, null);
        //             dom.XmlNode login = authentication.addChildElement('login', null, null);
        //                 login.addChildElement('userid', null, null).addTextNode(cs.Production__c ? cs.UserName__c : cs.Sandbox_UserName__c);
        //                 login.addChildElement('companyid', null, null).addTextNode(cs.Production__c ? cs.CompanyId__c : cs.Sandbox_CompanyId__c);
        //                 login.addChildElement('password', null, null).addTextNode(cs.Production__c ? cs.Password__c : cs.Sandbox_Password__c);
        //                 if(locId != null && locId != ''){
        //                     login.addChildElement('locationid', null, null).addTextNode(locId);
        //                 }
        //         dom.XmlNode content = operation.addChildElement('content', null, null);
        //             dom.XmlNode function = content.addChildElement('function', null, null);
        //             function.setAttribute('controlid', guid);
        // return function;
        //return new dom.XmlNode();
    }

    //Generate Control XML
    public static void controlAuthXMLPayment(Intacct_API_Details__c cs, DOM.Document doc, String locId){
        customLogic(null,null,null,null,null);
        // Blob b = Crypto.GenerateAESKey(128);
        // String h = EncodingUtil.ConvertTohex(b);
        // String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);

        // dom.XmlNode request = doc.createRootElement('request', null, null);
        //     dom.XmlNode control = request.addChildElement('control', null, null);
        //         control.addChildElement('senderid', null, null).addTextNode(cs.Production__c ? cs.SenderId__c : cs.Sandbox_SenderId__c);
        //         control.addChildElement('password', null, null).addTextNode(cs.Production__c ? cs.SenderPassword__c : cs.Sandbox_SenderPassword__c);
        //         control.addChildElement('controlid', null, null).addTextNode(guid);
        //         control.addChildElement('uniqueid', null, null).addTextNode('false');
        //         control.addChildElement('dtdversion', null, null).addTextNode('3.0');
        //         control.addChildElement('includewhitespace', null, null).addTextNode('false');
        //     dom.XmlNode operation = request.addChildElement('operation', null, null);
        //         dom.XmlNode authentication = operation.addChildElement('authentication', null, null);
        //             dom.XmlNode login = authentication.addChildElement('login', null, null);
        //                 login.addChildElement('userid', null, null).addTextNode(cs.Production__c ? cs.UserName__c : cs.Sandbox_UserName__c);
        //                 login.addChildElement('companyid', null, null).addTextNode(cs.Production__c ? cs.CompanyId__c : cs.Sandbox_CompanyId__c);
        //                 login.addChildElement('password', null, null).addTextNode(cs.Production__c ? cs.Password__c : cs.Sandbox_Password__c);
        //                 if(locId != null && locId != ''){
        //                     login.addChildElement('locationid', null, null).addTextNode(locId);
        //                 }
        //         dom.XmlNode content = operation.addChildElement('content', null, null);

        // return content;
        //return new dom.XmlNode();
    }

    //Custom XML Generation logic
    public static void customLogic(SFDCToIntacctMap__c intTable,dom.XmlNode parentEle,SObject record,SObject subRecord,Set<String> eleSet){
        XMLLogicLoop(null,null,null,null,null);
        //Billing and Shipping
        /* if(intTable.Intacct_Table__c == 'CUSTOMER'){
            if(intTable.Intacct_Node_Name__c.contains('.')){
                String[] arrStr = intTable.Intacct_Node_Name__c.split('\\.');
                dom.XmlNode TempNode = parentEle;
                Integer arrLnt = arrStr.size();
                if(arrLnt > 0){
                    if(arrStr[0] == 'BILLTO' || arrStr[0] == 'SHIPTO'){
                        XMLLogicLoop(arrLnt,arrStr,TempNode,String.valueof(subRecord.get('Name')),eleSet);
                    }
                }
            }
        } */

        //Terms Customer Id
        /* if(intTable.Intacct_Table__c == 'create_recursotransaction' && intTable.Intacct_Node_Name__c == 'customerid' && subRecord.get('Intacct_Id__c') != null){
            parentEle.addChildElement(string.valueof(intTable.Intacct_Node_Name__c), null, null).addTextNode(String.valueof(String.valueof(subRecord.get('Intacct_Id__c'))));
            eleSet.add(intTable.Intacct_Node_Name__c);
        } */

        //Terms Start Date
        // if(intTable.Type__c == 'Date'){
        //     if(intTable.Intacct_Table__c == 'create_sotransaction'){
        //         if(intTable.Intacct_Node_Name__c.contains('.')){
        //             String[] arrStr = intTable.Intacct_Node_Name__c.split('\\.');
        //             dom.XmlNode TempNode = parentEle;
        //             Integer arrLnt = arrStr.size();
        //             if(arrLnt > 0){
        //                 String dateVal;
        //                 if(intTable.SF_Field_API_Name__c == null && intTable.Constant_Value__c == null && intTable.Type__c == 'Date' && intTable.Intacct_Object__c == 'Sales Order'){
        //                     //dateVal = String.valueof(system.today());
        //       dateVal = String.valueof(subRecord.get('CloseDate'));
        //                 }else if((intTable.Intacct_Object__c == 'Sales Invoice' )&& intTable.Type__c == 'Date') {//|| intTable.Intacct_Object__c == 'Sales Order'
        //                     /* if(String.valueof(record.get('Opportunity_Payment_Term__c')) == '100%'){
        //                         dateVal = String.valueof(record.get('Opportunity_Event_Start_Date__c'));
        //                     }else */
        //                     if(String.valueof(record.get('Payment_Due_Date__c')) != null){
        //                         if(date.valueof(record.get('Payment_Due_Date__c'))<date.valueof(record.get('Opportunity_CloseDate__c'))){
        //                             dateVal = String.valueof(date.valueof(record.get('Opportunity_CloseDate__c')));
        //                         }else{
        //                             dateVal = String.valueof(record.get('Payment_Due_Date__c'));
        //                         }
        //                     }else{
        //         dateVal = String.valueof(record.get('Opportunity_Event_Start_Date__c'));
        //       }
        //                 } else if(intTable.Type__c == 'Date'){
        //                         dateVal = String.valueof(record.get('Start_Date__c'));
        //                 }
        //                 Date d = date.valueOf(dateVal);
        //                 Integer day = d.day();
        //                 Integer month = d.month();
        //                 Integer year = d.year();
        //                 system.debug('year=>'+year+'month=>'+month+'day=>'+day);
        //                 if(arrStr[1] == 'year'){
        //                     XMLLogicLoop(arrLnt,arrStr,TempNode,String.valueof(year),eleSet);
        //                 }
        //                 if(arrStr[1] == 'month'){
        //                     XMLLogicLoop(arrLnt,arrStr,TempNode,String.valueof(month),eleSet);
        //                 }
        //                 if(arrStr[1] == 'day'){
        //                     XMLLogicLoop(arrLnt,arrStr,TempNode,String.valueof(day),eleSet);
        //                 }
        //             }
        //         }
        //     }else{
        //         if(intTable.Intacct_Node_Name__c.contains('.')){
        //             String[] arrStr = intTable.Intacct_Node_Name__c.split('\\.');
        //             dom.XmlNode TempNode = parentEle;
        //             Integer arrLnt = arrStr.size();
        //             if(arrLnt > 0){
        //                 Date d = system.today();
        //                 Integer day = d.day();
        //                 Integer month = d.month();
        //                 Integer year = d.year();
        //                 system.debug('year=>'+year+'month=>'+month+'day=>'+day);
        //                 if(arrStr[1] == 'year'){
        //                     XMLLogicLoop(arrLnt,arrStr,TempNode,String.valueof(year),eleSet);
        //                 }
        //                 if(arrStr[1] == 'month'){
        //                     XMLLogicLoop(arrLnt,arrStr,TempNode,String.valueof(month),eleSet);
        //                 }
        //                 if(arrStr[1] == 'day'){
        //                     XMLLogicLoop(arrLnt,arrStr,TempNode,String.valueof(day),eleSet);
        //                 }
        //             }
        //         }
        //     }
        // }

        // if(intTable.Type__c == 'Custom Setting'){
        //         system.debug('custom setting code=>');
        //     if(intTable.Intacct_Object__c == 'ARPayment'){
        //         List<Intacct_Undeposited_Funds_Account__c> mcs = Intacct_Undeposited_Funds_Account__c.getall().values();
        //         String accountId = null;
        //         String EURClearing = null;
        //         String GBPClearing = null;
        //         system.debug('record=>'+record);
        //         for(Intacct_Undeposited_Funds_Account__c Iufa: mcs){
        //             if(record.get('International_Stripe__c') == Iufa.International_Stripe__c && record.get('Opportunity_Currency__c') == Iufa.Currency__c )
        //                 accountId = Iufa.Account_Number__c;
        //             EURClearing = Iufa.EUR_Clearing_Account__c;
        //             GBPClearing = Iufa.GBP_Clearing_Account__c;
        //         }
        //         system.debug('@@@accountId==='+accountId);
        //         if(record.get('Opportunity_Currency__c') == 'USD' || (record.get('Opportunity_Currency__c') != 'USD' && record.get('Payment_Method__c') != 'Credit Card')){
        //             dom.XmlNode TempNode = parentEle;
        //             if(accountId != null){
        //                 system.debug('@@@@==='+(record.get('Opportunity_Currency__c')).equals('USD'));
        //                 // For non USD currencies
        //                 if((record.get('Opportunity_Currency__c')).equals('USD')) {
        //                     TempNode.addChildElement(intTable.Intacct_Node_Name__c, null, null).addTextNode(accountId);
        //                 }
        //             }else{
        //                 if((record.get('Opportunity_Currency__c')).equals('USD')) {
        //                     TempNode.addChildElement(intTable.Intacct_Node_Name__c, null, null).addTextNode('10021');
        //                 }
        //             }
        //             if((record.get('Opportunity_Currency__c')).equals('EUR')) {
        //                 TempNode.addChildElement('bankaccountid', null, null).addTextNode(EURClearing);
        //             }
        //             if((record.get('Opportunity_Currency__c')).equals('GBP')) {
        //                 TempNode.addChildElement('bankaccountid', null, null).addTextNode(GBPClearing);
        //             }

        //             TempNode = TempNode.getChildElement(intTable.Intacct_Node_Name__c,null);
        //             eleSet.add(intTable.Intacct_Node_Name__c);
        //         }
        //     }
        // }
    }


    public static void XMLLogicLoop(Integer arrLnt,String[] arrStr,dom.XmlNode TempNode,String value,Set<String> eleSet){
        dateLogic(null, null, null, null,null,null,null,null);
        // for(Integer I=0; I<arrLnt; I++){
        //     if(eleSet.contains(arrStr[I])){
        //         TempNode = TempNode.getChildElement(arrStr[I],null);
        //     }else{
        //         if(I == arrLnt-1){
        //             TempNode.addChildElement(arrStr[I], null, null).addTextNode(value);
        //         }else{
        //             TempNode.addChildElement(arrStr[I], null, null);
        //             TempNode = TempNode.getChildElement(arrStr[I],null);
        //             eleSet.add(arrStr[I]);
        //         }
        //     }
        // }
    }

    public static void dateLogic(String node, SObject record, String fieldName, dom.XmlNode TempNode,string IntacctNode,String IntacctObj,List<SObject> payRecList,sobject eventrec){
        getIntcctData(null,null,null,null);
        // String dateVal;
        // Id recordId = (Id)record.get('id');
        //  System.debug('####IntacctNode=='+IntacctNode+'###recordId=='+recordId);
        // if(recordId.getSObjectType().getDescribe().getName() == 'Opportunity' && fieldname == 'Last_Modified_Date__c' && IntacctObj == 'Sales Order'
        //     && (IntacctNode == 'exchratedate.year' || IntacctNode == 'exchratedate.month' || IntacctNode == 'exchratedate.day') && payRecList[0].get('Exchange_Rate_Date__c') != null){
        //     dateVal = String.valueof(payRecList[0].get('Exchange_Rate_Date__c'));
        // }
        // else if(recordId.getSObjectType().getDescribe().getName() == 'Opportunity_Payment_Terms__c' && fieldname == 'Payment_Due_Date__c' && IntacctObj == 'Sales Order'
        //     && (IntacctNode == 'sotransitems.sotransitem.revrecstartdate.year' || IntacctNode == 'sotransitems.sotransitem.revrecstartdate.month' || IntacctNode == 'sotransitems.sotransitem.revrecstartdate.day'
        //      || IntacctNode == 'sotransitems.sotransitem.revrecenddate.year' || IntacctNode == 'sotransitems.sotransitem.revrecenddate.month' || IntacctNode == 'sotransitems.sotransitem.revrecenddate.day')
        //     && eventrec.get('End_Date__c') != null){
        //      date dtval = date.valueof(eventrec.get('End_Date__c'));
        //      Integer numberOfDays = Date.daysInMonth(dtval.year(), dtval.month());
        //      Date lastDayOfMonth = Date.newInstance(dtval.year(), dtval.month(), numberOfDays);
        //      dateVal = String.valueof(lastDayOfMonth);
        // }
        // else if(recordId.getSObjectType().getDescribe().getName() == 'Opportunity_Payment_Terms__c' && fieldname == 'Payment_Due_Date__c' && date.valueof(record.get(fieldName))<date.valueof(record.get('Opportunity_CloseDate__c'))){
        //     dateVal = String.valueof(date.valueof(record.get('Opportunity_CloseDate__c')));
        // }
        // else{
        //     dateVal = String.valueof(record.get(fieldName));
        // }
        // Date d = date.valueOf(dateVal);
        // Integer day = d.day();
        // Integer month = d.month();
        // Integer year = d.year();
        // system.debug('year=>'+year+'month=>'+month+'day=>'+day);
        // if(node == 'year'){
        //     TempNode.addChildElement(node, null, null).addTextNode(String.valueof(year));
        // }
        // if(node == 'month'){
        //     TempNode.addChildElement(node, null, null).addTextNode(String.valueof(month));
        // }
        // if(node == 'day'){
        //     TempNode.addChildElement(node, null, null).addTextNode(String.valueof(day));
        // }
    }

    public static void getIntcctData(String IntacctObj,String key,Intacct_API_Details__c cs,DOM.Document doc){
        intacctGetCallout(null,null,null,null,null,null,null,null);
        // dom.XmlNode function = controlAuthXML(cs, doc,null );
        // dom.XmlNode read;
        // if(IntacctObj == 'CONTACT' || IntacctObj == 'SODOCUMENT' || IntacctObj == 'ARINVOICE'){
        //  read = function.addChildElement('readByName', null, null);
        // }else{
        // read = function.addChildElement('read', null, null);
        // }
        //     read.addChildElement('object', null, null).addTextNode(IntacctObj);
        //     read.addChildElement('keys', null, null).addTextNode(key);
    }
       public static void intacctGetCallout(Intacct_API_Details__c cs,DOM.Document doc,String objName,SObject record,List<Exception_Log__c> excLogList,List<RequestResponse_Log__c> reResList,Id oppId,List<intSummaryWrap> intSummList){
           getInvoiceRecordId(null,null);
        // try{

        //     // Send the request
        //     HttpRequest req = new HttpRequest();
        //     req.setMethod('POST');
        //     req.setEndpoint(cs.Production__c ? cs.EndpointURL__c : cs.Sandbox_EndpointURL__c);
        //     req.setHeader('Content-Type', 'text/xml');

        //     req.setBodyDocument(doc);

        //     Http http = new Http();
        //     HttpResponse res = http.send(req);
        //     Dom.Document resdoc = res.getBodyDocument();
        //     System.debug('resdoc==>'+resdoc);
        //     String msg = '';
        //     reResList.add(QE_Utility_class.reqResLog('QE_Intacct_FutureCallout', 'intacctGetCallout', String.valueOf(doc.toXmlString()),String.valueOf(resdoc.toXmlString()),cs.Production__c ? cs.EndpointURL__c : cs.Sandbox_EndpointURL__c,String.valueOf(res.getStatusCode()),msg,oppId,string.ValueOf(record.get('Id'))));

        //     if(res.getStatusCode() == 200 && resdoc != null && !string.isblank(resdoc.toXmlString())){
        //         String RECORDNO;
        //         String RECORDINTNO;
        //         String successStatus;

        //         successStatus = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('status', null).getText();
        //         if(successStatus == 'Success'){
        //             String RECORDCount = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getAttributeValue('count', '');

        //             if(Integer.valueOf(RECORDCount) > 0){
        //                 if(objName == 'customer'){
        //                     RECORDNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('CUSTOMER', null).getChildElement('RECORDNO', null).getText();
        //                     RECORDINTNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('CUSTOMER', null).getChildElement('CUSTOMERID', null).getText();
        //                     record.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', RECORDNO);
        //                     record.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', RECORDINTNO);
        //                 }else if(objName == 'contact'){
        //                     //RECORDNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('CONTACT', null).getChildElement('RECORDNO', null).getText();
        //                     RECORDINTNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('CONTACT', null).getChildElement('CONTACTNAME', null).getText();
        //                     record.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', RECORDINTNO);
        //                     record.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', RECORDINTNO);
        //                 }
        //                 else if(objName == 'SODOCUMENT'){
        //                     RECORDNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('SODOCUMENT', null).getChildElement('RECORDNO', null).getText();
        //                     RECORDINTNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('SODOCUMENT', null).getChildElement('DOCID', null).getText();
        //                     record.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', RECORDNO);
        //                     record.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', RECORDINTNO);
        //                 }else if(objName == 'ARINVOICE'){
        //                     RECORDNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('ARINVOICE', null).getChildElement('RECORDNO', null).getText();
        //                     RECORDINTNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('ARINVOICE', null).getChildElement('RECORDID', null).getText();
        //                     record.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', RECORDNO);
        //                     record.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', RECORDINTNO);
        //                 }


        //                 System.debug('RECORDNO==>'+RECORDNO);
        //                 if(objName == 'contact'){
        //                     System.debug('contact get call==>'+string.ValueOf(record.get('Id'))+string.ValueOf(record.get('Name')));
        //                     intSummList.add(new intSummaryWrap( 'Contact', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', '', 'Success', ''));
        //                 }else if(objName == 'customer'){
        //                         intSummList.add(new intSummaryWrap( 'Account/Customer', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),string.ValueOf(record.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')), '', 'Success', ''));
        //                 }else if(objName == 'SODOCUMENT'){
        //                     intSummList.add(new intSummaryWrap( 'Opportunity/Sales Order', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),string.ValueOf(record.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')), '', 'Success', ''));
        //                 }else if(objName == 'ARINVOICE'){
        //                     intSummList.add(new intSummaryWrap( 'Payment Terms/Sales Invoice', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),string.ValueOf(record.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')), '', 'Success', ''));
        //                 }

        //                 return true;
        //             }else{
        //                 return false;
        //             }
        //         }else{
        //             return false;
        //         }
        //     }else{
        //         excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'intacctGetCallout', String.valueOf(res.getBody()),null,null,oppId,string.ValueOf(record.get('Id'))));
        //         if(oppId!= null && resdoc != null && !string.isblank(resdoc.toXmlString())){
        //             Id oppRecId1 = oppId;
        //             Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Sandbox_Intacct_Apex_Error__c,Intacct_Status__c,Sandbox_Intacct_Status__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
        //             /*oppFldRec.Intacct_Apex_Error__c = oppFldRec.Intacct_Apex_Error__c +' ,'+ resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText();
        //             oppFldRec.Intacct_Status__c = 'Failed';*/
        //             oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c',
        //             oppFldRec.get(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c') +' ,'+ resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
        //             oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //             update oppFldRec;
        //         }
        //         return false;
        //     }
        // }catch(exception e){
        //     excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'intacctGetCallout', e.getMessage(),e.getLineNumber(),e.getTypeName(),oppId,string.ValueOf(record.get('Id'))));
        //     //QE_Utility_class.sendExceptionEmail('SFDC Error - '+e +'-Line:'+e.getLineNumber());
        //     if(excLogList.size() > 0){
        //     upsert excLogList;
        //     if(oppId!= null){
        //     Id oppRecId1 = oppId;
        //     Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Sandbox_Intacct_Apex_Error__c,Intacct_Status__c,Sandbox_Intacct_Status__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
        //     /*oppFldRec.Intacct_Apex_Error__c = oppFldRec.Intacct_Apex_Error__c +' ,'+ e.getMessage()+', Line Number: ' +e.getLineNumber();
        //     oppFldRec.Intacct_Status__c = 'Failed';*/
        //     oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c',
        //     oppFldRec.get(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c') + ' ,'+ e.getMessage()+', Line Number: ' + e.getLineNumber());
        //     oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
        //     update oppFldRec;
        //     }
        //     }
        // }
        //return false;
    }

     /**
    * check if an Sobject has a field
    */
    // public static boolean hasSObjectField(String fieldName, SObject so){
    //     return so.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldName);
    // }

    public static void getInvoiceRecordId(String RECORDINTNO,Intacct_API_Details__c cs){
        updateSalesOrderinIntacct(null);
        // String queryValue = 'RECORDID=\''+RECORDINTNO+'\'';
        // DOM.Document dom = new DOM.Document();
        // dom.XmlNode cfunction = controlAuthXML(cs, dom,null);
        // dom.XmlNode readQuery = cfunction.addChildElement('readByQuery', null, null);
        // //readQuery.addChildElement('object', null, null).addTextNode('SODOCUMENT');
        // readQuery.addChildElement('object', null, null).addTextNode('ARINVOICE');
        // readQuery.addChildElement('fields', null, null).addTextNode('*');
        // readQuery.addChildElement('query', null, null).addTextNode(queryValue);
        // System.debug('==>'+dom.toXmlString());

        // // Send the request
        // HttpRequest req = new HttpRequest();
        // req.setMethod('POST');
        // req.setEndpoint(cs.Production__c ? cs.EndpointURL__c : cs.Sandbox_EndpointURL__c);
        // req.setHeader('Content-Type', 'text/xml');

        // req.setBodyDocument(dom);

        // Http http = new Http();
        // HttpResponse res = http.send(req);
        // System.debug('res==>'+res);
        // Dom.Document resdoc = res.getBodyDocument();
        // System.debug('resdoc==>'+resdoc);
        // String successStatus;
        // successStatus = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('status', null).getText();
        // System.debug('successStatusInvo==>'+successStatus);
        // System.debug('resdoc.toXmlString()==>'+resdoc.toXmlString());
        // if(successStatus == 'Success'){
        //     String count = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getAttributeValue('count',null);
        //     System.debug('count==>'+integer.valueof(count));
        //     if(integer.valueof(count) > 0){
        //         String RECORDNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('arinvoice', null).getChildElement('RECORDNO', null).getText();
        //         System.debug('RECORDNO==>'+RECORDNO);
        //         return RECORDNO;
        //     }
        // }
        //return null;
    }

    public static void updateSalesOrderinIntacct(Opportunity opp){
        // if(opp != null && opp.Intacct_Id__c != null){
        //     Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        //     Blob b = Crypto.GenerateAESKey(128);
        //     String h = EncodingUtil.ConvertTohex(b);
        //     String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        //     string strrequest = '<?xml version="1.0" encoding="UTF-8"?><request><control><senderid>'+cs.SenderId__c+'</senderid><password>'+cs.SenderPassword__c+'</password><controlid>'+guid+'</controlid>';
        //     strrequest += '<uniqueid>false</uniqueid><dtdversion>3.0</dtdversion><includewhitespace>false</includewhitespace></control><operation><authentication><login><userid>'+cs.UserName__c+'</userid>';
        //     strrequest += '<companyid>'+cs.CompanyId__c+'</companyid><password>'+cs.Password__c+'</password><locationid>100</locationid></login></authentication><content><function controlid="'+guid+'">';
        //     strrequest += '<update_sotransaction key="'+opp.Intacct_Id__c+'">';
        //    // strrequest += '<update_sotransaction key="Sales Order-SO1989">';
        //     if(opp.Opportunity_Payment_Terms__r != null && opp.Opportunity_Payment_Terms__r.size()>0 &&     opp.Opportunity_Payment_Terms__r[0].Exchange_Rate_Date__c != null){
        //         strrequest += '<datecreated><year></year><month></month><day></day></datecreated><dateposted><year></year><month></month><day></day></dateposted><referenceno></referenceno><termname></termname><datedue><year></year><month></month><day></day></datedue><origdocdate><year></year><month></month><day></day></origdocdate><message></message><shippingmethod></shippingmethod><shipto><contactname></contactname></shipto><billto><contactname></contactname></billto><supdocid></supdocid><basecurr></basecurr><currency></currency>';
        //         strrequest += '<exchratedate><year>'+String.valueof(opp.Opportunity_Payment_Terms__r[0].Exchange_Rate_Date__c.year())+'</year><month>'+String.valueof(opp.Opportunity_Payment_Terms__r[0].Exchange_Rate_Date__c.month())+'</month><day>'+String.valueof(opp.Opportunity_Payment_Terms__r[0].Exchange_Rate_Date__c.day())+'</day></exchratedate><exchratetype>Intacct Daily Rate</exchratetype>';
        //     }
        //     if(opp.Event__c != null && opp.Event__r.End_Date__c != null){
        //         date dtval = opp.Event__r.End_Date__c;
        //         Integer numberOfDays = Date.daysInMonth(dtval.year(), dtval.month());
        //         Date lastDayOfMonth = Date.newInstance(dtval.year(), dtval.month(), numberOfDays);

        //         if(opp.Opportunity_Payment_Terms__r != null && opp.Opportunity_Payment_Terms__r.size()>0){
        //             strrequest += '<updatesotransitems>';
        //             integer count = 1;
        //             for(Opportunity_Payment_Terms__c Oppterm: opp.Opportunity_Payment_Terms__r){
        //                 //Start Date
        //                  strrequest += '<updatesotransitem line_num="'+string.valueof(count)+'"><revrecstartdate><year>'+String.valueof(lastDayOfMonth.year())+'</year><month>'+String.valueof(lastDayOfMonth.month())+'</month><day>'+String.valueof(lastDayOfMonth.day())+'</day></revrecstartdate>';
        //                 //End Date
        //                 strrequest += '<revrecenddate><year>'+String.valueof(lastDayOfMonth.year())+'</year><month>'+String.valueof(lastDayOfMonth.month())+'</month><day>'+String.valueof(lastDayOfMonth.day())+'</day></revrecenddate></updatesotransitem>';
        //                 count++;
        //             }
        //         }
        //         strrequest += '</updatesotransitems></update_sotransaction></function></content></operation></request>';

        //         System.debug('strrequest ==>'+strrequest);
        //         Dom.Document doc = new Dom.Document();
        //         doc.load(strrequest);

        //         // Send the request
        //         HttpRequest req = new HttpRequest();
        //         req.setMethod('POST');
        //         req.setEndpoint(cs.EndpointURL__c);
        //         req.setHeader('Content-Type', 'text/xml');

        //         req.setBodyDocument(doc);
        //         //req.setBody(strrequest);

        //         Http http = new Http();
        //         if(!test.Isrunningtest()){
        //             HttpResponse res = http.send(req);
        //             Dom.Document resdoc = res.getBodyDocument();
        //             System.debug('resdocXmlString==>'+resdoc.toXmlString());
        //         }
        //     }

        // }
    }

    public class intSummaryWrap {
        // public String name;
        // public String SFId;
        // public String SFName;
        // public String inId;
        // public String companyId;
        // public String status;
        // public String errorMsg;
        // public intSummaryWrap(String n, String sId, String sfN, String iId, String comp, String st, String er){
        //     name = n;
        //     SFId = sId;
        //     SFName = sfN;
        //     inId = iId;
        //     companyId = comp;
        //     status = st;
        //     errorMsg = er;
        // }
    }

   
 }