if Meteor.isClient
    Template.stack_page.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_answers', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_comments', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'related_questions', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'linked_questions', Router.current().params.doc_id
        Session.setDefault('stack_section','main')
  
    Template.stack_page.onRendered ->
        Meteor.call 'get_question', Router.current().params.site, Router.current().params.doc_id,->
        Meteor.call 'get_question_answers', Router.current().params.site, Router.current().params.doc_id,->
        Meteor.call 'call_watson', Router.current().params.doc_id,'link','stack',->
        # Meteor.call 'get_question_comments', Router.current().params.site, Router.current().params.doc_id,->
    Template.stack_page.helpers
        linked_questions: ->
            question = Docs.findOne Router.current().params.doc_id
            Docs.find 
                model:'stack_question'
                _id:question.linked_question_ids
        related_questions: ->
            question = Docs.findOne Router.current().params.doc_id
            Docs.find 
                model:'stack_question'
                _id:question.related_question_ids
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
        'click .goto_q': -> Router.go "/site/#{Router.current().params.site}/doc/#{@_id}"

        'click .speak_this': ->
            # console.log @
            if Session.get('speaking')
                window.speechSynthesis.cancel()
                Session.set('speaking',false)
            else
                window.speechSynthesis.speak new SpeechSynthesisUtterance @analyzed_text
                Session.set('speaking',true)
    
        'click .speak_body': ->
            # console.log @
            if Session.get('speaking')
                window.speechSynthesis.cancel()
                Session.set('speaking',false)
            else
                window.speechSynthesis.speak new SpeechSynthesisUtterance @body
                Session.set('speaking',true)
    
        'click .say_title': (e,t)->
            # console.log 'title', @
            window.speechSynthesis.speak new SpeechSynthesisUtterance @title
        'click .say_name': (e,t)->
            # console.log 'title', @
            Meteor.call 'search_stackuser', Router.current().params.site, @user_id, ->

            window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name
        'click .say_site': (e,t)->
            # console.log 'title', @
            window.speechSynthesis.speak new SpeechSynthesisUtterance Router.current().params.site

        'click .get_linked': (e,t)->
            Meteor.call 'get_linked_questions', Router.current().params.site, Router.current().params.doc_id,->
        'click .get_related': (e,t)->
            Meteor.call 'get_related_questions', Router.current().params.site, Router.current().params.doc_id,->
        'click .call_watson': (e,t)->
            Meteor.call 'call_watson', Router.current().params.doc_id,'link','stack',->
        'click .call_tone': (e,t)->
            Meteor.call 'call_tone', Router.current().params.doc_id,->
        'click .get_question': (e,t)->
            question = Docs.findOne(Router.current().params.doc_id)
            Meteor.call 'get_question', Router.current().params.site, Router.current().params.doc_id,->
                
        'click .get_question_comments': (e,t)->
            # question = Docs.findOne(Router.current().params.doc_id)
            Meteor.call 'get_question_comments', Router.current().params.site, Router.current().params.doc_id,->
                
        'click .get_answers': (e,t)->
            question = Docs.findOne(Router.current().params.doc_id)
            Meteor.call 'question_answers', Router.current().params.site, question.question_id,->
                

if Meteor.isServer
    Meteor.publish 'question_comments', (question_doc_id)->
        # console.log question_doc_id
        Docs.find 
            model:'stack_comment'
            post_id:question_doc_id
    Meteor.publish 'question_linked_to', (question_doc_id)->
        # console.log question.question_id
        Docs.find 
            model:'stack_question'
            linked_to_ids:$in:[question_doc_id]
    
    Meteor.publish 'related_questions', (question_doc_id)->
        # console.log question.question_id
        question = Docs.findOne question_doc_id
        Docs.find 
            model:'stack_question'
            _id:$in:question.related_question_ids
    
    Meteor.publish 'linked_questions', (question_doc_id)->
        # console.log question.question_id
        question = Docs.findOne question_doc_id
        Docs.find 
            model:'stack_question'
            _id:$in:question.linked_question_ids
    
