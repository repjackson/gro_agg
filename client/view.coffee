Router.route '/p/:doc_id', (->
    @layout 'layout'
    @render 'post_view'
    ), name:'post_view_short'


Template.post_view.onCreated ->
    Session.set('post_view_mode', 'main')
    Meteor.call 'log_view', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'rpost_comments', @subreddit, Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'rpost_comment_tags', @subreddit, Router.current().params.doc_id, ->

Template.post_view.helpers
    rcomments: ->
        Docs.find 
            model:'rcomment'

Template.post_view.events
    'click .get_comments': ->
        Meteor.call 'get_post_comments', @subreddit, Router.current().params.doc_id, ->
    
    'click .set_main': ->
        Session.set('post_view_mode', 'main')
    'click .set_stats': ->
        Session.set('post_view_mode', 'stats')
    'click .set_tone': ->
        Session.set('post_view_mode', 'tone')
    'click .set_cleaned': ->
        Session.set('post_view_mode', 'cleaned')
    
    'click .set_comments': ->
        Session.set('post_view_mode', 'comments')
    'click .search_sub': ->
        # picked_tags.clear()
        unless @subreddit.toLowerCase() in picked_tags.array()
            picked_tags.push @subreddit.toLowerCase()
        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
        Meteor.setTimeout ->
            Session.set('toggle', !Session.get('toggle'))
        , 7000    
        
        Router.go '/'

Template.rcomment.onRendered ->
    console.log @data
    unless @data.watson
        console.log 'calling watson on comment'
        Meteor.call 'call_watson', @data._id,'data.body','comment',->
    unless @data.time_tags
        console.log 'calling watson on comment'
        Meteor.call 'tagify_time_rpost', @data._id,->
