/**
 * Created by bell on 22.02.2023.
 */

trigger DoctorTR on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DoctorTRHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
}