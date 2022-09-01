@isTest
global class OutReachAccessTokenMockClass implements HttpCalloutMock{
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"created_at":1659139204,"scope":"audits.all audits.read accounts.all accounts.read accounts","refresh_token":"tno-UzWaKWjRHYgqN2W5vs9pwEfpnw6ckV59cY1hhYU","expires_in":7199,"token_type":"Bearer","access_token":"eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJwcGF0ZWxAcXVpbnRldmVudHMuY29tIiwiaWF0IjoxNjU5MTM5MjA0LCJleHAiOjE2NTkxNDY0MDQsImJlbnRvIjoiYXBwMmEiLCJhY3QiOnsic3ViIjoiR2dYR2Z1TGpDUzlvdUo3OTU2b2VRX3J2WGpFQ05TTGdHUHF4TXJyZDRZcyIsIm5hbWUiOiJRdWludCBFdmVudHMiLCJpc3MiOiJmbGFnc2hpcCIsInR5cGUiOiJhcHAifSwib3JnX3VzZXJfaWQiOjM1NCwiYXVkIjoiUXVpbnQgRXZlbnRzIiwic2NvcGVzIjoiQkFBRUFRQVFBQkVBRWdBVEFDQUFJUUFpQUNNQU1BQXhBRElBTXdCQUFFRUFRZ0JEQW5BQ2NRSnlBbk1ESUFXaEJhSUZvQU1oQXlJREl3TXdBekVETWdNekEwQURRUU5DQTBNQ2dBS0JBb0lDZ3dQd0EvRUQ4Z0JRQUZFQVVnQlRBckFDc1FLeUFyTUVRQVJCQUhBQWNRQnlBSE1BWUFCaEFHSUFZd0dBQVlFQmdnR0RBN0VEc2dPd0E3TUJrQUdSQVpJQmt3Q0FBSUVBZ2dDREFrQUNRUUpDQWtNRGNBTnhBM0lEY3dDUUFKRUFrZ0NUQThBRHdRUENBOE1EZ0FPQkE0SURnd0Z3QVhFQmNnRnpBS0FBb1FDaUFLTUFzQUN4QUxJQXN3R2dBYUVCb2dHakFNQUF3UURDQU1NQlVBRlJBVklCVXdEUUFORUEwZ0RUQU9BQTRRRGlBT01CUUFGQkFVSUJRd0hRQWRFQjBnSFRBV0FCWVFGaUFXTUE4QUR4QVBJQTh3SEFBY0VCd2dIRCIsIm9yZ19ndWlkIjoiZWM4N2IyZmItM2QxMC00YmMxLTljODYtNDA0NTk5NjM4ZjljIiwib3JnX3Nob3J0bmFtZSI6InF1aW50ZXZlbnRzIn0.GjWxWkV47i3CS3_xpTOMRUo6P2jwAjOCUBkoWAzTMGI"}');
        res.setStatusCode(200);
        return res;
    }
}