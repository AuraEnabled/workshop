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

        Test.startTest();
        Account hospital = SObjectCreator.createHospital('Center 1', '1');
        insert hospital;

        Account hospitalDepartment = SObjectCreator.createHospitalDepartment('Division 1 - Adult', RECEPTION, ADULT, hospital.Id);
        insert hospitalDepartment;

        Contact doctor = SObjectCreator.createDoctor('Pharell', 'Williams', hospitalDepartment.Id);
        insert doctor;

        Patient__c patient = SObjectCreator.createPatient('Amber', 'Reed', 15, hospital.Id);
        insert patient;

        InsuranceCompany__c ic = SObjectCreator.createInsuranceCompany('IC 1');
        insert ic;

        Insurance__c insurance = SObjectCreator.createInsurance(2000, RECEPTION, CHILDREN, patient.Id, ic.Id);
        insert insurance;

        Test.stopTest();
    }

    @IsTest
    static void test_AppointmentInsert_fail(){
        Account dept = [SELECT Id FROM Account WHERE Name = 'Division 1 - Adult' LIMIT 1];
        Contact doctor = [SELECT Id FROM Contact WHERE AccountId = :dept.Id LIMIT 1];
        Patient__c patient = [SELECT Id FROM Patient__c WHERE FirstName__c = 'Amber'];
        Insurance__c insurance = [SELECT Id FROM Insurance__c WHERE DepartmentType__c = :CHILDREN LIMIT 1];

        Case appointment = SObjectCreator.createAppointment(insurance.Id, doctor.Id, dept.Id, patient.Id);

        Test.startTest();
        Database.SaveResult result = Database.insert(appointment, false);
        Test.stopTest();

        System.assert(!result.getErrors().isEmpty());
        System.assertEquals(result.getErrors()[0].getMessage(), System.Label.AgeAndDeptNotMatched);
    }
}