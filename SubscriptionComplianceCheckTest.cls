@isTest
private class SubscriptionComplianceCheckTest {

    private static final String BOUTIQUE = 'Conformité Boutique';
    private static final String CREDIT = 'Conformité Crédits';
    private static final String PARENT_BUNDLE = 'Conformité Parent Bundle';
    private static final String DIFFUSION_LBC = 'Conformité Diffusion LBC';
    private static final String DIFFUSION_AVAL = 'Conformité Diffusion AVAL';
    private static final String VISIBILITE_AVAL = 'Conformité Visibilité AVAL';
    private static final String PUB_LOCAL = 'Conformité Pub Local';
    private static final String IMMO_NEUF = 'Conformité Immo neuf';
    private static final String CONF_PUB = 'Conformité Pub';
    private static final String CONFORME = 'Conforme';
    private static final String CREATED = 'Created';
    private static final String MODE = 'Fashion';
    private static final String SSII = 'JobServiceCompany';
    private static final String MME = 'Ms';
    private static final String CLOVER = 'CLOVER';
    private static final String MANUEL = 'Manuel';
    private static final String UBIFLOW = 'Ubiflow';
    private static final String ELEMENTS_MANQUANTS = 'Éléments manquants';
    
    @isTest
    private static void testConformite() {
        List<SBQQ__Subscription__c> listSubscriptionToInsert = new List<SBQQ__Subscription__c>();

        Account compte = Account_DataFactory.createAccount('compte_1', '+33 6 00 00 00 00', '37915832200097');
        compte.Segmentation__c = SSII;
        compte.CompanyIndustry__c = 'Beauty';
        compte.BillingCountry = 'France';
        compte.BillingCity = 'city';
        compte.BillingState = 'Île-de-France';
        compte.BillingPostalCode = '93600';
        compte.BillingStreet = 'street';
        update compte;

        Acces_beneficiaire__c benef1 = AccesBeneficiaire_DataFactory.createBeneficiaire('benef_1', compte.Id, 'test1@lbc.fr', CREATED);
        benef1.AccessUserId__c = 'OUAH';
        benef1.AccessStoreId__c = 'OUAH';
        benef1.AccessCategory__c = MODE;
        benef1.Segmentation__c = SSII;
        benef1.AccessSalutation__c = MME;
        benef1.AccessFirstname__c = 'Mimmi';
        benef1.AccessLastname__c = 'Montey';
        benef1.AccessAddressStreet__c = '11 nowhere';
        benef1.AccessCategory__c = 'RealEstate';
        benef1.AccessAddressCountry__c = 'FR';
        benef1.AccessAddressCity__c = 'city';
        benef1.AccessAddressZipcode__c = '22000';
        update benef1;

        SBQQ__Subscription__c parentOK = new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, Souscription_Conforme__c = false,
            ComplianceProcess__c = PARENT_BUNDLE);
        insert parentOK;

        SBQQ__Subscription__c subChildOK = new SBQQ__Subscription__c();
        subChildOK.SBQQ__Quantity__c = 5;
        subChildOK.BeneficiaryAccess__c = benef1.Id;
        subChildOK.Status__c = ELEMENTS_MANQUANTS;
        subChildOK.ComplianceProcess__c = IMMO_NEUF;
        subChildOK.LeadPhone__c = '+33 6 00 00 00 66';
        
        subChildOK.Souscription_Conforme__c = false;
        subChildOK.PromoterDescription__c = 'UBIFLOW4';
        subChildOK.FlowType__c = MANUEL;
        subChildOK.ProductWorkflow__c = 'yeah';
        subChildOK.ContractEmail__c = 'test@test.test';

        subChildOK = parent.Id;
        //si champs formule Acces_beneficiaire__c : CompanySiret__c && CompanyName__c && CompanyAddressStreet__c && CompanyAddressZipcode__c && CompanyAddressCity__c && CompanyPhone__c
        //si champs formule : ContactGender__c && ContactFirstName__c && ContactLastName__c (voir pour insertion lookup sinon remplir champs)
        listSubscriptionToInsert.add(subChildOK);

        BQQ__Subscription__c subImmoOK = new SBQQ__Subscription__c();
        subImmoOK.SBQQ__Quantity__c = 5;
        subImmoOK.BeneficiaryAccess__c = benef1.Id;
        subImmoOK.Status__c = ELEMENTS_MANQUANTS;
        subImmoOK.ComplianceProcess__c = IMMO_NEUF;
        subImmoOK.LeadPhone__c = '+33 6 00 00 00 66';
        
        subImmoOK.Souscription_Conforme__c = false;
        subImmoOK.PromoterDescription__c = 'UBIFLOW4';
        subImmoOK.FlowType__c = MANUEL;
        subImmoOK.ProductWorkflow__c = 'yeah';
        subImmoOK.ContractEmail__c = 'test@test.test';

        listSubscriptionToInsert.add(subImmoOK);

        QQ__Subscription__c subOkPub = new SBQQ__Subscription__c();
        subOkPub.SBQQ__Quantity__c = 5;
        subOkPub.EffectiveEndDate__c = System.now().addDays(1);
        subOkPub.BeneficiaryAccess__c = benef1.Id;
        subOkPub.Status__c = ELEMENTS_MANQUANTS;
        subOkPub.ComplianceProcess__c = CONF_PUB;
        
        listSubscriptionToInsert.add(subOkPub);

        QQ__Subscription__c subNOkPub = new SBQQ__Subscription__c();
        subNOkPub.SBQQ__Quantity__c = 5;
        subNOkPub.EffectiveEndDate__c = System.now().addDays(-1);
        subNOkPub.BeneficiaryAccess__c = benef1.Id;
        subNOkPub.Status__c = ELEMENTS_MANQUANTS;
        subNOkPub.ComplianceProcess__c = CONF_PUB;
        
        listSubscriptionToInsert.add(subNOkPub);
        
        //chields NOK
        listSubscriptionToInsert.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, ComplianceProcess__c = BOUTIQUE, Souscription_Conforme__c = false,
                                           ProductWorkflow__c = 'yeah', BeneficiaryAccess__c = benef1.Id, FlowType__c = 'Manuel', BeneficiaryAccount__c = compte.Id));
        listSubscriptionToInsert.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, ComplianceProcess__c = DIFFUSION_LBC, Souscription_Conforme__c = false,
                                             ProductWorkflow__c = 'yeah', BeneficiaryAccess__c = benef1.Id, BeneficiaryAccount__c = compte.Id,
                                           BroadcastSoftware__c = CLOVER, BroadcastPartner__c = UBIFLOW, FlowType__c = 'Manuel'));
        listSubscriptionToInsert.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, ComplianceProcess__c = DIFFUSION_AVAL, FlowType__c = 'Manuel', Souscription_Conforme__c = false,
                                             ProductWorkflow__c = 'yeah', BeneficiaryAccess__c = benef1.Id, BeneficiaryAccount__c = compte.Id));
        listSubscriptionToInsert.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, ComplianceProcess__c = VISIBILITE_AVAL, FlowType__c = 'Manuel', Souscription_Conforme__c = false,
                                             ProductWorkflow__c = 'yeah', BeneficiaryAccess__c = benef1.Id, SBQQ__RequiredById__c = parent.Id, BeneficiaryAccount__c = compte.Id));
        listSubscriptionToInsert.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, ComplianceProcess__c = CREDIT, FlowType__c = 'Manuel', Souscription_Conforme__c = false,
                                             ProductWorkflow__c = 'yeah',BeneficiaryAccess__c = benef1.Id, BeneficiaryAccount__c = compte.Id));
        listSubscriptionToInsert.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 5, Status__c = ELEMENTS_MANQUANTS, ComplianceProcess__c = PUB_LOCAL, OrderNumber__c = '00215', Souscription_Conforme__c = false,
                                             PostalCode__c = 7500, KilometerRadius__c = '50', PrintVolume__c = 25));

        insert listSubscriptionToInsert;
        
        SubscriptionComplianceCheck batch = new SubscriptionComplianceCheck();
        
		Test.startTest();
		Database.executeBatch(batch);
		Test.stopTest();
        
        System.assertNotEquals(2, [SELECT Id FROM SBQQ__Subscription__c WHERE Souscription_Conforme__c = true AND ComplianceProcess__c =: IMMO_NEUF].size());
        System.assertNotEquals(1, [SELECT Id FROM SBQQ__Subscription__c WHERE Souscription_Conforme__c = true AND ComplianceProcess__c =: CONF_PUB].size());
        System.assertNotEquals(4, [SELECT Id FROM SBQQ__Subscription__c WHERE Souscription_Conforme__c = true].size());
    }
}