Template.registerHelper 'picked_tags', () -> picked_tags.array()
Template.registerHelper 'picked_authors', () -> picked_authors.array()
Template.registerHelper 'picked_domains', () -> picked_domains.array()
    
Template.registerHelper 'commafy', (num)-> if num then num.toLocaleString()

    
Template.registerHelper 'trunc', (input) ->
    if input
        input[0..500]
   
   
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
    if @data.domain in ['i.reddit.com','i.redd.it','i.imgur.com','imgur.com','gyfycat.com','giphy.com']
        true
    else 
        false
Template.registerHelper 'preview_path', ()->
    if @data and @data.domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']
        @data.preview and @data.preview.images[0].source.url
Template.registerHelper 'has_thumbnail', ()->
    # console.log @data.thumbnail
    @data.thumbnail not in ['default','self']
        # @data.thumbnail.length > 0 

Template.registerHelper 'is_youtube', ()->
    @data and @data.domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']
 
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
#         if @data.title
#             @data.title.toLowerCase()


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