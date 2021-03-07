Template.registerHelper 'unique_tags', () ->
    _.difference(@tags, picked_tags.array())

Template.registerHelper 'skv_is', (key,value) -> Session.equals(key,value)
Template.registerHelper 'youtube_parse', (url) ->
    regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    match = @data.url.match(regExp)
    if match && match[2].length == 11
        match[2]
    else
        null
   
Template.print_this.events
    'click .print': ->
        console.log @
   
   
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

Template.registerHelper 'is_youtube', ()->
    @data.domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']

    
   
   
        
Session.setDefault('loading', false)

Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'




@picked_tags = new ReactiveArray []
Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'home'
    loadingTemplate: 'splash'
    trackPageView: false
	progressTick: false
# 	progressDelay: 100
Router.route '*', -> @render 'home'



Template.card.onCreated ->
    # console.log @data
    unless @watson
        Meteor.call 'call_watson', @data._id, ->
    
Template.home.onCreated ->
    Session.setDefault('nsfw', false)
    @autorun -> Meteor.subscribe('alpha_combo',picked_tags.array())

    # Meteor.call 'call_watson', @data._id, ->
    
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'rposts', 
        picked_tags.array()
        Session.get('nsfw')
        Session.get('toggle')
  
    # @autorun => Meteor.subscribe 'reddit_post_count', 
    #     picked_tags.array()
    #     picked_reddit_domain.array()
    #     picked_rtime_tags.array()
    #     picked_subreddits.array()
    params = new URLSearchParams(window.location.search);
    
    tags = params.get("tags");
    if tags
        split = tags.split(',')
        if tags.length > 0
            for tag in split 
                unless tag in picked_tags.array()
                    picked_tags.push tag
            Session.set('loading',true)
            Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('loading',false)
            Meteor.setTimeout ->
                Session.set('toggle', !Session.get('toggle'))
            , 7000    
            
    # console.log(name)
    
    @autorun => Meteor.subscribe 'wiki_doc', 
        picked_tags.array()
    @autorun => Meteor.subscribe 'post_count', 
        picked_tags.array()


    @autorun => Meteor.subscribe 'tags',
        picked_tags.array()
        Session.get('nsfw')
        Session.get('toggle')
        

Template.registerHelper 'is_image', ()->
    if @domain in ['i.reddit.com','i.redd.it','i.imgur.com','imgur.com','gyfycat.com','v.redd.it','giphy.com']
        true
    else 
        false
Template.registerHelper 'has_thumbnail', ()->
    console.log @data.thumbnail
    @data.thumbnail.length > 0

Template.registerHelper 'is_youtube', ()->
    @data.domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']
Template.registerHelper 'ufrom', (input)-> moment.unix(input).fromNow()


Template.home.events
    'click .make_nsfw': (e,t)-> Session.set('nsfw', true)
    'click .make_safe': (e,t)-> Session.set('nsfw', false)
        
    'keyup .search_reddit': (e,t)->
        val = $('.search_reddit').val()
        Session.set('reddit_query', val)
        if e.which is 13 
            picked_tags.push val
            # window.speechSynthesis.speak new SpeechSynthesisUtterance val
            Meteor.call 'call_alpha', picked_tags.array().toString(), ->

            $('.search_reddit').val('')
            Session.set('reddit_loading',true)
            Meteor.call 'search_reddit', val, ->
                Session.set('reddit_loading',false)
                Session.set('reddit_query', null)
    'click .search_tag': (e,t)->
        Session.set('toggle', !Session.get('toggle'))

    'keyup .search_tag': (e,t)->
         if e.which is 13
            val = t.$('.search_tag').val().trim().toLowerCase()
            Session.set('loading',true)
            picked_tags.push val   
            Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('loading',false)
            Meteor.setTimeout ->
                Session.set('toggle', !Session.get('toggle'))
            , 10000    
            url = new URL(window.location);
            url.searchParams.set('tags', picked_tags.array());
            window.history.pushState({}, '', url);
            document.title = picked_tags.array()
            Meteor.call 'call_alpha', picked_tags.array().toString(), ->
            
            t.$('.search_tag').val('')
            t.$('.search_tag').focus()
            # Session.set('sub_doc_query', val)



Template.card.events
    'click .flat_tag_pick': -> 
        picked_tags.push @valueOf()
        Meteor.call 'search_reddit', picked_tags.array(), ->
        url = new URL(window.location);
        url.searchParams.set('tags', picked_tags.array());
        window.history.pushState({}, '', url);
        document.title = picked_tags.array()
        Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        Meteor.setTimeout ->
            Session.set('toggle',!Session.get('toggle'))
        , 7000

Template.home.helpers
    picked_tags: -> picked_tags.array()
    
    wikis: ->
        Docs.find({
            model:'wikipedia'
            # subreddit:Router.current().params.subreddit
        },
            sort:title:-1
            limit:21)
    rposts: ->
        Docs.find({
            model:'rpost'
            # subreddit:Router.current().params.subreddit
        },
            sort:"data.ups":-1
            limit:21)
    post_count: -> Counts.get 'post_count'
    
    # nightmode_class: -> if Session.get('nightmode') then 'invert'
    
    
    result_tags: -> results.find(model:'tag')

    is_nsfw: -> Session.get('nsfw')
            


Template.tag_picker.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
Template.tag_picker.helpers
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
            
            
Template.tag_picker.events
    'click .pick_tag': -> 
        # results.update
        # console.log @
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # if @model is 'reddit_emotion'
        #     picked_emotions.push @name
        # else
        # if @model is 'reddit_tag'
        picked_tags.push @name
        $('.search_subreddit').val('')
        
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        Session.set('reddit_loading',true)
        Meteor.call 'search_reddit', @name, ->
            Session.set('reddit_loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 5000)
        
        
        


Template.flat_tag_picker.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
Template.flat_tag_picker.helpers
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
Template.flat_tag_picker.events
    'click .select_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        picked_tags.push @valueOf()
        # Router.go "/r/#{Router.current().params.subreddit}/"
        $('.search_subreddit').val('')
        url = new URL(window.location)
        url.searchParams.set('tags', picked_tags.array())
        window.history.pushState({}, '', url)
        document.title = picked_tags.array()

        Session.set('loading',true)
        Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        Meteor.call 'search_reddit', @valueOf(), ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 10000)
        
        
        
