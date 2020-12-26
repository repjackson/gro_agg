if Meteor.isClient
    Router.route '/user/:username/posts', (->
        @layout 'profile_layout'
        @render 'user_posts'
        ), name:'user_posts'

    Template.user_posts.onCreated ->
        @autorun -> Meteor.subscribe 'user_posts', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_posts', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'post'

    Template.user_posts.events
        'keyup .new_post': (e,t)->
            if e.which is 13
                val = $('.new_post').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'post'
                    body: val
                    target_user_id: target_user._id



    Template.user_posts.helpers
        posts: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'post'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'user_posts', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'post'
            _author_id:user._id
        },
            limit:10
            sort:_timestamp:-1
        )
