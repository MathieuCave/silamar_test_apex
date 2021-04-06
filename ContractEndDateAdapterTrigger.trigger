trigger ContractEndDateAdapterTrigger on SBQQ__Subscription__c (after insert, after update) {
   
    Set<Id> cons = new Set<Id>();
    for (SBQQ__Subscription__c sub : Trigger.new) {
       cons.add(sub.SBQQ__Contract__c);
    }
    try {
        Contract contractToUpdate = new Contract();

        //pour les contrats des subscriptions du trigger
        for(AggregateResult aggResultContract : [SELECT SBQQ__Contract__c, 
        MAX(SBQQ__EndDate__c) maxEndDate, MAX(SBQQ__TerminatedDate__c) maxTerminateDate
        FROM SBQQ__Subscriptions__c where SBQQ__Contract__c IN :cons GROUP BY SBQQ__Contract__c]){

            //si le contrat à aucune subscriptions avec une date de fin
            if((date)aggResultContract.get('maxTerminateDate') == null){
                contractToUpdate.isTerminate = false;
                endDate = (date)aggResultContract.get('maxEndDate');
            }
            //sinon au moins une date de fin 
            else {
                contractToUpdate.isTerminate = true;
                endDate = (date)aggResultContract.get('maxTerminateDate');
            }
            
            contractToUpdate.add(new SBQQ__Subscription__c(Id = (String)aggResultContract.get('SBQQ__Contract__c'), endDate = endDate));
        }

        update contractToUpdate;
        
    } catch(Exception e) {
            Logs.error('ContractEndDateAdapterTrigger','SBQQ__Subscription__c Trigger insert & update', e);
    }
}