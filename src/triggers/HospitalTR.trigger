/**
 * Created by bell on 23.02.2023.
 */

trigger HospitalTR on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    HospitalTRHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
}