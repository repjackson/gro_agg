Router.route '/:group/p/:doc_id/edit', (->
    @layout 'layout'
    @render 'post_edit'
    ), name:'post_edit'
Router.route '/:group/p/:doc_id', (->
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

Template.post_edit.helpers
Template.post_view.helpers
    doc_by_id: ->
        Docs.findOne Router.current().params.doc_id
Template.post_edit.events
    'click .delete_post': ->
        if confirm 'delete?'
            Docs.remove @_id
            Router.go "/#{@group}"

    'click .publish': ->
        if confirm 'publish post?'
            Meteor.call 'publish_post', @_id, =>




Template.post_view.onCreated ->
    @autorun -> Meteor.subscribe('doc_by_id', Router.current().params.doc_id)
    @autorun -> Meteor.subscribe('rpost_comments', Router.current().params.group, Router.current().params.doc_id)
Template.post_view.onRendered ->
    Meteor.call 'get_post_comments', Router.current().params.group, Router.current().params.doc_id, ->

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

Template.rcomments_tab.onCreated ->
    @autorun => Meteor.subscribe 'rpost_comment_tags', Router.current().params.doc_id

Template.rcomments_tab.helpers
    rcomment_tags: ->
        results.find(model:'rpost_comment_tag')

Template.rcomment.onRendered ->
    # console.log @data
    unless @data.watson
        # console.log 'calling watson on comment'
        Meteor.call 'call_watson', @data._id,'data.body','comment',->
    unless @data.time_tags
        # console.log 'calling watson on comment'
        Meteor.call 'tagify_time_rpost', @data._id,->

