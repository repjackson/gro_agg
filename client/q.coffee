Router.route '/s/:site/q/:qid', (->
    @layout 'layout'
    @render 'q'
    ), name:'q'


Template.q.onCreated ->
    # @autorun => Meteor.subscribe 'doc', Router.current().params.qid
    @autorun => Meteor.subscribe 'qid', Router.current().params.site, Router.current().params.qid
    @autorun => Meteor.subscribe 'question_answers', Router.current().params.site, Router.current().params.qid
    @autorun => Meteor.subscribe 'q_c', Router.current().params.site, Router.current().params.qid
    @autorun => Meteor.subscribe 'question_doc_id', Router.current().params.site, Router.current().params.qid
    @autorun => Meteor.subscribe 'related_questions', Router.current().params.site, Router.current().params.qid
    @autorun => Meteor.subscribe 'linked_questions', Router.current().params.site, Router.current().params.qid
    Session.setDefault('stack_section','main')

Template.q.onRendered ->
    Meteor.call 'get_question', Router.current().params.site, Router.current().params.qid,->
    Meteor.call 'get_q_a', Router.current().params.site, Router.current().params.qid,->
    # Meteor.call 'call_watson', Router.current().params.qid,'link','stack',->
    Meteor.call 'get_q_c', Router.current().params.site, Router.current().params.qid,->
    # Meteor.setTimeout ->
    #     $('.top').visibility
    #         onTopVisible: (calculations) ->
    #             console.log 'top vis'
    #             # top is on screen
    #         onTopPassed: (calculations) ->
    #             console.log 'top pass'
    #             # top of element passed
    #         onUpdate: (calculations) ->
    #             # do something whenever calculations adjust
    #             console.log 'update'
    #             # updateTable calculations
    #     , 2000
Template.q.helpers
    linked_questions: ->
        question = Docs.findOne Router.current().params.qid
        Docs.find 
            model:'stack_question'
            _id:question.linked_question_ids
            site:Router.current().params.site
    related_questions: ->
        question = Docs.findOne Router.current().params.qid
        Docs.find 
            model:'stack_question'
            _id:question.related_question_ids
            site:Router.current().params.site
    question_answers: ->
        Docs.find({
            model:'stack_answer'
            site:Router.current().params.site
            question_id:parseInt(Router.current().params.qid)
        }, {
            sort:score:-1
        })
    question_comments: ->
        question = Docs.findOne Router.current().params.qid
        Docs.find 
            model:'stack_comment'
            post_id:parseInt(Router.current().params.qid)
            site:Router.current().params.site
    answer_class: -> if @accepted then 'accepted'


Template.q.events
    'click .goto_q': -> Router.go "/s/#{Router.current().params.site}/q/#{@question_id}"

    # 'click .speak_this': ->
    #     if Session.get('speaking')
    #         window.speechSynthesis.cancel()
    #         Session.set('speaking',false)
    #     else
    #         window.speechSynthesis.speak new SpeechSynthesisUtterance @analyzed_text
    #         Session.set('speaking',true)

    # 'click .speak_body': ->
    #     if Session.get('speaking')
    #         window.speechSynthesis.cancel()
    #         Session.set('speaking',false)
    #     else
    #         window.speechSynthesis.speak new SpeechSynthesisUtterance @body
    #         Session.set('speaking',true)

    'click .refresh_user': (e,t)->
        Meteor.call 'search_stackuser', Router.current().params.site, @user_id, ->

        # window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name

    'click .get_linked': (e,t)->
        console.log 'linked'
        Meteor.call 'get_linked_questions', Router.current().params.site, Router.current().params.qid,->
    'click .get_related': (e,t)->
        Meteor.call 'get_related_questions', Router.current().params.site, Router.current().params.qid,->
        console.log 'getting related'
    'click .call_watson': (e,t)->
        window.speechSynthesis.speak new SpeechSynthesisUtterance 'analyzing'
        Meteor.call 'call_watson', Router.current().params.qid,'link','stack',->
            
    'click .call_tone': (e,t)->
        Meteor.call 'call_tone', Router.current().params.qid,->
    'click .get_question': (e,t)->
        question = Docs.findOne(Router.current().params.qid)
        Meteor.call 'get_question', Router.current().params.site, Router.current().params.qid,->
            
    'click .get_q_c': (e,t)->
        # question = Docs.findOne(Router.current().params.qid)
        window.speechSynthesis.speak new SpeechSynthesisUtterance "getting #{Router.current().params.site} comments"
        Meteor.call 'get_q_c', Router.current().params.site, Router.current().params.qid,->
            
    'click .get_answers': (e,t)->
        window.speechSynthesis.speak new SpeechSynthesisUtterance "getting #{Router.current().params.site} answers"
        question = Docs.findOne(Router.current().params.qid)
        Meteor.call 'question_answers', Router.current().params.site, question.question_id,->
            

    'click .add_stack_tag': ->
        selected_tags.clear()
        selected_tags.push @valueOf()
        # if Session.equals('view_mode','stack')
        Router.go "/s/#{Router.current().params.site}"
        # Session.set('thinking',true)
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()

        Meteor.call 'search_stack', Router.current().params.site, @valueOf(), =>
            # Session.set('thinking',false)
    # 'click .toggle_alpha': -> 
    #     Session.set('view_alpha', !Session.get('view_alpha'))
    # 'click .toggle_reddit': -> 
    #     Session.set('view_reddit', !Session.get('view_reddit'))
    # 'click .toggle_duck': -> 
    #     Session.set('view_duck', !Session.get('view_duck'))
