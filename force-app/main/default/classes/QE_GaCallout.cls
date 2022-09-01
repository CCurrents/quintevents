/**
 * @File Name          : QE_GaCallout.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 11:16:37 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
public class QE_GaCallout {
    static final String GA_AGG_ID = 'UA-96277800-1';

    @Future(callout=true)
    public static void SendTransaction(String id, Boolean reverseTransaction) {
      Opportunity opp = [Select Amount, AccountId, PriceBook2Id From Opportunity where Id=:id LIMIT 1];
      
      // Lead lead = [Select Google_Analytics_ID__c, Google_Analytics_Site_Id__c From Lead where convertedAccountId=:opp.AccountId  LIMIT 1];
      
      /*
      if (String.isBlank(lead.Google_Analytics_ID__c) || String.isBlank(lead.Google_Analytics_Site_Id__c)){
        return;
      }
      */
      
      Account opptAccount = [Select id, Google_Analytics_ID__c, Google_Analytics_Site_Id__c From Account Where Id = :opp.AccountId Limit 1];

      if (String.isBlank(opptAccount.Google_Analytics_ID__c) || String.isBlank(opptAccount.Google_Analytics_Site_Id__c)){
        return;
      }
      
      Decimal amount = opp.amount;
      if(reverseTransaction) {
        amount *= -1;
      }

      // QE360_Event__c event = [Select Name From QE360_Event__c where Id=:opp.Event__c];
      List<PriceBook2> events = new List<PriceBook2>();
      if(String.isNotBlank(opp.PriceBook2Id))
          events = [Select Name from PriceBook2 where Id =:opp.PriceBook2Id];
      PriceBook2 event;
      if(events.size() > 0) event = events[0];
      HttpRequest req = new HttpRequest();
      req.setMethod('POST');
      req.setEndpoint('https://www.google-analytics.com/collect');
      Map<String,String> params = new Map<String,String>{
        'tid' => EncodingUtil.urlEncode(opptAccount.Google_Analytics_Site_Id__c, 'UTF-8'),
        'cid' => EncodingUtil.urlEncode(opptAccount.Google_Analytics_ID__c, 'UTF-8'),
        'ta' => EncodingUtil.urlEncode(event == null ? 'No Event Found': event.Name, 'UTF-8'),
        'tr' => String.valueOf(amount),
        't' => 'transaction',
        'ti' => String.valueOf(opp.Id)
      };

      req = setBody(req, params);
      Http http = new Http();

      GaMockHttpResponseGenerator gaMockResponseGenerator =  new GaMockHttpResponseGenerator();

      HttpResponse res = new HttpResponse();

      if (Test.isRunningTest()) {
          res = gaMockResponseGenerator.respond(req);
      } else {
          res = http.send(req);
      }
      System.debug(res.getStatus());

      params.put('tid', GA_AGG_ID);
      req = setBody(req, params);
      if (Test.isRunningTest()) {
          res = gaMockResponseGenerator.respond(req);
      } else {
          res = http.send(req);
      }
      System.debug(res.getStatus());

      List<OpportunityLineItem> items = [SELECT Product2Id, Price__c, Quantity, ApexProductName__c FROM OpportunityLineItem WHERE OpportunityId=:opp.Id];

      for (OpportunityLineItem item : items) {

          Decimal price = item.Price__c;
          if(reverseTransaction) {
            price *= -1;
          }

          params.put('tid', EncodingUtil.urlEncode(opptAccount.Google_Analytics_Site_Id__c, 'UTF-8'));
          params.put('in', EncodingUtil.urlEncode(event == null ? 'No Event Found': event.Name + ': ' + item.ApexProductName__c, 'UTF-8'));
          params.put('ic', String.valueOf(item.Product2Id));
          params.put('ip', String.valueOf(price));
          params.put('t', 'item');
          params.put('iq', String.valueOf(item.Quantity));

          req = setBody(req, params);

          HttpResponse itemRes = new HttpResponse();
          if (Test.isRunningTest()) {
              itemRes = gaMockResponseGenerator.respond(req);
          } else {
              itemRes = http.send(req);
          }
          System.debug(itemRes.getStatus());

          params.put('tid', GA_AGG_ID);
          req = setBody(req, params);
          if (Test.isRunningTest()) {
              itemRes = gaMockResponseGenerator.respond(req);
          } else {
              itemRes = http.send(req);
          }
          System.debug(itemRes.getStatus());
      }
    }

    private static HttpRequest setBody(HttpRequest req, Map<String, String> bodyMap){
      req.setBody('v=1&cu=USD' +
                  '&t=' + bodyMap.get('t') +
                  '&ta=' + bodyMap.get('ta') +
                  '&tid=' + bodyMap.get('tid') +
                  '&cid=' + bodyMap.get('cid') +
                  '&tr=' + bodyMap.get('tr') +
                  '&ti=' + bodyMap.get('ti') +
                  '&in=' + bodyMap.get('in') +
                  '&ic=' + bodyMap.get('ic') +
                  '&ip=' + bodyMap.get('ip') +
                  '&iq=' + bodyMap.get('iq'));

      return req;
    }
}