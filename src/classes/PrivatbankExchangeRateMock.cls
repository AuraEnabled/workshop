/**
 * Created by bell on 26.02.2023.
 */
@IsTest
public class PrivatbankExchangeRateMock implements HttpCalloutMock{

    public HttpResponse respond(HttpRequest request){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"ccy":"EUR","base_ccy":"UAH","buy":"38.60000","sale":"40.16064"},{"ccy":"USD","base_ccy":"UAH","buy":"36.56860","sale":"37.45318"}]');
        res.setStatusCode(200);
        return res;
    }
}
