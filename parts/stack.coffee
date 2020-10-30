if Meteor.isClient
    @selected_stack_tags = new ReactiveArray []
    @selected_site_tags = new ReactiveArray []

    Router.route '/stack', (->
        @layout 'layout'
        @render 'stack'
        ), name:'stack'

    Router.route '/site/:site', (->
        @layout 'layout'
        @render 'site_page'
        ), name:'site_page'
    
    Router.route '/site/:site/doc/:doc_id', (->
        @layout 'layout'
        @render 'stack_page'
        ), name:'stack_page'
    
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

        
        
        
    Template.site_page.onCreated ->
        @autorun => Meteor.subscribe 'site_by_param', Router.current().params.site
        @autorun => Meteor.subscribe 'stack_docs_by_site', Router.current().params.site
    Template.site_page.helpers
        current_site: ->
            Docs.findOne
                model:'stack_site'
                api_site_parameter:Router.current().params.site
        site_questions: ->
            Docs.find
                model:'stack'
                site:Router.current().params.site
    Template.site_page.events
        'keyup .search_site': (e,t)->
            # search = $('.search_site').val().toLowerCase().trim()
            search = $('.search_site').val().trim()
            if e.which is 13
                # window.speechSynthesis.cancel()
                # console.log search
                if search.length > 0
                    site = 
                        Docs.findOne
                            model:'stack_site'
                            api_site_parameter:Router.current().params.site
                    if site
                        Meteor.call 'search_stack', site.api_site_parameter, search, ->


            
                
    Template.stack.onCreated ->
        @autorun => Meteor.subscribe 'stack_docs',
            selected_stack_tags.array()
        @autorun -> Meteor.subscribe 'stack_sites',
            selected_site_tags.array()

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
   
   
   


if Meteor.isServer
    Meteor.publish 'stack_sites', ->
        Docs.find model:'stack_site'
    
    Meteor.publish 'stackuser_doc', (user_id)->
        Docs.find 
            model:'stackuser'
            user_id:user_id
    
    Meteor.publish 'site_by_param', (site)->
        Docs.find 
            model:'stack_site'
            api_site_parameter:site
    
    Meteor.publish 'stack_docs_by_site', (site)->
        site = Docs.findOne
            model:'stack_site'
            api_site_parameter:site
        Docs.find {
            model:'stack'
            site:site.api_site_parameter
        }, limit:10
    # Meteor.publish 'stack_docs', ->
    #     Docs.find {
    #         model:'stack'
    #     },
    #         limit:20
            
            