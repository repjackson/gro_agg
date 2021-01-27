if Meteor.isClient
    Router.route '/course/:course_id/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'course_post_edit'
        ), name:'course_post_edit'
    Router.route '/course/:course_id/post/:doc_id', (->
        @layout 'layout'
        @render 'course_post_view'
        ), name:'course_post_view'

    Template.course_post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.course_post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'comments', Router.current().params.doc_id

    Template.course_post_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    # Router.route '/posts', (->
    #     @layout 'layout'
    #     @render 'posts'
    #     ), name:'posts'

    Template.course_post_edit.events
        'click .delete_post': ->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/"

        'click .publish': ->
            if confirm 'publish post?'
                Meteor.call 'publish_post', @_id, =>
