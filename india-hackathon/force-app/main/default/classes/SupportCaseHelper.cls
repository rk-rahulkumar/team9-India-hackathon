global with sharing class SupportCaseHelper implements copadoAiHelper.Action.Actionable{
    global String[] appliesTo() {
        // declare for which objects this action is relevant.
        // return an empty array if the action is relevant to any object.
        return new String[]{'Case'};
    }

    global String jsonSchema() {
        // the name will be visible to the user, so be clear and concise
        // the description will be relevant to OpenAI ... be clear and verbose
        return '{'+
        '    "name": "create_case_comment",'+
        '    "description": "Given a details with the support agent on the AI Companion, create a case comment for customer on this case.",'+
        '    "examples": ["Create a case comment"],'+
        '    "parameters": {'+
        '        "type": "object",'+
        '        "properties": {'+
        '            "comment": {'+
        '                "type": "string",'+
        '                "description": "The draft case comment provided by AI Companion, it should not be more than 100 words."'+
        '            }},'+
        '        "required": ["comment"]'+
        '    }'+
        '}';
    }

    global copadoAiHelper.ActionResponse call(Id contextId, Map<String, Object> args) {
        String caseComment = (String) args.get('comment');
        try{
            CaseComment cc = new CaseComment(CommentBody=caseComment,ParentId=contextId,IsPublished=true);
            insert cc;
            // get the case number
			Case c = [SELECT Id, CaseNumber FROM Case WHERE Id = :contextId];
            return new copadoAiHelper.ActionResponse('I have added case comment to the Support Case with the Case Number '+c.CaseNumber);
        }catch(Exception e) {
            return new copadoAiHelper.ActionResponse('I could not created the case comment on this case. The error was: '+e.getMessage());
        }
    }
}