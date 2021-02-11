Template.reddit_page.onCreated ->
    @autorun -> Meteor.subscribe('doc_by_id', Router.current().params.doc_id)
    @autorun -> Meteor.subscribe('rpost_comments', Router.current().params.subreddit, Router.current().params.doc_id)
Template.reddit_page.onRendered ->
    Meteor.call 'get_post_comments', Router.current().params.subreddit, Router.current().params.doc_id, ->

Template.reddit_page.events
    'click .goto_sub': -> 
        Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
            Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->
            Meteor.call 'log_subreddit_view', Router.current().params.subreddit, ->
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
    console.log @data
    unless @data.watson
        console.log 'calling watson on comment'
        Meteor.call 'call_watson', @data._id,'data.body','comment',->
    unless @data.time_tags
        console.log 'calling watson on comment'
        Meteor.call 'tagify_time_rpost', @data._id,->

