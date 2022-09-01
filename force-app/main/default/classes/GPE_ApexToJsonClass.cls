public class GPE_ApexToJsonClass {
        
    public class LineItems {
        public String Name {get;set;} 
        public String articleid {get;set;} 
        public String price {get;set;} 
        public Integer quantity {get;set;} 
        public String GPTEventId{get;set;}
      
        public String packageId{get;set;}
        public String packagePrice{get;set;}
        public String packageQty{get;set;}
        public String hotelId{get;set;}
        public String hotelPrice{get;set;}
        public String hotelQty{get;set;}
        public String includeTransportation{get;set;}
        
        public LineItems(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Name') {Name = parser.getText();
                        } else if (text == 'articleid') {articleid = parser.getText();
                        } else if (text == 'price') { price = parser.getText();
                        } else if (text == 'quantity') { quantity = parser.getIntegerValue();
                        } else if (text == 'GPTEventId') { GPTEventId = parser.getText();
                        } else if (text == 'packageId') { packageId = parser.getText();
                        } else if (text == 'packagePrice') { packagePrice= parser.getText();
                        } else if (text == 'packageQty') { packageQty = parser.getText();
                        } else if (text == 'hotelId') { hotelId = parser.getText();
                        } else if (text == 'hotelPrice') { hotelPrice = parser.getText();
                        } else if (text == 'hotelQty') { hotelQty = parser.getText();
                        } else if (text == 'includeTransportation') {
                            includeTransportation = parser.getText();
                        }else {
                            System.debug(LoggingLevel.WARN, 'LineItems consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public Gpesale gpesale {get;set;} 
    public sale sale {get;set;} 
    public GPE_ApexToJsonClass(JSONParser parser) {
        System.debug('parser'+parser);
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                System.debug('text'+text);
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'sale') {
                        System.debug('parser'+parser);
                        sale = new sale(parser);
                    } else {                        
                        System.debug(LoggingLevel.WARN, 'GPE_ApexToJsonClass consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Fees {
        public Double order_processing_fee {get;set;} 
        public Double shipping_fee {get;set;} 

        public Fees(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'order_processing_fee') {
                            order_processing_fee = parser.getDoubleValue();
                        } else if (text == 'shipping_fee') {
                            shipping_fee = parser.getDoubleValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Fees consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Gpesale {
        public String city {get;set;} 
        public String country {get;set;} 
        public String currencyCharged {get;set;} 
        public String email {get;set;} 
        public Fees fees {get;set;} 
        public String firstName {get;set;} 
        public String gpeEventName {get;set;} 
        public String gptBookingId {get;set;} 
        public String lastName {get;set;} 
        public List<LineItems> lineItems {get;set;} 
        public String phone {get;set;} 
        public String state {get;set;} 
        public String street {get;set;} 
        public String total {get;set;} 
        public String zip {get;set;} 
        public String GPE_Order_Id {get;set;}     
        public String eventId{get;set;}
        public String discount{get;set;}
        public String paymentTerms{get;set;}
        public String googleAnalyticsId{get;set;}
        public String googleAnalyticsSiteId{get;set;}
        public String promoterId{get;set;}
        public String resellerId{get;set;}
        public String site{get;set;}
        public String totalAfterDiscount{get;set;}
        public String totalChargedInCurrency{get;set;}
        public String visitorCountry{get;set;}   

        public Gpesale(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'city') {
                            city = parser.getText();
                        } else if (text == 'country') {
                            country = parser.getText();
                        } else if (text == 'currencyCharged') {
                            currencyCharged = parser.getText();
                        } else if (text == 'email') {
                            email = parser.getText();
                        } else if (text == 'fees') {
                            fees = new Fees(parser);
                        } else if (text == 'firstName') {
                            firstName = parser.getText();
                        } else if (text == 'gpeEventName') {
                            gpeEventName = parser.getText();
                        } else if (text == 'gptBookingId') {
                            gptBookingId = parser.getText();
                        } else if (text == 'lastName') {
                            lastName = parser.getText();
                        } else if (text == 'lineItems') {
                            lineItems = arrayOfLineItems(parser);
                        } else if (text == 'phone') {
                            phone = parser.getText();
                        } else if (text == 'state') {
                            state = parser.getText();
                        } else if (text == 'street') {
                            street = parser.getText();
                        } else if (text == 'total') {
                            total = parser.getText();
                        } else if (text == 'zip') {
                            zip = parser.getText();
                        } else if(text == 'GPE_Order_Id'){
                            GPE_Order_Id = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Gpesale consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }

      
    }

    public class sale {
        public String city {get;set;} 
        public String country {get;set;} 
        public String currencyCharged {get;set;} 
        public String email {get;set;} 
        public Fees fees {get;set;} 
        public String firstName {get;set;} 
        public String gpeEventName {get;set;} 
        public String gptBookingId {get;set;} 
        public String lastName {get;set;} 
        public List<LineItems> lineItems {get;set;} 
        public String phone {get;set;} 
        public String state {get;set;} 
        public String street {get;set;} 
        public String total {get;set;} 
        public String zip {get;set;} 
        public String GPE_Order_Id {get;set;}     
        public String eventId{get;set;}
        public String discount{get;set;}
        public String paymentTerms{get;set;}
        public String googleAnalyticsId{get;set;}
        public String googleAnalyticsSiteId{get;set;}
        public String promoterId{get;set;}
        public String resellerId{get;set;}
        public String site{get;set;}
        public String totalAfterDiscount{get;set;}
        public String totalChargedInCurrency{get;set;}
        public String visitorCountry{get;set;}   

    public sale(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'city') {
                        city = parser.getText();
                    } else if (text == 'country') {
                        country = parser.getText();
                    } else if (text == 'currencyCharged') {
                        currencyCharged = parser.getText();
                    } else if (text == 'email') {
                        email = parser.getText();
                    } else if (text == 'fees') {
                        fees = new Fees(parser);
                    } else if (text == 'firstName') {
                        firstName = parser.getText();
                    } else if (text == 'gpeEventName') {
                        gpeEventName = parser.getText();
                    } else if (text == 'gptBookingId') {
                        gptBookingId = parser.getText();
                    } else if (text == 'lastName') {
                        lastName = parser.getText();
                    } else if (text == 'lineItems') {
                        lineItems = arrayOfLineItems(parser);
                    } else if (text == 'phone') {
                        phone = parser.getText();
                    } else if (text == 'state') {
                        state = parser.getText();
                    } else if (text == 'street') {
                        street = parser.getText();
                    } else if (text == 'total') {
                        total = parser.getText();
                    } else if (text == 'zip') {
                        zip = parser.getText();
                    } else if(text == 'GPE_Order_Id'){
                        GPE_Order_Id = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'Gpesale consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    }
    
    public static GPE_ApexToJsonClass parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new GPE_ApexToJsonClass(parser);
    }
    
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
    

    private static List<LineItems> arrayOfLineItems(System.JSONParser p) {
        List<LineItems> res = new List<LineItems>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new LineItems(p));
        }
        return res;
    }
}