Router.route '/r/:subreddit', (->
    @layout 'layout'
    @render 'subreddit'
    ), name:'subreddit'

Router.route '/r/:subreddit/post/:doc_id', (->
    @layout 'layout'
    @render 'rpage'
    ), name:'rpage'


Template.subreddit_best.onCreated ->
    @autorun => Meteor.subscribe 'subreddit_best', Router.current().params.subreddit
Template.subreddit_newest.onCreated ->
    @autorun => Meteor.subscribe 'subreddit_newest', Router.current().params.subreddit

Template.subreddit_best.helpers
    sub_best_docs: ->
        Docs.find {
            model:'rpost'
            subreddit:Router.current().params.subreddit
        }, 
            sort:"data.ups":-1
            limit:7
   
Template.subreddit_newest.helpers
    sub_newest_docs: ->
        Docs.find {
            model:'rpost'
            subreddit:Router.current().params.subreddit
        }, 
            sort:"data.created":-1
            limit:7
            
            
Template.subreddit.onCreated ->
    Session.setDefault('view_layout', 'grid')
    Session.setDefault('sort_key', 'data.created')
    Session.setDefault('sort_direction', -1)
    Session.setDefault('location_query', null)
    # @autorun => Meteor.subscribe 'subrzeddit_user_count', Router.current().params.subreddit
    @autorun => Meteor.subscribe 'subreddit_by_param', Router.current().params.subreddit
    @autorun => Meteor.subscribe 'sub_docs', 
        Router.current().params.subreddit
        picked_sub_tags.array()
        picked_domains.array()
        picked_time_tags.array()
        picked_authors.array()
        Session.get('sort_key')
        Session.get('sort_direction')
  
    @autorun => Meteor.subscribe 'sub_doc_count', 
        Router.current().params.subreddit
        picked_sub_tags.array()
        picked_domains.array()
        picked_time_tags.array()
        picked_authors.array()

    @autorun => Meteor.subscribe 'subreddit_result_tags',
        Router.current().params.subreddit
        picked_sub_tags.array()
        picked_domains.array()
        picked_time_tags.array()
        picked_authors.array()
        Session.get('sort_key')
        Session.get('sort_direction')
        Session.get('toggle')
    # Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->

    # Meteor.call 'log_subreddit_view', Router.current().params.subreddit, ->
    @autorun => Meteor.subscribe 'avg_emotions',
        Router.current().params.subreddit
        picked_sub_tags.array()
        ()->Session.set('ready',true)

Template.sub_post_card.events
    'click .view_post': (e,t)-> 
        Session.set('view_section','main')
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
        Router.go "/r/#{@subreddit}/post/#{@_id}"

Template.subreddit_doc_item.onRendered ->
    # unless @data.watson
    #     Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>

Template.sub_post_card.onRendered ->
    # unless @data.doc_sentiment_label
    #     Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
    # unless @data.time_tags
    #     Meteor.call 'tagify_time_rpost',@data._id,=>


Template.sort_direction_button.events
    'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
    'click .sort_up': (e,t)-> Session.set('sort_direction',1)


Template.subreddit.events
    'click .sort_created': -> 
        Session.set('sort_key', 'data.created')
        Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->
    'click .sort_ups': -> 
        Session.set('sort_key', 'data.ups')
        Meteor.call 'get_sub_best', Router.current().params.subreddit, ->
    'click .download': ->
        Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
    
    'click .pull_latest': ->
        Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->
    'click .get_info': ->
        l 'dl'
        Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
    # 'click .set_grid': (e,t)-> Session.set('view_layout', 'grid')
    # 'click .set_list': (e,t)-> Session.set('view_layout', 'list')

    'keyup .search_subreddit': (e,t)->
        val = $('.search_subreddit').val()
        Session.set('sub_doc_query', val)
        if e.which is 13 
            picked_sub_tags.push val
            # window.speechSynthesis.speak new SpeechSynthesisUtterance val

            $('.search_subreddit').val('')
            Session.set('loading',true)
            Meteor.call 'search_subreddit', Router.current().params.subreddit, val, ->
                Session.set('loading',false)
                Session.set('sub_doc_query', null)
            
Template.subreddit.helpers

    domain_selector_class: ->
        if @name in picked_domains.array() then 'blue' else 'basic'
    sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
    sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
    subreddit_result_tags: -> results.find(model:'subreddit_result_tag')
    subreddit_time_tags: -> results.find(model:'subreddit_time_tag')

    picked_sub_tags: -> picked_sub_tags.array()
    current_sub: -> Router.current().params.subreddit
    
    subreddit_doc: ->
        Docs.findOne
            model:'subreddit'
            "data.display_name":Router.current().params.subreddit
            # name:Router.current().params.subreddit
    sub_docs: ->
        Docs.find({
            model:'rpost'
            "data.subreddit":Router.current().params.subreddit
        },
            sort:"#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
            limit:20)

    sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
    sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
    emotion_avg: -> results.findOne(model:'emotion_avg')

    post_count: -> Counts.get('sub_doc_counter')


            


Template.sub_tag_picker.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
Template.sub_tag_picker.helpers
    selector_class: ()->
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
        Docs.findOne 
            title:@name.toLowerCase()
            
            
Template.sub_tag_picker.events
    'click .select_sub_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # if @model is 'subreddit_emotion'
        #     picked_emotions.push @name
        # else
        # if @model is 'subreddit_tag'
        picked_sub_tags.push @name
        $('.search_subreddit').val('')
        
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        Session.set('loading',true)
        Meteor.call 'search_subreddit', Router.current().params.subreddit, @name, ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 5000)
        
        
        

Template.sub_unpick_tag.onCreated ->
    # @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
    
Template.sub_unpick_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
Template.sub_unpick_tag.events
    'click .unselect_sub_tag': -> 
        Session.set('skip',0)
        picked_sub_tags.remove @valueOf()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        Session.set('loading',true)
        Meteor.call 'search_subreddit', Router.current().params.subreddit, picked_sub_tags.array(), ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 5000)


Template.flat_sub_tag_picker.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
Template.flat_sub_tag_picker.helpers
    selector_class: ()->
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
Template.flat_sub_tag_picker.events
    'click .select_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        picked_sub_tags.push @valueOf()
        Router.go "/r/#{Router.current().params.subreddit}/"
        $('.search_subreddit').val('')
        Session.set('loading',true)
        Meteor.call 'search_subreddit', Router.current().params.subreddit, @valueOf(), ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 700)
Template.flat_sub_user_tag_selector.events
    'click .select_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        picked_sub_tags.push @valueOf()
        parent = Template.parentData()
        Router.go "/r/#{parent.subreddit}/"
        $('.search_subreddit').val('')
        Session.set('loading',true)
        Meteor.call 'search_subreddit', parent.subreddit, @valueOf(), ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 700)



