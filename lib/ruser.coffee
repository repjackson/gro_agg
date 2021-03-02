if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'ruser'
        @render 'ruser_overview'
        ), name:'ruser_overview'
    Router.route '/user/:username/posts', (->
        @layout 'ruser'
        @render 'ruser_posts'
        ), name:'ruser_posts'
    Router.route '/user/:username/comments', (->
        @layout 'ruser'
        @render 'ruser_comments'
        ), name:'ruser_comments'
    Router.route '/user/:username/upvoted', (->
        @layout 'ruser'
        @render 'ruser_upvoted'
        ), name:'ruser_upvoted'
    Router.route '/user/:username/downvoted', (->
        @layout 'ruser'
        @render 'ruser_downvoted'
        ), name:'ruser_downvoted'
    Router.route '/user/:username/hidden', (->
        @layout 'ruser'
        @render 'ruser_hidden'
        ), name:'ruser_hidden'
    Router.route '/user/:username/saved', (->
        @layout 'ruser'
        @render 'ruser_saved'
        ), name:'ruser_saved'

    Template.ruser_comments.onCreated ->
        @autorun => Meteor.subscribe 'ruser_doc', Router.current().params.username
        @autorun => Meteor.subscribe 'ruser_comments', Router.current().params.username
  
    Template.registerHelper 'ruser_posts', ()->
        Docs.find
            model:'rpost'
            # author:Router.current().params.username
        
    

    Template.ruser.onCreated ->
        @autorun => Meteor.subscribe 'ruser_doc', Router.current().params.username
    Template.ruser_overview.onCreated ->
        @autorun => Meteor.subscribe 'rposts', Router.current().params.username, 10
        @autorun => Meteor.subscribe 'ruser_comments', Router.current().params.username
        @autorun => Meteor.subscribe 'ruser_result_tags',
            'rpost'
            Router.current().params.username
            picked_subreddit_tags.array()
            # picked_subreddit_domain.array()
            Session.get('toggle')
        @autorun => Meteor.subscribe 'ruser_result_tags',
            'rcomment'
            Router.current().params.username
            picked_subreddit_tags.array()
            # picked_subreddit_domain.array()
            Session.get('toggle')

    Template.ruser.onRendered ->
        Meteor.setTimeout =>
            Meteor.call 'get_user_info', Router.current().params.username, ->
                Meteor.call 'get_user_posts', Router.current().params.username, ->
                    Meteor.call 'ruser_omega', Router.current().params.username, ->
                        Meteor.call 'rank_ruser', Router.current().params.username, ->
        , 2000

    # Template.user_q_item.onRendered ->
    #     unless @data.watson
    #         Meteor.call 'call_watson', @data._id,'link','stack',->
        
        
    Template.ruser.helpers
    Template.ruser_posts.helpers
        user_comments: ->
            Docs.find
                model:'rcomment'
                # subreddit:Router.current().params.subreddit
                # "data.author":Router.current().params.username
        # ruser_posts: ->
        #     Docs.find
        #         model:'rpost'
        #         # subreddit:Router.current().params.subreddit
        #         # "data.author":Router.current().params.username
    Template.ruser_doc_item.onRendered ->
        # console.log @
        unless @data.watson
            Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
 
    Template.ruser_comment.onRendered ->
        unless @data.watson
            # console.log 'calling watson on comment'
            Meteor.call 'call_watson', @data._id,'data.body','comment',->
    Template.ruser_post.onRendered ->
        unless @data.watson
            # console.log 'calling watson on comment'
            Meteor.call 'call_watson', @data._id,'data.body','comment',->

    # Template.answer_item.onCreated ->
    #     @autorun => Meteor.subscribe 'question_from_id', @data.question_id
        
    # Template.answer_item.helpers
    #     answer_question: ->
    #         Docs.findOne
    #             model:'stack_question'
    #             question_id:@question_id
    
    Template.ruser_overview.onRendered ->
        Meteor.call 'get_user_comments', Router.current().params.username, ->
    Template.ruser_overview.helpers
        ruser_post_tag_results: ->
            results.find(model:'rpost_result_tag')
        ruser_comment_tag_results: ->
            results.find(model:'rcomment_result_tag')
    Template.ruser.helpers
        ruser_doc: ->
            Docs.findOne 
                model:'ruser'
                username:Router.current().params.username

    Template.ruser.events
        'click .get_user_info': ->
            Meteor.call 'get_user_info', Router.current().params.username, ->
        
        'click .get_user_posts': ->
            console.log 'click'
            Meteor.call 'get_user_posts', Router.current().params.username, ->
            # Meteor.call 'ruser_omega', Router.current().params.username, ->
            # Meteor.call 'rank_ruser', Router.current().params.username, ->

        # 'click .set_location': ->
        #     Session.set('location_query',@location)
        #     window.speechSynthesis.speak new SpeechSynthesisUtterance "#{Router.current().params.subreddit} users in #{@location}"
        #     Router.go "/s/#{Router.current().params.subreddit}/users"

        'click .toggle_detail': (e,t)-> 
            Session.set('view_detail',!Session.get('view_detail'))
        'click .toggle_question_detail': (e,t)-> 
            Session.set('view_question_detail',!Session.get('view_question_detail'))

        # 'click .say_subreddit': (e,t)->
        #     window.speechSynthesis.speak new SpeechSynthesisUtterance Router.current().params.subreddit
        # 'click .say_users': (e,t)->
        #     window.speechSynthesis.speak new SpeechSynthesisUtterance "#{Router.current().params.subreddit} users"
        # 'click .say_questions': (e,t)->
        #     window.speechSynthesis.speak new SpeechSynthesisUtterance "#{Router.current().params.subreddit} questions"
        # 'click .say_title': (e,t)->
        #     window.speechSynthesis.speak new SpeechSynthesisUtterance @title

        'click .search': ->
            window.speechSynthesis.speak new SpeechSynthesisUtterance "import #{Router.current().params.username}"
            Meteor.call 'search_ruser', Router.current().params.username, ->
        'click .get_answers': ->
            Meteor.call 'ruser_answers', Router.current().params.subreddit, Router.current().params.username, ->
        'click .get_questions': ->
            Meteor.call 'ruser_questions', Router.current().params.subreddit, Router.current().params.username, ->
        'click .get_comments': ->
            Meteor.call 'ruser_comments', Router.current().params.subreddit, Router.current().params.username, ->
        'click .get_badges': ->
            Meteor.call 'ruser_badges', Router.current().params.subreddit, Router.current().params.username, ->
        'click .get_tags': ->
            Meteor.call 'ruser_tags', Router.current().params.subreddit, Router.current().params.username, ->
                
        

    
if Meteor.isServer
    Meteor.publish 'ruser_doc', (username)->
        Docs.find 
            model:'ruser'
            username:username
    
#     Meteor.publish 'ruser_badges', (subreddit,user_id)->
#         Docs.find { 
#             model:'stack_badge'
#             "user.user_id":parseInt(user_id)
#         }, limit:10
    # Meteor.publish 'ruser_comments', (subreddit,user_id)->
    #     Docs.find { 
    #         model:'rcomment'
    #         # "owner.user_id":parseInt(user_id)
    #     }, limit:10
        
        
    Meteor.publish 'rposts', (username, limit=20)->
        Docs.find
            model:'rpost'
            author:username
        , limit:limit
            
    Meteor.publish 'ruser_comments', (username, limit=20)->
        Docs.find
            model:'rcomment'
            author:username
        , limit:limit
        
            
            