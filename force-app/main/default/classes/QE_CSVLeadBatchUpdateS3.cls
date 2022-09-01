global class QE_CSVLeadBatchUpdateS3 implements Database.batchable<sObject>,Database.AllowsCallouts, Database.Stateful
{
    global String xmlFile='';
       String d = system.now().year()+'-'+system.now().month()+'-'+system.now().day();
       
    
    global Database.queryLocator start(Database.batchableContext bc)
    {
        Datetime dt = system.now().addhours(-48);
      
       String query = 'SELECT FirstName,LastName,Email,Street,Visitor_Country__c,Rating,HasOptedOutOfEmail,state, country,PostalCode,Address,From_Lead_Convert__c,CreatedDate,LastModifiedDate FROM lead where createddate >= :dt AND Source__c Like \'' +'%f1experience%'+'\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.batchableContext bc, list<sObject> scope)
    {
    
           if(xmlFile == ''){
               xmlFile = '<?xml version="1.0" encoding="UTF-8"?>';
               xmlFile += '<Leads>';
           }
           for(sObject ldObj : scope)
          {
                Lead ld = (lead)ldObj;
               xmlFile+= '<Lead>'+'<Title></Title>'+'<FirstName>'+(ld.FirstName== null? ld.FirstName : ld.FirstName.escapeXMl())+'</FirstName>' + '<LastName>'+(ld.LastName== null? ld.LastName :ld.LastName.escapeXml())+'</LastName>'
               +'<Email>'+(ld.Email== null? ld.Email : ld.Email.escapeXml())+'</Email>' + '<StreetLine1>'+(ld.Street == null? ld.Street :ld.Street.escapeXml())+'</StreetLine1>'+'<StreetLine2></StreetLine2>'
               +'<State>'+(ld.State== null? ld.State: ld.State.escapeXml())+'</State>'+'<Country>'+(ld.Country== null? ld.Country :ld.Country.escapeXml())+'</Country>'+'<VisitorCountry>'+(ld.Visitor_Country__c== null? ld.Visitor_Country__c:ld.Visitor_Country__c.escapeXml())+'</VisitorCountry>' + '<Rating>'+(ld.Rating== null? ld.Rating:ld.Rating.escapeXml())+'</Rating>';
               
               xmlFile+=  '<Converted>'+ld.From_lead_convert__c+'</Converted>'
               +'<CreatedDate>'+ld.CreatedDate.Date().format()+'</CreatedDate>'+'<PostalCode>'+(ld.PostalCode== null? ld.PostalCode :ld.PostalCode.escapeXml())+'</PostalCode>'+'<LastModified>'+ld.lastmodifieddate.Date().format()+'</LastModified>';
               
               if(ld.HasOptedOutOfEmail == true) {
              xmlFile+= '<Unsubscribed>'+ld.HasOptedOutOfEmail+'</Unsubscribed>'+ '<OptIn>'+'false'+'</OptIn>';
               }
              else{
             xmlFile+='<OptIn>'+ld.HasOptedOutOfEmail+'</OptIn>'+'<Unsubscribed>'+'true'+'</Unsubscribed>';
             }
              xmlFile+= '</Lead>'; 
          }

    }
    
    global void finish(Database.batchableContext bc)
    {
        xmlFile += '</Leads>';
        String fileName = 'Leads'+'-'+d+'.xml';
        String bucketName = 'quintevents-twocircles';
        QE_AwsS3Helper awsInst = new QE_AwsS3Helper();
        awsInst.uploadXmlFileToS3(xmlFile,fileName,bucketName);
        system.debug('-----'+fileName);
        System.debug('xmlFile: '+xmlFile);
    }
}