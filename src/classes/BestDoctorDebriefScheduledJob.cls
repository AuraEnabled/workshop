/**
 * Created by bell on 23.02.2023.
 * Runs every last day of the moth at 11 pm:
 * System.schedule('BestDoctorDebriefScheduledJob', '0 0 23 L * ?', new BestDoctorDebriefScheduledJob());
 * '0 0 23 L * ?'
 */

global with sharing class BestDoctorDebriefScheduledJob implements Schedulable {

    private final Id hospitalDepartmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HospitalDepartment').getRecordTypeId();

    global void execute(SchedulableContext schedulableContext){

        Map<Id, Account> facilitiesWithBestDoctorsMap = new Map<Id, Account>(
                [SELECT Id, Name, DepartmentType__c, Department__c,
                    (SELECT Id, PaymentsAmount__c, BestDoctorOfMonth__c FROM Contacts
                    WHERE BestDoctorOfMonth__c = TRUE)
                FROM Account
                WHERE RecordTypeId = :hospitalDepartmentRecordTypeId]
        );

        insertTasksForBestDoctors(facilitiesWithBestDoctorsMap);
        Database.executeBatch(new BestDoctorDebriefBatchJob());
    }

    private void insertTasksForBestDoctors(Map<Id, Account> facilitiesWithBestDoctorsMap) {
        List<Task> bestDoctorTasks = new List<Task>();
        Map<Id, Double> facilityIdToBonusRate = mapFacilityIdToBonusRate(facilitiesWithBestDoctorsMap);

        for(Id facilityId : facilitiesWithBestDoctorsMap.keySet()){
            if(!facilitiesWithBestDoctorsMap.get(facilityId).Contacts.isEmpty()){
                Task task = new Task(
                        Subject = 'Other',
                        Status = 'Completed',
                        WhoId = facilitiesWithBestDoctorsMap.get(facilityId).Contacts[0].Id,
                        Priority = 'Normal',
                        Description = System.Label.BestDoctorTaskEntitlement,
                        Bonus__c = facilitiesWithBestDoctorsMap.get(facilityId).Contacts[0].PaymentsAmount__c * facilityIdToBonusRate.get(facilityId)
                );

                bestDoctorTasks.add(task);
            }
        }

        insert bestDoctorTasks;
    }

    private Map<Id, Double> mapFacilityIdToBonusRate(Map<Id, Account> facilitiesWithBestDoctorsMap){
        Map<Id, Double> facilityIdToBonusRate = new Map<Id, Double>();
        Map<String, DepartmentSalaryBonusRate__mdt> bonusRateMap = DepartmentSalaryBonusRate__mdt.getAll();

        for(Id facilityId : facilitiesWithBestDoctorsMap.keySet()){
            String metadataMapKey = facilitiesWithBestDoctorsMap.get(facilityId).DepartmentType__c + facilitiesWithBestDoctorsMap.get(facilityId).Department__c;
            facilityIdToBonusRate.put(facilityId, bonusRateMap.get(metadataMapKey).BonusRate__c);
        }

        return facilityIdToBonusRate;
    }
}