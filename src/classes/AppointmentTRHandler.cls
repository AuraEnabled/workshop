/**
 * Created by bell on 24.02.2023.
 */

public with sharing class AppointmentTRHandler {
    public static void handleTrigger(List<Case> newList, Map<Id, Case> oldMap, System.TriggerOperation triggerEvent) {

        switch on triggerEvent {
            when BEFORE_INSERT {
                AppointmentTRDispatcher.checkInsuranceFlagAndRelationMatch(newList);
            }
            when BEFORE_UPDATE {

            }
            when AFTER_INSERT {
                AppointmentTRDispatcher.validateHospitalDepartment(newList);
                AppointmentTRDispatcher.validateInsuranceDepartmentCoverage(newList);
            }
            when AFTER_UPDATE {
                AppointmentTRDispatcher.validateHospitalDepartment(newList);
                AppointmentTRDispatcher.validateInsuranceDepartmentCoverage(newList);
            }
            when else {
            }
        }
    }
}