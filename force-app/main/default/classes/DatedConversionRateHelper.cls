/**
 * @File Name          : DatedConversionRateHelper.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 3:51:50 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/8/2020   jagrawal@addonblue.com     Added where condition in SOQL for DatedConversionRate
**/
public class DatedConversionRateHelper {
 
    Map<Id, DatedConversionRate> DatedConversionRateById = null;
    Map<String,Decimal> conversionRateByIsoCode = new Map<String,Decimal>();
Map<Date, Map<String,Decimal>> conversionRateByDate = new Map<Date, Map<String,Decimal>>();
    // Constructor
    public DatedConversionRateHelper() {
        // Query all active currency types
        DatedConversionRateById = new Map<Id, DatedConversionRate>([
            Select Id, IsoCode, ConversionRate, StartDate, NextStartDate
            From DatedConversionRate where CreatedDate = LAST_N_DAYS:5 Order By StartDate DESC
        ]);
        // Create map of conversation rate by currency iso code
        if(!Test.isrunningTest())
        {
            for(DatedConversionRate dcr : DatedConversionRateById.values()) {
                if(conversionRateByIsoCode.get(dcr.IsoCode) == null){
                    conversionRateByIsoCode.put(dcr.IsoCode, dcr.ConversionRate);
                }
            }
        }else{
            conversionRateByIsoCode.put('USD',1);
            conversionRateByIsoCode.put('EUR',1);
        }
        
    }
    
    // Convert
    public Decimal convert(Decimal amount, String toIsoCode) {
        System.debug('conversionRateByIsoCode:'+conversionRateByIsoCode);
        // Get conversion rate
        Decimal toRate = conversionRateByIsoCode.get(toIsoCode.toUpperCase());
        // Calculate
        Decimal convertedAmount = amount * toRate;
        // Return
        return convertedAmount;
    }
    // Convert
    public Decimal convertforQuote(Decimal amount, String toIsoCode,Date exchangerateDate) {
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
    /**************************************************************************
       Purpose: Convert the Currency
       Parameters: Decimal amount, String fromIsoCode, String toIsoCode
       Returns: Decimal 
       Throws [Exceptions]: 
    ****************************************************************************/
    public Decimal convertCurrencyToUSD(Decimal amount, String fromIsoCode, Decimal toRate){
        
        if (String.isEmpty(fromIsoCode)) {
            return amount;
        }
        
        // get values and then rate
        Decimal fromRate = conversionRateByIsoCode.get(fromIsoCode.toUpperCase());        
        Decimal currencyRate = toRate/fromRate;
        
        // calculating the currency
        Decimal convertedRate = amount * currencyRate;
        Decimal convertedRateRounded = convertedRate.setScale(1, System.RoundingMode.HALF_UP);
        
        return convertedRateRounded;
    }
}