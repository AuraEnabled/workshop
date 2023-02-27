/**
 * Created by bell on 27.02.2023.
 */

@IsTest
public with sharing class BestDoctorDebriefTest {

    private static final String ADULT = 'Adult';
    private static final String RECEPTION = 'Reception';

    @TestSetup
    static void setup(){

        List<Account> hospitals = new List<Account>();
        List<Contact> doctors = new List<Contact>();
        List<Patient__c> patients = new List<Patient__c>();
        List<Case> appointments = new List<Case>();
        List<Insurance__c> insurances = new List<Insurance__c>();

        Test.startTest();
        Account hospital = SObjectCreator.createHospital('Center 1', '1');
        hospitals.add(hospital);

        Account hospitalDepartment = SObjectCreator.createHospitalDepartment('Division 1 - Adult', RECEPTION, ADULT, hospital.Id, (Decimal)10000);
        hospitals.add(hospitalDepartment);
        insert hospitals;

        Contact doctor = SObjectCreator.createDoctor('Raytheon', 'Technology', hospitalDepartment.Id, 0);
        doctors.add(doctor);

        Contact doctor2 = SObjectCreator.createDoctor('McDonnell', 'Douglas', hospitalDepartment.Id, 0);
        doctors.add(doctor2);
        insert doctors;

        Patient__c patient = SObjectCreator.createPatient('Northrop', 'Grumman', 54, null);
        patients.add(patient);

        Patient__c patient2 = SObjectCreator.createPatient('Lockheed', 'Martin', 54, null);
        patients.add(patient2);
        insert patients;

        InsuranceCompany__c ic = SObjectCreator.createInsuranceCompany('IC 1');
        insert ic;

        Insurance__c insurance = SObjectCreator.createInsurance(50000, RECEPTION, ADULT, patient.Id, ic.Id);
        insurances.add(insurance);

        Insurance__c insurance2 = SObjectCreator.createInsurance(50000, RECEPTION, ADULT, patient.Id, ic.Id);
        insurances.add(insurance2);
        insert insurances;

        Case appointment1_1 = SObjectCreator.createAppointment(insurance.Id, doctor.Id, hospitalDepartment.Id, patient.Id, true);
        appointments.add(appointment1_1);

        Case appointment1_2 = SObjectCreator.createAppointment(insurance.Id, doctor.Id, hospitalDepartment.Id, patient.Id, true);
        appointments.add(appointment1_2);

        Case appointment2_1 = SObjectCreator.createAppointment(insurance2.Id, doctor2.Id, hospitalDepartment.Id, patient2.Id, true);
        appointments.add(appointment2_1);

        Case appointment2_2 = SObjectCreator.createAppointment(insurance2.Id, doctor2.Id, hospitalDepartment.Id, patient2.Id, true);
        appointments.add(appointment2_2);
        insert appointments;

        Receipt__c receipt1_1 = SObjectCreator.createReceipt(1000, insurance.Id, patient.Id, appointment1_1.Id);
        insert receipt1_1;

        Receipt__c receipt1_2 = SObjectCreator.createReceipt(25000, insurance.Id, patient.Id, appointment1_2.Id);
        insert receipt1_2;

        Receipt__c receipt2_1 = SObjectCreator.createReceipt(1000, insurance2.Id, patient2.Id, appointment2_1.Id);
        insert receipt2_1;

        Receipt__c receipt2_2 = SObjectCreator.createReceipt(35000, insurance2.Id, patient2.Id, appointment2_2.Id);
        insert receipt2_2;

        Test.stopTest();
    }

    @IsTest
    static void test_bestDoctorReward(){

        Test.startTest();
        new BestDoctorDebriefScheduledJob().execute(null);
        Test.stopTest();

        Task task = [SELECT TYPEOF Who WHEN Contact THEN FirstName END, Id, Bonus__c, Description FROM Task];

        System.assertEquals('McDonnell', task.Who.FirstName);
        System.assertEquals(81000, task.Bonus__c);

    }
}