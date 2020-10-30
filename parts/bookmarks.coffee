if Meteor.isClient
    Template.user_bookmarks_small.onRendered ->
        @autorun => Meteor.subscribe('users_bookmarks',Router.current().params.username)
    Template.user_bookmarks_small.helpers
        users_bookmarks: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                _id:$in:user.bookmarked_ids
