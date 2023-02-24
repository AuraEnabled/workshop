/**
 * Created by bell on 21.02.2023.
 */

public with sharing class ReceiptTRHandler {

    public static void handleTrigger(List<Receipt__c> newList, Map<Id, Receipt__c> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
            }
            when BEFORE_UPDATE {
                System.debug('BEFORE_UPDATE');
            }
            when AFTER_INSERT {
                ReceiptTRDispatcher.checkInsuranceCoverage(newList);
                ReceiptTRDispatcher.recalculateNetIncome(newList, null);
            }
            when AFTER_UPDATE {
                ReceiptTRDispatcher.checkInsuranceCoverage(newList);
                ReceiptTRDispatcher.recalculateNetIncome(newList, oldMap);

            }
            when else {
            }
        }
    }
}