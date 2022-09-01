public class H4HRatePlanResponse {

    public class Policy {
        public ExtraPersonPrice ExtraPersonPrice {get;set;} 
        public Guarantee Guarantee {get;set;} 
        public Cancel Cancel {get;set;} 
        public Guarantee Deposit {get;set;} 
        public Guarantee ExtraFees {get;set;} 
        public Guarantee Payment {get;set;} 
        public List<Property> Property {get;set;} 

        public Policy(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'ExtraPersonPrice') {
                            ExtraPersonPrice = new ExtraPersonPrice(parser);
                        } else if (text == 'Guarantee') {
                            Guarantee = new Guarantee(parser);
                        } else if (text == 'Cancel') {
                            Cancel = new Cancel(parser);
                        } else if (text == 'Deposit') {
                            Deposit = new Guarantee(parser);
                        } else if (text == 'ExtraFees') {
                            ExtraFees = new Guarantee(parser);
                        } else if (text == 'Payment') {
                            Payment = new Guarantee(parser);
                        } else if (text == 'Property') {
                            Property = arrayOfProperty(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Policy consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class ArnResponse {
        public Info Info {get;set;} 
        public RateDetails RateDetails {get;set;} 

        public ArnResponse(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Info') {
                            Info = new Info(parser);
                        } else if (text == 'RateDetails') {
                            RateDetails = new RateDetails(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'ArnResponse consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Cancel {
        public String Description {get;set;} 
        public String LatestCancelTime {get;set;} 
        public String GMTOffSet {get;set;} 
        public BookingFee Fee {get;set;} 
        public Penalty Penalty {get;set;} 

        public Cancel(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@Description') {
                            Description = parser.getText();
                        } else if (text == '@LatestCancelTime') {
                            LatestCancelTime = parser.getText();
                        } else if (text == '@GMTOffSet') {
                            GMTOffSet = parser.getText();
                        } else if (text == 'Fee') {
                            Fee = new BookingFee(parser);
                        } else if (text == 'Penalty') {
                            Penalty = new Penalty(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Cancel consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class HotelRateDetails {
        public String InDate {get;set;} 
        public String OutDate {get;set;} 
        public String Rooms {get;set;} 
        public String Adults {get;set;} 
        public String Children {get;set;} 
        public Hotel Hotel {get;set;} 

        public HotelRateDetails(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@InDate') {
                            InDate = parser.getText();
                        } else if (text == '@OutDate') {
                            OutDate = parser.getText();
                        } else if (text == '@Rooms') {
                            Rooms = parser.getText();
                        } else if (text == '@Adults') {
                            Adults = parser.getText();
                        } else if (text == '@Children') {
                            Children = parser.getText();
                        } else if (text == 'Hotel') {
                            Hotel = new Hotel(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'HotelRateDetails consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Tax {
        public String Percent {get;set;} 
        public String Amount {get;set;} 

        public Tax(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@Percent') {
                            Percent = parser.getText();
                        } else if (text == '@Amount') {
                            Amount = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Tax consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class GatewayFee {
        public String Amount {get;set;} 

        public GatewayFee(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@Amount') {
                            Amount = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'GatewayFee consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Info {
        public String SiteID {get;set;} 
        public String Username {get;set;} 
        public String IpAddress {get;set;} 
        public String TimeReceived {get;set;} 
        public String TimeCompleted {get;set;} 
        public String Version {get;set;} 
        public String ServiceUrl {get;set;} 
        public String RequestID {get;set;} 

        public Info(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@SiteID') {
                            SiteID = parser.getText();
                        } else if (text == '@Username') {
                            Username = parser.getText();
                        } else if (text == '@IpAddress') {
                            IpAddress = parser.getText();
                        } else if (text == '@TimeReceived') {
                            TimeReceived = parser.getText();
                        } else if (text == '@TimeCompleted') {
                            TimeCompleted = parser.getText();
                        } else if (text == '@Version') {
                            Version = parser.getText();
                        } else if (text == '@ServiceUrl') {
                            ServiceUrl = parser.getText();
                        } else if (text == '@RequestID') {
                            RequestID = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Info consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class RatePlan {
        public String Code {get;set;} 
        public String Description {get;set;} 
        public String Gateway {get;set;} 
        public String CommissionStatus {get;set;} 
        public String BalanceDueAtHotel {get;set;} 
        public Room Room {get;set;} 
        public Policy Policy {get;set;} 

        public RatePlan(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@Code') {
                            Code = parser.getText();
                        } else if (text == '@Description') {
                            Description = parser.getText();
                        } else if (text == '@Gateway') {
                            Gateway = parser.getText();
                        } else if (text == '@CommissionStatus') {
                            CommissionStatus = parser.getText();
                        } else if (text == '@BalanceDueAtHotel') {
                            BalanceDueAtHotel = parser.getText();
                        } else if (text == 'Room') {
                            Room = new Room(parser);
                        } else if (text == 'Policy') {
                            Policy = new Policy(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'RatePlan consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class BookingFee {
        public String Amount {get;set;} 
        public String CurrencyCode {get;set;} 
        public String DisplayCurrencyMultiplier {get;set;} 
        public String RoomCurrencyMultiplier {get;set;} 
        public String ExchangeGMT {get;set;} 

        public BookingFee(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@Amount') {
                            Amount = parser.getText();
                        } else if (text == '@CurrencyCode') {
                            CurrencyCode = parser.getText();
                        } else if (text == '@DisplayCurrencyMultiplier') {
                            DisplayCurrencyMultiplier = parser.getText();
                        } else if (text == '@RoomCurrencyMultiplier') {
                            RoomCurrencyMultiplier = parser.getText();
                        } else if (text == '@ExchangeGMT') {
                            ExchangeGMT = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'BookingFee consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class ExtraPersonPrice {
        public String Adult {get;set;} 
        public String Child {get;set;} 
        public String CurrencyCode {get;set;} 
        public String DisplayCurrencyMultiplier {get;set;} 
        public String USDMultiplier {get;set;} 
        public String ExchangeGMT {get;set;} 

        public ExtraPersonPrice(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@Adult') {
                            Adult = parser.getText();
                        } else if (text == '@Child') {
                            Child = parser.getText();
                        } else if (text == '@CurrencyCode') {
                            CurrencyCode = parser.getText();
                        } else if (text == '@DisplayCurrencyMultiplier') {
                            DisplayCurrencyMultiplier = parser.getText();
                        } else if (text == '@USDMultiplier') {
                            USDMultiplier = parser.getText();
                        } else if (text == '@ExchangeGMT') {
                            ExchangeGMT = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'ExtraPersonPrice consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Penalty {
        public String Amount {get;set;} 
        public String CurrencyCode {get;set;} 
        public String DisplayCurrencyMultiplier {get;set;} 
        public String USDMultiplier {get;set;} 
        public String ExchangeGMT {get;set;} 

        public Penalty(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@Amount') {
                            Amount = parser.getText();
                        } else if (text == '@CurrencyCode') {
                            CurrencyCode = parser.getText();
                        } else if (text == '@DisplayCurrencyMultiplier') {
                            DisplayCurrencyMultiplier = parser.getText();
                        } else if (text == '@USDMultiplier') {
                            USDMultiplier = parser.getText();
                        } else if (text == '@ExchangeGMT') {
                            ExchangeGMT = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Penalty consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public ArnResponse ArnResponse {get;set;} 

    public H4HRatePlanResponse(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'ArnResponse') {
                        ArnResponse = new ArnResponse(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'H4HRatePlanResponse consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Total {
        public String Amount {get;set;} 
        public String IncludesBookingFee {get;set;} 

        public Total(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@Amount') {
                            Amount = parser.getText();
                        } else if (text == '@IncludesBookingFee') {
                            IncludesBookingFee = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Total consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class NightlyRate {
        public String nightDate {get;set;} 
        public String Price {get;set;} 

        public NightlyRate(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@Date') {
                            nightDate = parser.getText();
                        } else if (text == '@Price') {
                            Price = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'NightlyRate consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Guarantee {
        public String Description {get;set;} 

        public Guarantee(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@Description') {
                            Description = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Guarantee consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Room {
        public String Code {get;set;} 
        public String Name {get;set;} 
        public String Description {get;set;} 
        public String CurrencyCode {get;set;} 
        public String DisplayCurrencyMultiplier {get;set;} 
        public String USDMultiplier {get;set;} 
        public String ExchangeGMT {get;set;} 
        public String MaximumBookable {get;set;} 
        public String Refundable {get;set;} 
        public List<NightlyRate> NightlyRate {get;set;}
        public NightlyRate objNightlyRate {get;set;}
        public Tax Tax {get;set;} 
        public GatewayFee GatewayFee {get;set;} 
        public Total Total {get;set;} 
        public BookingFee BookingFee {get;set;} 

        public Room(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@Code') {
                            Code = parser.getText();
                        } else if (text == '@Name') {
                            Name = parser.getText();
                        } else if (text == '@Description') {
                            Description = parser.getText();
                        } else if (text == '@CurrencyCode') {
                            CurrencyCode = parser.getText();
                        } else if (text == '@DisplayCurrencyMultiplier') {
                            DisplayCurrencyMultiplier = parser.getText();
                        } else if (text == '@USDMultiplier') {
                            USDMultiplier = parser.getText();
                        } else if (text == '@ExchangeGMT') {
                            ExchangeGMT = parser.getText();
                        } else if (text == '@MaximumBookable') {
                            MaximumBookable = parser.getText();
                        } else if (text == '@Refundable') {
                            Refundable = parser.getText();
                        } else if (text == 'NightlyRate') {
                            if(parser.getCurrentToken() == System.JSONToken.START_ARRAY) {
                                NightlyRate = arrayOfNightlyRate(parser);
                            } else {
                                objNightlyRate = new NightlyRate(parser);
                            }
                        } else if (text == 'Tax') {
                            Tax = new Tax(parser);
                        } else if (text == 'GatewayFee') {
                            GatewayFee = new GatewayFee(parser);
                        } else if (text == 'Total') {
                            Total = new Total(parser);
                        } else if (text == 'BookingFee') {
                            BookingFee = new BookingFee(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Room consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Property {
        public String Description {get;set;} 
        public String Value {get;set;} 

        public Property(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@Description') {
                            Description = parser.getText();
                        } else if (text == '@Value') {
                            Value = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Property consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class RateDetails {
        public String DisplayCurrency {get;set;} 
        public HotelRateDetails HotelRateDetails {get;set;} 

        public RateDetails(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@DisplayCurrency') {
                            DisplayCurrency = parser.getText();
                        } else if (text == 'HotelRateDetails') {
                            HotelRateDetails = new HotelRateDetails(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'RateDetails consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Hotel {
        public String HotelID {get;set;} 
        public String HotelInfo {get;set;} 
        public String Latitude {get;set;} 
        public String Longitude {get;set;} 
        public String Name {get;set;} 
        public String Address1 {get;set;} 
        public String City {get;set;} 
        public String State {get;set;} 
        public String CountryCode {get;set;} 
        public String Postal {get;set;} 
        public String PercentMatch {get;set;} 
        public String ImageThumbnail {get;set;} 
        public String LocationDescription {get;set;} 
        public String TripAdvisorReviewCount {get;set;} 
        public String TripAdvisorRating {get;set;} 
        public String RatingImageUrl {get;set;} 
        public String PriceClass {get;set;} 
        public String PropertyLink {get;set;} 
        public RatePlan RatePlan {get;set;} 

        public Hotel(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == '@HotelID') {
                            HotelID = parser.getText();
                        } else if (text == '@HotelInfo') {
                            HotelInfo = parser.getText();
                        } else if (text == '@Latitude') {
                            Latitude = parser.getText();
                        } else if (text == '@Longitude') {
                            Longitude = parser.getText();
                        } else if (text == '@Name') {
                            Name = parser.getText();
                        } else if (text == '@Address1') {
                            Address1 = parser.getText();
                        } else if (text == '@City') {
                            City = parser.getText();
                        } else if (text == '@State') {
                            State = parser.getText();
                        } else if (text == '@CountryCode') {
                            CountryCode = parser.getText();
                        } else if (text == '@Postal') {
                            Postal = parser.getText();
                        } else if (text == '@PercentMatch') {
                            PercentMatch = parser.getText();
                        } else if (text == '@ImageThumbnail') {
                            ImageThumbnail = parser.getText();
                        } else if (text == '@LocationDescription') {
                            LocationDescription = parser.getText();
                        } else if (text == '@TripAdvisorReviewCount') {
                            TripAdvisorReviewCount = parser.getText();
                        } else if (text == '@TripAdvisorRating') {
                            TripAdvisorRating = parser.getText();
                        } else if (text == '@RatingImageUrl') {
                            RatingImageUrl = parser.getText();
                        } else if (text == '@PriceClass') {
                            PriceClass = parser.getText();
                        } else if (text == '@PropertyLink') {
                            PropertyLink = parser.getText();
                        } else if (text == 'RatePlan') {
                            RatePlan = new RatePlan(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Hotel consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public static H4HRatePlanResponse parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new H4HRatePlanResponse(parser);
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

    private static List<Property> arrayOfProperty(System.JSONParser p) {
        List<Property> res = new List<Property>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Property(p));
        }
        return res;
    }

    private static List<NightlyRate> arrayOfNightlyRate(System.JSONParser p) {
        List<NightlyRate> res = new List<NightlyRate>();
        if (p.getCurrentToken() == null) p.nextToken();
        while(p.nextToken() != System.JSONToken.END_ARRAY) {
            if(p.getCurrentToken() == System.JSONToken.START_OBJECT) {
                res.add(new NightlyRate(p));
            }
        }
        return res;
    }
}