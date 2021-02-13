Router.route '/g/:group', (->
    @layout 'layout'
    @render 'group'
    ), name:'group'
Router.route '/:group', (->
    @layout 'layout'
    @render 'group'
    ), name:'group_short'

@picked_tags = new ReactiveArray []
@picked_time_tags = new ReactiveArray []
@picked_location_tags = new ReactiveArray []
@picked_Persons = new ReactiveArray []
@picked_Locations = new ReactiveArray []
@picked_Organizations = new ReactiveArray []


Template.group.onCreated ->
    Session.setDefault('view_layout', 'grid')
    Session.setDefault('sort_key', 'data.created')
    Session.setDefault('sort_direction', -1)
    Session.setDefault('toggle', false)
    
    # Meteor.call 'get_sub_latest', Router.current().params.group, ->
    
    # @autorun => Meteor.subscribe 'shop_from_group', Router.current().params.group
    @autorun => Meteor.subscribe 'tags',
        Router.current().params.group
        picked_tags.array()
        picked_time_tags.array()
        picked_location_tags.array()
        picked_Persons.array()
        picked_Locations.array()
        picked_Organizations.array()
        Session.get('toggle')
    @autorun => Meteor.subscribe 'count', 
        Router.current().params.group
        picked_tags.array()
        picked_time_tags.array()
        picked_location_tags.array()
        picked_Persons.array()
        picked_Locations.array()
        picked_Organizations.array()
    
    @autorun => Meteor.subscribe 'posts', 
        Router.current().params.group
        picked_tags.array()
        picked_time_tags.array()
        picked_location_tags.array()
        picked_Persons.array()
        picked_Locations.array()
        picked_Organizations.array()
        Session.get('group_sort_key')
        Session.get('group_sort_direction')
        Session.get('group_skip_value')
        Session.get('toggle')

Template.group.helpers
    posts: ->
        Docs.find({
            model: $in: ['post','rpost']
            group:Router.current().params.group
        },
            sort:"#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
            limit:25
        )
  
    emotion_avg: -> results.findOne(model:'emotion_avg')
    
    sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
    sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
    emotion_avg: -> results.findOne(model:'emotion_avg')
    
    counter: -> Counts.get 'counter'

    sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
    sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
  
  
    picked_tags: -> picked_tags.array()
    picked_time_tags: -> picked_time_tags.array()
    picked_location_tags: -> picked_location_tags.array()
    picked_people_tags: -> picked_people_tags.array()
  
    result_tags: -> results.find(model:'tag')
    Organizations: -> results.find(model:'Organization')
    Companies: -> results.find(model:'Company')
    HealthConditions: -> results.find(model:'HealthCondition')
    Persons: -> results.find(model:'Person')
    
    time_tags: -> results.find(model:'time_tag')
    location_tags: -> results.find(model:'location_tag')
    Locations: -> results.find(model:'Location')
    authors: -> results.find(model:'author')
   
    domains: -> results.find(model:'group_domain_tag')
   
   
    current_group: -> Router.current().params.group
        
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
    #     Session.set('group_skip_value',0)

    'click .unpick_Location': ->
        picked_Locations.remove @valueOf()
    'click .pick_Location': ->
        picked_Locations.push @name
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
    'click .unpick_time_tag': ->
        picked_time_tags.remove @valueOf()
    'click .pick_time_tag': ->
        picked_time_tags.push @name
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
    'click .unpick_location_tag': ->
        picked_location_tags.remove @valueOf()
    'click .pick_location_tag': ->
        picked_location_tags.push @name
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name

    'click .add_post': ->
        new_id = 
            Docs.insert 
                model:'post'
                group:Router.current().params.group
        Router.go "/#{Router.current().params.group}/p/#{new_id}/edit"
 
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
    
            Meteor.call 'search_subreddit', Router.current().params.group, val, ->
                Session.set('loading',false)
                Session.set('sub_doc_query', null)
            Meteor.setTimeout ->
                Session.set('toggle',!Session.get('toggle'))
            , 8000
        

    'click .set_grid': (e,t)-> Session.set('view_layout', 'grid')
    'click .set_list': (e,t)-> Session.set('view_layout', 'list')
 
 
 
 
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
 
 
Template.post_card_small.events
    'click .view_post': (e,t)-> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title

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
 
 
 
 
 
 
 
 
 
 
 
Template.tag_picker.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
Template.tag_picker.helpers
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
     
     
     
     
     
     
     
     
     
     
     
     
     
            
Template.tag_picker.events
    'click .pick_tag': -> 
        # results.update
        # console.log @
        # window.speechSynthesis.cancel()
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # if @model is 'group_emotion'
        #     picked_emotions.push @name
        # else
        # if @model is 'group_tag'
        picked_tags.push @name
        $('.search_tag').val('')
        Session.set('group_skip_value',0)

        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        # Session.set('group_loading',true)
        Meteor.call 'search_subreddit', Router.current().params.group, @name, ->
            Session.set('group_loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 7000)
        
        
        

Template.unpick_tag.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
    
Template.unpick_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
        
        
Template.unpick_tag.events
    'click .unpick_tag': -> 
        Session.set('skip',0)
        # console.log @
        picked_tags.remove @valueOf()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
    

Template.flat_tag_picker.onCreated ->
    # @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
Template.flat_tag_picker.helpers
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
Template.flat_tag_picker.events
    'click .pick_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        picked_tags.push @valueOf()
        $('.search_group').val('')
        Meteor.call 'search_subreddit', Router.current().params.group, @name, ->
            Session.set('group_loading',false)

        Meteor.setTimeout ->
            Session.set('toggle',!Session.get('toggle'))
        , 8000
