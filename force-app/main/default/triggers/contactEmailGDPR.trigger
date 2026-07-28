trigger contactEmailGDPR on Contact (before update) 
{    
    for (Contact c : Trigger.new)
    {
        if(trigger.isUpdate) {
            Contact oldContact = trigger.oldMap.get(c.Id);
            system.debug(oldContact.email);
            system.debug(c.email);
            if(c.email != oldContact.email && !c.isChangeEmailGDPR__c ) {
                c.isSendEmailGDPR__c = true;
                c.Data_invio_GDPR__c = null;
                c.Data_risposta_GDPR__c = null;
                c.privacy__c = null;
                c.HasOptedOutOfEmail = false;
            } else {
                c.isChangeEmailGDPR__c =false ;
            }
        }
        
        if (trigger.isInsert){
            c.isSendEmailGDPR__c=true;
            
        }
    }
    
}