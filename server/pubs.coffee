Meteor.publish 'me', ->
    Meteor.users.find Meteor.userId()