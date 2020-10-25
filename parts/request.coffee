if Meteor.isClient
    Template.registerHelper 'claimer', () ->
        Meteor.users.findOne @claimed_user_id
    Template.registerHelper 'completer', () ->
        Meteor.users.findOne @completed_by_user_id
    
    
    Router.route '/requests', (->
        @layout 'layout'
        @render 'requests'
        ), name:'requests'
    Template.requests.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'request'
        @autorun => Meteor.subscribe 'all_users'
    Template.requests.helpers
        requests: ->
            Docs.find 
                model:'request'
                complete:$ne:true


    Template.request_card.events
        'click .request_card': ->
            Router.go "/request/#{@_id}/view"
            Docs.update @_id,
                $inc: views:1



    Router.route '/request/:doc_id/view', (->
        @layout 'layout'
        @render 'request_view'
        ), name:'request_view'

    Template.request_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
   
   
    Template.request_view.onRendered ->


    Template.request_view.events
        'click .claim': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    claimed_user_id: Meteor.userId()
                    status:'claimed'
            
                            
        'click .unclaim': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    claimed_user_id: 1
                $set:
                    status:'unclaimed'
            
                            
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete: true
                    completed_by_user_id:@claimed_user_id
                    status:'complete'
                    completed_timestamp:Date.now()
            Meteor.users.update @claimed_user_id,
                $inc:points:@point_bounty
                            
        'click .mark_incomplete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete: false
                    completed_by_user_id: null
                    status:'claimed'
                    completed_timestamp:null
            Meteor.users.update @claimed_user_id,
                $inc:points:-@point_bounty
                            

    Template.request_view.helpers
        can_claim: ->
            if @claimed_user_id
                false
            else 
                if @_author_id is Meteor.userId()
                    false
                else
                    true



# if Meteor.isServer
#     Meteor.methods
        # send_request: (request_id)->
        #     request = Docs.findOne request_id
        #     target = Meteor.users.findOne request.recipient_id
        #     gifter = Meteor.users.findOne request._author_id
        #
        #     console.log 'sending request', request
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: request.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -request.amount
        #     Docs.update request_id,
        #         $set:
        #             publishted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true


if Meteor.isClient
    Router.route '/request/:doc_id/edit', (->
        @layout 'layout'
        @render 'request_edit'
        ), name:'request_edit'

    Template.request_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.request_edit.onRendered ->


    Template.request_edit.events
        'click .delete_request': ->
            Swal.fire({
                title: "delete request?"
                text: "point bounty will be returned to your account"
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
                        title: 'request removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/requests"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish request?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_request', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'request published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish request?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_request', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'request unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )


    Template.request_edit.helpers
    Template.request_edit.events

if Meteor.isServer
    Meteor.methods
        publish_request: (request_id)->
            request = Docs.findOne request_id
            # target = Meteor.users.findOne request.recipient_id
            author = Meteor.users.findOne request._author_id

            console.log 'publishing request', request
            Meteor.users.update author._id,
                $inc:
                    points: -request.point_bounty
            Docs.update request_id,
                $set:
                    published:true
                    published_timestamp:Date.now()
                    
                    
        unpublish_request: (request_id)->
            request = Docs.findOne request_id
            # target = Meteor.users.findOne request.recipient_id
            author = Meteor.users.findOne request._author_id

            console.log 'unpublishing request', request
            Meteor.users.update author._id,
                $inc:
                    points: request.point_bounty
            Docs.update request_id,
                $set:
                    published:false
                    published_timestamp:null
                    
                    
if Meteor.isClient
    Router.route '/u/:username/requests', (->
        @layout 'profile'
        @render 'user_requests'
        ), name:'user_requests'

    Template.user_requests.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'request', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_requests', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'request'

    Template.user_requests.events
        'keyup .new_request': (e,t)->
            if e.which is 13
                val = $('.new_request').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'request'
                    body: val
                    target_user_id: target_user._id



    Template.user_requests.helpers
        requests: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'request'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'user_requests', (username)->
        Docs.find
            model:'request'