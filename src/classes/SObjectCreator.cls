/**
 * Created by bell on 24.02.2023.
 */

public class SObjectCreator {

    private static final Id HOSPITAL_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Hospital').getRecordTypeId();
    private static final Id HOSPITAL_DEPARTMENT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HospitalDepartment').getRecordTypeId();
    private static final String STATUS_NEW = 'New';



    public static Account createHospital(String name, String SLASerialNumber){
        Account hospital = new Account();
        hospital.Name = name;
        hospital.RecordTypeId = HOSPITAL_RECORD_TYPE_ID;
        hospital.SLA__c = 'Gold';
        hospital.SLASerialNumber__c = SLASerialNumber;
        hospital.SLAExpirationDate__c = Date.today().addYears(1);

        return hospital;
    }

    public static Account createHospitalDepartment(String name, String department, String departmentType, Id parentAccount){
        Account hospital = new Account();
        hospital.Name = name;
        hospital.Department__c = department;
        hospital.DepartmentType__c = departmentType;
        hospital.RecordTypeId = HOSPITAL_DEPARTMENT_RECORD_TYPE_ID;
        hospital.ParentId = parentAccount;

        return hospital;
    }

    public static Account createHospitalDepartment(String name, String department, String departmentType, Id parentAccount, Decimal facilityBonusTier){
        Account hospital = new Account();
        hospital.Name = name;
        hospital.Department__c = department;
        hospital.DepartmentType__c = departmentType;
        hospital.RecordTypeId = HOSPITAL_DEPARTMENT_RECORD_TYPE_ID;
        hospital.ParentId = parentAccount;
        hospital.DoctorPaymentsToReceiveBonus__c = facilityBonusTier;

        return hospital;
    }

    public static Contact createDoctor(String firstName, String lastName, Id hospitalId){
        Contact doctor = new Contact();
        doctor.FirstName = firstName;
        doctor.LastName = lastName;
        doctor.AccountId = hospitalId;

        return doctor;
    }

    public static Contact createDoctor(String firstName, String lastName, Id hospitalId, Decimal paymentsAmount){
        Contact doctor = new Contact();
        doctor.FirstName = firstName;
        doctor.LastName = lastName;
        doctor.AccountId = hospitalId;
        doctor.PaymentsAmount__c = paymentsAmount;

        return doctor;
    }

    public static Patient__c createPatient(String firstName, String lastName, Integer age, Id hospitalId){
        Patient__c patient = new Patient__c();
        patient.FirstName__c = firstName;
        patient.LastName__c = lastName;
        patient.Age__c = age;
        patient.Hospital__c = hospitalId;

        return patient;
    }

    public static InsuranceCompany__c createInsuranceCompany(String name){
        InsuranceCompany__c insuranceCompany = new InsuranceCompany__c();
        insuranceCompany.Name = name;

        return insuranceCompany;
    }

    public static Insurance__c createInsurance(Double amount, String coveredDepartments, String departmentType, Id patientId, Id insuranceCompanyId){
        Insurance__c insurance = new Insurance__c();
        insurance.Amount__c = amount;
        insurance.CoveredDepartments__c = coveredDepartments;
        insurance.DepartmentType__c = departmentType;
        insurance.Patient__c = patientId;
        insurance.InsuranceCompany__c = insuranceCompanyId;

        return insurance;
    }

    public static Case createAppointment(Id insuranceId, Id doctorId, Id departmentId, Id patientId){
        Case appointment = new Case();
        appointment.Status = STATUS_NEW;
        appointment.Insurance__c = insuranceId;
        appointment.ContactId = doctorId;
        appointment.AccountId = departmentId;
        appointment.Patient__c = patientId;

        return appointment;
    }

    public static Case createAppointment(Id insuranceId, Id doctorId, Id departmentId, Id patientId, Boolean byInsurance){
        Case appointment = new Case();
        appointment.Status = STATUS_NEW;
        appointment.Insurance__c = insuranceId;
        appointment.ContactId = doctorId;
        appointment.AccountId = departmentId;
        appointment.Patient__c = patientId;
        appointment.ByInsurance__c = byInsurance;

        return appointment;
    }

    public static Receipt__c createReceipt(Decimal amount, Id insuranceId, Id patientId, Id appointmentId){
        Receipt__c receipt = new Receipt__c();
        receipt.Amount__c = amount;
        receipt.Insurance__c = insuranceId;
        receipt.Patient__c = patientId;
        receipt.Appointment__c = appointmentId;

        return receipt;
    }

}