global class SubscriptionComplianceCheck implements Database.Batchable<sObject> {
    private static final String ELEMENTS_MANQUANTS = 'Éléments manquants';
    private static final String IMMO_NEUF = 'Conformité Immo neuf';
    private static final String CONF_PUB = 'Conformité Pub';
    
    global List<SBQQ__Subscription__c> start(Database.BatchableContext cnx) { 
         return [SELECT Id, CompanyAddressCity__c, CompanyPhone__c, ContactGender__c, ContactLastName__c, 
                 ContactFirstName__c, CompanyName__c, PromoterDescription__c, SBQQ__RequiredById__c,
                 FlowType__c, Souscription_Conforme__c, ComplianceProcess__c,  
                 ProductWorkflow__c, CompanyAddressStreet__c, CompanyAddressZipcode__c, LeadPhone__c,
                 ContractEmail__c, CompanySiret__c, EffectiveEndDate__c
                 FROM SBQQ__Subscription__c WHERE Status__c = :ELEMENTS_MANQUANTS
                 AND Souscription_Conforme__c = false];
    }
    
    global void execute(Database.BatchableContext cnx, List<SBQQ__Subscription__c> scope) {
		Map<Id, SBQQ__Subscription__c> mapIdSubscription_SubscriptionToUpdate = new Map<Id, SBQQ__Subscription__c>();
		Set<Id> setIdParentConforme = new Set<Id>();
        try {
            for(SBQQ__Subscription__c sub : scope) {
                switch on sub.ComplianceProcess__c {
                    when IMMO_NEUF {		//si la subscription est du process Conformité Immo neuf
                        sub = setConformiteImmoNeuf(sub);
                        if(sub.Souscription_Conforme__c == true && sub.SBQQ__RequiredById__c != null && sub.EffectiveEndDate__c > System.now()){
                            setIdParentConforme.add(sub.SBQQ__RequiredById__c);
                        }
                    }
                    when CONF_PUB {		// si la subscription est du process Conformité Pub
                        sub = setConformitePub(sub);
                    } // when   autres processus
                }
            }
            //suppression des doublons (risque 2 fois la même valeur parent dans scope)
            for(SBQQ__Subscription__c sub : scope){
                if(setIdParentConforme.contains(sub.Id)){
                    sub.Souscription_Conforme__c = true;
                    sub.MissingInformations__c = '';
                    setIdParentConforme.remove(sub.Id);
                }
            }
			//update du scope
			update scope;
            //update des subscription parents (hors scope) à mettre à jour
            setParentConforme(setIdParentConforme);
        } catch(Exception e) {
            Logs.error('SubscriptionComplianceCheck','Batch Compliance Check', e);
        }
    }
    
    global void finish(Database.BatchableContext cnx) {
		
    }

    private SBQQ__Subscription__c setConformitePub(SBQQ__Subscription__c sub) {
        if(sub.EffectiveEndDate__c > System.now()){
            sub.Souscription_Conforme__c = true;
            sub.MissingInformations__c = '';
        } else {
            sub.MissingInformations__c = CONF_PUB + ' : date de fin effective est inférieure à la date du jour';
        }
        return sub;
    } 
    

    private SBQQ__Subscription__c setConformiteImmoNeuf(SBQQ__Subscription__c sub) {
		String fieldsError = IMMO_NEUF + ' : ';
        if(sub.PromoterDescription__c != null 
            && sub.FlowType__c != null 
            && sub.ProductWorkflow__c != null
            && sub.ContractEmail__c != null 
            && sub.CompanySiret__c != null 
            && sub.CompanyName__c != null
            && sub.CompanyAddressStreet__c != null 
            && sub.CompanyAddressZipcode__c != null 
            && sub.CompanyAddressCity__c != null
            && sub.CompanyPhone__c != null 
            && sub.ContactGender__c != null 
            && sub.ContactFirstName__c != null 
            && sub.ContactLastName__c != null 
            && sub.LeadPhone__c != null) {
            sub.Souscription_Conforme__c = true;
            sub.MissingInformations__c = '';
        } else {
			fieldsError += PromoterDescription__c != null ? '' : ' PromoterDescription__c';
			fieldsError += FlowType__c != null ? '' : ' FlowType__c';
			fieldsError += ProductWorkflow__c != null ? '' : ' ProductWorkflow__c';
			fieldsError += ContractEmail__c != null ? '' : ' ContractEmail__c';
			fieldsError += CompanySiret__c != null ? '' : ' CompanySiret__c';
			fieldsError += CompanyName__c != null ? '' : ' CompanyName__c';
			fieldsError += CompanyAddressStreet__c != null ? '' : ' CompanyAddressStreet__c';
			fieldsError += CompanyAddressZipcode__c != null ? '' : ' CompanyAddressZipcode__c';
			fieldsError += CompanyAddressCity__c != null ? '' : ' CompanyAddressCity__c';
			fieldsError += CompanyPhone__c != null ? '' : ' CompanyPhone__c';
			fieldsError += ContactGender__c != null ? '' : ' ContactGender__c';
			fieldsError += ContactFirstName__c != null ? '' : ' ContactFirstName__c';
			fieldsError += ContactLastName__c != null ? '' : ' ContactLastName__c';
			fieldsError += LeadPhone__c != null ? '' : ' LeadPhone__c';
            sub.MissingInformations__c = fieldsError;
        }
        return sub;
    }
    
    private void setParentConforme(Set<Id> setParentId) {
		List<SBQQ__Subscription__c> listSubscriptionToUpdate = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c parentSub : [SELECT Id, Souscription_Conforme__c FROM SBQQ__Subscription__c WHERE Status__c = :ELEMENTS_MANQUANTS 
                                           AND Souscription_Conforme__c = false AND Id IN: setParentId]){
											   parentSub.Souscription_Conforme__c = true;
											   listSubscriptionToUpdate.add(parentSub);
										   }
		update parentSub;
    }
}
