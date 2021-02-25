if Meteor.isClient
    Router.route '/shop', (->
        @layout 'layout'
        @render 'shop'
        ), name:'shop'

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