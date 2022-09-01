/**
 * @File Name          : scheduleForArchivechannel.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/12/2020, 1:08:29 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/23/2020   jagrawal@addonblue.com     Initial Version
**/
global with sharing class scheduleForArchivechannel implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
         SlackPriceBookChannelArchive slackpricebookbatch = new SlackPriceBookChannelArchive();
         Database.executeBatch(slackpricebookbatch); 
    }
    
}