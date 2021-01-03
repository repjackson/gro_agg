@selected_reddit_tags = new ReactiveArray []
@selected_subreddit_tags = new ReactiveArray []
@selected_reddit_domain = new ReactiveArray []


Router.route '/reddit', (->
    @layout 'layout'
    @render 'reddit'
    ), name:'reddit'

Template.reddit.onCreated ->
    Session.setDefault('reddit_view_layout', 'grid')
    Session.setDefault('sort_key', 'data.created')
    Session.setDefault('sort_direction', -1)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'subrzeddit_user_count', Router.current().params.subreddit
    @autorun => Meteor.subscribe 'reddit_docs', 
        selected_reddit_tags.array()
        selected_subreddit_domain.array()
        selected_reddit_domain.array()
        Session.get('sort_key')
        Session.get('sort_direction')
  
    @autorun => Meteor.subscribe 'reddit_doc_count', 
        Router.current().params.subreddit
        selected_reddit_tags.array()
        selected_reddit_domain.array()

    @autorun => Meteor.subscribe 'reddit_result_tags',
        Router.current().params.subreddit
        selected_reddit_tags.array()
        selected_reddit_domain.array()
        Session.get('toggle')
    Meteor.call 'get_reddit_latest', Router.current().params.subreddit, ->

    Meteor.call 'log_reddit_view', Router.current().params.subreddit, ->
    @autorun => Meteor.subscribe 'agg_sentiment_subreddit',
        Router.current().params.subreddit
        selected_reddit_tags.array()
        ()->Session.set('ready',true)

Template.reddit_doc_item.events
    'click .view_post': (e,t)-> 
        Session.set('view_section','main')
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
        # Router.go "/subreddit/#{@subreddit}/post/#{@_id}"

Template.reddit_doc_item.onRendered ->
    # console.log @
    unless @data.watson
        Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>

Template.reddit_post_card_small.onRendered ->
    # console.log @
    unless @data.watson
        Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>


Template.reddit.events
    'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
    'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
    'click .sort_up': (e,t)-> Session.set('sort_direction',1)
    'click .limit_10': (e,t)-> Session.set('limit',10)
    'click .limit_1': (e,t)-> Session.set('limit',1)

    'click .sort_created': -> Session.set('sort_key', 'data.created')
    'click .sort_ups': -> Session.set('sort_key', 'data.ups')
    'click .download': ->
        Meteor.call 'get_reddit_info', Router.current().params.subreddit, ->
    
    'click .pull_latest': ->
        # console.log 'latest'
        Meteor.call 'get_reddit_latest', Router.current().params.subreddit, ->
    'click .get_info': ->
        # console.log 'dl'
        Meteor.call 'get_reddit_info', Router.current().params.subreddit, ->
    'click .set_grid': (e,t)-> Session.set('reddit_view_layout', 'grid')
    'click .set_list': (e,t)-> Session.set('reddit_view_layout', 'list')

    'keyup .search_subreddit': (e,t)->
        val = $('.search_subreddit').val()
        Session.set('reddit_doc_query', val)
        if e.which is 13 
            selected_reddit_tags.push val
            # window.speechSynthesis.speak new SpeechSynthesisUtterance val

            $('.search_subreddit').val('')
            Session.set('loading',true)
            Meteor.call 'search_subreddit', Router.current().params.subreddit, val, ->
                Session.set('loading',false)
                Session.set('reddit_doc_query', null)
            
Template.reddit.helpers
    domain_selector_class: ->
        if @name in selected_reddit_domain.array() then 'blue' else 'basic'
    sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
    sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
    reddit_result_tags: -> results.find(model:'reddit_result_tag')
    reddit_domain_tags: -> results.find(model:'reddit_domain_tag')

    selected_reddit_tags: -> selected_reddit_tags.array()
    
    # reddit_doc: ->
    #     Docs.findOne
    #         model:'subreddit'
    #         "data.display_name":Router.current().params.subreddit
    reddit_docs: ->
        Docs.find({
            model:'rpost'
            # subreddit:Router.current().params.subreddit
        },
            sort:"#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
            limit:20)
    emotion_avg: -> results.findOne(model:'emotion_avg')

    sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
    sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
    emotion_avg: -> results.findOne(model:'emotion_avg')

    post_count: -> Counts.get('reddit_doc_counter')


            


Template.reddit_tag_selector.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
Template.reddit_tag_selector.helpers
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
            
            
Template.reddit_tag_selector.events
    'click .select_tag': -> 
        # results.update
        # console.log @
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # if @model is 'reddit_emotion'
        #     selected_emotions.push @name
        # else
        # if @model is 'reddit_tag'
        selected_reddit_tags.push @name
        $('.search_subreddit').val('')
        
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        Session.set('loading',true)
        Meteor.call 'search_subreddit', Router.current().params.subreddit, @name, ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 5000)
        
        
        

Template.reddit_unselect_tag.onCreated ->
    
    @autorun => Meteor.subscribe('doc_by_title_small', @data.toLowerCase())
    
Template.reddit_unselect_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
Template.reddit_unselect_tag.events
    'click .unselect_reddit_tag': -> 
        Session.set('skip',0)
        console.log @
        selected_reddit_tags.remove @valueOf()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
    

Template.flat_reddit_tag_selector.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title_small', @data.valueOf().toLowerCase())
Template.flat_reddit_tag_selector.helpers
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
Template.flat_reddit_tag_selector.events
    'click .select_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        selected_reddit_tags.push @valueOf()
        Router.go "/r/#{Router.current().params.subreddit}/"
        $('.search_subreddit').val('')
        Session.set('loading',true)
        Meteor.call 'search_subreddit', Router.current().params.subreddit, @valueOf(), ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 3000)
