@isTest
global class RewardMockHttpResponse implements HttpCalloutMock {
	 global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('http://example.com/example/test', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Cache-Control','no-cache');
        res.setHeader('Content-type','application/x-www-form-urlencoded');
        res.setBody('{"MemberId":4999811,"Rewards":0,"Points":900,"RedemptionMultiplier":1.0,"EarnMultiplier":1.0,"Names":[{"FirstName":"H4H","LastName":"Open Demo","BirthDate":null,"Email":"testingemail@gmail.com","Address1":null,"Address2":null,"City":null,"State":null,"Country":null,"Postal":null,"Longitude":null,"Latitude":null,"HomePhone":null,"Referral":null,"ReferralId":"testingemail@gmail.com","RegistrationCode":null,"Password":null,"IsActive":true,"DeleteMember":false,"ReactivateMember":false,"UpdateMemberUsername":false,"CreditCards":null,"FullName":"H4H Open Demo"}],"DebugData":" Successful Existing Member RT-40598-testingemail@gmail.com","Error":null,"CurrentToken":"avUKZeijsMItMCP2PxHVA9GZ2jejcyriwO3Ugi%2fx1MmDCSj1ka7mkeHXVRZShK245jIqUjXxUHXHrF6hct2XKkN63URtAkhcXNW9NpI%2fm4ZCmBt8FRygBr9ZtrflufWxhfRtDTrz9IbGVTcszXjw4MQJ7ZzAgbftevL7o%2fd6CB2qyZ%2f9321AUtYikQyWbYd1Dc%2fRjAKAUJ0XGTsg41KTJrf%2fLsu9hH2fL0h%2fxj%2bHSL8Z9FnpGVyLVrHeuHmRUYx4RPyOzsGpBa%2byePOS%2baQ2spx8W6B%2bmTymv0QXVVEDuOSLSvmm3v2tpLr%2b4%2bZLoi5sQisVbLl75pjQfhIVRXShD3IQnGSBBb4ZGeS%2frKCdJ6X4Wjvec9XUAJ6Y%2fFU6XWwdzqc4NH4FLoiyhvy6ushbcNNo8rNFAVnvQEVjwTWkY5PRGDEFv6yC%2fWGun8CL2KJAi7JPwqQ4TqDkzspti47vX%2b6HlbfKGUVnlI2oMJUCsmmAc9UiyAoT3B9YTQmvqPPzB203%2fDBcZOBAUez6SEXQWOQibTs%2f7hQhHzbbH1tPET8J%2f8cR8zLr%2fegMCQn2V3tdUV%2fbJ4AVadnaZIyqqqOrnHMIlzsQ38%2b2iCJu3zmKiYudLBgElIlr0LEFPL%2bcTo0pjFru3D9jwqxW0GZqSCjAMr1JtZxCZ2h2TXh1kLARGk1rDTmPFS1GBp943%2f3yj79gNCKzEVWlXbZ7gRMRG%2fEctQqJcZnjKnvYeUlfLOmxG6B76PniQcFnJ86M8rPiTKcvAbCT%2fdE91vzZFq5AjvwuUA%3d%3d","TransactionResponse":"true","MetaTag":null,"MemberUsername":"RT-40598-testingemail@gmail.com","MemberProvider":null,"IsArnProvider":true,"AdditionalInfo":null,"MemberType":"Wholesale"}');
        res.setStatusCode(200);
        return res;
    }
}