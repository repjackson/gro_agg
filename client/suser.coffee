Router.route '/s/:site/u/:user_id', (->
    @layout 'suser_layout'
    @render 'suser_dash'
    ), name:'suser_dash'

Router.route '/s/:site/u/:user_id/q', (->
    @layout 'suser_layout'
    @render 'suser_q'
    ), name:'suser_q'
Template.suser_q.onCreated ->
    @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_q', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_tags', 
        'stack_question'
        Router.current().params.site, 
        Router.current().params.user_id
        selected_tags.array()
Template.suser_q.helpers
    stackuser_doc: ->
        Docs.findOne 
            model:'stackuser'
            site:Router.current().params.site
            user_id:parseInt(Router.current().params.user_id)
    q: ->
        cur = Docs.find
            model:'stack_question'
            "owner.user_id":parseInt(Router.current().params.user_id)
            site:Router.current().params.site
        cur
    suser_q_tags: -> results.find(model:'suser_tag')

Template.suser_q.events
    'click .select_location': -> selected_locations.push @name
    
    'click .unselect_location': -> selected_locations.remove @valueOf()





Router.route '/s/:site/u/:user_id/a', (->
    @layout 'suser_layout'
    @render 'suser_a'
    ), name:'suser_a'
Template.suser_a.onCreated ->
    @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_a', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_tags', 
        'stack_answer'
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
    suser_a_tags: -> results.find(model:'suser_tag')

Template.suser_a.events
    'click .select_location': -> selected_locations.push @name
    
    'click .unselect_location': -> selected_locations.remove @valueOf()



Router.route '/s/:site/u/:user_id/b', (->
    @layout 'suser_layout'
    @render 'suser_b'
    ), name:'suser_b'
Template.suser_b.onCreated ->
    @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_b', Router.current().params.site, Router.current().params.user_id

Router.route '/s/:site/u/:user_id/t', (->
    @layout 'suser_layout'
    @render 'suser_t'
    ), name:'suser_t'
Template.suser_t.onCreated ->
    @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_t', Router.current().params.site, Router.current().params.user_id

Template.suser_layout.onCreated ->
    @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
Template.suser_layout.onRendered ->
    Meteor.call 'search_stackuser', Router.current().params.site, Router.current().params.user_id, ->
    Meteor.call 'get_suser_a', Router.current().params.site, Router.current().params.user_id, ->
    Meteor.call 'get_suser_q', Router.current().params.site, Router.current().params.user_id, ->
    # Meteor.call 'get_suser_t', Router.current().params.site, Router.current().params.user_id, ->
    Meteor.call 'get_suser_c', Router.current().params.site, Router.current().params.user_id, ->
    # Meteor.call 'get_suser_b', Router.current().params.site, Router.current().params.user_id, ->
    # Meteor.setTimeout ->
    #     Meteor.call 'omega', Router.current().params.site, Router.current().params.user_id, ->
    # , 1000
    
    
Template.suser_dash.onCreated ->
    # console.log 'hi'
    @autorun => Meteor.subscribe 'suser_b', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_t', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_c', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_q', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_a', Router.current().params.site, Router.current().params.user_id
Template.suser_dash.onRendered ->
    suser = 
        Docs.findOne 
            model:'stackuser'
            site:Router.current().params.site
            user_id:parseInt(Router.current().params.user_id)
    Meteor.call 'log_view', suser._id, ->

Template.suser_q_item.onRendered ->
    unless @data.watson
        Meteor.call 'call_watson', @data._id,'link','stack',->
        # window.speechSynthesis.speak new SpeechSynthesisUtterance "dao"

Template.suser_c_item.events
    'click .call': (e,t)-> 
        # console.log 'hi'
        window.speechSynthesis.speak new SpeechSynthesisUtterance "anlyzing"
        Meteor.call 'call_watson',@_id,'body','text', (err,res)=>

Template.suser_a_item.events
    'click .call': (e,t)-> 
        # console.log 'hi'
        window.speechSynthesis.speak new SpeechSynthesisUtterance "anlyzing"
        Meteor.call 'call_watson',@_id,'body','html', (err,res)=>
Template.answer_item.events
    'click .call': (e,t)-> 
        # console.log 'hi'
        window.speechSynthesis.speak new SpeechSynthesisUtterance "anlyzing"
        Meteor.call 'call_watson',@_id,'body','html', (err,res)=>


Template.suser_dash.helpers
    suser_c: ->
        cur = Docs.find
            model:'stack_comment'
            site:Router.current().params.site
            "owner.user_id":parseInt(Router.current().params.user_id)
        cur
    suser_q: ->
        Docs.find
            model:'stack_question'
            site:Router.current().params.site
            "owner.user_id":parseInt(Router.current().params.user_id)
    suser_a: ->
        Docs.find
            model:'stack_answer'
            site:Router.current().params.site
            "owner.user_id":parseInt(Router.current().params.user_id)
    suser_b: ->
        Docs.find
            model:'stack_badge'
    suser_t: ->
        Docs.find
            model:'stack_tag'

Template.suser_a_item.onCreated ->
    @autorun => Meteor.subscribe 'question_from_id', @data.question_id
    
Template.suser_a_item.helpers
    a_q: ->
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
        Meteor.call 'get_suser_q', Router.current().params.site, Router.current().params.user_id, ->
    'click .get_comments': ->
        Meteor.call 'get_suser_c', Router.current().params.site, Router.current().params.user_id, ->
    'click .get_b': ->
        Meteor.call 'get_suser_b', Router.current().params.site, Router.current().params.user_id, ->
    'click .get_tags': ->
        Meteor.call 'get_suser_t', Router.current().params.site, Router.current().params.user_id, ->
            
           
Template.suser_dash.events
    'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
    'click .tog_qtags': (e,t)-> Session.set('view_qtags',!Session.get('view_qtags'))
           
           
            
            
Router.route '/s/:site/u/:user_id/c', (->
    @layout 'suser_layout'
    @render 'suser_c'
    ), name:'suser_c'
Template.suser_c.onCreated ->
    @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
    @autorun => Meteor.subscribe 'suser_c', Router.current().params.site, Router.current().params.user_id
Template.suser_c.onRendered ->
    Meteor.call 'get_suser_c', Router.current().params.site, Router.current().params.user_id, ->
Template.suser_c.helpers
    suser_c: ->
        cur = Docs.find
            model:'stack_comment'
            "owner.user_id":parseInt(Router.current().params.user_id)
            site:Router.current().params.site
        cur