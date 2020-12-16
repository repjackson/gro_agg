# Router.route '/u/:', (->
#     @layout 'layout'
#     @render 's_users'
#     ), name:'s_users'
    
# Template.reddit_page.onCreated ->
#     @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)
#     @autorun -> Meteor.subscribe('rpost_comments', Router.current().params.subreddit, Router.current().params.doc_id)
# Template.reddit_page.onRendered ->
#     Meteor.call 'get_post_comments', Router.current().params.subreddit, Router.current().params.doc_id, ->

# Template.rcomment.events
#     'click .call_watson_comment': ->
#         unless @watson
#             console.log 'calling watson on comment'
#             Meteor.call 'call_watson', @_id,'data.body','comment',->

# Template.reddit_page.events
#     'click .call_visual': ->
#         Meteor.call 'call_visual', Router.current().params.doc_id, 'url', ->
#     'click .call_meta': ->
#         Meteor.call 'call_visual', Router.current().params.doc_id, 'meta', ->
#     'click .call_thumbnail': ->
#         Meteor.call 'call_visual', Router.current().params.doc_id, 'thumb', ->

#     'click .get_post_comments': ->
#         Meteor.call 'get_post_comments', Router.current().params.subreddit, Router.current().params.doc_id, ->
#     'click .goto_ruser': ->
#         doc = Docs.findOne Router.current().params.doc_id
#         Meteor.call 'get_user_info', doc.data.author, ->

#     'click .get_post': ->
#         Session.set('view_section','main')
