global class scheduledUpdateParentAccount implements Schedulable{
     global void execute(SchedulableContext sc) {
          // We now call the batch class to be scheduled
        UpdateParentAccount batchUpPaAC = new UpdateParentAccount(); 
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(batchUpPaAC,1500);
     }
  }