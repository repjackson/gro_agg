if Meteor.isClient
    Router.route '/g/:group/p/:doc_id/edit', (->
        @layout 'layout'
        @render 'group_post_edit'
        ), name:'group_post_edit'
    Router.route '/g/:group/p/:doc_id', (->
        @layout 'layout'
        @render 'group_post_view'
        ), name:'group_post_view'

    Template.group_post_edit.onCreated ->
        @autorun -> Meteor.subscribe('doc_by_id', Router.current().params.doc_id)

        # @autorun -> Meteor.subscribe('post_comments', Router.current().params.group, Router.current().params.doc_id)
    Template.group_post_view.onCreated ->
        @autorun -> Meteor.subscribe('doc_by_id', Router.current().params.doc_id)
        @autorun -> Meteor.subscribe('post_comments', Router.current().params.group, Router.current().params.doc_id)
    Template.group_post_view.onRendered ->
        Meteor.call 'get_post_comments', Router.current().params.group, Router.current().params.doc_id, ->
    Template.group_post_view.helpers
        doc_by_id: -> Docs.findOne Router.current().params.doc_id


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


if Meteor.isClient
    # Template.post_card.onCreated ->
    #     @autorun => Meteor.subscribe 'doc_comments', @data._id


    # Template.post_card.events
    #     'click .view_post': ->
    #         Router.go "/m/post/#{@_id}/view"
    # Template.post_item.events
    #     'click .view_post': ->
    #         Router.go "/m/post/#{@_id}/view"


    Template.group_post_edit.events
        'click .delete_post': ->
            Swal.fire({
                title: "delete post?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'post removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/g/#{group}"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish post?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_post', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'post published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish post?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_post', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'post unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )
