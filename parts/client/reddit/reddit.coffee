@selected_reddit_tags = new ReactiveArray []
@selected_reddit_subreddits = new ReactiveArray []
@selected_subreddit_tags = new ReactiveArray []
@selected_reddit_domain = new ReactiveArray []
@selected_reddit_time_tags = new ReactiveArray []
@selected_reddit_authors = new ReactiveArray []

Template.registerHelper 'embed', ()->
    if @data and @data.media and @data.media.oembed and @data.media.oembed.html
        dom = document.createElement('textarea')
        # dom.innerHTML = doc.body
        dom.innerHTML = @data.media.oembed.html
        return dom.value
        # Docs.update @_id,
        #     $set:
        #         parsed_selftext_html:dom.value

Template.registerHelper 'is_image', ()->
    if @data.domain in ['i.reddit.com','i.redd.it','i.imgur.com','imgur.com','gyfycat.com','v.redd.it','giphy.com']
        # console.log 'is image'
        true
    else 
        # console.log 'is NOT image'
        false
Template.registerHelper 'has_thumbnail', ()->
    console.log @data.thumbnail
    @data.thumbnail.length > 0

Template.registerHelper 'is_youtube', ()->
    @data.domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']




Template.nav.helpers
    reddit_loading: -> Session.get('reddit_loading')

Router.route '/reddit', (->
    @layout 'layout'
    @render 'reddit'
    ), name:'reddit'

Template.reddit.onCreated ->
    Session.setDefault('reddit_skip_value', 0)
    Session.setDefault('reddit_view_layout', 'grid')
    Session.setDefault('sort_key', 'data.created')
    Session.setDefault('sort_direction', -1)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'subrzeddit_user_count', Router.current().params.subreddit
    @autorun => Meteor.subscribe 'reddit_docs', 
        selected_reddit_tags.array()
        selected_subreddit_domain.array()
        selected_reddit_time_tags.array()
        selected_reddit_subreddits.array()
        selected_reddit_authors.array()
        Session.get('sort_key')
        Session.get('sort_direction')
        Session.get('reddit_skip_value')
  
    @autorun => Meteor.subscribe 'reddit_doc_count', 
        Router.current().params.subreddit
        selected_reddit_tags.array()
        selected_reddit_domain.array()
        selected_reddit_time_tags.array()
        selected_reddit_subreddits.array()

    @autorun => Meteor.subscribe 'reddit_tags',
        selected_reddit_tags.array()
        selected_reddit_domain.array()
        selected_reddit_time_tags.array()
        selected_reddit_subreddits.array()
        selected_reddit_authors.array()
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
    # unless @data.watson
    #     Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>

Template.reddit_post_card_small.onRendered ->
    # console.log @
    # unless @data.watson
    #     Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
    unless @time_tags
        Meteor.call 'tagify_time_rpost',@data._id,=>

Template.reddit_page.onCreated ->
    @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)
Template.reddit_page.onRendered ->
    Meteor.call 'get_post_comments', Router.current().params.subreddit, Router.current().params.doc_id, ->

Template.reddit_page.events
    'click .goto_sub': -> 
        Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
            Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->
            Meteor.call 'log_subreddit_view', Router.current().params.subreddit, ->
    'click .call_visual': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'url', ->
    'click .call_meta': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'meta', ->
    'click .call_thumbnail': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'thumb', ->
    'click .goto_ruser': ->
        doc = Docs.findOne Router.current().params.doc_id
        Meteor.call 'get_user_info', doc.data.author, ->
    'click .get_post': ->
        Session.set('view_section','main')
        Meteor.call 'get_reddit_post', Router.current().params.doc_id, @reddit_id, ->

Template.reddit.events
    'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
    'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
    'click .sort_up': (e,t)-> Session.set('sort_direction',1)
    'click .limit_10': (e,t)-> Session.set('limit',10)
    'click .limit_1': (e,t)-> Session.set('limit',1)
   
    'click .show_newest': (e,t)-> 
        Meteor.call 'reddit_new', ->
        Session.set('reddit_view_mode','newest')
        Session.set('sort_key', 'data.created')
    'click .show_hot': (e,t)-> 
        Meteor.call 'reddit_best', ->
        Session.set('reddit_view_mode','hot')
        Session.set('sort_key', 'data.ups')
    'click .show_best': (e,t)->
        Meteor.call 'reddit_best', ->
        Session.set('sort_key', 'data.ups')
        Session.set('reddit_view_mode','best')
        
    # 'click .sort_created': -> 
    #     Session.set('sort_key', 'data.created')
    # 'click .sort_ups': -> 
    #     Session.set('sort_key', 'data.ups')

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
    'click .skip_right': (e,t)-> Session.set('reddit_skip_value', Session.get('reddit_skip_value')+1)

    'click .select_reddit_time_tag': ->
        selected_reddit_time_tags.push @name

    'keyup .search_reddit': (e,t)->
        val = $('.search_reddit').val()
        Session.set('reddit_query', val)
        if e.which is 13 
            selected_reddit_tags.push val
            # window.speechSynthesis.speak new SpeechSynthesisUtterance val

            $('.search_reddit').val('')
            Session.set('reddit_loading',true)
            Meteor.call 'search_reddit', val, ->
                Session.set('reddit_loading',false)
                Session.set('reddit_query', null)
            
Template.reddit.helpers
    reddit_query: -> Session.get('reddit_query')

    domain_selector_class: ->
        if @name in selected_reddit_domain.array() then 'blue' else 'basic'
    sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
    sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
    reddit_result_tags: -> results.find(model:'reddit_tag')
    reddit_domain_tags: -> results.find(model:'reddit_domain_tag')
    reddit_time_tags: -> results.find(model:'reddit_time_tag')
    reddit_subreddits: -> results.find(model:'reddit_subreddit')

    skip_value: -> Session.get('reddit_skip_value')
    
    hot_class: ->
        if Session.equals('reddit_view_mode','hot')
            'black'
        else 
            'basic'
    best_class: ->
        if Session.equals('reddit_view_mode','best')
            'black'
        else 
            'basic'

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
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        Session.set('reddit_loading',true)
        Meteor.call 'search_reddit', @name, ->
            Session.set('reddit_loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 5000)
        
        
        

Template.reddit_unpick_tag.onCreated ->
    
    @autorun => Meteor.subscribe('doc_by_title_small', @data.toLowerCase())
    
Template.reddit_unpick_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
Template.reddit_unpick_tag.events
    'click .unselect_reddit_tag': -> 
        Session.set('skip',0)
        # console.log @
        selected_reddit_tags.remove @valueOf()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
    

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