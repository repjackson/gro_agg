if Meteor.isClient
    @selected_stack_tags = new ReactiveArray []
    @selected_site_tags = new ReactiveArray []

    Router.route '/stack', (->
        @layout 'layout'
        @render 'stack'
        ), name:'stack'

    


    Template.stack_page.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_answers', Router.current().params.doc_id
        Session.setDefault('stack_section','main')
    Template.stack_page.onRendered ->
        Meteor.call 'get_question', Router.current().params.site, Router.current().params.doc_id,->
        Meteor.call 'question_answers', Router.current().params.site, Router.current().params.doc_id,->
    Template.stack_page.helpers
        question_answers: ->
            Docs.find 
                model:'stack_answer'
    Template.stack_page.events
        'click .call_watson': (e,t)->
            Meteor.call 'call_watson', Router.current().params.doc_id,'link','stack',->
        'click .call_tone': (e,t)->
            Meteor.call 'call_tone', Router.current().params.doc_id,->
        'click .get_question': (e,t)->
            question = Docs.findOne(Router.current().params.doc_id)
            Meteor.call 'get_question', Router.current().params.site, question.question_id,->
                
        'click .get_answers': (e,t)->
            question = Docs.findOne(Router.current().params.doc_id)
            Meteor.call 'question_answers', Router.current().params.site, question.question_id,->
                
                
  
  
    Router.route '/site/:site/user/:user_id', (->
        @layout 'layout'
        @render 'stackuser_page'
        ), name:'stackuser_page'

    Template.stackuser_page.onCreated ->
        @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.site, Router.current().params.user_id
    Template.stackuser_page.helpers
        stackuser_doc: ->
            Docs.findOne 
                model:'stackuser'

    Template.stackuser_page.events
        'click .search': ->
            Meteor.call 'search_stack_user', Router.current().params.site, Router.current().params.user_id, ->
                
        

            
                
    Template.stack.onCreated ->
        # @autorun => Meteor.subscribe 'stack_docs',
        #     selected_stack_tags.array()
        @autorun -> Meteor.subscribe 'stack_sites',
            selected_site_tags.array()
            Session.get('site_name_filter')
    Template.stack.helpers
        site_docs: ->
            Docs.find
                model:'stack_site'
        stack_docs: ->
            Docs.find
                model:'stack'

    Template.stack.events
        'click .doc': ->
            console.log @
        'click .dl': ->
            Meteor.call 'stack_sites'
        'keyup .search_site_name': ->
            search = $('.search_site_name').val()
            Session.set('site_name_filter', search)
            
   
   


if Meteor.isServer
    Meteor.publish 'stack_sites', (selected_tags, name_filter='')->
        match = {model:'stack_site'}
        match.site_type = 'main_site'
        if name_filter.length > 0
            match.name = {$regex:"#{name_filter}", $options:'i'}
        Docs.find match,
            limit:300
    
    Meteor.publish 'question_answers', (question_doc_id)->
        question = Docs.findOne question_doc_id
        console.log question.question_id
        Docs.find 
            model:'stack_answer'
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
            
            