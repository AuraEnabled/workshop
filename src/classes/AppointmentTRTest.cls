/**
 * Created by bell on 24.02.2023.
 */

@IsTest
public class AppointmentTRTest {

    private static final String ADULT = 'Adult';
    private static final String CHILDREN = 'Children';
    private static final String PSYCHO = 'Psychiatric';
    private static final String RECEPTION = 'Reception';

    @TestSetup
    static void setup(){
        List<Account> hospitals = new List<Account>();
        List<Contact> doctors = new List<Contact>();
        List<Patient__c> patients = new List<Patient__c>();
        List<Insurance__c> insurances = new List<Insurance__c>();

        Test.startTest();
        Account hospital = SObjectCreator.createHospital('Center 1', '1');
        hospitals.add(hospital);

        Account hospitalDepartment = SObjectCreator.createHospitalDepartment('Division 1 - Adult', RECEPTION, ADULT, hospital.Id);
        hospitals.add(hospitalDepartment);

        Account hospitalDepartment2 = SObjectCreator.createHospitalDepartment('Division 2 - Adult', PSYCHO, ADULT, hospital.Id);
        hospitals.add(hospitalDepartment2);

        insert hospitals;

        Contact doctor = SObjectCreator.createDoctor('Pharell', 'Williams', hospitalDepartment.Id);
        doctors.add(doctor);

        Contact doctor2 = SObjectCreator.createDoctor('Umberto', 'Eco', hospitalDepartment2.Id);
        doctors.add(doctor2);

        insert doctors;

        Patient__c patient = SObjectCreator.createPatient('Amber', 'Reed', 15, hospital.Id);
        patients.add(patient);

        Patient__c patient2 = SObjectCreator.createPatient('Jose', 'Barros', 54, hospital.Id);
        patients.add(patient2);

        Patient__c patient3 = SObjectCreator.createPatient('Franz', 'Ferdinand', 50, hospital.Id);
        patients.add(patient3);

        insert patients;

        InsuranceCompany__c ic = SObjectCreator.createInsuranceCompany('IC 1');
        insert ic;

        Insurance__c insurance = SObjectCreator.createInsurance(2000, RECEPTION, CHILDREN, patient.Id, ic.Id);
        insurances.add(insurance);

        Insurance__c insurance2 = SObjectCreator.createInsurance(2000, PSYCHO, ADULT, patient2.Id, ic.Id);
        insurances.add(insurance2);

        Insurance__c insurance3 = SObjectCreator.createInsurance(2000, PSYCHO, ADULT, patient3.Id, ic.Id);
        insurances.add(insurance3);

        insert insurances;

        Test.stopTest();
    }

    @IsTest
    static void test_AppointmentInsert_fail(){
        Account dept = [SELECT Id FROM Account WHERE Name = 'Division 1 - Adult' LIMIT 1];
        Contact doctor = [SELECT Id FROM Contact WHERE AccountId = :dept.Id LIMIT 1];
        Patient__c patient = [SELECT Id FROM Patient__c WHERE FirstName__c = 'Amber'];
        Insurance__c insurance = [SELECT Id FROM Insurance__c WHERE DepartmentType__c = :CHILDREN LIMIT 1];

        Case appointment = SObjectCreator.createAppointment(insurance.Id, doctor.Id, dept.Id, patient.Id, true);

        Test.startTest();
        Database.SaveResult result = Database.insert(appointment, false);
        Test.stopTest();

        System.assert(!result.getErrors().isEmpty());
        System.assertEquals(result.getErrors()[0].getMessage(), System.Label.AgeAndDeptNotMatched);
    }

    @IsTest
    static void test_AppointmentInsert_success(){
        Account dept = [SELECT Id FROM Account WHERE Name = 'Division 2 - Adult' LIMIT 1];
        Contact doctor = [SELECT Id FROM Contact WHERE AccountId = :dept.Id LIMIT 1];
        Patient__c patient = [SELECT Id FROM Patient__c WHERE FirstName__c = 'Franz'];
        Insurance__c insurance = [SELECT Id FROM Insurance__c WHERE Patient__c = :patient.Id LIMIT 1];

        Case appointment = SObjectCreator.createAppointment(insurance.Id, doctor.Id, dept.Id, patient.Id, true);

        Test.startTest();
        Database.SaveResult result = Database.insert(appointment, false);
        Test.stopTest();

        System.debug('###'+result);

        System.assert(result.getErrors().isEmpty());

    }

    @IsTest
    static void test_validateInsuranceDepartmentCoverage_fail(){
        Account dept = [SELECT Id FROM Account WHERE Name = 'Division 1 - Adult' LIMIT 1];
        Contact doctor = [SELECT Id FROM Contact WHERE AccountId = :dept.Id LIMIT 1];
        Patient__c patient = [SELECT Id FROM Patient__c WHERE FirstName__c = 'Jose'];
        Insurance__c insurance = [SELECT Id FROM Insurance__c WHERE Patient__c = :patient.Id LIMIT 1];

        Case appointment = SObjectCreator.createAppointment(insurance.Id, doctor.Id, dept.Id, patient.Id, true);

        Test.startTest();
        Database.SaveResult result = Database.insert(appointment, false);
        Test.stopTest();

        System.debug('###'+result);

        System.assert(!result.getErrors().isEmpty());
        System.assertEquals('The insurance doesn\'t cover this type of department', result.getErrors()[0].getMessage());
    }
}