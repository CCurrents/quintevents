/**
 * @File Name          : QNG_JSON2Apex.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 02-22-2022
 * @Modification Log   : 
 * Ver       Date            Author                       Modification
 * 1.0    20/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 * 1.1    11/13/2020  jagrawal@addonblue.com                 #451 Protectgroup Integration
 * 1.2    11/23/2020  kchavda@addonblue.com                  #627 Get the exchange rate date from the JSON for Online Orders
 * 1.3    04/29/2021  kchavda@addonblue.com                  #891 Add Order Purchase date on Order for Online Order
**/


public class QNG_JSON2Apex {

    public class Sale {
        public Decimal totalAfterDiscount;
        public Decimal totalChargedInCurrency;
        public Decimal discount;
        // #451 Protectgroup Integration -- Start
        public Decimal protectGroupAmount;
        public String protectGroupId;
        // #451 Protectgroup Integration -- End
        public String discountCode;
        public String resellerId;
        public String promoterId;
        public String eventId;
        public String city;
        public String country;
        public String currencyCharged;
        public String email;
        public String firstName;
        public String googleAnalyticsId;
        public String googleAnalyticsSiteId;
        public String lastName;
        public String phone;
        public String purchaseOrderNumber;
        public String site;
        public String state;
        public String street;
        public String visitorCountry;
        public String zip;
        public String paymentTerms;
        public String h4hPointsSpent;
        public Boolean isRewardApplied;
        public String company_name;
        public String paymentMethod;
        public Decimal h4hRewardPercentage;
        public Boolean api;
        public List<LineItems> lineItems;
        public List<RetailHotelLineItems> retailHotelLineItems;
        public Decimal exchangeRate;
        //#706 Add new field "qngOrderId" to Order object
        public String qngOrderId;
        //#715 QNG Quote from Salesforce
        public String quoteId;
        public string accountingAppLink;
        public string purchaseDate;
        //#1160 RoomCash
        public Decimal pointsAwarded;
    }

    public class LineItems {
        public ID packageId;
        public Integer packageQty;
        public Decimal packagePrice;
        public ID hotelId;
        public Integer hotelQty;
        public Decimal hotelPrice;
        public Boolean includeTransportation;
        public Boolean seacret;//#1033 change
        public List<Stays> Stays;
    }

    public class RetailHotelLineItems {
        public String HotelId;
        public String HotelName;
        public String ReservationId;
        public String ItineraryId;
        public String CheckInDate;
        public String CheckOutDate;
        public Double ReservationTotalPrice;
        public String RoomCode;
        public Integer RoomQuantity;
    }

    public Sale sale;

    public class Stays {
        public String stayid;
        public Double stayPrice;
        public Integer stayQty;
        public String qngRoomingListId;
        public Boolean includeTransportation;
    }

    
    public static QNG_JSON2Apex parse(String json) {
        return (QNG_JSON2Apex) System.JSON.deserialize(json, QNG_JSON2Apex.class);
    }
}