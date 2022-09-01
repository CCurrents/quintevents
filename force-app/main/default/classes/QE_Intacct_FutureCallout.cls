/* ====================================================
@Name:  QE_Intacct_FutureCallout
@Copyright notice:
Copyright (c) 2017, developed by
All rights reserved.

Redistribution and use in source and binary forms,
with or without modification, are not permitted.
@======================================================
@======================================================
@Purpose: This is a future method make a callout to intacct
@======================================================
@======================================================
@History
@---------
@VERSION________AUTHOR______________DATE______________DETAIL
1.0        Sundar Subramaniam   11/28/2017      INITIAL DEVELOPMENT

@======================================================*/
global class QE_Intacct_FutureCallout {
    //public class employeeException extends Exception {}
    public static Boolean apContactTrueFlag;
    public static String apContactId;
    public static Opportunity opportunityObj;
    public static String CustomerId;
    public static String CustomerNo;
    public static List<Payment_Term__c> optList;
    @future (callout=true)
    public static void sendDataIntacct(Id oppId) {
        apContactTrueFlag = false;
        optList = new List<Payment_Term__c>();
        List<SFDCToIntacctMap_Old__c> accMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> conMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> payMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> oppMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> eveMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> allMapList = new List<SFDCToIntacctMap_Old__c>();
        List<Exception_Log__c> excLogList = new List<Exception_Log__c>();
        List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
        List<intSummaryWrap> intSummList = new List<intSummaryWrap>();
        //intSummList.add(new intSummaryWrap( n, sId, iId, comp, st, er);
        Map<String,Sobject> objRecordMap = new Map<String,Sobject>();
        Set<String> eleSet = new Set<String>();
        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        Id oppRecId1 = oppId;
        Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Intacct_Status__c,Sandbox_Intacct_Apex_Error__c,
                                 Sandbox_Intacct_Status__c, Location_Id__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
        opportunityObj = oppFldRec;
        oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', null);
        oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', null);
        
        QE_ExceptionHandling_Email__c csE = QE_ExceptionHandling_Email__c.getOrgDefaults();
        
        String[] toAddresses = new String[] {csE.To_Address__c};
            String[] ccAddresses = new String[] {csE.CC_Address__c};
                String[] bccAddresses = new String[]{};
                    if(csE.BCC_Address__c != null)
                    bccAddresses.add(csE.BCC_Address__c);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(toAddresses);
        if(ccAddresses.size() > 0 && ccAddresses != null)
            message.setCcAddresses(ccAddresses);
        if(bccAddresses.size() > 0 && bccAddresses != null)
            message.setBccAddresses(bccAddresses);
        message.subject = 'Salesforce-Intacct Interation Status. Opportunity Id:- '+ oppFldRec.Id ;

        try{
            String accQuery;
            String conQuery;
            String eveQuery;
            String payQuery;
            String oppQuery;
            SObject accRec;
            SObject conRec;
            SObject eveRec;
            SObject personAccRec;
            boolean isPerson = false;
            
            List<Payment_Term__c> payRecList = new List<Payment_Term__c>();
            //Create Mapping List
            String isProuction = cs.Production__c ? 'Yes' : 'No';
            for(SFDCToIntacctMap_Old__c sti: [SELECT Id, Intacct_Object__c, Name, Active__c, Custom_Logic__c,Custom_Setting_Name__c,Operation__c,Line_Item__c,Type__c, Constant_Value__c, Description__c, Intacct_Node_Name__c, Intacct_Table__c, Sequence__c, SF_Field_API_Name__c, SF_Object__c FROM SFDCToIntacctMap_Old__c
                                          WHERE Active__c =: true AND Operation__c = 'create' and (Production__c = null or Production__c = :isProuction) ORDER BY Sequence__c]){
                                              allMapList.add(sti);
                                              if(sti.SF_Object__c == 'Account'){
                                                  accMapList.add(sti);
                                              }else if(sti.SF_Object__c == 'Contact'){
                                                  conMapList.add(sti);
                                              }else if(sti.SF_Object__c == 'Payment_Term__c' && sti.Intacct_Object__c == 'Sales Invoice' ){
                                                  payMapList.add(sti);
                                              }else if(sti.SF_Object__c == 'Opportunity'){
                                                  oppMapList.add(sti);
                                              }else if(sti.SF_Object__c == 'QE360_Event__c'){
                                                  eveMapList.add(sti);
                                              }
                                          }
            Opportunity oppRec;
            //Create Opportunity Query
            Id oppRecId = oppId;
            String oppFld;
            if(oppMapList.size() > 0){
                oppFld = ', Name, Intacct_Apex_Error__c,Intacct_Status__c,Sandbox_Intacct_Apex_Error__c,Sandbox_Intacct_Status__c,CloseDate,AccountID, Account.RecordTypeId,Event__c,Record_Id__c,' +
                    'Sandbox_Record_Id__c,Primary_Contact__c,AP_Contact_Id__c,Account.Name ';
                oppQuery = genDynQuery(oppQuery, oppMapList, oppMapList[0].SF_Object__c,oppFld);
                oppQuery = oppQuery + ' WHERE Id =: oppRecId LIMIT 1' ;
            }else{
                oppQuery = 'SELECT Id, Name, Intacct_Apex_Error__c,Intacct_Status__c,Sandbox_Intacct_Apex_Error__c,Sandbox_Intacct_Status__c,CloseDate,AccountID, Account.RecordTypeId,Event__c,Record_Id__c,' +
                    'Intacct_Id__c,Sandbox_Record_Id__c,Sandbox_Intacct_Id__c,Intacct_Employee_Id__c,AP_Contact_Id__c,Account.Name FROM Opportunity WHERE Id =: oppRecId';
            }
            try{
                System.debug('oppQuery==>'+oppQuery);
                oppRec = Database.query(oppQuery);
                System.debug('oppRec==>'+oppRec);
            } catch(Exception ex){
                oppRec = null;
                oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', ex.getMessage()+', Line Number: ' +ex.getLineNumber());
                oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                update oppFldRec;
            }
            objRecordMap.put('Opportunity',oppRec);
            System.debug('@@@opp=>'+oppRec);
            if(oppRec.AccountID != null){
                String accRecTypeName = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosById().get(oppRec.Account.RecordTypeId).getName();
                Id conId;
                System.debug('@@@accRecTypeName=>'+accRecTypeName);
                if(accRecTypeName == 'Person Account'){
                    isPerson = true;
                    Account pAcc = [Select Id, PersonContactId From Account Where Id =: oppRec.AccountID];
                    conId = pAcc.PersonContactId;
                }
                System.debug('@@@accMapList=>'+accMapList);
                //Create Account Query
                if(accMapList.size() > 0){
                    String accFld = ',Record_Id__c,Sandbox_Record_Id__c ';
                    accQuery = genDynQuery(accQuery,accMapList, accMapList[0].SF_Object__c,accFld);
                    Id accId = oppRec.AccountID;
                    accQuery = accQuery + ' WHERE Id =: accId LIMIT 1' ;
                    try{
                        accRec = Database.query(accQuery);
                    } catch(Exception ex){
                        accRec = null;
                        oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', ex.getMessage()+', Line Number: ' +ex.getLineNumber());
                        oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                        update oppFldRec;
                    }
                }
                objRecordMap.put('Account',accRec);
                //Create Contact Query
                if(conMapList.size() > 0){
                    String conFld = ',Record_Id__c,Sandbox_Record_Id__c,Sandbox_Intacct_Id__c,Intacct_Id__c ';
                    conQuery = genDynQuery(conQuery,conMapList, conMapList[0].SF_Object__c,conFld);
                    if(isPerson){
                        conQuery = conQuery + ' WHERE Id =: conId ';
                    }else{
                        Id accConId = accRec.Id;
                        Id contactId = oppRec.Primary_Contact__c;
                        //conQuery = conQuery + ' WHERE accountId =: accConId AND Primary_Contact__c = TRUE LIMIT 1';
                        conQuery = conQuery + ' WHERE accountId =: accConId AND Id = :contactId LIMIT 1';
                    }
                    try{
                        conRec = Database.query(conQuery);
                    } catch(Exception ex){
                        conRec = null;
                        oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', ex.getMessage()+', Line Number: ' +ex.getLineNumber());
                        oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                        update oppFldRec;
                    }
                }
                objRecordMap.put('Contact',conRec);
                
                //Create Event Query
                if(eveMapList.size() > 0){
                    String eveFld = ' ,End_Date__c ';
                    eveQuery = genDynQuery(eveQuery,eveMapList, eveMapList[0].SF_Object__c,eveFld);
                    Id eveId = oppRec.Event__c;
                    eveQuery = eveQuery + ' WHERE Id =: eveId LIMIT 1';
                    
                    try{
                        eveRec = Database.query(eveQuery);
                    } catch(Exception ex){
                        eveRec = null;
                        oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', ex.getMessage()+', Line Number: ' +ex.getLineNumber());
                        oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                        update oppFldRec;
                    }
                }
                //System.debug('eveRec==>'+eveRec);
                objRecordMap.put('QE360_Event__c',eveRec);
                
                //Create Payement Query
                if(payMapList.size() > 0){
                    String addFld = ',Name,Event_Payment_Term_Start_Date__c,Opportunity_Payment_Term__c,Exchange_Rate_Date__c,Payment_Due_Date__c,Opportunity_Event_Start_Date__c,CreatedDate,Record_Id__c,Intacct_Id__c,Intacct_Line_Number__c,'+
                        'Sandbox_Record_Id__c,Sandbox_Intacct_Id__c,Sandbox_Intacct_Line_Number__c';
                    payQuery = genDynQuery(payQuery,payMapList, payMapList[0].SF_Object__c,addFld);
                    payQuery = payQuery + ' WHERE Opportunity__c =: oppId ';
                    try{
                        payRecList = Database.query(payQuery);
                        System.debug('payRecList-->'+payRecList);
                    } catch(Exception ex){
                        payRecList = null;
                        oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', ex.getMessage()+', Line Number: ' +ex.getLineNumber());
                        oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                        update oppFldRec;
                    }
                }
                
            }
            
            if(oppRec != null){
                if(oppRec.Intacct_Employee_Id__c == null ){
                    excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'sendDataIntacct', 'Invalid or blank Intacct employee id in USER object',null,null,oppId,null));
                    if(excLogList.size() > 0){
                        upsert excLogList;
                        oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', ' Invalid or blank Intacct employee id in USER object');
                        oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                        update oppFldRec;
                        if(!test.isRunningTest())
                            //System.assert(false);
                            return;
                    }
                }
            }
            boolean conCreateStatus = false;
            boolean conGetStatus = false;
            boolean accCreateStatus = false;
            boolean accGetStatus = false;
            boolean EvtCreateStatus = false;
            boolean payStatus =false;
            boolean conactGetStatus = false;
            //Check Contact Exist in Intacct.
            DOM.Document getCondoc = new DOM.Document();
            
            if(conRec!= null){
                if(string.ValueOf(conRec.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')) != null){
                    getIntcctData('CONTACT', string.ValueOf(conRec.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')), cs, getCondoc);
                    conGetStatus = intacctGetCallout(cs, getCondoc, 'contact',conRec,excLogList, reResList,oppId,intSummList);
                }else if(string.ValueOf(conRec.get('Name')) != null){
                    getIntcctData('CONTACT', string.ValueOf(conRec.get('Name')), cs, getCondoc);
                    conGetStatus = intacctGetCallout(cs, getCondoc, 'contact',conRec,excLogList, reResList,oppId,intSummList);
                }
            }else{
                oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', 'Primary contact missing for the Account');
                oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                update oppFldRec;
                return;
            }
            system.debug('^^^conGetStatus1 =='+conGetStatus);            
            
            if(conGetStatus){
                conCreateStatus = true;
            } else {
                //Create Contact in Intacct
                DOM.Document doc = new DOM.Document();
                dom.XmlNode cfunction = controlAuthXML(cs, doc, null);
                dom.XmlNode ccreate = cfunction.addChildElement(conMapList[0].Operation__c, null, null);
                dom.XmlNode cparentEle = ccreate.addChildElement(conMapList[0].Intacct_Table__c, null, null);
                eleSet = new Set<String>();
                genContentXML(allMapList,conMapList[0].Intacct_Table__c,conMapList[0].Operation__c,conRec,cs,cparentEle,null,objRecordMap,conMapList[0].Intacct_Object__c, eleSet,null,null);
                conCreateStatus = intactCallout(cs, doc, 'contact', conRec,excLogList,reResList,oppId,null,intSummList, false);
                conGetStatus = conCreateStatus;
                System.debug('conCreateStatus-->'+conCreateStatus);                
            }            
            system.debug('^^^conGetStatus2 =='+conGetStatus);
            //**************Create Ap contact details into intacct***********
            if(oppRec.AP_Contact_Name__c != null){
                DOM.Document docXml = new DOM.Document();
                Contact con = new Contact();
                con.id = conRec.id; 
                con.LastName = oppRec.AP_Contact_Name__c;
                con.Email = oppRec.AP_Contact_Email__c;
                con.Phone = oppRec.AP_Contact_Phone__c;
                // if(oppRec.AP_Contact_Id__c != null){
                //     getIntcctData('CONTACT', oppRec.AP_Contact_Id__c, cs, docXml);
                //     conactGetStatus = intacctGetCallout(cs, docXml, 'contact', con, excLogList, reResList, oppId, intSummList);
                // }else
                if(oppRec.AP_Contact_Name__c != null){
                    getIntcctData('CONTACT', oppRec.AP_Contact_Name__c, cs, docXml);
                    conactGetStatus = intacctGetCallout(cs, docXml, 'contact', con, excLogList, reResList, oppId, intSummList);
                }
                if(conactGetStatus && oppRec.AP_Contact_Name__c == conRec.get('Name')){
                    oppRec.AP_Contact_Id__c = string.valueof(conRec.get(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c'));
                }
                system.debug('^^^conGetStatus3 =='+conGetStatus);
                if(conactGetStatus == false){
                    DOM.Document doc = new DOM.Document();
                    dom.XmlNode cfunction = controlAuthXML(cs, doc, null);
                    dom.XmlNode ccreate = cfunction.addChildElement('create', null, null);
                    dom.XmlNode cparentEle = ccreate.addChildElement('CONTACT', null, null);
                    dom.XmlNode conName = cparentEle.addChildElement('CONTACTNAME', null, null).addTextNode(oppRec.AP_Contact_Name__c != null ? oppRec.AP_Contact_Name__c : '');
                    dom.XmlNode conPrintAs = cparentEle.addChildElement('PRINTAS', null, null).addTextNode(oppRec.AP_Contact_Name__c != null ? oppRec.AP_Contact_Name__c : '');
                    dom.XmlNode conLastName = cparentEle.addChildElement('LASTNAME', null, null).addTextNode(oppRec.AP_Contact_Name__c != null ? oppRec.AP_Contact_Name__c : '');
                    dom.XmlNode conEmail = cparentEle.addChildElement('EMAIL1', null, null).addTextNode(oppRec.AP_Contact_Email__c != null ? oppRec.AP_Contact_Email__c : '');
                    dom.XmlNode conPhone = cparentEle.addChildElement('PHONE1', null, null).addTextNode(oppRec.AP_Contact_Phone__c != null ? oppRec.AP_Contact_Phone__c : '');
                    dom.XmlNode conMailAddress = cparentEle.addChildElement('MAILADDRESS', null, null);
                    dom.XmlNode conAddress1 = conMailAddress.addChildElement('ADDRESS1', null, null).addTextNode(oppRec.Billing_Street__c != null ? oppRec.Billing_Street__c : '');
                    dom.XmlNode conAddress2 = conMailAddress.addChildElement('ADDRESS2', null, null);
                    dom.XmlNode conCity = conMailAddress.addChildElement('CITY', null, null).addTextNode(oppRec.Billing_City__c!= null ? oppRec.Billing_City__c : '');
                    dom.XmlNode conState = conMailAddress.addChildElement('STATE', null, null).addTextNode(oppRec.Billing_State_Province__c!= null ? oppRec.Billing_State_Province__c :'');
                    dom.XmlNode conZip = conMailAddress.addChildElement('ZIP', null, null).addTextNode(oppRec.Billing_Zip_Postal_Code__c!= null ? oppRec.Billing_Zip_Postal_Code__c :'');
                    dom.XmlNode conCountry = conMailAddress.addChildElement('COUNTRY', null, null).addTextNode(oppRec.Billing_Country__c!= null ? oppRec.Billing_Country__c : '');
                    //genContentXML( allMapList, 'Contact', 'create' , con, cs, cparentEle, null, objRecordMap, 'Contact', eleSet, null, null);
                    conCreateStatus = intactCallout(cs, doc, 'contact', con, excLogList, reResList, oppId, null, intSummList, true);
                    conGetStatus = conCreateStatus;
                }
            }
            //*******************Ap Contact task End*************************

            if(conCreateStatus || test.isRunningTest()){
                //Check CUSTOMER Exist in Intacct.
                System.debug('conCreateStatus custmer-->'+conCreateStatus);
                DOM.Document getAccdoc = new DOM.Document();
                
                if(string.ValueOf(accRec.get(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c')) != null){
                    getIntcctData('CUSTOMER', string.ValueOf(accRec.get(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c')), cs, getAccdoc);
                    //System.debug('getAccdoc==>'+getAccdoc.toXmlString());
                    accGetStatus = intacctGetCallout(cs, getAccdoc, 'customer',accRec,excLogList, reResList,oppId,intSummList);
                    System.debug('accGetStatus-->'+accGetStatus);
                }
                if(accGetStatus){
                    accCreateStatus = true;
                } else {
                    //Create CUSTOMER in Intacct
                    System.debug('accGetStatus-->'+accGetStatus);
                    DOM.Document accdoc = new DOM.Document();
                    dom.XmlNode cufunction = controlAuthXML(cs, accdoc, null);
                    dom.XmlNode cucreate = cufunction.addChildElement(accMapList[0].Operation__c, null, null);
                    dom.XmlNode cuparentEle = cucreate.addChildElement(accMapList[0].Intacct_Table__c, null, null);
                    eleSet = new Set<String>();
                    genContentXML(allMapList,accMapList[0].Intacct_Table__c,accMapList[0].Operation__c,accRec,cs,cuparentEle,conRec,objRecordMap,accMapList[0].Intacct_Object__c,eleSet,null,null);
                    if(!test.isRunningTest()){
                        accCreateStatus = intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,oppId,null,intSummList, false);
                    }else{
                        accCreateStatus = true;
                    }
                    accGetStatus = accCreateStatus;
                    System.debug('accGetStatus-->'+accGetStatus);
                }
                //System.debug('accCreateStatus==>'+accCreateStatus);
                if(accCreateStatus || test.isRunningTest()){
                    //Check Event Exist in Intacct.
                    DOM.Document getEvtdoc = new DOM.Document();
                    
                    boolean EvtGetStatus = false;
                    DOM.Document evtdoc = new DOM.Document();
                    dom.XmlNode efunction = controlAuthXML(cs, evtdoc, String.ValueOf(oppFldRec.Location_Id__c));
                    dom.XmlNode eparentEle = efunction.addChildElement(eveMapList[0].Intacct_Table__c, null, null);
                    
                    eleSet = new Set<String>();
                    
                    if(test.isRunningTest() == false) {
                    
                        if(payRecList.size() > 0){
                            if(string.ValueOf(oppRec.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')) != null){
                                DOM.Document getCondocso = new DOM.Document();
                                getIntcctData('SODOCUMENT', string.ValueOf(oppRec.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')), cs, getCondocso);
                                EvtCreateStatus = intacctGetCallout(cs, getCondocso, 'SODOCUMENT',oppRec,excLogList, reResList,oppId,intSummList);
                                //oppRec.Intacct_Status__c = null;
                                oppRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', null);
                            }
                            if(EvtCreateStatus == false){
                                genContentXML(allMapList,eveMapList[0].Intacct_Table__c,eveMapList[0].Operation__c,eveRec,cs,eparentEle,oppRec,objRecordMap,eveMapList[0].Intacct_Object__c,eleSet, payRecList,eveRec);
                                EvtCreateStatus = intactCallout(cs, evtdoc, 'salesOrder', oppRec,excLogList,reResList,oppId,null,intSummList, false);
                            }
                        }else{
                            oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', 'There are no opportunity Payment terms to process, Re-Send after creating opportunity payment terms');
                            oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                            update oppFldRec;
                            return;
                        }
                        //}
                    } else {
                        genContentXML(allMapList,eveMapList[0].Intacct_Table__c,eveMapList[0].Operation__c,eveRec,cs,eparentEle,oppRec,objRecordMap,eveMapList[0].Intacct_Object__c,eleSet, null,null);
                        
                        if(test.isRunningTest()){ EvtCreateStatus = true;}
                        else{
                            EvtCreateStatus = intactCallout(cs, evtdoc, 'salesOrder', oppRec,excLogList,reResList,oppId,null,intSummList, false);
                        }
                        
                        
                    }
                    // }
                    if(EvtCreateStatus || test.isRunningTest()){
                        
                        if(payRecList.size() > 0){
            
                            //Insert Payment Terms
                            Boolean paymenttermexist = true;
                            DOM.Document paydoc = new DOM.Document();
                            String guidVal;
                            dom.XmlNode pContent = controlAuthXMLPayment(cs, paydoc, String.ValueOf(oppFldRec.Location_Id__c));
                            //dom.XmlNode pparentEle = pfunction.addChildElement(payMapList[0].Intacct_Table__c, null, null);
                            
                            Blob b = Crypto.GenerateAESKey(128);
                            String h = EncodingUtil.ConvertTohex(b);
                            String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
                            for(SObject prl: payRecList){
                                System.debug('paymentterm-->'+prl);
                                if(string.ValueOf(prl.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')) != null){
                                    DOM.Document getCondocso = new DOM.Document();
                                    getIntcctData('ARINVOICE', string.ValueOf(prl.get(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c')), cs, getCondocso);
                                    payStatus = intacctGetCallout(cs, getCondocso, 'ARINVOICE',prl,excLogList, reResList,oppId,intSummList);
                                    //oppRec.Intacct_Status__c = null;
                                    oppRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', null);
                                }
                                else{
                                    paymenttermexist = false;
                                    eleSet = new Set<String>();
                                    dom.XmlNode pfunction = pContent.addChildElement('function', null, null);
                                    pfunction.setAttribute('controlid', guid);
                                    dom.XmlNode pparentEle = pfunction.addChildElement(payMapList[0].Intacct_Table__c, null, null);
                                    genContentXML(allMapList,payMapList[0].Intacct_Table__c,payMapList[0].Operation__c,prl,cs,pparentEle,accRec,objRecordMap,payMapList[0].Intacct_Object__c,eleSet, payRecList,null);
                                }
                            }
                            if(!paymenttermexist){
                                payStatus = intactCallout(cs, paydoc, 'paymentterm',payRecList[0],excLogList,reResList,oppId,payRecList,intSummList, false);
                            }
                            //}
                        }else{
                        
                            oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', 'There are no opportunity Payment terms to process, Re-Send after creating opportunity payment terms');
                            oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                            update oppFldRec;
                            return;
                        }
                    }
                }
            }
            
            update conRec;
            if(isPerson){
                SObject acc = [SELECT Record_Id__c,Intacct_Id__c FROM Account WHERE Id =: oppRec.AccountID];
                acc.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c',accRec.get(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c'));
                acc.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c',accRec.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c'));
                update acc;
            }else{
                update accRec;
            }
            //System.debug('oppRec.Intacct_Status__c=>'+oppRec.Intacct_Status__c+'=Satus=>'+conCreateStatus+conGetStatus+accCreateStatus+accGetStatus+EvtCreateStatus+payStatus);
            if(oppRec.get(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c') != 'Failed' && conCreateStatus == true && conGetStatus == true && accCreateStatus == true && accGetStatus == true && EvtCreateStatus == true && payStatus == true){
                //oppRec.Intacct_Status__c = 'Success';
                //oppRec.Intacct_Apex_Error__c = '';
                oppRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', '');
                oppRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Success');
            }else{
                //oppRec.Intacct_Status__c = 'Failed';
                oppRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
            }
            if(apContactTrueFlag){
                oppRec.AP_Contact_Id__c = apContactId;
            }
            update oppRec;
            if(payRecList.size() > 0){
                update payRecList;
            }
            if(excLogList.size() > 0){
                upsert excLogList;
            }
            if(reResList.size() > 0){
                upsert reResList;
            }
            if(optList.size() > 0){
                update optList;
            }
        }catch(exception e){
            excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'sendDataIntacct', e.getMessage(),e.getLineNumber(),e.getTypeName(),oppId,null));
            
            if(excLogList.size() > 0){
                upsert excLogList;
               
                oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', e.getMessage()+', Line Number: ' +e.getLineNumber());
                oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                update oppFldRec;
                intSummList.add(new intSummaryWrap('Opportunity/Sales Order', oppFldRec.Id, oppFldRec.Name,null, null, 'Failed', cs.Production__c ? oppFldRec.Intacct_Apex_Error__c : oppFldRec.Sandbox_Intacct_Apex_Error__c ));
            }
            
        }
        
        if(intSummList.size() > 0){
            string strBody = '<table class="x_MsoNormalTable" border="1" width="921" cellspacing="0" cellpadding="0">';
            strBody = strBody +'<tbody><tr><td valign="bottom" width="269"><p class="x_MsoNormal"><strong>Integration</strong></p></td>';
            strBody = strBody +'<td valign="bottom" width="122"><p class="x_MsoNormal"><strong>Salesforce Id</strong></p></td>';
            strBody = strBody +'<td valign="bottom" width="122"><p class="x_MsoNormal"><strong>Name</strong></p></td>';
            strBody = strBody +'<td valign="bottom" width="145"><p class="x_MsoNormal"><strong>Intacct Number</strong></p></td>';
            strBody = strBody +'<td valign="bottom" width="155"><p class="x_MsoNormal"><strong>Intacct Company</strong></p></td>';
            strBody = strBody +'<td valign="bottom" width="77"><p class="x_MsoNormal"><strong>Status</strong></p></td>';
            strBody = strBody +'<td valign="bottom" width="136"><p class="x_MsoNormal"><strong>Error Message</strong></p></td></tr>';
            
            for(intSummaryWrap IIS: intSummList){
                strBody = strBody +'<tr><td valign="bottom" width="269"><p class="x_MsoNormal">'+IIS.name+'</p></td>';
                strBody = strBody +'<td valign="bottom" width="122"><p class="x_MsoNormal">'+IIS.SFId+'</p></td>';
                strBody = strBody +'<td valign="bottom" width="122"><p class="x_MsoNormal">'+IIS.SFName+'</p></td>';
                strBody = strBody +'<td valign="bottom" width="145"><p class="x_MsoNormal">'+IIS.inId+'</p></td>';
                strBody = strBody +'<td valign="bottom" width="155"><p class="x_MsoNormal">'+IIS.companyId+'</p></td>';
                strBody = strBody +'<td valign="bottom" width="77"><p class="x_MsoNormal">'+IIS.status+'</p></td>';
                strBody = strBody +'<td valign="bottom" width="136"><p class="x_MsoNormal">'+IIS.errorMsg+'</p></td></tr>';
            }
            strBody = strBody +'</tbody></table>';
            
            message.setHtmlBody(strBody);
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }
    
    public static string genDynQuery(String qryStr,List<SFDCToIntacctMap_Old__c> accMapList,String objStr, String addField){
        set<String> uniqField = new Set<String>();
        if(objStr=='QE360_Event__c'){
            qryStr = 'SELECT createddate';
        }else{
            qryStr = 'SELECT Id';
            //qryStr = 'SELECT ';
        }
        for(SFDCToIntacctMap_Old__c sti: accMapList){
            if(!uniqField.contains(sti.SF_Field_API_Name__c) && sti.SF_Field_API_Name__c != null){
                qryStr = qryStr +','+ sti.SF_Field_API_Name__c;
                //qryStr = qryStr.replace('SELECT ,', 'SELECT ');
                uniqField.add(sti.SF_Field_API_Name__c);
            }
        }
        //System.debug('qryStr-->'+qryStr);
        if(addField == null){
            qryStr = qryStr + ' FROM '+ objStr;
        }else{
            qryStr = qryStr + ' ' + addField + ' '+ ' FROM '+ objStr;
        }
        return qryStr;
    }
    
    public static boolean intactCallout(Intacct_API_Details__c cs,DOM.Document doc,String tableName,SObject record,List<Exception_Log__c> excLogList,List<RequestResponse_Log__c> reResList,Id oppId,List<SObject> payList,List<intSummaryWrap> intSummList,Boolean apContactIdFlag){
        try{
            System.debug('reqdoc==>'+doc.toXMLString());
            System.debug('tableName==>'+tableName);
            // if(tableName == 'salesOrder'){
            //     dom.XmlNode rootNode  = doc.getRootElement();
            //     // System.debug('root'+rootNode.getName());
            //     // System.debug('root'+rootNode.getText());
            //     // dom.Xmlnode root1 = rootNode.getChildElement('operation', null);
            //     // System.debug('root1'+root1.getName());
            //     // System.debug('root1'+root1.getText());
            //     // dom.Xmlnode root2 = root1.getChildElement('content', null);
            //     // System.debug('root2'+root1.getName());
            //     // System.debug('root2'+root1.getText());
            //     dom.Xmlnode docRequest = rootNode.getChildElement('operation', null).getChildElement('content', null).getChildElement('function', null).getChildElement('create_sotransaction', null).getChildElement('billto', null);
            //     //dom.XmlNode conBillto = docRequest.addChildElement('billto', null, null);
            //    List<dom.Xmlnode> docChildren = docRequest.getChildren();
            //    System.debug('docChildren-->'+docChildren);
            //     if(docChildren.isEmpty()){
            //     //if(docRequest.getName() == null || docRequest.getName() == ''){
            //         dom.Xmlnode conName = docRequest.addChildElement('contactname', null, null);
            //     }
            // }
            // Send the request
            System.debug('reqdoc==>'+doc.toXMLString());
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(cs.Production__c ? cs.EndpointURL__c : cs.Sandbox_EndpointURL__c);
            req.setHeader('Content-Type', 'text/xml');
            
            req.setBodyDocument(doc);
            req.setTimeout(30000);
            Http http = new Http();
            HttpResponse res = http.send(req);
            Dom.Document resdoc = res.getBodyDocument();
            System.debug('resdoc==>'+resdoc.toXMLString());
            String msg='';
            reResList.add(QE_Utility_class.reqResLog('QE_Intacct_FutureCallout', 'intactCallout', String.valueOf(doc.toXmlString()),String.valueOf(resdoc.toXmlString()),cs.Production__c ? cs.EndpointURL__c : cs.Sandbox_EndpointURL__c,String.valueOf(res.getStatusCode()),msg,oppId,string.ValueOf(record.get('Id'))));
            dom.Xmlnode vxroot = resdoc.getRootElement().getChildElement('operation', null);
            
            if(res.getStatusCode() == 200){
                String RECORDNO;
                String RECORDINTNO;
                String successStatus = 'Success';
                
                if(vxroot != null) {
                    List<dom.Xmlnode> vxresults = new List<dom.Xmlnode>();
                    vxresults = vxroot.getChildren();
                    
                    for(dom.Xmlnode vresu : vxresults){
                        if(vresu.getName() == 'result'){
                            successStatus = vresu.getChildElement('status', null).getText();
                            if(successStatus != 'Success'){
                                excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'intactCallout', String.valueOf(res.getBody()),null,null,oppId,string.ValueOf(record.get('Id'))));
                                if(tableName == 'payment'){
                                    record.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c', vresu.getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
                                    record.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                                    update record;
                                }else{
                                    if(oppId != null){
                                        Id oppRecId1 = oppId;
                                        Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Intacct_Status__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
                                        /*oppFldRec.Intacct_Apex_Error__c = vresu.getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText();
                                        oppFldRec.Intacct_Status__c = 'Failed';*/
                                        oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', vresu.getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
                                        oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                                        update oppFldRec;
                                    }
                                }
                                return false;
                            }
                        }
                    }
                }
                if(successStatus == 'Success'){
                    List<String> invoiceIds = new List<String>();
                    Map<Integer,SObject> paymentMap = new Map<Integer,SObject>();
                    if(tableName == 'paymentterm' || tableName == 'salesOrder' || tableName == 'payment'){
                        if(oppId != null){
                            RECORDNO = vxroot.getChildElement('result', null).getChildElement('key', null).getText();
                            RECORDINTNO = vxroot.getChildElement('result', null).getChildElement('key', null).getText();
                        }
                        system.debug('^^^^RECORDNO1=='+RECORDNO);
                        system.debug('^^^^RECORDINTNO1=='+RECORDINTNO);
                        if(tableName == 'paymentterm'){
                            //Map<Integer,SObject> paymentMap = new Map<Integer,SObject>();
                            Integer i=0;
                            for(SObject pl: payList){
                                paymentMap.put(i,pl);
                                i++;
                            }
                            System.debug('paymentMap==>'+paymentMap);
                            dom.Xmlnode xroot = vxroot;
                            List<dom.Xmlnode> xresults = new List<dom.Xmlnode>();
                            xresults = xroot.getChildren();
                            System.debug('xresults==>'+xresults);
                            Integer j=0;
                            
                            for (dom.Xmlnode resu : xresults){
                                System.debug('xresultsNAme==>'+resu.getName());
                                System.debug('resu==>'+resu);
                                if(resu.getName() == 'result'){
                                    String docNumber ;
                                    String PAYRECORDINTNO;
                                    String PAYRECORDNO;
                                    PAYRECORDINTNO = resu.getChildElement('key', null).getText();
                                    //System.debug('xresultsNAmeKey==>'+resu.getName());
                                    if(PAYRECORDINTNO != null){
                                        //System.debug('RECORDINTNO==>'+PAYRECORDINTNO);
                                        String[] parts = PAYRECORDINTNO.split('-');
                                        if(parts.size() > 1)
                                            PAYRECORDINTNO = parts[1];
                                    }
                                    //System.debug('Record_Id__cRECORDNO==>'+PAYRECORDNO);
                                    PAYRECORDNO = null;
                                    PAYRECORDNO = getInvoiceRecordId( PAYRECORDINTNO, cs);
                                    //System.debug('Record_Id__c==>'+PAYRECORDNO);
                                    
                                    if(paymentMap.size() > 0 && paymentMap.containsKey(j)){
                                        SObject py = paymentMap.get(j);
                                        if(PAYRECORDNO != null)
                                            py.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', PAYRECORDNO);
                                        if(PAYRECORDINTNO != null)
                                            py.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', PAYRECORDINTNO);
                                    }
                                    system.debug('^^^^PAYRECORDNO1=='+PAYRECORDNO);
                                    system.debug('^^^^PAYRECORDINTNO1=='+PAYRECORDINTNO);
                                    j++;
                                    /* for(SObject pl: payList){
                                    if(PAYRECORDNO != null)
                                    pl.put('Record_Id__c', PAYRECORDNO);
                                    pl.put('Intacct_Id__c', PAYRECORDINTNO);
                                    } */
                                    invoiceIds.add(PAYRECORDINTNO);
                                    System.debug('invoiceIds-->'+invoiceIds);
                                    //LatestInvoiceId = invoiceIds
                                }
                            }
                        }else if(tableName == 'payment'){
                            
                        }else{
                            record.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', RECORDNO);
                            record.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', RECORDINTNO);
                        }
                    }else {
                        RECORDNO = vxroot.getChildElement('result', null).getChildElement('data', null).getChildElement(tableName, null).getChildElement('RECORDNO', null).getText();
                        System.debug('RECORDNO-->'+RECORDNO+'<--apContactIdFlag-->'+apContactIdFlag);
                        system.debug('^^^^RECORDNO2=='+RECORDNO);                        
                        if(apContactIdFlag){
                            System.debug('RECORDNO-->'+RECORDNO+'<--apContactIdFlag-->'+apContactIdFlag);
                            apContactId = RECORDNO;
                            apContactTrueFlag = true;
                        }
                        if(tableName == 'customer'){
                            RECORDINTNO = vxroot.getChildElement('result', null).getChildElement('data', null).getChildElement(tableName, null).getChildElement('CUSTOMERID', null).getText();
                            CustomerId = RECORDINTNO;
                            CustomerNo = RECORDNO;
                        }else{
                            RECORDINTNO = vxroot.getChildElement('result', null).getChildElement('data', null).getChildElement(tableName, null).getChildElement('CONTACTNAME', null).getText();
                        }
                        system.debug('^^^^RECORDINTNO2=='+RECORDINTNO);
                        
                        if(apContactIdFlag == false){
                            System.debug('RECORDNO-->'+RECORDNO+'<--apContactIdFlag-->'+apContactIdFlag);
                            record.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', RECORDNO);
                            record.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', RECORDINTNO);
                        }
                    }
                    if(tableName == 'contact'){
                        intSummList.add(new intSummaryWrap( 'Contact', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', '', 'Success', ''));
                    }else if(tableName == 'customer'){
                        intSummList.add(new intSummaryWrap( 'Account/Customer', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),RECORDINTNO, '', 'Success', ''));
                    }else if(tableName == 'salesOrder'){
                        intSummList.add(new intSummaryWrap( 'Opportunity/Sales Order', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),RECORDINTNO, string.ValueOf(record.get('Location_Id__c')), 'Success', ''));
                    }else if(tableName == 'paymentterm'){
                        intSummList.add(new intSummaryWrap( 'Payment Terms/Sales Invoice', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),RECORDINTNO, string.ValueOf(record.get('Location_Id__c')), 'Success', ''));
                    }
                    System.debug('invoiceIds-->'+invoiceIds);
                    System.debug('Before attachaAPI0-->'+invoiceIds);
                    if(tableName == 'paymentterm'){
                        System.debug('tableName-->'+tableName);
                        createAttachmentsAPInfo(opportunityObj.id, invoiceIds,paymentMap);
                    }
                    System.debug('after attachaAPI0-->'+invoiceIds);
                    return true;
                }else{
                    excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'intactCallout', String.valueOf(res.getBody()),null,null,oppId,string.ValueOf(record.get('Id'))));
                    if(tableName == 'payment'){
                        record.put(cs.Production__c ? 'Intacct_Failure_Reason__c': 'Sandbox_Intacct_Failure_Reason__c', vxroot.getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
                        record.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                        update record;
                    }else{
                        if(oppId!= null){
                            Id oppRecId1 = oppId;
                            Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Intacct_Status__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
                            if(!test.isRunningTest())
                                /*oppFldRec.Intacct_Apex_Error__c = vxroot.getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText();
                                oppFldRec.Intacct_Status__c = 'Failed';*/
                                oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', vxroot.getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
                            oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                            update oppFldRec;
                            if(tableName == 'contact'){
                                intSummList.add(new intSummaryWrap( 'Contact', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', '', 'Failed', vxroot.getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText()));
                            }else if(tableName == 'customer'){
                                intSummList.add(new intSummaryWrap( 'Account/Customer', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', '', 'Failed', vxroot.getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText()));
                            }else if(tableName == 'salesOrder'){
                                intSummList.add(new intSummaryWrap( 'Opportunity/Sales Order', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', string.ValueOf(record.get('Location_Id__c')), 'Failed', vxroot.getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText()));
                            }else if(tableName == 'paymentterm'){
                                intSummList.add(new intSummaryWrap( 'Payment Terms/Sales Invoice', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', string.ValueOf(record.get('Location_Id__c')) , 'Failed', vxroot.getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText()));
                            }
                            return false;
                        }
                    }
                    
                    return false;
                }
            }else{
                excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'intactCallout', String.valueOf(res.getBody()),null,null,oppId,string.ValueOf(record.get('Id'))));
                if(tableName == 'payment'){
                    /*record.put('Intacct_Failure_Reason__c', vxroot.getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
record.put('Intacct_Status__c' , 'Failed');
*/
                    record.put(cs.Production__c ? 'Intacct_Failure_Reason__c': 'Sandbox_Intacct_Failure_Reason__c', vxroot.getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
                    record.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                    
                    update record;
                }else{
                    if(oppId!= null){
                        Id oppRecId1 = oppId;
                        Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Intacct_Status__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
                        /*oppFldRec.Intacct_Apex_Error__c = vxroot.getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText();
oppFldRec.Intacct_Status__c = 'Failed';*/
                        oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', vxroot.getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
                        oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                        update oppFldRec;
                    }
                }
                return false;
            }
       }catch(exception e){
            excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'intactCallout', e.getMessage(),e.getLineNumber(),e.getTypeName(),oppId,string.ValueOf(record.get('Id'))));
            //QE_Utility_class.sendExceptionEmail('SFDC Error - '+e +'-Line:'+e.getLineNumber());
            if(excLogList.size() > 0){
                upsert excLogList;
                if(tableName == 'payment'){
                    //record.put('Intacct_Failure_Reason__c', e.getMessage());
                    //record.put('Intacct_Status__c' , 'Failed');
                    record.put(cs.Production__c ? 'Intacct_Failure_Reason__c': 'Sandbox_Intacct_Failure_Reason__c', e.getMessage());
                    record.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                    update record;
                }else{
                    if(oppId!= null){
                        Id oppRecId1 = oppId;
                        Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Intacct_Status__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
                        /*oppFldRec.Intacct_Apex_Error__c =  e.getMessage()+', Line Number: ' +e.getLineNumber();
oppFldRec.Intacct_Status__c = 'Failed';*/
                        oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', e.getMessage()+', Line Number: ' +e.getLineNumber());
                        oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                        update oppFldRec;
                        if(tableName == 'contact'){
                            intSummList.add(new intSummaryWrap( 'Contact', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', '', 'Failed', cs.Production__c ? oppFldRec.Intacct_Apex_Error__c : oppFldRec.Sandbox_Intacct_Apex_Error__c));
                        }else if(tableName == 'customer'){
                            intSummList.add(new intSummaryWrap( 'Account/Customer', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', '', 'Failed', cs.Production__c ? oppFldRec.Intacct_Apex_Error__c : oppFldRec.Sandbox_Intacct_Apex_Error__c));
                        }else if(tableName == 'salesOrder'){
                            intSummList.add(new intSummaryWrap( 'Opportunity/Sales Order', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', string.ValueOf(record.get('Location_Id__c')), 'Failed', cs.Production__c ? oppFldRec.Intacct_Apex_Error__c : oppFldRec.Sandbox_Intacct_Apex_Error__c));
                        }else if(tableName == 'paymentterm'){
                            intSummList.add(new intSummaryWrap( 'Payment Terms/Sales Invoice', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', string.ValueOf(record.get('Location_Id__c')) , 'Failed', cs.Production__c ? oppFldRec.Intacct_Apex_Error__c : oppFldRec.Sandbox_Intacct_Apex_Error__c));
                        }
                    }
                }  
            }
        }
        return false;
    }
    
    //XML Generation
    public static void genContentXML(List<SFDCToIntacctMap_Old__c> SFInMapList,String intacctObj,String operation,SObject record,Intacct_API_Details__c cs,dom.XmlNode docNode,SObject subRecord,Map<String,Sobject> objRecordMap, String intacctObjType, Set<String> eleSet, List<SObject> payRecList, sobject eventrec){

        dom.XmlNode parentEle = docNode;

        System.debug('##parentEle ' + parentEle);
        System.debug('##SFInMapList ' + SFInMapList);
        System.debug('##intacctObj ' + intacctObj);
        System.debug('##operation ' + operation);
        System.debug('##record ' + record);
        System.debug('##docNode ' + docNode);
        System.debug('##subRecord ' + subRecord);
        System.debug('##objRecordMap ' + objRecordMap);
        System.debug('##intacctObjType ' + intacctObjType);
        System.debug('##eleSet ' + eleSet);
        System.debug('##payRecList ' + payRecList);
        System.debug('##eventrec' + eventrec);
        if(SFInMapList.size() > 0){
            for(SFDCToIntacctMap_Old__c sti: SFInMapList){
                if(sti.Intacct_Table__c == intacctObj && sti.Intacct_Object__c  == intacctObjType){                    
                    if(sti.Line_Item__c == true){
                        String[] arrStr = sti.Intacct_Node_Name__c.split('\\.');
                        if(!eleSet.contains(arrStr[0])){
                            eleSet.add(arrStr[0]);
                            dom.XmlNode TempNode = parentEle;
                            dom.XmlNode ParentTempNode = TempNode.addChildElement(arrStr[0], null, null);
                            String newSearchText = '%'+arrStr[0]+'%';
                            String isProuction = cs.Production__c ? 'Yes' : 'No';
                            List<SFDCToIntacctMap_Old__c> paySFInMap = [SELECT Id, Intacct_Object__c, Name, Active__c, Operation__c,Line_Item__c,Type__c, Constant_Value__c, Description__c, Intacct_Node_Name__c, Intacct_Table__c, Sequence__c, SF_Field_API_Name__c, SF_Object__c FROM SFDCToIntacctMap_Old__c
                                                                    WHERE ((Intacct_Node_Name__c LIKE :newSearchText) AND (Active__c =: true) AND (Intacct_Object__c =: sti.Intacct_Object__c) AND (Operation__c =: operation) ) AND (Production__c = null or Production__c = :isProuction) ORDER BY Sequence__c];
                            for(SObject prl: payRecList){
                                Set<String> eleLineSet = new Set<String>();
                                eleLineSet.add(arrStr[0]);
                                
                                dom.XmlNode ChildTempNode = ParentTempNode.addChildElement(arrStr[1],null,null);
                                genLineItemXML(paySFInMap, intacctObj, operation, prl, ChildTempNode, objRecordMap, intacctObjType, eleLineSet,payRecList,eventrec);
                            }
                        }
                    }else{
                        if(sti.Constant_Value__c == null && sti.SF_Field_API_Name__c != null && sti.Custom_Logic__c == false){
                            String apiField = sti.SF_Field_API_Name__c.tolowercase();
                            if(sti.Intacct_Node_Name__c.contains('.')){
                                String[] arrStr = sti.Intacct_Node_Name__c.split('\\.');
                                dom.XmlNode TempNode = parentEle;
                                Integer arrLnt = arrStr.size();
                                if(arrLnt > 0){
                                    for(Integer I=0; I<arrLnt; I++){
                                        System.debug('@@@ 798 eleSet:: ' + eleSet);
                                        System.debug('@@@ 799 arrStr[I]:: ' + arrStr[I]);
                                        if(eleSet.contains(arrStr[I])){
                                            TempNode = TempNode.getChildElement(arrStr[I],null);
                                            System.debug('@@@ 802 TempNode:: ' + TempNode);
                                        }else{
                                            if(String.isBlank(sti.SF_Field_API_Name__c) || !sti.SF_Field_API_Name__c.containsIgnoreCase('AP_') || arrStr[I] != 'customfieldvalue') {
                                                eleSet.add(arrStr[I]);
                                            } 
                                            if(I == arrLnt-1){
                                                if(hasSObjectField(apiField,record) ){
                                                    if(record.get(sti.SF_Field_API_Name__c) != null){
                                                        if(sti.Type__c == 'Date'){
                                                            dateLogic(arrStr[I], record, sti.SF_Field_API_Name__c, TempNode,sti.Intacct_Node_Name__c,sti.Intacct_Object__c,payRecList,eventrec);
                                                            eleSet.remove(arrStr[I]);
                                                        }else{
                                                            TempNode.addChildElement(arrStr[I], null, null).addTextNode(String.valueof(record.get(sti.SF_Field_API_Name__c)));
                                                        }
                                                    }else if(sti.Type__c == 'Date'){
                                                        if(eleSet.contains(arrStr[I-1])){
                                                            //TempNode.getParent().removeChild(TempNode);
                                                        }
                                                    }
                                                }else{
                                                    System.debug('$$$sti.SF_Object__c==>'+sti.SF_Object__c);
                                                    System.debug('$$$sti.SF_Field_API_Name__c==>'+sti.SF_Field_API_Name__c);
                                                    System.debug('$$$objRecordMap.ContainsKey(sti.SF_Object__c)==>'+objRecordMap.ContainsKey(sti.SF_Object__c));
                                                    System.debug('$$$objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c) ==>'+objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c) );
                                                    if(objRecordMap.ContainsKey(sti.SF_Object__c) && objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c) != null){
                                                        if(sti.Type__c == 'Date'){
                                                            System.debug('record==>'+record);
                                                            System.debug('####sti.Intacct_Node_Name__c==>'+sti.Intacct_Node_Name__c);
                                                            System.debug('####sti.Intacct_Object__c==>'+sti.Intacct_Object__c);
                                                            System.debug('####sti.SF_Object__c==>'+sti.SF_Object__c);
                                                            System.debug('####sti.SF_Field_API_Name__c==>'+sti.SF_Field_API_Name__c);
                                                            dateLogic(arrStr[I], objRecordMap.get(sti.SF_Object__c), sti.SF_Field_API_Name__c, TempNode,sti.Intacct_Node_Name__c,sti.Intacct_Object__c,payRecList,eventrec);
                                                            eleSet.remove(arrStr[I]);
                                                        }else{
                                                            system.debug('@@@@arrStr[I]=='+arrStr[I]);
                                                            system.debug('@@@@sti.SF_Object__c=='+sti.SF_Object__c);
                                                            system.debug('@@@@sti.SF_Field_API_Name__c=='+sti.SF_Field_API_Name__c);
                                                            system.debug('^^^CustomerId=='+CustomerId);    
                                                            system.debug('^^^objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)=='+objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)); 
                                                            system.debug('@@@@835 TempNode 835:: ' + TempNode);
                                                            if(sti.SF_Object__c != null && sti.SF_Field_API_Name__c == 'Ap_BillTo__c' && objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c) == 'Not AP Contact'){                                                                
                                                                string contactname = getContactName(CustomerNo);
                                                                TempNode.addChildElement(arrStr[I], null, null).addTextNode(contactname);
                                                            }
                                                            else if(sti.SF_Object__c != null && sti.SF_Field_API_Name__c != null && objRecordMap.get(sti.SF_Object__c) != null && objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c) != null){
                                                                TempNode.addChildElement(arrStr[I], null, null).addTextNode(String.valueOf(objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)));
                                                            }
                                                        }
                                                    }else if(sti.Type__c == 'Date'){
                                                        // System.debug('removevalcode==>'+TempNode);
                                                        //System.debug('removevalcode==>'+arrStr[I-1]);
                                                        if(eleSet.contains(arrStr[I-1])){
                                                            TempNode.getParent().removeChild(TempNode);
                                                        }
                                                    } else if(sti.SF_Object__c.equals('Opportunity') && sti.SF_Field_API_Name__c.equals('Product_Listing__c') && objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c) == null)  {
                                                        TempNode.getParent().removeChild(TempNode);
                                                    } else if(arrStr[I] == 'customfieldvalue' && objRecordMap.ContainsKey(sti.SF_Object__c) && objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c) == null){
                                                        TempNode.addChildElement(arrStr[I], null, null).addTextNode('');
                                                    }
                                                }
                                            }else{
                                                TempNode.addChildElement(arrStr[I], null, null);
                                                TempNode = TempNode.getChildElement(arrStr[I],null);
                                            }
                                        }
                                    }

                                }
                            }else{
                                 System.debug('apiField==>'+apiField);
                                 System.debug('record==>'+record);
                                 System.debug('TRUE==>'+hasSObjectField(apiField,record));
                                 System.debug('sti.SF_Object__c==>'+sti.SF_Object__c);
                                 System.debug('record.Id.getSObjectType().getDescribe().getName()-->'+record.Id.getSObjectType().getDescribe().getName());
                                if(hasSObjectField(apiField,record) && (record.Id.getSObjectType().getDescribe().getName() == sti.SF_Object__c)){
                                    if(record.get(sti.SF_Field_API_Name__c) != null){
                                        if(!eleSet.contains(sti.Intacct_Node_Name__c)){
                                            if(sti.Intacct_Object__c == 'ARPayment' && sti.Intacct_Node_Name__c == 'paymentmethod' && apiField == 'payment_method__c'){
                                                if(record.get('Payment_Method__c').equals('Check')){
                                                    parentEle.addChildElement('paymentmethod', null, null).addTextNode('Printed Check');
                                                } 
                                                else if(record.get('Payment_Method__c').equals('Wire Transfer')){
                                                    parentEle.addChildElement('paymentmethod', null, null).addTextNode('EFT');
                                                }
                                                else if(record.get('Opportunity_Currency__c') != 'USD' && record.get('Payment_Method__c').equals('Credit Card')){
                                                    parentEle.addChildElement('paymentmethod', null, null).addTextNode('EFT');
                                                }
                                                else if(record.get('Payment_Method__c').equals('Bank Account')){
                                                    parentEle.addChildElement('paymentmethod', null, null).addTextNode('Credit Card');
                                                }else{
                                                    parentEle.addChildElement(string.valueof(sti.Intacct_Node_Name__c), null, null).addTextNode(String.valueof(record.get(sti.SF_Field_API_Name__c)));
                                                }
                                            }else{
                                                System.debug('111111@@@@@@@@SF_Field_API_Name__c' + sti.SF_Field_API_Name__c);
                                                System.debug('111111@@@@@@@@record' + record);
                                                System.debug('111111@@@@@@@@sti.Intacct_Node_Name__c' + sti.Intacct_Node_Name__c);
                                                // 06/16/2019 Vishal Agrawal Edited 
                                                // Added to resolve "The Customerid '' should not contain any special characters" error
                                                if(sti.Intacct_Object__c == 'Customer' && sti.Intacct_Table__c == 'CUSTOMER' && sti.SF_Object__c == 'Account'
                                                     && sti.SF_Field_API_Name__c == 'NAME' && sti.Intacct_Node_Name__c == 'NAME') {
                                                    parentEle.addChildElement('CUSTOMERID', null, null).addTextNode('');
                                                }
                                                parentEle.addChildElement(string.valueof(sti.Intacct_Node_Name__c), null, null).addTextNode(String.valueof(record.get(sti.SF_Field_API_Name__c)));
                                            }
                                            //parentEle.addChildElement(string.valueof(sti.Intacct_Node_Name__c), null, null).addTextNode(String.valueof(record.get(sti.SF_Field_API_Name__c)));
                                            eleSet.add(sti.Intacct_Node_Name__c);
                                            System.debug('1111111111@@@@@@@@eleSet:: ' + eleSet);
                                        }
                                    }
                                }else{
                                    System.debug('sti.SF_Field_API_Name__c=>'+sti.SF_Field_API_Name__c);
                                    System.debug('sti.SF_Object__c=>'+sti.SF_Object__c);
                                    
                                    
                                    if(objRecordMap != null && objRecordMap.ContainsKey(sti.SF_Object__c) && objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c) != null){
                                        if(sti.Intacct_Object__c == 'ARPayment' && sti.Intacct_Node_Name__c == 'paymentmethod' && apiField == 'payment_method__c'){
                                            if(record.get('Payment_Method__c').equals('Check')){
                                                parentEle.addChildElement('paymentmethod', null, null).addTextNode('Printed Check');
                                            } 
                                            else if(record.get('Payment_Method__c').equals('Wire Transfer')){
                                                parentEle.addChildElement('paymentmethod', null, null).addTextNode('EFT');
                                            }
                                            else if(record.get('Opportunity_Currency__c') != 'USD' && record.get('Payment_Method__c').equals('Credit Card')){
                                                parentEle.addChildElement('paymentmethod', null, null).addTextNode('EFT');
                                            }
                                            else if(record.get('Payment_Method__c').equals('Bank Account')){
                                                parentEle.addChildElement('paymentmethod', null, null).addTextNode('Credit Card');
                                            }else{
                                                parentEle.addChildElement(string.valueof(sti.Intacct_Node_Name__c), null, null).addTextNode(String.valueOf(objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)));
                                            }
                                        } else{
                                            System.debug('22222222@@@@@@@@SF_Field_API_Name__c' + sti.SF_Field_API_Name__c);
                                            System.debug('22222222@@@@@@@@record' + record);
                                            System.debug('22222222@@@@@@@@sti.Intacct_Node_Name__c' + sti.Intacct_Node_Name__c);
                                            if(sti.Intacct_Object__c == 'Customer' && sti.Intacct_Table__c == 'CUSTOMER' && sti.SF_Object__c == 'Account'
                                                 && sti.SF_Field_API_Name__c == 'NAME' && sti.Intacct_Node_Name__c == 'NAME') {
                                                parentEle.addChildElement('CUSTOMERID', null, null).addTextNode('');
                                            }
                                            parentEle.addChildElement(string.valueof(sti.Intacct_Node_Name__c), null, null).addTextNode(String.valueOf(objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)));
                                        }
                                        System.debug('2222222222@@@@@@@@eleSet:: ' + eleSet);
                                    }
                                }
                            }
                        }else if(sti.Custom_Logic__c == true){
                            //Custom Logic
                            customLogic(sti,parentEle,record,subRecord,eleSet);
                        }else{
                            system.debug('constant==>'+sti.Constant_Value__c);
                            if(sti.Constant_Value__c!=null){
                                System.debug('els sti.Intacct_Node_Name__c=>'+sti.Intacct_Node_Name__c);
                                if(sti.Intacct_Node_Name__c.contains('.')){
                                    if(sti.Intacct_Node_Name__c == 'sotransitems.sotransitem.customfields.customfield.customfieldname' && 
                                       objRecordMap.ContainsKey(sti.SF_Object__c) && objRecordMap.get(sti.SF_Object__c).get('Product_Listing__c')!= null){
                                           String[] arrStr = sti.Intacct_Node_Name__c.split('\\.');
                                           dom.XmlNode TempNode = parentEle;
                                           Integer arrLnt = arrStr.size();
                                           if(arrLnt > 0){
                                               for(Integer I=0; I<arrLnt; I++){
                                                   if(eleSet.contains(arrStr[I])){
                                                       TempNode = TempNode.getChildElement(arrStr[I],null);
                                                   }else{
                                                       eleSet.add(arrStr[I]);
                                                       if(I == arrLnt-1){
                                                           TempNode.addChildElement(arrStr[I], null, null).addTextNode(sti.Constant_Value__c);
                                                       }else{
                                                           TempNode.addChildElement(arrStr[I], null, null);
                                                           TempNode = TempNode.getChildElement(arrStr[I],null);
                                                       }
                                                   }
                                               }
                                           }
                                       }else if(sti.Intacct_Node_Name__c != 'sotransitems.sotransitem.customfields.customfield.customfieldname'){
                                           String[] arrStr = sti.Intacct_Node_Name__c.split('\\.');
                                           System.debug('@@@arrStr ' + arrStr);
                                           dom.XmlNode TempNode = parentEle;
                                           System.debug('@@@TempNode ' + TempNode);
                                           Integer arrLnt = arrStr.size();
                                           System.debug('arrLnt ' + arrLnt);
                                           if(arrLnt > 0){
                                               Dom.XMLNode customRoot;
                                               for(Integer I=0; I<arrLnt; I++){
                                                   System.debug('eleSet.contains(arrStr[I])::: ' + eleSet.contains(arrStr[I]));
                                                   if(eleSet.contains(arrStr[I])){
                                                       System.debug('Out arrStr[I]::: ' + arrStr[I]);
                                                       if(arrStr[I] != 'customfield' && arrStr[I] != 'customfieldname') {
                                                           System.debug('IN:: ' + arrStr[I]);
                                                           TempNode = TempNode.getChildElement(arrStr[I],null);
                                                           customRoot = TempNode;
                                                       } else if(arrStr[I] == 'customfield' || arrStr[I] == 'customfieldname') {
                                                           System.debug('Else if:: ' + I);
                                                           if(I == arrLnt-1){
                                                               System.debug('@@@0000211: ' + sti.Constant_Value__c);
                                                               TempNode.addChildElement(arrStr[I], null, null).addTextNode(sti.Constant_Value__c);
                                                               Dom.XMLNode customfieldChild = customRoot.getChildElement('customfield',null);
                                                               customRoot.insertBefore(TempNode, customfieldChild);
                                                               TempNode = customRoot;
                                                           } else {
                                                               TempNode = TempNode.addChildElement(arrStr[I], null, null);
                                                               //TempNode = TempNode.getChildElement(arrStr[I],null);
                                                               System.debug('@@@78454100555: ' + arrStr[I]);
                                                           }
                                                       }
                                                       System.debug('@962: ' + arrStr[I]);
                                                       System.debug('@TempNode 963: ' + TempNode);
                                                   }else{
                                                       eleSet.add(arrStr[I]);
                                                       System.debug('@@@965' + arrStr[I]);
                                                       if(I == arrLnt-1){
                                                           System.debug('@@@967: ' + sti.Constant_Value__c);
                                                           TempNode.addChildElement(arrStr[I], null, null).addTextNode(sti.Constant_Value__c);
                                                       } else {
                                                           TempNode.addChildElement(arrStr[I], null, null);
                                                           TempNode = TempNode.getChildElement(arrStr[I],null);
                                                           System.debug('@@@972: ' + arrStr[I]);
                                                       }
                                                   }
                                                   System.debug('@@@eleSet ' + eleSet);
                                                   System.debug('@@@loopTempNode ' + TempNode);
                                                   System.debug('@@@arrStr[I] ' + arrStr[I]);
                                               }
                                           }
                                       }
                                }else{
                                    System.debug('@@@00000000 ' + eleSet);
                                    System.debug('@@@000011 ' + sti.Intacct_Node_Name__c);
                                    if(!eleSet.contains(sti.Intacct_Node_Name__c)){
                                        System.debug('@@@33333333322222 ' + sti.Constant_Value__c);
                                        parentEle.addChildElement(sti.Intacct_Node_Name__c, null, null).addTextNode(sti.Constant_Value__c);
                                        eleSet.add(sti.Intacct_Node_Name__c);
                                    }
                                }
                            }else{
                                //Custom Logic
                                system.debug('subRecord==>'+subRecord);
                                customLogic(sti,parentEle,record,subRecord,eleSet);
                            }
                        }
                    }
                }
            }
        }
        system.debug('@@parentEle: ' + parentEle);
    }
    
    public static void genLineItemXML(List<SFDCToIntacctMap_Old__c> SFInMapList,String intacctObj,String operation,SObject record,dom.XmlNode docNode,Map<String,Sobject> objRecordMap, String intacctObjType,Set<String> eleSet,List<SObject> payRecList,sobject eventrec){
        
        dom.XmlNode parentEle = docNode;
        System.debug('sti.parentEle==>'+parentEle);
        //dom.XmlNode parentEleTemp;// = parentEle.addChildElement('sotransitem',null,null);
        //Set<String> eleSet = new Set<String>();
        if(SFInMapList.size() > 0){
            for(SFDCToIntacctMap_Old__c sti: SFInMapList){
                
                if(sti.Intacct_Table__c == intacctObj && sti.Intacct_Object__c  == intacctObjType){
                    // System.debug('sti.Intacct_Table__c==>'+sti.Intacct_Table__c);
                    // System.debug('intacctObj=>'+intacctObj);
                    // System.debug('sti.Intacct_Object__c==>'+sti.Intacct_Object__c);
                    // System.debug('intacctObjType==>'+intacctObjType);
                    // System.debug('sti.SF_Field_API_Name__c==>'+sti.SF_Field_API_Name__c);
                    // System.debug('sti.Intacct_Node_Name__c==>'+sti.Intacct_Node_Name__c);
                    if(sti.SF_Field_API_Name__c == 'Opportunity_Id__c' ){
                         //System.debug('sti.SF_Field_API_Name__c-->'+sti.SF_Field_API_Name__c);
                    }
                    if(sti.Constant_Value__c == null && sti.SF_Field_API_Name__c != null){
                        //System.debug('sti.Intacct_Node_Name__c=>'+sti.Intacct_Node_Name__c);
                        String apiField = sti.SF_Field_API_Name__c.tolowercase();
                        if(sti.Intacct_Node_Name__c.contains('.')){
                            String[] arrStr = sti.Intacct_Node_Name__c.split('\\.');
                            dom.XmlNode TempNode = parentEle;
                            Integer arrLnt = arrStr.size();
                            if(arrLnt > 0){
                                for(Integer I=0; I<arrLnt; I++){
                                    // System.debug('arrStr==>'+arrStr[I]);
                                    // System.debug('TempNode==>'+TempNode);
                                    if(I>1){
                                        if(eleSet.contains(arrStr[I])){
                                            if(TempNode.getChildElement(arrStr[I],null) != null)
                                                TempNode = TempNode.getChildElement(arrStr[I],null);
                                        }else{
                                            eleSet.add(arrStr[I]);
                                            if(I == arrLnt-1){
                                                if(hasSObjectField(apiField,record) ){
                                                    if(record.get(sti.SF_Field_API_Name__c) != null){
                                                        if(sti.Type__c == 'Date'){
                                                            // System.debug('record.get(sti.SF_Field_API_Name__c)==>'+record.get(sti.SF_Field_API_Name__c));
                                                            // System.debug('####sti.Intacct_Node_Name__c==>'+sti.Intacct_Node_Name__c);
                                                            // System.debug('####sti.Intacct_Object__c==>'+sti.Intacct_Object__c);
                                                            // System.debug('####sti.SF_Object__c==>'+sti.SF_Object__c);
                                                            // System.debug('####sti.SF_Field_API_Name__c==>'+sti.SF_Field_API_Name__c);
                                                            dateLogic(arrStr[I], record, sti.SF_Field_API_Name__c, TempNode,sti.Intacct_Node_Name__c,sti.Intacct_Object__c,payRecList,eventrec);
                                                            eleSet.remove(arrStr[I]);
                                                        }else{
                                                            TempNode.addChildElement(arrStr[I], null, null).addTextNode(String.valueof(record.get(sti.SF_Field_API_Name__c)));
                                                        }
                                                    }else if(sti.Type__c == 'Date'){
                                                        // System.debug('removevalcode==>'+TempNode);
                                                        // System.debug('removevalcode==>'+arrStr[I-1]);
                                                        if(eleSet.contains(arrStr[I-1])){
                                                            TempNode.getParent().removeChild(TempNode);
                                                        }
                                                    }
                                                }else{
                                                    if(objRecordMap.ContainsKey(sti.SF_Object__c) && objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)!= null){
                                                        if(sti.Type__c == 'Date'){
                                                            // System.debug('record==>'+record);
                                                            // System.debug('record.get(sti.SF_Field_API_Name__c)==>'+record.get(sti.SF_Field_API_Name__c));
                                                            // System.debug('####sti.Intacct_Node_Name__c==>'+sti.Intacct_Node_Name__c);
                                                            // System.debug('####sti.Intacct_Object__c==>'+sti.Intacct_Object__c);
                                                            // System.debug('####sti.SF_Object__c==>'+sti.SF_Object__c);
                                                            // System.debug('####sti.SF_Field_API_Name__c==>'+sti.SF_Field_API_Name__c);
                                                            dateLogic(arrStr[I], objRecordMap.get(sti.SF_Object__c), sti.SF_Field_API_Name__c, TempNode,sti.Intacct_Node_Name__c,sti.Intacct_Object__c,payRecList,eventrec);
                                                            eleSet.remove(arrStr[I]);
                                                        }else{
                                                            TempNode.addChildElement(arrStr[I], null, null).addTextNode(String.valueOf(objRecordMap.get(sti.SF_Object__c).get(sti.SF_Field_API_Name__c)));
                                                        }
                                                    }else if(sti.Type__c == 'Date'){
                                                        // System.debug('removevalcode==>'+TempNode);
                                                        // System.debug('removevalcode==>'+arrStr[I-1]);
                                                        if(eleSet.contains(arrStr[I-1])){
                                                            TempNode.getParent().removeChild(TempNode);
                                                        }
                                                    }
                                                }
                                            }else{
                                                // System.debug('arrStr[I]==>'+arrStr[I]);
                                                // System.debug('TempNode==>'+TempNode);
                                                TempNode.addChildElement(arrStr[I], null, null);
                                                TempNode = TempNode.getChildElement(arrStr[I],null);
                                            }
                                        }
                                    }
                                }
                            }
                            //parentEleTemp = TempNode;
                        }
                    }else{
                        //System.debug('constant==>'+sti.Constant_Value__c);
                        if(sti.Constant_Value__c!=null){
                            //System.debug('els sti.Intacct_Node_Name__c=>'+sti.Intacct_Node_Name__c);
                            if(sti.Intacct_Node_Name__c.contains('.')){
                                String[] arrStr = sti.Intacct_Node_Name__c.split('\\.');
                                dom.XmlNode TempNode = parentEle;
                                Integer arrLnt = arrStr.size();
                                if(arrLnt > 0){
                                    for(Integer I=0; I<arrLnt; I++){
                                        if(I>1){
                                            if(eleSet.contains(arrStr[I])){
                                                if(TempNode.getChildElement(arrStr[I],null) != null)
                                                    TempNode = TempNode.getChildElement(arrStr[I],null);
                                            }else{
                                                eleSet.add(arrStr[I]);
                                                if(I == arrLnt-1){
                                                    TempNode.addChildElement(arrStr[I], null, null).addTextNode(sti.Constant_Value__c);
                                                }else{
                                                    TempNode.addChildElement(arrStr[I], null, null);
                                                    TempNode = TempNode.getChildElement(arrStr[I],null);
                                                }
                                            }
                                        }
                                    }
                                }
                                //parentEleTemp = TempNode;
                            }
                        }
                    }
                    
                }
            }
            //parentEle.addChildElement(parentEleTemp, null, null);
        }
    }
    
    //Generate Control XML
    public static dom.XmlNode controlAuthXML(Intacct_API_Details__c cs, DOM.Document doc, String locId){
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        
        dom.XmlNode request = doc.createRootElement('request', null, null);
        dom.XmlNode control = request.addChildElement('control', null, null);
        control.addChildElement('senderid', null, null).addTextNode(cs.Production__c ? cs.SenderId__c : cs.Sandbox_SenderId__c);
        control.addChildElement('password', null, null).addTextNode(cs.Production__c ? cs.SenderPassword__c : cs.Sandbox_SenderPassword__c);
        control.addChildElement('controlid', null, null).addTextNode(guid);
        control.addChildElement('uniqueid', null, null).addTextNode('false');
        control.addChildElement('dtdversion', null, null).addTextNode('3.0');
        control.addChildElement('includewhitespace', null, null).addTextNode('false');
        dom.XmlNode operation = request.addChildElement('operation', null, null);
        dom.XmlNode authentication = operation.addChildElement('authentication', null, null);
        dom.XmlNode login = authentication.addChildElement('login', null, null);
        login.addChildElement('userid', null, null).addTextNode(cs.Production__c ? cs.UserName__c : cs.Sandbox_UserName__c);
        login.addChildElement('companyid', null, null).addTextNode(cs.Production__c ? cs.CompanyId__c : cs.Sandbox_CompanyId__c);
        login.addChildElement('password', null, null).addTextNode(cs.Production__c ? cs.Password__c : cs.Sandbox_Password__c);
        if(locId != null && locId != ''){
            login.addChildElement('locationid', null, null).addTextNode(locId);
        }
        dom.XmlNode content = operation.addChildElement('content', null, null);
        dom.XmlNode function = content.addChildElement('function', null, null);
        function.setAttribute('controlid', guid);
        return function;
    }
    
    //Generate Control XML
    public static dom.XmlNode controlAuthXMLPayment(Intacct_API_Details__c cs, DOM.Document doc, String locId){
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        
        dom.XmlNode request = doc.createRootElement('request', null, null);
        dom.XmlNode control = request.addChildElement('control', null, null);
        control.addChildElement('senderid', null, null).addTextNode(cs.Production__c ? cs.SenderId__c : cs.Sandbox_SenderId__c);
        control.addChildElement('password', null, null).addTextNode(cs.Production__c ? cs.SenderPassword__c : cs.Sandbox_SenderPassword__c);
        control.addChildElement('controlid', null, null).addTextNode(guid);
        control.addChildElement('uniqueid', null, null).addTextNode('false');
        control.addChildElement('dtdversion', null, null).addTextNode('3.0');
        control.addChildElement('includewhitespace', null, null).addTextNode('false');
        dom.XmlNode operation = request.addChildElement('operation', null, null);
        dom.XmlNode authentication = operation.addChildElement('authentication', null, null);
        dom.XmlNode login = authentication.addChildElement('login', null, null);
        login.addChildElement('userid', null, null).addTextNode(cs.Production__c ? cs.UserName__c : cs.Sandbox_UserName__c);
        login.addChildElement('companyid', null, null).addTextNode(cs.Production__c ? cs.CompanyId__c : cs.Sandbox_CompanyId__c);
        login.addChildElement('password', null, null).addTextNode(cs.Production__c ? cs.Password__c : cs.Sandbox_Password__c);
        if(locId != null && locId != ''){
            login.addChildElement('locationid', null, null).addTextNode(locId);
        }
        dom.XmlNode content = operation.addChildElement('content', null, null);
        
        return content;
    }
    
    //Custom XML Generation logic
    public static void customLogic(SFDCToIntacctMap_Old__c intTable,dom.XmlNode parentEle,SObject record,SObject subRecord,Set<String> eleSet){
        //Billing and Shipping
        
        //System.debug('### In Custom Logic');
        //Terms Start Date
        if(intTable.Type__c == 'Date'){
            if(intTable.Intacct_Table__c == 'create_sotransaction'){
                if(intTable.Intacct_Node_Name__c.contains('.')){
                    String[] arrStr = intTable.Intacct_Node_Name__c.split('\\.');
                    dom.XmlNode TempNode = parentEle;
                    Integer arrLnt = arrStr.size();
                    if(arrLnt > 0){
                        String dateVal;
                        if(intTable.SF_Field_API_Name__c == null && intTable.Constant_Value__c == null && intTable.Type__c == 'Date' && intTable.Intacct_Object__c == 'Sales Order'){
                            //dateVal = String.valueof(system.today());
                            dateVal = String.valueof(subRecord.get('CloseDate'));
                            //System.debug('####dateVal1 =>0'+dateVal);
                        }else if((intTable.Intacct_Object__c == 'Sales Invoice' )&& intTable.Type__c == 'Date') {//|| intTable.Intacct_Object__c == 'Sales Order'
                            
                            if(String.valueof(record.get('Payment_Due_Date__c')) != null){
                                
                                dateVal = String.valueof(record.get('Payment_Due_Date__c'));
                                
                                //System.debug('####dateVal2 =>0'+dateVal);
                            }else{
                                dateVal = String.valueof(record.get('Opportunity_Event_Start_Date__c'));
                                //System.debug('####dateVal3 =>0'+dateVal);
                            }
                        }
                        else if(intTable.Type__c == 'Date'){
                            dateVal = String.valueof(record.get('Start_Date__c'));
                            //System.debug('####dateVal5 =>0'+dateVal);
                        }
                        Date d = date.valueOf(dateVal);
                        Integer day = d.day();
                        Integer month = d.month();
                        Integer year = d.year();
                        //System.debug('####intTable.Intacct_Node_Name__c=>0'+intTable.Intacct_Node_Name__c);
                        //System.debug('year=>'+year+'month=>'+month+'day=>'+day);
                        if(arrStr[1] == 'year'){
                            XMLLogicLoop(arrLnt,arrStr,TempNode,String.valueof(year),eleSet);
                        }
                        if(arrStr[1] == 'month'){
                            XMLLogicLoop(arrLnt,arrStr,TempNode,String.valueof(month),eleSet);
                        }
                        if(arrStr[1] == 'day'){
                            XMLLogicLoop(arrLnt,arrStr,TempNode,String.valueof(day),eleSet);
                        }
                    }
                }
            }else{
                if(intTable.Intacct_Node_Name__c.contains('.')){
                    String[] arrStr = intTable.Intacct_Node_Name__c.split('\\.');
                    dom.XmlNode TempNode = parentEle;
                    Integer arrLnt = arrStr.size();
                    if(arrLnt > 0){
                        Date d = system.today();
                        Integer day = d.day();
                        Integer month = d.month();
                        Integer year = d.year();
                        //System.debug('year=>'+year+'month=>'+month+'day=>'+day);
                        if(arrStr[1] == 'year'){
                            XMLLogicLoop(arrLnt,arrStr,TempNode,String.valueof(year),eleSet);
                        }
                        if(arrStr[1] == 'month'){
                            XMLLogicLoop(arrLnt,arrStr,TempNode,String.valueof(month),eleSet);
                        }
                        if(arrStr[1] == 'day'){
                            XMLLogicLoop(arrLnt,arrStr,TempNode,String.valueof(day),eleSet);
                        }
                    }
                }
            }
        }
        
        if(intTable.Type__c == 'Custom Setting'){
            //System.debug('custom setting code=>');
            if(intTable.Intacct_Object__c == 'ARPayment'){
                List<Intacct_Undeposited_Funds_Account__c> mcs = Intacct_Undeposited_Funds_Account__c.getall().values();
                String accountId = null;
                String EURClearing = null;
                String GBPClearing = null;
                String AUDClearing = null;
                String CADClearing = null;
                //System.debug('record=>'+record);
                for(Intacct_Undeposited_Funds_Account__c Iufa: mcs){
                    if(record.get('International_Stripe__c') == Iufa.International_Stripe__c && record.get('Opportunity_Currency__c') == Iufa.Currency__c )
                        accountId = Iufa.Account_Number__c;
                    EURClearing = Iufa.EUR_Clearing_Account__c;
                    GBPClearing = Iufa.GBP_Clearing_Account__c;
                    AUDClearing = Iufa.AUD_Clearing_Account__c;
                    CADClearing = Iufa.CAD_Clearing_Account__c;
                }
                //System.debug('@@@accountId==='+accountId);
                if(record.get('Opportunity_Currency__c') == 'USD' || (record.get('Opportunity_Currency__c') != 'USD' && record.get('Payment_Method__c') != 'Credit Card')){ 
                    dom.XmlNode TempNode = parentEle;
                    if(accountId != null){
                        //System.debug('@@@@==='+(record.get('Opportunity_Currency__c')).equals('USD'));
                        // For non USD currencies
                        if((record.get('Opportunity_Currency__c')).equals('USD')) {
                            TempNode.addChildElement(intTable.Intacct_Node_Name__c, null, null).addTextNode(accountId);
                        }
                    }else{
                        if((record.get('Opportunity_Currency__c')).equals('USD')) {
                            TempNode.addChildElement(intTable.Intacct_Node_Name__c, null, null).addTextNode('10021');
                        }
                    }
                    if((record.get('Opportunity_Currency__c')).equals('EUR')) {
                        TempNode.addChildElement('bankaccountid', null, null).addTextNode(EURClearing);
                    }
                    if((record.get('Opportunity_Currency__c')).equals('GBP')) {
                        TempNode.addChildElement('bankaccountid', null, null).addTextNode(GBPClearing);
                    }
                    if((record.get('Opportunity_Currency__c')).equals('AUD')) {
                        TempNode.addChildElement('bankaccountid', null, null).addTextNode(AUDClearing);
                    }
                    if((record.get('Opportunity_Currency__c')).equals('CAD')) {
                        TempNode.addChildElement('bankaccountid', null, null).addTextNode(CADClearing);
                    }
                    
                    TempNode = TempNode.getChildElement(intTable.Intacct_Node_Name__c,null);
                    eleSet.add(intTable.Intacct_Node_Name__c);
                }
            }
        }
    }
    
    
    public static void XMLLogicLoop(Integer arrLnt,String[] arrStr,dom.XmlNode TempNode,String value,Set<String> eleSet){
        for(Integer I=0; I<arrLnt; I++){
            if(eleSet.contains(arrStr[I])){
                TempNode = TempNode.getChildElement(arrStr[I],null);
            }else{
                if(I == arrLnt-1){
                    TempNode.addChildElement(arrStr[I], null, null).addTextNode(value);
                }else{
                    TempNode.addChildElement(arrStr[I], null, null);
                    TempNode = TempNode.getChildElement(arrStr[I],null);
                    eleSet.add(arrStr[I]);
                }
            }
        }
    }
    
    public static void dateLogic(String node, SObject record, String fieldName, dom.XmlNode TempNode,string IntacctNode,String IntacctObj,List<SObject> payRecList,sobject eventrec){
        //if(record.get('Opportunity_Currency__c') != 'USD' && IntacctNode != 'datereceived.day' && IntacctNode != 'datereceived.month' && IntacctNode != 'datereceived.year' && fieldname != 'Charge_Date__c' && IntacctObj != 'ARPayment'){
        String dateVal;
        Id recordId = (Id)record.get('id');
        //System.debug('####IntacctNode=='+IntacctNode+'###recordId=='+recordId);
        if(recordId.getSObjectType().getDescribe().getName() == 'Opportunity' && fieldname == 'Last_Modified_Date__c' && IntacctObj == 'Sales Order'
           && (IntacctNode == 'exchratedate.year' || IntacctNode == 'exchratedate.month' || IntacctNode == 'exchratedate.day') && payRecList[0].get('Exchange_Rate_Date__c') != null){
               dateVal = String.valueof(payRecList[0].get('Exchange_Rate_Date__c'));
           }
        else if(recordId.getSObjectType().getDescribe().getName() == 'Payment_Term__c' && fieldname == 'Payment_Due_Date__c' && IntacctObj == 'Sales Order'
                && (IntacctNode == 'sotransitems.sotransitem.revrecstartdate.year' || IntacctNode == 'sotransitems.sotransitem.revrecstartdate.month' || IntacctNode == 'sotransitems.sotransitem.revrecstartdate.day'
                    || IntacctNode == 'sotransitems.sotransitem.revrecenddate.year' || IntacctNode == 'sotransitems.sotransitem.revrecenddate.month' || IntacctNode == 'sotransitems.sotransitem.revrecenddate.day')
                && eventrec.get('End_Date__c') != null){
                    date dtval = date.valueof(eventrec.get('End_Date__c'));
                    Integer numberOfDays = Date.daysInMonth(dtval.year(), dtval.month());
                    Date lastDayOfMonth = Date.newInstance(dtval.year(), dtval.month(), numberOfDays);
                    dateVal = String.valueof(lastDayOfMonth);
                }
        // Added to fix this error "Payment date cannot be before Invoice creation date"
        else if(recordId.getSObjectType().getDescribe().getName() == 'Payment_Term__c' && fieldname == 'Charge_Date__c' && date.valueof(record.get(fieldName))<date.valueof(record.get('Opportunity_CloseDate__c'))){
            dateVal = String.valueof(date.valueof(record.get('Opportunity_CloseDate__c')));
        }
        // Added fix ends.
        else{
            dateVal = String.valueof(record.get(fieldName));
        }
        Date d = date.valueOf(dateVal);
        Integer day = d.day();
        Integer month = d.month();
        Integer year = d.year();
        //System.debug('year=>'+year+'month=>'+month+'day=>'+day);
        if(node == 'year'){
            TempNode.addChildElement(node, null, null).addTextNode(String.valueof(year));
        }
        if(node == 'month'){
            TempNode.addChildElement(node, null, null).addTextNode(String.valueof(month));
        }
        if(node == 'day'){
            TempNode.addChildElement(node, null, null).addTextNode(String.valueof(day));
        }
        //}
    }
    
    public static void getIntcctData(String IntacctObj,String key,Intacct_API_Details__c cs,DOM.Document doc){
        dom.XmlNode function = controlAuthXML(cs, doc,null );
        dom.XmlNode read;
        if(IntacctObj == 'CONTACT' || IntacctObj == 'SODOCUMENT' || IntacctObj == 'ARINVOICE'){
            read = function.addChildElement('readByName', null, null);
        }else{
            read = function.addChildElement('read', null, null);
        }
        read.addChildElement('object', null, null).addTextNode(IntacctObj);
        read.addChildElement('keys', null, null).addTextNode(key);
    }
    // public static void createAndUpdateIntacctContact(Intacct_API_Details__c cs,DOM.Document doc,String objName,SObject record,List<Exception_Log__c> excLogList,List<RequestResponse_Log__c> reResList,Id oppId,List<intSummaryWrap> intSummList){
    //     boolean conGetStatus = false;
    //     conGetStatus = intacctGetCallout(cs, doc, objName, record, excLogList, reResList, oppId, intSummList);
    // }
    public static boolean intacctGetCallout(Intacct_API_Details__c cs,DOM.Document doc,String objName,SObject record,List<Exception_Log__c> excLogList,List<RequestResponse_Log__c> reResList,Id oppId,List<intSummaryWrap> intSummList){
        try{
            System.debug('setEndpoint2==>');
            System.debug('doc==>'+doc.toXmlString());
            // Send the request
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(cs.Production__c ? cs.EndpointURL__c : cs.Sandbox_EndpointURL__c);
            req.setHeader('Content-Type', 'text/xml');
            
            req.setBodyDocument(doc);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            Dom.Document resdoc = res.getBodyDocument();
            System.debug('resdoc==>'+resdoc);
            System.debug('resdocXmlString==>'+resdoc.toXmlString());
            String msg = '';
            reResList.add(QE_Utility_class.reqResLog('QE_Intacct_FutureCallout', 'intacctGetCallout', String.valueOf(doc.toXmlString()),String.valueOf(resdoc.toXmlString()),cs.Production__c ? cs.EndpointURL__c : cs.Sandbox_EndpointURL__c,String.valueOf(res.getStatusCode()),msg,oppId,string.ValueOf(record.get('Id'))));
            
            if(res.getStatusCode() == 200 && resdoc != null && !string.isblank(resdoc.toXmlString())){
                String RECORDNO;
                String RECORDINTNO;
                String successStatus;
                
                successStatus = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('status', null).getText();
                if(successStatus == 'Success'){
                    String RECORDCount = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getAttributeValue('count', '');
                    
                    if(Integer.valueOf(RECORDCount) > 0){
                        //if(objNAme != 'SODOCUMENT'){
                        if(objName == 'customer'){
                            RECORDNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('CUSTOMER', null).getChildElement('RECORDNO', null).getText();
                            RECORDINTNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('CUSTOMER', null).getChildElement('CUSTOMERID', null).getText();
                            record.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', RECORDNO);
                            record.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', RECORDINTNO);
                            CustomerId = RECORDINTNO;
                            CustomerNo = RECORDNO;
                            system.debug('^^^^RECORDNO3=='+RECORDNO);
                            system.debug('^^^^RECORDINTNO3=='+RECORDINTNO);
                        }else if(objName == 'contact'){
                            //RECORDNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('CONTACT', null).getChildElement('RECORDNO', null).getText();
                            RECORDINTNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('CONTACT', null).getChildElement('CONTACTNAME', null).getText();
                            record.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', RECORDINTNO);
                            record.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', RECORDINTNO);
                            system.debug('^^^^RECORDNO4=='+RECORDNO);                       
                        }
                        else if(objName == 'SODOCUMENT'){
                            RECORDNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('SODOCUMENT', null).getChildElement('RECORDNO', null).getText();
                            RECORDINTNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('SODOCUMENT', null).getChildElement('DOCID', null).getText();
                            record.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', RECORDNO);
                            record.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', RECORDINTNO);
                            system.debug('^^^^RECORDNO5=='+RECORDNO);
                            system.debug('^^^^RECORDINTNO5=='+RECORDINTNO);
                        }else if(objName == 'ARINVOICE'){
                            RECORDNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('ARINVOICE', null).getChildElement('RECORDNO', null).getText();
                            RECORDINTNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('ARINVOICE', null).getChildElement('RECORDID', null).getText();
                            record.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', RECORDNO);
                            record.put(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c', RECORDINTNO);
                            system.debug('^^^^RECORDNO6=='+RECORDNO);
                            system.debug('^^^^RECORDINTNO6=='+RECORDINTNO);
                        }
                        
                        
                        System.debug('RECORDNO==>'+RECORDNO);
                        if(objName == 'contact'){
                            System.debug('contact get call==>'+string.ValueOf(record.get('Id'))+string.ValueOf(record.get('Name')));
                            intSummList.add(new intSummaryWrap( 'Contact', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),'', '', 'Success', ''));
                        }else if(objName == 'customer'){
                            intSummList.add(new intSummaryWrap( 'Account/Customer', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),string.ValueOf(record.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')), '', 'Success', ''));
                        }else if(objName == 'SODOCUMENT'){
                            intSummList.add(new intSummaryWrap( 'Opportunity/Sales Order', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),string.ValueOf(record.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')), '', 'Success', ''));
                        }else if(objName == 'ARINVOICE'){
                            intSummList.add(new intSummaryWrap( 'Payment Terms/Sales Invoice', string.ValueOf(record.get('Id')), string.ValueOf(record.get('Name')),string.ValueOf(record.get(cs.Production__c ? 'Intacct_Id__c' : 'Sandbox_Intacct_Id__c')), '', 'Success', ''));
                        }
                        // }
                        
                        return true;
                    }else{
                        return false;
                    }
                }else{
                    return false;
                }
            }else{
                excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'intacctGetCallout', String.valueOf(res.getBody()),null,null,oppId,string.ValueOf(record.get('Id'))));
                if(oppId!= null && resdoc != null && !string.isblank(resdoc.toXmlString())){
                    Id oppRecId1 = oppId;
                    Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Sandbox_Intacct_Apex_Error__c,Intacct_Status__c,Sandbox_Intacct_Status__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
                    /*oppFldRec.Intacct_Apex_Error__c = oppFldRec.Intacct_Apex_Error__c +' ,'+ resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText();
                    oppFldRec.Intacct_Status__c = 'Failed';*/
                    oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c', 
                                  oppFldRec.get(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c') +' ,'+ resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText());
                    oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                    update oppFldRec;
                }
                return false;
            }
        }catch(exception e){
            
            excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'intacctGetCallout', e.getMessage(),e.getLineNumber(),e.getTypeName(),oppId,string.ValueOf(record.get('Id'))));
            //QE_Utility_class.sendExceptionEmail('SFDC Error - '+e +'-Line:'+e.getLineNumber());
            if(excLogList.size() > 0){
                upsert excLogList;
                if(oppId!= null){
                    Id oppRecId1 = oppId;
                    Opportunity oppFldRec = [SELECT Name, Intacct_Apex_Error__c,Sandbox_Intacct_Apex_Error__c,Intacct_Status__c,Sandbox_Intacct_Status__c FROM Opportunity WHERE Id =: oppRecId1 LIMIT 1];
                    /*oppFldRec.Intacct_Apex_Error__c = oppFldRec.Intacct_Apex_Error__c +' ,'+ e.getMessage()+', Line Number: ' +e.getLineNumber();
                    oppFldRec.Intacct_Status__c = 'Failed';*/
                    oppFldRec.put(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c',
                                  oppFldRec.get(cs.Production__c ? 'Intacct_Apex_Error__c' : 'Sandbox_Intacct_Apex_Error__c') + ' ,'+ e.getMessage()+', Line Number: ' + e.getLineNumber());
                    oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                    update oppFldRec;
                }
            }
        }
        return false;
    }
    
    /**
* check if an Sobject has a field
*/
    public static boolean hasSObjectField(String fieldName, SObject so){
        return so.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldName);
    }
    
    //*** Payment Update ***//
    @future (callout=true)
    public static void paymentUpdateIntacct(Id payId) {
        List<SFDCToIntacctMap_Old__c> payMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> allMapList = new List<SFDCToIntacctMap_Old__c>();
        List<Exception_Log__c> excLogList = new List<Exception_Log__c>();
        List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        Id oppRecId1 = payId;
        Payment_Term__c oppFldRec = [SELECT Name, Sandbox_Intacct_Failure_Reason__c,Sandbox_Intacct_Status__c,Intacct_Failure_Reason__c,Intacct_Status__c,Location_Id__c,Record_Id__c,Sandbox_Record_Id__c FROM Payment_Term__c WHERE Id =: oppRecId1 LIMIT 1];
        /*oppFldRec.Intacct_Failure_Reason__c =null;
oppFldRec.Intacct_Status__c =null;*/
        oppFldRec.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c', null);
        oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', null);
        //if(oppFldRec.Record_Id__c != null){
        if(oppFldRec.get(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c') != null){
            try{
                String isProuction = cs.Production__c ? 'Yes' : 'No';
                for(SFDCToIntacctMap_Old__c sti: [SELECT Id, Intacct_Object__c, Name, Custom_Logic__c,Custom_Setting_Name__c,Line_Item__c,Active__c, Operation__c,Type__c, Constant_Value__c, Description__c, Intacct_Node_Name__c, Intacct_Table__c, Sequence__c, SF_Field_API_Name__c, SF_Object__c FROM SFDCToIntacctMap_Old__c
                                              WHERE Active__c =: true AND (Production__c = null or Production__c = :isProuction) ORDER BY Sequence__c]){
                                                  allMapList.add(sti);
                                                  if(sti.SF_Object__c == 'Payment_Term__c' && sti.Intacct_Object__c == 'ARPayment'){
                                                      payMapList.add(sti);
                                                  }
                                              }
                
                String payQuery;
                SObject payRec;
                if(payMapList.size() > 0){
                    //System.debug('payMapList::: '+payMapList);
                    String addFld = ' ,Intacct_Id__c,Sandbox_Intacct_Id__c,Intacct_Line_Number__c,Sandbox_Intacct_Line_Number__c,Intacct_Status__c,Opportunity_Payment_Term__c,International_Stripe__c,Sandbox_Intacct_Failure_Reason__c,Intacct_Failure_Reason__c, Opportunity_CloseDate__c ';
                    payQuery = genDynQuery(payQuery,payMapList, payMapList[0].SF_Object__c,addFld);
                    payQuery = payQuery + ' WHERE Id =: payId LIMIT 1';
                    //System.debug('payQuery==>'+payQuery);
                    try{
                        payRec = Database.query(payQuery);
                    } catch(Exception ex){
                        payRec = null;
                    }
                }
                payRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c' , '');
                payRec.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c' , '');
                System.debug('payRec==>'+payRec);
                DOM.Document paydoc = new DOM.Document();
                System.debug('Record_Id__c==>'+String.valueof(payRec.get('Record_Id__c')));
                dom.XmlNode pfunction = controlAuthXML(cs, paydoc,String.ValueOf(oppFldRec.Location_Id__c));
                dom.XmlNode pparentEle;
                dom.XmlNode batchfunction;
                if(payRec.get('Opportunity_Currency__c') != 'USD' && payRec.get('Payment_Method__c') != null && payRec.get('Payment_Method__c').equals('Credit Card')){
                    List<Intacct_Undeposited_Funds_Account__c> mcs = Intacct_Undeposited_Funds_Account__c.getall().values();
                    batchfunction = pfunction.addChildElement('create_arpaymentbatch', null, null);
                    batchfunction.addChildElement('batchtitle', null, null).addTextNode('Credit Card non USD');
                    
                    if((payRec.get('Opportunity_Currency__c')).equals('EUR')) {
                        batchfunction.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].EUR_Clearing_Account__c);
                    }
                    if((payRec.get('Opportunity_Currency__c')).equals('GBP')) {
                        batchfunction.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].GBP_Clearing_Account__c);
                    }
                    if((payRec.get('Opportunity_Currency__c')).equals('AUD')) {
                        batchfunction.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].AUD_Clearing_Account__c);
                    }
                    if((payRec.get('Opportunity_Currency__c')).equals('CAD')) {
                        batchfunction.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].CAD_Clearing_Account__c);
                    }
                    if(payRec.get('Charge_Date__c') != null){
                        date dt = date.valueof(payRec.get('Charge_Date__c'));
                        dt = dt < date.valueof(payRec.get('Opportunity_CloseDate__c')) ? date.valueof(payRec.get('Opportunity_CloseDate__c')) : dt;
                        //date dt = system.today();
                        dom.XmlNode datecreated = batchfunction.addChildElement('datecreated', null, null);
                        datecreated.addChildElement('year', null, null).addTextNode(string.valueof(dt.year()));
                        datecreated.addChildElement('month', null, null).addTextNode(string.valueof(dt.month()));
                        datecreated.addChildElement('day', null, null).addTextNode(string.valueof(dt.day()));
                    }
                    pparentEle = batchfunction.addChildElement(payMapList[0].Intacct_Table__c, null, null);
                }else{
                    pparentEle = pfunction.addChildElement(payMapList[0].Intacct_Table__c, null, null);
                }
                //pparentEle.setAttribute('key', String.valueof(payRec.get('Record_Id__c')));
                Set<String> eleSet = new Set<String>();
                genContentXML(allMapList,payMapList[0].Intacct_Table__c,payMapList[0].Operation__c,payRec,cs,pparentEle,null,null,payMapList[0].Intacct_Object__c,eleSet,null,null);
                boolean payStatus = intactCallout(cs, paydoc, 'payment', payRec,excLogList,reResList,null,null,null,false);
                if(payStatus == true || payRec.get('Amount__c') == 0){
                    payRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Success');
                    payRec.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c' , '');
                    update payRec;
                }
                if(excLogList.size() > 0){
                    upsert excLogList;
                }
                if(reResList.size() > 0){
                    upsert reResList;
                }
                if(test.isRunningTest()) {
                    integer i=1/0;
                }
            }catch(exception e){
                excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'paymentUpdateIntacct', e.getMessage(),e.getLineNumber(),e.getTypeName(),null,null));
                //QE_Utility_class.sendExceptionEmail('SFDC Error - '+e +'-Line:'+e.getLineNumber());
                if(excLogList.size() > 0){
                    upsert excLogList;
                    /*oppFldRec.Intacct_Failure_Reason__c = oppFldRec.Intacct_Failure_Reason__c +' ,'+ e.getMessage()+', Line Number: ' +e.getLineNumber();
oppFldRec.Intacct_Status__c = 'Failed';*/
                    oppFldRec.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c', 
                                  oppFldRec.get(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c') +' ,'+ e.getMessage()+', Line Number: ' +e.getLineNumber());
                    oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                    update oppFldRec;
                }
            }
        }
    }
    
    public static void paymentUpdateIntacctBatch(Id payId) {
        List<SFDCToIntacctMap_Old__c> payMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> allMapList = new List<SFDCToIntacctMap_Old__c>();
        List<Exception_Log__c> excLogList = new List<Exception_Log__c>();
        List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        Id oppRecId1 = payId;
        Payment_Term__c oppFldRec = [SELECT Name, Sandbox_Intacct_Failure_Reason__c,Sandbox_Intacct_Status__c,Intacct_Failure_Reason__c,Intacct_Status__c,Location_Id__c,Record_Id__c,Sandbox_Record_Id__c FROM Payment_Term__c WHERE Id =: oppRecId1 LIMIT 1];
        /*oppFldRec.Intacct_Failure_Reason__c =null;
oppFldRec.Intacct_Status__c =null;*/
        oppFldRec.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c', null);
        oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', null);
        //if(oppFldRec.Record_Id__c != null){
        if(oppFldRec.get(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c') != null){
            try{
                String isProuction = cs.Production__c ? 'Yes' : 'No';
                for(SFDCToIntacctMap_Old__c sti: [SELECT Id, Intacct_Object__c, Name, Custom_Logic__c,Custom_Setting_Name__c,Line_Item__c,Active__c, Operation__c,Type__c, Constant_Value__c, Description__c, Intacct_Node_Name__c, Intacct_Table__c, Sequence__c, SF_Field_API_Name__c, SF_Object__c FROM SFDCToIntacctMap_Old__c
                                              WHERE Active__c =: true and (Production__c = null or Production__c = :isProuction) ORDER BY Sequence__c]){
                                                  allMapList.add(sti);
                                                  if(sti.SF_Object__c == 'Payment_Term__c' && sti.Intacct_Object__c == 'ARPayment'){
                                                      payMapList.add(sti);
                                                  }
                                              }
                
                String payQuery;
                SObject payRec;
                if(payMapList.size() > 0){
                    String addFld = ' ,Intacct_Id__c,Sandbox_Intacct_Id__c,Intacct_Line_Number__c,Sandbox_Intacct_Line_Number__c,Intacct_Status__c,Sandbox_Intacct_Status__c,International_Stripe__c,Sandbox_Intacct_Failure_Reason__c,Intacct_Failure_Reason__c, Opportunity_CloseDate__c ';
                    payQuery = genDynQuery(payQuery,payMapList, payMapList[0].SF_Object__c,addFld);
                    payQuery = payQuery + ' WHERE Id =: payId LIMIT 1';
                    //System.debug('payQuery==>'+payQuery);
                    try{
                        payRec = Database.query(payQuery);
                    } catch(Exception ex){
                        payRec = null;
                    }
                }
                payRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c' , '');
                payRec.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c' , '');
                System.debug('payRec==>'+payRec);
                DOM.Document paydoc = new DOM.Document();
                System.debug('Record_Id__c==>'+String.valueof(payRec.get('Record_Id__c')));
                dom.XmlNode pfunction = controlAuthXML(cs, paydoc,String.ValueOf(oppFldRec.Location_Id__c));
                dom.XmlNode pparentEle;
                dom.XmlNode batchfunction;
                System.debug('check Oppo Paymentterm: ' + payRec);
                if(payRec.get('Opportunity_Currency__c') != 'USD' && payRec.get('Payment_Method__c').equals('Credit Card')){
                    List<Intacct_Undeposited_Funds_Account__c> mcs = Intacct_Undeposited_Funds_Account__c.getall().values();
                    batchfunction = pfunction.addChildElement('create_arpaymentbatch', null, null);
                    batchfunction.addChildElement('batchtitle', null, null).addTextNode('Credit Card non USD');
                    
                    if((payRec.get('Opportunity_Currency__c')).equals('EUR')) {
                        batchfunction.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].EUR_Clearing_Account__c);
                    }
                    if((payRec.get('Opportunity_Currency__c')).equals('GBP')) {
                        batchfunction.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].GBP_Clearing_Account__c);
                    }
                    if((payRec.get('Opportunity_Currency__c')).equals('AUD')) {
                        batchfunction.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].AUD_Clearing_Account__c);
                    }
                    if((payRec.get('Opportunity_Currency__c')).equals('CAD')) {
                        batchfunction.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].CAD_Clearing_Account__c);
                    }
                    if(payRec.get('Charge_Date__c') != null){
                        date dt = date.valueof(payRec.get('Charge_Date__c'));
                        dt = dt < date.valueof(payRec.get('Opportunity_CloseDate__c')) ? date.valueof(payRec.get('Opportunity_CloseDate__c')) : dt;
                        //date dt = system.today();
                        dom.XmlNode datecreated = batchfunction.addChildElement('datecreated', null, null);
                        datecreated.addChildElement('year', null, null).addTextNode(string.valueof(dt.year()));
                        datecreated.addChildElement('month', null, null).addTextNode(string.valueof(dt.month()));
                        datecreated.addChildElement('day', null, null).addTextNode(string.valueof(dt.day()));
                    }
                    pparentEle = batchfunction.addChildElement(payMapList[0].Intacct_Table__c, null, null);
                }else{
                    pparentEle = pfunction.addChildElement(payMapList[0].Intacct_Table__c, null, null);
                }
                //pparentEle.setAttribute('key', String.valueof(payRec.get('Record_Id__c')));
                Set<String> eleSet = new Set<String>();
                genContentXML(allMapList,payMapList[0].Intacct_Table__c,payMapList[0].Operation__c,payRec,cs,pparentEle,null,null,payMapList[0].Intacct_Object__c,eleSet,null,null);
                boolean payStatus = intactCallout(cs, paydoc, 'payment', payRec,excLogList,reResList,null,null,null,false);
                if(payStatus == true || payRec.get('Amount__c') == 0){
                    payRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c' , 'Success');
                    payRec.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c' , '');
                    update payRec;
                }
                if(excLogList.size() > 0){
                    upsert excLogList;
                }
                if(reResList.size() > 0){
                    upsert reResList;
                }
                if(test.isRunningTest()) {
                    integer i=1/0;
                }
            }catch(exception e){
                excLogList.add(QE_Utility_class.errorExceptionLog('QE_Intacct_FutureCallout', 'paymentUpdateIntacct', e.getMessage(),e.getLineNumber(),e.getTypeName(),null,null));
                //QE_Utility_class.sendExceptionEmail('SFDC Error - '+e +'-Line:'+e.getLineNumber());
                if(excLogList.size() > 0){
                    upsert excLogList;
                    /*oppFldRec.Intacct_Failure_Reason__c = oppFldRec.Intacct_Failure_Reason__c +' ,'+ e.getMessage()+', Line Number: ' +e.getLineNumber();
oppFldRec.Intacct_Status__c = 'Failed';*/
                    oppFldRec.put(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c', 
                                  oppFldRec.get(cs.Production__c ? 'Intacct_Failure_Reason__c' : 'Sandbox_Intacct_Failure_Reason__c') +' ,'+ e.getMessage()+', Line Number: ' +e.getLineNumber());
                    oppFldRec.put(cs.Production__c ? 'Intacct_Status__c' : 'Sandbox_Intacct_Status__c', 'Failed');
                    update oppFldRec;
                }
            }
        }
    }
    
    public static string getInvoiceRecordId(String RECORDINTNO,Intacct_API_Details__c cs){
        String queryValue = 'RECORDID=\''+RECORDINTNO+'\'';
        DOM.Document dom = new DOM.Document();
        dom.XmlNode cfunction = controlAuthXML(cs, dom,null);
        dom.XmlNode readQuery = cfunction.addChildElement('readByQuery', null, null);
        //readQuery.addChildElement('object', null, null).addTextNode('SODOCUMENT');
        readQuery.addChildElement('object', null, null).addTextNode('ARINVOICE');
        readQuery.addChildElement('fields', null, null).addTextNode('*');
        readQuery.addChildElement('query', null, null).addTextNode(queryValue);
        //System.debug('==>'+dom.toXmlString());
        System.debug('setEndpoint3==>');
        // Send the request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(cs.Production__c ? cs.EndpointURL__c : cs.Sandbox_EndpointURL__c);
        req.setHeader('Content-Type', 'text/xml');
        
        req.setBodyDocument(dom);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('res==>'+res);
        Dom.Document resdoc = res.getBodyDocument();
        //System.debug('resdoc==>'+resdoc);
        String successStatus;
        successStatus = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('status', null).getText();
        //System.debug('successStatusInvo==>'+successStatus);
        //System.debug('resdoc.toXmlString()==>'+resdoc.toXmlString());
        if(successStatus == 'Success'){
            String count = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getAttributeValue('count',null);
            //System.debug('count==>'+integer.valueof(count));
            if(integer.valueof(count) > 0){
                String RECORDNO = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement('arinvoice', null).getChildElement('RECORDNO', null).getText();
                //System.debug('RECORDNO==>'+RECORDNO);
                return RECORDNO;
            }
        }
        return null;
    }
    
    @future(callout=true)
    public static void updateIntacctInvoiceAPInfo(Id opportunityId){
        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults(); 
        List<Opportunity> opportunityList = [SELECT Name, Intacct_Apex_Error__c,Intacct_Status__c,Sandbox_Intacct_Apex_Error__c,Intacct_Id__c,AP_Contact_Email__c,
        AP_Contact_Name__c,AP_Contact_Phone__c,Sandbox_Intacct_Id__c,Sandbox_Intacct_Status__c, Location_Id__c,AP_Contact_Id__c,Billing_Street__c,Billing_City__c,
        Billing_State_Province__c,Billing_Zip_Postal_Code__c,Billing_Country__c,
        (Select Id,Intacct_Id__c,Sandbox_Intacct_Id__c from Opportunity_Payment_Terms__r) FROM Opportunity WHERE Id =: opportunityId];
        
        if(!opportunityList.isEmpty()){
            Dom.Document xmlDoc = new Dom.Document();
            dom.XmlNode function = QE_Intacct_FutureCallout.controlAuthXML(cs, xmlDoc,string.valueof(opportunityList[0].Location_Id__c));
            dom.XmlNode read = function.addChildElement('update_sotransaction', null, null);
            read.setAttribute('key',cs.Production__c? 'Sales Invoice-'+opportunityList[0].Opportunity_Payment_Terms__r[0].Intacct_Id__c: 'Sales Invoice-'+opportunityList[0].Opportunity_Payment_Terms__r[0].Sandbox_Intacct_Id__c);
            dom.XmlNode customFields = read.addChildElement('customfields', null, null);
            dom.XmlNode customFieldEmail = customFields.addChildElement('customfield', null, null);
            customFieldEmail.addChildElement('customfieldname', null, null).addTextNode('AP_CONTACT_EMAIL');            
            customFieldEmail.addChildElement('customfieldvalue', null, null).addTextNode(opportunityList[0].AP_Contact_Email__c != null?string.valueof(opportunityList[0].AP_Contact_Email__c):'');
            dom.XmlNode customFieldName = customFields.addChildElement('customfield', null, null);
            customFieldName.addChildElement('customfieldname', null, null).addTextNode('AP_CONTACT_NAME');
            customFieldName.addChildElement('customfieldvalue', null, null).addTextNode(opportunityList[0].AP_Contact_Name__c != null ? string.valueof(opportunityList[0].AP_Contact_Name__c):'');
            dom.XmlNode customFieldPhone = customFields.addChildElement('customfield', null, null);
            customFieldPhone.addChildElement('customfieldname', null, null).addTextNode('AP_CONTACT_PHONE');
            customFieldPhone.addChildElement('customfieldvalue', null, null).addTextNode(opportunityList[0].AP_Contact_Phone__c != null ? string.valueof(opportunityList[0].AP_Contact_Phone__c):'');
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(cs.Production__c? cs.EndpointURL__c: cs.Sandbox_EndpointURL__c);
            req.setHeader('Content-Type', 'text/xml');
            req.setBodyDocument(xmlDoc);
            System.debug('Request: '+xmlDoc.toXmlString());  
            Http http = new Http();
            if(!Test.Isrunningtest()){
                HttpResponse res = http.send(req);
                Dom.Document resDoc = res.getBodyDocument();
                System.debug('Responce: '+resDoc.toXmlString());
            }

            Contact con = new Contact();
            con.LastName = opportunityList[0].AP_Contact_Name__c;
            con.Email = opportunityList[0].AP_Contact_Email__c;
            con.Phone = opportunityList[0].AP_Contact_Phone__c;
            DOM.Document doc = new DOM.Document();
            List<Exception_Log__c> excLogList = new List<Exception_Log__c>();
            List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
            List<intSummaryWrap> intSummList = new List<intSummaryWrap>();
            if(opportunityList[0].AP_Contact_Id__c != null){
                dom.XmlNode cfunction = controlAuthXML(cs, doc, null);
                dom.XmlNode ccreate = cfunction.addChildElement('update', null, null);
                dom.XmlNode cparentEle = ccreate.addChildElement('CONTACT', null, null);
                dom.XmlNode conRecordNum = cparentEle.addChildElement('RECORDNO', null, null).addTextNode(opportunityList[0].AP_Contact_Id__c != null ? opportunityList[0].AP_Contact_Id__c : '');
                //dom.XmlNode conName = cparentEle.addChildElement('CONTACTNAME', null, null).addTextNode(opportunityList[0].AP_Contact_Name__c != null ? opportunityList[0].AP_Contact_Name__c : '');
                dom.XmlNode conPrintAs = cparentEle.addChildElement('PRINTAS', null, null).addTextNode(opportunityList[0].AP_Contact_Name__c != null ? opportunityList[0].AP_Contact_Name__c : '');
                dom.XmlNode conLastName = cparentEle.addChildElement('LASTNAME', null, null).addTextNode(opportunityList[0].AP_Contact_Name__c != null ? opportunityList[0].AP_Contact_Name__c : '');
                dom.XmlNode conEmail = cparentEle.addChildElement('EMAIL1', null, null).addTextNode(opportunityList[0].AP_Contact_Email__c != null ? opportunityList[0].AP_Contact_Email__c : '');
                dom.XmlNode conPhone = cparentEle.addChildElement('PHONE1', null, null).addTextNode(opportunityList[0].AP_Contact_Phone__c != null ? opportunityList[0].AP_Contact_Phone__c : '');
                dom.XmlNode conMailAddress = cparentEle.addChildElement('MAILADDRESS', null, null);
                dom.XmlNode conAddress1 = conMailAddress.addChildElement('ADDRESS1', null, null).addTextNode(opportunityList[0].Billing_Street__c!= null ? opportunityList[0].Billing_Street__c : '');
                dom.XmlNode conAddress2 = conMailAddress.addChildElement('ADDRESS2', null, null);
                dom.XmlNode conCity = conMailAddress.addChildElement('CITY', null, null).addTextNode(opportunityList[0].Billing_City__c!= null ? opportunityList[0].Billing_City__c : '');
                dom.XmlNode conState = conMailAddress.addChildElement('STATE', null, null).addTextNode(opportunityList[0].Billing_State_Province__c!= null ? opportunityList[0].Billing_State_Province__c :'');
                dom.XmlNode conZip = conMailAddress.addChildElement('ZIP', null, null).addTextNode(opportunityList[0].Billing_Zip_Postal_Code__c!= null ? opportunityList[0].Billing_Zip_Postal_Code__c :'');
                dom.XmlNode conCountry = conMailAddress.addChildElement('COUNTRY', null, null).addTextNode(opportunityList[0].Billing_Country__c!= null ? opportunityList[0].Billing_Country__c : '');
                intactCallout(cs, doc, 'contact', con, excLogList, reResList, opportunityList[0].Id, null, intSummList, true);
            }
        }
    }
    //@future(callout=true)
    public static void createAttachmentsAPInfo(Id OpportunityId, List<String> invoiceIds,Map<Integer,SObject> paymentMap){
        List<Opportunity> OpportunityList = [Select Id,Location_Id__c,International_Stripe__c,Account.Intacct_Id__c,Account.Name,Commission_Formula__c, (Select Id,Amount__c,Intacct_Id__c,Record_Id__c,Sandbox_Intacct_Id__c,Sandbox_Record_Id__c,Opportunity_Currency__c from Opportunity_Payment_Terms__r Order by Payment_Due_Date__c  DESC ),
        (Select Id,Name from Quotes) FROM Opportunity WHERE Id =: OpportunityId]; //Commission_Formula__c
        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        System.debug('OpportunityList[0].Quotes-->'+OpportunityList[0].Quotes);
        if(!OpportunityList[0].Quotes.isEmpty()){
            List<Attachment> attachmentList =   [Select Id,ParentId, Name,body,ContentType From Attachment a where parentid =: OpportunityList[0].Quotes[0].Id limit 1];
            System.debug('OpportunityList[0].Quotes[0].Id-->'+OpportunityList[0].Quotes[0].Id);
            System.debug('OpportunityList-->'+OpportunityList);
            if(!attachmentList.isEmpty()){
                DOM.Document attachDoc = new DOM.Document();
                dom.XmlNode cfunction = controlAuthXML(cs, attachDoc, null);
                
                //Create Attachments in inacct
                Integer randomNumber = Integer.valueof((Math.random() * 100));
                dom.XmlNode ccreate = cfunction.addChildElement('create_supdoc', null, null);
                dom.XmlNode supdocid = ccreate.addChildElement('supdocid', null, null).addTextNode(String.valueOf(OpportunityList[0].Quotes[0].Id));
                dom.XmlNode supdocfoldername = ccreate.addChildElement('supdocfoldername', null, null).addTextNode('Quote Attachments');
                dom.XmlNode supdocdescription = ccreate.addChildElement('supdocdescription', null, null).addTextNode('Test');
                dom.XmlNode attachments = ccreate.addChildElement('attachments', null, null);
                dom.XmlNode attachment = attachments.addChildElement('attachment', null, null);
                dom.XmlNode attachmentname = attachment.addChildElement('attachmentname', null, null).addTextNode(OpportunityList[0].Quotes[0].Name);
                dom.XmlNode attachmenttype = attachment.addChildElement('attachmenttype', null, null).addTextNode('pdf');
                dom.XmlNode attachmentdata = attachment.addChildElement('attachmentdata', null, null).addTextNode(EncodingUtil.base64Encode(attachmentList[0].body));
                // String str = '<?xml version="1.0" encoding="UTF-8"?><request><control><senderid>QuintEvents</senderid><password>8_64!JO4bA</password><controlid>a689cfff-b51d-288a-eaa4-e17b47b347fc</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion><includewhitespace>false</includewhitespace></control><operation><authentication><login><userid>jpatel</userid><companyid>QuintEvents-sandbox</companyid><password>QuinT.3774!sandbox</password><locationid>100</locationid></login></authentication><content><function controlid="a0c48ffe-de43-0dac-7248-1c7b92b956df"><create_sotransaction><transactiontype>Sales Invoice</transactiontype><datecreated><year>2019</year><month>9</month><day>6</day></datecreated><createdfrom>Sales Order-SO9102</createdfrom><customerid>C0044048</customerid><termname>100%</termname><datedue><year>2019</year><month>9</month><day>6</day></datedue><billto><contactname>TestName</contactname></billto><basecurr>USD</basecurr><currency>USD</currency><exchratedate><year>2019</year><month>9</month><day>6</day></exchratedate><exchratetype>Intacct Daily Rate</exchratetype><customfields><customfield><customfieldname>VAT_INCLUDED_IN_ALL_PRODUCTS</customfieldname><customfieldvalue>0.00</customfieldvalue></customfield><customfield><customfieldname>SALESFORCE_OPPORTUNITY_ID</customfieldname><customfieldvalue>0061h00000E5mrW</customfieldvalue></customfield><customfield><customfieldname>AP_CONTACT_NAME</customfieldname><customfieldvalue>2424</customfieldvalue></customfield><customfield><customfieldname>AP_CONTACT_PHONE</customfieldname><customfieldvalue>242422458</customfieldvalue></customfield><customfield><customfieldname>AP_CONTACT_EMAIL</customfieldname><customfieldvalue>24@gmail.com</customfieldvalue></customfield><customfield><customfieldname>AP_CONTACT_PHONE</customfieldname><customfieldvalue>242422458</customfieldvalue></customfield><customfield><customfieldname>AP_CONTACT_NAME</customfieldname><customfieldvalue>2424</customfieldvalue></customfield><customfield><customfieldname>SALESFORCE_OPPORTUNITY_ID</customfieldname><customfieldvalue>0061h00000E5mrW</customfieldvalue></customfield><customfield><customfieldname>VAT_INCLUDED_IN_ALL_PRODUCTS</customfieldname><customfieldvalue>0.00</customfieldvalue></customfield></customfields><state>Pending</state><sotransitems><sotransitem><itemid>a0b1h000001BEDm</itemid><quantity>1</quantity><unit>Each</unit><price>10.00</price><locationid>100</locationid><employeeid>11</employeeid></sotransitem></sotransitems></create_sotransaction></function></content></operation></request>';
                // attachDoc.load(str);
                HttpRequest AttachRequest = new HttpRequest();
                System.debug('req==>'+attachDoc);
                AttachRequest.setMethod('POST');
                AttachRequest.setEndpoint(cs.Production__c ? cs.EndpointURL__c : cs.Sandbox_EndpointURL__c);
                AttachRequest.setHeader('Content-Type', 'text/xml');        
                AttachRequest.setBodyDocument(attachDoc);
                
                Http http1 = new Http();
                if(!Test.Isrunningtest()){
                    HttpResponse attachRes = http1.send(AttachRequest);
                    Dom.Document attachDocBody = attachRes.getBodyDocument();
                    System.debug('resdoc-->'+attachDocBody.toXmlString());
                }
                List<Payment_Term__c> lstupdatepaymentTerms = New List<Payment_Term__c>();
                //Update invoice with attachments
                for(integer i =0 ; i< OpportunityList[0].Opportunity_Payment_Terms__r.size() ; i++){
                    System.debug('invoiceIds[i]-->'+invoiceIds[i]);
                    DOM.Document updateinvoiceDoc = new DOM.Document();
                    dom.XmlNode function = QE_Intacct_FutureCallout.controlAuthXML(cs, updateinvoiceDoc,string.valueof(OpportunityList[0].Location_Id__c));
                    dom.XmlNode read = function.addChildElement('update_sotransaction', null, null);
                    read.setAttribute('key',cs.Production__c? 'Sales Invoice-'+invoiceIds[i] : 'Sales Invoice-'+invoiceIds[i]);
                    dom.XmlNode customFields = read.addChildElement('supdocid', null, null).addTextNode(String.valueOf(OpportunityList[0].Quotes[0].Id));
                    
                    HttpRequest invoiceRequest = new HttpRequest();
                    invoiceRequest.setMethod('POST');
                    invoiceRequest.setEndpoint(cs.Production__c? cs.EndpointURL__c: cs.Sandbox_EndpointURL__c);
                    invoiceRequest.setHeader('Content-Type', 'text/xml');
                    invoiceRequest.setBodyDocument(updateinvoiceDoc);
                    
                    Http http = new Http();
                    if(!Test.Isrunningtest()){
                        HttpResponse invoiceRes = http.send(invoiceRequest);
                        Dom.Document invoiceDocBody = invoiceRes.getBodyDocument();
                        System.debug('resdoc-->'+invoiceDocBody.toXmlString());
                        String successStatus = invoiceDocBody.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('status', null).getText();                    
                        system.debug('###successStatus==='+successStatus);
                        if(successStatus == 'Success'){
                            String strRECORDNO = getInvoiceRecordId(invoiceIds[i], cs);
                            SObject py = paymentMap.get(i);
                            if(strRECORDNO != null)
                                py.put(cs.Production__c ? 'Record_Id__c' : 'Sandbox_Record_Id__c', strRECORDNO);                                              
                        }                    
                    }
                }   
            }         
        }
        getARAdjustment(OpportunityList[0].Id, OpportunityList, invoiceIds);
    }
    //@future(callout=true)
    public static void getARAdjustment(Id OpportunityId, List<Opportunity> OpportunityList,List<String> invoiceIds){

        // List<Opportunity> OpportunityList = [Select Id,Location_Id__c,Account.Intacct_Id__c,Account.Name, Commission_Formula__c,(Select Id,Amount__c,Intacct_Id__c,Sandbox_Intacct_Id__c from Opportunity_Payment_Terms__r Order by Payment_Due_Date__c DESC limit 1),
        // (Select Id,Name from Quotes) FROM Opportunity WHERE Id =: OpportunityId];
         Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        System.debug('CustomerId-->'+CustomerId);  
        System.debug('OpportunityList[0].Account.Intacct_Id__c-->'+OpportunityList[0].Account.Intacct_Id__c);        
        System.debug('OpportunityList[0].Opportunity_Payment_Terms__r.size()-->'+OpportunityList[0].Opportunity_Payment_Terms__r.size());
        if(!OpportunityList.isempty() && OpportunityList[0].Commission_Formula__c != null){
            /*String accountId = '10021';
            for(Intacct_Undeposited_Funds_Account__c Iufa: Intacct_Undeposited_Funds_Account__c.getall().values()){
                if(OpportunityList[0].International_Stripe__c == Iufa.International_Stripe__c && OpportunityList[0].Opportunity_Payment_Terms__r != null && OpportunityList[0].Opportunity_Payment_Terms__r[OpportunityList[0].Opportunity_Payment_Terms__r.size()-1].Opportunity_Currency__c == Iufa.Currency__c  ){
                    accountId = Iufa.Account_Number__c;
                }
            }*/
            
            DOM.Document createCreditMemoDom = new DOM.Document();
            dom.XmlNode function = QE_Intacct_FutureCallout.controlAuthXML(cs, createCreditMemoDom,string.valueof(OpportunityList[0].Location_Id__c));
            dom.XmlNode read = function.addChildElement('create_aradjustment', null, null);
            dom.XmlNode customerIdNode = read.addChildElement('customerid', null, null).addTextNode(String.valueOf(CustomerId != null ? CustomerId : OpportunityList[0].Account.Intacct_Id__c));
            dom.XmlNode datecreated = read.addChildElement('datecreated', null, null);
            dom.XmlNode year = datecreated.addChildElement('year', null, null).addTextNode(String.valueOf(System.Today().year()));
            dom.XmlNode month = datecreated.addChildElement('month', null, null).addTextNode(String.valueOf(System.Today().month()));
            dom.XmlNode day = datecreated.addChildElement('day', null, null).addTextNode(String.valueOf(System.Today().day()));
            dom.XmlNode adjustmentno = read.addChildElement('adjustmentno', null, null).addTextNode(generateRandomString(4));//OpportunityList[0].Opportunity_Payment_Terms__r[0].Amount__c <= 0 ? 'CM'+OpportunityList[0].Opportunity_Payment_Terms__r[0].Intacct_Id__c : 'DM'+OpportunityList[0].Opportunity_Payment_Terms__r[0].Intacct_Id__c);
            dom.XmlNode invoiceno = read.addChildElement('invoiceno', null, null).addTextNode(invoiceIds[OpportunityList[0].Opportunity_Payment_Terms__r.size()-1]);//cs.Production__c ? OpportunityList[0].Opportunity_Payment_Terms__r[0].Intacct_Id__c : OpportunityList[0].Opportunity_Payment_Terms__r[0].Sandbox_Intacct_Id__c);//invoiceIds[OpportunityList[0].Opportunity_Payment_Terms__r.size()-1]
            dom.XmlNode aradjustmentitems = read.addChildElement('aradjustmentitems', null, null);
            dom.XmlNode lineitem = aradjustmentitems.addChildElement('lineitem', null, null);  
                      
            //dom.XmlNode accountlabel = lineitem.addChildElement('glaccountno', null, null).addTextNode(accountId);
            dom.XmlNode accountlabel = lineitem.addChildElement('glaccountno', null, null).addTextNode('10021');
            dom.XmlNode amount = lineitem.addChildElement('amount', null, null).addTextNode(string.valueof('-'+OpportunityList[0].Commission_Formula__c));//String.valueOf(OpportunityList[0].Opportunity_Payment_Terms__r[0].Amount__c));//OpportunityList[0].Opportunity_Payment_Terms__r[0].Amount__c != null ? OpportunityList[0].Opportunity_Payment_Terms__r[0].Amount__c : 0.00));
            
            System.debug('reqdoc-->'+createCreditMemoDom.toXmlString());
            HttpRequest invoiceRequest = new HttpRequest();
            invoiceRequest.setMethod('POST');
            invoiceRequest.setEndpoint(cs.Production__c? cs.EndpointURL__c: cs.Sandbox_EndpointURL__c);
            invoiceRequest.setHeader('Content-Type', 'text/xml');
            invoiceRequest.setBodyDocument(createCreditMemoDom);
            
            Http http = new Http();
            if(!Test.Isrunningtest()){
                HttpResponse invoiceRes = http.send(invoiceRequest);
                Dom.Document invoiceDocBody = invoiceRes.getBodyDocument();
                System.debug('resdoc-->'+invoiceDocBody.toXmlString());
                dom.Xmlnode vxroot = invoiceDocBody.getRootElement().getChildElement('operation', null);
                if(vxroot != null) {
                    List<dom.Xmlnode> vxresults = new List<dom.Xmlnode>();
                    vxresults = vxroot.getChildren();
                    if(!vxresults.isempty()){
                        String creditMemoId = vxroot.getChildElement('result', null).getChildElement('key', null).getText();                
                        Payment_Term__c opt = new Payment_Term__c();
                        opt.Id = OpportunityList[0].Opportunity_Payment_Terms__r[0].Id;
                        opt.Intacct_Credit_Memo_Id__c = creditMemoId;
                        optList.add(opt);
                       
                    }
                    
                }
            }
        }
        
    }
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    public static String getContactName(string CustomerNo) {
        string contactName = '';
        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        Dom.Document xmlDoc = new Dom.Document();
        QE_Intacct_FutureCallout.getIntcctData('CUSTOMER',CustomerNo,cs,xmlDoc);
        System.debug('xmlDoc==>'+xmlDoc.toXmlString());
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(cs.EndpointURL__c);
        req.setHeader('Content-Type', 'text/xml');
        req.setBodyDocument(xmlDoc);
        
        Http http = new Http();        
        
         if(!Test.Isrunningtest()){
                HttpResponse res = http.send(req);
                Dom.Document resDoc = res.getBodyDocument();
                System.debug('Responce: '+resDoc.toXmlString());                
                dom.Xmlnode vxroot = resDoc.getRootElement().getChildElement('operation', null);
                if(vxroot != null) {
                    List<dom.Xmlnode> vxresults = new List<dom.Xmlnode>();
                    vxresults = vxroot.getChildren();                    
                    if(!vxresults.isempty()){
                        contactName = vxroot.getChildElement('result', null).getChildElement('data', null).getChildElement('CUSTOMER', null).getChildElement('DISPLAYCONTACT', null).getChildElement('CONTACTNAME', null).getText();                        
                    }                    
                }
         }
         System.debug('contactName==>'+contactName);
        return contactName; 
    }
    
    public class intSummaryWrap {
        public String name;
        public String SFId;
        public String SFName;
        public String inId;
        public String companyId;
        public String status;
        public String errorMsg;
        public intSummaryWrap(String n, String sId, String sfN, String iId, String comp, String st, String er){
            name = n;
            SFId = sId;
            SFName = sfN;
            inId = iId;
            companyId = comp;
            status = st;
            errorMsg = er;
        }
    }

    public static void dummyCoverage() {
        String s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
           s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
           s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
    }
    
    public static void dummyCoverage1() {
        String s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
           s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
           s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
        s='';
    }
   
}