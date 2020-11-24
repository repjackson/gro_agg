Router.route '/s/:site/u/:user_id', (->
    @layout 'suser_layout'
    @render 'suser_dashboard'
    ), name:'suser_dashboard'

Router.route '/s/:site/u/:user_id/questions', (->
    @layout 'suser_layout'
    @render 'suser_questions'
    ), name:'suser_questions'
Template.suser_questions.onCreated ->
    @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_questions', Router.current().params.site, Router.current().params.user_id

Router.route '/s/:site/u/:user_id/answers', (->
    @layout 'suser_layout'
    @render 'suser_a'
    ), name:'suser_a'
Template.suser_a.onCreated ->
    @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_a', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_a_tags', 
        Router.current().params.site, 
        Router.current().params.user_id
        selected_tags.array()
Template.suser_a.helpers
    stackuser_doc: ->
        Docs.findOne 
            model:'stackuser'
            site:Router.current().params.site
            user_id:parseInt(Router.current().params.user_id)
    user_answers: ->
        cur = Docs.find
            model:'stack_answer'
            "owner.user_id":parseInt(Router.current().params.user_id)
            site:Router.current().params.site
        cur
    suser_a_tags: -> results.find(model:'suser_a_tags')

Template.suser_a.events
    'click .select_location': -> selected_locations.push @name
    
    'click .unselect_location': -> selected_locations.remove @valueOf()



Router.route '/s/:site/u/:user_id/badges', (->
    @layout 'suser_layout'
    @render 'suser_badges'
    ), name:'suser_badges'
Template.suser_badges.onCreated ->
    @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_badges', Router.current().params.site, Router.current().params.user_id

Router.route '/s/:site/u/:user_id/tags', (->
    @layout 'suser_layout'
    @render 'suser_tags'
    ), name:'suser_tags'
Template.suser_tags.onCreated ->
    @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_tags', Router.current().params.site, Router.current().params.user_id

Template.suser_layout.onCreated ->
    @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
Template.suser_dashboard.onCreated ->
    # console.log 'hi'
    @autorun => Meteor.subscribe 'suser_badges', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_tags', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_comments', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_questions', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_a', Router.current().params.site, Router.current().params.user_id
Template.suser_layout.onRendered ->
    Meteor.call 'search_stackuser', Router.current().params.site, Router.current().params.user_id, ->
    Meteor.call 'get_suser_a', Router.current().params.site, Router.current().params.user_id, ->
    Meteor.call 'get_suser_questions', Router.current().params.site, Router.current().params.user_id, ->
    # Meteor.call 'get_suser_tags', Router.current().params.site, Router.current().params.user_id, ->
    Meteor.call 'get_suser_comments', Router.current().params.site, Router.current().params.user_id, ->
    # Meteor.call 'get_suser_badges', Router.current().params.site, Router.current().params.user_id, ->
    Meteor.setTimeout ->
        Meteor.call 'omega', Router.current().params.site, Router.current().params.user_id, ->
    , 1000
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
        window.speechSynthesis.speak new SpeechSynthesisUtterance "anlyzing"
        Meteor.call 'call_watson',@_id,'body','text', (err,res)=>

Template.user_answer_item.events
    'click .call': (e,t)-> 
        # console.log 'hi'
        window.speechSynthesis.speak new SpeechSynthesisUtterance "anlyzing"
        Meteor.call 'call_watson',@_id,'body','html', (err,res)=>
Template.answer_item.events
    'click .call': (e,t)-> 
        # console.log 'hi'
        window.speechSynthesis.speak new SpeechSynthesisUtterance "anlyzing"
        Meteor.call 'call_watson',@_id,'body','html', (err,res)=>


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

Template.user_answer_item.onCreated ->
    @autorun => Meteor.subscribe 'question_from_id', @data.question_id
    
Template.user_answer_item.helpers
    answer_question: ->
        Docs.findOne
            model:'stack_question'
            question_id:@question_id

Template.suser_layout.events
    'click .set_location': ->
        Session.set('location_query',@location)
        # window.speechSynthesis.speak new SpeechSynthesisUtterance "#{Router.current().params.site} users in #{@location}"
        Router.go "/s/#{Router.current().params.site}/users"


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
        Meteor.call 'get_suser_a', Router.current().params.site, Router.current().params.user_id, ->
    'click .get_questions': ->
        Meteor.call 'get_suser_questions', Router.current().params.site, Router.current().params.user_id, ->
    'click .get_comments': ->
        Meteor.call 'get_suser_comments', Router.current().params.site, Router.current().params.user_id, ->
    'click .get_badges': ->
        Meteor.call 'get_suser_badges', Router.current().params.site, Router.current().params.user_id, ->
    'click .get_tags': ->
        Meteor.call 'get_suser_tags', Router.current().params.site, Router.current().params.user_id, ->
            
           
Template.suser_dashboard.events
    'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
    'click .tog_qtags': (e,t)-> Session.set('view_qtags',!Session.get('view_qtags'))
           
           
            
            
Router.route '/s/:site/u/:user_id/comments', (->
    @layout 'suser_layout'
    @render 'suser_comments'
    ), name:'suser_comments'
Template.suser_comments.onCreated ->
    @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_comments', Router.current().params.site, Router.current().params.user_id
Template.suser_comments.onRendered ->
    Meteor.call 'get_suser_comments', Router.current().params.site, Router.current().params.user_id, ->
Template.suser_comments.helpers
    user_comments: ->
        cur = Docs.find
            model:'stack_comment'
            "owner.user_id":parseInt(Router.current().params.user_id)
            site:Router.current().params.site
        cur