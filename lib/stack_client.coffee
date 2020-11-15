if Meteor.isClient
    @selected_stack_tags = new ReactiveArray []
    @selected_site_tags = new ReactiveArray []

    Router.route '/stack', (->
        @layout 'layout'
        @render 'stack'
        ), name:'stack'

    

    Template.nav.events
        'click .home2': -> 
            # console.log @valueOf()
            Session.set('site_name_filter',null)
            selected_tags.clear()
            window.speechSynthesis.cancel()

            # window.speechSynthesis.speak new SpeechSynthesisUtterance @innerHTML()

    Template.body.events
        'click .say_site': -> 
            window.speechSynthesis.speak new SpeechSynthesisUtterance @site
  
    Template.stack.events
        'click .goto_site': -> 
            selected_tags.clear()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # 'click .site': -> 
        #     console.log @valueOf()
        #     window.speechSynthesis.speak new SpeechSynthesisUtterance @name

  
  

            
                
    Template.stack.onCreated ->
        # @autorun => Meteor.subscribe 'stack_docs',
        #     selected_stack_tags.array()
        @autorun -> Meteor.subscribe 'stack_sites',
            selected_tags.array()
            Session.get('site_name_filter')
    Template.stack.helpers
        site_docs: ->
            Docs.find
                model:'stack_site'
        stack_docs: ->
            Docs.find
                model:'stack_question'

    Template.stack.events
        'click .doc': ->
            console.log @
        'click .dl': ->
            Meteor.call 'stack_sites'
        'keyup .search_site_name': ->
            search = $('.search_site_name').val()
            Session.set('site_name_filter', search)
            
   
   


if Meteor.isServer
    Meteor.publish 'stack_sites', (selected_tags=[], name_filter='')->
        match = {model:$in:['stack_site','tribe']}
        match.site_type = 'main_site'
        if selected_tags.length > 0
            match.tags = $all: selected_tags
        if name_filter.length > 0
            match.name = {$regex:"#{name_filter}", $options:'i'}
        Docs.find match,
            limit:300
    
    Meteor.publish 'question_answers', (question_doc_id)->
        question = Docs.findOne question_doc_id
        console.log question.question_id
        Docs.find 
            model:'stack_answer'
            site:question.site
            question_id:question.question_id
    
    Meteor.publish 'stackuser_doc', (site,user_id)->
        console.log 'looking for', site, user_id
        Docs.find 
            model:'stackuser'
            user_id:parseInt(user_id)
            site:site
    
    Meteor.publish 'site_by_param', (site)->
        Docs.find 
            model:'stack_site'
            api_site_parameter:site
    
    # Meteor.publish 'stack_docs', ->
    #     Docs.find {
    #         model:'stack'
    #     },
    #         limit:20
            
            