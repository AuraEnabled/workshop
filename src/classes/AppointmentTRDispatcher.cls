/**
 * Created by bell on 24.02.2023.
 */

public with sharing class AppointmentTRDispatcher {

    private static final Integer maturityDelimiter = 16;
    private static final String ADULT = 'Adult';
    private static final String CHILDREN = 'Children';
    private static final String PSYCHO = 'Psychiatric';

    public static void validateHospitalDepartment(List<Case> newList){

        Map<Id, Case> newMap = new Map<Id, Case>(newList);
        Map<Id, Case> caseMapWithRelatedObjects = new Map<Id, Case>([
                SELECT Id,
                        Account.DepartmentType__c, Account.Department__c,
                        Patient__r.Age__c
                FROM Case WHERE Id IN :newMap.keySet()
        ]);

        for(Case appointment : caseMapWithRelatedObjects.values()){
            if (appointment.Patient__r.Age__c < maturityDelimiter){
                if (!appointment.Account.DepartmentType__c.equals(CHILDREN)
                        ||appointment.Account.Department__c.equals(PSYCHO)){

                    newMap.get(appointment.Id).addError(System.Label.AgeAndDeptNotMatched);
                }
            }
            else {
                if (!appointment.Account.DepartmentType__c.equals(ADULT)){

                    newMap.get(appointment.Id).addError(System.Label.AgeAndDeptNotMatched);
                }
            }
        }
    }

    public static void validateInsuranceDepartmentCoverage(List<Case> newList){

        Map<Id, Case> newMap = new Map<Id, Case>(newList);
        Map<Id, Case> caseMapWithRelatedObjects = new Map<Id, Case>([
                SELECT Id,
                        Account.Department__c,
                        Insurance__r.CoveredDepartments__c
                FROM Case WHERE Id IN :newMap.keySet() AND ByInsurance__c = TRUE
        ]);

        for (Case appointment : caseMapWithRelatedObjects.values()) {
            List<String> coveredDepartments = appointment.Insurance__r.CoveredDepartments__c?.split(';');

            if(!coveredDepartments.contains(appointment.Account.Department__c)) {
                newMap.get(appointment.Id).addError(System.Label.InsuranceDeptCoverageMisuse);
            }
        }
    }

    public static void checkInsuranceFlagAndRelationMatch(List<Case> newList){

        for(Case appointment : newList){
            if(appointment.ByInsurance__c && String.isBlank(appointment.Insurance__c)){
                appointment.Insurance__c.addError('Please choose an insurance');
            }
            else if(!appointment.ByInsurance__c && !String.isBlank(appointment.Insurance__c)){
                appointment.ByInsurance__c.addError('Please fill the checkbox');
            }
        }
    }
}