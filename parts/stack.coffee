if Meteor.isClient
    Router.route '/stack', (->
        @layout 'layout'
        @render 'stack'
        ), name:'stack'


    Template.stack.onCreated ->
        @autorun -> Meteor.subscribe 'stack_sites'
        @autorun -> Meteor.subscribe 'stack_docs'
    Template.stack.helpers
        sites: ->
            Docs.find
                model:'site'
        stack_docs: ->
            Docs.find
                model:'stack'



if Meteor.isServer
    Meteor.publish 'stack_sites', ->
        Docs.find model:'site'
    
    Meteor.publish 'stack_docs', ->
        Docs.find {
            model:'stack'
        },
            limit:20
            
            