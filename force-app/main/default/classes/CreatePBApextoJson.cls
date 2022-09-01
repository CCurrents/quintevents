/**
 * @File Name          : CreatePBApextoJson.cls
 * @Description        : class use to extract value from the json and convert as a list.
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/22/2020, 3:11:00 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/22/2020    maptel@addonblue.com      Initial Version
**/
public with sharing class CreatePBApextoJson{
    
    public Integer id {get;set;} 
    public String thumbnail {get;set;} 
    public String banner {get;set;} 
    public String country {get;set;} 
    public String town {get;set;} 
    public String title {get;set;} 
    public String fromdate {get;set;} 
    public String todate {get;set;} 

    public CreatePBApextoJson(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'id') {
                        id = parser.getIntegerValue();
                    } else if (text == 'thumbnail') {
                        thumbnail = parser.getText();
                    } else if (text == 'banner') {
                        banner = parser.getText();
                    } else if (text == 'country') {
                        country = parser.getText();
                    } else if (text == 'town') {
                        town = parser.getText();
                    } else if (text == 'title') {
                        title = parser.getText();
                    } else if (text == 'fromdate') {
                        fromdate = parser.getText();
                    } else if (text == 'todate') {
                        todate = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'CreatePBApextoJson consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    /**
    * @description  : parse method to create json parser
    * @author       : mpatel@addonblue.com | 4/22/2020 
    * @param        : String json
    * @return       : List<CreatePBApextoJson> 
    **/
    public static List<CreatePBApextoJson> parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return arrayOfCreatePBApextoJson(parser);
    }
    /**
    * @description  : tracking the json start or json is end
    * @author       : mpatel@addonblue.com | 4/22/2020 
    * @param        : System.JSONParser parser
    * @return       : void 
    **/
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    
    /**
    * @description  : get the tocken of the json
    * @author       : mpatel@addonblue.com | 4/22/2020 
    * @param        : System.JSONParser p
    * @return       : List<CreatePBApextoJson> 
    **/
    private static List<CreatePBApextoJson> arrayOfCreatePBApextoJson(System.JSONParser p) {
        List<CreatePBApextoJson> res = new List<CreatePBApextoJson>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new CreatePBApextoJson(p));
        }
        return res;
    }
}