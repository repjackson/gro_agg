if Meteor.isClient
    Router.route '/site/:site/user/:user_id', (->
        @layout 'layout'
        @render 'stackuser_page'
        ), name:'stackuser_page'

    Template.stackuser_page.onCreated ->
        @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'stackuser_badges', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'stackuser_tags', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'stackuser_comments', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'stackuser_questions', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'stackuser_answers', Router.current().params.site, Router.current().params.user_id
    Template.stackuser_page.onRendered ->
        Meteor.call 'stackuser_answers', Router.current().params.site, Router.current().params.user_id, ->
        Meteor.call 'stackuser_questions', Router.current().params.site, Router.current().params.user_id, ->
        Meteor.call 'stackuser_comments', Router.current().params.site, Router.current().params.user_id, ->
        Meteor.call 'stackuser_badges', Router.current().params.site, Router.current().params.user_id, ->
        Meteor.call 'stackuser_tags', Router.current().params.site, Router.current().params.user_id, ->



        
    Template.stackuser_page.helpers
        stackuser_doc: ->
            Docs.findOne 
                model:'stackuser'
        user_comments: ->
            Docs.find
                model:'stack_comment'
        user_questions: ->
            Docs.find
                model:'stack_question'
        user_answers: ->
            Docs.find
                model:'stack_answer'
        user_badges: ->
            Docs.find
                model:'stack_badge'
        user_tags: ->
            Docs.find
                model:'stack_tag'
        user_comments: ->
            Docs.find
                model:'stack_comment'

    Template.answer_item.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'question_from_id', @data.question_id
        
    Template.answer_item.helpers
        answer_question: ->
            console.log @
            Docs.findOne
                model:'stack_question'
                question_id:@question_id
    
        
    Template.stackuser_page.events
        'click .agg': ->
            Meteor.call 'omega', Router.current().params.site, Router.current().params.user_id, ->
        
        'click .say_title': (e,t)->
            console.log 'title', @
            window.speechSynthesis.speak new SpeechSynthesisUtterance @title

        'click .search': ->
            Meteor.call 'search_stackuser', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_answers': ->
            Meteor.call 'stackuser_answers', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_questions': ->
            Meteor.call 'stackuser_questions', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_comments': ->
            Meteor.call 'stackuser_comments', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_badges': ->
            Meteor.call 'stackuser_badges', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_tags': ->
            Meteor.call 'stackuser_tags', Router.current().params.site, Router.current().params.user_id, ->
                
        


if Meteor.isServer
    Meteor.publish 'question_from_id', (qid)->
        Docs.find 
            # model:'stack_question'
            question_id:qid
    
    Meteor.publish 'stackuser_badges', (site,user_id)->
        Docs.find { 
            model:'stack_badge'
            "user.user_id":parseInt(user_id)
        }, limit:10
    Meteor.publish 'stackuser_comments', (site,user_id)->
        Docs.find { 
            model:'stack_comment'
            "owner.user_id":parseInt(user_id)
        }, limit:10
    Meteor.publish 'stackuser_questions', (site,user_id)->
        Docs.find { 
            model:'stack_question'
            "owner.user_id":parseInt(user_id)
        }, limit:10
    Meteor.publish 'stackuser_answers', (site,user_id)->
        Docs.find { 
            model:'stack_answer'
            "owner.user_id":parseInt(user_id)
        }, limit:10
    Meteor.publish 'stackuser_tags', (site,user_id)->
        Docs.find { 
            model:'stack_tag'
            user_id:parseInt(user_id)
        }, limit:10
            
            
            