if Meteor.isClient
    Template.user_dashboard.onCreated ->
        # @autorun -> Meteor.subscribe 'user_credits', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_debits', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_requests', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_completed_requests', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_event_tickets', Router.current().params.username
        # @autorun -> Meteor.subscribe 'model_docs', 'event'
        @autorun -> Meteor.subscribe 'model_docs', 'log_event'
        
    Template.user_dashboard.events
        'click .user_credit_segment': ->
            Router.go "/debit/#{@_id}/view"
            
        'click .user_debit_segment': ->
            Router.go "/debit/#{@_id}/view"
 
        'keyup .add_post': (e,t)->
            if e.which is 13
                body = $('.add_post').val()
                console.log body
                
                Docs.insert 
                    model:'post'
                    body:body
                $('.add_post').val('')
                
        'click .remove_post': (e,t)->
            if confirm 'delete post?'
                Docs.remove @_id
            
            
    Template.user_dashboard.helpers
        log_events: ->
            Docs.find 
                model:'log_event'
                # _author_id: Meteor.userId()

        latest_posts: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'post'
                _author_id: current_user._id
            }, 
                limit: 10
                sort: _timestamp:-1
        latest_thoughts: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'thought'
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
                model:'debit'
                recipient_id: current_user._id
            }, 
                sort: _timestamp:-1
                limit: 10

        user_requests: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'request'
                _author_id: current_user._id
            }, 
                sort: _timestamp:-1
                limit: 10

        user_completed_requests: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'request'
                completed_by_user_id: current_user._id
            }, 
                sort: _timestamp:-1
                limit: 10

        user_event_tickets: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transaction'
                transaction_type:'ticket_purchase'
            }, 
                sort: _timestamp:-1
                limit: 10


if Meteor.isServer
    Meteor.publish 'user_debits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'debit'
            _author_id:user._id
        },{
            limit:20
            sort: _timestamp:-1
        })
        
        
    # Meteor.publish 'user_requests', (username)->
    #     user = Meteor.users.findOne username:username
    #     Docs.find({
    #         model:'request'
    #         completed_by_user_id:user._id
    #     },{
    #         limit:20
    #         sort: _timestamp:-1
    #     })
        
    Meteor.publish 'user_event_tickets', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'transaction'
            transaction_type:'ticket_purchase'
            _author_id:user._id
        },{
            limit:20
            sort: _timestamp:-1
        })
        
        
        
        