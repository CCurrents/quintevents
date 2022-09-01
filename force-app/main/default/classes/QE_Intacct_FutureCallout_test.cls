@isTest
public class QE_Intacct_FutureCallout_test{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();     
    }
    
    public static testMethod void testmethod1(){
        User u = new User(
       ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
       LastName = 'last',
       Email = 'intact@test.com',
       Username = 'intact@test.com' + System.currentTimeMillis(),
       CompanyName = 'TEST',
       Title = 'title',
       Alias = 'alias',
       TimeZoneSidKey = 'America/Los_Angeles',
       EmailEncodingKey = 'UTF-8',
       LanguageLocaleKey = 'en_US',
       LocaleSidKey = 'en_US',
       Intacct_Employee_Id__c = '123'
    );
    Insert u;
    System.RunAs(u) {

        String Accrecid = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        String Accrecid1 = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId  = Accrecid;
        acc.Name = 'testName';
        acc.From_Lead_Convert__c = true;
        acc.Record_Id__c = 'Sales Order-SO0050';
        acc.Intacct_Id__c = 'test11';
        insert acc;

        Contact contact = new Contact();
        contact.accountid = acc.id;
        contact.lastname='test';
        contact.email='test@test.com';
        contact.Primary_Contact__c  = true;
        contact.Record_Id__c = 'Sales Order-SO0050';
        insert contact;

        QE360_Event__c   evt = new QE360_Event__c();
        evt.Name = 'test event';
        evt.Start_Date__c = Date.Parse('8/21/2015');
        evt.End_Date__c = Date.Parse('8/24/2015');
        insert evt;

        String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecid;
        opp.accountid = acc.id;
        opp.Name = 'test opportunity';
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.Event__c = evt.id;
        opp.CloseDate = date.parse('12/27/2017');
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Record_Id__c  = 'Sales Order-SO0050';
        opp.Primary_Contact__c = contact.Id;
        opp.OwnerId  = u.Id;
        opp.AP_Contact_Id__c = '12345';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;

        
        Payment_Term__c oppPaymentTerms = new Payment_Term__c();
        oppPaymentTerms.Opportunity__c = opp.id;
        insert oppPaymentTerms;

        Payment_Term__c  objOppTerms = new Payment_Term__c();
        objOppTerms.Opportunity__c = opp.Id;
        objOppTerms.Amount__c = 10;
        objOppTerms.Status__c = 'Pending';
        objOppTerms.Payment_Term__c = '100%';
    //  objOppTerms.Opportunity_Event_Start_Date__c = system.today();
    //  objOppTerms.Event_Payment_Term_Start_Date__c = system.today();
        insert objOppTerms;
       
        List<Payment_Term__c> lstPayment = new List<Payment_Term__c> ();
        lstPayment.add(objOppTerms);

    QE_ExceptionHandling_Email__c SFDCEmail = new QE_ExceptionHandling_Email__c();
        //SFDCEmail.BCC_Address__c = 'test@test.com';
        SFDCEmail.CC_Address__c = 'test@test.com';
        SFDCEmail.To_Address__c = 'test@test.com';
        insert SFDCEmail;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
        SFDCToIntacctMapObj.SF_Object__c = 'Contact';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;


        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = null;
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id.id.id';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = true;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id.id';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'update';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Amount__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Amount__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Payment_Terms__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Id';
        SFDCToIntacctMapObj.SF_Object__c = 'QE360_Event__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'sotransitems.sotransitem.employeeid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 5.24;
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Intacct_Employee_Id__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;


        Intacct_API_Details__c Intacct = new Intacct_API_Details__c();
        Intacct.CompanyId__c = 'test';
        Intacct.EndpointURL__c = 'test';
        Intacct.Password__c = 'test';
        Intacct.SenderId__c = 'test';
        Intacct.SenderPassword__c = 'test';
        Intacct.UserName__c = 'test';
        Intacct.Production__c = true;
        insert Intacct;

        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        system.debug('Intacct_API_Details__c==>'+cs);
        DOM.Document accdoc = new DOM.Document();
        List<Exception_Log__c> excLogList = new List<Exception_Log__c>();
        List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
        SObject accRec = [select id,createddate,RecordTypeId,Name,Record_Id__c,Description from account where id=:acc.id];
        SObject conRec = [select id,RecordTypeId,lastname,Record_Id__c from Contact where id=:contact.id];
        SObject oppRec = [SELECT Id, Name, AccountID, Account.RecordTypeId,Event__c,Record_Id__c,Intacct_Id__c,Intacct_Employee_Id__c FROM Opportunity WHERE Id =: opp.id];
        List<SObject> eveReclst = [SELECT Id,Start_Date__c FROM QE360_Event__c];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type1'));
        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
    //QE_Intacct_FutureCallout.intSummaryWrap obj = new QE_Intacct_FutureCallout.intSummaryWrap();
        List<QE_Intacct_FutureCallout.intSummaryWrap> intSummList = new List<QE_Intacct_FutureCallout.intSummaryWrap>();
       QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'paymentterm', lstPayment[0],excLogList,reResList,opp.id,lstPayment,intSummList,true);

        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type2'));



        QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList,false);
        QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'CUST', accRec,excLogList,reResList,opp.id,lstPayment,intSummList,false);
        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type4'));
        QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList,false);
        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type6'));
        QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList,false);

        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type6'));
        QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'payment', lstPayment[0],excLogList,reResList,null,null,null,false);
        
        List<String> invoiceIds = new List<String>();
        invoiceIds.add('INV3534');
        invoiceIds.add('INV3535');
        invoiceIds.add('INV3536');
        invoiceIds.add('INV3537');
        Quote quote = new Quote();
        quote.Name = 'test';
        quote.OpportunityId = opp.Id;
        insert quote;

        Attachment attach=new Attachment();
        attach.Name='Test';
        Blob bodyBlob=Blob.valueOf('Testing Body of Attachment');
        attach.body=bodyBlob;
        attach.parentId=quote.id;
        insert attach;
        QE_Intacct_FutureCallout.createAttachmentsAPInfo(opp.id, invoiceIds,new Map<Integer,SObject>());
        //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'paymentterm', lstPayment[0],excLogList,reResList,opp.id,lstPayment,intSummList);
        Test.stopTest();

        DOM.Document getAccdoc = new DOM.Document();
        //   QE_Intacct_FutureCallout.intacctGetCallout(cs, getAccdoc, accRec,excLogList, reResList,opp.id);

        List<SFDCToIntacctMap_Old__c> accMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> conMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> payMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> oppMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> eveMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> allMapList = new List<SFDCToIntacctMap_Old__c>();
         for(SFDCToIntacctMap_Old__c sti: [SELECT Id,Line_Item__c, Intacct_Object__c, Name, Custom_Logic__c,Active__c, Operation__c,Type__c, Constant_Value__c, Description__c, Intacct_Node_Name__c, Intacct_Table__c, Sequence__c, SF_Field_API_Name__c, SF_Object__c FROM SFDCToIntacctMap_Old__c WHERE Active__c =: true ORDER BY Sequence__c]){
                allMapList.add(sti);
                if(sti.SF_Object__c == 'Account'){
                    accMapList.add(sti);
                }else if(sti.SF_Object__c == 'Contact'){
                    conMapList.add(sti);
                }else if(sti.SF_Object__c == 'Opportunity_Payment_Terms__c'){
                    payMapList.add(sti);
                }else if(sti.SF_Object__c == 'Opportunity'){
                    oppMapList.add(sti);
                }else if(sti.SF_Object__c == 'QE360_Event__c'){
                    eveMapList.add(sti);
                }

            }
             Map<String,Sobject> objRecordMap = new Map<String,Sobject>();
             objRecordMap.put('Opportunity',oppRec);
             objRecordMap.put('Account',accRec);
             objRecordMap.put('Contact',conRec);
             set<string> elseset = new set<string>();


            DOM.Document doc = new DOM.Document();
            dom.XmlNode function = QE_Intacct_FutureCallout.controlAuthXML(cs, doc, '100');
        dom.XmlNode parentEle;
        parentEle = function.addChildElement('test', null, null);

        set<string> elseset1 = new set<string>();
        elseset1.add('test');
        QE_Intacct_FutureCallout.genContentXML(allMapList,accMapList[2].Intacct_Table__c,accMapList[2].Operation__c,accRec,cs,parentEle,conRec,objRecordMap,accMapList[2].Intacct_Object__c,elseset1,lstPayment,null);

        QE_Intacct_FutureCallout.genLineItemXML(allMapList,accMapList[1].Intacct_Table__c,accMapList[1].Operation__c,accRec,parentEle,objRecordMap,accMapList[1].Intacct_Object__c,elseset1,null,null);
        QE_Intacct_FutureCallout.genLineItemXML(allMapList,accMapList[2].Intacct_Table__c,accMapList[2].Operation__c,accRec,parentEle,objRecordMap,accMapList[2].Intacct_Object__c,elseset1,null,null);

        Set<String> strset = new Set<String>();
        strset.add('test');
        // QE_Intacct_FutureCallout.customLogic(accMapList[2],parentEle,lstPayment[0],accRec,strset);

          String[] arr = new String[]{'test1','tt'};

          QE_Intacct_FutureCallout.XMLLogicLoop(1,arr,parentEle,'test',strset);
          QE_Intacct_FutureCallout.XMLLogicLoop(2,arr,parentEle,'test',strset);
          doc = new DOM.Document();
          QE_Intacct_FutureCallout.getIntcctData('test','test',cs,doc);
          QE_Intacct_FutureCallout.hasSObjectField('test',oppRec);

          QE_Intacct_FutureCallout.dateLogic('year',accRec,'createddate',parentEle,null,null,null,null);
          QE_Intacct_FutureCallout.dateLogic('month',accRec,'createddate',parentEle,null,null,null,null);
          QE_Intacct_FutureCallout.dateLogic('day',accRec,'createddate',parentEle,null,null,null,null);

          //QE_Intacct_FutureCallout.paymentUpdateIntacct('07MW0000004KXj5');

     //  Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type5'));

    }
    }

   public static testMethod void testmethod5(){
        User u = new User(
       ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
       LastName = 'last',
       Email = 'intact@test.com',
       Username = 'intact@test.com' + System.currentTimeMillis(),
       CompanyName = 'TEST',
       Title = 'title',
       Alias = 'alias',
       TimeZoneSidKey = 'America/Los_Angeles',
       EmailEncodingKey = 'UTF-8',
       LanguageLocaleKey = 'en_US',
       LocaleSidKey = 'en_US',
       Intacct_Employee_Id__c = '123'
    );
    Insert u;
    System.RunAs(u) {

        String Accrecid = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        String Accrecid1 = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId  = Accrecid;
        acc.Name = 'testName';
        acc.From_Lead_Convert__c = true;
        acc.Record_Id__c = 'Sales Order-SO0050';
        insert acc;

        Contact contact = new Contact();
        contact.accountid = acc.id;
        contact.lastname='test';
        contact.email='test@test.com';
        contact.Primary_Contact__c  = true;
        contact.Record_Id__c = 'Sales Order-SO0050';
        insert contact;

        QE360_Event__c   evt = new QE360_Event__c();
        evt.Name = 'test event';
        evt.Start_Date__c = Date.Parse('8/21/2015');
        evt.End_Date__c = Date.Parse('8/24/2015');
        insert evt;



        String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecid;
        opp.accountid = acc.id;
        opp.Name = 'test opportunity';
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.Event__c = evt.id;
        opp.CloseDate = date.parse('12/27/2017');
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Record_Id__c  = 'Sales Order-SO0050';
        opp.OwnerId  = u.Id;
        opp.Primary_Contact__c = contact.Id;
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;

        Payment_Term__c oppPaymentTerms = new Payment_Term__c();
        oppPaymentTerms.Opportunity__c = opp.id;
        insert oppPaymentTerms;

        Payment_Term__c objOppTerms = new Payment_Term__c();
        objOppTerms.Opportunity__c = opp.Id;
        objOppTerms.Amount__c = 10;
        objOppTerms.Status__c = 'Pending';
        objOppTerms.Payment_Term__c = '100%';
    //  objOppTerms.Opportunity_Event_Start_Date__c = system.today();
    //  objOppTerms.Event_Payment_Term_Start_Date__c = system.today();
        insert objOppTerms;

        List<Payment_Term__c> lstPayment = new List<Payment_Term__c> ();
        lstPayment.add(objOppTerms);

    QE_ExceptionHandling_Email__c SFDCEmail = new QE_ExceptionHandling_Email__c();
        //SFDCEmail.BCC_Address__c = 'test@test.com';
        SFDCEmail.CC_Address__c = 'test@test.com';
        SFDCEmail.To_Address__c = 'test@test.com';
        insert SFDCEmail;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
        SFDCToIntacctMapObj.SF_Object__c = 'Contact';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;


        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = null;
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id.id.id';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = true;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id.id';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'update';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Amount__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Payment_Terms__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Id';
        SFDCToIntacctMapObj.SF_Object__c = 'QE360_Event__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'sotransitems.sotransitem.employeeid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 5.24;
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Intacct_Employee_Id__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;


        Intacct_API_Details__c Intacct = new Intacct_API_Details__c();
        Intacct.CompanyId__c = 'test';
        Intacct.EndpointURL__c = 'test';
        Intacct.Password__c = 'test';
        Intacct.SenderId__c = 'test';
        Intacct.SenderPassword__c = 'test';
        Intacct.UserName__c = 'test';
        Intacct.Production__c = true;
        insert Intacct;

        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        system.debug('Intacct_API_Details__c==>'+cs);
        DOM.Document accdoc = new DOM.Document();
        List<Exception_Log__c> excLogList = new List<Exception_Log__c>();
        List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
        SObject accRec = [select id,createddate,RecordTypeId,Name,Record_Id__c,Description from account where id=:acc.id];
        SObject conRec = [select id,RecordTypeId,lastname,Record_Id__c from Contact where id=:contact.id];
        SObject oppRec = [SELECT Id, Name, AccountID, Account.RecordTypeId,Event__c,Record_Id__c,Intacct_Id__c,Intacct_Employee_Id__c FROM Opportunity WHERE Id =: opp.id];
        List<SObject> eveReclst = [SELECT Id,Start_Date__c FROM QE360_Event__c];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type1'));
        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
    //QE_Intacct_FutureCallout.intSummaryWrap obj = new QE_Intacct_FutureCallout.intSummaryWrap();
        List<QE_Intacct_FutureCallout.intSummaryWrap> intSummList = new List<QE_Intacct_FutureCallout.intSummaryWrap>();
      // QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'paymentterm', lstPayment[0],excLogList,reResList,opp.id,lstPayment,intSummList);

        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type2'));



        //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);
       // QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'CUST', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);
        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type4'));
       //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);
      Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type6'));
       //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);

     //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'payment', lstPayment[0],excLogList,reResList,null,null,null);
     Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type4'));
     QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'paymentterm', lstPayment[0],excLogList,reResList,opp.id,lstPayment,intSummList,false);
        Test.stopTest();

        DOM.Document getAccdoc = new DOM.Document();
     //   QE_Intacct_FutureCallout.intacctGetCallout(cs, getAccdoc, accRec,excLogList, reResList,opp.id);

        List<SFDCToIntacctMap_Old__c> accMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> conMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> payMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> oppMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> eveMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> allMapList = new List<SFDCToIntacctMap_Old__c>();
         for(SFDCToIntacctMap_Old__c sti: [SELECT Id,Line_Item__c, Intacct_Object__c, Name, Custom_Logic__c,Active__c, Operation__c,Type__c, Constant_Value__c, Description__c, Intacct_Node_Name__c, Intacct_Table__c, Sequence__c, SF_Field_API_Name__c, SF_Object__c FROM SFDCToIntacctMap_Old__c WHERE Active__c =: true ORDER BY Sequence__c]){
                allMapList.add(sti);
                if(sti.SF_Object__c == 'Account'){
                    accMapList.add(sti);
                }else if(sti.SF_Object__c == 'Contact'){
                    conMapList.add(sti);
                }else if(sti.SF_Object__c == 'Opportunity_Payment_Terms__c'){
                    payMapList.add(sti);
                }else if(sti.SF_Object__c == 'Opportunity'){
                    oppMapList.add(sti);
                }else if(sti.SF_Object__c == 'QE360_Event__c'){
                    eveMapList.add(sti);
                }

            }
             Map<String,Sobject> objRecordMap = new Map<String,Sobject>();
             objRecordMap.put('Opportunity',oppRec);
             objRecordMap.put('Account',accRec);
             objRecordMap.put('Contact',conRec);
             set<string> elseset = new set<string>();


            DOM.Document doc = new DOM.Document();
            dom.XmlNode function = QE_Intacct_FutureCallout.controlAuthXML(cs, doc, null);
        dom.XmlNode parentEle;
        parentEle = function.addChildElement('test', null, null);

        set<string> elseset1 = new set<string>();
        elseset1.add('test');
        QE_Intacct_FutureCallout.genContentXML(allMapList,accMapList[2].Intacct_Table__c,accMapList[2].Operation__c,accRec,cs,parentEle,conRec,objRecordMap,accMapList[2].Intacct_Object__c,elseset1,lstPayment,null);

        QE_Intacct_FutureCallout.genLineItemXML(allMapList,accMapList[1].Intacct_Table__c,accMapList[1].Operation__c,accRec,parentEle,objRecordMap,accMapList[1].Intacct_Object__c,elseset1,null,null);
        QE_Intacct_FutureCallout.genLineItemXML(allMapList,accMapList[2].Intacct_Table__c,accMapList[2].Operation__c,accRec,parentEle,objRecordMap,accMapList[2].Intacct_Object__c,elseset1,null,null);

        Set<String> strset = new Set<String>();
        strset.add('test');
        // QE_Intacct_FutureCallout.customLogic(accMapList[2],parentEle,lstPayment[0],accRec,strset);

          String[] arr = new String[]{'test1','tt'};

          QE_Intacct_FutureCallout.XMLLogicLoop(1,arr,parentEle,'test',strset);
          QE_Intacct_FutureCallout.XMLLogicLoop(2,arr,parentEle,'test',strset);
          doc = new DOM.Document();
          QE_Intacct_FutureCallout.getIntcctData('test','test',cs,doc);
          QE_Intacct_FutureCallout.hasSObjectField('test',oppRec);

          QE_Intacct_FutureCallout.dateLogic('year',accRec,'createddate',parentEle,null,null,null,null);
          QE_Intacct_FutureCallout.dateLogic('month',accRec,'createddate',parentEle,null,null,null,null);
          QE_Intacct_FutureCallout.dateLogic('day',accRec,'createddate',parentEle,null,null,null,null);

          //QE_Intacct_FutureCallout.paymentUpdateIntacct('07MW0000004KXj5');
    }
    }

   public static testMethod void testmethod6(){
        User u = new User(
       ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
       LastName = 'last',
       Email = 'intact@test.com',
       Username = 'intact@test.com' + System.currentTimeMillis(),
       CompanyName = 'TEST',
       Title = 'title',
       Alias = 'alias',
       TimeZoneSidKey = 'America/Los_Angeles',
       EmailEncodingKey = 'UTF-8',
       LanguageLocaleKey = 'en_US',
       LocaleSidKey = 'en_US',
       Intacct_Employee_Id__c = '123'
    );
    Insert u;
    System.RunAs(u) {

        String Accrecid = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        String Accrecid1 = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId  = Accrecid;
        acc.Name = 'testName';
        acc.From_Lead_Convert__c = true;
        acc.Record_Id__c = 'Sales Order-SO0050';
        insert acc;

        Contact contact = new Contact();
        contact.accountid = acc.id;
        contact.lastname='test';
        contact.email='test@test.com';
        contact.Primary_Contact__c  = true;
        contact.Record_Id__c = 'Sales Order-SO0050';
        insert contact;

        QE360_Event__c   evt = new QE360_Event__c();
        evt.Name = 'test event';
        evt.Start_Date__c = Date.Parse('8/21/2015');
        evt.End_Date__c = Date.Parse('8/24/2015');
        insert evt;



        String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecid;
        opp.accountid = acc.id;
        opp.Name = 'test opportunity';
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.Event__c = evt.id;
        opp.CloseDate = date.parse('12/27/2017');
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Record_Id__c  = 'Sales Order-SO0050';
        opp.Primary_Contact__c = contact.Id;
        opp.OwnerId  = u.Id;
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;

        Payment_Term__c oppPaymentTerms = new Payment_Term__c();
        oppPaymentTerms.Opportunity__c = opp.id;
        insert oppPaymentTerms;

        Payment_Term__c objOppTerms = new Payment_Term__c();
        objOppTerms.Opportunity__c = opp.Id;
        objOppTerms.Amount__c = 10;
        objOppTerms.Status__c = 'Pending';
        objOppTerms.Payment_Term__c = '100%';
    //  objOppTerms.Opportunity_Event_Start_Date__c = system.today();
    //  objOppTerms.Event_Payment_Term_Start_Date__c = system.today();
        insert objOppTerms;

        List<Payment_Term__c> lstPayment = new List<Payment_Term__c> ();
        lstPayment.add(objOppTerms);

    QE_ExceptionHandling_Email__c SFDCEmail = new QE_ExceptionHandling_Email__c();
        //SFDCEmail.BCC_Address__c = 'test@test.com';
        SFDCEmail.CC_Address__c = 'test@test.com';
        SFDCEmail.To_Address__c = 'test@test.com';
        insert SFDCEmail;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
        SFDCToIntacctMapObj.SF_Object__c = 'Contact';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;


        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = null;
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id.id.id';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = true;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id.id';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'update';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Amount__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Payment_Terms__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Id';
        SFDCToIntacctMapObj.SF_Object__c = 'QE360_Event__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'sotransitems.sotransitem.employeeid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 5.24;
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Intacct_Employee_Id__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;


        Intacct_API_Details__c Intacct = new Intacct_API_Details__c();
        Intacct.CompanyId__c = 'test';
        Intacct.EndpointURL__c = 'test';
        Intacct.Password__c = 'test';
        Intacct.SenderId__c = 'test';
        Intacct.SenderPassword__c = 'test';
        Intacct.UserName__c = 'test';
        Intacct.Production__c = true;
        insert Intacct;

        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        system.debug('Intacct_API_Details__c==>'+cs);
        DOM.Document accdoc = new DOM.Document();
        List<Exception_Log__c> excLogList = new List<Exception_Log__c>();
        List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
        SObject accRec = [select id,createddate,RecordTypeId,Name,Record_Id__c,Description from account where id=:acc.id];
        SObject conRec = [select id,RecordTypeId,lastname,Record_Id__c from Contact where id=:contact.id];
        SObject oppRec = [SELECT Id, Name, AccountID, Account.RecordTypeId,Event__c,Record_Id__c,Intacct_Id__c,Intacct_Employee_Id__c FROM Opportunity WHERE Id =: opp.id];
        List<SObject> eveReclst = [SELECT Id,Start_Date__c FROM QE360_Event__c];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type1'));
        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
    //QE_Intacct_FutureCallout.intSummaryWrap obj = new QE_Intacct_FutureCallout.intSummaryWrap();
        List<QE_Intacct_FutureCallout.intSummaryWrap> intSummList = new List<QE_Intacct_FutureCallout.intSummaryWrap>();
      // QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'paymentterm', lstPayment[0],excLogList,reResList,opp.id,lstPayment,intSummList);

        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type5'));



        //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);
       // QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'CUST', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);
        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
      //  Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type4'));
       //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);
    //  Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type6'));
       //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);

     //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'payment', lstPayment[0],excLogList,reResList,null,null,null);
   //  Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type6'));
   //  QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'paymentterm', lstPayment[0],excLogList,reResList,opp.id,lstPayment,intSummList);
        Test.stopTest();

        DOM.Document getAccdoc = new DOM.Document();
     //   QE_Intacct_FutureCallout.intacctGetCallout(cs, getAccdoc, accRec,excLogList, reResList,opp.id);

        List<SFDCToIntacctMap_Old__c> accMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> conMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> payMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> oppMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> eveMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> allMapList = new List<SFDCToIntacctMap_Old__c>();
         for(SFDCToIntacctMap_Old__c sti: [SELECT Id,Line_Item__c, Intacct_Object__c, Name, Custom_Logic__c,Active__c, Operation__c,Type__c, Constant_Value__c, Description__c, Intacct_Node_Name__c, Intacct_Table__c, Sequence__c, SF_Field_API_Name__c, SF_Object__c FROM SFDCToIntacctMap_Old__c WHERE Active__c =: true ORDER BY Sequence__c]){
                allMapList.add(sti);
                if(sti.SF_Object__c == 'Account'){
                    accMapList.add(sti);
                }else if(sti.SF_Object__c == 'Contact'){
                    conMapList.add(sti);
                }else if(sti.SF_Object__c == 'Opportunity_Payment_Terms__c'){
                    payMapList.add(sti);
                }else if(sti.SF_Object__c == 'Opportunity'){
                    oppMapList.add(sti);
                }else if(sti.SF_Object__c == 'QE360_Event__c'){
                    eveMapList.add(sti);
                }

            }
             Map<String,Sobject> objRecordMap = new Map<String,Sobject>();
             objRecordMap.put('Opportunity',oppRec);
             objRecordMap.put('Account',accRec);
             objRecordMap.put('Contact',conRec);
             set<string> elseset = new set<string>();


            DOM.Document doc = new DOM.Document();
            dom.XmlNode function = QE_Intacct_FutureCallout.controlAuthXML(cs, doc, null);
        dom.XmlNode parentEle;
        parentEle = function.addChildElement('test', null, null);

        set<string> elseset1 = new set<string>();
        elseset1.add('test');
        QE_Intacct_FutureCallout.genContentXML(allMapList,accMapList[2].Intacct_Table__c,accMapList[2].Operation__c,accRec,cs,parentEle,conRec,objRecordMap,accMapList[2].Intacct_Object__c,elseset1,lstPayment,null);

        QE_Intacct_FutureCallout.genLineItemXML(allMapList,accMapList[1].Intacct_Table__c,accMapList[1].Operation__c,accRec,parentEle,objRecordMap,accMapList[1].Intacct_Object__c,elseset1,null,null);
        QE_Intacct_FutureCallout.genLineItemXML(allMapList,accMapList[2].Intacct_Table__c,accMapList[2].Operation__c,accRec,parentEle,objRecordMap,accMapList[2].Intacct_Object__c,elseset1,null,null);

        Set<String> strset = new Set<String>();
        strset.add('test');
        // QE_Intacct_FutureCallout.customLogic(accMapList[2],parentEle,lstPayment[0],accRec,strset);

          String[] arr = new String[]{'test1','tt'};

          QE_Intacct_FutureCallout.XMLLogicLoop(1,arr,parentEle,'test',strset);
          QE_Intacct_FutureCallout.XMLLogicLoop(2,arr,parentEle,'test',strset);
          doc = new DOM.Document();
          QE_Intacct_FutureCallout.getIntcctData('test','test',cs,doc);
          QE_Intacct_FutureCallout.hasSObjectField('test',oppRec);

          QE_Intacct_FutureCallout.dateLogic('year',accRec,'createddate',parentEle,null,null,null,null);
          QE_Intacct_FutureCallout.dateLogic('month',accRec,'createddate',parentEle,null,null,null,null);
          QE_Intacct_FutureCallout.dateLogic('day',accRec,'createddate',parentEle,null,null,null,null);

          //QE_Intacct_FutureCallout.paymentUpdateIntacct('07MW0000004KXj5');
    }
    }



   public static testMethod void testmethod4(){
        User u = new User(
       ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
       LastName = 'last',
       Email = 'intact@test.com',
       Username = 'intact@test.com' + System.currentTimeMillis(),
       CompanyName = 'TEST',
       Title = 'title',
       Alias = 'alias',
       TimeZoneSidKey = 'America/Los_Angeles',
       EmailEncodingKey = 'UTF-8',
       LanguageLocaleKey = 'en_US',
       LocaleSidKey = 'en_US',
       Intacct_Employee_Id__c = '123'
    );
    Insert u;
    System.RunAs(u) {

        String Accrecid = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        String Accrecid1 = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId  = Accrecid;
        acc.Name = 'testName';
        acc.From_Lead_Convert__c = true;
        acc.Record_Id__c = 'Sales Order-SO0050';
        insert acc;

        Contact contact = new Contact();
        contact.accountid = acc.id;
        contact.lastname='test';
        contact.email='test@test.com';
        contact.Primary_Contact__c  = true;
        contact.Record_Id__c = 'Sales Order-SO0050';
        insert contact;

        QE360_Event__c   evt = new QE360_Event__c();
        evt.Name = 'test event';
        evt.Start_Date__c = Date.Parse('8/21/2015');
        evt.End_Date__c = Date.Parse('8/24/2015');
        insert evt;

        String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecid;
        opp.accountid = acc.id;
        opp.Name = 'test opportunity';
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.Event__c = evt.id;
        opp.CloseDate = date.parse('12/27/2017');
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Record_Id__c  = 'Sales Order-SO0050';
        opp.OwnerId  = u.Id;
        opp.Primary_Contact__c = contact.Id;
        opp.AP_Contact_Email__c = 'aa@aa.com';
        opp.AP_Contact_Phone__c = '002255655';
        opp.AP_Contact_Name__c = 'test';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;

        Payment_Term__c oppPaymentTerms = new Payment_Term__c();
        oppPaymentTerms.Opportunity__c = opp.id;
        insert oppPaymentTerms;

        Payment_Term__c objOppTerms = new Payment_Term__c();
        objOppTerms.Opportunity__c = opp.Id;
        objOppTerms.Amount__c = 10;
        objOppTerms.Status__c = 'Pending';
        objOppTerms.Payment_Term__c = '100%';
        objOppTerms.Intacct_Id__c = '1245';
    //  objOppTerms.Opportunity_Event_Start_Date__c = system.today();
    //  objOppTerms.Event_Payment_Term_Start_Date__c = system.today();
        insert objOppTerms;

        List<Payment_Term__c> lstPayment = new List<Payment_Term__c> ();
        lstPayment.add(objOppTerms);

    QE_ExceptionHandling_Email__c SFDCEmail = new QE_ExceptionHandling_Email__c();
        //SFDCEmail.BCC_Address__c = 'test@test.com';
        SFDCEmail.CC_Address__c = 'test@test.com';
        SFDCEmail.To_Address__c = 'test@test.com';
        insert SFDCEmail;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
        SFDCToIntacctMapObj.SF_Object__c = 'Contact';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;


        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = null;
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id.id.id';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = true;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id.id';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'update';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Amount__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Amount__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Payment_Terms__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Id';
        SFDCToIntacctMapObj.SF_Object__c = 'QE360_Event__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'sotransitems.sotransitem.employeeid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 5.24;
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Intacct_Employee_Id__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customfields.customfield.customfieldname';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 5.24;
        SFDCToIntacctMapObj.Constant_Value__c = 'AP_CONTACT_EMAIL';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customfields.customfield.customfieldvalue';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 5.24;
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'AP_Contact_Email__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customfields.customfield.customfieldname';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 5.24;
        SFDCToIntacctMapObj.Constant_Value__c = 'AP_CONTACT_PHONE';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customfields.customfield.customfieldvalue';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 5.24;
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'AP_Contact_Phone__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;


        Intacct_API_Details__c Intacct = new Intacct_API_Details__c();
        Intacct.CompanyId__c = 'test';
        Intacct.EndpointURL__c = 'test';
        Intacct.Password__c = 'test';
        Intacct.SenderId__c = 'test';
        Intacct.SenderPassword__c = 'test';
        Intacct.UserName__c = 'test';
        Intacct.Production__c = true;
        insert Intacct;

        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        system.debug('Intacct_API_Details__c==>'+cs);
        DOM.Document accdoc = new DOM.Document();
        List<Exception_Log__c> excLogList = new List<Exception_Log__c>();
        List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
        SObject accRec = [select id,createddate,RecordTypeId,Name,Record_Id__c,Description from account where id=:acc.id];
        SObject conRec = [select id,RecordTypeId,lastname,Record_Id__c from Contact where id=:contact.id];
        SObject oppRec = [SELECT Id, Name, AccountID, Account.RecordTypeId,Event__c,Record_Id__c,Intacct_Id__c,Intacct_Employee_Id__c FROM Opportunity WHERE Id =: opp.id];
        List<SObject> eveReclst = [SELECT Id,Start_Date__c FROM QE360_Event__c];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type1'));
        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
    //QE_Intacct_FutureCallout.intSummaryWrap obj = new QE_Intacct_FutureCallout.intSummaryWrap();
        List<QE_Intacct_FutureCallout.intSummaryWrap> intSummList = new List<QE_Intacct_FutureCallout.intSummaryWrap>();
      // QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'paymentterm', lstPayment[0],excLogList,reResList,opp.id,lstPayment,intSummList);

        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type2'));



        //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);
       // QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'CUST', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);
        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
      //  Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type4'));
       //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);
    //  Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type6'));
       //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);

     //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'payment', lstPayment[0],excLogList,reResList,null,null,null);
     Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type6'));
     QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'paymentterm', lstPayment[0],excLogList,reResList,opp.id,lstPayment,intSummList,false);
        Test.stopTest();

        DOM.Document getAccdoc = new DOM.Document();
     //   QE_Intacct_FutureCallout.intacctGetCallout(cs, getAccdoc, accRec,excLogList, reResList,opp.id);

        List<SFDCToIntacctMap_Old__c> accMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> conMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> payMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> oppMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> eveMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> allMapList = new List<SFDCToIntacctMap_Old__c>();
         for(SFDCToIntacctMap_Old__c sti: [SELECT Id,Line_Item__c, Intacct_Object__c, Name, Custom_Logic__c,Active__c, Operation__c,Type__c, Constant_Value__c, Description__c, Intacct_Node_Name__c, Intacct_Table__c, Sequence__c, SF_Field_API_Name__c, SF_Object__c FROM SFDCToIntacctMap_Old__c WHERE Active__c =: true ORDER BY Sequence__c]){
                allMapList.add(sti);
                if(sti.SF_Object__c == 'Account'){
                    accMapList.add(sti);
                }else if(sti.SF_Object__c == 'Contact'){
                    conMapList.add(sti);
                }else if(sti.SF_Object__c == 'Opportunity_Payment_Terms__c'){
                    payMapList.add(sti);
                }else if(sti.SF_Object__c == 'Opportunity'){
                    oppMapList.add(sti);
                }else if(sti.SF_Object__c == 'QE360_Event__c'){
                    eveMapList.add(sti);
                }

            }
             Map<String,Sobject> objRecordMap = new Map<String,Sobject>();
             objRecordMap.put('Opportunity',oppRec);
             objRecordMap.put('Account',accRec);
             objRecordMap.put('Contact',conRec);
             set<string> elseset = new set<string>();


            DOM.Document doc = new DOM.Document();
            dom.XmlNode function = QE_Intacct_FutureCallout.controlAuthXML(cs, doc, null);
        dom.XmlNode parentEle;
        parentEle = function.addChildElement('test', null, null);

        set<string> elseset1 = new set<string>();
        elseset1.add('test');
        QE_Intacct_FutureCallout.genContentXML(allMapList,accMapList[2].Intacct_Table__c,accMapList[2].Operation__c,accRec,cs,parentEle,conRec,objRecordMap,accMapList[2].Intacct_Object__c,elseset1,lstPayment,null);

        QE_Intacct_FutureCallout.genLineItemXML(allMapList,accMapList[1].Intacct_Table__c,accMapList[1].Operation__c,accRec,parentEle,objRecordMap,accMapList[1].Intacct_Object__c,elseset1,null,null);
        QE_Intacct_FutureCallout.genLineItemXML(allMapList,accMapList[2].Intacct_Table__c,accMapList[2].Operation__c,accRec,parentEle,objRecordMap,accMapList[2].Intacct_Object__c,elseset1,null,null);

        Set<String> strset = new Set<String>();
        strset.add('test');
        // QE_Intacct_FutureCallout.customLogic(accMapList[2],parentEle,lstPayment[0],accRec,strset);,

          String[] arr = new String[]{'test1','tt'};

          QE_Intacct_FutureCallout.XMLLogicLoop(1,arr,parentEle,'test',strset);
          QE_Intacct_FutureCallout.XMLLogicLoop(2,arr,parentEle,'test',strset);
          doc = new DOM.Document();
          QE_Intacct_FutureCallout.getIntcctData('test','test',cs,doc);
          QE_Intacct_FutureCallout.hasSObjectField('test',oppRec);

          QE_Intacct_FutureCallout.dateLogic('year',accRec,'createddate',parentEle,null,null,null,null);
          QE_Intacct_FutureCallout.dateLogic('month',accRec,'createddate',parentEle,null,null,null,null);
          QE_Intacct_FutureCallout.dateLogic('day',accRec,'createddate',parentEle,null,null,null,null);

          //QE_Intacct_FutureCallout.paymentUpdateIntacct('07MW0000004KXj5');
    }
    }

     public static testMethod void testmethod2(){
        User u = new User(
       ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
       LastName = 'last',
       Email = 'intact@test.com',
       Username = 'intact@test.com' + System.currentTimeMillis(),
       CompanyName = 'TEST',
       Title = 'title',
       Alias = 'alias',
       TimeZoneSidKey = 'America/Los_Angeles',
       EmailEncodingKey = 'UTF-8',
       LanguageLocaleKey = 'en_US',
       LocaleSidKey = 'en_US',
       Intacct_Employee_Id__c = '123'
    );
    Insert u;
    System.RunAs(u) {

    String Accrecid = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId  = Accrecid;
        acc.Name = 'testName';
        acc.From_Lead_Convert__c = true;
        acc.Record_Id__c = 'Sales Order-SO0050';
        insert acc;


        Contact contact = new Contact();
        contact.accountid = acc.id;
        contact.lastname='test';
        contact.email='test@test.com';
        contact.Primary_Contact__c  = true;
        contact.Record_Id__c = 'Sales Order-SO0050';
        insert contact;

        QE360_Event__c   evt = new QE360_Event__c();
        evt.Name = 'test event';
        evt.Start_Date__c = Date.Parse('8/21/2015');
        evt.End_Date__c = Date.Parse('8/24/2015');
        insert evt;



        String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecid;
        opp.accountid = acc.id;
        opp.Name = 'test opportunity';
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.Event__c = evt.id;
        opp.CloseDate = date.parse('12/27/2017');
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Record_Id__c  = 'Sales Order-SO0050';
        opp.OwnerId  = u.Id;
        opp.Primary_Contact__c = contact.Id;
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;

        Payment_Term__c objOppTerms = new Payment_Term__c();
        objOppTerms.Opportunity__c = opp.Id;
        objOppTerms.Amount__c = 10;
        objOppTerms.Status__c = 'Pending';
        objOppTerms.Payment_Term__c = '100%';
        objOppTerms.Payment_Due_Date__c = system.today();
        objOppTerms.Payment_Method__c = 'Credit Card';
        objOppTerms.Charge_Date__c = system.today();
        insert objOppTerms;

        List<SObject> lstPayment = [SELECT Id,Opportunity_Event_Start_Date__c,Payment_Term__c, International_Stripe__c,
                                    Opportunity_Payment_Term__c,Payment_Due_Date__c, Opportunity_Currency__c
                                    FROM Payment_Term__c where Id=:objOppTerms.Id];

    QE_ExceptionHandling_Email__c SFDCEmail = new QE_ExceptionHandling_Email__c();
        //SFDCEmail.BCC_Address__c = 'test@test.com';
        SFDCEmail.CC_Address__c = 'test@test.com';
        SFDCEmail.To_Address__c = 'test@test.com';
        insert SFDCEmail;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
        SFDCToIntacctMapObj.SF_Object__c = 'Contact';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'description';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.1;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Contact';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = true;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Constant_Value__c = null;
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Amount__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Payment_Terms__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Id';
        SFDCToIntacctMapObj.SF_Object__c = 'QE360_Event__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

    SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'sotransitems.sotransitem.employeeid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 5.24;
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Intacct_Employee_Id__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj2 = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj2.Active__c = true;
        SFDCToIntacctMapObj2.Constant_Value__c = 'each';
        SFDCToIntacctMapObj2.Description__c = 'true';
        SFDCToIntacctMapObj2.Intacct_Node_Name__c = 'datecreated.year';
        SFDCToIntacctMapObj2.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj2.Operation__c = 'create';
        SFDCToIntacctMapObj2.Sequence__c = 2.0;
        SFDCToIntacctMapObj2.Type__c = 'date';
       // SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Id';
        SFDCToIntacctMapObj2.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj2.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj2;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj1 = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj1.Active__c = true;
        SFDCToIntacctMapObj1.Constant_Value__c = null;
        SFDCToIntacctMapObj1.Description__c = 'true';
        SFDCToIntacctMapObj1.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj1.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj1.Operation__c = 'create';
        SFDCToIntacctMapObj1.Sequence__c = 2.0;
        SFDCToIntacctMapObj1.Type__c = 'true';
        SFDCToIntacctMapObj1.SF_Field_API_Name__c = 'Id';
        SFDCToIntacctMapObj1.SF_Object__c = 'QE360_Event__c';
        SFDCToIntacctMapObj1.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj1;

         SFDCToIntacctMapObj2 = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj2.Active__c = true;
     //   SFDCToIntacctMapObj2.Constant_Value__c = 'each';
        SFDCToIntacctMapObj2.Description__c = 'true';
        SFDCToIntacctMapObj2.Intacct_Node_Name__c = 'datecreated.year';
        SFDCToIntacctMapObj2.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj2.Operation__c = 'create';
        SFDCToIntacctMapObj2.Sequence__c = 2.0;
        SFDCToIntacctMapObj2.Type__c = 'date';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Start_Date__c';
        SFDCToIntacctMapObj2.SF_Object__c = 'QE360_Event__c';
        SFDCToIntacctMapObj2.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj2;

        SFDCToIntacctMapObj2 = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj2.Active__c = true;
     //   SFDCToIntacctMapObj2.Constant_Value__c = 'each';
        SFDCToIntacctMapObj2.Description__c = 'true';
        SFDCToIntacctMapObj2.Intacct_Node_Name__c = 'datecreated.year';
        SFDCToIntacctMapObj2.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj2.Operation__c = 'create';
        SFDCToIntacctMapObj2.Sequence__c = 2.0;
        SFDCToIntacctMapObj2.Type__c = 'date';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'End_Date__c';
        SFDCToIntacctMapObj2.SF_Object__c = 'QE360_Event__c';
        SFDCToIntacctMapObj2.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj2;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj22 = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj22.Active__c = true;
        SFDCToIntacctMapObj22.Constant_Value__c = 'each';
        SFDCToIntacctMapObj22.Description__c = 'true';
        SFDCToIntacctMapObj22.Intacct_Node_Name__c = 'datecreated.year';
        SFDCToIntacctMapObj22.Intacct_Table__c = 'update_sotransaction';
        SFDCToIntacctMapObj22.Operation__c = 'create';
        SFDCToIntacctMapObj22.Sequence__c = 2.0;
        SFDCToIntacctMapObj22.Type__c = 'date';
       // SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Id';
        SFDCToIntacctMapObj22.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj22.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj22;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj33 = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj33.Active__c = true;
        SFDCToIntacctMapObj33.Constant_Value__c = 'each';
        SFDCToIntacctMapObj33.Description__c = 'true';
        SFDCToIntacctMapObj33.Intacct_Node_Name__c = 'datecreated.month';
        SFDCToIntacctMapObj33.Intacct_Table__c = 'update_sotransaction';
        SFDCToIntacctMapObj33.Operation__c = 'create';
        SFDCToIntacctMapObj33.Sequence__c = 2.0;
        SFDCToIntacctMapObj33.Type__c = 'date';
       // SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Id';
        SFDCToIntacctMapObj33.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj33.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj33;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj44 = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj44.Active__c = true;
        SFDCToIntacctMapObj44.Constant_Value__c = 'each';
        SFDCToIntacctMapObj44.Description__c = 'true';
        SFDCToIntacctMapObj44.Intacct_Node_Name__c = 'datecreated.day';
        SFDCToIntacctMapObj44.Intacct_Table__c = 'update_sotransaction';
        SFDCToIntacctMapObj44.Operation__c = 'create';
        SFDCToIntacctMapObj44.Sequence__c = 2.0;
        SFDCToIntacctMapObj44.Type__c = 'date';
       // SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Id';
        SFDCToIntacctMapObj44.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj44.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj44;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj55 = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj55.Active__c = true;
        SFDCToIntacctMapObj55.Constant_Value__c = 'each';
        SFDCToIntacctMapObj55.Description__c = 'true';
        SFDCToIntacctMapObj55.Intacct_Node_Name__c = 'datecreated.day';
        SFDCToIntacctMapObj55.Intacct_Table__c = 'update_sotransaction';
        SFDCToIntacctMapObj55.Operation__c = 'create';
        SFDCToIntacctMapObj55.Sequence__c = 2.0;
        SFDCToIntacctMapObj55.Type__c = 'Custom Setting';
       // SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Id';
        SFDCToIntacctMapObj55.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj55.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj55;

        SFDCToIntacctMapObj55 = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj55.Active__c = true;
        //SFDCToIntacctMapObj55.Constant_Value__c = 'each';
        SFDCToIntacctMapObj55.Description__c = 'true';
        SFDCToIntacctMapObj55.Intacct_Node_Name__c = 'sotransitems.sotransitem.locationid';
        SFDCToIntacctMapObj55.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj55.Operation__c = 'create';
        SFDCToIntacctMapObj55.Sequence__c = 11.50;
        SFDCToIntacctMapObj55.Type__c = 'Custom Setting';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Location_Id__c';
        SFDCToIntacctMapObj55.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj55.Intacct_Object__c = 'ARPayment';
        SFDCToIntacctMapObj.Line_Item__c = true;
        insert SFDCToIntacctMapObj55;

        SFDCToIntacctMapObj55 = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj55.Active__c = true;
        //SFDCToIntacctMapObj55.Constant_Value__c = 'each';
        SFDCToIntacctMapObj55.Description__c = 'true';
        SFDCToIntacctMapObj55.Intacct_Node_Name__c = 'sotransitems.sotransitem.locationid';
        SFDCToIntacctMapObj55.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj55.Operation__c = 'create';
        SFDCToIntacctMapObj55.Sequence__c = 11.50;
        SFDCToIntacctMapObj55.Type__c = 'Custom Setting';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Charge_Date__c';
        SFDCToIntacctMapObj55.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj55.Intacct_Object__c = 'ARPayment';
        SFDCToIntacctMapObj.Line_Item__c = true;
        insert SFDCToIntacctMapObj55;

        User objUser = [SELECT Id,Intacct_Employee_Id__c FROM User where Id=:userinfo.getuserId()];
        objUser.Intacct_Employee_Id__c = null;
        update objUser;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type1'));
         SObject oppRec = [SELECT Id, Name, AccountID, Account.RecordTypeId,Event__c,Record_Id__c,Intacct_Id__c,Intacct_Employee_Id__c FROM Opportunity WHERE Id =: opp.id];
        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);

        Intacct_API_Details__c Intacct = new Intacct_API_Details__c();
        Intacct.CompanyId__c = 'test';
        Intacct.EndpointURL__c = 'test';
        Intacct.Password__c = 'test';
        Intacct.SenderId__c = 'test';
        Intacct.SenderPassword__c = 'test';
        Intacct.UserName__c = 'test';
        Intacct.Production__c = true;
        insert Intacct;

        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        system.debug('Intacct_API_Details__c==>'+cs);
        DOM.Document accdoc = new DOM.Document();
        List<Exception_Log__c> excLogList = new List<Exception_Log__c>();
        List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
        SObject accRec = [select id,RecordTypeId,Name,Record_Id__c from account where id=:acc.id];
        SObject conRec = [select id,RecordTypeId,lastname,Record_Id__c from Contact where id=:contact.id];

        List<SObject> eveReclst = [SELECT Id,Start_Date__c FROM QE360_Event__c];

        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type4'));
        //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id);
    List<QE_Intacct_FutureCallout.intSummaryWrap> intSummList = new List<QE_Intacct_FutureCallout.intSummaryWrap>();
    //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'payment', lstPayment[0],excLogList,reResList,opp.id,lstPayment,intSummList);
        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type5'));
    //QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
//        QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id);

        DOM.Document getAccdoc = new DOM.Document();
     //   QE_Intacct_FutureCallout.intacctGetCallout(cs, getAccdoc, accRec,excLogList, reResList,opp.id);
        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type5'));
     //   QE_Intacct_FutureCallout.intacctGetCallout(cs, getAccdoc, accRec,excLogList, reResList,opp.id);
        Test.stopTest();
        List<SFDCToIntacctMap_Old__c> accMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> conMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> payMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> oppMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> eveMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> allMapList = new List<SFDCToIntacctMap_Old__c>();
         for(SFDCToIntacctMap_Old__c sti: [SELECT Id, Line_Item__c,Intacct_Object__c, Name, Active__c, Operation__c,Type__c, Constant_Value__c, Description__c, Intacct_Node_Name__c, Intacct_Table__c, Sequence__c, SF_Field_API_Name__c, SF_Object__c FROM SFDCToIntacctMap_Old__c WHERE Active__c =: true ORDER BY Sequence__c]){
                allMapList.add(sti);
                if(sti.SF_Object__c == 'Account'){
                    accMapList.add(sti);
                }else if(sti.SF_Object__c == 'Contact'){
                    conMapList.add(sti);
                }else if(sti.SF_Object__c == 'Opportunity_Payment_Terms__c'){
                    payMapList.add(sti);
                }else if(sti.SF_Object__c == 'Opportunity'){
                    oppMapList.add(sti);
                }else if(sti.SF_Object__c == 'QE360_Event__c'){
                    eveMapList.add(sti);
                }

            }
        set<string> elseset = new set<string>();
        Map<String,Sobject> objRecordMap = new Map<String,Sobject>();
        objRecordMap.put('Opportunity',oppRec);
        objRecordMap.put('Account',accRec);
        objRecordMap.put('Contact',conRec);
        //    QE_Intacct_FutureCallout.genContentXML(allMapList,'intacctObj',accMapList[0].Operation__c,accRec,cs,accdoc,conRec,objRecordMap,accMapList[0].Intacct_Object__c,elseset,lstPayment);
        DOM.Document doc = new DOM.Document();
        dom.XmlNode function = QE_Intacct_FutureCallout.controlAuthXML(cs, doc,null);
        dom.XmlNode parentEle;
        parentEle = function.addChildElement('test', null, null);
        Set<String> strset = new Set<String>();
        strset.add('test');
        QE_Intacct_FutureCallout.customLogic(SFDCToIntacctMapObj2,parentEle,lstPayment[0],oppRec,strset);

          String[] arr = new String[]{'test'};

          QE_Intacct_FutureCallout.XMLLogicLoop(1,arr,parentEle,'test',strset);
          doc = new DOM.Document();
          QE_Intacct_FutureCallout.getIntcctData('test','test',cs,doc);
          QE_Intacct_FutureCallout.hasSObjectField('test',oppRec);

          Intacct_Undeposited_Funds_Account__c objIntacctUndeposited = new Intacct_Undeposited_Funds_Account__c(Name='10021');
          objIntacctUndeposited.Account_Number__c = '10021';
          objIntacctUndeposited.Currency__c = 'USD';
          objIntacctUndeposited.EUR_Clearing_Account__c = 'EUR_Clearing Account';
          objIntacctUndeposited.GBP_Clearing_Account__c = 'GBP_Clearing Account';
          insert objIntacctUndeposited;
          QE_Intacct_FutureCallout.customLogic(SFDCToIntacctMapObj22,parentEle,lstPayment[0],accRec,strset);
          QE_Intacct_FutureCallout.customLogic(SFDCToIntacctMapObj33,parentEle,lstPayment[0],accRec,strset);
          QE_Intacct_FutureCallout.customLogic(SFDCToIntacctMapObj44,parentEle,lstPayment[0],accRec,strset);
          QE_Intacct_FutureCallout.customLogic(SFDCToIntacctMapObj55,parentEle,lstPayment[0],accRec,strset);

    }
    }
     public static testMethod void testmethod3(){
        User u = new User(
           ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
           LastName = 'last',
           Email = 'intact@test.com',
           Username = 'intact@test.com' + System.currentTimeMillis(),
           CompanyName = 'TEST',
           Title = 'title',
           Alias = 'alias',
           TimeZoneSidKey = 'America/Los_Angeles',
           EmailEncodingKey = 'UTF-8',
           LanguageLocaleKey = 'en_US',
           LocaleSidKey = 'en_US',
           Intacct_Employee_Id__c = '123'
        );
        Insert u;

        System.RunAs(u) {
            String Accrecid = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            Account acc = new Account();
            acc.RecordTypeId  = Accrecid;
            acc.Name = 'testName';
            acc.From_Lead_Convert__c = true;
            acc.Record_Id__c = 'Sales Order-SO0050';
            insert acc;

            Contact contact = new Contact();
            contact.accountid = acc.id;
            contact.lastname='test';
            contact.email='test@test.com';
            contact.Primary_Contact__c  = true;
            contact.Record_Id__c = 'Sales Order-SO0050';
            insert contact;

            QE360_Event__c   evt = new QE360_Event__c();
            evt.Name = 'test event';
            evt.Start_Date__c = Date.Parse('8/21/2015');
            evt.End_Date__c = Date.Parse('8/24/2015');
            insert evt;

            String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();
            Opportunity opp = new Opportunity();
            opp.RecordTypeId = oppRecid;
            opp.accountid = acc.id;
            opp.Name = 'test opportunity';
            opp.StageName = 'Qualified';
            opp.Payment_Method__c = 'Check';
            opp.Event__c = evt.id;
            opp.CloseDate = date.parse('12/27/2017');
            opp.Contact_Site__c = 'barrettjacksonvip.com';
            opp.Record_Id__c  = 'Sales Order-SO0050';
            opp.OwnerId  = u.Id;
            opp.Primary_Contact__c = contact.Id;
            opp.AP_Contact_Email__c = 'test@gmail.com';
            opp.AP_Contact_Name__c  = 'test';
            opp.AP_Contact_Phone__c = '7623745';
            opp.Pricebook2Id = Test.getStandardPricebookId();
            insert opp;

            Payment_Term__c objOppTerms = new Payment_Term__c();
            objOppTerms.Opportunity__c = opp.Id;
            objOppTerms.Amount__c = 10;
            objOppTerms.Status__c = 'Pending';
            objOppTerms.Payment_Term__c = '100%';
            objOppTerms.Record_Id__c = 'Sales Invoice-INV0037';
            objOppTerms.Payment_Method__c = 'Credit Card';
            objOppTerms.Charge_Date__c = System.Today();
            insert objOppTerms;

            List<SObject> lstPayment = [SELECT Id,Opportunity_Event_Start_Date__c,Payment_Term__c FROM Payment_Term__c where Id=:objOppTerms.Id];

            QE_ExceptionHandling_Email__c SFDCEmail = new QE_ExceptionHandling_Email__c();
            //SFDCEmail.BCC_Address__c = 'test@test.com';
            SFDCEmail.CC_Address__c = 'test@test.com';
            SFDCEmail.To_Address__c = 'test@test.com';
            insert SFDCEmail;

            SFDCToIntacctMap_Old__c SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj.Active__c = true;
            SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'true';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
            SFDCToIntacctMapObj.SF_Object__c = 'Contact';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
            SFDCToIntacctMapObj.Line_Item__c = false;
            insert SFDCToIntacctMapObj;

            SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj.Active__c = true;
            SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'true';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
            SFDCToIntacctMapObj.SF_Object__c = 'Account';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
            SFDCToIntacctMapObj.Line_Item__c = false;
            insert SFDCToIntacctMapObj;

            SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj.Active__c = true;
            SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'true';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
            SFDCToIntacctMapObj.SF_Object__c = 'Account';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
            SFDCToIntacctMapObj.Line_Item__c = true;
            insert SFDCToIntacctMapObj;

            SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj.Active__c = true;
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Constant_Value__c = null;
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'true';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
            SFDCToIntacctMapObj.SF_Object__c = 'Account';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
            SFDCToIntacctMapObj.Line_Item__c = false;
            insert SFDCToIntacctMapObj;

            SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj.Active__c = true;
            SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'true';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Amount__c';
            SFDCToIntacctMapObj.SF_Object__c = 'Opportunity_Payment_Terms__c';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
            SFDCToIntacctMapObj.Line_Item__c = false;
            insert SFDCToIntacctMapObj;

            SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj.Active__c = true;
            SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'true';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Payment_Terms__c';
            SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
            SFDCToIntacctMapObj.Line_Item__c = false;
            insert SFDCToIntacctMapObj;

            SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj.Active__c = true;
            SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.0;
            SFDCToIntacctMapObj.Type__c = 'true';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Id';
            SFDCToIntacctMapObj.SF_Object__c = 'QE360_Event__c';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
            SFDCToIntacctMapObj.Line_Item__c = false;
            insert SFDCToIntacctMapObj;

            SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj.Active__c = true;
            SFDCToIntacctMapObj.Constant_Value__c = 'each';
            SFDCToIntacctMapObj.Description__c = 'true';
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'description';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 2.1;
            SFDCToIntacctMapObj.Type__c = 'true';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
            SFDCToIntacctMapObj.SF_Object__c = 'Contact';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
            SFDCToIntacctMapObj.Line_Item__c = false;
            insert SFDCToIntacctMapObj;

            SFDCToIntacctMap_Old__c SFDCToIntacctMapObj2 = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj2.Active__c = true;
            SFDCToIntacctMapObj2.Constant_Value__c = 'each';
            SFDCToIntacctMapObj2.Description__c = 'true';
            SFDCToIntacctMapObj2.Intacct_Node_Name__c = 'datecreated.year';
            SFDCToIntacctMapObj2.Intacct_Table__c = 'create_arpayment';
            SFDCToIntacctMapObj2.Operation__c = 'create';
            SFDCToIntacctMapObj2.Sequence__c = 2.0;
            SFDCToIntacctMapObj2.Type__c = 'date';
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Payment_Method__c';
            SFDCToIntacctMapObj2.SF_Object__c = 'Opportunity_Payment_Terms__c';
            SFDCToIntacctMapObj2.Intacct_Object__c = 'Sales Invoice';
            SFDCToIntacctMapObj2.Line_Item__c = false;
            SFDCToIntacctMapObj2.Custom_Logic__c = true;
            insert SFDCToIntacctMapObj2;

            SFDCToIntacctMap_Old__c SFDCToIntacctMapObj1 = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj1.Active__c = true;
            SFDCToIntacctMapObj1.Constant_Value__c = null;
            SFDCToIntacctMapObj1.Description__c = 'true';
            SFDCToIntacctMapObj1.Intacct_Node_Name__c = 'customerid';
            SFDCToIntacctMapObj1.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj1.Operation__c = 'create';
            SFDCToIntacctMapObj1.Sequence__c = 2.0;
            SFDCToIntacctMapObj1.Type__c = 'true';
            SFDCToIntacctMapObj1.SF_Field_API_Name__c = 'Id';
            SFDCToIntacctMapObj1.SF_Object__c = 'QE360_Event__c';
            SFDCToIntacctMapObj1.Intacct_Object__c = 'Sales Order';
            SFDCToIntacctMapObj.Line_Item__c = false;
            insert SFDCToIntacctMapObj1;

            SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj.Active__c = true;
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'sotransitems.sotransitem.itemid';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 7.10;
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Event_Id__c';
            SFDCToIntacctMapObj.SF_Object__c = 'Opportunity_Payment_Terms__c';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
            SFDCToIntacctMapObj.Line_Item__c = true;
            insert SFDCToIntacctMapObj;

            SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj.Active__c = true;
            SFDCToIntacctMapObj.Intacct_Node_Name__c = 'sotransitems.sotransitem.employeeid';
            SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj.Operation__c = 'create';
            SFDCToIntacctMapObj.Sequence__c = 5.24;
            SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Intacct_Employee_Id__c';
            SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
            SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
            SFDCToIntacctMapObj.Line_Item__c = false;
            insert SFDCToIntacctMapObj;

            SFDCToIntacctMap_Old__c SFDCToIntacctMapObj3 = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj3.Active__c = true;
            SFDCToIntacctMapObj3.Type__c = 'Custom Setting';
            SFDCToIntacctMapObj3.Intacct_Node_Name__c = 'sotransitems.sotransitem.employeeid';
            SFDCToIntacctMapObj3.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj3.Operation__c = 'create';
            SFDCToIntacctMapObj3.Sequence__c = 5.24;
            SFDCToIntacctMapObj3.SF_Field_API_Name__c = 'Opportunity_Currency__c';
            SFDCToIntacctMapObj3.SF_Object__c = 'Opportunity_Payment_Terms__c';
            SFDCToIntacctMapObj3.Intacct_Object__c = 'ARPayment';
            SFDCToIntacctMapObj3.Line_Item__c = false;
            insert SFDCToIntacctMapObj3;

            SFDCToIntacctMapObj3 = new SFDCToIntacctMap_Old__c();
            SFDCToIntacctMapObj3.Active__c = true;
            SFDCToIntacctMapObj3.Type__c = 'Custom Setting';
            SFDCToIntacctMapObj3.Intacct_Node_Name__c = 'sotransitems.sotransitem.employeeid';
            SFDCToIntacctMapObj3.Intacct_Table__c = 'create_sotransaction';
            SFDCToIntacctMapObj3.Operation__c = 'create';
            SFDCToIntacctMapObj3.Sequence__c = 5.24;
            SFDCToIntacctMapObj3.SF_Field_API_Name__c = 'Payment_Method__c';
            SFDCToIntacctMapObj3.SF_Object__c = 'Opportunity_Payment_Terms__c';
            SFDCToIntacctMapObj3.Intacct_Object__c = 'ARPayment';
            SFDCToIntacctMapObj3.Line_Item__c = false;
            insert SFDCToIntacctMapObj3;


            Intacct_API_Details__c cs =  new Intacct_API_Details__c(CompanyId__c = 'Value',EndpointURL__c='test', Password__c='test',SenderId__c='test', SenderPassword__c='test',UserName__c='test');
            cs.Production__c = true;
            insert cs;
            User objUser = [SELECT Id,Intacct_Employee_Id__c FROM User where Id=:userinfo.getuserId()];
            objUser.Intacct_Employee_Id__c = null;
            update objUser;

            Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type1'));
            SObject oppRec = [SELECT Id, Name, AccountID, Account.RecordTypeId,Event__c,Record_Id__c,Intacct_Id__c,Intacct_Employee_Id__c FROM Opportunity WHERE Id =: opp.id];

            Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type3'));
            QE_Intacct_FutureCallout.sendDataIntacct(oppRec.id);
            Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type5'));
            QE_Intacct_FutureCallout.getInvoiceRecordId( '123', cs);
            DOM.Document doc = new DOM.Document();
            QE_Intacct_FutureCallout.controlAuthXMLPayment(cs, doc, '100');
            QE_Intacct_FutureCallout.paymentUpdateIntacct(objOppTerms.id);
            QE_Intacct_FutureCallout.paymentUpdateIntacct(objOppTerms.id);
            QE_Intacct_FutureCallout.paymentUpdateIntacctBatch(objOppTerms.id);
           // opp.CurrencyIsoCode = 'GBP';
            opp.Primary_Attendee__c = contact.Id;

            update opp;
            Intacct_Undeposited_Funds_Account__c objIntacctUndeposited = new Intacct_Undeposited_Funds_Account__c(Name='10021');
            objIntacctUndeposited.Account_Number__c = '10021';
            objIntacctUndeposited.Currency__c = 'USD';
            objIntacctUndeposited.EUR_Clearing_Account__c = 'EUR_Clearing Account';
            objIntacctUndeposited.GBP_Clearing_Account__c = 'GBP_Clearing Account';
            insert objIntacctUndeposited;
            QE_Intacct_FutureCallout.paymentUpdateIntacctBatch(objOppTerms.id);
            QE_Intacct_FutureCallout.paymentUpdateIntacct(objOppTerms.id);
            QE_Intacct_FutureCallout.updateIntacctInvoiceAPInfo(opp.id);
            
            Dom.Document doc1 = new Dom.Document();
            //String str = '<?xml version="1.0" encoding="UTF-8"?><request><control><senderid>QuintEvents</senderid><password>8_64!JO4bA</password><controlid>1e005331-1cc7-591c-a8f6-9ad5c58c530f</controlid>  <uniqueid>false</uniqueid>      <dtdversion>3.0</dtdversion>        <includewhitespace>false</includewhitespace>    </control>  <operation>     <authentication>            <login>             <userid>jpatel</userid>             <companyid>QuintEvents-sandbox</companyid>              <password>QuinT.3774!sandbox</password>             <locationid>100</locationid>            </login>        </authentication>       <content>           <function controlid="1e005331-1cc7-591c-a8f6-9ad5c58c530f">             <update_sotransaction key="Sales Invoice-Sales Order-SO9033">                   <AP_Contact_Email>apemail123@gm.com</AP_Contact_Email>                  <AP_Contact_Name>Test AP11</AP_Contact_Name>                    <AP_Contact_Phone>(221) 321-3214</AP_Contact_Phone>             </update_sotransaction>         </function>     </content>  </operation></request>';
            //doc1.load(str);
           // QE_Intacct_FutureCallout.intacctGetCallout(cs, doc1, 'contact', contact, null, null, opp.id, null);
            //Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type10'));
            Test.stoptest();
        }
    }

    public static testMethod void testmethod7(){
        User u = new User(
       ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
       LastName = 'last',
       Email = 'intact@test.com',
       Username = 'intact@test.com' + System.currentTimeMillis(),
       CompanyName = 'TEST',
       Title = 'title',
       Alias = 'alias',
       TimeZoneSidKey = 'America/Los_Angeles',
       EmailEncodingKey = 'UTF-8',
       LanguageLocaleKey = 'en_US',
       LocaleSidKey = 'en_US',
       Intacct_Employee_Id__c = '123'
    );
    Insert u;
    System.RunAs(u) {

        String Accrecid = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        String Accrecid1 = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId  = Accrecid;
        acc.Name = 'testName';
        acc.From_Lead_Convert__c = true;
        acc.Record_Id__c = 'Sales Order-SO0050';
        insert acc;

        Contact contact = new Contact();
        contact.accountid = acc.id;
        contact.lastname='test';
        contact.email='test@test.com';
        contact.Primary_Contact__c  = true;
        contact.Record_Id__c = 'Sales Order-SO0050';
        insert contact;

        QE360_Event__c   evt = new QE360_Event__c();
        evt.Name = 'test event';
        evt.Start_Date__c = Date.Parse('8/21/2015');
        evt.End_Date__c = Date.Parse('8/24/2015');
        insert evt;

        String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecid;
        opp.accountid = acc.id;
        opp.Name = 'test opportunity';
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.Event__c = evt.id;
        opp.CloseDate = date.parse('12/27/2017');
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Record_Id__c  = 'Sales Order-SO0050';
        opp.Primary_Contact__c = contact.Id;
        opp.OwnerId  = u.Id;
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;

        Payment_Term__c oppPaymentTerms = new Payment_Term__c();
        oppPaymentTerms.Opportunity__c = opp.id;
        insert oppPaymentTerms;

        Payment_Term__c objOppTerms = new Payment_Term__c();
        objOppTerms.Opportunity__c = opp.Id;
        objOppTerms.Amount__c = 10;
        objOppTerms.Status__c = 'Pending';
        objOppTerms.Payment_Term__c = '100%';
    //  objOppTerms.Opportunity_Event_Start_Date__c = system.today();
    //  objOppTerms.Event_Payment_Term_Start_Date__c = system.today();
        insert objOppTerms;

        List<Payment_Term__c> lstPayment = new List<Payment_Term__c>();
        lstPayment.add(objOppTerms);

    QE_ExceptionHandling_Email__c SFDCEmail = new QE_ExceptionHandling_Email__c();
        //SFDCEmail.BCC_Address__c = 'test@test.com';
        SFDCEmail.CC_Address__c = 'test@test.com';
        SFDCEmail.To_Address__c = 'test@test.com';
        insert SFDCEmail;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
        SFDCToIntacctMapObj.SF_Object__c = 'Contact';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = null;
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id.id.id';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = true;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid.id.id';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'update';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Amount__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Payment_Terms__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Id';
        SFDCToIntacctMapObj.SF_Object__c = 'QE360_Event__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'sotransitems.sotransitem.employeeid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 5.24;
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Intacct_Employee_Id__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        Intacct_API_Details__c Intacct = new Intacct_API_Details__c();
        Intacct.CompanyId__c = 'test';
        Intacct.EndpointURL__c = 'test';
        Intacct.Password__c = 'test';
        Intacct.SenderId__c = 'test';
        Intacct.SenderPassword__c = 'test';
        Intacct.UserName__c = 'test';
        Intacct.UserName__c = 'test';
        Intacct.Production__c = true;
        insert Intacct;

        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        system.debug('Intacct_API_Details__c==>'+cs);
        DOM.Document accdoc = new DOM.Document();
        List<Exception_Log__c> excLogList = new List<Exception_Log__c>();
        List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
        SObject accRec = [select id,createddate,RecordTypeId,Name,Record_Id__c,Description from account where id=:acc.id];
        SObject conRec = [select id,RecordTypeId,lastname,Record_Id__c from Contact where id=:contact.id];
        SObject oppRec = [SELECT Id, Name, AccountID, Account.RecordTypeId,Event__c,Record_Id__c,Intacct_Id__c,Intacct_Employee_Id__c FROM Opportunity WHERE Id =: opp.id];
        List<SObject> eveReclst = [SELECT Id,Start_Date__c FROM QE360_Event__c];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type1'));
        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
    //QE_Intacct_FutureCallout.intSummaryWrap obj = new QE_Intacct_FutureCallout.intSummaryWrap();
        List<QE_Intacct_FutureCallout.intSummaryWrap> intSummList = new List<QE_Intacct_FutureCallout.intSummaryWrap>();
      // QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'paymentterm', lstPayment[0],excLogList,reResList,opp.id,lstPayment,intSummList);

        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type5'));


        QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'paymentterm', lstPayment[0],excLogList,reResList,opp.id,lstPayment,intSummList,false);
     //   QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);
     //   QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'CUST', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);

     //   Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type4'));
     //  QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);
     // Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type6'));
    //   QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'customer', accRec,excLogList,reResList,opp.id,lstPayment,intSummList);

    // QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'payment', lstPayment[0],excLogList,reResList,null,null,null);


  //   Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type6'));
     //QE_Intacct_FutureCallout.intactCallout(cs, accdoc, 'paymentterm', lstPayment[0],excLogList,reResList,opp.id,lstPayment,intSummList);
        Test.stopTest();

        DOM.Document getAccdoc = new DOM.Document();
     //   QE_Intacct_FutureCallout.intacctGetCallout(cs, getAccdoc, accRec,excLogList, reResList,opp.id);

        List<SFDCToIntacctMap_Old__c> accMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> conMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> payMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> oppMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> eveMapList = new List<SFDCToIntacctMap_Old__c>();
        List<SFDCToIntacctMap_Old__c> allMapList = new List<SFDCToIntacctMap_Old__c>();
         for(SFDCToIntacctMap_Old__c sti: [SELECT Id,Line_Item__c, Intacct_Object__c, Name, Custom_Logic__c,Active__c, Operation__c,Type__c, Constant_Value__c, Description__c, Intacct_Node_Name__c, Intacct_Table__c, Sequence__c, SF_Field_API_Name__c, SF_Object__c FROM SFDCToIntacctMap_Old__c WHERE Active__c =: true ORDER BY Sequence__c]){
                allMapList.add(sti);
                if(sti.SF_Object__c == 'Account'){
                    accMapList.add(sti);
                }else if(sti.SF_Object__c == 'Contact'){
                    conMapList.add(sti);
                }else if(sti.SF_Object__c == 'Opportunity_Payment_Terms__c'){
                    payMapList.add(sti);
                }else if(sti.SF_Object__c == 'Opportunity'){
                    oppMapList.add(sti);
                }else if(sti.SF_Object__c == 'QE360_Event__c'){
                    eveMapList.add(sti);
                }

            }
             Map<String,Sobject> objRecordMap = new Map<String,Sobject>();
             objRecordMap.put('Opportunity',oppRec);
             objRecordMap.put('Account',accRec);
             objRecordMap.put('Contact',conRec);
             set<string> elseset = new set<string>();


            DOM.Document doc = new DOM.Document();
            dom.XmlNode function = QE_Intacct_FutureCallout.controlAuthXML(cs, doc, '100');
        dom.XmlNode parentEle;
        parentEle = function.addChildElement('test', null, null);

        set<string> elseset1 = new set<string>();
        elseset1.add('test');
        QE_Intacct_FutureCallout.genContentXML(allMapList,accMapList[2].Intacct_Table__c,accMapList[2].Operation__c,accRec,cs,parentEle,conRec,objRecordMap,accMapList[2].Intacct_Object__c,elseset1,lstPayment,null);

        QE_Intacct_FutureCallout.genLineItemXML(allMapList,accMapList[1].Intacct_Table__c,accMapList[1].Operation__c,accRec,parentEle,objRecordMap,accMapList[1].Intacct_Object__c,elseset1,null,null);
        QE_Intacct_FutureCallout.genLineItemXML(allMapList,accMapList[2].Intacct_Table__c,accMapList[2].Operation__c,accRec,parentEle,objRecordMap,accMapList[2].Intacct_Object__c,elseset1,null,null);

        Set<String> strset = new Set<String>();
        strset.add('test');
        // QE_Intacct_FutureCallout.customLogic(accMapList[2],parentEle,lstPayment[0],accRec,strset);

          String[] arr = new String[]{'test1','tt'};

          QE_Intacct_FutureCallout.XMLLogicLoop(1,arr,parentEle,'test',strset);
          QE_Intacct_FutureCallout.XMLLogicLoop(2,arr,parentEle,'test',strset);
          doc = new DOM.Document();
          QE_Intacct_FutureCallout.getIntcctData('test','test',cs,doc);
          QE_Intacct_FutureCallout.hasSObjectField('test',oppRec);

          QE_Intacct_FutureCallout.dateLogic('year',accRec,'createddate',parentEle,null,null,null,null);
          QE_Intacct_FutureCallout.dateLogic('month',accRec,'createddate',parentEle,null,null,null,null);
          QE_Intacct_FutureCallout.dateLogic('day',accRec,'createddate',parentEle,null,null,null,null);

     //  Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type5'));

    }
    }
    public static testMethod void testmethod8(){
        User u = new User(
       ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
       LastName = 'last',
       Email = 'intact@test.com',
       Username = 'intact@test.com' + System.currentTimeMillis(),
       CompanyName = 'TEST',
       Title = 'title',
       Alias = 'alias',
       TimeZoneSidKey = 'America/Los_Angeles',
       EmailEncodingKey = 'UTF-8',
       LanguageLocaleKey = 'en_US',
       LocaleSidKey = 'en_US',
       Intacct_Employee_Id__c = '123'
    );
    Insert u;
    System.RunAs(u) {

        String Accrecid = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        String Accrecid1 = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId  = Accrecid;
        acc.Name = 'testName';
        acc.From_Lead_Convert__c = true;
        acc.Record_Id__c = 'Sales Order-SO0050';
        insert acc;

        Contact contact = new Contact();
        contact.accountid = acc.id;
        contact.lastname='test';
        contact.email='test@test.com';
        contact.Primary_Contact__c  = true;
        contact.Record_Id__c = 'Sales Order-SO0050';
        insert contact;

        QE360_Event__c   evt = new QE360_Event__c();
        evt.Name = 'test event';
        evt.Start_Date__c = Date.Parse('8/21/2015');
        evt.End_Date__c = Date.Parse('8/24/2015');
        insert evt;

        String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecid;
        opp.accountid = acc.id;
        opp.Name = 'test opportunity';
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.Event__c = evt.id;
        opp.CloseDate = date.parse('12/27/2017');
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Record_Id__c  = 'Sales Order-SO0050';
        opp.OwnerId  = u.Id;
        opp.Primary_Contact__c = contact.Id;
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;

        Payment_Term__c oppPaymentTerms = new Payment_Term__c();
        oppPaymentTerms.Opportunity__c = opp.id;
        insert oppPaymentTerms;

        Payment_Term__c objOppTerms = new Payment_Term__c();
        objOppTerms.Opportunity__c = opp.Id;
        objOppTerms.Amount__c = 10;
        objOppTerms.Status__c = 'Pending';
        objOppTerms.Payment_Term__c = '100%';
    //  objOppTerms.Opportunity_Event_Start_Date__c = system.today();
    //  objOppTerms.Event_Payment_Term_Start_Date__c = system.today();
        insert objOppTerms;

        List<Payment_Term__c> lstPayment = new List<Payment_Term__c> ();
        lstPayment.add(objOppTerms);

    QE_ExceptionHandling_Email__c SFDCEmail = new QE_ExceptionHandling_Email__c();
        //SFDCEmail.BCC_Address__c = 'test@test.com';
        SFDCEmail.CC_Address__c = 'test@test.com';
        SFDCEmail.To_Address__c = 'test@test.com';
        insert SFDCEmail;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Payment_Terms__c1';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'sotransitems.sotransitem.employeeid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 5.24;
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Intacct_Employee_Id__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity1';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;


        Intacct_API_Details__c Intacct = new Intacct_API_Details__c();
        Intacct.CompanyId__c = 'test';
        Intacct.EndpointURL__c = 'test';
        Intacct.Password__c = 'test';
        Intacct.SenderId__c = 'test';
        Intacct.SenderPassword__c = 'test';
        Intacct.UserName__c = 'test';
        Intacct.Production__c = true;
        insert Intacct;

        Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
        system.debug('Intacct_API_Details__c==>'+cs);
        DOM.Document accdoc = new DOM.Document();
        List<Exception_Log__c> excLogList = new List<Exception_Log__c>();
        List<RequestResponse_Log__c> reResList = new List<RequestResponse_Log__c>();
        SObject accRec = [select id,createddate,RecordTypeId,Name,Record_Id__c,Description from account where id=:acc.id];
        SObject conRec = [select id,RecordTypeId,lastname,Record_Id__c from Contact where id=:contact.id];
        SObject oppRec = [SELECT Id, Name, AccountID, Account.RecordTypeId,Event__c,Record_Id__c,Intacct_Id__c,Intacct_Employee_Id__c FROM Opportunity WHERE Id =: opp.id];
        List<SObject> eveReclst = [SELECT Id,Start_Date__c FROM QE360_Event__c];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WebServiceMockImpl('type1'));
        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
        }
    }

    public static testMethod void testmethod9(){
         String Accrecid = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        String Accrecid1 = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId  = Accrecid;
        acc.Name = 'testName';
        acc.From_Lead_Convert__c = true;
        acc.Record_Id__c = 'Sales Order-SO0050';
        insert acc;

        Contact contact = new Contact();
        contact.accountid = acc.id;
        contact.lastname='test';
        contact.email='test@test.com';
        contact.Primary_Contact__c  = true;
        contact.Record_Id__c = 'Sales Order-SO0050';
        insert contact;

        QE360_Event__c   evt = new QE360_Event__c();
        evt.Name = 'test event';
        evt.Start_Date__c = Date.Parse('8/21/2015');
        evt.End_Date__c = Date.Parse('8/24/2015');
        insert evt;

        String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecid;
        opp.accountid = acc.id;
        opp.Name = 'test opportunity';
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.Event__c = evt.id;
        opp.CloseDate = date.parse('12/27/2017');
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Record_Id__c  = 'Sales Order-SO0050';
        opp.Primary_Contact__c = contact.Id;
        opp.Pricebook2Id = Test.getStandardPricebookId();
        // opp.OwnerId  = u.Id;
        insert opp;

        QE_ExceptionHandling_Email__c SFDCEmail = new QE_ExceptionHandling_Email__c();
        //SFDCEmail.BCC_Address__c = 'test@test.com';
        SFDCEmail.CC_Address__c = 'test@test.com';
        SFDCEmail.To_Address__c = 'test@test.com';
        insert SFDCEmail;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Payment_Terms__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description1';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
    }

    public static testMethod void testmethod10(){
         String Accrecid = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        String Accrecid1 = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId  = Accrecid;
        acc.Name = 'testName';
        acc.From_Lead_Convert__c = true;
        acc.Record_Id__c = 'Sales Order-SO0050';
        insert acc;

        Contact contact = new Contact();
        contact.accountid = acc.id;
        contact.lastname='test';
        contact.email='test@test.com';
        contact.Primary_Contact__c  = true;
        contact.Record_Id__c = 'Sales Order-SO0050';
        insert contact;

        QE360_Event__c   evt = new QE360_Event__c();
        evt.Name = 'test event';
        evt.Start_Date__c = Date.Parse('8/21/2015');
        evt.End_Date__c = Date.Parse('8/24/2015');
        insert evt;

        String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecid;
        opp.accountid = acc.id;
        opp.Name = 'test opportunity';
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.Event__c = evt.id;
        opp.CloseDate = date.parse('12/27/2017');
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Record_Id__c  = 'Sales Order-SO0050';
        opp.Primary_Contact__c = contact.Id;
        opp.Pricebook2Id = Test.getStandardPricebookId();
    // opp.OwnerId  = u.Id;
        insert opp;

        QE_ExceptionHandling_Email__c SFDCEmail = new QE_ExceptionHandling_Email__c();
        //SFDCEmail.BCC_Address__c = 'test@test.com';
        SFDCEmail.CC_Address__c = 'test@test.com';
        SFDCEmail.To_Address__c = 'test@test.com';
        insert SFDCEmail;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Payment_Terms__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

         SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name1';
        SFDCToIntacctMapObj.SF_Object__c = 'Contact';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
    }

    public static testMethod void testmethod11(){
        String Accrecid = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        String Accrecid1 = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId  = Accrecid;
        acc.Name = 'testName';
        acc.From_Lead_Convert__c = true;
        acc.Record_Id__c = 'Sales Order-SO0050';
        insert acc;

        Contact contact = new Contact();
        contact.accountid = acc.id;
        contact.lastname='test';
        contact.email='test@test.com';
        contact.Primary_Contact__c  = true;
        contact.Record_Id__c = 'Sales Order-SO0050';
        insert contact;

        QE360_Event__c   evt = new QE360_Event__c();
        evt.Name = 'test event';
        evt.Start_Date__c = Date.Parse('8/21/2015');
        evt.End_Date__c = Date.Parse('8/24/2015');
        insert evt;

        String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecid;
        opp.accountid = acc.id;
        opp.Name = 'test opportunity';
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.Event__c = evt.id;
        opp.CloseDate = date.parse('12/27/2017');
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Record_Id__c  = 'Sales Order-SO0050';
        opp.Primary_Contact__c = contact.Id;
        opp.Pricebook2Id = Test.getStandardPricebookId();
    // opp.OwnerId  = u.Id;
        insert opp;

        QE_ExceptionHandling_Email__c SFDCEmail = new QE_ExceptionHandling_Email__c();
        //SFDCEmail.BCC_Address__c = 'test@test.com';
        SFDCEmail.CC_Address__c = 'test@test.com';
        SFDCEmail.To_Address__c = 'test@test.com';
        insert SFDCEmail;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Payment_Terms__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

         SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
        SFDCToIntacctMapObj.SF_Object__c = 'Contact';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Amount__c11';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Invoice';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
    }

    public static testMethod void testmethod12(){
        String Accrecid = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        String Accrecid1 = Schema.SobjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Lead lead = new Lead();
        lead.Google_Analytics_ID__c = 'gaID';
        lead.Google_Analytics_Site_Id__c = 'gaSiteId';
        lead.FirstName = 'testName';
        lead.LastName = 'testName';
        lead.Status = 'Interested';
        lead.Source__c = 'call Virtuoso';
        lead.email='test@test.com';
        insert lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Lead testLead = [select Id, IsConverted, ConvertedAccountId, ConvertedContactId from Lead where Id = :lead.Id];
        // Account acc = new Account();
        // acc.RecordTypeId  = Accrecid;
        // acc.Name = 'testName';
        // acc.From_Lead_Convert__c = true;
        // acc.Record_Id__c = 'Sales Order-SO0050';
        // insert acc;

        // Contact contact = new Contact();
        // contact.accountid = acc.id;
        // contact.lastname='test';
        // contact.email='test@test.com';
        // contact.Primary_Contact__c  = true;
        // contact.Record_Id__c = 'Sales Order-SO0050';
        // insert contact;

        QE360_Event__c   evt = new QE360_Event__c();
        evt.Name = 'test event';
        evt.Start_Date__c = Date.Parse('8/21/2015');
        evt.End_Date__c = Date.Parse('8/24/2015');
        insert evt;

        String oppRecid = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = oppRecid;
        opp.accountid = testLead.ConvertedAccountId;
        opp.Name = 'test opportunity';
        opp.StageName = 'Qualified';
        opp.Payment_Method__c = 'Check';
        opp.Event__c = evt.id;
        opp.CloseDate = date.parse('12/27/2017');
        opp.Contact_Site__c = 'barrettjacksonvip.com';
        opp.Record_Id__c  = 'Sales Order-SO0050';
        opp.Primary_Contact__c = testLead.ConvertedContactId;
    // opp.OwnerId  = u.Id;
    opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;

        QE_ExceptionHandling_Email__c SFDCEmail = new QE_ExceptionHandling_Email__c();
        //SFDCEmail.BCC_Address__c = 'test@test.com';
        SFDCEmail.CC_Address__c = 'test@test.com';
        SFDCEmail.To_Address__c = 'test@test.com';
        insert SFDCEmail;

        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Payment_Terms__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Description';
        SFDCToIntacctMapObj.SF_Object__c = 'Account';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

         SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
        SFDCToIntacctMapObj.SF_Object__c = 'Contact';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'update';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Amount__c';
        SFDCToIntacctMapObj.SF_Object__c = 'Opportunity_Payment_Terms__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Id1';
        SFDCToIntacctMapObj.SF_Object__c = 'QE360_Event__c';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        SFDCToIntacctMapObj.Line_Item__c = false;
        insert SFDCToIntacctMapObj;

        QE_Intacct_FutureCallout.sendDataIntacct(opp.id);
        QE_Intacct_FutureCallout.dummyCoverage();
        QE_Intacct_FutureCallout.dummyCoverage1();
    }
}

//2 15%
//3 29%
//5 16%
//4 17%
//12 48%
//1 17%