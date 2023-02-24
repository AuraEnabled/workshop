/**
 * Created by bell on 21.02.2023.
 */

public with sharing class ReceiptTRDispatcher {

    public static void recalculateNetIncome(List<Receipt__c> newList, Map<Id, Receipt__c> oldMap) {

        Map<Id, Id> receiptIdToCorrespondentAppointmentId = new Map<Id, Id>();
        Map<Id, Double> doctorIdToFacilityBonusTier = new Map<Id, Double>();
        Map<Id, Double> doctorIdToNewAmount = new Map<Id, Double>();

        for(Receipt__c receipt : newList) {
            receiptIdToCorrespondentAppointmentId.put(receipt.Id, receipt.Appointment__c);
        }

        Map<Id, Case> appointmentMap = new Map<Id, Case>(
                [SELECT Id, ContactId, AccountId, Account.DoctorPaymentsToReceiveBonus__c
                FROM Case WHERE Id IN :receiptIdToCorrespondentAppointmentId.values()]
        );

        for(Case appt : appointmentMap.values()) {
            if(!appointmentMap.keySet().contains(appt.ContactId))
                doctorIdToFacilityBonusTier.put(appt.ContactId, appt.Account.DoctorPaymentsToReceiveBonus__c);
        }

        if(!doctorIdToFacilityBonusTier.keySet().isEmpty())
            doctorIdToNewAmount = recalculateIncomePerDoctor(doctorIdToFacilityBonusTier);

        updateDoctors(doctorIdToNewAmount);
    }

    private static Map<Id, Double> recalculateIncomePerDoctor(Map<Id, Double> doctorIdToFacilityBonusTier) {

        Date startOfMonth = System.today().toStartOfMonth();
        Date endOfMonth = System.today().addMonths(1).toStartOfMonth().addDays(-1);
        Map<Id, Double> doctorIdToOverallMonthlyIncome = new Map<Id, Double>();
        Map<Id, Double> doctorIdForUpdateToNewAmount = new Map<Id, Double>();

        List<Case> appointments = new List<Case>(
                [SELECT Id, ContactId,
                    (SELECT Id, Amount__c
                    FROM Receipts__r WHERE CreatedDate >= :startOfMonth AND CreatedDate <= :endOfMonth)
                FROM Case WHERE CreatedDate >= :startOfMonth AND CreatedDate <= :endOfMonth
                AND ContactId IN :doctorIdToFacilityBonusTier.keySet()]
        );

        for(Case appt : appointments){
            if(!doctorIdToOverallMonthlyIncome.containsKey(appt.ContactId)) {
                doctorIdToOverallMonthlyIncome.put(appt.ContactId, 0);
            }

            for(Receipt__c receipt : appt.Receipts__r){
                doctorIdToOverallMonthlyIncome.put(
                        appt.ContactId, doctorIdToOverallMonthlyIncome.get(appt.ContactId) + receipt.Amount__c
                );
            }
        }

        for (Id doctorId : doctorIdToOverallMonthlyIncome.keySet()){
            if (doctorIdToFacilityBonusTier.get(doctorId) < doctorIdToOverallMonthlyIncome.get(doctorId)){
                doctorIdForUpdateToNewAmount.put(doctorId, doctorIdToOverallMonthlyIncome.get(doctorId));
            }
        }

        return doctorIdForUpdateToNewAmount;
    }

    private static void updateDoctors(Map<Id, Double> doctorIdForUpdateToNewAmount){
        List<Contact> doctorListForUpdate = new List<Contact>();

        doctorListForUpdate = [SELECT Id, PaymentsAmount__c FROM Contact WHERE Id IN :doctorIdForUpdateToNewAmount.keySet()];

        for(Contact doctor : doctorListForUpdate) {
            doctor.PaymentsAmount__c =
                    doctor.PaymentsAmount__c < doctorIdForUpdateToNewAmount.get(doctor.Id) ?
                    doctorIdForUpdateToNewAmount.get(doctor.Id) : doctor.PaymentsAmount__c;
        }

        if(!doctorListForUpdate.isEmpty()){
            update doctorListForUpdate;
        }
    }

    public static void checkInsuranceCoverage(List<Receipt__c> newList) {

        List<Insurance__c> insuranceListForUpdate = new List<Insurance__c>();
        Map<Id, Receipt__c> receiptMap = new Map<Id, Receipt__c>(newList);
        Map<Id, Receipt__c> receiptsWithAdditionalObjectFields = new Map<Id, Receipt__c>(
                [SELECT Id, Amount__c, Insurance__c, Insurance__r.Amount__c, Insurance__r.CoveredAmount__c
                FROM Receipt__c
                WHERE Id IN :receiptMap.keySet()
                ]
        );

        for (Id receiptId : receiptsWithAdditionalObjectFields.keySet()){
            Insurance__c insurance = new Insurance__c();
            insurance.Id = receiptsWithAdditionalObjectFields.get(receiptId).Insurance__c;
            insurance.Amount__c = receiptsWithAdditionalObjectFields.get(receiptId).Insurance__r.Amount__c;
            insurance.CoveredAmount__c =
                    receiptsWithAdditionalObjectFields.get(receiptId).Insurance__r.CoveredAmount__c + receiptsWithAdditionalObjectFields.get(receiptId).Amount__c;


            if(insurance.Amount__c - insurance.CoveredAmount__c < 0){

                receiptMap.get(receiptId).addError(System.Label.InsuranceCoverageLimitReached);
            }
            else{
                insuranceListForUpdate.add(insurance);
            }
        }

        update insuranceListForUpdate;
    }
}

