if Meteor.isClient
    Router.route '/group/:group_id/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'group_post_edit'
        ), name:'group_post_edit'
    Router.route '/group/:group_id/post/:doc_id', (->
        @layout 'layout'
        @render 'group_post_view'
        ), name:'group_post_view'

    Template.group_post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.group_post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'comments', Router.current().params.doc_id

    Template.group_post_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    # Router.route '/posts', (->
    #     @layout 'layout'
    #     @render 'posts'
    #     ), name:'posts'

    Template.group_post_edit.events
        'click .delete_post': ->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/"

        'click .publish': ->
            if confirm 'publish post?'
                Meteor.call 'publish_post', @_id, =>
