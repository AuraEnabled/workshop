/**
 * Created by bell on 24.02.2023.
 */

trigger AppointmentTR on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    AppointmentTRHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
}