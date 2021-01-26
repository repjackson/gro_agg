if Meteor.isClient
    Router.route '/orders', -> @render 'orders'
    
    Template.orders.onCreated ->
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), 'order'

    Template.orders.helpers
        order_items: ->
            Docs.find
                model:'order'

    Template.orders.events
        'click .new_order': ->
            new_id = Docs.insert
                model:'order'
            Router.go "/order/#{new_id}/edit"


    Template.order_card_template.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'order'
    Template.order_card_template.helpers
        product: ->
            console.log @

        delivery_when: ->
            moment(@delivery_timestamp).fromNow()

        deliverer: ->
            Meteor.users.findOne
                _id: @delivering_by


    Template.order_card_template.events
        'click .mark_preparing': ->
            Docs.update @_id,
                $set:
                    order_preparing:true
                    preparing_by:Meteor.userId()

        'click .mark_delivering': ->
            Docs.update @_id,
                $set:
                    order_delivering:true
                    delivering_by:Meteor.userId()

        'click .mark_delivered': ->
            Docs.update @_id,
                $set:
                    order_delivered:true
                    delivery_timestamp:Date.now()

    Template.order_page.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.order_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.order_page.helpers
        is_member: ->
            order = Docs.findOne Router.current().params.doc_id
            if order.members and Meteor.user().username in order.members then true else false

    Template.order_page.events
        'click .join': ->
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    members: Meteor.user().username
        'click .leave': ->
            Docs.update Router.current().params.doc_id,
                $pull:
                    members: Meteor.user().username
