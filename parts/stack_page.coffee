if Meteor.isClient
    Template.stack_page.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_answers', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_comments', Router.current().params.doc_id
        Session.setDefault('stack_section','main')
    Template.stack_page.onRendered ->
        Meteor.call 'get_question', Router.current().params.site, Router.current().params.doc_id,->
        Meteor.call 'question_answers', Router.current().params.site, Router.current().params.doc_id,->
        # Meteor.call 'get_question_comments', Router.current().params.site, Router.current().params.doc_id,->
    Template.stack_page.helpers
        question_answers: ->
            Docs.find 
                model:'stack_answer'
        question_comments: ->
            question = Docs.findOne Router.current().params.doc_id
            Docs.find 
                model:'stack_comment'
                post_id:question.question_id
        answer_class: -> if @accepted then 'accepted'

    Template.stack_page.events
        'click .call_watson': (e,t)->
            Meteor.call 'call_watson', Router.current().params.doc_id,'link','stack',->
        'click .call_tone': (e,t)->
            Meteor.call 'call_tone', Router.current().params.doc_id,->
        'click .get_question': (e,t)->
            question = Docs.findOne(Router.current().params.doc_id)
            Meteor.call 'get_question', Router.current().params.site, question.question_id,->
                
        'click .get_question_comments': (e,t)->
            # question = Docs.findOne(Router.current().params.doc_id)
            Meteor.call 'get_question_comments', Router.current().params.site, Router.current().params.doc_id,->
                
        'click .get_answers': (e,t)->
            question = Docs.findOne(Router.current().params.doc_id)
            Meteor.call 'question_answers', Router.current().params.site, question.question_id,->
                

if Meteor.isServer
    Meteor.publish 'question_comments', (question_doc_id)->
        question = Docs.findOne question_doc_id
        console.log question.question_id
        Docs.find 
            model:'stack_comment'
            post_id:question.question_id
    
