Template.registerHelper 'youtube_parse', (url) ->
    regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    match = @data.url.match(regExp)
    if match && match[2].length == 11
        match[2]
    else
        null
   
Session.setDefault('loading', false)
Template.body.events
    'click .set_main': -> Session.set('view_section','main')
    # 'click a': ->
        
        
    'click .say_body': ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @innerText
        
    # 'click .say': ->
    #     window.speechSynthesis.speak new SpeechSynthesisUtterance @innerText
        
# Template.say.events
#     'click .quiet': (e,t)->
#         Session.set('talking',false)
#         window.speechSynthesis.cancel()
#     'click .say_this': (e,t)->
#         Session.set('talking',true)
#         dom = document.createElement('textarea')
#         # dom.innerHTML = doc.body
#         dom.innerHTML = Template.parentData()["#{@k}"]
#         text1 = $("<textarea/>").html(dom.innerHTML).text();
#         text2 = $("<textarea/>").html(text1).text();
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance text2
# Meteor.startup ->
#     if Meteor.isDevelopment
#         window.speechSynthesis.speak new SpeechSynthesisUtterance 'dao'
        

Router.route '/', (->
    @layout 'layout'
    @render 'front'
    ), name:'home'



# Template.registerHelper 'is_positive', () ->
#     # console.log @doc_sentiment_score
#     if @doc_sentiment_score
#         @doc_sentiment_score > 0
    
# Template.registerHelper 'sentiment_class', () ->
#     if @sentiment_avg > 0 then 'green' else 'red'
# Template.registerHelper 'sv', (key) -> Session.get(key)
# Template.registerHelper 'sentence_color', () ->
#     switch @tones[0].tone_id
#         when 'sadness' then 'blue'
#         when 'joy' then 'green'
#         when 'confident' then 'teal'
#         when 'analytical' then 'orange'
#         when 'tentative' then 'yellow'
        
# Template.registerHelper 'abs_percent', (num) -> 
#     # console.l/og Math.abs(num*100)
#     parseInt(Math.abs(num*100))
    
# Template.registerHelper 'commafy', (num)-> if num then num.toLocaleString()

# Template.registerHelper 'rcomments', (doc_id)->
#     post = Docs.findOne Router.current().params.doc_id
#     # console.log 'comments for ', post
#     Docs.find
#         model:'rcomment'
#         parent_id:"t3_#{post.reddit_id}"

    
# Template.registerHelper 'trunc', (input) ->
#     input[0..350]
        
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
    
    
# Template.registerHelper 'connection', () -> Meteor.status()
# Template.registerHelper 'connected', () -> Meteor.status().connected
    
    
  
# Template.registerHelper 'tag_term', () ->
#     Docs.findOne 
#         model:'wikipedia'
#         title:@valueOf()



# Template.registerHelper 'session', () -> Session.get(@key)


# Template.registerHelper 'skip_is_zero', ()-> Session.equals('skip', 0)
# Template.registerHelper 'one_post', ()-> Counts.get('result_counter') is 1
# Template.registerHelper 'two_posts', ()-> Counts.get('result_counter') is 2
# Template.registerHelper 'key_value', (key,value)-> @["#{key}"] is value

# Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
# Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")
# Template.registerHelper 'lowered_title', ()-> @title.toLowerCase()


# Template.registerHelper 'field_value', () ->
#     # console.log @
#     parent = Template.parentData()
#     parent5 = Template.parentData(5)
#     parent6 = Template.parentData(6)


#     if @direct
#         parent = Template.parentData()
#     else if parent5
#         if parent5._id
#             parent = Template.parentData(5)
#     else if parent6
#         if parent6._id
#             parent = Template.parentData(6)
#     # console.log 'parent', parent
#     if parent
#         parent["#{@key}"]

# Template.registerHelper 'lowered', (input)-> input.toLowerCase()
# Template.registerHelper 'money_format', (input)-> (input/100).toFixed()

# Template.registerHelper 'template_subs_ready', () ->
#     Template.instance().subscriptionsReady()

# Template.registerHelper 'global_subs_ready', () ->
#     Session.get('global_subs_ready')

# Template.registerHelper 'nl2br', (text)->
#     nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
#     new Spacebars.SafeString(nl2br)

# Template.registerHelper 'dev', -> Meteor.isDevelopment
# Template.registerHelper 'fixed', (number)->
#     # console.log number
#     number.toFixed(2)
#     # (number*100).toFixed()

# Template.registerHelper 'session_is', (key)->
#     Session.get(key)

# Template.registerHelper 'is_loading', -> Session.get 'loading'
# Template.registerHelper 'long_time', (input)-> 
#     moment(input).format("h:mm a")
# Template.registerHelper 'long_date', (input)-> moment(input).format("dddd, MMMM Do h:mm a")
# Template.registerHelper 'home_long_date', (input)-> moment(input).format("dd, MMM Do h:mm a")
# Template.registerHelper 'short_date', (input)-> moment(input).format("dddd, MMMM Do")
# Template.registerHelper 'med_date', (input)-> moment(input).format("MMM D 'YY")
# # Template.registerHelper 'medium_date', (input)-> moment(input).format("MMMM Do YYYY")
# Template.registerHelper 'medium_date', (input)-> moment(input).format("dddd, MMMM Do")
# Template.registerHelper 'today', -> moment(Date.now()).format("dddd, MMMM Do a")
# Template.registerHelper 'int', (input)-> input.toFixed(0)
# Template.registerHelper 'made_when', ()-> moment(@_timestamp).fromNow()
# Template.registerHelper 'cal_time', (input)-> moment(input).calendar()


# Template.registerHelper 'loading_class', ()->
#     if Session.get 'loading' then 'disabled' else ''

# # Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()

# Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment
# Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()
# Template.registerHelper 'loading_class', ()->
#     if Session.get 'loading' then 'disabled' else ''
# Template.registerHelper 'from_now', (input)-> moment(input).fromNow()

# Template.registerHelper 'embed', ()->
#     if @data and @data.media and @data.media.oembed and @data.media.oembed.html
#         dom = document.createElement('textarea')
#         # dom.innerHTML = doc.body
#         dom.innerHTML = @data.media.oembed.html
#         return dom.value
#         # Docs.update @_id,
#         #     $set:
#         #         parsed_selftext_html:dom.value



Template.registerHelper 'skv_is', (key, value) ->
    Session.equals key,value

Template.registerHelper 'kv_is', (key, value) ->
    @["#{key}"] is value


# Template.registerHelper 'template_subs_ready', () ->
#     Template.instance().subscriptionsReady()

# Template.registerHelper 'global_subs_ready', () ->
#     Session.get('global_subs_ready')



# Template.registerHelper 'nl2br', (text)->
#     nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
#     new Spacebars.SafeString(nl2br)

# Template.registerHelper 'fixed0', (number)-> if number then number.toFixed().toLocaleString()
# Template.registerHelper 'fixed', (number)-> if number then number.toFixed(2)

    
    
    
# Template.registerHelper 'comments', ()->
#     Docs.find
#         model:'comment'
#         parent_id:@_id
        

# Template.registerHelper 'ruser_doc', () ->
#     Docs.findOne 
#         model:'ruser'

# Template.registerHelper 'user_class', () ->
#     if @online then 'user_online'

# # Template.registerHelper 'field_value', () ->
# #     # console.log @
# #     parent = Template.parentData()
# #     # console.log 'parent', parent
# #     if parent
# #         parent["#{@key}"]



# Template.registerHelper 'is_logging_out', () -> Session.get('logging_out')

# Template.registerHelper 'is_image', ()->
#     if @data.domain in ['i.reddit.com','i.redd.it','i.imgur.com','imgur.com','gyfycat.com','v.redd.it','giphy.com']
#         true
#     else 
#         false
# Template.registerHelper 'has_thumbnail', ()->
#     console.log @data.thumbnail
#     @data.thumbnail.length > 0

# Template.registerHelper 'is_youtube', ()->
#     @data.domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']



# Template.registerHelper 'current_doc', () ->
#     found_doc_by_id = Docs.findOne Router.current().params.doc_id
#     found_doc_by_slug = 
#         Docs.findOne 
#             slug:Router.current().params.slug
#     if found_doc_by_id
#         found_doc_by_id
#     else if found_doc_by_slug
#         found_doc_by_slug

# Template.registerHelper 'lowered_title', ()-> @title.toLowerCase()


# Template.registerHelper 'field_value', () ->
#     # console.log @
#     parent = Template.parentData()
#     parent5 = Template.parentData(5)
#     parent6 = Template.parentData(6)


#     if @direct
#         parent = Template.parentData()
#     else if parent5
#         if parent5._id
#             parent = Template.parentData(5)
#     else if parent6
#         if parent6._id
#             parent = Template.parentData(6)
#     # console.log 'parent', parent
#     if parent
#         parent["#{@key}"]

# Template.registerHelper 'ufrom', (input)-> moment.unix(input).fromNow()


# Template.registerHelper 'session_key_value_is', (key, value) ->
#     # console.log 'key', key
#     # console.log 'value', value
#     Session.equals key,value

# Template.registerHelper 'key_value_is', (key, value) ->
#     # console.log 'key', key
#     # console.log 'value', value
#     @["#{key}"] is value


# Template.registerHelper 'template_subs_ready', () ->
#     Template.instance().subscriptionsReady()

# Template.registerHelper 'global_subs_ready', () ->
#     Session.get('global_subs_ready')



# Template.registerHelper 'nl2br', (text)->
#     nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
#     new Spacebars.SafeString(nl2br)


# Template.registerHelper 'dev', -> Meteor.isDevelopment
# # Template.registerHelper 'fixed', (number)->
# #     # console.log number
# #     number.toFixed(2)
# #     # (number*100).toFixed()
Template.registerHelper 'to_percent', (number)->
    # console.log number
    (number*100).toFixed()



# Template.registerHelper 'loading_class', ()->
#     if Session.get 'loading' then 'disabled' else ''

# # Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()
# Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment

# Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()


# Template.registerHelper 'loading_class', ()->
#     if Session.get 'loading' then 'disabled' else ''

# Template.registerHelper 'from_now', (input)-> moment(input).fromNow()
