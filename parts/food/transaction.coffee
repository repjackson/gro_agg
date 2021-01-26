if Meteor.isClient
    Template.transactions.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'transaction'
        @autorun -> Meteor.subscribe 'model_docs', 'shop'
        # @autorun -> Meteor.subscribe 'shop'
    Template.transactions.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 3000
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000



    Template.transactions.events
    Template.transactions.helpers
        delivered_transactions: ->
            Docs.find
                model:'transaction'
                delivered:true
        undelivered_transactions: ->
            Docs.find
                model:'transaction'
                delivered:false

    Template.my_transactions.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'transaction'
        @autorun -> Meteor.subscribe 'model_docs', 'shop'
        # @autorun -> Meteor.subscribe 'shop'
    Template.my_transactions.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 3000
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.my_transactions.events
    Template.my_transactions.helpers
        transactions: ->
            Docs.find
                model:'transaction'
                _author_id:Meteor.userId()
