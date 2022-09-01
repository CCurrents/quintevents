/**
 * @File Name          : SalesAgentProgramTriggerHelperTest.cls
 * @Description        : 
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : jthakkar@addonblue.com
 * @Last Modified On   : 28/2/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    27/1/2020   jthakkar@addonblue.com     Initial Version
**/
@isTest public with sharing class SalesAgentProgramTriggerHelperTest {
    
    @isTest static void testMethod_one() { 
        
        TestDataFactory.createTriggerSettingsEntry();
        Pricebook2 priceBook = TestDataFactory.createPricebook();
        
        Program__c program = TestDataFactory.createProgram()[0];
        
        priceBook.Program__c = program.Id;
        update priceBook;
        
        Sales_Agent__c objSales = TestDataFactory.createSalesAgent(program)[0];            
		
        Sales_Agent_Event__c objSalesAgentEvent = TestDataFactory.createSalesAgentEvent(priceBook, objSales)[0];
        
        Sales_Agent_Program__c salesAgentProgram = TestDataFactory.createSalesAgentProgram(program, objSales)[0];
    }
}