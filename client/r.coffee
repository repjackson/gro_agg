    
Router.route '/reddit', (->
    @layout 'layout'
    @render 'reddit'
    ), name:'reddit'


Router.route '/r/:subreddit/users', (->
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
        Meteor.call 'get_sub_latest', @data.display_name, ->
        Meteor.call 'get_sub_info', @data.display_name, ->

        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
    'keyup .search_subreddits': (e,t)->
        val = $('.search_subreddits').val()
        Session.set('subreddit_query', val)
        if e.which is 13 
            Meteor.call 'search_subreddits', val, ->
                # $('.search_subreddits').val('')
                # Session.set('subreddit_query', null)
            
            
    'click .search_subs': ->
        Meteor.call 'search_subreddits', 'news', ->
Template.reddit.helpers
    subreddit_docs: ->
        Docs.find
            model:'subreddit'


