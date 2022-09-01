public class QE_StripeException extends Exception {

    public QE_StripeError error;
	
	public QE_StripeException(QE_StripeError err) {
		this.error = err;
	}
	
	public override String getMessage() {
		return this.error.message;
	}
	
	public QE_StripeError getError() {
		return this.error;
	}
    
}