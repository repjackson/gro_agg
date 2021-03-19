Router.route '/user/:username/posts', (->
    @layout 'profile_layout'
    @render 'user_posts'
    ), name:'user_posts'


Template.user_posts.onCreated ->
    @autorun -> Meteor.subscribe 'user_posts', 
        Router.current().params.username
        Session.set('skip')
Template.user_posts.helpers
    posts: -> Docs.find model:'post'

