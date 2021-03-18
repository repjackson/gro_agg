Router.route '/ruser/:username', (->
    @layout 'layout'
    @render 'ruser'
    ), name:'ruser'


Template.ruser.onCreated ->
    @autorun => Meteor.subscribe 'user_doc', Router.current().params.username, ->
Template.ruser_posts.onCreated ->
    @autorun => Meteor.subscribe 'user_posts', Router.current().params.username, 42, ->
    @autorun => Meteor.subscribe 'user_result_tags',
        'rpost'
        Router.current().params.username
        picked_sub_tags.array()
        # selected_subreddit_domain.array()
        Session.get('toggle')
        , ->
Template.ruser_comments.onCreated ->
    @autorun => Meteor.subscribe 'user_comments', Router.current().params.username, ->
    @autorun => Meteor.subscribe 'user_result_tags',
        'rcomment'
        Router.current().params.username
        picked_sub_tags.array()
        # selected_subreddit_domain.array()
        Session.get('toggle')
        , ->
Template.ruser_comments.onCreated ->

Template.ruser.events
    # Meteor.setTimeout =>
    'click .refresh_info': ->
        $('body').toast(
            showIcon: 'user'
            message: 'getting user info'
            displayTime: 'auto',
        )
        Meteor.call 'get_user_info', Router.current().params.username, ->
            $('body').toast(
                message: 'info retrieved'
                showIcon: 'user'
                showProgress: 'bottom'
                class: 'info'
                displayTime: 'auto',
            )
            Session.set('thinking',false)
Template.ruser_comments.events
    'click .refresh_comments': ->
        $('body').toast(
            showIcon: 'chat'
            message: 'getting comments'
            displayTime: 'auto',
        )
        Meteor.call 'get_user_comments', Router.current().params.username, ->
            $('body').toast(
                message: 'comments done'
                showIcon: 'chat'
                showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
            )
            Session.set('thinking',false)

Template.ruser_doc_item.onRendered ->
    # console.log @
    # unless @data.watson
    #     Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>

Template.ruser_comment.events
    'click .call_watson_comment': ->
        # console.log 'call', 
        Meteor.call 'call_watson', @_id,'data.body','comment',->
        
Template.ruser_comment.onRendered ->
    # unless @data.watson
    #     # console.log 'calling watson on comment'
    #     Meteor.call 'call_watson', @data._id,'data.body','comment',->
Template.ruser_post.onRendered ->
    # unless @data.watson
    #     # console.log 'calling watson on comment'
    #     Meteor.call 'call_watson', @data._id,'data.body','comment',->

Template.ruser.events
    'click .refresh_stats': ->
        Meteor.setTimeout =>
            $('body').toast(
                showIcon: 'dna'
                message: 'calculating stats'
                displayTime: 'auto',
            )
            Meteor.call 'user_omega', Router.current().params.username, ->
                $('body').toast(
                    message: 'stats calculated'
                    showIcon: 'dna'
                    showProgress: 'bottom'
                    class: 'success'
                    displayTime: 'auto',
                )
                Session.set('thinking',false)
       


Template.ruser.helpers
    user_doc: ->
        Docs.findOne
            model:'user'
            username:Router.current().params.username
    current_username: -> Router.current().params.username
Template.ruser_posts.events
    'click .refresh_posts': ->
        $('body').toast(
            showIcon: 'edit'
            message: 'getting user posts'
            displayTime: 'auto',
        )
        Meteor.call 'get_user_posts', Router.current().params.username, ->
            $('body').toast(
                message: 'posts downloaded'
                showIcon: 'user'
                showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
            )
            Session.set('thinking',false)
      


        
Template.ruser_posts.helpers
    user_post_docs: ->
        Docs.find {
            model:'rpost'
            author:Router.current().params.username
        },{
            limit:20
            sort:
                _timestamp:-1
        }  
    user_post_tag_results: -> results.find(model:'rpost_result_tag')
Template.ruser_comments.helpers
    user_comment_docs: ->
        Docs.find
            model:'rcomment'
            author:Router.current().params.username
        , limit:20
    user_comment_tag_results: -> results.find(model:'rcomment_result_tag')
Template.ruser.events
    'click .search_tag': -> 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        picked_user_tags.clear()
        picked_user_tags.push @valueOf()
        Router.go "/users"


    'click .refresh_rank': ->
        $('body').toast(
            showIcon: 'line chart'
            message: 'ranking user'
            displayTime: 'auto',
        )
        Meteor.call 'rank_user', Router.current().params.username, ->
            $('body').toast(
                message: 'user ranked'
                showIcon: 'line chart'
                showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
            )
            Session.set('thinking',false)

    # 'click .get_user_posts': ->
    #     Meteor.call 'get_user_posts', Router.current().params.username, ->
    #     Meteor.call 'user_omega', Router.current().params.username, ->
    #     Meteor.call 'rank_user', Router.current().params.username, ->

    'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
    'click .toggle_question_detail': (e,t)-> Session.set('view_question_detail',!Session.get('view_question_detail'))

    'click .search': ->
        # window.speechSynthesis.speak new SpeechSynthesisUtterance "import #{Router.current().params.username}"
        Meteor.call 'search_user', Router.current().params.username, ->
    
