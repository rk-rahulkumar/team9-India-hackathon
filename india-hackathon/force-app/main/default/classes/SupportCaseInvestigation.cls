global with sharing class SupportCaseInvestigation implements copadoAiHelper.Action.Actionable{
    global String[] appliesTo() {
        // declare for which objects this action is relevant.
        // return an empty array if the action is relevant to any object.
        return new String[]{'Case'};
    }

    global String jsonSchema() {
        // the name will be visible to the user, so be clear and concise
        // the description will be relevant to OpenAI ... be clear and verbose
        return '{'+
        '    "name": "create_case_investigation",'+
        '    "description": "Given a details with the support agent on the AI Companion, create a investigation of this case only if requested by user.",'+
        '    "examples": ["Create an investigation"],'+
        '    "parameters": {'+
        '        "type": "object",'+
        '        "properties": {'+
        '            "summary": {'+
        '                "type": "string",'+
        '                "description": "The case summary using the case details and conversation done on AI Companion. It should provide all the useful details related to that case."'+
        '            }},'+
        '        "required": ["description"]'+
        '    }'+
        '}';
    }

    global copadoAiHelper.ActionResponse call(Id contextId, Map<String, Object> args) {
        try{
            String caseSummary = (String) args.get('summary');
            // get the case details
			Case c = [SELECT Id, CaseNumber, Subject, Troubleshooting_Steps__c, description FROM Case WHERE Id = :contextId];

            copado__User_Story__c userStory = new copado__User_Story__c();
            userStory.OwnerId = '00G7Y000009YqUvUAK';
            userStory.RecordTypeId = '0127R000000xn4AQAQ';
            userStory.copado__User_Story_Title__c = c.Subject;
            userStory.copado__Team__c = 'a1t7Y000009jSu0QAE';
            if(String.isNotBlank(c.Troubleshooting_Steps__c)) {
                userStory.copado__Functional_Specifications__c = '<p><b>Case Summary</b></p>' + '<p>' + caseSummary + '</p>'
                    +'<p><b>Case Description</b></p>' + '<p>' + c.description + '</p>'
                    +'<p><b>Troubleshooting Steps</b></p>' + '<p>' + c.Troubleshooting_Steps__c + '</p>';
            }
            else {
                userStory.copado__Functional_Specifications__c =  '<p><b>Case Summary</b></p>' + '<p>' + caseSummary + '</p>'
                            +'<p><b>Case Description</b></p>' + '<p>' + c.description + '</p>';
            }

            insert userStory;
            // get the user story
            copado__User_Story__c createdUserStory = [SELECT Id, Name FROM copado__User_Story__c WHERE Id = :userStory.Id];

            c.Status = 'Escalated';
            c.User_Story__c = createdUserStory.Id;
            update c;

            return new copadoAiHelper.ActionResponse('I have created the investigation for this case with the User Story Number '+createdUserStory.Name + ' https://copado-india-hackathon--hackaton9.sandbox.lightning.force.com/'+createdUserStory.Id);
        }catch(Exception e) {
            return new copadoAiHelper.ActionResponse('I could not created the investigation on this case. The error was: '+e.getMessage());
        }
    }
}