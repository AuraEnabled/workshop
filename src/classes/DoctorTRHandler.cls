/**
 * Created by bell on 22.02.2023.
 */

public with sharing class DoctorTRHandler {
    public static void handleTrigger(List<Contact> newList, Map<Id, Contact> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                DoctorTRDispatcher.abortContactInsertIfFacilityNotDepartment(newList);
                DoctorTRDispatcher.defineNewBestDoctorInFacility(newList, null);
            }
            when BEFORE_UPDATE {
                System.debug('BEFORE_UPDATE');
                DoctorTRDispatcher.defineNewBestDoctorInFacility(newList, oldMap);
            }
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');

            }
            when else {
            }
        }
    }
}