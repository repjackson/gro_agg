if Meteor.isClient
    Template.registerHelper 'claimer', () ->
        Meteor.users.findOne @claimed_user_id
    Template.registerHelper 'completer', () ->
        Meteor.users.findOne @completed_by_user_id
    
    Router.route '/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'post_edit'
        ), name:'post_edit'
    Router.route '/post/:doc_id/view', (->
        @layout 'layout'
        @render 'post_view'
        ), name:'post_view'
    Router.route '/posts/', (->
        @layout 'layout'
        @render 'posts'
        ), name:'posts'

    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_tips.onCreated ->
        @autorun -> Meteor.subscribe 'post_tips', Router.current().params.doc_id

    Template.post_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    # Router.route '/posts', (->
    #     @layout 'layout'
    #     @render 'posts'
    #     ), name:'posts'

    Template.post_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id


    Template.post_card.events
        'click .view_post': ->
            Router.go "/m/post/#{@_id}/view"
    Template.post_item.events
        'click .view_post': ->
            Router.go "/m/post/#{@_id}/view"


    Template.post_edit.events
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
                    Router.go "/m/post"
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
            
            
    Template.post_tips.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000

    Template.post_tips.events
        'click .tip': ->
            if confirm 'tip?'
                Docs.insert     
                    model:'tip'
                    post_id:@_id
                Docs.update @_id,
                    $addToSet:
                        tipper_ids:Meteor.userId()
                        tipper_usernames:Meteor.user().username
                Meteor.call 'calc_post_stats', @_id, ->
    

    Template.post_tips.helpers
        tips: ->
            Docs.find
                model:'tip'
        
        tippers: ->
            Meteor.users.find
                _id:$in:@tipper_ids
        
        tipper_tips: ->
            console.log @
            Docs.find
                model:'tip'
                _author_id:@_id
        
        can_claim: ->
            if @claimed_user_id
                false
            else 
                if @_author_id is Meteor.userId()
                    false
                else
                    true


            
            
if Meteor.isServer
    Meteor.methods 
        calc_post_stats: (post_id)->
            post = Docs.findOne post_id
            tip_total = 0
            
            tip_cur = 
                Docs.find 
                    model:'tip'
                    post_id:post_id
            # for tip in tip_cur.fetch()
            #     console.log tip
            
            tip_total = 10*tip_cur.count()
            
            Docs.update post_id,
                $set:
                    tip_total:tip_total
                    tip_count:tip_cur.count()
            
    Meteor.publish 'post_tips', (post_id)->
        Docs.find   
            model:'tip'
            post_id:post_id
    
