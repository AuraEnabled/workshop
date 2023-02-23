/**
 * Created by bell on 23.02.2023.
 */

public with sharing class BestDoctorDebriefBatchJob implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, PaymentsAmount__c, BestDoctorOfMonth__c FROM Contact]);
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope){
        for(Contact doctor : scope){
            doctor.PaymentsAmount__c = 0;
            doctor.BestDoctorOfMonth__c = false;
        }

        update scope;
    }

    public void finish(Database.BatchableContext BC) {}
}