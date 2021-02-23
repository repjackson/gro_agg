if Meteor.isClient
    Router.route '/u/:username/friends', (->
        @layout 'profile_layout'
        @render 'user_friends'
        ), name:'user_friends'
    
    Template.user_friends.onCreated ->
        @autorun => Meteor.subscribe 'all_users'
        @autorun => Meteor.subscribe 'friends'



    Template.user_friends.helpers
        friends: ->
            current_user = Meteor.users.findOne Router.current().params.username
            Meteor.users.find
                _id:$in: current_user.friend_ids
        nonfriends: ->
            Meteor.users.find
                _id:$nin:Meteor.user().friend_ids


    Template.registerHelper 'is_friend', () ->
        Meteor.user() and Meteor.user().friend_ids and @_id in Meteor.user().friend_ids

    Template.user_friend_button.helpers


    Template.user_friend_button.events
        'click .friend':->
            Meteor.users.update Meteor.userId(),
                $addToSet: friend_ids:@_id
        'click .unfriend':->
            Meteor.users.update Meteor.userId(),
                $pull: friend_ids:@_id

        'keyup .assign_earn': (e,t)->
            if e.which is 13
                post = t.$('.assign_earn').val().trim()
                # console.log post
                current_user = Meteor.users.findOne Router.current().params.username
                Docs.insert
                    body:post
                    model:'earn'
                    assigned_user_id:current_user._id
                    assigned_username:current_user.username

                t.$('.assign_earn').val('')



if Meteor.isServer
    Meteor.publish 'friends', ()->
        Meteor.users.find {},
            fields:
                username:1
                tags:1
                profile_image_id:1
                nickname:1