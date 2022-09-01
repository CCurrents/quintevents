global class IntacctUpdateInvoices implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{ 
    
    Set<String> setOrderIds = new Set<String>();
    public IntacctUpdateInvoices(Set<String> setOrderID){
        setOrderIds = setOrderID;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select Id, Location_Id__c, Pricebook2.Name, CreatedDate, Record_Id__c, Intacct_Id__c, Status FROM Order WHERE Id IN :setOrderIds');
    }
    
    global void execute(Database.BatchableContext bc, List<Order> scope){
        Set<String> setOrder = new Set<String>();
        for(Order objOrder: scope){
            setOrder.add(objOrder.Id);
        }
        
        List<Payment_Term__c> lstPTs = [Select Id, Intacct_Id__c, Order__r.Quote_Bill_To_Name__c, Commission__c, Balance_Due__c, Order__r.Quote_Company_Name__c, Order__r.Opportunity.Order_s_Packages__c, Order__r.OrderNumber, Order__r.Location_Id__c FROM Payment_Term__c WHERE Record_Id__c != null and Status__c != 'Passed' and Status__c != 'Canceled' and Order__c IN :setOrder];

        System.debug('lstPTs'+ lstPTs.size());
        
        Integration_Setting__mdt objIntegrationSetting = new Integration_Setting__mdt();
        objIntegrationSetting =  [Select Content_Type__c,Endpoint__c,Type__c, UserId__c, Password__c,SenderId__c,SenderPassword__c,CompanyId__c from Integration_Setting__mdt where DeveloperName = 'Intacct' and Is_Active__c = true LIMIT 1];
        
        for(Payment_Term__c objPT : lstPTs){
            Dom.Document xmlDoc = new Dom.Document();
            dom.XmlNode request = xmlDoc.createRootElement('request', null, null);
            dom.XmlNode control = request.addChildElement('control', null, null);
            //control.addChildElement('senderid', null, null).addTextNode(objIntegrationSetting.UserId__c);
            //control.addChildElement('password', null, null).addTextNode(objIntegrationSetting.Password__c);
            control.addChildElement('senderid', null, null).addTextNode(objIntegrationSetting.SenderId__c);
            control.addChildElement('password', null, null).addTextNode(objIntegrationSetting.SenderPassword__c);
            control.addChildElement('controlid', null, null).addTextNode(Utility.getRandomNumber());
            control.addChildElement('uniqueid', null, null).addTextNode('false');
            control.addChildElement('dtdversion', null, null).addTextNode('3.0');
            control.addChildElement('includewhitespace', null, null).addTextNode('false');
            dom.XmlNode operation = request.addChildElement('operation', null, null);
            dom.XmlNode authentication = operation.addChildElement('authentication', null, null);
            dom.XmlNode login = authentication.addChildElement('login', null, null);
            login.addChildElement('userid', null, null).addTextNode(objIntegrationSetting.UserId__c);
            login.addChildElement('companyid', null, null).addTextNode(objIntegrationSetting.CompanyId__c);
            login.addChildElement('password', null, null).addTextNode(objIntegrationSetting.Password__c);
            login.addChildElement('locationid', null, null).addTextNode(String.valueOf(objPT.Order__r.Location_Id__c));
            
            dom.XmlNode content = operation.addChildElement('content', null, null);
            
            dom.XmlNode function = content.addChildElement('function', null, null);
            function.setAttribute('controlid', Utility.getRandomNumber());
            dom.XmlNode updateTranscation = function.addChildElement('update_sotransaction', null, null);
            if(!Test.IsRunningTest()) {
                updateTranscation.setAttribute('key', objPT.Intacct_Id__c);
            }
            
            dom.XmlNode customeFieldsTag = updateTranscation.addChildElement('customfields', null, null);
            
            
            /*String BilltoName = objPT.Order__r.Quote_Bill_To_Name__c != null ? objPT.Order__r.Quote_Bill_To_Name__c : '--'; 
            dom.XmlNode customeFieldIdTag = customeFieldsTag.addChildElement('customfield', null, null);
            customeFieldIdTag.addChildElement('customfieldname', null, null).addTextNode('BILL_TO_NAME');
            customeFieldIdTag.addChildElement('customfieldvalue', null, null).addTextNode(String.valueOf(BilltoName));
            
            /*dom.XmlNode customeFieldIdTag1 = customeFieldsTag.addChildElement('customfield', null, null);
            customeFieldIdTag1.addChildElement('customfieldname', null, null).addTextNode('BALANCE_DUE');
            customeFieldIdTag1.addChildElement('customfieldvalue', null, null).addTextNode(String.valueOf(objPT.Balance_Due__c));*/
            
            dom.XmlNode customeFieldIdTag2 = customeFieldsTag.addChildElement('customfield', null, null);
            customeFieldIdTag2.addChildElement('customfieldname', null, null).addTextNode('PACKAGE_NAME');
            customeFieldIdTag2.addChildElement('customfieldvalue', null, null).addTextNode(String.valueOf(objPT.Order__r.Opportunity.Order_s_Packages__c));
            
            if(objPT.Order__r.Quote_Company_Name__c != null){
                dom.XmlNode customeFieldIdTag3 = customeFieldsTag.addChildElement('customfield', null, null);
                customeFieldIdTag3.addChildElement('customfieldname', null, null).addTextNode('COMPANY_NAME');
                customeFieldIdTag3.addChildElement('customfieldvalue', null, null).addTextNode(String.valueOf(objPT.Order__r.Quote_Company_Name__c));
            }
            
            if(!Test.IsRunningTest()) {
                Utility.callout('Intacct',xmlDoc.toXmlString());
                System.debug(objPT.Intacct_Id__c);
            }
        }
    }    
    global void finish(Database.BatchableContext bc) {
        System.debug('Records processed. Shazam!');
    }    
}