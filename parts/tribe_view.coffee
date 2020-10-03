if Meteor.isClient
    Template.tribe_view.onCreated ->
        # @autorun -> Meteor.subscribe 'user_member_tribes', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_leader_tribes', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_tribes', Router.current().params.username
        @autorun => Meteor.subscribe 'tribe_reddit_posts', Router.current().params.doc_id
    Template.tribe_view.onRendered ->
        # Meteor.call 'log_view', Router.current().params.doc_id
        # Meteor.setTimeout ->
        #     $('.ui.accordion').accordion()
        # , 2000
        # Meteor.setTimeout ->
        #     $('.ui.embed').embed();
        # , 1000
        # Meteor.call 'mark_read', Router.current().params.doc_id, ->

    Template.tribe_view.events
        'keyup .search_subreddit': (e,t)->
            if e.which is 13
                val = $('.search_subreddit').val()
                Meteor.call 'search_subreddit', val, Router.current().params.doc_id, ->
        
    Template.tribe_view.helpers
        tribe_reddit_posts: ->
            subreddit = Docs.findOne(Router.current().params.doc_id).display_name
            Docs.find {
                model:'reddit'
                subreddit:subreddit
            }, 
                sort:_timestamp:-1
                limit:10

        
        
        
        
if Meteor.isServer
    Meteor.publish 'tribe_reddit_posts', (tribe_id)->
        subreddit = Docs.findOne(tribe_id).display_name
        Docs.find {
            model:'reddit'
            subreddit:subreddit
        }, 
            sort:_timestamp:-1
            limit:10
            

