/**
 * @File Name          : QE_H4H_Create_Reservation_Rooming_CNTRL.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 5:55:14 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
public class QE_H4H_Create_Reservation_Rooming_CNTRL{
   /* public Id roomListId;
    public Id oliID;
    public Rooming_List__c roomingList;
    public boolean displayPopup {get;set;}*/
    

    public QE_H4H_Create_Reservation_Rooming_CNTRL(ApexPages.StandardController stdController) {
        closePopup();
        createReservationAndRedirect();
        // roomListId = stdController.getId();
        //displayPopup = true;
        
        // List<Rooming_List__c> roomList = new List<Rooming_List__c>([Select Id,Guest_Name__c,Opportunity__c,OpportunityLineItem_Id__c from Rooming_List__c where Id = :roomListId]);
        
        // if(roomList.size() > 0) {
        //     roomingList = roomList[0];
        //     oliID = roomList[0].OpportunityLineItem_Id__c;
        //     List<Opportunity_Payment_Terms__c> oppPayTerms = new List<Opportunity_Payment_Terms__c>([Select Id from Opportunity_Payment_Terms__c where Opportunity__c = :roomingList.Opportunity__c AND (Status__c = 'Passed' OR Payment_Method__c = 'Value-In-Kind')]);
        //     if(oppPayTerms.size() > 0 && roomList.size() > 0 && String.isNotBlank(roomList[0].Guest_Name__c)) {
        //         displayPopup = false;
        //         //oli = olis[0];
        //     }
        // }
    }

    public pageReference closePopup() {
        /*displayPopup = false;
        pageReference ref = new pageReference('/' + roomListId);
        ref.setRedirect(true);
        return ref;*/
        return null;
    }

    public pageReference createReservationAndRedirect() {
        pageReference pr = null;

        // if(!displayPopup) {
        //     List<Opportunity> lstOpportunity = new List<Opportunity>([Select Id, CurrencyIsoCode, Primary_Contact__c, Primary_Contact__r.FirstName, Primary_Contact__r.LastName,
        //                                                             Primary_Contact__r.Email, Primary_Contact__r.Phone, Primary_Contact__r.Country_Code__c,Event__c,Event__r.H4H_Site_Id__c,
        //                                                             Primary_Contact__r.MailingStreet, Primary_Contact__r.MailingCity, Primary_Contact__r.MailingPostalCode, Primary_Contact__r.MailingCountryCode, Primary_Contact__r.MailingStateCode,
        //                                                             (Select Id, Status__c,Payment_Method__c from Opportunity_Payment_Terms__r where Status__c = 'Passed' OR Payment_Method__c = 'Value-In-Kind' Order by LastModifiedDate desc Limit 1),
        //                                                             (Select Id, Name, Hotel_Id__c,Check_In_Date__c,Check_Out_Date__c, Room_Type_Hotel__c, Quantity, H4H_Adult_Quantity__c,H4H_Need_to_Hold__c,
        //                                                             H4H_Itinerary_Id__c, H4H_Reservation_Id__c,H4H_Hold_Created__c, H4H_RatePlan_Code__c, H4H_Reservation_Created__c, H4H_Room_Code__c, Roomtype_Id__c from OpportunityLineItems
        //                                                             where Id = :oliID AND Check_In_Date__c != Null AND Check_Out_Date__c != Null AND Hotel_Id__c != NUll AND H4H_Hold_Created__c = true)
        //                                                             from Opportunity where Id = :roomingList.Opportunity__c]);

        //     QE_H4HHotelProcess.reservationCreateRequestCommon(lstOpportunity, true);
        //     pr = closePopup();
        // }

        return pr;
        
    }
}