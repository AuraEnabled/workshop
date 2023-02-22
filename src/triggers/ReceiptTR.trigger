/**
 * Created by bell on 21.02.2023.
 */

trigger ReceiptTR on Receipt__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    ReceiptTRHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
}