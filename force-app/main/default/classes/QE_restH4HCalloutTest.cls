@isTest
global class QE_restH4HCalloutTest  implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"MemberId":1004186,"Rewards":0,"Points":480,"RedemptionMultiplier":1.0,"EarnMultiplier":1.0,"Names":[{"FirstName":"sc","LastName":"test005","BirthDate":null,"Email":"sdrt@test.com","Address1":null,"Address2":null,"City":null,"State":null,"Country":null,"Postal":null,"Longitude":null,"Latitude":null,"HomePhone":null,"Referral":null,"ReferralId":"sdrt@test.com","Password":null,"IsActive":true,"DeleteMember":false,"UpdateMemberUsername":false,"CreditCards":null,"FullName":"sc test005"}],"DebugData":" Successful Existing Member RT-40598-sdrt@test.com","Error":null,"CurrentToken":"X%2fSsVJs3U73FYiQ3pn4%2frrmC5INmun4wAJS8PIgydUoGKgi9H6nxtShP7txRHniFHRn007bSQPd0PH5M8p36uv6XHmaTQ%2fiYaOKTosFRug8p0dvGv4lPTA25SWmY6HWAZyW2rmzgYx8fDkG4nQ%2bNk%2b0bIsy9MbSkKYNhCU7yOlYqvofrZSVFr3o1Mr%2bTm3Zh%2fLE5fougAW8ceX00KnD8%2bFj83TWAKzCJEKO7Ol31MkiqXP1%2bqlcRf8GkTy1BRC9N6VtQN4OuHLwR5yirsuTRABjKw4YyL9%2fGvbbZfAPUt0Y8tTAAlbHFMvStfVflGfRW7t%2f9BcvnkSyWTpherbefBi8Boxf0UpfSf1aA0k3UH8wUUWjCYdWEkPnPgY6Uy3VyLCJIRx%2bZfvcHVrmUtr%2fOYxm23m5rg2IeonDwo8JHdMuzE2XqNYJWd5JvtdOY98T9cS3%2bsXtJtKM01KSYV6MO3%2fuBS11%2b5TuinHJKN%2fnHs3gNTHgRJDcMnCsVjJsciy1jtQ2ITmr8%2bpWhkHH4Y34mkXjMUXDRekfh%2fVMzYtP9c%2fanzIzFelN3JnN3ENeWuz8vCzZUdKXsmw6GxzjQzjQv9AIWUkruSDtFOCDpJWhVjb735Zo8zhFewMAckegN0CGo9K7oo3Vhzwpgcznyrf5Ym8ZzZTI5YapoznkJdqZmvM2xcHbreuWNCX%2bUKriwyVStkxGxKutz1fyDB12noJVn9cnc1yHQyJZmBFxGiEg8KJ5WiU8igqymZWpwWtPEKz7r","TransactionResponse":"true","MetaTag":null,"MemberUsername":"RT-40598-sdrt@test.com","MemberProvider":null,"IsArnProvider":true,"AdditionalInfo":null,"MemberType":"Wholesale"}');
        response.setStatusCode(200);
        return response; 
    }
}