/**
 * @File Name          : QuoteLineItemUtility.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/31/2020, 7:21:42 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/31/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class QuoteLineItemUtility {

    public class LineItemBundleClass {
        @AuraEnabled public QuoteLineItem ParentPackage {get;set;}
        @AuraEnabled public List<QuoteLineItem> ChildLineItems {get;set;}
        
        public LineItemBundleClass() {
            ParentPackage = new QuoteLineItem();
            ChildLineItems = new List<QuoteLineItem>();
        }
    }
    
}