if Meteor.isClient
    @selected_stack_tags = new ReactiveArray []
    @selected_site_tags = new ReactiveArray []

    Router.route '/stack', (->
        @layout 'layout'
        @render 'stack'
        ), name:'stack'

    
    Router.route '/site/:site/user/:user_id', (->
        @layout 'layout'
        @render 'stackuser_page'
        ), name:'stackuser_page'

    Template.stack_page.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.stack_page.events
        'click .call_watson': (e,t)->
            Meteor.call 'call_watson', Router.current().params.doc_id,'link','stack',->
        'click .call_tone': (e,t)->
            Meteor.call 'call_tone', Router.current().params.doc_id,->
  
  
  
    Template.stackuser_page.onCreated ->
        @autorun => Meteor.subscribe 'stackuser_doc', Router.current().params.user_id

        

            
                
    Template.stack.onCreated ->
        @autorun => Meteor.subscribe 'stack_docs',
            selected_stack_tags.array()
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
        if name_filter.length > 0
            match.name = {$regex:"#{name_filter}", $options:'i'}
        Docs.find match,
            limit:20
    
    Meteor.publish 'stackuser_doc', (user_id)->
        Docs.find 
            model:'stackuser'
            user_id:user_id
    
    Meteor.publish 'site_by_param', (site)->
        Docs.find 
            model:'stack_site'
            api_site_parameter:site
    
    # Meteor.publish 'stack_docs', ->
    #     Docs.find {
    #         model:'stack'
    #     },
    #         limit:20
            
            