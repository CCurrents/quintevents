@isTest(seeAllData=false)
public class QE_DatedConversionRateHelper_Test {
    
    @isTest static void test_method_one() {
        Test.startTest();
        QE_DatedConversionRateHelper datedConversionRateHelper = new QE_DatedConversionRateHelper(); 
        datedConversionRateHelper.convert(1,'EUR',null);
        datedConversionRateHelper.convertCurrencyFromIsoToIso(500, 'EUR', 'USD');
        Decimal convertedCurrency = 500.00;
        system.assertEquals(convertedCurrency, datedConversionRateHelper.convertCurrencyFromIsoToIso(500, '', 'USD'));
        Test.stopTest();
    }
    
}