public class QE_DatedConversionRateHelper {

    Map<Id, DatedConversionRate> DatedConversionRateById = null;
    Map<String,Decimal> conversionRateByIsoCode = new Map<String,Decimal>();
    Map<Date, Map<String,Decimal>> conversionRateByDate = new Map<Date, Map<String,Decimal>>();

    // Constructor
    public QE_DatedConversionRateHelper() {
        // Query all active currency types
        DatedConversionRateById = new Map<Id, DatedConversionRate>([
            Select Id, IsoCode, ConversionRate, StartDate, NextStartDate
            From DatedConversionRate Order By StartDate DESC
        ]);
        // Create map of conversation rate by currency iso code
        for(DatedConversionRate dcr : DatedConversionRateById.values()) {
            if(!conversionRateByDate.Containskey(dcr.startDate)){
                conversionRateByDate.put(dcr.startDate, new Map<String,Decimal>{dcr.IsoCode => dcr.ConversionRate});                
            }else{
                conversionRateByDate.get(dcr.startDate).put(dcr.IsoCode, dcr.ConversionRate);
            }
            
            if(conversionRateByIsoCode.get(dcr.IsoCode) == null){
                conversionRateByIsoCode.put(dcr.IsoCode, dcr.ConversionRate);
            }
        }
    }
    
    // Convert
    public Decimal convert(Decimal amount, String toIsoCode,Date exchangerateDate) {
        System.debug('conversionRateByIsoCode:'+conversionRateByIsoCode);
        System.debug('conversionRateByDate:'+conversionRateByDate);
        // Get conversion rate        
        Decimal toRate;
        if(exchangerateDate != null && conversionRateByDate.containskey(exchangerateDate) && conversionRateByDate.get(exchangerateDate) != null){
            toRate = conversionRateByDate.get(exchangerateDate).get(toIsoCode.toUpperCase());
        }
        else{
            toRate = conversionRateByIsoCode.get(toIsoCode.toUpperCase());        
        }
        // Calculate
        Decimal convertedAmount = amount * toRate;
        // Return
        return convertedAmount;
    }
    
    /**************************************************************************
       Purpose: Convert the Currency
       Parameters: Decimal amount, String fromIsoCode, String toIsoCode
       Returns: Decimal 
       Throws [Exceptions]: 
    ****************************************************************************/
    public Decimal convertCurrencyFromIsoToIso(Decimal amount, String fromIsoCode, String toIsoCode){
        
        if (String.isEmpty(fromIsoCode) || String.isEmpty(toIsoCode)) {
            return amount;
        }
        
        // get values and then rate
        Decimal fromRate = conversionRateByIsoCode.get(fromIsoCode.toUpperCase());
        Decimal toRate = conversionRateByIsoCode.get(toIsoCode.toUpperCase());
        Decimal currencyRate = toRate/fromRate;
        
        // calculating the currency
        Decimal convertedRate = amount * currencyRate;
        Decimal convertedRateRounded = convertedRate.setScale(1, System.RoundingMode.HALF_UP);
        
        return convertedRateRounded;
    }
}