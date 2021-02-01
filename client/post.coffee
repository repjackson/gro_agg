# if Meteor.isClient
#     Router.route '/p/:doc_id/edit', (->
#         @layout 'layout'
#         @render 'post_edit'
#         ), name:'post_edit'
#     Router.route '/p/:doc_id', (->
#         @layout 'layout'
#         @render 'post_view'
#         ), name:'post_view_small'
#     Router.route '/post/:doc_id/view', (->
#         @layout 'layout'
#         @render 'post_view'
#         ), name:'post_view'

#     Template.post_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#     Template.post_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#         @autorun => Meteor.subscribe 'comments', Router.current().params.doc_id

#     Template.post_view.onRendered ->
#         Meteor.call 'log_view', Router.current().params.doc_id, ->
#     # Router.route '/posts', (->
#     #     @layout 'layout'
#     #     @render 'posts'
#     #     ), name:'posts'

#     Template.post_edit.events
#         'click .delete_post': ->
#             if confirm 'delete?'
#                 Docs.remove @_id
#                 Router.go "/"

#         'click .publish': ->
#             if confirm 'publish post?'
#                 Meteor.call 'publish_post', @_id, =>
