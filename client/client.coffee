Template.registerHelper 'unique_tags', () ->
    diff = _.difference(@tags, picked_tags.array())
    diff[..7]
    
    
Template.registerHelper 'skv_is', (key,value) -> Session.equals(key,value)
Template.registerHelper 'youtube_parse', (url) ->
    regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    match = @url.match(regExp)
    if match && match[2].length == 11
        match[2]
    else
        null
   
@l = console.log
   
   
Template.print_this.events
    'click .print': ->
        console.log @
   
Template.registerHelper 'thinking_class', ()->
    if Session.get('thinking') then 'disabled' else ''


# Template.registerHelper 'domain_results', ()->results.find(model:'domain')
# Template.registerHelper 'author_results', ()->results.find(model:'author')
# Template.registerHelper 'time_tag_results', ()->results.find(model:'time_tag')
# Template.registerHelper 'subreddit_results', ()-> results.find(model:'subreddit_tag')
# Template.registerHelper 'Location_results', ()-> results.find(model:'Location')
# Template.registerHelper 'person_results', ()-> results.find(model:'person_tag')


Template.registerHelper 'embed', ()->
    if @html
        dom = document.createElement('textarea')
        # dom.innerHTML = doc.body
        dom.innerHTML = @html
        return dom.value
        # Docs.update @_id,
        #     $set:
        #         parsed_selftext_html:dom.value
Template.registerHelper 'inner', ()->
    dom = document.createElement('textarea')
    # dom.innerHTML = doc.body
    dom.innerHTML = @selftext
    return dom.value
    # Docs.update @_id,
    #     $set:
    #         parsed_selftext_html:dom.value

   
   
        
Session.setDefault('loading', false)

Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'



@picked_tags = new ReactiveArray []
# @picked_time_tags = new ReactiveArray []
# @picked_sub_tags = new ReactiveArray []
# @picked_domains = new ReactiveArray []
# @picked_authors = new ReactiveArray []
# @picked_persons = new ReactiveArray []
# @picked_Locations = new ReactiveArray []


Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'home'
    loadingTemplate: 'splash'
    trackPageView: false
	progressTick: false
# 	progressDelay: 100
Router.route '*', -> @render 'home'

# Template.skve.helpers
#     calculated_class: ->
#         if Session.equals(@k,@v) then 'black' else 'basic circular'
# Template.skve.events
#     'click .set_session_v': ->
#         Session.set(@k, @v)

    

# Template.registerHelper 'is_image', ()->
#     if @domain in ['i.reddit.com','i.redd.it','i.imgur.com','imgur.com','gyfycat.com','v.redd.it','giphy.com']
#         true
#     else 
#         false
Template.registerHelper 'has_thumbnail', ()->
    # console.log @data.thumbnail
    @thumbnail.length > 0

Template.registerHelper 'is_youtube', ()->
    @domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']
    
    
Template.registerHelper 'ufrom', (input)-> moment.unix(input).fromNow()







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
            
           
Template.unpick_tag.onCreated ->
    console.log @data
    @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
            

Template.unpick_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                model:'wikipedia'
                title:@valueOf().toLowerCase()
                
        console.log found
        found
Template.unpick_tag.events
    'click .unpick':-> 
        picked_tags.remove @valueOf()
        url = new URL(window.location);
        url.searchParams.set('tags', picked_tags.array());
        window.history.pushState({}, '', url);
        document.title = picked_tags.array()
        Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        Meteor.call 'search_reddit', picked_tags.array(), ->
        Meteor.setTimeout ->
            Session.set('toggle',!Session.get('toggle'))
        , 10000
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()

            
            
            
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
        $('.search').val('')
        url = new URL(window.location)
        url.searchParams.set('tags', picked_tags.array())
        window.history.pushState({}, '', url)
        document.title = picked_tags.array()

        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        Session.set('loading',true)
        Meteor.call 'call_wiki', @name, ->        
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 10000)
        


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
        Router.go "/"
        $('.search').val('')
        url = new URL(window.location)
        url.searchParams.set('tags', picked_tags.array())
        window.history.pushState({}, '', url)
        document.title = picked_tags.array()

        Session.set('loading',true)
        # Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 10000)
        
        
        

Template.registerHelper 'picked_tags', () -> picked_tags.array()
# Template.registerHelper 'picked_authors', () -> picked_authors.array()
# Template.registerHelper 'picked_domains', () -> picked_domains.array()
# Template.registerHelper 'picked_persons', () -> picked_persons.array()
# Template.registerHelper 'picked_Locations', () -> picked_Locations.array()
    
Template.registerHelper 'commafy', (num)-> if num then num.toLocaleString()

    
Template.registerHelper 'trunc', (input) ->
    if input
        input[0..300]
   
   
Template.registerHelper 'emotion_avg', (metric) -> results.findOne(model:'emotion_avg')

Template.registerHelper 'calculated_size', (metric) ->
    # whole = parseInt(@["#{metric}"]*10)
    whole = parseInt(metric*10)
    switch whole
        when 0 then 'f5'
        when 1 then 'f6'
        when 2 then 'f7'
        when 3 then 'f8'
        when 4 then 'f9'
        when 5 then 'f10'
        when 6 then 'f11'
        when 7 then 'f12'
        when 8 then 'f13'
        when 9 then 'f14'
        when 10 then 'f15'
Template.registerHelper 'abs_percent', (num) -> 
    # console.l/og Math.abs(num*100)
    parseInt(Math.abs(num*100))

    
# Template.registerHelper 'connection', () -> Meteor.status()
# Template.registerHelper 'connected', () -> Meteor.status().connected
    
Template.registerHelper 'is_image', ()->
    if @domain in ['i.reddit.com','i.redd.it','i.imgur.com','imgur.com','gyfycat.com','giphy.com']
        true
    else 
        false
Template.registerHelper 'preview_path', ()->
    if @domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']
        @preview and @preview.images[0].source.url
Template.registerHelper 'has_thumbnail', ()->
    # console.log @thumbnail
    @thumbnail not in ['default','self']
        # @thumbnail.length > 0 

Template.registerHelper 'is_youtube', ()->
    @domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']
 
Template.registerHelper 'one_post', ()-> Counts.get('post_counter') is 1
Template.registerHelper 'two_posts', ()-> Counts.get('post_counter') is 2
Template.registerHelper 'two_posts', ()-> Counts.get('post_counter') is 3

  
Template.registerHelper 'tag_term', () ->
    Docs.findOne 
        model:'wikipedia'
        title:@valueOf()



# Template.registerHelper 'skip_is_zero', ()-> Session.equals('skip', 0)
# Template.registerHelper 'key_value', (key,value)-> @["#{key}"] is value



# Template.registerHelper 'lowered', (input)-> input.toLowerCase()
# Template.registerHelper 'money_format', (input)-> (input/100).toFixed()


# Template.registerHelper 'fixed', (number)->
#     # console.log number
#     number.toFixed(2)
#     # (number*100).toFixed()


Template.registerHelper 'is_loading', -> Session.get 'loading'
# Template.registerHelper 'long_time', (input)-> 
#     moment(input).format("h:mm a")
Template.registerHelper 'long_date', (input)-> moment(input).format("dddd, MMMM Do h:mm a")
# Template.registerHelper 'home_long_date', (input)-> moment(input).format("dd, MMM Do h:mm a")
# Template.registerHelper 'short_date', (input)-> moment(input).format("dddd, MMMM Do")
# Template.registerHelper 'med_date', (input)-> moment(input).format("MMM D 'YY")
# # Template.registerHelper 'medium_date', (input)-> moment(input).format("MMMM Do YYYY")
# Template.registerHelper 'medium_date', (input)-> moment(input).format("dddd, MMMM Do")
# Template.registerHelper 'today', -> moment(Date.now()).format("dddd, MMMM Do a")
# Template.registerHelper 'int', (input)-> input.toFixed(0)
Template.registerHelper 'when', ()-> moment(@_timestamp).fromNow()
# Template.registerHelper 'cal_time', (input)-> moment(input).calendar()

# Template.registerHelper 'current_month', ()-> moment(Date.now()).format("MMMM")
# Template.registerHelper 'current_day', ()-> moment(Date.now()).format("DD")


Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment
Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()


Template.registerHelper 'lowered', (input)-> input.toLowerCase()
Template.registerHelper 'money_format', (input)-> (input/100).toFixed(2)


Template.registerHelper 'kv_is', (key, value) ->
    @["#{key}"] is value
Template.registerHelper 'post_header_class', () ->
    if @max_emotion_name
        if @max_emotion_name is 'sadness' then 'blue'
        else if @max_emotion_name is 'anger' then 'red'
        else if @max_emotion_name is 'joy' then 'green'
        else if @max_emotion_name is 'disgust' then 'orange'
    else if @doc_sentiment_label is 'positive'
        'green'
    else if @doc_sentiment_label is 'negative'
        'red'
    



Template.registerHelper 'template_subs_ready', () ->
    Template.instance().subscriptionsReady()

# Template.registerHelper 'global_subs_ready', () ->
#     Session.get('global_subs_ready')



Template.registerHelper 'fixed0', (number)-> if number then number.toFixed().toLocaleString()
Template.registerHelper 'fixed', (number)-> if number then number.toFixed(2)

    
Template.registerHelper 'when', ()-> moment(@_timestamp).fromNow()
Template.registerHelper 'seven_tags', ()-> 
    cleaned = _.difference(@tags, picked_tags.array())
    # console.log cleaned
    if cleaned
        cleaned[..7]
Template.registerHelper 'five_tags', ()-> 
    cleaned = _.difference(@tags, picked_tags.array())
    # console.log cleaned
    if cleaned
        cleaned[..5]

# Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
# Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")


Template.registerHelper 'current_doc', () ->
    found_doc_by_id = Docs.findOne Router.current().params.doc_id
    found_doc_by_slug = 
        Docs.findOne 
            slug:Router.current().params.slug
    if found_doc_by_id
        found_doc_by_id
    else if found_doc_by_slug
        found_doc_by_slug

Template.registerHelper 'current_subreddit', () ->
    Docs.findOne 
        model:'subreddit'
        "data.display_name":Router.current().params.subreddit


Template.registerHelper 'result_tags', () -> results.find(model:'tag')


# Template.registerHelper 'lowered_title', ()-> 
#     if @data
#         if @title
#             @title.toLowerCase()


Template.registerHelper 'ufrom', (input)-> moment.unix(input).fromNow()


Template.registerHelper 'session_key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    Session.equals key,value

Template.registerHelper 'key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    @["#{key}"] is value



Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)


Template.registerHelper 'dev', -> Meteor.isDevelopment
# Template.registerHelper 'fixed', (number)->
#     # console.log number
#     number.toFixed(2)
#     # (number*100).toFixed()
Template.registerHelper 'to_percent', (number)->
    # console.log number
    (number*100).toFixed()


Template.registerHelper 'session_is', (key)->
    Session.get(key)


Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'from_now', (input)-> moment(input).fromNow()