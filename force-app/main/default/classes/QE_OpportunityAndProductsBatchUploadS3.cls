global class QE_OpportunityAndProductsBatchUploadS3 implements Database.batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    
    global String xmlFile='';
    String d = system.now().year()+'-'+system.now().month()+'-'+system.now().day();
        
    global Database.queryLocator start(Database.batchableContext bc) {
        Datetime dt = system.now().addhours(-48);
        //System.debug('Query-->'+[Select Opportunity.Owner.Name, Opportunity.Name, Opportunity.CloseDate, Product2.Name, TotalPrice,Opportunity.Account.Name, Opportunity.Email__c, Opportunity.Billing_Street__c, Opportunity.Billing_City__c,Opportunity.Billing_State_Province__c, Opportunity.Billing_Zip_Postal_Code__c, Opportunity.Billing_Country__c,Opportunity.Account.PersonHasOptedOutOfEmail, Opportunity.Account.Primary_Contact__r.HasOptedOutOfEmail, Opportunity.RecordType.Name From OpportunityLineItem]);
        String query = 'Select Opportunity.Owner.Name, Opportunity.Name, Opportunity.CloseDate, Product2.Name, TotalPrice,'+
                        'Opportunity.Account.Name, Opportunity.Email__c, Opportunity.Billing_Street__c, Opportunity.Billing_City__c,'+
                        'Opportunity.Billing_State_Province__c, Opportunity.Billing_Zip_Postal_Code__c, Opportunity.Billing_Country__c,'+
                        'Opportunity.Account.PersonHasOptedOutOfEmail, Opportunity.Account.Primary_Contact__r.HasOptedOutOfEmail, Opportunity.RecordType.Name '+
                        'From OpportunityLineItem Where (lastmodifieddate >=:dt OR createddate >= :dt) And Record_Type__c = \'Package\' And '+
                        '(Opportunity.Name Like \''+'%Formula 1%'+'\' OR  Opportunity.Name Like \''+'%Innovation Series%'+'\') And '+
                        'Opportunity.StageName = \'Closed Won\'';
        System.debug('query: '+ query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.batchableContext bc, list<sObject> scope) {
        if(xmlFile == '') {
            xmlFile = '<?xml version="1.0" encoding="UTF-8"?>';
            xmlFile += '<Customers>';
        }
        for(sObject oliObj : scope) {
        
            OpportunityLineItem oli = (OpportunityLineItem)oliObj;
            System.debug('Oli: '+oli);
            xmlFile += '<Customer>'+
           
                '<OwnerName>'+(oli.Opportunity.Owner.Name == null? oli.Opportunity.Owner.Name: oli.Opportunity.Owner.Name.escapeXml())+'</OwnerName>'+
                '<OpportunityName>'+(oli.Opportunity.Name == null? oli.Opportunity.Name:oli.Opportunity.Name.escapeXml())+'</OpportunityName>'+
                '<CloseDate>'+oli.Opportunity.CloseDate.format()+'</CloseDate>'+
                '<ProductName>'+(oli.Product2.Name == null? oli.Product2.Name:oli.Product2.Name.escapeXml())+'</ProductName>'+
                '<GrandTotal>'+oli.TotalPrice+'</GrandTotal>'+
                '<AccountName>'+(oli.Opportunity.Account.Name == null? oli.Opportunity.Account.Name:oli.Opportunity.Account.Name.escapeXml())+'</AccountName>'+
                '<ClientEmail>'+(oli.opportunity.email__c == null? oli.opportunity.email__c:oli.opportunity.email__c.escapeXml())+'</ClientEmail>'+
                '<BillingStreet>'+(oli.Opportunity.Billing_Street__c == null? oli.Opportunity.Billing_Street__c:oli.Opportunity.Billing_Street__c.escapeXml())+'</BillingStreet>'+
                '<BillingCity>'+(oli.Opportunity.Billing_City__c == null? oli.Opportunity.Billing_City__c:oli.Opportunity.Billing_City__c.escapeXml())+'</BillingCity>'+
                '<BillingStateProvince>'+(oli.Opportunity.Billing_State_Province__c== null? oli.Opportunity.Billing_State_Province__c:oli.Opportunity.Billing_State_Province__c.escapeXml())+'</BillingStateProvince>'+
                '<BillingZipPostalCode>'+(oli.Opportunity.Billing_Zip_Postal_Code__c== null? oli.Opportunity.Billing_Zip_Postal_Code__c:oli.Opportunity.Billing_Zip_Postal_Code__c.escapeXml())+'</BillingZipPostalCode>'+
                '<BillingCountry>'+(oli.Opportunity.Billing_Country__c== null? oli.Opportunity.Billing_Country__c:oli.Opportunity.Billing_Country__c.escapeXml())+'</BillingCountry>';
              
            if(oli.Opportunity.RecordType.Name.equals('Person Opportunity')) {
                xmlFile += '<OptIn>'+!oli.Opportunity.Account.PersonHasOptedOutOfEmail+'</OptIn>'+
                    '<Unsubscribed>'+oli.Opportunity.Account.PersonHasOptedOutOfEmail+'</Unsubscribed>';
            }
            if(oli.Opportunity.RecordType.Name.equals('Business Opportunity')) {
                // Do something else for bussiness opportunities
                xmlFile += '<OptIn>'+!oli.Opportunity.Account.Primary_Contact__r.HasOptedOutOfEmail+'</OptIn>'+
                    '<Unsubscribed>'+oli.Opportunity.Account.Primary_Contact__r.HasOptedOutOfEmail+'</Unsubscribed>';
            }
            xmlFile += '</Customer>';
        }

    }
    
    global void finish(Database.batchableContext bc) {
        if(xmlFile != '' && xmlFile != null) {    
            xmlFile += '</Customers>';
            String fileName = 'Customers'+'-'+d+'.xml';
            String bucketName = 'quintevents-twocircles';
            QE_AwsS3Helper awsInst = new QE_AwsS3Helper();
            if(!Test.isrunningTest()){
                awsInst.uploadXmlFileToS3(xmlFile,fileName,bucketName);
            }
        }
        System.debug('xmlFile: '+xmlFile);
    }
}