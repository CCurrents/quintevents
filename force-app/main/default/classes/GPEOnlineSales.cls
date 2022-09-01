/**
* @File Name          : GPEOnlineSales.cls
* @Description        : 
* @Author             : lpanchal@addonblue.com
* @Group              : 
* @Last Modified By   : jagrawal@addonblue.com
* @Last Modified On   : 6/19/2020, 1:46:26 PM
* @Modification Log   : 
* Ver       Date            Author                  Modification
* 1.0    3/16/2020   lpanchal@addonblue.com     Initial Version
**/
@RestResource(urlMapping='/gpeonlinesale/*')
global class GPEOnlineSales {
    global List<OnlineSalesHelper.ResponseMessage> ResponseMessage {get; set;}
    @TestVisible
    private static Map<Id,Product2> insertedProductMap {get; set;}
    /**********************************************************************************
***********************************************************************************/
    /**********************************************/
    
    @HttpPost
    global static void create() {
        RequestResponse_Log__c objReqRes = new RequestResponse_Log__c();
        try{
            //String gpesale;
            List<OnlineSalesHelper.ResponseMessage> wrapperObj;
            RestRequest request = RestContext.request;
            String jsonString = request.requestBody.toString();
            System.debug('jsonString:'+jsonString);
            objReqRes.Request__c = jsonString;
            objReqRes.Class_Name__c = 'GPEOnlineSales';
            objReqRes.Method_Name__c = 'create';
            objReqRes.API_URL__c = '/services/apexrest/gpeonlinesale';
            GPE_ApexToJsonClass gpeSales = (GPE_ApexToJsonClass) JSON.deserialize(jsonString, GPE_ApexToJsonClass.class);
            string strbody = string.valueof(gpeSales);
            strbody = strbody.replace('discount=null, ','');
            strbody = strbody.replace('googleAnalyticsId=null, googleAnalyticsSiteId=null, ','');
            strbody = strbody.replace('eventId=null, ','');
            strbody = strbody.replace('hotelId=null, hotelPrice=null, hotelQty=null, includeTransportation=null, packageId=null, packagePrice=null, packageQty=null, ','');
            strbody = strbody.replace('paymentTerms=null, ','');
            strbody = strbody.replace('promoterId=null, resellerId=null, site=null, ','');
            strbody = strbody.replace('totalAfterDiscount=null, totalChargedInCurrency=null, visitorCountry=null, ','');
            strbody = strbody.replace(', sale=null','');
            System.debug('gpeSales:'+strbody);
            String[] emailStr = System.Label.Email_Notification.split(',');
            String str = 'Hello, \n\n';
            str += strbody;
            str += '\n\n';
            str += 'Thank you.';
            System.debug('str:'+str);
            String userName = UserInfo.getUserName();
            User activeUser = [Select Email From User where Username = : userName limit 1];
            String userEmail = activeUser.Email;
            try{
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {Utility.createSingleEmailMessage(emailStr, 'EndPoint Requested JSON', userName, str, false, false)});
            }
            catch(Exception ex){
                system.debug('Not able to send emails');
            }   
            System.debug('gpeSales.Gpesale'+gpeSales.Gpesale);
            Account account = OnlineSalesHelper.getAccount(gpeSales.Gpesale);
            wrapperObj = OnlineSalesHelper.createOpportunity(account, gpeSales.Gpesale);
            System.debug('wrapperObj@@@'+wrapperObj);
            Quote salesQuote = new Quote();
            
            if(wrapperObj != null && wrapperObj[0].opportunity.Id != null){
                wrapperObj = OnlineSalesHelper.crtQuote(wrapperObj[0].opportunity,wrapperObj[0].lstProduct,wrapperObj[0].OnlineSaleLineItemSet,gpeSales.Gpesale);
                RestContext.response.addHeader('Content-Type', 'application/json');
                if(wrapperObj[0].opportunity != null){ objReqRes.Opportunity__c = wrapperObj[0].opportunity.Id; }
                if(wrapperObj[0].quote != null){ objReqRes.Opportunity__c = wrapperObj[0].quote.OpportunityId; objReqRes.Quote__c = wrapperObj[0].quote.Id; }
                if(wrapperObj[0].order != null){ objReqRes.Opportunity__c = wrapperObj[0].order.OpportunityId; objReqRes.Quote__c = wrapperObj[0].order.QuoteId; objReqRes.Order__c = wrapperObj[0].order.Id; }
                objReqRes.Response__c = wrapperObj[0].str;
                objReqRes.Status_Code__c = '200';
                RestContext.response.responseBody = Blob.valueOf(wrapperObj[0].str);
            }
            else {
                if(wrapperObj[0].opportunity != null){ objReqRes.Opportunity__c = wrapperObj[0].opportunity.Id; }
                if(wrapperObj[0].quote != null){ objReqRes.Opportunity__c = wrapperObj[0].quote.OpportunityId; objReqRes.Quote__c = wrapperObj[0].quote.Id; }
                if(wrapperObj[0].order != null){ objReqRes.Opportunity__c = wrapperObj[0].order.OpportunityId; objReqRes.Quote__c = wrapperObj[0].order.QuoteId; objReqRes.Order__c = wrapperObj[0].order.Id; }
                objReqRes.Response__c = wrapperObj[0].str;
                objReqRes.Status_Code__c = '400';
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(wrapperObj[0].str);
            }
            System.debug('objReqRes:-'+objReqRes);
            
        }
        catch(Exception e){
            objReqRes.Response__c = 'Exception:- '+e.getMessage()+'=\nLineNumber=>'+e.getLinenumber()+'\nStackTrace:-'+e.getStackTraceString();
            System.debug('Exception:- '+e.getMessage()+'=LineNumber=>'+e.getLinenumber());
            Log.debug('Exception:'+e.getMessage() +'-'+e.getLinenumber());
        }
        insert objReqRes;
    }
    
}