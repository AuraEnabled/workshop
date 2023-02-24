/**
 * Created by bell on 23.02.2023.
 */

public with sharing class HospitalTRHandler {
    public static void handleTrigger(List<Account> newList, Map<Id, Account> oldMap, System.TriggerOperation triggerEvent) {

        switch on triggerEvent {
            when BEFORE_INSERT {

            }
            when BEFORE_UPDATE {

            }
            when AFTER_INSERT {
                if (!Test.isRunningTest()){
                    HospitalTRDispatcher.launchBatchJobForPatientGeneration(newList);
                }
            }
            when AFTER_UPDATE {

            }
            when else {
            }
        }
    }
}