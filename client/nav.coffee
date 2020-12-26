Template.nav.onRendered ->
    Meteor.setTimeout ->
        $('.menu .item')
            .popup()
        $('.ui.left.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'overlay'
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
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_rightbar')
    , 1000

Template.nav.events 
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
    'click .set_shift': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', 'shift', ->
            Session.set 'loading', false
    # 'click .set_request': ->
    #     Session.set 'loading', true
    #     Meteor.call 'set_facets', 'request', ->
    #         Session.set 'loading', false
    # 'click .set_offer': ->
    #     Session.set 'loading', true
    #     Meteor.call 'set_facets', 'offer', ->
    #         Session.set 'loading', false
    # 'click .set_model': ->
    #     Session.set 'loading', true
    #     Meteor.call 'set_facets', 'model', ->
    #         Session.set 'loading', false
    # 'click .set_event': ->
    #     Session.set 'loading', true
    #     Meteor.call 'set_facets', 'event', ->
    #         Session.set 'loading', false
    # 'click .set_location': ->
    #     Session.set 'loading', true
    #     Meteor.call 'set_facets', 'location', ->
    #         Session.set 'loading', false
    # 'click .set_photo': ->
    #     Session.set 'loading', true
    #     Meteor.call 'set_facets', 'photo', ->
    #         Session.set 'loading', false
    # 'click .set_project': ->
    #     Session.set 'loading', true
    #     Meteor.call 'set_facets', 'project', ->
    #         Session.set 'loading', false
    # 'click .set_expense': ->
    #     Session.set 'loading', true
    #     Meteor.call 'set_facets', 'expense', ->
    #         Session.set 'loading', false
    # 'click .set_post': ->
    #     Session.set 'loading', true
    #     Meteor.call 'set_facets', 'post', ->
    #         Session.set 'loading', false
    'click .add_gift': ->
        # user = Meteor.users.findOne(username:@username)
        new_gift_id =
            Docs.insert
                model:'gift'
                recipient_id: @_id
        Router.go "/debit/#{new_gift_id}/edit"
    
    'click .add': ->
        # user = Meteor.users.findOne(username:@username)
        new_post_id =
            Docs.insert
                model:'post'
        Router.go "/post/#{new_post_id}/edit"

    'click .add_request': ->
        # user = Meteor.users.findOne(username:@username)
        new_id =
            Docs.insert
                model:'request'
                recipient_id: @_id
        Router.go "/request/#{new_id}/edit"


    'click .view_profile': ->
        Meteor.call 'calc_user_points', Meteor.userId()
