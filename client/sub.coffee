@selected_sub_tags = new ReactiveArray []
@selected_group_domain = new ReactiveArray []
@selected_group_time_tags = new ReactiveArray []
@selected_group_authors = new ReactiveArray []


# Router.route '/r/:group', (->
#     @layout 'layout'
#     @render 'group'
#     ), name:'group'

Router.route '/r/:group/post/:doc_id', (->
    @layout 'layout'
    @render 'rpage'
    ), name:'rpage'
    

# Template.group.onCreated ->
    # Session.setDefault('location_query', null)
    # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'subrzeddit_user_count', Router.current().params.group
    # @autorun => Meteor.subscribe 'group_by_param', Router.current().params.group
    # @autorun => Meteor.subscribe 'sub_docs_by_name', 
    #     Router.current().params.group
    #     selected_sub_tags.array()
    #     selected_group_domain.array()
    #     selected_group_time_tags.array()
    #     selected_group_authors.array()
    #     Session.get('sort_key')
    #     Session.get('sort_direction')
  
    # @autorun => Meteor.subscribe 'sub_doc_count', 
    #     Router.current().params.group
    #     selected_sub_tags.array()
    #     selected_group_domain.array()
    #     selected_group_time_tags.array()
    #     selected_group_authors.array()

    # @autorun => Meteor.subscribe 'group_result_tags',
    #     Router.current().params.group
    #     selected_sub_tags.array()
    #     selected_group_domain.array()
    #     selected_group_time_tags.array()
    #     selected_group_authors.array()
    #     Session.get('toggle')

    # @autorun => Meteor.subscribe 'agg_sentiment_group',
    #     Router.current().params.group
    #     selected_sub_tags.array()
    #     ()->Session.set('ready',true)

Template.doc_item.events
    'click .view_post': (e,t)-> 
        Session.set('view_section','main')
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
        # Router.go "/group/#{@group}/post/#{@_id}"

Template.doc_item.onRendered ->
    # console.log @
    unless @data.watson
        Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>

Template.post_card_small.onRendered ->
    # console.log @
    unless @data.watson
        Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
    unless @data.time_tags
        Meteor.call 'tagify_time_rpost',@data._id,=>


# Template.group.events
#     'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
#     'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
#     'click .sort_up': (e,t)-> Session.set('sort_direction',1)
#     'click .limit_10': (e,t)-> Session.set('limit',10)
#     'click .limit_1': (e,t)-> Session.set('limit',1)

#     'click .sort_created': -> Session.set('sort_key', 'data.created')
#     'click .sort_ups': -> Session.set('sort_key', 'data.ups')
#     # 'click .download': ->
#     #     Meteor.call 'get_sub_info', Router.current().params.group, ->
    
#     'click .unselect_time_tag': ->
#         selected_group_time_tags.remove @valueOf()
#     'click .select_time_tag': ->
#         selected_group_time_tags.push @name
#         window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    
#     'click .unselect_domain': ->
#         selected_group_domain.remove @valueOf()
#     'click .select_domain': ->
#         selected_group_domain.push @name
#         window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    
#     'click .unselect_author': ->
#         selected_group_authors.remove @valueOf()
#     'click .select_author': ->
#         selected_group_authors.push @name
#         window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    
    
    
#     'click .pull_latest': ->
#         # console.log 'latest'
#         Meteor.call 'get_sub_latest', Router.current().params.group, ->



# Template.sub_tag_selector.onCreated ->
#     @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
# Template.sub_tag_selector.helpers
#     selector_class: ()->
#         term = 
#             Docs.findOne 
#                 title:@name.toLowerCase()
#         if term
#             if term.max_emotion_name
#                 switch term.max_emotion_name
#                     when 'joy' then "  green"
#                     when "anger" then "  red"
#                     when "sadness" then "  blue"
#                     when "disgust" then "  orange"
#                     when "fear" then "  grey"
#                     else " grey"
#     term: ->
#         Docs.findOne 
#             title:@name.toLowerCase()
            
            
# Template.sub_tag_selector.events
#     'click .select_sub_tag': -> 
#         # results.update
#         # console.log @
#         # window.speechSynthesis.cancel()
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
#         # if @model is 'group_emotion'
#         #     selected_emotions.push @name
#         # else
#         # if @model is 'group_tag'
#         selected_sub_tags.push @name
#         $('.search_group').val('')
        
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
#         Session.set('subs_loading',true)
#         Meteor.call 'search_group', Router.current().params.group, @name, ->
#             Session.set('loading',false)
#             Session.set('sub_doc_query', null)
            
#         Meteor.setTimeout( ->
#             Session.set('toggle',!Session.get('toggle'))
#         , 5000)
        
        
        

# Template.sub_unselect_tag.onCreated ->
#     @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
    
# Template.sub_unselect_tag.helpers
#     term: ->
#         found = 
#             Docs.findOne 
#                 # model:'wikipedia'
#                 title:@valueOf().toLowerCase()
#         found
# Template.sub_unselect_tag.events
#     'click .unselect_sub_tag': -> 
#         Session.set('skip',0)
#         console.log @
#         selected_sub_tags.remove @valueOf()
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
    

# Template.flat_sub_tag_selector.onCreated ->
#     @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
# Template.flat_sub_tag_selector.helpers
#     selector_class: ()->
#         term = 
#             Docs.findOne 
#                 title:@valueOf().toLowerCase()
#         if term
#             if term.max_emotion_name
#                 switch term.max_emotion_name
#                     when 'joy' then "  green"
#                     when "anger" then "  red"
#                     when "sadness" then "  blue"
#                     when "disgust" then "  orange"
#                     when "fear" then "  grey"
#                     else " grey"
#     term: ->
#         Docs.findOne 
#             title:@valueOf().toLowerCase()
# Template.flat_sub_tag_selector.events
#     'click .select_flat_tag': -> 
#         # results.update
#         # window.speechSynthesis.cancel()
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
#         selected_sub_tags.push @valueOf()
#         Router.go "/#{Router.current().params.group}/"
#         $('.search_group').val('')
#         Session.set('loading',true)
#         Meteor.call 'search_group', Router.current().params.group, @valueOf(), ->
#             Session.set('loading',false)
#         Meteor.setTimeout( ->
#             Session.set('toggle',!Session.get('toggle'))
#         , 3000)
