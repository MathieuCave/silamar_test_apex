global class SubscriptionComplianceCheck implements Database.Batchable<sObject> {
    private static final String ELEMENTS_MANQUANTS = 'Éléments manquants';
    private static final String IMMO_NEUF = 'Conformité Immo neuf';
    private static final String CONF_PUB = 'Conformité Pub';
    
    global List<SBQQ__Subscription__c> start(Database.BatchableContext cnx) { 
         return [SELECT Id, CompanyAddressCity__c, OrderNumber__c, CompanyAddressCountry__c, CompanyPhone__c, ContactGender__c, ContactLastName__c, 
                 ContactFirstName__c, Companyindustry__c, CompanyName__c, PrintVolume__c, BroadcastSoftware__c, PromoterDescription__c, SBQQ__RequiredById__c,
                 FlowType__c, BroadcastPartner__c, PostalCode__c, Souscription_Conforme__c, ComplianceProcess__c, Status__c, AccessStoreState__c, 
                 ProductWorkflow__c, AccessUserId__c, KilometerRadius__c, AccessStoreId__c, CompanyAddressStreet__c, CompanyAddressZipcode__c, LeadPhone__c,
                 ContractEmail__c, CompanySegment__c, CompanySiret__c, EffectiveEndDate__c, MissingInformations__c
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
            MissingInformations__c = CONF_PUB;
        }
        return sub;
    } 
    

    private SBQQ__Subscription__c setConformiteImmoNeuf(SBQQ__Subscription__c sub) {
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
            MissingInformations__c = IMMO_NEUF;
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