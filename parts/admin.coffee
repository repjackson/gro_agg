if Meteor.isClient
    Router.route '/admin', (->
        @layout 'layout'
        @render 'admin'
        ), name:'admin'

    Template.admin.onCreated ->
        @autorun -> Meteor.subscribe 'admins'
        # @autorun -> Meteor.subscribe 'user_model_docs', 'offer', Router.current().params.username
        # @autorun => Meteor.subscribe 'admin', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'stat'

    Template.admin.events
        'keyup .new_offer': (e,t)->
            if e.which is 13
                val = $('.new_offer').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'offer'
                    body: val
                    target_user_id: target_user._id



    Template.admin.helpers
        admins: ->
            Meteor.users.find
                roles: $in: ['admin']
        
        
        offers: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'offer'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'admin', (username)->
        Docs.find
            model:'offer'
            
    Meteor.publish 'admins', ()->
        Meteor.users.find   
            roles:$in:['admin']
            
            
            