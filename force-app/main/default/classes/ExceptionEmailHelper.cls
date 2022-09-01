public class ExceptionEmailHelper {
    
    public void compileAndSend(Exception e, String className) {
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'jpatel@quintevents.com'};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Apex error message');
        mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
        String plainTextBody = 
            'Class: ' + className
            + '\nLine: '+ e.getLineNumber()
            + '\nCause: ' + e.getCause()
            + '\nMessage: ' + e.getMessage()
            + '\nUser: ' + UserInfo.getName() + ' (' + UserInfo.getUserId() + ')'
            + '\nOrg: ' + UserInfo.getOrganizationName() + ' (' + UserInfo.getOrganizationId() + ')'
            + '\nDateTime: ' + (System.now()).format('EEE, MM/dd/yyyy hh:mm:ss a');

            
        mail.setPlainTextBody(plainTextBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}