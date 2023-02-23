/**
 * Created by bell on 23.02.2023.
 * System.schedule('PrivatbankExchangeRateScheduleJob', '0 0 12 * * ?', new PrivatbankExchangeRateScheduleJob());
 * '0 0 12 * * ?'
 */

public with sharing class PrivatbankExchangeRateScheduleJob implements Schedulable {

    private static String endPoint = 'https://api.privatbank.ua/p24api/pubinfo?exchange&coursid=11';

    public void execute(SchedulableContext schedulableContext){

        performCalloutToPrivatbankAsync();
    }

    @future(callout = true)
    private static void performCalloutToPrivatbankAsync(){
        ExchangeRate__c exchangeRateCustomSetting = ExchangeRate__c.getInstance();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        List<PBRate> currencyList = new List<PBRate>();
        currencyList = (List<PBRate>)System.JSON.deserialize(response.getBody(), List<PBRate>.class);
        System.debug(currencyList);

        for(PBRate rate : currencyList){
            switch on rate.ccy.toLowerCase(){
                when 'eur' {
                    exchangeRateCustomSetting.EurToUah__c = Double.valueOf(rate.buy);
                }
                when 'usd' {
                    exchangeRateCustomSetting.UsdToUah__c = Double.valueOf(rate.buy);
                }
                when else {

                }
            }
        }

        upsert exchangeRateCustomSetting;
    }

    public class PBRate {
        public String ccy;
        public String buy;
    }
}