@selected_subreddit_tags = new ReactiveArray []
@selected_subreddit_domain = new ReactiveArray []


Router.route '/r/:subreddit', (->
    @layout 'layout'
    @render 'subreddit'
    ), name:'subreddit'

Router.route '/r/:subreddit/post/:doc_id', (->
    @layout 'layout'
    @render 'reddit_page'
    ), name:'reddit_page'
    

Template.subreddit.onCreated ->
    Session.setDefault('subreddit_view_layout', 'grid')
    Session.setDefault('sort_key', 'data.created')
    Session.setDefault('sort_direction', -1)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'subrzeddit_user_count', Router.current().params.subreddit
    @autorun => Meteor.subscribe 'subreddit_by_param', Router.current().params.subreddit
    @autorun => Meteor.subscribe 'sub_docs_by_name', 
        Router.current().params.subreddit
        selected_subreddit_tags.array()
        selected_subreddit_domain.array()
        Session.get('sort_key')
        Session.get('sort_direction')
  
    @autorun => Meteor.subscribe 'sub_doc_count', 
        Router.current().params.subreddit
        selected_subreddit_tags.array()
        selected_subreddit_domain.array()

    @autorun => Meteor.subscribe 'subreddit_result_tags',
        Router.current().params.subreddit
        selected_subreddit_tags.array()
        selected_subreddit_domain.array()
        Session.get('toggle')
    Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->

    Meteor.call 'log_subreddit_view', Router.current().params.subreddit, ->
    @autorun => Meteor.subscribe 'agg_sentiment_subreddit',
        Router.current().params.subreddit
        selected_subreddit_tags.array()
        ()->Session.set('ready',true)

Template.subreddit_doc_item.events
    'click .view_post': (e,t)-> 
        Session.set('view_section','main')
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
        # Router.go "/subreddit/#{@subreddit}/post/#{@_id}"

Template.subreddit_doc_item.onRendered ->
    # console.log @
    unless @data.watson
        Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>

Template.subreddit_post_card_small.onRendered ->
    # console.log @
    unless @data.watson
        Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>


Template.subreddit.events
    'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
    'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
    'click .sort_up': (e,t)-> Session.set('sort_direction',1)
    'click .limit_10': (e,t)-> Session.set('limit',10)
    'click .limit_1': (e,t)-> Session.set('limit',1)

    'click .sort_created': -> Session.set('sort_key', 'data.created')
    'click .sort_ups': -> Session.set('sort_key', 'data.ups')
    'click .download': ->
        Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
    
    'click .pull_latest': ->
        # console.log 'latest'
        Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->
    'click .get_info': ->
        # console.log 'dl'
        Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
    'click .set_grid': (e,t)-> Session.set('subreddit_view_layout', 'grid')
    'click .set_list': (e,t)-> Session.set('subreddit_view_layout', 'list')

    'keyup .search_subreddit': (e,t)->
        val = $('.search_subreddit').val()
        Session.set('sub_doc_query', val)
        if e.which is 13 
            selected_subreddit_tags.push val
            # window.speechSynthesis.speak new SpeechSynthesisUtterance val

            $('.search_subreddit').val('')
            Session.set('loading',true)
            Meteor.call 'search_subreddit', Router.current().params.subreddit, val, ->
                Session.set('loading',false)
                Session.set('sub_doc_query', null)
            
Template.subreddit.helpers
    domain_selector_class: ->
        if @name in selected_subreddit_domain.array() then 'blue' else 'basic'
    sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
    sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
    subreddit_result_tags: -> results.find(model:'subreddit_result_tag')
    subreddit_domain_tags: -> results.find(model:'subreddit_domain_tag')

    selected_sub_tags: -> selected_subreddit_tags.array()
    
    subreddit_doc: ->
        Docs.findOne
            model:'subreddit'
            "data.display_name":Router.current().params.subreddit
    sub_docs: ->
        Docs.find({
            model:'rpost'
            subreddit:Router.current().params.subreddit
        },
            sort:"#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
            limit:20)
    emotion_avg: -> results.findOne(model:'emotion_avg')

    sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
    sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
    emotion_avg: -> results.findOne(model:'emotion_avg')

    post_count: -> Counts.get('sub_doc_counter')


            


Template.sub_tag_selector.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
Template.sub_tag_selector.helpers
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
            
            
Template.sub_tag_selector.events
    'click .select_tag': -> 
        # results.update
        # console.log @
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # if @model is 'subreddit_emotion'
        #     selected_emotions.push @name
        # else
        # if @model is 'subreddit_tag'
        selected_subreddit_tags.push @name
        $('.search_subreddit').val('')
        
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        Session.set('loading',true)
        Meteor.call 'search_subreddit', Router.current().params.subreddit, @name, ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 5000)
        
        
        

Template.sub_unselect_tag.onCreated ->
    
    @autorun => Meteor.subscribe('doc_by_title_small', @data.toLowerCase())
    
Template.sub_unselect_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
Template.sub_unselect_tag.events
    'click .unselect_sub_tag': -> 
        Session.set('skip',0)
        console.log @
        selected_subreddit_tags.remove @valueOf()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
    

Template.flat_sub_tag_selector.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title_small', @data.valueOf().toLowerCase())
Template.flat_sub_tag_selector.helpers
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
Template.flat_sub_tag_selector.events
    'click .select_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        selected_subreddit_tags.push @valueOf()
        Router.go "/r/#{Router.current().params.subreddit}/"
        $('.search_subreddit').val('')
        Session.set('loading',true)
        Meteor.call 'search_subreddit', Router.current().params.subreddit, @valueOf(), ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 3000)
Template.flat_sub_ruser_tag_selector.events
    'click .select_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        selected_subreddit_tags.push @valueOf()
        parent = Template.parentData()
        Router.go "/r/#{parent.subreddit}/"
        $('.search_subreddit').val('')
        Session.set('loading',true)
        Meteor.call 'search_subreddit', parent.subreddit, @valueOf(), ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 3000)
