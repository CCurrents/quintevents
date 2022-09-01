// Created by : vaibhav.khopade@addonblue.com
//Created on : 26 Apr 2022
// Desc : for fix of issue 1204

global class CSVLeadBatch_LasVegasLeadsS3 implements Database.batchable<sObject>,Database.AllowsCallouts, Database.Stateful 
{
	   global String xmlFile='';
       String d = system.now().year()+'-'+system.now().month()+'-'+system.now().day();
       public Date StartDateInput;
       
    public CSVLeadBatch_LasVegasLeadsS3 (Date StartDateInp)
    {
        this.StartDateInput = StartDateInp;
    }
    
    public CSVLeadBatch_LasVegasLeadsS3(){
        d = system.now().year()+'-'+system.now().month()+'-'+system.now().day();
    }
    
    global Database.queryLocator start(Database.batchableContext bc)
    {
        Datetime dt;
        Datetime dtNextDay;
        
        if(StartDateInput != NULL){
            Date startDate = StartDateInput;
            dt = (Datetime) startDate;
            dtNextDay = dt.addDays(1);
            d= startDate.year() + '-' + startDate.month() + '-' + startDate.day();
            system.debug('*** dt = ' + dt);
            system.debug('*** d = ' + d);
        }
        else{
            dt = system.now().addhours(-48);
            system.debug('*** dt2 = ' + dt);
        }
        
        system.debug('*** startDate = ' + StartDateInput);
        system.debug('dt before SOQL =  ' + dt);
        
        String query;
        if(Test.isRunningTest()){
			query = 'SELECT FirstName,LastName,Email,Street,Visitor_Country__c,Rating,HasOptedOutOfEmail,state, country,PostalCode,Address,From_Lead_Convert__c,CreatedDate,LastModifiedDate FROM lead where createddate >= :dt AND Source__c Like \'' +'%f1experience%'+'\'';            
        }
        else
        {
       		query = 'SELECT FirstName,LastName,Email,Street,Visitor_Country__c,Rating,HasOptedOutOfEmail,state, country,PostalCode,Address,From_Lead_Convert__c,CreatedDate,LastModifiedDate, Event_Interest_Picklist__r.Name FROM lead where createddate >= :dt AND Source__c Like \'' +'%f1experience%'+'\' AND Event_Interest_Picklist__r.Name Like \'' + '%Las Vegas%' + '\'';     
        }
       
        system.debug('*** query = ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.batchableContext bc, list<sObject> scope)
    {
    	system.debug('*** inside execute ......');
        system.debug('*** size of scope = ' + scope.size());
        
           if(xmlFile == ''){
               xmlFile = '<?xml version="1.0" encoding="UTF-8"?>';
               xmlFile += '<Leads>';
           }
        
        
           for(sObject ldObj : scope)
           {
              //system.debug('*** lead object = ' + ldObj);
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
              
              //system.debug('*** xmlFile string = ' + xmlFile);
          }
       
    }
    
    global void finish(Database.batchableContext bc)
    {
        xmlFile += '</Leads>';
        String fileName = 'Las-Vegas-Leads-'+'-'+d+'.xml';
        String bucketName = 'quintevents-twocircles';
        QE_AwsS3Helper awsInst = new QE_AwsS3Helper();
        if (Test.isRunningTest() != True){
        	awsInst.uploadXmlFileToS3(xmlFile,fileName,bucketName);    
        }
        
        system.debug('-----fileName = '+fileName);
        //System.debug('xmlFile: '+xmlFile);
    }
}