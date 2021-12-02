/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SPOSnapshotBatch implements Database.Batchable<SObject>, Database.Stateful, System.Schedulable {
    global List<spo4__SalesProcess__c> allActiveSalesProcesses;
    global Map<Id,List<spo4.PBStItem>> pbstItemsBySPId;
    global List<String> stages;
    global String whereClause;
    global SPOSnapshotBatch() {

    }
    global SPOSnapshotBatch(String whereClause) {

    }
    global void execute(System.SchedulableContext sc) {

    }
    global void execute(Database.BatchableContext bc, List<Opportunity> opps) {

    }
    global void finish(Database.BatchableContext bc) {

    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return null;
    }
}
