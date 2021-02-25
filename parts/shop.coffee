if Meteor.isClient
    Router.route '/shop', (->
        @layout 'layout'
        @render 'shop'
        ), name:'shop'
    Router.route '/s/:doc_id/edit', (->
        @layout 'layout'
        @render 'shop_edit'
        ), name:'shop_edit'
    Router.route '/s/:doc_id', (->
        @layout 'layout'
        @render 'shop_view'
        ), name:'shop_view'

    Template.shop_view.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_shop_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

        
    Template.shop_edit.onCreated ->
        @autorun => Meteor.subscribe 'target_from_shop_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.shop.onCreated ->
        @autorun -> Meteor.subscribe 'products'
        # @autorun => Meteor.subscribe 'my_received_messages'
        # @autorun => Meteor.subscribe 'my_sent_messages'
        @autorun => Meteor.subscribe 'all_users'
        # @autorun => Meteor.subscribe 'model_docs', 'stat'

    Template.shop.helpers
        shop_items: ->
            Docs.find 
                model:'post'
                can_buy:true
    Template.shop.events
        'click .add_message': ->
            new_message_id =
                Docs.insert
                    model:'message'
            Router.go "/message/#{new_message_id}/edit"

if Meteor.isServer
    Meteor.publish 'products', ()->
        Docs.find 
            model:'post'
            can_buy: true