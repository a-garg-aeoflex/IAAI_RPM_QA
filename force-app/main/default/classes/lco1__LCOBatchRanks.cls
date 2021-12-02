/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class LCOBatchRanks implements Database.Batchable<SObject>, Database.Stateful, System.Schedulable, System.WebServiceMock, lco1.LCOBatchable {
    global Date dateFrom {
        get;
        set;
    }
    global Date dateTo {
        get;
        set;
    }
    global Set<Date> processedDates {
        get;
        set;
    }
    global LCOBatchRanks() {

    }
    global void execute(System.SchedulableContext sc) {

    }
    global void execute(Database.BatchableContext info, List<lco1__Performance_Snapshot__c> scope) {

    }
    global void finish(Database.BatchableContext info) {

    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return null;
    }
}