Template.view_chatpop.onCreated ->
    @autorun => Meteor.subscribe 'global_chat'
Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'
    # @autorun => Meteor.subscribe 'all_users'
    @autorun => Meteor.subscribe 'my_unread_messages'

Template.nav.onRendered ->
    Meteor.setTimeout ->
        $('.ui.dropdown').dropdown()
    , 2000
    # count = 0
    # cursor = Docs.find({ model: 'message', read: false });
    # console.log 'found messages', cursor.count()
    # handle = cursor.observeChanges({
    #     added: (id, message)->
    #         count += 1
    #         # console.log("#{message.body} brings the total to #{count} admins.")
    #         $('body').toast(
    #             message: "message: #{message.body}"
    #             showIcon: 'mail'
    #             classImage: 'avatar',
    #             showProgress: 'bottom'
    #             class: 'success'
    #             displayTime: 'auto',
    #         )
    # })

Template.nav.events
    #     'click .logout': ->
    #         Session.set 'logging_out', true
    #         Meteor.logout ->
    #             Session.set 'logging_out', false
    #             Router.go '/login'
    
    'click .toggle_nightmode': ->
        if Meteor.user().invert_class is 'invert'
            Meteor.users.update Meteor.userId(),
                $set:invert_class:''
        else
            Meteor.users.update Meteor.userId(),
                $set:invert_class:'invert'

    'click .new_message': ->
        Docs.insert 
            model:'message'
            read:false
            body:'hi there'


    'click .toggle_admin': ->
        if 'admin' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'admin'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'admin'

    'click .home': -> Router.go '/'
    'click .reconnect': -> Meteor.reconnect()

    'click .add': ->
        new_question_id =
            Docs.insert
                model:'question'
        Router.go "/question/#{new_question_id}/edit"

    'click .post': ->
        new_post_id =
            Docs.insert
                model:'post'
                source:'self'
                # buyer_id:Meteor.userId()
                # buyer_username:Meteor.user().username
        Router.go "/m/post/#{new_post_id}/edit"
    'click .alerts': ->
        Session.set('viewing_alerts', !Session.get('viewing_alerts'))
    'click .toggle_friends': ->
        Session.set('viewing_friends', !Session.get('viewing_friends'))
        
    'click .toggle_admin': ->
        if 'admin' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'admin'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'admin'
    'click .toggle_dev': ->
        if 'dev' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'dev'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'dev'
    'click .set_member': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'member', ->
            Session.set 'loading', false
    'click .set_tribe': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'tribe', ->
            Session.set 'loading', false
    'click .set_request': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'request', ->
            Session.set 'loading', false
    'click .set_offer': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'offer', ->
            Session.set 'loading', false
    'click .set_model': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'model', ->
            Session.set 'loading', false
    'click .set_event': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'event', ->
            Session.set 'loading', false
    'click .set_location': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'location', ->
            Session.set 'loading', false
    'click .set_photo': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'photo', ->
            Session.set 'loading', false
    'click .set_project': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'project', ->
            Session.set 'loading', false
    'click .set_expense': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'expense', ->
            Session.set 'loading', false
    'click .set_post': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'post', ->
            Session.set 'loading', false
    'click .add_gift': ->
        # user = Meteor.users.findOne(username:@username)
        new_gift_id =
            Docs.insert
                model:'gift'
                recipient_id: @_id
        Router.go "/debit/#{new_gift_id}/edit"

    'click .add_request': ->
        # user = Meteor.users.findOne(username:@username)
        new_id =
            Docs.insert
                model:'request'
                recipient_id: @_id
        Router.go "/request/#{new_id}/edit"


    'click .view_profile': ->
        Meteor.call 'calc_user_points', Meteor.userId()
        



Template.nav.onRendered ->
    Meteor.setTimeout ->
        $('.menu .item')
            .popup()
        $('.ui.left.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'overlay'
                dimmer:false
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_leftbar')
    , 1000
    Meteor.setTimeout ->
        $('.ui.right.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'overlay'
                exclusive:true
                dimmer:false
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_rightbar')
    , 1000

Template.chatpop.events
    'click .open_chat': -> Session.set('viewing_chat',true)
    'click .close_chat': -> Session.set('viewing_chat',false)
Template.chatpop.helpers
    viewing_chat: -> Session.get('viewing_chat')
Template.view_chatpop.helpers
    last_messages: ->
        Docs.find {
            model:'global_chat'
        }, 
            sort:_timestamp:-1
            limit:10
Template.chatpop.events
    # 'keyup .add_chat': _.throttle((e,t)->
    'keyup .add_chat': (e,t)->
        if e.which is 13
            console.log 'hi'
            comment = t.$('.add_chat').val()
            Docs.insert
                # parent_id: parent._id
                model:'global_chat'
                bot:false
                body:comment
            Meteor.call 'add_chat', comment, ->
            t.$('.add_chat').val('')
        # , 2000)
Template.rightbar.events
    'click .logout': ->
        Session.set 'logging_out', true
        Meteor.logout ->
            Session.set 'logging_out', false
            Router.go '/login'
            
    'click .toggle_nightmode': ->
        if Meteor.user().invert_class is 'invert'
            Meteor.users.update Meteor.userId(),
                $set:invert_class:''
        else
            Meteor.users.update Meteor.userId(),
                $set:invert_class:'invert'
            

Template.footer.helpers
    connect_status: -> 
        # console.log Meteor.status()
        Meteor.status()
Template.nav.helpers
    alert_toggle_class: ->
        if Session.get('viewing_alerts') then 'active' else ''
    current_tribe: () ->
        if Meteor.user()
            Docs.findOne 
                _id:Meteor.user().current_tribe_id
        
Template.nav.events
        
Template.topbar.onCreated ->
    @autorun => Meteor.subscribe 'my_received_messages'
    @autorun => Meteor.subscribe 'my_sent_messages'
Template.friendbar.onCreated ->
    # @autorun => Meteor.subscribe 'user_friends', Meteor.user().username
    @autorun => Meteor.subscribe 'my_friends'

Template.nav.helpers
    unread_count: ->
        Docs.find( 
            model:'message'
            read:false
            # recipient_id:Meteor.userId()
            # read_ids:$nin:[Meteor.userId()]
        ).count()
Template.topbar.helpers
    recent_alerts: ->
        Docs.find 
            model:'message'
            read:false
            # recipient_id:Meteor.userId()
            # read_ids:$nin:[Meteor.userId()]
        , sort:_timestamp:-1
        
Template.recent_alert.events
    'click .mark_read': (e,t)->
        # console.log @
        # console.log $(e.currentTarget).closest('.alert')
        $(e.currentTarget).closest('.alert').transition('slide left')
        Meteor.call 'mark_read', @_id, ->
            
        # Meteor.setTimeout ->
        # , 500
     
     
        
Template.topbar.events
    'click .close_topbar': ->
        Session.set('viewing_alerts', false)

        
        
Template.leftbar.events
    # 'click .toggle_leftbar': ->
    #     $('.ui.sidebar')
    #         .sidebar('setting', 'transition', 'push')
    #         .sidebar('toggle')
    'click .toggle_admin': ->
        if 'admin' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'admin'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'admin'
    'click .toggle_dev': ->
        if 'dev' in Meteor.user().roles
            Meteor.users.update Meteor.userId(),
                $pull:'roles':'dev'
        else
            Meteor.users.update Meteor.userId(),
                $addToSet:'roles':'dev'
                
    'click .set_member': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'member', ->
            Session.set 'loading', false
    'click .set_photo': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'photo', ->
            Session.set 'loading', false
            
    'click .set_expense': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'expense', ->
            Session.set 'loading', false
    'click .set_location': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'location', ->
            Session.set 'loading', false
    'click .set_project': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'project', ->
            Session.set 'loading', false
    'click .add_gift': ->
        # user = Meteor.users.findOne(username:@username)
        new_gift_id =
            Docs.insert
                model:'gift'
                recipient_id: @_id
        Router.go "/debit/#{new_gift_id}/edit"

    'click .add_request': ->
        # user = Meteor.users.findOne(username:@username)
        new_id =
            Docs.insert
                model:'request'
                recipient_id: @_id
        Router.go "/request/#{new_id}/edit"

        