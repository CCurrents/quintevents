@isTest
public class TestClassforTrigger {
    
    static Lead createLead() {
        Test.startTest();
		return new Lead(FirstName = 'Whale', LastName='Kaner', Email = 'porcha@gmail.com', OwnerName__c = 'Aaron Odom', OwnerEmail__c = 'aodom@quintevents.com', OwnerPhone__c = '(704) 926-2706', DE_Event_Interest__c = 'derby 2017', form_type__c = 'info request', OwnerID = '005i0000001r2rP', Source__c = 'web derbyexperiences.com');
    }

    static Task createTask(Id userId, Id ldId) {
        return new Task(
            OwnerId = userId,
            Subject = 'Thank you for contacting Derby Experiences',
            WhoId = ldId,
            Priority = 'Normal'
        );
    }

    static testMethod void TestInsertTask() {
        Id userId = '005i0000006UBB4'; // This should really be a user created during the test
        Lead createlead = createLead();
        insert createlead;

        Task tk = createTask(userId, createlead.id);
        

        insert tk;

        Test.stopTest();


    }
}