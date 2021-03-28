Template.registerHelper 'unique_tags', () ->
    diff = _.difference(@tags, picked_tags.array())
    diff[..7]
    
    
@l = console.log
   

Template.registerHelper 'thinking_class', ()->
    if Session.get('thinking') then 'disabled' else ''


# Template.registerHelper 'domain_results', ()->results.find(model:'domain')
# Template.registerHelper 'author_results', ()->results.find(model:'author')
# Template.registerHelper 'time_tag_results', ()->results.find(model:'time_tag')
# Template.registerHelper 'subreddit_results', ()-> results.find(model:'subreddit_tag')
# Template.registerHelper 'Location_results', ()-> results.find(model:'Location')
# Template.registerHelper 'person_results', ()-> results.find(model:'person_tag')

Session.setDefault('loading', false)


@picked_Persons = new ReactiveArray []
@picked_Locations = new ReactiveArray []
@picked_Companys = new ReactiveArray []
@picked_Organizations = new ReactiveArray []
@picked_timestamp_tags = new ReactiveArray []


Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'wiki'
    loadingTemplate: 'splash'
    trackPageView: false
	progressTick: false
# 	progressDelay: 100
Router.route '*', -> @render 'wiki'


# Template.registerHelper 'picked_authors', () -> picked_authors.array()
# Template.registerHelper 'picked_domains', () -> picked_domains.array()
# Template.registerHelper 'picked_persons', () -> picked_persons.array()
# Template.registerHelper 'picked_Locations', () -> picked_Locations.array()
    
Template.registerHelper 'commafy', (num)-> if num then num.toLocaleString()

    
Template.registerHelper 'trunc', (input) ->
    if input
        input[0..300]
   
   
Template.registerHelper 'emotion_avg', (metric) -> results.findOne(model:'emotion_avg')
Template.registerHelper 'skv_is', (key,val) -> 
    Session.equals(key,val)
Template.registerHelper 'kv_is', (key,val) -> 
    @["#{key}"] is val

Template.registerHelper 'calculated_size', (metric) ->
    # whole = parseInt(@["#{metric}"]*10)
    whole = parseInt(metric*10)
    switch whole
        when 0 then 'f5'
        when 1 then 'f6'
        when 2 then 'f7'
        when 3 then 'f8'
        when 4 then 'f9'
        when 5 then 'f10'
        when 6 then 'f11'
        when 7 then 'f12'
        when 8 then 'f13'
        when 9 then 'f14'
        when 10 then 'f15'
        
        
        
        
Template.registerHelper 'abs_percent', (num) -> 
    # console.l/og Math.abs(num*100)
    parseInt(Math.abs(num*100))

    
# Template.registerHelper 'connection', () -> Meteor.status()
# Template.registerHelper 'connected', () -> Meteor.status().connected
    



Router.route '/post/:doc_id/', -> @render 'post_view'

Template.post_view.onCreated ->
    @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
Template.post_view.onRendered ->
    Meteor.call 'log_view', Router.current().params.doc_id
    
    
Template.comments.onCreated ->
    # if Router.current().params.doc_id
    #     parent = Docs.findOne Router.current().params.doc_id
    # else
    #     parent = Docs.findOne Template.parentData()._id
    # if parent
    @autorun => Meteor.subscribe 'children', 'comment', @data._id
Template.comments.helpers
    doc_comments: ->
        # console.log Template.parentData()
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.currentData()
        if Router.current().params.doc_id
            parent = Docs.findOne Router.current().params.doc_id
        else
            parent = Docs.findOne Template.currentData()._id
        # if Meteor.user()
        Docs.find {
            parent_id:parent._id
            model:'comment'
        }, sort:_timestamp:-1
        # else
        #     Docs.find
        #         model:'comment'
        #         parent_id:parent._id
        #         _author_id:$exists:false
                    
Template.comments.events
    'keyup .add_comment': (e,t)->
        if e.which is 13
            if Router.current().params.doc_id
                parent = Docs.findOne Router.current().params.doc_id
            else
                parent = Docs.findOne Template.currentData()._id
            # parent = Docs.findOne Router.current().params.doc_id
            comment = t.$('.add_comment').val()
            Docs.insert
                parent_id: parent._id
                model:'comment'
                parent_model:parent.model
                body:comment
            t.$('.add_comment').val('')
            found_bounty = Docs.findOne
                model:'bounty'
                status:$ne:'complete'
                require_reply:true
                reply_requirement_met:$ne:true
                target_id:Meteor.userId()
            if found_bounty
                Docs.update found_bounty._id,
                    $set:
                        reply_requirement_met: true
                if Meteor.isClient
                    $('body').toast({
                        class: 'success',
                        message: "reply requirement met"
                    })

    'click .remove_comment': ->
        if confirm 'Confirm remove comment'
            Docs.remove @_id

