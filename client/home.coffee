@home_picked_tags = new ReactiveArray []
@picked_time_tags = new ReactiveArray []
@picked_groups = new ReactiveArray []
@picked_location_tags = new ReactiveArray []
@picked_Persons = new ReactiveArray []
@picked_Locations = new ReactiveArray []
@picked_Organizations = new ReactiveArray []


Template.home.onCreated ->
    Session.setDefault('view_layout', 'grid')
    Session.setDefault('sort_key', 'data.created')
    Session.setDefault('sort_direction', -1)
    Session.setDefault('toggle', false)
    
    # @autorun => Meteor.subscribe 'shop_from_home', Router.current().params.home
    @autorun => Meteor.subscribe 'tags',
        null
        home_picked_tags.array()
        picked_groups.array()
        picked_time_tags.array()
        picked_location_tags.array()
        picked_Persons.array()
        picked_Locations.array()
        picked_Organizations.array()
        Session.get('toggle')
    @autorun => Meteor.subscribe 'count', 
        null
        home_picked_tags.array()
        picked_groups.array()
        picked_time_tags.array()
        picked_location_tags.array()
        picked_Persons.array()
        picked_Locations.array()
        picked_Organizations.array()
    
    @autorun => Meteor.subscribe 'posts', 
        null
        home_picked_tags.array()
        picked_groups.array()
        picked_time_tags.array()
        picked_location_tags.array()
        picked_Persons.array()
        picked_Locations.array()
        picked_Organizations.array()
        Session.get('sort_key')
        Session.get('sort_direction')
        Session.get('skip_value')
        Session.get('toggle')

Template.home.helpers
    posts: ->
        Docs.find({
            model: 'rpost'
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
  
  
    home_picked_tags: -> home_picked_tags.array()
    picked_time_tags: -> picked_time_tags.array()
    picked_location_tags: -> picked_location_tags.array()
    picked_people_tags: -> picked_people_tags.array()
    picked_groups: -> picked_groups.array()
  
    result_tags: -> results.find(model:'tag')
    group_results: -> results.find(model:'group')
    Organizations: -> results.find(model:'Organization')
    Companies: -> results.find(model:'Company')
    HealthConditions: -> results.find(model:'HealthCondition')
    Persons: -> results.find(model:'Person')
    
    time_tags: -> results.find(model:'time_tag')
    location_tags: -> results.find(model:'location_tag')
    Locations: -> results.find(model:'Location')
    authors: -> results.find(model:'author')
   
    domains: -> results.find(model:'home_domain_tag')
   
        
Template.home.events
    # 'click .unpick_home_tag': -> 
    #     Session.set('skip',0)
    #     # console.log @
    #     home_picked_tags.remove @valueOf()
    #     # window.speechSynthesis.speak new SpeechSynthesisUtterance home_picked_tags.array().toString()

    # 'click .pick_tag': -> 
    #     # results.update
    #     # console.log @
    #     # window.speechSynthesis.cancel()
    #     window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    #     # if @model is 'home_emotion'
    #     #     picked_emotions.push @name
    #     # else
    #     # if @model is 'home_tag'
    #     home_picked_tags.push @name
    #     $('.search_tag').val('')
    #     Session.set('skip_value',0)

    'click .unpick_group': ->
        picked_groups.remove @valueOf()
    'click .pick_group': ->
        picked_groups.push @name
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
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
                home:Router.current().params.home
        Router.go "/#{Router.current().params.home}/p/#{new_id}/edit"
 
    'focus .search_tag': (e,t)->
        Session.set('toggle',!Session.get('toggle'))

    'keyup .search_tag': (e,t)->
         if e.which is 13
            val = t.$('.search_tag').val().trim().toLowerCase()
            window.speechSynthesis.speak new SpeechSynthesisUtterance val
            home_picked_tags.push val   
            t.$('.search_tag').val('')
            # Session.set('sub_doc_query', val)
            Session.set('loading',true)
    
            Meteor.call 'search_reddit', home_picked_tags.array(), ->
                Session.set('loading',false)
                Session.set('sub_doc_query', null)
            Meteor.setTimeout ->
                Session.set('toggle',!Session.get('toggle'))
            , 8000
        

    'click .set_grid': (e,t)-> Session.set('view_layout', 'grid')
    'click .set_list': (e,t)-> Session.set('view_layout', 'list')
 
 
 
 
Template.home_post_card_small.events
    'click .view_post': (e,t)-> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
    'click .call_watson': (e,t)-> 
        Meteor.call 'call_watson',@_id,'data.url','url',@data.url,=>
Template.home_doc_item.events
    'click .view_post': (e,t)-> 
        Session.set('view_section','main')
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
        # Router.go "/home/#{@home}/p/#{@_id}"

Template.home_doc_item.onRendered ->
    # console.log @
    unless @data.watson
        Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>

Template.home_post_card_small.onRendered ->
    # console.log @
    unless @data.watson
        Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
    unless @data.time_tags
        Meteor.call 'tagify_time_rpost',@data._id,=>
 
Template.home_post_card_small.helpers
    five_tags: -> @tags[..5]
 
 
 
 
 
 
 
 
 
 
 
Template.home_tag_picker.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
Template.home_tag_picker.helpers
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
     
     
     
     
Template.home_tag_picker.events
    'click .home_pick_tag': -> 
        # results.update
        # console.log @
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # if @model is 'home_emotion'
        #     picked_emotions.push @name
        # else
        # if @model is 'home_tag'
        home_picked_tags.push @name
        $('.search_tag').val('')
        Session.set('skip_value',0)

        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        window.speechSynthesis.speak new SpeechSynthesisUtterance home_picked_tags.array().toString()
        Session.set('loading',true)
        Meteor.call 'search_reddit', home_picked_tags.array(), ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 7000)
        
        
        

Template.home_unpick_tag.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
    
Template.home_unpick_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
        
        
Template.home_unpick_tag.events
    'click .unpick_tag': -> 
        Session.set('skip',0)
        # console.log @
        home_picked_tags.remove @valueOf()
        window.speechSynthesis.speak new SpeechSynthesisUtterance home_picked_tags.array().toString()
        Session.set('loading',true)
        Meteor.call 'search_reddit', home_picked_tags.array(), ->
            Session.set('loading',false)


Template.flat_home_tag_picker.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
Template.flat_home_tag_picker.helpers
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
Template.flat_home_tag_picker.events
    'click .pick_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        home_picked_tags.push @valueOf()
        $('.search_home').val('')
        Session.set('loading',true)
        Meteor.call 'search_reddit', home_picked_tags.array(), ->
            Session.set('loading',false)
        Router.go "/#{Router.current().params.home}"
        window.speechSynthesis.speak new SpeechSynthesisUtterance home_picked_tags.array()
        Meteor.setTimeout ->
            Session.set('toggle',!Session.get('toggle'))
        , 8000
