global class DuplicateContactSchdule implements Schedulable{
	global void execute(SchedulableContext ctx) {
      DuplicateContact objDupCon = new DuplicateContact();
        database.executeBatch(objDupCon,1);
   }   
}