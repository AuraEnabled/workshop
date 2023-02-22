/**
 * Created by bell on 22.02.2023.
 */

public with sharing class DoctorTRDispatcher {

    public static void defineNewBestDoctorInFacility(List<Contact> newList, Map<Id, Contact> oldMap) {

        List<Contact> newDoctors = new List<Contact>();
        Map<Id, Contact> newMap = new Map<Id, Contact>();
        Set<Id> facilityIdsToCheckNewBestDoctor = new Set<Id>();

        for(Contact doctor : newList){
            if(doctor.BestDoctorOfMonth__c && doctor.PaymentsAmount__c >= oldMap?.get(doctor.Id)?.PaymentsAmount__c)
                continue;


            if(oldMap == null || doctor.PaymentsAmount__c != oldMap.get(doctor.Id).PaymentsAmount__c){
                facilityIdsToCheckNewBestDoctor.add(doctor.AccountId);
                newDoctors.add(doctor);
            }
        }

        if(!facilityIdsToCheckNewBestDoctor.isEmpty()){
            checkFacilityBestDoctor(facilityIdsToCheckNewBestDoctor, newDoctors);
        }
    }

    private static void checkFacilityBestDoctor(Set<Id> facilityIds, List<Contact> newDoctors) {

        List<Contact> formerBestDoctorsForUpdate = new List<Contact>();
        Map<Id, Account> facilitiesWithBestDoctorsMap = new Map<Id, Account>(
            [SELECT Id, Name,
                (SELECT Id, PaymentsAmount__c, BestDoctorOfMonth__c FROM Contacts
                ORDER BY PaymentsAmount__c DESC NULLS LAST LIMIT 1)
            FROM Account
            WHERE Id IN :facilityIds]
        );

        for(Contact doctor : newDoctors){
            if(!facilitiesWithBestDoctorsMap?.get(doctor.AccountId)?.Contacts.isEmpty()
                && doctor.PaymentsAmount__c > facilitiesWithBestDoctorsMap?.get(doctor.AccountId)?.Contacts[0]?.PaymentsAmount__c){

                    doctor.BestDoctorOfMonth__c = true;
                    facilitiesWithBestDoctorsMap.get(doctor.AccountId).Contacts[0].BestDoctorOfMonth__c = false;
                    formerBestDoctorsForUpdate.add(facilitiesWithBestDoctorsMap.get(doctor.AccountId).Contacts[0]);

            }
        }

        if(!formerBestDoctorsForUpdate.isEmpty()){
            update formerBestDoctorsForUpdate;
        }
    }

    public static void abortContactInsertIfFacilityNotDepartment(List<Contact> newList){

        Map<Id, List<Contact>> facilityIdToContactList = new Map<Id, List<Contact>>();
        Id hospitalDepartmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HospitalDepartment').getRecordTypeId();

        for (Contact doctor : newList){

            if(!facilityIdToContactList.containsKey(doctor.AccountId)){
                facilityIdToContactList.put(doctor.AccountId, new List<Contact>());
            }

            facilityIdToContactList.get(doctor.AccountId).add(doctor);
        }

        List<Account> facilityList = [SELECT Id, RecordTypeId FROM Account WHERE Id IN :facilityIdToContactList.keySet()];

        for (Account facility : facilityList){
            if(!facility.RecordTypeId.equals(hospitalDepartmentRecordTypeId)) {
                facilityIdToContactList.get(facility.Id)[0].addError('Doctor should be member of Hospital Department');
            }
        }
    }
}