/**
 * @File Name          : OnlineSales.cls
 * @Description        : 
 * @Author             : lpanchal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/19/2020, 4:13:39 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/17/2020   lpanchal@addonblue.com     Initial Version
**/
@RestResource(urlMapping='/OnlineSales/*')
global with sharing class OnlineSales {
    @HttpPost
    global static void create() {
        RequestResponse_Log__c objReqRes = new RequestResponse_Log__c();
        try{
            RestRequest request = RestContext.request;
            List<OnlineSalesHelper.ResponseMessage> wrapperObj ;
            String jsonString = request.requestBody.toString();
            System.debug('jsonString:'+jsonString);
            objReqRes.Request__c = jsonString;
            objReqRes.Class_Name__c = 'OnlineSales';
            objReqRes.Method_Name__c = 'create';
            objReqRes.API_URL__c = '/services/apexrest/OnlineSales';
            GPE_ApexToJsonClass sale = (GPE_ApexToJsonClass) JSON.deserialize(jsonString, GPE_ApexToJsonClass.class);
            System.debug('Total Number of SOQL Queries allowed in this Apex code context: ' +  Limits.getLimitQueries());
            System.debug('1. Queries used in this Apex code so far: ' + Limits.getQueries());
            System.debug(sale);
            String strSaleJson = JSON.serialize(sale.sale);
            
            sale.Gpesale = (GPE_ApexToJsonClass.gpeSale) JSON.deserialize(strSaleJson, GPE_ApexToJsonClass.gpeSale.class);
            System.debug('sale.Gpesale----'+sale.Gpesale);
            Account account = OnlineSalesHelper.getAccount(sale.Gpesale);
            System.debug('2. Queries used in this Apex code so far: ' + Limits.getQueries());
            System.debug(account);
            wrapperObj = OnlineSalesHelper.createOpportunity(account, sale.Gpesale);
            System.debug('3. Queries used in this Apex code so far: ' + Limits.getQueries());
            System.debug('wrapperObj---'+wrapperObj);
            
            if(wrapperObj != null && wrapperObj[0].opportunity.Id != null){
                // crtQuote(Opportunity oppList, Boolean isGPE, List<Product2> lstProduct , Set<GPE_ApexToJsonClass.LineItems> OnlineSaleLineItemSet, GPE_ApexToJsonClass.Gpesale sale)
                wrapperObj =  OnlineSalesHelper.crtQuote(wrapperObj[0].opportunity, wrapperObj[0].lstProduct,wrapperObj[0].OnlineSaleLineItemSet,sale.Gpesale);
                RestContext.response.addHeader('Content-Type', 'application/json');
                if(wrapperObj[0].opportunity != null){ objReqRes.Opportunity__c = wrapperObj[0].opportunity.Id; }
                if(wrapperObj[0].quote != null){ objReqRes.Opportunity__c = wrapperObj[0].quote.OpportunityId; objReqRes.Quote__c = wrapperObj[0].quote.Id; }
                if(wrapperObj[0].order != null){ objReqRes.Opportunity__c = wrapperObj[0].order.OpportunityId; objReqRes.Quote__c = wrapperObj[0].order.QuoteId; objReqRes.Order__c = wrapperObj[0].order.Id; }
                objReqRes.Response__c = wrapperObj[0].str;
                objReqRes.Status_Code__c = '200';
                RestContext.response.responseBody = Blob.valueOf(wrapperObj[0].str);
            }else {
                if(wrapperObj[0].opportunity != null){ objReqRes.Opportunity__c = wrapperObj[0].opportunity.Id; }
                if(wrapperObj[0].quote != null){ objReqRes.Opportunity__c = wrapperObj[0].quote.OpportunityId; objReqRes.Quote__c = wrapperObj[0].quote.Id; }
                if(wrapperObj[0].order != null){ objReqRes.Opportunity__c = wrapperObj[0].order.OpportunityId; objReqRes.Quote__c = wrapperObj[0].order.QuoteId; objReqRes.Order__c = wrapperObj[0].order.Id; }
                objReqRes.Response__c = wrapperObj[0].str;
                objReqRes.Status_Code__c = '400';
                RestContext.response.addHeader('Content-Type', 'application/json');
                System.debug('wrapperObj str@@@@'+wrapperObj);
                RestContext.response.responseBody = Blob.valueOf(wrapperObj[0].str);
            }
            System.debug('4. Queries used in this Apex code so far: ' + Limits.getQueries());
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