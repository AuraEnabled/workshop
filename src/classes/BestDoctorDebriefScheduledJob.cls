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
                [SELECT Id, Name,
                    (SELECT Id, PaymentsAmount__c, BestDoctorOfMonth__c FROM Contacts
                    WHERE BestDoctorOfMonth__c = TRUE)
                FROM Account
                WHERE RecordTypeId = :hospitalDepartmentRecordTypeId]
        );

        insertTasksForBestDoctors(facilitiesWithBestDoctorsMap);
    }

    private void insertTasksForBestDoctors(Map<Id, Account> facilitiesWithBestDoctorsMap) {

        List<Task> bestDoctorTasks = new List<Task>();

        for(Id facilityId : facilitiesWithBestDoctorsMap.keySet()){
            if(!facilitiesWithBestDoctorsMap.get(facilityId).Contacts.isEmpty()){
                Task task = new Task(
                        Subject = 'Other',
                        Status = 'Completed',
                        WhoId = facilitiesWithBestDoctorsMap.get(facilityId).Contacts[0].Id,
                        Priority = 'Normal',
                        Description = System.Label.BestDoctorTaskEntitlement
                );

                bestDoctorTasks.add(task);
            }

            insert bestDoctorTasks;
        }
    }
}

