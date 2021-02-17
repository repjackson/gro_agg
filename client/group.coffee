# Router.route '/g/:group', (->
#     @layout 'layout'
#     @render 'group'
#     ), name:'group'
# # Router.route '/:group', (->
# #     @layout 'layout'
# #     @render 'group'
# #     ), name:'group_short'

# @picked_tags = new ReactiveArray []
# @group_picked_time_tags = new ReactiveArray []
# @group_picked_location_tags = new ReactiveArray []
# @picked_Persons = new ReactiveArray []
# @picked_Locations = new ReactiveArray []
# @picked_Organizations = new ReactiveArray []


# Template.group.onCreated ->
#     Session.setDefault('view_layout', 'grid')
#     Session.setDefault('sort_key', 'data.created')
#     Session.setDefault('sort_direction', -1)
#     Session.setDefault('toggle', false)
    
#     Meteor.call 'lower_group', Router.current().params.group, ->
    
#     # @autorun => Meteor.subscribe 'shop_from_group', Router.current().params.group
#     @autorun => Meteor.subscribe 'tags',
#         Router.current().params.group
#         picked_tags.array()
#         group_picked_time_tags.array()
#         group_picked_location_tags.array()
#         picked_Persons.array()
#         picked_Locations.array()
#         picked_Organizations.array()
#         Session.get('toggle')
#     @autorun => Meteor.subscribe 'count', 
#         Router.current().params.group
#         picked_tags.array()
#         group_picked_time_tags.array()
#         group_picked_location_tags.array()
#         picked_Persons.array()
#         picked_Locations.array()
#         picked_Organizations.array()
    
#     @autorun => Meteor.subscribe 'posts', 
#         Router.current().params.group
#         picked_tags.array()
#         group_picked_time_tags.array()
#         group_picked_location_tags.array()
#         picked_Persons.array()
#         picked_Locations.array()
#         picked_Organizations.array()
#         Session.get('sort_key')
#         Session.get('sort_direction')
#         Session.get('skip_value')
#         Session.get('toggle')

# Template.group.helpers
#     posts: ->
#         group_param = Router.current().params.group
#         Docs.find({
#             model: $in: ['post','rpost']
#             group_lowered:group_param.toLowerCase()
#         },
#             sort:"#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
#             limit:25
#         )
  
#     emotion_avg: -> results.findOne(model:'emotion_avg')
    
#     sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
#     sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
#     emotion_avg: -> results.findOne(model:'emotion_avg')
    
#     counter: -> Counts.get 'counter'

#     sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
#     sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
  
  
#     picked_tags: -> picked_tags.array()
#     group_picked_time_tags: -> group_picked_time_tags.array()
#     group_picked_location_tags: -> group_picked_location_tags.array()
#     picked_people_tags: -> picked_people_tags.array()
  
#     result_tags: -> results.find(model:'tag')
#     Organizations: -> results.find(model:'Organization')
#     Companies: -> results.find(model:'Company')
#     HealthConditions: -> results.find(model:'HealthCondition')
#     Persons: -> results.find(model:'Person')
    
#     time_tags: -> results.find(model:'time_tag')
#     location_tags: -> results.find(model:'location_tag')
#     Locations: -> results.find(model:'Location')
#     authors: -> results.find(model:'author')
   
#     domains: -> results.find(model:'group_domain_tag')
   
   
#     current_group: -> Router.current().params.group
        
Template.group.events
    # 'click .unpick_group_tag': -> 
    #     Session.set('skip',0)
    #     # console.log @
    #     picked_tags.remove @valueOf()
    #     # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()

    # 'click .pick_tag': -> 
    #     # results.update
    #     # console.log @
    #     # window.speechSynthesis.cancel()
    #     window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    #     # if @model is 'group_emotion'
    #     #     picked_emotions.push @name
    #     # else
    #     # if @model is 'group_tag'
    #     picked_tags.push @name
    #     $('.search_tag').val('')
    #     Session.set('skip_value',0)

    'click .unpick_Location': ->
        picked_Locations.remove @valueOf()
    'click .pick_Location': ->
        picked_Locations.push @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
    'click .unpick_time_tag': ->
        group_picked_time_tags.remove @valueOf()
    'click .pick_time_tag': ->
        group_picked_time_tags.push @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
    'click .unpick_location_tag': ->
        group_picked_location_tags.remove @valueOf()
    'click .pick_location_tag': ->
        group_picked_location_tags.push @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
  
    'click .unpick_author': ->
        group_picked_author_tags.remove @valueOf()
    'click .pick_author': ->
        group_picked_author_tags.push @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name

    'click .add_post': ->
        new_id = 
            Docs.insert 
                model:'post'
                group:Router.current().params.group
        Router.go "/g/#{Router.current().params.group}/p/#{new_id}/edit"
 
    'focus .search_tag': (e,t)->
        Session.set('toggle',!Session.get('toggle'))

    'keyup .search_tag': (e,t)->
         if e.which is 13
            val = t.$('.search_tag').val().trim().toLowerCase()
            window.speechSynthesis.speak new SpeechSynthesisUtterance val
            picked_tags.push val   
            t.$('.search_tag').val('')
            # Session.set('sub_doc_query', val)
            Session.set('loading',true)
    
            Meteor.call 'search_subreddit', Router.current().params.group, picked_tags.array(), ->
                Session.set('loading',false)
                Session.set('sub_doc_query', null)
            Meteor.setTimeout ->
                Session.set('toggle',!Session.get('toggle'))
            , 8000
        

    'click .set_grid': (e,t)-> Session.set('view_layout', 'grid')
    'click .set_list': (e,t)-> Session.set('view_layout', 'list')
 
 
 
 
Template.post_card_small.events
    'click .view_post': (e,t)-> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
    'click .call_watson': (e,t)-> 
        Meteor.call 'call_watson',@_id,'data.url','url',@data.url,=>
Template.doc_item.events
    'click .view_post': (e,t)-> 
        Session.set('view_section','main')
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
        # Router.go "/group/#{@group}/p/#{@_id}"

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
 
Template.post_card_small.helpers
    five_tags: -> @tags[..5]
 
 
 
 
 
 
 
 
 
 
 
Template.group_tag_picker.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
Template.group_tag_picker.helpers
    picker_class: ()->
        term = 
            Docs.findOne 
                title:@name.toLowerCase()
        if term
            if term.max_emotion_name
                switch term.max_emotion_name
                    when 'joy' then " basic green"
                    when "anger" then " basic red"
                    when "sadness" then " basic blue"
                    when "disgust" then " basic orange"
                    when "fear" then " basic grey"
                    else "basic grey"
    term: ->
        res = 
            Docs.findOne 
                title:@name.toLowerCase()
        # console.log res
        res
     
     
     
     
Template.group_tag_picker.events
    'click .pick_tag': -> 
        # results.update
        # console.log @
        group_picked_tags.push @name
        $('.search_tag').val('')
        Session.set('skip_value',0)

        
        
        

Template.group_unpick_tag.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
    
Template.group_unpick_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
        
        
Template.group_unpick_tag.events
    'click .group_unpick_tag': -> 
        Session.set('skip',0)
        # console.log @
        group_picked_tags.remove @valueOf()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
    

Template.group_flat_tag_picker.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
Template.group_flat_tag_picker.helpers
    picker_class: ()->
        term = 
            Docs.findOne 
                title:@valueOf().toLowerCase()
        if term
            if term.max_emotion_name
                switch term.max_emotion_name
                    when 'joy' then " basic green"
                    when "anger" then " basic red"
                    when "sadness" then " basic blue"
                    when "disgust" then " basic orange"
                    when "fear" then " basic grey"
                    else "basic grey"
    term: ->
        Docs.findOne 
            title:@valueOf().toLowerCase()
Template.group_flat_tag_picker.events
    'click .pick_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        group_picked_tags.push @valueOf()
        $('.search_group').val('')
        # Router.go "/g/#{Router.current().params.group}"
