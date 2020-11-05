if Meteor.isClient
    Template.stack_page.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_answers', Router.current().params.doc_id
        Session.setDefault('stack_section','main')
    Template.stack_page.onRendered ->
        Meteor.call 'get_question', Router.current().params.site, Router.current().params.doc_id,->
        Meteor.call 'question_answers', Router.current().params.site, Router.current().params.doc_id,->
    Template.stack_page.helpers
        question_answers: ->
            Docs.find 
                model:'stack_answer'
    Template.stack_page.events
        'click .call_watson': (e,t)->
            Meteor.call 'call_watson', Router.current().params.doc_id,'link','stack',->
        'click .call_tone': (e,t)->
            Meteor.call 'call_tone', Router.current().params.doc_id,->
        'click .get_question': (e,t)->
            question = Docs.findOne(Router.current().params.doc_id)
            Meteor.call 'get_question', Router.current().params.site, question.question_id,->
                
        'click .get_answers': (e,t)->
            question = Docs.findOne(Router.current().params.doc_id)
            Meteor.call 'question_answers', Router.current().params.site, question.question_id,->
                
