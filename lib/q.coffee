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
        Meteor.setTimeout ->
            $('.top').visibility
                onTopVisible: (calculations) ->
                    console.log 'top vis'
                    # top is on screen
                onTopPassed: (calculations) ->
                    console.log 'top pass'
                    # top of element passed
                onUpdate: (calculations) ->
                    # do something whenever calculations adjust
                    console.log 'update'
                    # updateTable calculations
            , 2000
    Template.stack_page.helpers
        linked_questions: ->
            question = Docs.findOne Router.current().params.doc_id
            Docs.find 
                model:'stack_question'
                _id:question.linked_question_ids
                site:Router.current().params.site
        related_questions: ->
            question = Docs.findOne Router.current().params.doc_id
            Docs.find 
                model:'stack_question'
                _id:question.related_question_ids
                site:Router.current().params.site
        question_answers: ->
            Docs.find({
                model:'stack_answer'
                site:Router.current().params.site
            }, {
                sort:score:-1
            })
        question_comments: ->
            question = Docs.findOne Router.current().params.doc_id
            Docs.find 
                model:'stack_comment'
                post_id:question.question_id
                site:Router.current().params.site
        answer_class: -> if @accepted then 'accepted'


    Template.stack_page.events
        'click .goto_q': -> Router.go "/site/#{Router.current().params.site}/doc/#{@_id}"

        # 'click .speak_this': ->
        #     if Session.get('speaking')
        #         window.speechSynthesis.cancel()
        #         Session.set('speaking',false)
        #     else
        #         window.speechSynthesis.speak new SpeechSynthesisUtterance @analyzed_text
        #         Session.set('speaking',true)
    
        # 'click .speak_body': ->
        #     if Session.get('speaking')
        #         window.speechSynthesis.cancel()
        #         Session.set('speaking',false)
        #     else
        #         window.speechSynthesis.speak new SpeechSynthesisUtterance @body
        #         Session.set('speaking',true)
    
        'click .refresh_user': (e,t)->
            Meteor.call 'search_stackuser', Router.current().params.site, @user_id, ->

            # window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name

        'click .get_linked': (e,t)->
            console.log 'linked'
            Meteor.call 'get_linked_questions', Router.current().params.site, Router.current().params.doc_id,->
        'click .get_related': (e,t)->
            Meteor.call 'get_related_questions', Router.current().params.site, Router.current().params.doc_id,->
            console.log 'getting related'
        'click .call_watson': (e,t)->
            window.speechSynthesis.speak new SpeechSynthesisUtterance 'analyzing'
            Meteor.call 'call_watson', Router.current().params.doc_id,'link','stack',->
                
        'click .call_tone': (e,t)->
            Meteor.call 'call_tone', Router.current().params.doc_id,->
        'click .get_question': (e,t)->
            question = Docs.findOne(Router.current().params.doc_id)
            Meteor.call 'get_question', Router.current().params.site, Router.current().params.doc_id,->
                
        'click .get_question_comments': (e,t)->
            # question = Docs.findOne(Router.current().params.doc_id)
            window.speechSynthesis.speak new SpeechSynthesisUtterance "getting #{Router.current().params.site} comments"
            Meteor.call 'get_question_comments', Router.current().params.site, Router.current().params.doc_id,->
                
        'click .get_answers': (e,t)->
            window.speechSynthesis.speak new SpeechSynthesisUtterance "getting #{Router.current().params.site} answers"
            question = Docs.findOne(Router.current().params.doc_id)
            Meteor.call 'question_answers', Router.current().params.site, question.question_id,->
                

    
