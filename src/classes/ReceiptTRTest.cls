/**
 * Created by bell on 26.02.2023.
 */

@IsTest
public class ReceiptTRTest {

    private static final String ADULT = 'Adult';
    private static final String CHILDREN = 'Children';
    private static final String RECEPTION = 'Reception';

    @TestSetup
    static void setup(){
        List<Account> hospitals = new List<Account>();
        List<Contact> doctors = new List<Contact>();
        List<Patient__c> patients = new List<Patient__c>();
        List<Case> appointments = new List<Case>();

        Test.startTest();
        Account hospital = SObjectCreator.createHospital('Center 1', '1');
        hospitals.add(hospital);

        Account hospitalDepartment = SObjectCreator.createHospitalDepartment('Division 1 - Adult', RECEPTION, ADULT, hospital.Id, (Decimal)10000);
        hospitals.add(hospitalDepartment);
        insert hospitals;

        Contact doctor = SObjectCreator.createDoctor('Ian', 'McCollum', hospitalDepartment.Id, 0);
        doctors.add(doctor);

        Contact doctor2 = SObjectCreator.createDoctor('McDonnell', 'Douglas', hospitalDepartment.Id, 0);
        doctors.add(doctor2);
        insert doctors;

        Patient__c patient = SObjectCreator.createPatient('Northrop', 'Grumman', 54, null);
        patients.add(patient);

        Patient__c patient2 = SObjectCreator.createPatient('Lockheed', 'Martin', 54, null);
        patients.add(patient2);

        Patient__c patient3 = SObjectCreator.createPatient('General', 'Dynamics', 54, null);
        patients.add(patient3);
        insert patients;

        InsuranceCompany__c ic = SObjectCreator.createInsuranceCompany('IC 1');
        insert ic;

        Insurance__c insurance = SObjectCreator.createInsurance(2000, RECEPTION, ADULT, patient.Id, ic.Id);
        insert insurance;

        Case appointment = SObjectCreator.createAppointment(insurance.Id, doctor.Id, hospitalDepartment.Id, patient.Id, true);
        appointments.add(appointment);

        Case appointment2 = SObjectCreator.createAppointment(null, doctor.Id, hospitalDepartment.Id, patient2.Id, false);
        appointments.add(appointment2);

        Case appointment3 = SObjectCreator.createAppointment(null, doctor2.Id, hospitalDepartment.Id, patient3.Id, false);
        appointments.add(appointment3);
        insert appointments;

        Test.stopTest();
    }

    @IsTest
    static void test_checkInsuranceCoverage_fail(){
        Patient__c patient = [SELECT Id FROM Patient__c WHERE FirstName__c = 'Northrop'];
        Insurance__c insurance = [SELECT Id FROM Insurance__c WHERE Patient__c = :patient.Id LIMIT 1];
        Case appointment = [SELECT Id, ContactId FROM Case WHERE Patient__c = :patient.Id LIMIT 1];

        Receipt__c receipt = SObjectCreator.createReceipt(2500, insurance.Id, patient.Id, appointment.Id);

        Test.startTest();
        Database.SaveResult result = Database.insert(receipt, false);
        Test.stopTest();

        System.assert(!result.getErrors().isEmpty());
        System.assertEquals(System.Label.InsuranceCoverageLimitReached, result.getErrors()[0].getMessage());
    }

    @IsTest
    static void test_appointmentWithoutInsurance_success(){
        Patient__c patient = [SELECT Id FROM Patient__c WHERE FirstName__c = 'Lockheed'];
        Case appointment = [SELECT Id,ContactId FROM Case WHERE Patient__c = :patient.Id LIMIT 1];

        Receipt__c receipt = SObjectCreator.createReceipt(2500, null, patient.Id, appointment.Id);

        Test.startTest();
        Database.SaveResult result = Database.insert(receipt, true);
        Test.stopTest();

        Contact doctor = [SELECT Id, FirstName, PaymentsAmount__c FROM Contact WHERE Id = :appointment.ContactId];

        System.assert(result.isSuccess());
        System.assertEquals(0, doctor.PaymentsAmount__c);
    }

    @IsTest
    static void test_receiptUpdateDoctorAmountStatistics(){
        Patient__c patient = [SELECT Id FROM Patient__c WHERE FirstName__c = 'General'];
        Case appointment = [SELECT Id, ContactId FROM Case WHERE Patient__c = :patient.Id LIMIT 1];

        Receipt__c receipt = SObjectCreator.createReceipt(12000, null, patient.Id, appointment.Id);
        Test.startTest();
        Database.SaveResult result = Database.insert(receipt, true);
        Test.stopTest();

        Contact doctor = [SELECT Id, FirstName, PaymentsAmount__c FROM Contact WHERE Id = :appointment.ContactId];

        System.assertEquals(12000, doctor.PaymentsAmount__c);
    }
}