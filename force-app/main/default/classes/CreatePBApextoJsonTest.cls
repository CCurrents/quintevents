/**
 * @File Name          : CreatePBApextoJsonTest.cls
 * @Description        : test class for the CreateEventApextoJson controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/20/2020, 3:23:57 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/20/2020   mpatel@addonblue.com     Initial Version
**/
@isTest
private with sharing class CreatePBApextoJsonTest{
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void apexToJsonFirstTestExecution() {
        String json = '['+
        '    {'+
        '        \"id\": 3870,'+
        '        \"thumbnail\": \"https://s3.eu-central-1.amazonaws.com/gpt-v2-img/img/events/vietnam.jpg\",'+
        '        \"banner\": \"https://s3.eu-central-1.amazonaws.com/gpt-v2-img/img/flaggen/VN.png\",'+
        '        \"country\": \"Vietnam\",'+
        '        \"town\": \"Hanoi\",'+
        '        \"title\": \"FORMULA 1 VIETNAM GRAND PRIX 2020\",'+
        '        \"fromdate\": \"2020-04-01\",'+
        '        \"todate\": \"2020-04-30\"'+
        '    }'+
        ']';
        List<CreatePBApextoJson> r = CreatePBApextoJson.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        CreatePBApextoJson objCreatePBApextoJson = new CreatePBApextoJson(System.JSON.createParser(json));
        System.assert(objCreatePBApextoJson != null);
    }
}