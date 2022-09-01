/**
* @File Name          : MementoOrderSendToAWS.cls
* @Description        : 
* @Author             : jagrawal@addonblue.com
* @Group              : 
* @Last Modified By   : fsuraitawala@addonblue.com
* @Last Modified On   : 01-13-2021
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    08/04/2020      mpatel@addonblue.com     Initial Version
**/
global class MementoOrderSendToAWS implements Database.batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    global List<OrderItem> UpdateOrderItemList = new List<OrderItem>();
    String query;
    public MementoOrderSendToAWS(String query){
        this.query = query;
    }
    global Database.queryLocator start(Database.batchableContext bc){
        String status = 'Active';
        List<OrderItem> orderList = Database.query(query);
        if(orderList.isEmpty()){
            String csvString = '';
            csvString += 'Order Id';
            csvString += ', Order Item Id';
            csvString += ', Client Name'; 
            csvString += ', Email'; 
            csvString += ', Race';
            csvString += ', Gift Category';
            csvString += '\n';    
            System.debug('csvString-->'+csvString);
            Integer statusCode = awsCallout(csvString);
            System.debug('statusCode-->'+statusCode);
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.batchableContext bc, list<sObject> scope){
        String csvString = '';
        csvString += 'Order Id';
        csvString += ', Order Item Id';
        csvString += ', Client Name'; 
        csvString += ', Email'; 
        csvString += ', Race';
        csvString += ', Gift Category';
        csvString += '\n';
        
        Set<Id> oppId = new Set<Id>();
        System.debug('scope-->'+scope);
        System.debug('scope.size()-->'+scope.size());
        List<OrderItem> orderItemList = new List<OrderItem>();
        
        for(sobject sObj : scope){
            OrderItem oi = (OrderItem)sObj;
            oppId.add(oi.Order.OpportunityId);
            //#667 - Exclude OrderItem which are already send to AWS on Change Order
            Decimal diffQuantity = oi.Quantity;
            if(oi.QuoteLineItem.Original_Quantity__c > 0) {
                diffQuantity = oi.Quantity - oi.QuoteLineItem.Original_Quantity__c;
            }
            if(diffQuantity > 0) {
                for(Integer i = 0; i < diffQuantity; i++) {
                    orderItemList.add(oi);
                }
            }
        }
        List<OpportunityContactRole> ocrList = [Select id, Contact.Email, OpportunityId from OpportunityContactRole where OpportunityId IN: oppId and Role ='Primary Attendee Contact'];
        Map<Id, String> primaryAttendeeEmail = new Map<Id, String>();
        for(OpportunityContactRole obj : ocrList){
            primaryAttendeeEmail.put(obj.OpportunityId, obj.Contact.Email);
        }
        
        for(orderitem orderItemObj : orderItemList){
            //System.debug(orderItemObj.Order.Status);
            //OrderItem orderItemObj = (OrderItem)sObj;
            csvString += orderItemObj.OrderId;
            csvString += ','+orderItemObj.Id;
            csvString += ','+orderItemObj.Order.Account.Name.replaceAll(',',''); 
            csvString += ','+primaryAttendeeEmail.get(orderItemObj.order.OpportunityId);
            if(orderItemObj.order.Pricebook2.Name != null){ csvString += ','+orderItemObj.order.Pricebook2.Name.replaceAll(',',''); }
            csvString += ','+orderItemObj.Product2.Type__c;
            csvString += '\n';
        }
        
        System.debug('csvString-->'+csvString);
        Integer statusCode = awsCallout(csvString);
        if(statusCode == 200){
            for(sobject sObj : scope){
                OrderItem oi = (OrderItem)sObj;
                oi.Sent_To_Authentic__c = true;
                UpdateOrderItemList.add(oi);
            }
        }
    }
    global void finish(Database.batchableContext bc){
        if(!UpdateOrderItemList.isEmpty()){
            Utility.processRecords(UpdateOrderItemList, 'update');
        }
    }
    private Integer awsCallout(String csvString){
        Integration_Setting__mdt objIntegrationSetting = new Integration_Setting__mdt();
        objIntegrationSetting =  [Select Type__c,UserId__c,ConsumerKey__c,ConsumerSecret__c,Password__c from Integration_Setting__mdt where DeveloperName ='AWS_Server_Setting' and Is_Active__c = true LIMIT 1];

        String method = objIntegrationSetting.Type__c;
        String contentType = 'text/csv';
        String formattedDateforFileName = Datetime.now().formatGMT('EEE,ddMMM-yyyy-HH:mm:ssz');
        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String bucketName = objIntegrationSetting.Password__c; //AWS_S3_Settings__c.getOrgDefaults().S3_Buket_Name__c;
        String s3Key = objIntegrationSetting.ConsumerKey__c; //AWS_S3_Settings__c.getOrgDefaults().S3_Key__c;
        String s3Secret =  objIntegrationSetting.ConsumerSecret__c; //AWS_S3_Settings__c.getOrgDefaults().S3_Secret__c;
        String s3Host = objIntegrationSetting.UserId__c; //AWS_S3_Settings__c.getOrgDefaults().S3_Host__c; 
        String fileName = 'Orders-'+formattedDateforFileName+'.csv';
        system.debug('fileName-->'+fileName);
        // Encode xml data
        String encodedXmlContentString = EncodingUtil.base64Encode(Blob.valueOf(csvString));
        
        // Request
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('https://' + bucketname + '.' + s3Host + '/' + filename);
        req.setHeader('Host', bucketname + '.' + s3Host);
        req.setHeader('Content-Length', string.valueOf(encodedXmlContentString.length()));
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Content-type', contentType);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', formattedDateString);
        req.setHeader('ACL', 'public-read');
        req.setBodyAsBlob(Blob.valueOf(csvString));
        
        // Sign
        String stringToSign = method+'\n\n' +
            contentType + '\n' +
            formattedDateString + '\n' +
            '/' + bucketname + '/' + filename;
        HTTPResponse res;
        Integer statusCode;
        if(!Test.isRunningTest()) {
            String encodedStringToSign = EncodingUtil.urlEncode(stringToSign, 'UTF-8');
            Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(s3Secret));
            String signed = EncodingUtil.base64Encode(mac);
            String authHeader = 'AWS' + ' ' + s3Key + ':' + signed;
            req.setHeader('Authorization',authHeader);
            String decoded = EncodingUtil.urlDecode(encodedStringToSign , 'UTF-8');
            
            System.debug('Request:'+req);
            
            Http http = new Http(); 
            res = http.send(req);
            statusCode = res.getStatusCode();
            System.debug('*Resp:' + String.ValueOF(res.getBody()));
            System.debug('RESPONSE STRING: ' + res.toString());
            System.debug('RESPONSE STATUS: ' + res.getStatus());
            System.debug('STATUS_CODE: ' + res.getStatusCode());            
        }else{
            statusCode = 200; 
        }
        return statusCode;
    }
}