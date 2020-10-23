if Meteor.isClient
    Template.user_dashboard.onCreated ->
        # @autorun -> Meteor.subscribe 'user_credits', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_debits', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_log_events', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_requests', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_completed_requests', Router.current().params.username
        # @autorun -> Meteor.subscribe 'user_event_tickets', Router.current().params.username
        # @autorun -> Meteor.subscribe 'model_docs', 'event'
        @autorun -> Meteor.subscribe 'model_docs', 'reply'
        @autorun -> Meteor.subscribe 'user_questions', Router.current().params.username

    Template.user_dashboard.events
        # 'click .user_credit_segment': ->
        #     Router.go "/debit/#{@_id}/view"
            
        # 'click .user_debit_segment': ->
        #     Router.go "/debit/#{@_id}/view"
 
 
 
        'keyup .add_post': (e,t)->
            if e.which is 13
                body = $('.add_post').val()
                console.log body
                
                Docs.insert 
                    model:'post'
                    body:body
                $('.add_post').val('')
                
            
    Template.user_dashboard.helpers
        questions_asked: ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find 
                model:'question'
                target_user_id:user._id
        asking_question: -> Session.get('asking_question_id') 
        question_asking: -> Docs.findOne Session.get('asking_question_id') 
    
        replies:-> 
            Docs.find 
                model:'reply'
                parent_id:@_id
        replying:-> Session.equals('replying_id', @_id)
        log_events: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find 
                model:'log_event'
                _author_id: current_user._id

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
        
        
        
        