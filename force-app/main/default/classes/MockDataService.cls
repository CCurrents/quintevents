/**
 * Created by joshlequire1 on 9/5/22.
 */

public with sharing class MockDataService {

    public static void createMockData() {
        //Disable Duplicate Rules for Inserts
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.duplicateRuleHeader.allowSave = true;
        dml.duplicateRuleHeader.runAsCurrentUser = true;

        //Setup Leads
        Id standardLeadRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        List<Lead> newLeads = new List<Lead>{
                new Lead(Salutation = 'Mr.', FirstName = 'Fulvia', LastName = 'Mullen', Email = 'codery1@bearsvip.com', Status = 'Open', Website = 'https://tripod.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Mrs.', FirstName = 'Steward', LastName = 'Daulton', Email = 'codery2@bearsvip.com', Status = 'Open', Website = 'http://canalblog.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Mr.', FirstName = 'Christina', LastName = 'Niblo', Email = 'codery3@bearsvip.com', Status = 'Open', Website = 'https://baidu.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Prof.', FirstName = 'Luella', LastName = 'Thickins', Email = 'codery4@bearsvip.com', Status = 'Open', Website = 'http://amazonaws.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Mr.', FirstName = 'Renault', LastName = 'Fluin', Email = 'codery5@bearsvip.com', Status = 'Open', Website = 'http://umn.edu', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Mrs.', FirstName = 'Avis', LastName = 'Twatt', Email = 'codery6@bearsvip.com', Status = 'Open', Website = 'http://mtv.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Ms.', FirstName = 'Ulberto', LastName = 'Peller', Email = 'codery7@bearsvip.com', Status = 'Open', Website = 'http://xrea.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Mr.', FirstName = 'Harlen', LastName = 'Leindecker', Email = 'codery8@bearsvip.com', Status = 'Open', Website = 'http://last.fm', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Ms.', FirstName = 'Tanya', LastName = 'Dafydd', Email = 'codery9@bearsvip.com', Status = 'Open', Website = 'https://reuters.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Mrs.', FirstName = 'Pamela', LastName = 'Jekel', Email = 'codery10@bearsvip.com', Status = 'Open', Website = 'https://fastcompany.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Prof.', FirstName = 'Marlie', LastName = 'Hankinson', Email = 'codery11@bearsvip.com', Status = 'Open', Website = 'http://friendfeed.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Dr.', FirstName = 'Christalle', LastName = 'Gerrels', Email = 'codery12@bearsvip.com', Status = 'Open', Website = 'http://about.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Mr.', FirstName = 'Sterne', LastName = 'Commusso', Email = 'codery13@bearsvip.com', Status = 'Open', Website = 'http://cornell.edu', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Prof.', FirstName = 'Sue', LastName = 'Dodgshon', Email = 'codery14@bearsvip.com', Status = 'Open', Website = 'http://yolasite.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Ms.', FirstName = 'Vincenz', LastName = 'Jadczak', Email = 'codery15@bearsvip.com', Status = 'Open', Website = 'https://wikispaces.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Ms.', FirstName = 'Kora', LastName = 'Knowler', Email = 'codery16@bearsvip.com', Status = 'Open', Website = 'http://army.mil', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Dr.', FirstName = 'Collete', LastName = 'Maidment', Email = 'codery17@bearsvip.com', Status = 'Open', Website = 'http://ning.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Prof.', FirstName = 'Kellie', LastName = 'Sysland', Email = 'codery18@bearsvip.com', Status = 'Open', Website = 'http://163.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Prof.', FirstName = 'Simeon', LastName = 'Ashness', Email = 'codery19@bearsvip.com', Status = 'Open', Website = 'http://shinystat.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Prof.', FirstName = 'Webster', LastName = 'Kelloway', Email = 'codery20@bearsvip.com', Status = 'Open', Website = 'http://wikipedia.org', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Dr.', FirstName = 'Boycey', LastName = 'Euston', Email = 'codery21@bearsvip.com', Status = 'Open', Website = 'https://upenn.edu', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Ms.', FirstName = 'Inesita', LastName = 'Hetterich', Email = 'codery22@bearsvip.com', Status = 'Open', Website = 'https://jalbum.net', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Prof.', FirstName = 'Ryun', LastName = 'Stennes', Email = 'codery23@bearsvip.com', Status = 'Open', Website = 'https://hugedomains.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Prof.', FirstName = 'Catie', LastName = 'Elsbury', Email = 'codery24@bearsvip.com', Status = 'Open', Website = 'https://ucla.edu', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT),
                new Lead(Salutation = 'Mrs.', FirstName = 'Joanie', LastName = 'Giacopazzi', Email = 'codery25@bearsvip.com', Status = 'Open', Website = 'http://com.com', Source__c = 'Web chicagobearsvip.com', Marketing_Email_Consent__c = 'Yes', CurrencyIsoCode = 'USD', RecordTypeId = standardLeadRT)
        };
        Database.insert(newLeads, dml);

//Setup PersonAccounts
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        List<Account> newPersonAccounts = new List<Account>{
                new Account(Salutation = 'Mrs.', FirstName = 'Rutger', LastName = 'Valti', PersonEmail = 'codery1@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Prof.', FirstName = 'Deina', LastName = 'Rope', PersonEmail = 'codery2@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Dr.', FirstName = 'Carlyn', LastName = 'Giblett', PersonEmail = 'codery3@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Mrs.', FirstName = 'Maggee', LastName = 'Winton', PersonEmail = 'codery4@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Mrs.', FirstName = 'Abbott', LastName = 'Dowdall', PersonEmail = 'codery5@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Dr.', FirstName = 'Kirstin', LastName = 'Leachman', PersonEmail = 'codery6@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Mr.', FirstName = 'Yul', LastName = 'Mogey', PersonEmail = 'codery7@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Dr.', FirstName = 'Darnall', LastName = 'Thairs', PersonEmail = 'codery8@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Mr.', FirstName = 'Else', LastName = 'Sadlier', PersonEmail = 'codery9@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Prof.', FirstName = 'Hedda', LastName = 'Schoroder', PersonEmail = 'codery10@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Prof.', FirstName = 'Silva', LastName = 'Tatton', PersonEmail = 'codery11@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Mrs.', FirstName = 'Kristos', LastName = 'Merritt', PersonEmail = 'codery12@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Mr.', FirstName = 'Gabbey', LastName = 'Twittey', PersonEmail = 'codery13@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Mrs.', FirstName = 'Davis', LastName = 'Shemilt', PersonEmail = 'codery14@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Prof.', FirstName = 'Aloysia', LastName = 'Godfrey', PersonEmail = 'codery15@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Dr.', FirstName = 'Oriana', LastName = 'Lemin', PersonEmail = 'codery16@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Dr.', FirstName = 'Tades', LastName = 'Chappel', PersonEmail = 'codery17@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Mrs.', FirstName = 'Gerhardt', LastName = 'Cowdry', PersonEmail = 'codery18@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Dr.', FirstName = 'Lauralee', LastName = 'Gomes', PersonEmail = 'codery19@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Ms.', FirstName = 'Quinn', LastName = 'Roebuck', PersonEmail = 'codery20@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Ms.', FirstName = 'Marjorie', LastName = 'Szanto', PersonEmail = 'codery21@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Dr.', FirstName = 'Deloris', LastName = 'Teacy', PersonEmail = 'codery22@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Mrs.', FirstName = 'Coleen', LastName = 'Urquhart', PersonEmail = 'codery23@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Mr.', FirstName = 'Rene', LastName = 'Pauncefoot', PersonEmail = 'codery24@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT),
                new Account(Salutation = 'Ms.', FirstName = 'Reyna', LastName = 'Warricker', PersonEmail = 'codery25@bearsvip.com', Source__pc = 'call quintloyalty.com', CurrencyIsoCode = 'USD', RecordTypeId = personAccountRT)
        };
        //Database.insert(newPersonAccounts, dml);

        insert newPersonAccounts;

        Set<Id> newAccountIds = new Set<Id>();

        for (Account acct : newPersonAccounts) {
            newAccountIds.add(acct.Id);
        }

        System.debug(newAccountIds);

        Map<String, Account> accountMap = new Map<String, Account>();
        Integer paIterator = 1;
        List<Account> newAccountsWithIds = [SELECT Id, PersonContactId FROM Account WHERE Id IN :newAccountIds];
        System.debug(newAccountsWithIds);
        for (Account acct : newAccountsWithIds) {
            accountMap.put(String.valueOf(paIterator), acct);
            paIterator++;
        }

        System.debug(accountMap);

//Setup Program
        Program__c bearsVIPProgram = new Program__c(Name = 'Chicago Bears VIP', Contact_Site__c = 'chicagobearsvip.com');
        insert bearsVIPProgram;

// Setup Orders and LineItems
        List<Order> newOrders = new List<Order>{
                new Order(Description = '8014z000001oeWNAAY', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-06-21'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001of2hAAA', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-06-22'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001oencAAA', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-06-22'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001oeudAAA', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-06-22'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001oewKAAQ', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-06-22'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001oeVEAAY', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-06-21'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001os6mAAA', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-07-11'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001ojcjAAA', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-06-28'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001oUY9AAM', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-06-09'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001n0zfAAA', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-06-01'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001mx8xAAA', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-05-25'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001oPBnAAM', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-06-06'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001oPAzAAM', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-06-06'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001osotAAA', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-07-12'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001oslzAAA', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-07-12'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000001osrOAAQ', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-07-12'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000000BSy2AAG', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-05-12'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000000BSyvAAG', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-05-12'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000000BTJPAA4', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-05-15'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z000000BTLGAA4', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-05-15'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z0000024wqxAAA', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-08-29'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z0000024xyOAAQ', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-09-01'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z0000024xz2AAA', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-09-01'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z0000024stdAAA', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-08-19'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid'),
                new Order(Description = '8014z0000024yE2AAI', Pricebook2Id = '01s4z0000004gfHAAQ', EffectiveDate = Date.valueOf('2022-09-02'), Status = 'Draft', CurrencyIsoCode = 'USD', IsReductionOrder = false, Order_Payment_Status__c = 'Fully Paid')
        };

        List<Order> ordersForInsert = new List<Order>();
        Integer orderAccountIterator = 1;
        for (Order ord : newOrders) {
            Account thisAccount = accountMap.get(String.valueOf(orderAccountIterator));
            System.debug(thisAccount);
            Order orderForInsert = new Order();
            orderForInsert.Description = ord.Description;
            orderForInsert.Pricebook2Id = ord.Pricebook2Id;
            orderForInsert.EffectiveDate = ord.EffectiveDate;
            orderForInsert.Status = ord.Status;
            orderForInsert.CurrencyIsoCode = ord.CurrencyIsoCode;
            orderForInsert.IsReductionOrder = ord.IsReductionOrder;
            orderForInsert.Order_Payment_Status__c = ord.Order_Payment_Status__c;
            orderForInsert.AccountId = thisAccount.Id;
            orderForInsert.BillToContactId = thisAccount.PersonContactId;
            orderForInsert.ShipToContactId = thisAccount.PersonContactId;
            System.debug(orderForInsert);
            ordersForInsert.add(orderForInsert);

            if (orderAccountIterator == 25) {
                orderAccountIterator = 1;
            } else {
                orderAccountIterator++;
            }
        }

        insert ordersForInsert;

        Map<String, Order> orderMap = new Map<String, Order>();

        for (Order ord : ordersForInsert) {
            orderMap.put(ord.Description, ord);
        }

        List<OrderItem> newOrderItems = new List<OrderItem>{
                new OrderItem(Description = '8014z000000BSy2AAG', PricebookEntryId = '01u4z00000IwoycAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BSy2AAG', PricebookEntryId = '01u4z00000IwoyxAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BSy2AAG', PricebookEntryId = '01u4z00000IwozIAAR', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BSy2AAG', PricebookEntryId = '01u4z00000IwowvAAB', Quantity = 2, UnitPrice = 799),
                new OrderItem(Description = '8014z000000BSy2AAG', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BSy2AAG', PricebookEntryId = '01u4z00000IwotJAAR', Quantity = 1, UnitPrice = 127.84),
                new OrderItem(Description = '8014z000000BSy2AAG', PricebookEntryId = '01u4z00000IwoxbAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BSyvAAG', PricebookEntryId = '01u4z00000IwoyxAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BSyvAAG', PricebookEntryId = '01u4z00000IwozPAAR', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BSyvAAG', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BSyvAAG', PricebookEntryId = '01u4z00000IwoxNAAR', Quantity = 2, UnitPrice = 1099),
                new OrderItem(Description = '8014z000000BSyvAAG', PricebookEntryId = '01u4z00000Iwoy3AAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BTJPAA4', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 4, UnitPrice = 259),
                new OrderItem(Description = '8014z000000BTJPAA4', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 4, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BTJPAA4', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 4, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BTJPAA4', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BTJPAA4', PricebookEntryId = '01u4z00000IwotJAAR', Quantity = 1, UnitPrice = 82.88),
                new OrderItem(Description = '8014z000000BTJPAA4', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 4, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BTLGAA4', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 3, UnitPrice = 259),
                new OrderItem(Description = '8014z000000BTLGAA4', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 3, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BTLGAA4', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 3, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BTLGAA4', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000000BTLGAA4', PricebookEntryId = '01u4z00000IwotJAAR', Quantity = 1, UnitPrice = 62.16),
                new OrderItem(Description = '8014z000000BTLGAA4', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 3, UnitPrice = 0),
                new OrderItem(Description = '8014z000001mx8xAAA', PricebookEntryId = '01u4z00000IwoyxAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000001mx8xAAA', PricebookEntryId = '01u4z00000IwozPAAR', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000001mx8xAAA', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001mx8xAAA', PricebookEntryId = '01u4z00000IwoxNAAR', Quantity = 2, UnitPrice = 1099),
                new OrderItem(Description = '8014z000001mx8xAAA', PricebookEntryId = '01u4z00000IwotJAAR', Quantity = 1, UnitPrice = 175.84),
                new OrderItem(Description = '8014z000001mx8xAAA', PricebookEntryId = '01u4z00000Iwoy3AAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000001mx8xAAA', PricebookEntryId = '01u4z00000Iwsf7AAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000001n0zfAAA', PricebookEntryId = '01u4z00000IwoycAAB', Quantity = 5, UnitPrice = 0),
                new OrderItem(Description = '8014z000001n0zfAAA', PricebookEntryId = '01u4z00000IwoyxAAB', Quantity = 5, UnitPrice = 0),
                new OrderItem(Description = '8014z000001n0zfAAA', PricebookEntryId = '01u4z00000IwozBAAR', Quantity = 5, UnitPrice = 0),
                new OrderItem(Description = '8014z000001n0zfAAA', PricebookEntryId = '01u4z00000IwowoAAB', Quantity = 5, UnitPrice = 859),
                new OrderItem(Description = '8014z000001n0zfAAA', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001n0zfAAA', PricebookEntryId = '01u4z00000IwoxUAAR', Quantity = 5, UnitPrice = 0),
                new OrderItem(Description = '8014z000001n0zfAAA', PricebookEntryId = '01u4z00000IwotJAAR', Quantity = 1, UnitPrice = 343.6),
                new OrderItem(Description = '8014z000001oencAAA', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 1, UnitPrice = 259),
                new OrderItem(Description = '8014z000001oencAAA', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oencAAA', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oencAAA', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oencAAA', PricebookEntryId = '01u4z00000IwotJAAR', Quantity = 1, UnitPrice = 20.72),
                new OrderItem(Description = '8014z000001oencAAA', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oeudAAA', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 1, UnitPrice = 259),
                new OrderItem(Description = '8014z000001oeudAAA', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oeudAAA', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oeudAAA', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oeudAAA', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oeVEAAY', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 2, UnitPrice = 259),
                new OrderItem(Description = '8014z000001oeVEAAY', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oeVEAAY', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oeVEAAY', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oeVEAAY', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oewKAAQ', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 1, UnitPrice = 259),
                new OrderItem(Description = '8014z000001oewKAAQ', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oewKAAQ', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oewKAAQ', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oewKAAQ', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oeWNAAY', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 1, UnitPrice = 259),
                new OrderItem(Description = '8014z000001oeWNAAY', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oeWNAAY', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oeWNAAY', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oeWNAAY', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001of2hAAA', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 1, UnitPrice = 259),
                new OrderItem(Description = '8014z000001of2hAAA', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001of2hAAA', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001of2hAAA', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001of2hAAA', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001ojcjAAA', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 1, UnitPrice = 259),
                new OrderItem(Description = '8014z000001ojcjAAA', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001ojcjAAA', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001ojcjAAA', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001ojcjAAA', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oPAzAAM', PricebookEntryId = '01u4z00000IwoycAAB', Quantity = 3, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oPAzAAM', PricebookEntryId = '01u4z00000IwoyxAAB', Quantity = 3, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oPAzAAM', PricebookEntryId = '01u4z00000IwozBAAR', Quantity = 3, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oPAzAAM', PricebookEntryId = '01u4z00000IwowoAAB', Quantity = 3, UnitPrice = 859),
                new OrderItem(Description = '8014z000001oPAzAAM', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oPAzAAM', PricebookEntryId = '01u4z00000IwoxUAAR', Quantity = 3, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oPBnAAM', PricebookEntryId = '01u4z00000IwoycAAB', Quantity = 3, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oPBnAAM', PricebookEntryId = '01u4z00000IwoyxAAB', Quantity = 3, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oPBnAAM', PricebookEntryId = '01u4z00000IwozWAAR', Quantity = 3, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oPBnAAM', PricebookEntryId = '01u4z00000Iwox2AAB', Quantity = 3, UnitPrice = 749),
                new OrderItem(Description = '8014z000001oPBnAAM', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oPBnAAM', PricebookEntryId = '01u4z00000IwoxiAAB', Quantity = 3, UnitPrice = 0),
                new OrderItem(Description = '8014z000001os6mAAA', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 1, UnitPrice = 259),
                new OrderItem(Description = '8014z000001os6mAAA', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001os6mAAA', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001os6mAAA', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001os6mAAA', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oslzAAA', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 5, UnitPrice = 259),
                new OrderItem(Description = '8014z000001oslzAAA', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 5, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oslzAAA', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 5, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oslzAAA', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oslzAAA', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 5, UnitPrice = 0),
                new OrderItem(Description = '8014z000001osotAAA', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 2, UnitPrice = 259),
                new OrderItem(Description = '8014z000001osotAAA', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000001osotAAA', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000001osotAAA', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001osotAAA', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000001osrOAAQ', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 4, UnitPrice = 259),
                new OrderItem(Description = '8014z000001osrOAAQ', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 4, UnitPrice = 0),
                new OrderItem(Description = '8014z000001osrOAAQ', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 4, UnitPrice = 0),
                new OrderItem(Description = '8014z000001osrOAAQ', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001osrOAAQ', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 4, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oUY9AAM', PricebookEntryId = '01u4z00000IwozPAAR', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oUY9AAM', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oUY9AAM', PricebookEntryId = '01u4z00000IwoxNAAR', Quantity = 2, UnitPrice = 1099),
                new OrderItem(Description = '8014z000001oUY9AAM', PricebookEntryId = '01u4z00000IwotJAAR', Quantity = 1, UnitPrice = 175.84),
                new OrderItem(Description = '8014z000001oUY9AAM', PricebookEntryId = '01u4z00000Iwoy3AAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z000001oUY9AAM', PricebookEntryId = '01u4z00000Iwsf7AAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024stdAAA', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 4, UnitPrice = 259),
                new OrderItem(Description = '8014z0000024stdAAA', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 4, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024stdAAA', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 4, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024stdAAA', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024stdAAA', PricebookEntryId = '01u4z00000IwotJAAR', Quantity = 1, UnitPrice = 98.42),
                new OrderItem(Description = '8014z0000024stdAAA', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 4, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024wqxAAA', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 1, UnitPrice = 259),
                new OrderItem(Description = '8014z0000024wqxAAA', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024wqxAAA', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024wqxAAA', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024wqxAAA', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000Kg1qpAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000Kg1qpAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000IwoycAAB', Quantity = 5, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000IwoycAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000IwoyxAAB', Quantity = 5, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000IwoyxAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000IwozrAAB', Quantity = 5, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000IwozrAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000IwoyAAAR', Quantity = 5, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000IwoyAAAR', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000IwoyVAAR', Quantity = 2, UnitPrice = 899),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000IwoyVAAR', Quantity = 5, UnitPrice = 899),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000JsReGAAV', Quantity = 1, UnitPrice = 321),
                new OrderItem(Description = '8014z0000024xyOAAQ', PricebookEntryId = '01u4z00000JsRe2AAF', Quantity = 1, UnitPrice = 321),
                new OrderItem(Description = '8014z0000024xz2AAA', PricebookEntryId = '01u4z00000IwoycAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xz2AAA', PricebookEntryId = '01u4z00000IwoycAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xz2AAA', PricebookEntryId = '01u4z00000IwoyxAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xz2AAA', PricebookEntryId = '01u4z00000IwoyxAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xz2AAA', PricebookEntryId = '01u4z00000IwosdAAB', Quantity = 1, UnitPrice = -2928),
                new OrderItem(Description = '8014z0000024xz2AAA', PricebookEntryId = '01u4z00000IwozrAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xz2AAA', PricebookEntryId = '01u4z00000IwozrAAB', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xz2AAA', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xz2AAA', PricebookEntryId = '01u4z00000IwoyAAAR', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xz2AAA', PricebookEntryId = '01u4z00000IwoyAAAR', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024xz2AAA', PricebookEntryId = '01u4z00000IwoyVAAR', Quantity = 2, UnitPrice = 899),
                new OrderItem(Description = '8014z0000024xz2AAA', PricebookEntryId = '01u4z00000IwoyVAAR', Quantity = 2, UnitPrice = 899),
                new OrderItem(Description = '8014z0000024xz2AAA', PricebookEntryId = '01u4z00000JsRgBAAV', Quantity = 2, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024yE2AAI', PricebookEntryId = '01u4z00000IwoyjAAB', Quantity = 3, UnitPrice = 259),
                new OrderItem(Description = '8014z0000024yE2AAI', PricebookEntryId = '01u4z00000IwozdAAB', Quantity = 3, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024yE2AAI', PricebookEntryId = '01u4z00000IwowhAAB', Quantity = 3, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024yE2AAI', PricebookEntryId = '01u4z00000IwosdAAB', Quantity = 1, UnitPrice = -777),
                new OrderItem(Description = '8014z0000024yE2AAI', PricebookEntryId = '01u4z00000IwosrAAB', Quantity = 1, UnitPrice = 0),
                new OrderItem(Description = '8014z0000024yE2AAI', PricebookEntryId = '01u4z00000IwoyHAAR', Quantity = 3, UnitPrice = 0)
        };

        List<OrderItem> oisForInsert = new List<OrderItem>();

        for (OrderItem oi : newOrderItems) {
            OrderItem oiForInsert = new OrderItem();
            oiForInsert.Description = oi.Description;
            oiForInsert.PricebookEntryId = oi.PricebookEntryId;
            oiForInsert.Quantity = oi.Quantity;
            oiForInsert.UnitPrice = oi.UnitPrice;
            oiForInsert.OrderId = orderMap.get(oi.Description).Id;
            oisForInsert.add(oiForInsert);
        }

        insert oisForInsert;

    }

}