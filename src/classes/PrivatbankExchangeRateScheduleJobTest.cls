/**
 * Created by bell on 26.02.2023.
 */
@IsTest
public with sharing class PrivatbankExchangeRateScheduleJobTest {
    @TestSetup
    static void setup(){
        ExchangeRate__c exchangeRateCustomSettingUsd = new ExchangeRate__c();
        exchangeRateCustomSettingUsd.EurToUah__c = 0;
        exchangeRateCustomSettingUsd.UsdToUah__c = 0;

        insert exchangeRateCustomSettingUsd;
    }

    @IsTest
    static void test_performCalloutToPrivatbankAsync_success(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PrivatbankExchangeRateMock());
        new PrivatbankExchangeRateScheduleJob().execute(null);
        Test.stopTest();

        ExchangeRate__c exchangeRateCustomSetting = ExchangeRate__c.getInstance();

        System.assertEquals(36.56860, exchangeRateCustomSetting.UsdToUah__c);
        System.assertEquals(38.60000, exchangeRateCustomSetting.EurToUah__c);
    }
}
