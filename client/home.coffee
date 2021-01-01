# # @selected_tags = new ReactiveArray []
# @selected_models = new ReactiveArray []
# @selected_subreddits = new ReactiveArray []
# @selected_emotions = new ReactiveArray []


Template.alpha.onCreated ->
    @autorun -> Meteor.subscribe('alpha_combo',selected_tags.array())
Template.alpha.onRendered ->
    # unless @data.watson
    #     Meteor.call 'call_watson', @data._id, 'url','url',->
    # if @data.response
    # window.speechSynthesis.cancel()
    # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.response.queryresult.pods[1].subpods[1].plaintext
    if @data 
        if @data.voice
            window.speechSynthesis.speak new SpeechSynthesisUtterance @data.voice
        else if @data.response 
            if @data.response.queryresult.pods
                window.speechSynthesis.speak new SpeechSynthesisUtterance @data.response.queryresult.pods[1].subpods[0].plaintext
    # Meteor.setTimeout( =>
    # , 7000)

Template.alpha.helpers
    split_datatypes: ->
        split = @datatypes.split ','
        split

Template.alpha.events
    'click .select_datatype': ->
        selected_tags.push @valueOf().toLowerCase()
    'click .alphatemp': ->
        window.speechSynthesis.cancel()
        window.speechSynthesis.speak new SpeechSynthesisUtterance @plaintext
        




Template.unselect_tag.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title_small', @data.toLowerCase())
    
Template.unselect_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
Template.unselect_tag.events
  'click .unselect_tag': -> 
        selected_tags.remove @valueOf()
        Session.set('skip',0)
        window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
    


Template.tag_selector.onCreated ->
    if @data.name
        @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
Template.tag_selector.helpers
    selector_class: ()->
        term = 
            Docs.findOne 
                title:@name.toLowerCase()
        if term
            if term.max_emotion_name
                switch term.max_emotion_name
                    when 'joy' then ' basic green'
                    when 'anger' then ' basic red'
                    when 'sadness' then ' basic blue'
                    when 'disgust' then ' basic orange'
                    when 'fear' then ' basic grey'
                    else 'basic'
    term: ->
        Docs.findOne 
            title:@name.toLowerCase()
            
# Template.dao.events
#     'keyup .search_stack': (e,t)->
#         # search = $('.search_title').val().toLowerCase().trim()
#         search = $('.search_stack').val().trim()
#         # _.throttle( =>

#         # if search.length > 4
#         #     Session.set('query',search)
#         # else if search.length is 0
#         #     Session.set('query','')
#         if e.which is 13
#             window.speechSynthesis.cancel()
#             if search.length > 0
#                 Meteor.call 'search_stack', search, selected_tags.array(), (err,res)->

#     # 'click .call_stack': -> Meteor.call 'search_stack', selected_tags.array()
#     'click .select_model': -> selected_models.push @name
#     'click .select_emotion': -> selected_emotions.push @name
#     'click .select_location': -> selected_locations.push @name
    
#     'click .unselect_location': -> selected_locations.remove @valueOf()
#     'click .unselect_model': -> selected_models.remove @valueOf()
#     'click .unselect_subreddit': -> selected_subreddits.remove @valueOf()
#     'click .unselect_emotion': -> selected_emotions.remove @valueOf()
            
            
# # Template.tag_selector.events
# #     'click .select_tag': -> 
# #         # results.update
# #         window.speechSynthesis.cancel()
# #         # selected_tags.push @name
# #         Session.set('query','')
# #         Session.set('skip',0)
# #         $('.search_site').val('')
# #         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
# #         window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
# #         # Meteor.call 'call_alpha', selected_tags.array().toString(), ->
# #         # Session.set('loading',true)
# #         # Meteor.call 'search_stack', Router.current().params.site, @name, ->
# #             # Session.set('loading',false)
# #         # Session.set('thinking',true)
# #         # Meteor.call 'call_wiki', @name, ->
# #         # Meteor.call 'search_reddit', selected_tags.array(), ->
# #         #     Session.set('thinking',false)
# #         # Meteor.call 'search_ddg', @name, ->
# #         # Session.set('viewing_doc',null)
# #         Meteor.setTimeout( ->
# #             Session.set('toggle',!Session.get('toggle'))
# #         , 5000)
       
       
# # Template.doc_tag.onCreated ->
# #     @autorun => Meteor.subscribe('doc_by_title_small', @data)
# # Template.doc_tag.helpers
# #     selector_class: ->
# #         term = 
# #             Docs.findOne 
# #                 title:@valueOf()
# #         if term
# #             if term.max_emotion_name
# #                 switch term.max_emotion_name
# #                     when 'joy' then 'green'
# #                     when 'anger' then 'red'
# #                     when 'sadness' then 'blue'
# #                     when 'disgust' then 'orange'
# #                     when 'fear' then 'grey'
# #     term: ->
# #         Docs.findOne 
# #             title:@valueOf()
            
            
# # Template.doc_tag.events
# #     'click .select_tag': -> 
# #         # results.update
# #         window.speechSynthesis.cancel()
        
# #         selected_tags.push @valueOf()
# #         Session.set('query','')
# #         Session.set('skip',0)
# #         Session.set('viewing_doc',null)
# #         Session.set('thinking',true)
# #         Meteor.call 'call_wiki', @valueOf(), ->
# #         Meteor.call 'search_reddit', selected_tags.array(), ->
# #             Session.set('thinking',false)
# #         Meteor.call 'search_ddg', @name, ->
# #         Meteor.call 'call_alpha', selected_tags.array().toString(), ->
# #         window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
            
# #         # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
# #         Meteor.setTimeout( ->
# #             Session.set('toggle',!Session.get('toggle'))
# #         , 10000)
       
       
       
       
       
# # # Template.select_subreddit.onCreated ->
# # #     @autorun => Meteor.subscribe('tribe_by_title', @data.name)
# # # Template.select_subreddit.helpers
# # #     tribe_doc: ->
# # #         found = Docs.findOne 
# # #             title:@name
# # #             model:'tribe'
# # #         found 
            
       
       
# # Template.watson_full.events
# #     'click .add_stack_tag': ->
# #         selected_tags.clear()
# #         selected_tags.push @valueOf()
# #         # if Session.equals('view_mode','stack')
# #         Router.go "/s/#{Router.current().params.site}"
# #         # Session.set('thinking',true)
# #         # $('body').toast(
# #         #     showIcon: 'stack exchange'
# #         #     message: 'started'
# #         #     displayTime: 'auto',
# #         #     position: 'bottom right'
# #         # )
# #         # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()

# #         Meteor.call 'search_stack', Router.current().params.site, @valueOf(), =>


Template.alpha.helpers
    alphas: ->
        Docs.find 
            model:'alpha'
            # query: $in: selected_tags.array()
            query: selected_tags.array().toString()

