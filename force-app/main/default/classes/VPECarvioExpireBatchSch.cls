global class VPECarvioExpireBatchSch implements Schedulable {
    global void execute(SchedulableContext sc) {
        VPECarvioExpireBatch b = new VPECarvioExpireBatch();
        database.executeBatch(b);
        
    }

}