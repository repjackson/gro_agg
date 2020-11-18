if Meteor.isClient
    Router.route '/subreddit/:name', (->
        @layout 'layout'
        @render 'subreddit_docs'
        ), name:'subreddit_docs'
        
    Router.route '/subreddit/:name/doc/:doc_id', (->
        @layout 'layout'
        @render 'subreddit_page'
        ), name:'subreddit_page'
    Router.route '/subreddits', (->
        @layout 'layout'
        @render 'subreddits'
        ), name:'subreddits'
    
    
    Router.route '/subreddit/:name/users', (->
        @layout 'layout'
        @render 'subreddit_users'
        ), name:'subreddit_users'
    Template.subreddits.onCreated ->
        Session.setDefault('subreddit_query',null)
        @autorun -> Meteor.subscribe('subreddits',
            Session.get('subreddit_query')
            selected_tags.array())

    Template.subreddits.events
        'keyup .search_subreddits': (e,t)->
            Session.set('subreddit_query', $('.search_subreddits').val())
        'click .search_subs': ->
            Meteor.call 'search_subreddits', 'news', ->
    Template.subreddits.helpers
        subreddit_docs: ->
            Docs.find
                model:'subreddit'

    Template.subreddit_docs.onCreated ->
        # Session.setDefault('user_query', null)
        # Session.setDefault('location_query', null)
        # @autorun => Meteor.subscribe 'subrzeddit_user_count', Router.current().params.subreddit
        @autorun => Meteor.subscribe 'subreddit_by_param', Router.current().params.name
        # @autorun => Meteor.subscribe 'sub_docs_by_name', Router.current().params.name
        # @autorun => Meteor.subscribe 'stackusers_by_subreddit', 
            # Router.current().params.site
            # Session.get('user_query')

    Template.subreddit_docs.helpers
        subreddit_doc: ->
            Docs.findOne
                model:'subreddit'
                "data.display_name":Router.current().params.name
        # subreddit_docs: ->
        #     Docs.find
        #         model:'reddit'
        #         subreddit:Router.current().param.name

if Meteor.isServer
    Meteor.publish 'subreddit_by_param', (name)->
        Docs.find
            model:'subreddit'
            "data.display_name":name
    Meteor.publish 'subreddits', (
        query=''
        selected_tags
        )->
        match = {model:'subreddit'}
        
        if query.length > 0
            match["data.display_name"] = {$regex:"#{query}", $options:'i'}
        Docs.find match
            
    # Meteor.publish 'sub_docs_by_name', (name)->
    #     Docs.find
    #         model:'reddit'
    #         subreddit:name
            