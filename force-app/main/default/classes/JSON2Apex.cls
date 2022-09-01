/**
 * @File Name          : JSON2Apex.cls
 * @Description        : support class to extrct json in EventCallout_Lex controller
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : ratik.singhal@addonblue.com
 * @Last Modified On   : 08-05-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/23/2020    maptel@addonblue.com      Initial Version
**/
public with sharing class JSON2Apex {

    public class Order {
        public String fromDate {get;set;} // in json: from
        public String to {get;set;} 
        public Integer min {get;set;} 
        public Integer max {get;set;} 

        public Order(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'from') {
                            fromDate = parser.getText();
                        } else if (text == 'to') {
                            to = parser.getText();
                        } else if (text == 'min') {
                            min = parser.getIntegerValue();
                        } else if (text == 'max') {
                            max = parser.getIntegerValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Order consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public Integer id {get;set;} 
    public String title {get;set;} 
    public Order order {get;set;} 
    public Price price {get;set;} 
    public Boolean isdelivery {get;set;} 
    public String infotext {get;set;} 
    public String group_Z {get;set;} // in json: group
    
    public JSON2Apex(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'id') {
                        id = parser.getIntegerValue();
                    } else if (text == 'title') {
                        title = parser.getText();
                    } else if (text == 'order') {
                        order = new Order(parser);
                    } else if (text == 'price') {
                        price = new Price(parser);
                    } else if (text == 'isdelivery') {
                        isdelivery = parser.getBooleanValue();
                    } else if (text == 'infotext') {
                        infotext = parser.getText();
                    } else if (text == 'group') {
                        group_Z = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Price {
        public Decimal net {get;set;} 
        public Decimal gross {get;set;} 
        public Decimal tax {get;set;} 
        public String currency_isoCode{get;set;} 

        public Price(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'net') {
                            net = parser.getDecimalValue();
                        } else if (text == 'gross') {
                            gross = parser.getDecimalValue();
                        } else if (text == 'tax') {
                            tax = parser.getDecimalValue();
                        } else if (text == 'currency_isoCode') {
                            currency_isoCode = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Price consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
    * @description  : parse method to create json parser
    * @author       : mpatel@addonblue.com | 4/23/2020 
    * @param        : String json
    * @return       : List<JSON2Apex> 
    **/
    public static List<JSON2Apex> parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return arrayOfJSON2Apex(parser);
    }

    /**
    * @description  : get tocken of the json
    * @author       : mpatel@addonblue.com | 4/23/2020 
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
    * @description  : return list of thr json class
    * @author       : mpatel@addonblue.com | 4/23/2020 
    * @param        : System.JSONParser p
    * @return       : List<JSON2Apex>
    **/
    private static List<JSON2Apex> arrayOfJSON2Apex(System.JSONParser p) {
        List<JSON2Apex> res = new List<JSON2Apex>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new JSON2Apex(p));
        }
        return res;
    }
}