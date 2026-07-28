trigger leadEmailGDPR on Lead (before insert, before update) 
{    
    for (lead l : Trigger.new)
    {
        if(trigger.isUpdate) {
            Lead oldLead = trigger.oldMap.get(l.Id);
            system.debug(oldLead.email);
            system.debug(l.email);
            if(l.email != oldLead.email && !l.isChangeEmailGDPR__c ) {
                l.isSendEmailGDPR__c = true;
                l.Data_invio_GDPR__c = null;
                l.Data_risposta_GDPR__c = null;
                l.privacy__c = null;
                l.HasOptedOutOfEmail = false;

            } else {
                l.isChangeEmailGDPR__c =false ;
            }
        }
        
        if (trigger.isInsert){
            l.isSendEmailGDPR__c=true;
        }
    }
    
}