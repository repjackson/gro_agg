if Meteor.isClient
    Router.route '/ruser/:username', (->
        @layout 'layout'
        @render 'ruser'
        ), name:'ruser'

   
    Template.ruser.onCreated ->
        @autorun => Meteor.subscribe 'ruser_doc', Router.current().params.username
        @autorun => Meteor.subscribe 'rposts', Router.current().params.username, 42
        @autorun => Meteor.subscribe 'ruser_comments', Router.current().params.username
        @autorun => Meteor.subscribe 'ruser_result_tags',
            'rpost'
            Router.current().params.username
            selected_subreddit_tags.array()
            # selected_subreddit_domain.array()
            Session.get('toggle')
        @autorun => Meteor.subscribe 'ruser_result_tags',
            'rcomment'
            Router.current().params.username
            selected_subreddit_tags.array()
            # selected_subreddit_domain.array()
            Session.get('toggle')

    Template.ruser.onRendered ->
        Meteor.call 'get_user_comments', Router.current().params.username, ->
        Meteor.setTimeout =>
            Meteor.call 'get_user_info', Router.current().params.username, ->
                Meteor.call 'get_user_posts', Router.current().params.username, ->
                    Meteor.call 'ruser_omega', Router.current().params.username, ->
                        Meteor.call 'rank_ruser', Router.current().params.username, ->
        , 2000

    Template.ruser_doc_item.onRendered ->
        # console.log @
        unless @data.watson
            Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
 
    Template.ruser_comment.onRendered ->
        unless @data.watson
            # console.log 'calling watson on comment'
            Meteor.call 'call_watson', @data._id,'data.body','comment',->
        unless @data.time_tags
            # console.log 'calling watson on comment'
            Meteor.call 'tagify_time_rpost', @data._id,->
    Template.ruser_post.onRendered ->
        unless @data.watson
            # console.log 'calling watson on comment'
            Meteor.call 'call_watson', @data._id,'data.body','comment',->
        unless @data.time_tags
            # console.log 'calling watson on comment'
            Meteor.call 'tagify_time_rpost', @data._id,->

    Template.ruser.helpers
        ruser_post_tag_results: -> results.find(model:'rpost_result_tag')
        ruser_comment_tag_results: -> results.find(model:'rcomment_result_tag')
    Template.ruser.events
        'click .get_user_info': ->
            Meteor.call 'get_user_info', Router.current().params.username, ->
        'click .search_tag': -> 
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            selected_ruser_tags.clear()
            selected_ruser_tags.push @valueOf()
            Router.go "/rusers"

        'click .get_user_posts': ->
            Meteor.call 'get_user_posts', Router.current().params.username, ->
            Meteor.call 'ruser_omega', Router.current().params.username, ->
            Meteor.call 'rank_ruser', Router.current().params.username, ->

        'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
        'click .toggle_question_detail': (e,t)-> Session.set('view_question_detail',!Session.get('view_question_detail'))

        'click .search': ->
            window.speechSynthesis.speak new SpeechSynthesisUtterance "import #{Router.current().params.username}"
            Meteor.call 'search_ruser', Router.current().params.username, ->
        

    
if Meteor.isServer
    Meteor.publish 'ruser_doc', (username)->
        Docs.find 
            model:'ruser'
            username:username
    
    Meteor.publish 'rposts', (username, limit=42)->
        Docs.find {
            model:'rpost'
            author:username
        },{
            limit:limit
            sort:
                _timestamp:-1
        }  
    Meteor.publish 'ruser_comments', (username, limit=42)->
        Docs.find
            model:'rcomment'
            author:username
        , limit:limit