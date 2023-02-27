/**
 * Created by bell on 21.02.2023.
 */

public with sharing class ReceiptTRDispatcher {

    public static void recalculateNetIncome(List<Receipt__c> newList, Map<Id, Receipt__c> oldMap) {

        Map<Id, Id> receiptIdToCorrespondentAppointmentId = new Map<Id, Id>();
        Map<Id, Double> doctorIdToFacilityBonusTier = new Map<Id, Double>();

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

        if(!doctorIdToFacilityBonusTier.keySet().isEmpty()){
            recalculateIncomePerDoctor(doctorIdToFacilityBonusTier);
        }
    }

    private static void recalculateIncomePerDoctor(Map<Id, Double> doctorIdToFacilityBonusTier) {

        Date startOfMonth = System.today().toStartOfMonth();
        Date endOfMonth = System.today().addMonths(1).toStartOfMonth().addDays(-1);
        Map<Id, Double> doctorIdToOverallMonthlyIncome = new Map<Id, Double>();
        List<Contact> doctorUpdateList = new List<Contact>();

        Map<Id, Case> appointmentsMap = new Map<Id, Case>(
                [SELECT Id, ContactId
                FROM Case WHERE CreatedDate >= :startOfMonth AND CreatedDate <= :endOfMonth
                AND ContactId IN :doctorIdToFacilityBonusTier.keySet()]
        );

        Map<Id, Receipt__c> doctorReceiptsWithinMonth = new Map<Id, Receipt__c>([
                SELECT Id, Amount__c, Appointment__c
                FROM Receipt__c WHERE CreatedDate >= :startOfMonth AND CreatedDate <= :endOfMonth
                AND Appointment__c IN :appointmentsMap.keySet()
        ]);

        for(Receipt__c receipt : doctorReceiptsWithinMonth.values()){
            if(!doctorIdToOverallMonthlyIncome.containsKey(appointmentsMap.get(receipt.Appointment__c).ContactId)){
                doctorIdToOverallMonthlyIncome.put(appointmentsMap.get(receipt.Appointment__c).ContactId, 0);
            }

            doctorIdToOverallMonthlyIncome.put(
                    appointmentsMap.get(receipt.Appointment__c).ContactId,
                    doctorIdToOverallMonthlyIncome.get(appointmentsMap.get(receipt.Appointment__c).ContactId) + receipt.Amount__c
            );
        }

        for (Id doctorId : doctorIdToOverallMonthlyIncome.keySet()){
            if (doctorIdToFacilityBonusTier.get(doctorId) < doctorIdToOverallMonthlyIncome.get(doctorId)){
                Contact doctor = new Contact(
                        Id = doctorId,
                        PaymentsAmount__c = doctorIdToOverallMonthlyIncome.get(doctorId)
                );
                doctorUpdateList.add(doctor);
            }
        }

        update doctorUpdateList;
    }

    public static void checkInsuranceCoverage(List<Receipt__c> newList) {

        List<Insurance__c> insuranceListForUpdate = new List<Insurance__c>();
        Map<Id, Receipt__c> receiptMap = new Map<Id, Receipt__c>(newList);
        Map<Id, Receipt__c> receiptsWithAdditionalObjectFields = new Map<Id, Receipt__c>(
                [SELECT Id, Amount__c, Insurance__c, Insurance__r.Amount__c, Insurance__r.CoveredAmount__c
                FROM Receipt__c
                WHERE Id IN :receiptMap.keySet() AND Appointment__r.ByInsurance__c = TRUE
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
