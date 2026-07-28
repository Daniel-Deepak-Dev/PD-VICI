trigger statusCaseUpdatedByMail on EmailMessage (before insert) 
{
    map<Id, EmailMessage> mapCasoMail = new map<Id, EmailMessage>();
    
    for(EmailMessage em : Trigger.new) 
        mapCasoMail.put(em.ParentId, em);
    
    List<Case> lc = [select id, status, Data_Ora_Ultima_Mail__c  from Case where id=:mapCasoMail.keySet()];
    
    for(Case c : lc)  
    {
        if(mapCasoMail.containsKey(c.Id))
        {
            EmailMessage em = mapCasoMail.get(c.Id);
            if(em.Incoming) 
            {
                c.Data_Ora_Ultima_Mail__c  = em.MessageDate;
                c.Nuova_email__c  = true;
            }
        }
    }
    
    update lc;
}