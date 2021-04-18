Router.route '/user/:username/posts', (->
    @layout 'profile_layout'
    @render 'user_posts'
    ), name:'user_posts'


Template.user_posts.onCreated ->
    @autorun -> Meteor.subscribe 'user_posts', 
        Router.current().params.username
        Session.get('skip')
Template.user_posts.onRendered ->
    Session.set('skip',0)
Template.user_posts.events
    'click .skip_left': ->
        console.log Session.get('skip')
        Session.set('skip', parseInt(Session.get('skip')-1))
    'click .skip_right': ->
        console.log Session.get('skip')
        Session.set('skip', parseInt(Session.get('skip')+1))
Template.user_posts.helpers
    posts: -> Docs.find model:'post'

