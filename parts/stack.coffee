if Meteor.isClient
    Router.route '/stack', (->
        @layout 'layout'
        @render 'stack'
        ), name:'stack'


    Template.stack.onCreated ->
        # @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_posts', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_friends', Router.current().params.username
