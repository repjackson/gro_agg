if Meteor.isClient
    @selected_user_levels = new ReactiveArray []
    
    Router.route '/listing/:doc_id/view', (->
        @layout 'layout'
        @render 'listing_view'
        ), name:'listing_view'
    Router.route '/listings/', (->
        @layout 'layout'
        @render 'listings'
        ), name:'listings'

    Template.listing_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
   
    Template.listing_view.onRendered ->


    Template.listing_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            if confirm 'confirm?'
                Meteor.call 'send_listing', @_id, =>
                    Router.go "/listing/#{@_id}/view"


    Template.listing_view.helpers
    Template.listing_view.events

# if Meteor.isServer
#     Meteor.methods
        # send_listing: (listing_id)->
        #     listing = Docs.findOne listing_id
        #     target = Meteor.users.findOne listing.recipient_id
        #     gifter = Meteor.users.findOne listing._author_id
        #
        #     console.log 'sending listing', listing
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: listing.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -listing.amount
        #     Docs.update listing_id,
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
    Router.route '/listing/:doc_id/edit', (->
        @layout 'layout'
        @render 'listing_edit'
        ), name:'listing_edit'

    Template.listing_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.listing_edit.onRendered ->


    Template.listing_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'publish_listing', @_id, =>
                    Router.go "/listing/#{@_id}/view"


    Template.listing_edit.helpers
    Template.listing_edit.events

if Meteor.isServer
    Meteor.methods
        reward_listing: (listing_id, target_id)->
            listing = Docs.findOne listing_id
            target = Meteor.users.findOne target_id

            console.log 'rewarding listing', listing
            Meteor.users.update target._id,
                $addToSet:
                    rewarded_listing_ids: listing._id