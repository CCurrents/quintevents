public class MailBoxResponse{
    
    public List<OutReachMailBoxResponse> data;
    public class OutReachMailBoxResponse{
        public String type;	//mailbox
        public Integer id;	//27
        public cls_attributes attributes;
        public cls_relationships relationships;
        public cls_links links;        
    }
    
    public class cls_attributes {
            public Integer authId;	//26
            public String createdAt;	//2018-08-15T14:00:19.000Z
            public boolean editable;
            public String email;	//kdoolan@quintevents.com
            public String emailProvider;	//office365_oauth2
            public String emailSignature;	
            /*<p><strong>KRISTEN DOOLAN</strong><br>
Senior Marketing Coordinator at <a href="http://quintevents.com/">QuintEvents</a><br>
<strong>o</strong> 704-749-5396 | <strong>m</strong> 704-575-8794</p>
<p>9300 &nbsp;&nbsp;Harris Corners Parkway, Suite 120<br>
Charlotte, NC 28269</p>*/
            public String ewsEndpoint;	//https://outlook.office365.com/EWS/Exchange.asmx
            public String ewsSslVerifyMode;
            public String exchangeVersion;
            public String imapHost;
            public String imapPort;
            public String imapSsl;
            public String maxEmailsPerDay;
            public String maxMailingsPerDay;
            public String maxMailingsPerWeek;	//5000
            public String optOutMessage;	//To unsubscribe, click the button below. Thanks!
            public String optOutSignature;	//If you'd like me to stop sending you emails, please <a href="%unsubscribe_url%">click here</a>
            public String prospectEmailExclusions;
            public Integer providerId;	//14
            public String providerType;	//EwsOauthAccount
            public boolean sendDisabled;
            public String sendErroredAt;
            public Integer sendMaxRetries;	//10
            public String sendMethod;	//ews
            public Integer sendPeriod;	//60
            public string sendPermanentErrorAt;
            public boolean sendRequiresSync;
            public String sendSuccessAt;
            public Integer sendThreshold;	//10
            public String sendgridWebhookUrl;	//https://app2a.outreach.io/hooks/sendgrid
            public String smtpHost;
            public String smtpPort;
            public String smtpSsl;
            public String smtpUsername;	//kdoolan@quintevents.com
            public Integer syncActiveFrequency;	//120
            public boolean syncDisabled;
            public String syncErroredAt;
            public String syncFinishedAt;	//2018-09-14T15:58:42.000Z
            public String syncMethod;	//ews
            public string syncOutreachFolder;
            public Integer syncPassiveFrequency;	//600
            public String syncPermanentErrorAt;
            public String syncSuccessAt;	//2018-09-14T15:58:36.000Z
            public String updatedAt;	//2018-09-14T15:58:42.000Z
            public Integer userId;	//33
            public String username;	//kdoolan@quintevents.com
        }
     
        public class cls_relationships {
            public cls_creator creator;
            public cls_mailAliases mailAliases;
            public cls_mailings mailings;
            public cls_updater updater;
            public cls_user user;
        }
        public	class cls_creator {
            public cls_data data;
        }
        public	class cls_data {
            public String type;	//user
            public Integer id;	//33
        }
        public	class cls_mailAliases {
            public cls_links links;
        }
        public	class cls_links {
            public String self;	//https://api.outreach.io/api/v2/mailboxes/27
        }
        public	class cls_mailings {
            public cls_links links;
        }
        public	class cls_updater {
            public cls_data data;
        }
        public	class cls_user {
            public cls_data data;
        }
        
}