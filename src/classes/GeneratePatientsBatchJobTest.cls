/**
 * Created by bell on 26.02.2023.
 */
@IsTest
public with sharing class GeneratePatientsBatchJobTest {

    @TestSetup
    static void setup(){
        Account hospital = SObjectCreator.createHospital('Locarno Center Test', '1');

        insert hospital;
    }

    @IsTest
    static void test_patientGeneration_success(){
        List<Account> hospitalList = [SELECT Id FROM Account WHERE Name = 'Locarno Center Test'];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GeneratePatientMock());
        Database.executeBatch(new GeneratePatientsBatchJob(hospitalList), 1);
        Test.stopTest();

        List<Patient__c> patients = [SELECT Id, FirstName__c, LastName__c, Age__c, Hospital__c FROM Patient__c WHERE Hospital__c = :hospitalList[0].Id];

        System.assertEquals(1, patients.size());
        System.assertEquals(hospitalList[0].id, patients[0].Hospital__c);
    }

}