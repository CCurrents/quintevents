@isTest
global class MailBoxMockClass  implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {      
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"data":[{"type":"mailbox","id":36,"attributes":{"authId":null,"createdAt":"2018-08-29T17:13:00.000Z","editable":true,"email":"testAddon@grandprixevents.com","emailProvider":null,"emailSignature":null,"ewsEndpoint":null,"ewsSslVerifyMode":null,"exchangeVersion":null,"imapHost":null,"imapPort":null,"imapSsl":null,"maxEmailsPerDay":null,"maxMailingsPerDay":null,"maxMailingsPerWeek":5000,"optOutMessage":"To unsubscribe, click the button below. Thanks!","optOutSignature":"If youd like me to stop sending you emails, please \u003ca href=\"%unsubscribe_url%\"\u003eclick here\u003c/a\u003e","prospectEmailExclusions":null,"providerId":null,"providerType":null,"sendDisabled":true,"sendErroredAt":null,"sendMaxRetries":10,"sendMethod":"smtp","sendPeriod":60,"sendPermanentErrorAt":null,"sendRequiresSync":true,"sendSuccessAt":null,"sendThreshold":10,"sendgridWebhookUrl":"https://app2a.outreach.io/hooks/sendgrid","smtpHost":null,"smtpPort":null,"smtpSsl":null,"smtpUsername":null,"syncActiveFrequency":120,"syncDisabled":true,"syncErroredAt":null,"syncFinishedAt":null,"syncMethod":"imap","syncOutreachFolder":null,"syncPassiveFrequency":600,"syncPermanentErrorAt":null,"syncSuccessAt":null,"updatedAt":"2018-08-29T17:13:00.000Z","userId":41,"username":"blearst=quintevents.com@example.com"},"relationships":{"creator":{"data":null},"mailAliases":{"links":{"related":"https://api.outreach.io/api/v2/mailAliases?filter%5Bmailbox%5D%5Bid%5D=36"}},"mailings":{"links":{"related":"https://api.outreach.io/api/v2/mailings?filter%5Bmailbox%5D%5Bid%5D=36"}},"updater":{"data":null},"user":{"data":{"type":"user","id":41}}},"links":{"self":"https://api.outreach.io/api/v2/mailboxes/36"}}]}');
        res.setStatusCode(200);
        return res;
    }

}