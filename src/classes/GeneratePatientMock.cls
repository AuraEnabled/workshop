/**
 * Created by bell on 26.02.2023.
 */
@IsTest
public with sharing class GeneratePatientMock implements HttpCalloutMock {

    static String json2= '{\n' +
            '  "results": [\n' +
            '    {\n' +
            '      "name": {\n' +
            '        "first": "Naja",\n' +
            '        "last": "Christiansen"\n' +
            '      },\n' +
            '      "location": {\n' +
            '        "city": "Silkeboeg"\n' +
            '      },\n' +
            '      "dob": {\n' +
            '        "age": 41\n' +
            '      }\n' +
            '    }\n' +
            '  ]\n' +
            '}';

    public HttpResponse respond(HttpRequest request){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json2);
        res.setStatusCode(200);

        return res;
    }
}