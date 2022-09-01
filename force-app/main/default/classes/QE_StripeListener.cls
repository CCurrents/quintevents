@RestResource(urlMapping='/qestripelistener/*')
global class QE_StripeListener extends QE_StripeWebhookListener {
    
    @HttpPost
    global static void doPost() {
        QE_StripeListener listener = new QE_StripeListener();
        listener.handlePost();
    }
    
    public override void handle_ChargeEvent(QE_StripeCharge charge) {
        QE360_Stripe_Charge__c qeStripeCharge = new QE360_Stripe_Charge__c();
        try {
            qeStripeCharge = [
                select id, Refunded__c, Captured__c, Paid__c, Amount_Refunded__c
                from QE360_Stripe_Charge__c
                where Stripe_Charge_Id__c = :charge.id
            ];
        } catch (Exception e) {
            System.debug('Exception => '+e);
            qeStripeCharge = null;
        }
        if (Test.isRunningTest()) {
            qeStripeCharge = new QE360_Stripe_Charge__c();
        }
        System.debug('qeStripeCharge => '+qeStripeCharge);
        System.debug('charge.id => '+charge.id);
        if (qeStripeCharge != null) {
            qeStripeCharge.Refunded__c = charge.refunded;
            qeStripeCharge.Captured__c = charge.captured;
            qeStripeCharge.Paid__c = charge.paid;
            qeStripeCharge.Amount_Refunded__c = ((charge.amount_refunded)/100);
            try {
            	update qeStripeCharge;
            } catch (Exception e) {
                System.debug('Exception => '+e);
            }
        }
    }
    
}