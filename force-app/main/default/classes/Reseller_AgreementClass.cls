/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 11-02-2020
 * @last modified by  : jagrawal@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   09-30-2020   jagrawal@addonblue.com   Initial Version
 * 1.1   10-27-2020   jagrawal@addonblue.com   #596 Changed RecordType name from Travel Agent to Reseller
 * 1.2   11-02-2020   jagrawal@addonblue.com   #610 Travel Agent related changes
 * 1.3   04-05-2021   cshah@addonblue.com      #866 Reseller lead convert and agreement changes
**/

public class Reseller_AgreementClass {
    public Contact con { get; set; }
    public Reseller_AgreementClass(){
        Id id = ApexPages.currentPage().getParameters().get('id');
        //changed recordtype name for #596
        List<Contact> lstContacts = [Select id,Name,Account.BillingStreet,Account.BillingCity,Account.Billingstate,
                                     Account.BillingPostalCode,Account.BillingCountry,Account.RecordType.Name,Title,
                                     Account.Name from Contact 
                                     WHERE Account.RecordType.Name = 'Reseller' AND Id = :id];
        if(lstContacts.size() > 0){ con = lstContacts[0]; }
    }
}