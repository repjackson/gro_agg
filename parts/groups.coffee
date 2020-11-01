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
        'click .search_sub': (e,t)->
            val = $('.search_subreddit').val()
            sub = Docs.findOne Router.current().params.doc_id
            Meteor.call 'search_reddit', val, sub.display_name, ->
                $('.search_subreddit').val('')
        'keyup .search_subreddit': (e,t)->
            val = $('.search_subreddit').val()
            sub = Docs.findOne Router.current().params.doc_id
            if e.which is 13
                console.log 'searching', val, sub.display_name
                Meteor.call 'search_reddit', val, sub.display_name, ->
                    $('.search_subreddit').val('')
    
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
        if sub
            console.log 'sub docs', sub.display_name
            if sub.display_name
                # subreddit: sub.display_name
                Docs.find {
                    model:'post'
                    # subreddit: 'funny'
                    # model: 'reddit'
                }, 
                    sort:
                        _timestamp:-1
                    limit:2
        