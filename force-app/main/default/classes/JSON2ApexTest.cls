/**
 * @File Name          : JSON2ApexTest.cls
 * @Description        : test class for the JSON2Apex controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/23/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/23/2020   mpatel@addonblue.com     Initial Version
**/
@isTest
private with sharing class JSON2ApexTest {
    @testSetup static void setup() {
        TestDataFactory.createTriggerSettingsEntry();      
    }
    @isTest static void apexToJsonFirstTestExecution() {
        String json = '['+
        '   {'+
        '       \"id\":89134,'+
        '       \"title\":\"A Platinum (WE)\",'+
        '       \"order\":'+
        '       {'+
        '           \"from\":\"2019-01-07\",'+
        '           \"to\":\"2019-04-14\",'+
        '           \"min\":1,'+
        '           \"max\":0'+
        '       },'+
        '       \"price\":'+
        '       {'+
        '           \"net\":370,'+
        '           \"gross\":370,'+
        '           \"tax\":0'+
        '       },'+
        '       \"isdelivery\":false,'+
        '       \"infotext\":\"The Grandstand Platinum area is the ultimate place to watch one of the season\\u2019s most exciting venues. Situated within yards of the starting line, the pits, the podium and the track\\u2019s first corner, the seats also provide a panoramic view of the entire track. With a direct sight of F1 engines entering and exiting the pits as well as front row seats to the podium to cheer and celebrate with your favorite driver, grandstand platinum tickets are simply a treat to your eyes and ears. Moreover, with 6 simultaneous displaying screens, the Platinum grandstand area ensures you to capture every moment of the exhilarating Shanghai Grand Prix.\",'+
        '       \"group\":\"Grandstand A\"'+
        '   }'+
        ']';
        List<JSON2Apex> r = JSON2Apex.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        JSON2Apex.Order objOrder = new JSON2Apex.Order(System.JSON.createParser(json));
        System.assert(objOrder != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        JSON2Apex objJSON2Apex = new JSON2Apex(System.JSON.createParser(json));
        System.assert(objJSON2Apex != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        JSON2Apex.Price objPrice = new JSON2Apex.Price(System.JSON.createParser(json));
        System.assert(objPrice != null);
    }
}