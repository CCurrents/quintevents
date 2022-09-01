/**
 * @File Name          : QE_ARNHotelOrdersController.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 3:27:54 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@RestResource(urlMapping='/arnhotelorder/*')
global with sharing class QE_ARNHotelOrdersController{

    @httppost
    global static Opportunity create() {
        RestRequest req = RestContext.request;
        System.debug('Total Number of SOQL Queries allowed in this Apex code context: ' +  Limits.getLimitQueries());
        System.debug('1. Queries used in this Apex code so far: ' + Limits.getQueries());
        DOM.Document doc=new DOM.Document();
        if(Test.isrunningTest()){
            doc.load('<ArnResponse><Info SiteID="53763" Username="WBE" IpAddress="172.24.16.31" TimeReceived="2019-12-26T14:59:25.076" TimeCompleted="2019-12-26T14:59:31.086" Version="1.0.0.0" ServiceUrl="http://www.tripauthority.com/hotel.asmx" RequestID="9E8C0C21-BD7B-4CDA-A988-F1F737E05684" MasterId="920" AffiliateId="17431" /><Reservation ArnChargeCurrency="USD" CampaignCode="GROUP-EVENT-EMAIL" CustomerComparableDiscount="0.00" CustomerDiscount="0.00" CustomerRebate="0" DisplayCurrency="USD" ElectiveRebateAdjustment="0" ItineraryID="5848033" PartnerMargin="0" PartnerShare="0" PartnerShareUSD="0.00" RecordLocator="e550ae0b-781b-4e70-ab8a-a90cc6a224d6"><HotelReservation Adults="2" Children="0" CustomerConfirmationNumber="69864SB000056" InDate="2020-04-17" OutDate="2020-04-20" ReservationID="6030393" ReservationLocator="7885413" Rooms="1"><Hotel BrandCode="YX" HotelCity="Fort Lauderdale" HotelCountry="US" HotelID="821525" HotelName="Fortuna Hotel" HotelPostal="33304" HotelState="FL"><RatePlan BalanceDueAtHotel="true" Code="RA1" CommissionStatus="Commissionable" Description="A1qra1: Rate Of The Day. Rate Of The Day. Rate Of The Day." Gateway="4"><Room Code="A1Q" CurrencyCode="USD" Description="Executive King Studio Executive King Studio. Alarm Clock Microwave. Cable Television Complimentary High Speed Interne. Air Conditioning Individually C." DisplayCurrencyMultiplier="1" ExchangeGMT="2019-10-30T19:00:06.957" MaximumBookable="1" Name="A1Q" Refundable="true" USDMultiplier="1"><NightlyRate Date="2020-04-17" Price="244.00"/><NightlyRate Date="2020-04-18" Price="244.00"/><NightlyRate Date="2020-04-19" Price="174.00"/><Tax Amount="72.82" Percent="11.00"/><GatewayFee Amount="0.00"/><Total Amount="734.82" IncludesBookingFee="false"/><BookingFee Amount="4.95" CurrencyCode="USD" DisplayCurrencyMultiplier="1" ExchangeGMT="2019-10-30T19:00:06.957" RoomCurrencyMultiplier="1"/></Room><Policy><ExtraPersonPrice Adult="0.00" Child="0.00" CurrencyCode="USD" DisplayCurrencyMultiplier="1" ExchangeGMT="2019-10-30T19:00:06.957" USDMultiplier="1"/><Guarantee Description="Deposit required at time of booking."/><Cancel Description="CXL: CXL WITHIN 72 HRS-FEE 1 NIGHT-INCL TAX-FEES-MUST CANCEL 72 HOURS PRIOR TO ARRIVAL 1 NIGHT STAY PENALTY" GMTOffSet="0" LatestCancelTime="2020-04-13T23:59:00.000"><Fee Amount="0.00" CurrencyCode="USD" DisplayCurrencyMultiplier="1" ExchangeGMT="2019-10-30T19:00:06.957" RoomCurrencyMultiplier="1"/><Penalty Amount="0.00" CurrencyCode="USD" DisplayCurrencyMultiplier="1" ExchangeGMT="2019-10-30T19:00:06.957" USDMultiplier="1"/></Cancel><Deposit Description="CC ACCEPTED VI MC DS AX"/><ExtraFees Description="This price is based on the number of adults you specified in your search. The hotel may charge additional fees when more than two adults stay in a single room, per the hotel\'s individual policy. Any additional fees will be charged by the hotel directly at the time of checkout. For more details on fees associated with more than two adults staying in a single room, please contact the hotel directly. Guest will be responsible for additional fees such as additional guests, security deposit, incidentals, resort fees, and additional room nights. Guest will pay hotel directly for these charges if they exist."/><Payment Description="In order to guarantee your room this reservation requires a non-refundable fee of $4.95 (USD) at time of reservation. This amount will appear on your credit card statement under Hotels For Hope. "/><Payment Description="Tax and/or property fees are included in the total based on the tax and/or fee information provided by the property."/><ChargeName Description="Hotels For Hope"/><Property Description="Check-In Time" Value="4 PM"/><Property Description="Check-Out Time" Value="11 AM"/><NoteToHotelPersonnel/><CheckInSupport/></Policy></RatePlan></Hotel><Guests><Primary AgeGroup="Adult" Email="aguilark0814@hotmail.com" FirstName="Karen" LastName="Aguilar" Message="Custom1:" PhoneArea="305" PhoneCountry="1" PhoneNumber="7622583"><Address Address="1940 NW 16 Terrace, Apt. F302" City="Miami" CountryCode="US" PostalCode="33125" Region="FL" Type="Home"/></Primary></Guests><Service ExchangeGMT="2019-10-30T19:00:06.957"><RoomCurrency CurrencyCode="USD"><Cost BookingFee="4.95" GatewayFee="0.00" Price="662.00" TaxAmount="72.82" TaxPercent="11.00" TotalAmount="739.77" TotalAmountIncludesBookingFee="true"/><Charge Due="734.82" Paid="4.95"/></RoomCurrency><DisplayCurrency CurrencyCode="USD"><Cost BookingFee="4.95" GatewayFee="0.00" Price="662.00" TaxAmount="72.82" TaxPercent="11.00" TotalAmount="739.77" TotalAmountIncludesBookingFee="true"/><Charge Due="734.82" Paid="4.95"/></DisplayCurrency><USD><Cost BookingFee="4.95" GatewayFee="0.00" Price="662.00" TaxAmount="72.82" TaxPercent="11.00" TotalAmount="739.77" TotalAmountIncludesBookingFee="true"/><Charge Due="734.82" Paid="4.95"/></USD></Service></HotelReservation><CustomFields><Field Name="Custom1"/><Field Name="marketingOptIn">false</Field></CustomFields></Reservation></ArnResponse>');
        } else {
            doc.load(req.requestBody.toString());
        }
        DOM.XmlNode rootNodeMain = doc.getRootElement();
        DOM.XmlNode rootNode = rootNodeMain.getChildElement('Reservation',null);
        List<QE360_Event__c> existingEvent = [select id from QE360_Event__c where Name = 'H4H CUG Hotels' and Active__c = true limit 1];
        string eventId = '';
        if(existingEvent.Isempty()){
            QE360_Event__c event = new QE360_Event__c();
            event.Name = 'H4H CUG Hotels';
            event.Active__c = true;
            event.Start_Date__c = Date.newinstance(2019,11,15);
            event.End_Date__c = Date.newinstance(2020,01,01);
            insert event;
            eventId = event.id;
        } else {
            eventId = existingEvent[0].id;
        }
        System.debug('@@@: ' + rootNode);
        Account account = getAccount(rootNode,eventId);
        System.debug('2. Queries used in this Apex code so far: ' + Limits.getQueries());
        Opportunity opportunity = createOpportunity(account, rootNode, eventId);
        System.debug('3. Queries used in this Apex code so far: ' + Limits.getQueries());
        System.debug(opportunity);
        return opportunity;
    }

    private static Account getAccount(DOM.XmlNode rootNode, String eventId) {
        Account account;
        Lead lead;
        DOM.XmlNode childNode = rootNode.getChildElement('HotelReservation',null).getChildElement('Guests',null).getChildElement('Primary',null);
        DOM.XmlNode childAddressNode = rootNode.getChildElement('HotelReservation',null).getChildElement('Guests',null).getChildElement('Primary',null).getChildElement('Address',null);

        if((account = findAccount(childNode.getAttributeValue('Email',null))) != null) {
            account.BillingStreet = childAddressNode.getAttributeValue('Address',null);
            account.BillingCity = childAddressNode.getAttributeValue('City',null);
            account.BillingPostalCode = childAddressNode.getAttributeValue('PostalCode',null);
            account.BillingCountryCode = childAddressNode.getAttributeValue('CountryCode',null);
            account.BillingStateCode = childAddressNode.getAttributeValue('Region',null);
            account.ShippingStreet = childAddressNode.getAttributeValue('Address',null);
            account.ShippingCity = childAddressNode.getAttributeValue('City',null);
            account.ShippingPostalCode = childAddressNode.getAttributeValue('PostalCode',null);
            account.ShippingCountryCode = childAddressNode.getAttributeValue('CountryCode',null);
            account.ShippingStateCode = childAddressNode.getAttributeValue('Region',null);
            account.Phone = childNode.getAttributeValue('PhoneArea',null) + childNode.getAttributeValue('PhoneNumber',null);

            if(account.IsPersonAccount) {
                if(!Test.isRunningTest()) {
                    account.Event_Interest_Picklist__pc = eventId;
                }
            }

            update account;
            return account;
        } else if ((lead = findLead(childNode.getAttributeValue('Email',null))) != null) {
            lead.FirstName = childNode.getAttributeValue('FirstName',null);
            lead.LastName = childNode.getAttributeValue('LastName',null);
            lead.Street = childAddressNode.getAttributeValue('Address',null);
            lead.City = childAddressNode.getAttributeValue('City',null);
            lead.CountryCode = childAddressNode.getAttributeValue('CountryCode',null);
            lead.StateCode = childAddressNode.getAttributeValue('Region',null);
            lead.PostalCode = childAddressNode.getAttributeValue('PostalCode',null);
            lead.Phone = childNode.getAttributeValue('PhoneArea',null) + childNode.getAttributeValue('PhoneNumber',null);
            lead.Event_Interest_Picklist__c = eventId;
            lead.Source__c = 'web f1experiences.com';
            lead.LeadSource = 'web f1experiences.com';
            update lead;
            return convertLead(lead);
        } else {
            lead = createLead(childNode,childAddressNode,eventId);
            return convertLead(lead);
        }
    }

    private static Account findAccount(String email) {
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Email = :email LIMIT 1];
        if (contacts.size() == 0) {
            return null;
        } else {
            return [SELECT Id,IsPersonAccount FROM Account WHERE Id = :contacts[0].AccountId];
        }
    }

    private static Lead findLead(String email) {
        List<Lead> leads = [SELECT Id FROM Lead WHERE Email = :email and IsConverted = false LIMIT 1];
        if (leads.size() == 0) {
            return null;
        } else {
            return leads[0];
        }
    }

    private static Lead createLead(DOM.XmlNode childNode,DOM.XmlNode addressNode,String eventId) {
        Lead lead = new Lead(
            City = addressNode.getAttributeValue('City',null),
            CountryCode = addressNode.getAttributeValue('CountryCode',null),
            Email = childNode.getAttributeValue('Email',null),
            FirstName = childNode.getAttributeValue('FirstName',null),
            LastName = childNode.getAttributeValue('LastName',null),
            Lead_Type__c = 'Person',
            PostalCode = addressNode.getAttributeValue('PostalCode',null),
            StateCode = addressNode.getAttributeValue('Region',null),
            Street = addressNode.getAttributeValue('Address',null),
            Phone = childNode.getAttributeValue('PhoneArea',null) + childNode.getAttributeValue('PhoneNumber',null),
            Source__c = 'web f1experiences.com',
            LeadSource = 'web f1experiences.com',
            Event_Interest_Picklist__c = eventId
        );

        system.debug('lead'+lead);
        insert lead;
        return lead;
    }

    private static Account convertLead(Lead lead) {
        Database.LeadConvertResult result = QE_LeadConversionHelper.convert(lead.Id);
        if (result.isSuccess()) {
            Account account = [SELECT Id FROM Account WHERE Id = :result.getAccountId()];
            account.Copy_Billing_to_Shipping_Address__c = true;
            update account;
            return account;
        } else {
            return null;
        }
    }

    private static Opportunity createOpportunity(Account acct, DOM.XmlNode rootNode, String eventId) {
        DOM.XmlNode childNode = rootNode.getChildElement('HotelReservation',null).getChildElement('Guests',null).getChildElement('Primary',null);
        DOM.XmlNode addressNode = rootNode.getChildElement('HotelReservation',null).getChildElement('Guests',null).getChildElement('Primary',null).getChildElement('Address',null);

        Account account = [ SELECT Id, OwnerId, RecordTypeId, IsPersonAccount FROM Account WHERE Id = :acct.Id];

        // Primary Contact should be the person placing order
        Contact primaryContact = [Select Id From Contact Where Email = :childNode.getAttributeValue('Email',null) Limit 1];

        Opportunity opportunity = new Opportunity(
            AccountId = account.Id,
            Primary_Contact__c = primaryContact.Id,
            Name = 'H4H CUG Hotels',
            CloseDate = System.today(),
            Contact_Site__c = 'f1experiences.com',
            CurrencyIsoCode = 'USD',
            OwnerId = account.OwnerId,
            RecordType = opportunityRecordType(account),
            StageName = 'Closed Won',
            Event__c = eventId,
            Payment_Terms__c = '100%',
            Payment_Method__c = 'Credit Card',
            Phone__c = childNode.getAttributeValue('PhoneArea',null) + childNode.getAttributeValue('PhoneNumber',null),
            Bill_To_Name__c = childNode.getAttributeValue('FirstName',null) + ' ' + childNode.getAttributeValue('LastName',null),
            Billing_Street__c = addressNode.getAttributeValue('Address',null),
            Billing_City__c = addressNode.getAttributeValue('City',null),
            Billing_State_Province__c = getStateName().get(addressNode.getAttributeValue('Region',null)),
            Billing_Zip_Postal_Code__c = addressNode.getAttributeValue('PostalCode',null),
            Billing_Country__c = getCountryName().get(addressNode.getAttributeValue('CountryCode',null)),
            Ship_To_Name__c = childNode.getAttributeValue('FirstName',null) + ' ' + childNode.getAttributeValue('LastName',null),
            Shipping_Street__c = addressNode.getAttributeValue('Address',null),
            Shipping_City__c = addressNode.getAttributeValue('City',null),
            Shipping_State_Province__c = getStateName().get(addressNode.getAttributeValue('Region',null)),
            Shipping_Zip_Postal_Code__c = addressNode.getAttributeValue('PostalCode',null),
            Shipping_Country__c = getCountryName().get(addressNode.getAttributeValue('CountryCode',null)),
            Send_Payment_Email__c = false
        );
        insert opportunity;
        
        addOpportunityLineItem(opportunity,rootNode);              

        return opportunity;
    }

    private static RecordType opportunityRecordType(Account account) {
        String typeName = account.IsPersonAccount ? 'Person' : 'Business';
        return [
            SELECT Id
            FROM RecordType
            WHERE Name = :typeName + ' Opportunity' AND SObjectType = 'Opportunity'
        ];
    }

    public static Pricebook2 pricebook {
        get {
            if (pricebook == null) {
                pricebook = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
            }

            return pricebook;
        }
        private set;
    }

    private static void addOpportunityLineItem(Opportunity opportunity,DOM.XmlNode rootNode) {

        Dom.XMLNode[] roomArray = rootNode.getChildElement('HotelReservation',null).getChildElement('Hotel',null).getChildElement('RatePlan',null).getChildren();
        Decimal dblAmount = 0;
        if(roomArray != null && roomArray.size()>0){
            List<Product2> productExist = [Select Id, (Select id from pricebookentries where currencyIsocode = 'USD' and IsActive = true) from Product2 where name = 'CUG Hotel' and RecordType.DeveloperName = 'Hotels' and Event__c =: opportunity.Event__c and Isactive = True Limit 1];
            String ProductId = '';
            string pricebookentryId = '';
            if(productExist.isEmpty()) {
                Product2 genericproduct = New Product2(
                    Name = 'CUG Hotel',
                    RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),
                    Type__c = 'Hotel',
                    A_La_Carte__c = true,
                    IsActive = true,
                    Available__c = true,
                    Event__c = opportunity.Event__c,
                    CurrencyIsoCode = opportunity.CurrencyIsoCode,
                    Quantity_Per_Order_Threshold__c = 50
                );
                insert genericproduct;
                ProductId = genericproduct.Id;
                Pricebookentry pbentry = New Pricebookentry(
                    Product2Id = ProductId,
                    Pricebook2Id = pricebook.id,
                    UnitPrice = 0.0,
                    IsActive = true,
                    UseStandardPrice = false
                );
                insert pbentry;
                pricebookentryId = pbentry.Id;
            } else {
                ProductId = productExist[0].Id;
                pricebookentryId = productExist[0].pricebookentries[0].Id;
            }

            List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
            
            for(Dom.XMLNode nodebject : roomArray){
                if(nodebject.getName() == 'Room'){
                    system.debug('****11==='+nodebject.getChildElement('Total',null).getAttributeValue('Amount',null));
                    system.debug('****22==='+nodebject.getAttributeValue('Description',null));
                    OpportunityLineItem oppLineItem = new OpportunityLineItem();
                    oppLineItem.Quantity = 1;
                    oppLineItem.OpportunityId = opportunity.Id;
                    oppLineItem.UnitPrice = Double.valueof(nodebject.getChildElement('Total',null).getAttributeValue('Amount',null));
                    oppLineItem.PriceBookEntryId = pricebookentryId;
                    oppLineItem.Record_Type__c = 'A La Carte';
                    oppLineItem.ProductType__c = 'Hotel';
                    if(nodebject.getAttributeValue('Description',null) != null){
                        string strdesc = nodebject.getAttributeValue('Description',null);
                        oppLineItem.Description = strdesc.length()>255?strdesc.substring(0,255):strdesc;
                    }
                    oppLineItemList.add(oppLineItem);
                    dblAmount += oppLineItem.UnitPrice;
                }
            } 

            if(oppLineItemList.size()>0 && !Test.isrunningTest()){
               insert oppLineItemList;
            }
        }
        
        //  Opportunity_Payment_Terms__c oppPaymentTerms = new Opportunity_Payment_Terms__c(
        //     Payment_Term__c = '100%',
        //     CurrencyIsoCode = 'USD',
        //     Opportunity__c = opportunity.id,
        //     Payment_Method__c = 'Credit Card',
        //     Percentage_Of_Payment__c = 100,
        //     Status__c = 'Passed',
        //     Payment_Due_Date__c = system.today(),
        //     Amount__c = dblAmount
        // );
        // Insert oppPaymentTerms;
    }

    public static Map<string,string> getCountryName(){
        Map<String, String> countryMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
          countryMap.put(f.getValue(), f.getLabel());
        }
        return countryMap;
    }

    public static Map<string,string> getStateName(){
        Map<String, String> countryMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = User.Statecode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
          countryMap.put(f.getValue(), f.getLabel());
        }
        return countryMap;
    }
}