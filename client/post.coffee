Router.route '/p/:doc_id', (->
    @layout 'layout'
    @render 'post_view'
    ), name:'post_view'

Template.post_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
Template.post_view.onCreated ->
    @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'comments', Router.current().params.doc_id

Template.post_view.onRendered ->
    Meteor.call 'log_view', Router.current().params.doc_id, ->
# Router.route '/posts', (->
#     @layout 'layout'
#     @render 'posts'
#     ), name:'posts'

Template.post_edit.events
    'click .delete_post': ->
        if confirm 'delete?'
            Docs.remove @_id
            Router.go "/#{@group}"

    'click .publish': ->
        if confirm 'publish post?'
            Meteor.call 'publish_post', @_id, =>





Template.post_view.events
    'click .goto_sub': -> 
        Meteor.call 'get_sub_latest', Router.current().params.group, ->
    'click .call_visual': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'url', ->
    'click .call_meta': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'meta', ->
    'click .call_thumbnail': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'thumb', ->
    'click .goto_ruser': ->
        doc = Docs.findOne Router.current().params.doc_id
        Meteor.call 'get_user_info', doc.data.author, ->
    'click .get_post': ->
        Session.set('view_section','main')
        Meteor.call 'get_reddit_post', Router.current().params.doc_id, @reddit_id, ->
Template.rcomment.onRendered ->
    # console.log @data
    unless @data.watson
        # console.log 'calling watson on comment'
        Meteor.call 'call_watson', @data._id,'data.body','comment',->
    unless @data.time_tags
        # console.log 'calling watson on comment'
        Meteor.call 'tagify_time_rpost', @data._id,->

