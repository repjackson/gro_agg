if Meteor.isClient
    Router.route '/subreddit/:name', (->
        @layout 'layout'
        @render 'subreddit_docs'
        ), name:'subreddit_docs'
        
    Router.route '/subreddit/:name/doc/:doc_id', (->
        @layout 'layout'
        @render 'reddit_page'
        ), name:'reddit_page'
        
        
    Router.route '/subreddits', (->
        @layout 'layout'
        @render 'subreddits'
        ), name:'subreddits'
    
    
    Router.route '/subreddit/:name/users', (->
        @layout 'layout'
        @render 'subreddit_users'
        ), name:'subreddit_users'
        
        
    Template.reddit_page.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)
    
    Template.reddit_page.events
        'click .get_post': ->
            Meteor.call 'get_reddit_post', Router.current().params.doc_id, @reddit_id, ->
    
    Template.subreddits.onCreated ->
        Session.setDefault('subreddit_query',null)
        @autorun -> Meteor.subscribe('subreddits',
            Session.get('subreddit_query')
            selected_tags.array())

    Template.subreddits.events
        'click .goto_sub': (e,t)->
            window.speechSynthesis.speak new SpeechSynthesisUtterance @data.display_name
        'keyup .search_subreddits': (e,t)->
            val = $('.search_subreddits').val()
            Session.set('subreddit_query', val)
            if e.which is 13 
                Meteor.call 'search_subreddits', val, ->
                    $('.search_subreddits').val('')
                    Session.set('subreddit_query', null)
                
                
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
        @autorun => Meteor.subscribe 'sub_docs_by_name', Router.current().params.name
        # @autorun => Meteor.subscribe 'stackusers_by_subreddit', 
            # Router.current().params.site
            # Session.get('user_query')
        Meteor.call 'log_subreddit_view', Router.current().params.name, ->

    Template.subreddit_doc_item.events
        'click .view_post': (e,t)-> 
            window.speechSynthesis.speak new SpeechSynthesisUtterance @title
            # Router.go "/subreddit/#{@subreddit}/doc/#{@_id}"

    Template.subreddit_docs.helpers
        subreddit_doc: ->
            Docs.findOne
                model:'subreddit'
                "data.display_name":Router.current().params.name
        sub_docs: ->
            Docs.find
                model:'reddit'
                subreddit:Router.current().params.name

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
        Docs.find match,
            limit:42
            
    Meteor.publish 'sub_docs_by_name', (name)->
        Docs.find {
            model:'reddit'
            subreddit:name
        }, limit:20
    Meteor.methods 
        log_subreddit_view: (name)->
            sub = Docs.findOne
                model:'subreddit'
                "data.display_name":name
            Docs.update sub._id,
                $inc:dao_views:1