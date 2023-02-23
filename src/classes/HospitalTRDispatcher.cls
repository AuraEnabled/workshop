/**
 * Created by bell on 23.02.2023.
 */

public with sharing class HospitalTRDispatcher {
    public static void launchBatchJobForPatientGeneration(List<Account> newList){
        Id hospitalRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Hospital').getRecordTypeId();
        Integer batchSize = 1;
        List<Account> hospitalList = new List<Account>();

        for (Account facility : newList){
            if(facility.RecordTypeId.equals(hospitalRecordTypeId)){
                hospitalList.add(facility);
            }
        }

        if(!hospitalList.isEmpty()){
            Database.executeBatch(new GeneratePatientsBatchJob(newList), batchSize);
        }
    }
}