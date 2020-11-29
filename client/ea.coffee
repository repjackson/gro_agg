selected_reg_type = new ReactiveArray()

Router.route '/ea', (->
    @layout 'layout'
    @render 'ea'
    ), name:'ea'


Template.ea.onCreated ->
    Session.setDefault('name_query','')
    Session.setDefault('location_query','')
    Session.setDefault('register_query','')
    Session.setDefault('number_query','')
    @autorun -> Meteor.subscribe 'ea_docs', 
        selected_reg_type.array()
        Session.get 'name_query'
        Session.get 'location_query'
        Session.get 'register_query'
        Session.get 'number_query'
        
    @autorun -> Meteor.subscribe 'e_tags', 
        selected_reg_type.array()
        Session.get 'name_query'
        Session.get 'location_query'
        Session.get 'register_query'
        Session.get 'number_query'
        

Template.ea.onRendered ->

Template.ea.helpers
    ea_docs: ->
        Docs.find({
            model:'ea'
        }, {
            sort:score:-1
        })
    localities: ->
        results.find({
            model:'locality'
        }, {
            sort:count:-1
        })
    answer_class: -> if @accepted then 'accepted'


Template.ea.events
    'click .goto_q': -> Router.go "/s/#{Router.current().params.site}/q/#{@question_id}"

    'keyup .search_name': (e,t)->
        val = $('.search_name').val()
        Session.set('name_query', val)
        # if e.which is 13 
            # Meteor.call 'search_name', val, ->
            #     $('.search_name').val('')
            #     Session.set('name_query', null)

    'keyup .search_location': (e,t)->
        val = $('.search_location').val()
        Session.set('location_query', val)
        # if e.which is 13 
        #     Meteor.call 'search_location', val, ->
    #             $('.search_location').val('')
    #             Session.set('location_query', null)

    'keyup .search_number': (e,t)->
        val = $('.search_number').val()
        Session.set('number_query', val)
    #     if e.which is 13 
    #         Meteor.call 'search_number', val, ->
    #             $('.search_number').val('')
    #             Session.set('number_query', null)

    'keyup .search_type': (e,t)->
        val = $('.search_type').val()
        Session.set('type_query', val)
    #     if e.which is 13 
    #         Meteor.call 'search_number', val, ->
    #             $('.search_number').val('')
    #             Session.set('number_query', null)

    'click .clear_name': -> 
        Session.set('name_query', null)
        $('.search_name').val('')
    'click .clear_location': -> 
        Session.set('location_query', null)
        $('.search_location').val('')
    'click .clear_number': -> 
        Session.set('number_query', null)
        $('.search_number').val('')
    'click .clear_type': -> 
        Session.set('type_query', null)
        $('.search_type').val('')
    
Template.call_register.events    
    'click .call_ea': (e,t)->
        console.log @
        Meteor.call 'call_ea', @k, ->

        # window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name
