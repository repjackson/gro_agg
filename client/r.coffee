Router.route '/r/:name', (->
    @layout 'layout'
    @render 'subreddit'
    ), name:'subreddit'
    
Router.route '/r/:name/post/:rid', (->
    @layout 'layout'
    @render 'reddit_page'
    ), name:'reddit_page'
    
    
Router.route '/reddit', (->
    @layout 'layout'
    @render 'reddit'
    ), name:'reddit'


Router.route '/r/:name/users', (->
    @layout 'layout'
    @render 's_users'
    ), name:'s_users'
    
    
Template.reddit_page.onCreated ->
    @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)

Template.reddit_page.events
    'click .get_post': ->
        Meteor.call 'get_reddit_post', Router.current().params.doc_id, @reddit_id, ->

Template.reddit.onCreated ->
    Session.setDefault('subreddit_query',null)
    @autorun -> Meteor.subscribe('subreddits',
        Session.get('subreddit_query')
        selected_tags.array())

Template.reddit.events
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
Template.reddit.helpers
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
        # Router.go "/subreddit/#{@subreddit}/post/#{@_id}"

Template.subreddit_docs.helpers
    subreddit_doc: ->
        Docs.findOne
            model:'subreddit'
            "data.display_name":Router.current().params.name
    sub_docs: ->
        Docs.find
            model:'reddit'
            subreddit:Router.current().params.name