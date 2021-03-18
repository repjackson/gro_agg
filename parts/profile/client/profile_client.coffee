Router.route '/user/:username', (->
    @layout 'profile_layout'
    @render 'user_dashboard'
    ), name:'user_dashboard'
Router.route '/user/:username/comments', (->
    @layout 'profile_layout'
    @render 'user_comments'
    ), name:'user_comments'
Router.route '/user/:username/posts', (->
    @layout 'profile_layout'
    @render 'user_posts'
    ), name:'user_posts'
Router.route '/user/:username/upvoted', (->
    @layout 'profile_layout'
    @render 'user_upvoted'
    ), name:'user_upvoted'
Router.route '/user/:username/downvoted', (->
    @layout 'profile_layout'
    @render 'user_downvoted'
    ), name:'user_downvoted'
Router.route '/user/:username/vault', (->
    @layout 'profile_layout'
    @render 'user_vault'
    ), name:'user_vault'
Router.route '/user/:username/tips', (->
    @layout 'profile_layout'
    @render 'user_tips'
    ), name:'user_tips'
Router.route '/user/:username/bounties', (->
    @layout 'profile_layout'
    @render 'user_bounties'
    ), name:'user_bounties'
Router.route '/user/:username/groups', (->
    @layout 'profile_layout'
    @render 'user_groups'
    ), name:'user_groups'

Template.user_vault.onCreated ->
    @autorun -> Meteor.subscribe 'user_vault', Router.current().params.username
Template.user_vault.helpers
    private_posts: -> 
        user = Meteor.users.findOne(username:Router.current().params.username)

        Docs.find 
            model:'post'
            is_private:true
            _author_id:user._id




Template.user_comments.onCreated ->
    @autorun -> Meteor.subscribe 'user_comments', Router.current().params.username
Template.user_comments.helpers
    comments: -> Docs.find model:'comment'

Template.user_tips.onCreated ->
    @autorun -> Meteor.subscribe 'user_tips', Router.current().params.username
Template.user_tips.helpers
    tips: -> Docs.find model:'tip'

Template.user_posts.onCreated ->
    @autorun -> Meteor.subscribe 'user_posts', Router.current().params.username
Template.user_posts.helpers
    posts: -> Docs.find model:'post'


# Template.user_bounties.onCreated ->
#     @autorun -> Meteor.subscribe 'user_bounties', Router.current().params.username
# Template.user_bounties.helpers
#     bountys: -> Docs.find model:'bounty'


Template.profile_layout.onCreated ->
    # @autorun -> Meteor.subscribe 'user_post_count', Router.current().params.username
    # @autorun -> Meteor.subscribe 'user_comment_count', Router.current().params.username

Template.user_dashboard.onCreated ->
    # @autorun -> Meteor.subscribe 'user_tips_received_count', Router.current().params.username
    # @autorun -> Meteor.subscribe 'user_tips_sent_count', Router.current().params.username
    # @autorun -> Meteor.subscribe 'user_karma_sent', Router.current().params.username
    # @autorun -> Meteor.subscribe 'user_karma_received', Router.current().params.username
    # @autorun -> Meteor.subscribe 'user_feed_items', Router.current().params.username
    # @autorun -> Meteor.subscribe 'model_docs', 'bounty'
Template.user_dashboard.events
    'click .mark_viewed': ->
        console.log @
        $('body').toast({
            message: 'marked read'
            class: 'success'
        })
        
        Meteor.call 'mark_viewed', @_id, ->

    'click .user_credit_segment': ->
        Router.go "/debit/#{@_id}/view"
        
    'click .user_debit_segment': ->
        Router.go "/debit/#{@_id}/view"
        
    'click .user_checkin_segment': ->
        Router.go "/drink/#{@drink_id}/view"
        
    'keyup .add_feed_item': (e,t)->
        if e.which is 13
            val = $('.add_feed_item').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'feed_item'
                body: val
                target_user_id: target_user._id
                target_user_username: target_user.username
            val = $('.add_feed_item').val('')

        
Template.user_dashboard.helpers
    bounties_from: -> 
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        
        Docs.find {
            model:'bounty'
            _author_id:target_user._id
        },
            sort:
                _timestamp:-1
            limit:10
    bounties_to: -> 
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        
        Docs.find {
            model:'bounty'
            target_id:target_user._id
        },
            sort:
                _timestamp:-1
            limit:10
    feed_items: -> 
        Docs.find {
            model:'feed_item'
        },
            sort:
                _timestamp:-1
            limit:10
    user_post_count: -> Counts.get 'user_post_count'
    post_points: -> Counts.get('user_post_count')*10
    user_comment_count: -> Counts.get 'user_comment_count'
    user_tips_sent_count: -> Counts.get 'user_tips_sent_count'
    user_tips_received_count: -> Counts.get 'user_tips_received_count'

    user_karma_received: ->
        current_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find 
            model:'debit'
            target_id:current_user._id
    user_karma_sent: ->
        current_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find 
            model:'debit'
            _author_id:current_user._id
    user_referred: ->
        current_user = Meteor.users.findOne(username:Router.current().params.username)
        Meteor.users.find 
            referrer:current_user._id
    user_comments: ->
        current_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find {
            model:'comment'
            _author_id: current_user._id
        }, 
            limit: 10
            sort: _timestamp:-1
    user_debits: ->
        current_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find {
            model:'debit'
            _author_id: current_user._id
        }, 
            limit: 10
            sort: _timestamp:-1
    user_credits: ->
        current_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find {
            model:'bounty'
            target_id: current_user._id
        }, 
            sort: _timestamp:-1
            limit: 10
  
    user_credits: ->
        current_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find {
            model:'debit'
            target_id: current_user._id
        }, 
            sort: _timestamp:-1
            limit: 10
  
    user_groups: ->
        current_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find {
            model:'group'
            member_ids: $in:[current_user._id]
        }, 
            sort: _timestamp:-1
            limit: 10


    group_bookmarks: ->
        user = Meteor.users.findOne username:Router.current().params.username
        Docs.find {
            model:'group_bookmark'
            _author_id:user._id
        }, sort:search_amount:-1
    posts: ->
        user = Meteor.users.findOne username:Router.current().params.username
        Docs.find {
            model:'post'
            _author_id:user._id
        }, 
            sort:
                search_amount:-1
            limit:10
    tips: ->
        user = Meteor.users.findOne username:Router.current().params.username
        Docs.find {
            model:'tip'
            _author_id:user._id
        }, sort:amount:-1
            
    reflections: ->
        user = Meteor.users.findOne username:Router.current().params.username
        Docs.find {
            model:'reflections'
            _author_id:user._id
        }, sort:_timestamp:-1
    comments: ->
        user = Meteor.users.findOne username:Router.current().params.username
        Docs.find {
            model:'comment'
            _author_id:user._id
        }, sort:_timestamp:-1
            
    
    
Template.profile_layout.onCreated ->
    @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username

Template.profile_layout.onRendered ->
    # Meteor.setTimeout ->
    #     $('.no_blink')
    #         .popup()
    # , 1000
    user = Meteor.users.findOne(username:Router.current().params.username)
    # Meteor.setTimeout ->
    #     if user
    #         Meteor.call 'calc_user_stats', user._id, ->
    #         Meteor.call 'log_user_view', user._id, ->
    # , 2000


Template.profile_layout.helpers
    route_slug: -> "user_#{@slug}"
    user: -> Meteor.users.findOne username:Router.current().params.username
    user_comment_count: -> Counts.get 'user_comment_count'
    user_post_count: -> Counts.get 'user_post_count'

Template.profile_layout.events

    'click a.select_term': ->
        $('.profile_yield')
            .transition('fade out', 200)
            .transition('fade in', 200)
    'click .click_group': (e,t)->
        # $('.label')
        #     .transition('fade out', 200)
        Router.go "/g/#{@name}"
    'keyup .goto_group': (e,t)->
        if e.which is 13
            val = $('.goto_group').val()
            found_group =
                Docs.findOne 
                    model:'group_bookmark'
                    name:val
            if found_group
                Docs.update found_group._id,
                    $inc:search_amount:1
            else
                Docs.insert 
                    model:'group_bookmark'
                    search_amount:1
                    name:val
            # $('.header')
            #     .transition('scale', 200)
            # $('.global_container')
            #     .transition('scale', 400)
            Router.go "/g/#{val}"
            # target_user = Meteor.users.findOne(username:Router.current().params.username)
            # Docs.insert
            #     model:'debit'
            #     body: val
            #     target_user_id: target_user._id
    'click .remove_group': ->
        if confirm 'remove group?'
            Docs.remove @_id
    # 'click .goto_users': ->
    #     $('.global_container')
    #         .transition('fade right', 500)
    #         # .transition('fade in', 200)
    #     Meteor.setTimeout ->
    #         Router.go '/users'
    #     , 500


    'click .refresh_user_stats': ->
        user = Meteor.users.findOne(username:Router.current().params.username)
        # Meteor.call 'calc_user_stats', user._id, ->
        Meteor.call 'calc_user_stats', user._id, ->
        Meteor.call 'calc_user_tags', user._id, ->

    'click .send': ->
        user = Meteor.users.findOne(username:Router.current().params.username)
        if Meteor.userId() is user._id
            new_debit_id =
                Docs.insert
                    model:'debit'
                    amount:1
        else
            new_debit_id =
                Docs.insert
                    model:'debit'
                    amount:1
                    target_id: user._id
        Router.go "/debit/#{new_debit_id}/edit"


    'click .tip': ->
        # user = Meteor.users.findOne(username:@username)
        new_debit_id =
            Docs.insert
                model:'debit'
        Router.go "/debit/#{new_debit_id}/edit"


    # 'click .recalc_user_cloud': ->
    #     Meteor.call 'recalc_user_cloud', Router.current().params.username, ->

    'click .logout': ->
        # Router.go '/login'
        Session.set 'logging_out', true
        Meteor.logout ->
            Session.set 'logging_out', false





