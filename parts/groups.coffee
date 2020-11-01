if Meteor.isClient
    Router.route '/groups', (->
        @layout 'layout'
        @render 'groups'
    ), name:'groups'
 
    Router.route '/group/:doc_id', (->
        @layout 'layout'
        @render 'group_view'
    ), name:'group_view'
    Template.group_view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'subreddit_docs', Router.current().params.doc_id
    Template.group_view.events
        'keyup .search_subreddit': (e,t)->
            if e.which is 13
                val = $('.search_subreddit').val()
                sub = Docs.findOne Router.current().params.doc_id
                console.log val, sub.display_name
                Meteor.call 'search_reddit', val, sub.display_name, ->
    
    Template.group_view.helpers
        subreddit_docs: ->
            sub = Docs.findOne Router.current().params.doc_id
            
            Docs.find 
                model:'reddit'
                subreddit:sub.display_name
            , limit:100

   
    Template.groups.onCreated ->
        @autorun -> Meteor.subscribe 'groups'
    Template.groups.events
        'click .print': ->
            console.log @
    Template.groups.helpers
        group_docs: ->
            Docs.find
                model:'group'
        
        
if Meteor.isServer
    Meteor.publish 'groups', ->
        Docs.find 
            model:'group'
        , limit:100
        
    Meteor.publish 'subreddit_docs', (subreddit_id)->
        sub = Docs.findOne subreddit_id
        # console.log 'sub',sub
        Docs.find {
            model:'reddit'
            subreddit:sub.display_name
        }
        
        