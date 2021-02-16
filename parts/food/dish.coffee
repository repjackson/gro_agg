if Meteor.isClient
    Router.route '/dish/:doc_id/view', (->
        @layout 'layout'
        @render 'dish_view'
        ), name:'dish_view'
    Template.dish_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'shop_from_dish_id', Router.current().params.doc_id
   
   
    Router.route '/dish/:doc_id/edit', (->
        @layout 'layout'
        @render 'dish_edit'
        ), name:'dish_edit'

    Template.dish_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.dish_edit.onRendered ->


    Template.dish_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'publish_menu', @_id, =>
                    Router.go "/menu/#{@_id}/view"


if Meteor.isServer
    Meteor.publish 'shop_from_dish_id', (dish_id)->
        dish = Docs.findOne dish_id
        console.log 'dish', dish
        Docs.find
            # model:'shop'
            _id:dish.shop_id