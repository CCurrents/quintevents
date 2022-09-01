/**
 * @File Name          : SlackPriceBookChannelTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 03-22-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/12/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest public class SlackPriceBookChannelTest {
	@TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testRun1(){
        List<Id> lstIds = new List<Id>();
        Pricebook2 objPricebook = TestDataFactory.createPricebook();
        objPricebook.End_Date__c = System.today().addDays(-7);
        objPricebook.Slack_Channel_Id__c = null;
        update objPricebook;

        lstIds.add(objPricebook.Id);

        SlackPriceBookChannelArchive slackpricebookbatch = new SlackPriceBookChannelArchive();
        Database.executeBatch(slackpricebookbatch);

        SlackPriceBookChannel slackPriceBookChannelBatch = new SlackPriceBookChannel(lstIds);
        System.enqueueJob(slackPriceBookChannelBatch);
    }
}