if Meteor.isClient
    Router.route '/user/:username/tips', (->
        @layout 'profile_layout'
        @render 'user_tips'
        ), name:'user_tips'

    Template.user_tips.onCreated ->
        @autorun -> Meteor.subscribe 'user_tips', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_tips', Router.current().params.username
        @autorun => Meteor.subscribe 'all_users'

    Template.user_tips.events
        'keyup .new_tip': (e,t)->
            if e.which is 13
                val = $('.new_tip').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'tip'
                    body: val
                    target_user_id: target_user._id



    Template.user_tips.helpers
        tips: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'tip'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'user_tips', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'tip'
            _author_id:user._id
        },
            limit:100
            sort:_timestamp:-1
        )
