/**
* @File Name          : ScheduledWeeklyAvailableProductsReport.cls
* @Description        : 
* @Author             : kchavda@addonblue.com
* @Group              : 
* @Last Modified By   : kchavda@addonblue.com
* @Last Modified On   : 06-16-2021
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0     06-16-2021      kchavda@addonblue.com     Initial Version
**/
global class ScheduledWeeklyAvailableProductsReport implements Schedulable {
   global void execute(SchedulableContext sc) {
        generateCSVofProductHistory();
   }
   
   public static void generateCSVofProductHistory(){
        String csvString = '';
        csvString += 'Product Id';
        csvString += ', Product Name';
        csvString += ', OldValue'; 
        csvString += ', NewValue'; 
        csvString += ', CreatedDate';
        csvString += ', CreatedBy';
        csvString += ', Pricebook Name';
        csvString += ', Current Inventory';
        csvString += '\n';                      
        
        for(Product2History objPH: [SELECT Id, Product2Id,Product2.Name, OldValue, NewValue,CreatedDate, createdby.Name,Product2.Primary_Price_Book__r.Name,Product2.Current_Inventory__c FROM Product2History where Field = 'Available__c' and createddate = Last_N_Days:7 and Product2.GPT_Article_Id__c = null]){
            csvString += objPH.Product2Id;
            csvString += ','+objPH.Product2.Name.replaceAll(',','');
            csvString += ','+objPH.OldValue; 
            csvString += ','+objPH.NewValue;
            csvString += ','+objPH.CreatedDate;
            csvString += ','+objPH.createdby.Name.replaceAll(',','');            
            if(objPH.Product2.Primary_Price_Book__r.Name != null){ csvString += ','+objPH.Product2.Primary_Price_Book__r.Name.replaceAll(',',''); }            
            csvString += ','+objPH.Product2.Current_Inventory__c;
            csvString += '\n';
        }
        
        blob csvBlob = Blob.valueOf(csvString);
        string csvname= 'Available_Products.csv';
        
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{}; 
        toAddresses.addall(system.label.Available_Products_Email_Notification.split(','));
        String subject =' Weekly Available Products Report';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody(' Weekly Available Products Report');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        if(!Test.isrunningTest()) Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
   }
}