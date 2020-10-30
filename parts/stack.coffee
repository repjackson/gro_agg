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

    Template.stack_page.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        
    Template.stack.onCreated ->
        @autorun => Meteor.subscribe 'stack_docs',
            selected_stack_tags.array()
        @autorun -> Meteor.subscribe 'stack_sites',
            selected_site_tags.array()

    Template.stack.helpers
        sites: ->
            Docs.find
                model:'site'
        stack_docs: ->
            Docs.find
                model:'stack'

    Template.stack.events
        'click .doc': ->
            console.log @


# if Meteor.isServer
    # Meteor.publish 'stack_sites', ->
    #     Docs.find model:'site'
    
    # Meteor.publish 'stack_docs', ->
    #     Docs.find {
    #         model:'stack'
    #     },
    #         limit:20
            
            