Router.route '/r/:subreddit', (->
    @layout 'layout'
    @render 'subreddit'
    ), name:'subreddit'
    
Router.route '/r/:subreddit/post/:doc_id', (->
    @layout 'layout'
    @render 'reddit_page'
    ), name:'reddit_page'
    

Template.subreddit.onCreated ->
    # Session.setDefault('user_query', null)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'subrzeddit_user_count', Router.current().params.subreddit
    @autorun => Meteor.subscribe 'subreddit_by_param', Router.current().params.subreddit
    @autorun => Meteor.subscribe 'sub_docs_by_name', Router.current().params.subreddit
    # @autorun => Meteor.subscribe 'stackusers_by_subreddit', 
        # Router.current().params.site
        # Session.get('user_query')
    Meteor.call 'log_subreddit_view', Router.current().params.subreddit, ->

Template.subreddit_doc_item.events
    'click .view_post': (e,t)-> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance @title
        # Router.go "/subreddit/#{@subreddit}/post/#{@_id}"

Template.subreddit_doc_item.onRendered ->
    console.log @
    unless @data.watson
        Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>


Template.subreddit.events
    'click .download': ->
        Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
    
    'click .pull_latest': ->
        console.log 'latest'
        Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->
    'click .get_info': ->
        Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
            
    'keyup .search_subreddit': (e,t)->
        val = $('.search_subreddit').val()
        Session.set('sub_doc_query', val)
        if e.which is 13 
            Meteor.call 'search_subreddit', Router.current().params.subreddit, val, ->
                $('.search_subreddit').val('')
                Session.set('sub_doc_query', null)
            
            
            
            
Template.subreddit.helpers
    subreddit_doc: ->
        Docs.findOne
            model:'subreddit'
            "data.display_name":Router.current().params.subreddit
    sub_docs: ->
        Docs.find
            model:'rpost'
            subreddit:Router.current().params.subreddit