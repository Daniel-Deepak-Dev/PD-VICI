@isTest
private class CloneSurveyControllerTest {

    private static TestMethod void testGSurveysController(){
        SurveyTestingUtil tu = new SurveyTestingUtil();

        Survey__c s = new Survey__c(Name = 'test survey');
        insert s;
        ApexPages.CurrentPage().getparameters().put('id',s.id);
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(s);
        CloneSurveyController sc = new CloneSurveyController(stc);
        String saveUrl = sc.save().getUrl();
        String surveyUrl = '/apex/SurveyManagerPage?id='+sc.survey.Id;
 
        List<Survey__c> listSurveys = [select id from survey__c where name='test survey'];

        System.assertEquals(null, sc.pageMessage.message);
    }

}