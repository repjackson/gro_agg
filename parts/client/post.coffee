Router.route '/p/:doc_id/view', (->
    @layout 'layout'
    @render 'post_view'
    ), name:'post_view_long'
Router.route '/p/:doc_id', (->
    @layout 'layout'
    @render 'post_view'
    ), name:'post_view_short'

Template.post_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
Template.post_view.onCreated ->
    Session.set('session_clicks', Session.get('session_clicks')+2)
    Meteor.call 'log_view', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

Template.post_view.helpers
    reflections: ->
        Docs.find
            model:'reflection'
            parent_id:Router.current().params.doc_id


Template.post_edit.events
    'click .delete_post': ->
        if confirm 'delete post? cannot be undone'
            Docs.remove @_id
            if @group
                Router.go "/g/#{@group}"
            else 
                Router.go "/"
Template.post_view.events
    'click .search_dao': ->
        picked_tags.clear()
        Router.go '/'
