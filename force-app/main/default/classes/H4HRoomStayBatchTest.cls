/**
 * @File Name          : H4HRoomStayBatchTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 3:54:58 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/8/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest public class H4HRoomStayBatchTest {
	@TestSetup static void makeData(){
        TestDataFactory.createTriggerSettingsEntry();
    }
    @isTest static void testRun1(){
        Product2 objProduct = TestDataFactory.createProduct();
        Map<Id,Product2> mapofProduct = new Map<Id,Product2>();
        mapofProduct.put(objProduct.Id,objProduct);
        H4HRoomStayBatch roomStayBatch = new H4HRoomStayBatch(2,2,mapofProduct.keySet());
        roomStayBatch.testClassResponseString = '{"ArnResponse": {"Info": {"@SiteID": "{SITEID}","@Username": "{API-USERNAME}","@IpAddress": "127.0.0.1","@TimeReceived": "2018-04-13T16:01:13.510","@TimeCompleted": "2018-04-13T16:01:13.651","@Version": "1.0.0.0","@ServiceUrl": "https://api.travsrv.com/hotel.aspx?inDate=2018-10-20&latitude=30.099016&longitude=-81.601370&maxResults=1&outDate=2018-10-22&radius=10&siteid={SITEID}","@RequestID": "436E177E-558F-4287-B55A-5DBD9F4C7579"},"Availability": {"@DisplayCurrency": "USD","HotelAvailability": {"@InDate": "2018-10-20","@OutDate": "2018-10-22","@Rooms": "1","@Adults": "2","@Children": "0","Hotel": {"@HotelID": "272393","@IsEphemeral": "true",'+
            +'"RatePlan": [{"@Code": "F89648494F22FFE25A254AD1CE7D18FD27B862F1A609BD28872D9CD6DDA2E956B160BE3DB7EB0191B160BE3DB7EB01917EA3048807BEE935","@Description": "Best Available","@BuyerOnly": "false","@Gateway": "41","@CommissionStatus": "Commissionable","@BalanceDueAtHotel": "false","Room": {"@Code": "HRLM--_eJwFwcuaczAAANAHmgVRCRaziPRvxkyJadx3biWUfkFH9On_fc5BTlaYBzSSx4m6Iwz3cS_pRnKxCtkQzjqPQZm8Lh771NInUK3ri_pDYTzZL6lQtgl0H0_fOj_f5dRd1kT_pX8dtg_pq0LMTJYHFXNuPqi0PxdLuTjEAeTtKNfYZ3Gd3suIjMbm3_prdXk03gvS_pfpUJnL_poCL9kNoyIlpA2DURM1_fqAtELSKYuKh6e248vaSGk9hE9Dns4MYIncb5jC_fcZG_p_fOeSN3Z0N_fib2UqSpSLCPFgqPX2sQTP9rmXEv_ptXOMVOlVLoC_fujzlUz6tJvvFwUEonyP6njavHdzsVVF2EesNGSmILz3twKMBKm_fp7PK2XCcgV8ghjMc93ZaXrLkm622zmAYaTaPSItlgfYOcO2TSZ6hvwXlxw_fSAVdl9fv4Hwe6AJQ","@Name": "Standard room","@Description": "- 1 King Bed - Nonsmoking Room - Free Breakfast, Free Wifi, Fridge, Microwave","@CurrencyCode": "USD","@DisplayCurrencyMultiplier": "1","@USDMultiplier": "1","@ExchangeGMT": "2018-04-13T11:00:26.790","@MaximumBookable": "99","NightlyRate": [{"@Date": "2018-10-20","@Price": "114.44"},{"@Date": "2018-10-21","@Price": "114.43"}],"Tax": {"@Percent": "11.51","@Amount": "29.77"},"GatewayFee": {"@Amount": "0.00"},"Total": {"@Amount": "258.64","@IncludesBookingFee": "false"},"BookingFee": {"@Amount": "0.00","@CurrencyCode": "USD","@DisplayCurrencyMultiplier": "1","@RoomCurrencyMultiplier": "1","@ExchangeGMT": "2018-04-13T11:00:26.790"}}}]}}}}}';
        Database.executeBatch(roomStayBatch);
    }
    @isTest static void testRun2(){
        Product2 objProduct = TestDataFactory.createProduct();
        Map<Id,Product2> mapofProduct = new Map<Id,Product2>();
        mapofProduct.put(objProduct.Id,objProduct);
        H4HRoomStayBatch roomStayBatch = new H4HRoomStayBatch(2,2,mapofProduct.keySet());
        roomStayBatch.testClassResponseString = '{"ArnResponse": {"Info": {"@SiteID": "{SITEID}","@Username": "{API-USERNAME}","@IpAddress": "127.0.0.1","@TimeReceived": "2018-04-13T16:01:13.510","@TimeCompleted": "2018-04-13T16:01:13.651","@Version": "1.0.0.0","@ServiceUrl": "https://api.travsrv.com/hotel.aspx?inDate=2018-10-20&latitude=30.099016&longitude=-81.601370&maxResults=1&outDate=2018-10-22&radius=10&siteid={SITEID}","@RequestID": "436E177E-558F-4287-B55A-5DBD9F4C7579"},"Availability": {"@DisplayCurrency": "USD","HotelAvailability": {"@InDate": "2018-10-20","@OutDate": "2018-10-22","@Rooms": "1","@Adults": "2","@Children": "0","Hotel": {"@HotelID": "272393","@IsEphemeral": "true",'+
            +'"RatePlan": {"@Code": "F89648494F22FFE25A254AD1CE7D18FD27B862F1A609BD28872D9CD6DDA2E956B160BE3DB7EB0191B160BE3DB7EB01917EA3048807BEE935","@Description": "Best Available","@BuyerOnly": "false","@Gateway": "41","@CommissionStatus": "Commissionable","@BalanceDueAtHotel": "false","Room": {"@Code": "HRLM--_eJwFwcuaczAAANAHmgVRCRaziPRvxkyJadx3biWUfkFH9On_fc5BTlaYBzSSx4m6Iwz3cS_pRnKxCtkQzjqPQZm8Lh771NInUK3ri_pDYTzZL6lQtgl0H0_fOj_f5dRd1kT_pX8dtg_pq0LMTJYHFXNuPqi0PxdLuTjEAeTtKNfYZ3Gd3suIjMbm3_prdXk03gvS_pfpUJnL_poCL9kNoyIlpA2DURM1_fqAtELSKYuKh6e248vaSGk9hE9Dns4MYIncb5jC_fcZG_p_fOeSN3Z0N_fib2UqSpSLCPFgqPX2sQTP9rmXEv_ptXOMVOlVLoC_fujzlUz6tJvvFwUEonyP6njavHdzsVVF2EesNGSmILz3twKMBKm_fp7PK2XCcgV8ghjMc93ZaXrLkm622zmAYaTaPSItlgfYOcO2TSZ6hvwXlxw_fSAVdl9fv4Hwe6AJQ","@Name": "Standard room","@Description": "- 1 King Bed - Nonsmoking Room - Free Breakfast, Free Wifi, Fridge, Microwave","@CurrencyCode": "USD","@DisplayCurrencyMultiplier": "1","@USDMultiplier": "1","@ExchangeGMT": "2018-04-13T11:00:26.790","@MaximumBookable": "99","NightlyRate": [{"@Date": "2018-10-20","@Price": "114.44"},{"@Date": "2018-10-21","@Price": "114.43"}],"Tax": {"@Percent": "11.51","@Amount": "29.77"},"GatewayFee": {"@Amount": "0.00"},"Total": {"@Amount": "258.64","@IncludesBookingFee": "false"},"BookingFee": {"@Amount": "0.00","@CurrencyCode": "USD","@DisplayCurrencyMultiplier": "1","@RoomCurrencyMultiplier": "1","@ExchangeGMT": "2018-04-13T11:00:26.790"}}}}}}}}';
        Database.executeBatch(roomStayBatch);
    }
}