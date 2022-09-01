/*
@Name             : Stripe
@Author           : Aslam Bari/Sanjay Mankani (http://www.aslambari.com/stripe_apex_toolkit.html)
@Date             : 6 Oct, 2011
@Description      : This class is the stripe class used to call all Stripe methods.
                      
*/

public class Stripe{

    String API_KEY='';
    public Stripe(string apiKey){
        API_KEY = apiKey;
    }
    
    public StripeResponseModel createCharge(string cnumber, string exp_year, string exp_month, string cvc, string amount, string curncy, string description){
        StripeCharge strChr=new StripeCharge(API_KEY);
        return strChr.CreateCharge(cnumber,exp_year,exp_month,cvc,amount,curncy,description);
    }
    
    public StripeResponseModel createCharge(string customerId,integer amount, string curncy, string description, string eventName){
        StripeCharge strChr=new StripeCharge(API_KEY);
        return strChr.CreateCharge(customerId,amount,curncy,description,eventName);
    }
    
    public StripeResponseModel retrieveCharge(String chargeId){
        StripeCharge strChr=new StripeCharge(API_KEY);
        return strChr.retrieveCharge(chargeId);
    }
    
    public StripeResponseModel createCustomer(String cnumber,String exp_month,String exp_year,String cvc,String name,String addressLine1,String addressLine2,String zip,String state,String country,String email,String description,String salesRepEmail){
        StripeCustomer strCust=new StripeCustomer(API_KEY); 
        return strCust.createCustomer(cnumber,exp_month,exp_year,cvc,name,addressLine1,addressLine2,zip,state,country,email,description,salesRepEmail);
    }
    
    public String updateCustomerRaw(String stripeCusId, String newDefaultCardId){
        StripeCustomer strCust=new StripeCustomer(API_KEY); 
        return strCust.updateCustomerRaw(stripeCusId,newDefaultCardId);
    }
    
    public StripeResponseModel retrieveCustomer(String customerId){
        StripeCustomer strCust=new StripeCustomer(API_KEY);
        return strCust.retrieveCustomer(customerId);
    }

    public String retrieveCustomerRaw(String customerId){
        StripeCustomer strCust=new StripeCustomer(API_KEY);
        return strCust.retrieveCustomerRaw(customerId);
    }        
    
    public StripeResponseModel createInvoice(String customer,String amount,String curency,String description){
        StripeInvoice strInv=new StripeInvoice(API_KEY);
        return strInv.createInvoice(customer,amount,curency,description);
    }
    
    public StripeResponseModel retreiveInvoice(String invoiceId){
        StripeInvoice strInv=new StripeInvoice(API_KEY);
        return strInv.retreiveInvoice(invoiceId);
    }
    
    public StripeResponseModel createPlan(String planName,String amount,String curency,String interval,String planLabel){
        StripePlan strPlan=new StripePlan(API_KEY);
        return strPlan.createPlan(planName,amount,curency,interval,planLabel);
    }
    
    public StripeResponseModel retrievePlan(String planId){
        StripePlan strPlan=new StripePlan(API_KEY);
        return strPlan.retrievePlan(planId);
    }
    
    public String addCard(String customerId, String cnumber,String exp_month,String exp_year,String cvc,String name,String addressLine1,String addressCity,String addressState, String addressZip){
        StripeCard strCard=new StripeCard(API_KEY);
        return strCard.addCard(customerId,cnumber,exp_month,exp_year,cvc,name,addressLine1,addressCity,addressState,addressZip);
    }
}