/**
 * Created by bell on 23.02.2023.
 *
 */

public with sharing class GeneratePatientsBatchJob implements Database.Batchable<Patient__c>, Database.AllowsCallouts {

    private final String endPoint = 'https://randomuser.me/api/?results=1';
    private List<Account> accounts;
    private Integer numberOfPatientsToCreatePerHospital = 120;

    public GeneratePatientsBatchJob() {}

    public GeneratePatientsBatchJob(List<Account> upcomingHospitals){
        this.accounts = upcomingHospitals;
    }

    public Iterable<Patient__c> start(Database.BatchableContext BC){
        List<Patient__c> patients = new List<Patient__c>();
        numberOfPatientsToCreatePerHospital = Test.isRunningTest() ? 1 : numberOfPatientsToCreatePerHospital;

        for (Account hospital : accounts) {
            for (Integer i = 0; i < numberOfPatientsToCreatePerHospital; i++) {
                Patient__c patient = new Patient__c(
                        Hospital__c = hospital.Id
                );
                patients.add(patient);
            }
        }

        return patients;
    }

    public void execute(Database.BatchableContext BC, List<Patient__c> patients){
        Results wrapper = performCalloutForPatient();

        patients[0].FirstName__c = wrapper.results[0].name.first;
        patients[0].LastName__c = wrapper.results[0].name.last;
        patients[0].Age__c = Integer.valueOf(wrapper.results[0].dob.age);
        patients[0].City__c = wrapper.results[0].location.city;

        insert patients;
    }

    public void finish(Database.BatchableContext BC){}

    public Results performCalloutForPatient(){

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        Results getUser = new Results();
        getUser = (Results)System.JSON.deserialize(response.getBody(), Results.class);
        return getUser;
    }


    public class Results{
        public List<RandomUserWrapper> results;
    }

    public class RandomUserWrapper {
        public Name name;
        public Location location;
        public DOB dob;
    }

    public class Name {
        public String first;
        public String last;
    }

    public class DOB {
        public String age;
    }

    public class Location {
        public String city;
    }
}