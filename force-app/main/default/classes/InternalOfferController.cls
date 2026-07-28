public class InternalOfferController {
    @TestVisible private static String leftCode = 'QSF';
	public class IntOfferException extends Exception {}
	
    @AuraEnabled
    public static void updateOpportunity(Id opportunityId) {
        Opportunity opp = [SELECT Internal_Vici_offer_nr__c, Validity_internal_offer_if_present__c
                           FROM Opportunity
                   		   WHERE Id = :String.escapeSingleQuotes(opportunityId)
                           LIMIT 1];
        
        if (opp.Internal_Vici_offer_nr__c == NULL && opp.Validity_internal_offer_if_present__c == NULL) {
            ProgressivoOffertaInterna__c cs = [SELECT Last__c FROM ProgressivoOffertaInterna__c];
            String yearCode = String.valueOf(Date.today().year()).mid(2, 3);
            
            System.debug('Prog. code: ' + String.valueOf(cs.Last__c+1).leftPad(4, '0'));
            
            opp.Internal_Vici_offer_nr__c = leftCode + yearCode + (String.valueOf(++cs.Last__c).leftPad(4, '0'));
            opp.Validity_internal_offer_if_present__c = Date.today().addDays(60);
            
            update cs;
            update opp;
        } else {
            throw new IntOfferException('The fields are already enhanced');
        }
    }
}