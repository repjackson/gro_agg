if Meteor.isClient
    Router.route '/site/:site/user/:user_id', (->
        @layout 'suser_layout'
        @render 'suser_dashboard'
        ), name:'suser_dashboard'

    Router.route '/site/:site/user/:user_id/questions', (->
        @layout 'suser_layout'
        @render 'suser_questions'
        ), name:'suser_questions'

    Router.route '/site/:site/user/:user_id/answers', (->
        @layout 'suser_layout'
        @render 'suser_answers'
        ), name:'suser_answers'

    Router.route '/site/:site/user/:user_id/comments', (->
        @layout 'suser_layout'
        @render 'suser_comments'
        ), name:'suser_comments'
    Template.suser_comments.onCreated ->
        @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'suser_comments', Router.current().params.site, Router.current().params.user_id

    Router.route '/site/:site/user/:user_id/badges', (->
        @layout 'suser_layout'
        @render 'suser_badges'
        ), name:'suser_badges'

    Router.route '/site/:site/user/:user_id/tags', (->
        @layout 'suser_layout'
        @render 'suser_tags'
        ), name:'suser_tags'

    Template.suser_layout.onCreated ->
        @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
    Template.suser_dashboard.onCreated ->
        @autorun => Meteor.subscribe 'user_badges', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'suser_tags', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'suser_comments', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'suser_questions', Router.current().params.site, Router.current().params.user_id
        @autorun => Meteor.subscribe 'suser_answers', Router.current().params.site, Router.current().params.user_id
    Template.suser_layout.onRendered ->
        Meteor.call 'search_stackuser', Router.current().params.site, Router.current().params.user_id, ->
        Meteor.call 'get_suser_answers', Router.current().params.site, Router.current().params.user_id, ->
        Meteor.call 'get_suser_questions', Router.current().params.site, Router.current().params.user_id, ->
        # Meteor.call 'get_suser_tags', Router.current().params.site, Router.current().params.user_id, ->
        Meteor.call 'get_suser_comments', Router.current().params.site, Router.current().params.user_id, ->
        # Meteor.call 'get_suser_badges', Router.current().params.site, Router.current().params.user_id, ->
        # Meteor.setTimeout ->
        #     Meteor.call 'omega', Router.current().params.site, Router.current().params.user_id, ->
        # , 1000
    Template.suser_dashboard.onRendered ->
        suser = 
            Docs.findOne 
                model:'stackuser'
                site:Router.current().params.site
                user_id:parseInt(Router.current().params.user_id)
        Meteor.call 'log_view', suser._id, ->

    Template.user_question_item.onRendered ->
        unless @data.watson
            Meteor.call 'call_watson', @data._id,'link','stack',->
            # window.speechSynthesis.speak new SpeechSynthesisUtterance "dao"

    Template.user_comment_item.events
        'click .call': (e,t)-> 
            # console.log 'hi'
            window.speechSynthesis.speak new SpeechSynthesisUtterance "anlyzing emotion"
            Meteor.call 'call_watson',@_id,'body','text', (err,res)=>
                # console.log res
                # if @max_emotion_name
                #     window.speechSynthesis.speak new SpeechSynthesisUtterance @max_emotion_name
            # Meteor.setTimeout ->
            # , 2000


    Template.suser_comments.helpers
        stackuser_doc: ->
            Docs.findOne 
                model:'stackuser'
                site:Router.current().params.site
                user_id:parseInt(Router.current().params.user_id)
        user_comments: ->
            cur = Docs.find
                model:'stack_comment'
                "owner.user_id":parseInt(Router.current().params.user_id)
                site:Router.current().params.site
            cur
    Template.suser_layout.helpers
        stackuser_doc: ->
            Docs.findOne 
                model:'stackuser'
                site:Router.current().params.site
                user_id:parseInt(Router.current().params.user_id)
    Template.suser_dashboard.helpers
        user_comments: ->
            cur = Docs.find
                model:'stack_comment'
                site:Router.current().params.site
                "owner.user_id":parseInt(Router.current().params.user_id)
            cur
        user_questions: ->
            Docs.find
                model:'stack_question'
                site:Router.current().params.site
                "owner.user_id":parseInt(Router.current().params.user_id)
        user_answers: ->
            Docs.find
                model:'stack_answer'
                site:Router.current().params.site
                "owner.user_id":parseInt(Router.current().params.user_id)
        # user_badges: ->
        #     Docs.find
        #         model:'stack_badge'
        # user_tags: ->
        #     Docs.find
        #         model:'stack_tag'

    Template.answer_item.onCreated ->
        @autorun => Meteor.subscribe 'question_from_id', @data.question_id
        
    Template.answer_item.helpers
        answer_question: ->
            Docs.findOne
                model:'stack_question'
                question_id:@question_id
    
    Template.suser_layout.events
        'click .set_location': ->
            Session.set('location_query',@location)
            # window.speechSynthesis.speak new SpeechSynthesisUtterance "#{Router.current().params.site} users in #{@location}"
            Router.go "/site/#{Router.current().params.site}/users"

        'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
        'click .toggle_question_detail': (e,t)-> Session.set('view_question_detail',!Session.get('view_question_detail'))

        'click .boop': ->
            window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name
            Meteor.call 'omega', Router.current().params.site, Router.current().params.user_id, ->
            Meteor.call 'rank_user', Router.current().params.site, Router.current().params.user_id, ->
            # Meteor.call 'boop', Router.current().params.site, Router.current().params.user_id, ->
        'click .agg': ->
            Meteor.call 'omega', Router.current().params.site, Router.current().params.user_id, ->
        
        # 'click .say_site': (e,t)->
        #     window.speechSynthesis.speak new SpeechSynthesisUtterance Router.current().params.site
        'click .say_users': (e,t)->
            window.speechSynthesis.speak new SpeechSynthesisUtterance "#{Router.current().params.site} users"
        'click .say_questions': (e,t)->
            window.speechSynthesis.speak new SpeechSynthesisUtterance "#{Router.current().params.site} questions"
        # 'click .say_title': (e,t)->
        #     window.speechSynthesis.speak new SpeechSynthesisUtterance @title

        'click .search': ->
            window.speechSynthesis.speak new SpeechSynthesisUtterance "import #{Router.current().params.site} user"
            Meteor.call 'search_stackuser', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_answers': ->
            Meteor.call 'get_suser_answers', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_questions': ->
            Meteor.call 'get_suser_questions', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_comments': ->
            Meteor.call 'get_suser_comments', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_badges': ->
            Meteor.call 'get_suser_badges', Router.current().params.site, Router.current().params.user_id, ->
        'click .get_tags': ->
            Meteor.call 'get_suser_tags', Router.current().params.site, Router.current().params.user_id, ->
                
        


Meteor.methods
    boop: (site,user_id)->
        user = 
            Docs.findOne
                model:'stackuser'
                user_id:parseInt(user_id)
                site:site
        if user
            Docs.update user._id,
                $inc:boops:1
        # else
        
        
    
if Meteor.isServer
    Meteor.publish 'question_from_id', (qid)->
        Docs.find 
            # model:'stack_question'
            question_id:qid
    
    Meteor.publish 'suser_badges', (site,user_id)->
        Docs.find { 
            model:'stack_badge'
            user_id:parseInt(user_id)
            site:site
        }, limit:10
    Meteor.publish 'suser_comments', (site,user_id)->
        cur = Docs.find { 
            model:'stack_comment'
            "owner.user_id":parseInt(user_id)
            site:site
        }, limit:100
        cur
    Meteor.publish 'suser_questions', (site,user_id)->
        Docs.find { 
            model:'stack_question'
            "owner.user_id":parseInt(user_id)
            site:site
        }, limit:20
    Meteor.publish 'suser_answers', (site,user_id)->
        Docs.find { 
            model:'stack_answer'
            "owner.user_id":parseInt(user_id)
            site:site
        }, limit:100
    Meteor.publish 'suser_tags', (site,user_id)->
        Docs.find { 
            model:'stack_tag'
            user_id:parseInt(user_id)
            site:site
        }, limit:10
            
            
            