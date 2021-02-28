Router.route '/p/:doc_id', (->
    @layout 'layout'
    @render 'post_view'
    ), name:'post_view_short'


Template.post_view.onCreated ->
    # Session.set('session_clicks', Session.get('session_clicks')+2)
    # Meteor.call 'log_view', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

Template.post_view.helpers


Template.post_view.events
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

