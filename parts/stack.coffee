if Meteor.isClient
    @selected_stack_tags = new ReactiveArray []
    @selected_site_tags = new ReactiveArray []

    Router.route '/stack', (->
        @layout 'layout'
        @render 'stack'
        ), name:'stack'

    Router.route '/stack/:doc_id', (->
        @layout 'layout'
        @render 'stack_page'
        ), name:'stack_page'
    
    Router.route '/site/:name', (->
        @layout 'layout'
        @render 'site_page'
        ), name:'site_page'

    Template.stack_page.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        
    Template.site_page.onCreated ->
        @autorun => Meteor.subscribe 'site_by_name', Router.current().params.name
    Template.site_page.helpers
        current_site: ->
            Docs.findOne
                model:'stack_site'
                name:Router.current().params.name
                
                
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
    
    Meteor.publish 'site_by_name', (name)->
        Docs.find 
            model:'stack_site'
            name:name
    
    # Meteor.publish 'stack_docs', ->
    #     Docs.find {
    #         model:'stack'
    #     },
    #         limit:20
            
            