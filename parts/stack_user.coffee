if Meteor.isClient
    Router.route '/site/:site/user/:user_id', (->
        @layout 'layout'
        @render 'stackuser_page'
        ), name:'stackuser_page'

    Template.stackuser_page.onCreated ->
        @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'stackuser_badges', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'stackuser_comments', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'stackuser_questions', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'stackuser_answers', Router.current().params.site, Router.current().params.user_id
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


    Template.stackuser_page.events
        'click .search': ->
            Meteor.call 'search_stack_user', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_answers': ->
            Meteor.call 'stack_user_answers', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_questions': ->
            Meteor.call 'stack_user_questions', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_comments': ->
            Meteor.call 'stack_user_comments', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_badges': ->
            Meteor.call 'stack_user_badges', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_tags': ->
            Meteor.call 'stack_user_tags', Router.current().params.site, Router.current().params.user_id, ->
                
        


if Meteor.isServer
    Meteor.publish 'stackuser_badges', (site,user_id)->
        Docs.find { 
            model:'stack_badge'
            user:
                user_id:user_id
        }, limit:10
    Meteor.publish 'stackuser_comments', (site,user_id)->
        Docs.find { 
            model:'stack_comment'
            owner:
                user_id:user_id
        }, limit:10
    Meteor.publish 'stackuser_questions', (site,user_id)->
        Docs.find { 
            model:'stack_question'
            owner:
                user_id:user_id
        }, limit:10
    Meteor.publish 'stackuser_answers', (site,user_id)->
        Docs.find { 
            model:'stack_answer'
            owner:
                user_id:user_id
        }, limit:10
    Meteor.publish 'stackuser_tags', (site,user_id)->
        Docs.find { 
            model:'stack_tag'
            # owner:
            #     user_id:user_id
        }, limit:10
            
            
            