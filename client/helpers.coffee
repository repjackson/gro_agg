Template.registerHelper 'field_value', () ->
    # console.log @
    parent = Template.parentData()

    # if @direct
    parent = Template.parentData()
    if parent
        parent["#{@key}"]



Template.registerHelper 'sentence_color', () ->
    console.log @tones[0].tone_id
    switch @tones[0].tone_id
        when 'sadness' then 'blue invert inverted'
        when 'joy' then 'green invert inverted'
        when 'confident' then 'teal invert inverted'
        when 'analytical' then 'orange invert inverted'
        when 'tentative' then 'yellow invert inverted'



Template.registerHelper 'post_person', () ->
    # console.log @
    parent = Template.parentData()
        
    Docs.findOne
        model:'person'
        _id:@person_id




        
Template.registerHelper 'page_doc', (key)->
    Docs.findOne 
        _id:Router.current().params.doc_id
        
Template.registerHelper 'youtube_parse', (url) ->
    regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    match = @url.match(regExp)
    if match && match[2].length == 11
        # console.log match[2]
        return match[2];
    else
        # console.log 'error, not vid'
        null
        

    
Template.registerHelper 'calculated_size', (metric) ->
    # console.log 'metric', metric
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    whole = parseInt(@["#{metric}"]*10)
    # console.log 'whole', whole

    if whole is 2 then 'f7'
    else if whole is 3 then 'f8'
    else if whole is 4 then 'f9'
    else if whole is 5 then 'f10'
    else if whole is 6 then 'f11'
    else if whole is 7 then 'f12'
    else if whole is 8 then 'f13'
    else if whole is 9 then 'f14'
    else if whole is 10 then 'f15'
    
    
Template.registerHelper 'connection', () ->
    # console.log Meteor.status()
    Meteor.status()

Template.registerHelper 'connected', () -> Meteor.status().connected
    
    
Template.registerHelper 'tone_size', () ->
    # console.log 'this weight', @weight
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    # whole = parseInt(@["#{metric}"]*10)
    # console.log 'whole', whole
    if @weight
        if @weight is -5 then 'f6'
        else if @weight is -4 then 'f7'
        else if @weight is -3 then 'f8'
        else if @weight is -2 then 'f9'
        else if @weight is -1 then 'f10'
        else if @weight is 0 then 'f12'
        else if @weight is 1 then 'f12'
        else if @weight is 2 then 'f13'
        else if @weight is 3 then 'f14'
        else if @weight is 4 then 'f15'
        else if @weight is 5 then 'f16'
        else if @weight > 5 then 'f16'
        
    else
        'f12'
  
    

Template.registerHelper 'is_dao', () -> @username is 'dao'



Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")



# Template.registerHelper 'field_value', () ->
#     # console.log @
#     parent = Template.parentData()
#     # console.log 'parent', parent
#     if parent
#         parent["#{@key}"]

Template.registerHelper 'doc_comments', () ->
    Docs.find
        model:'comment'
        parent_id:@_id

Template.registerHelper 'is_logging_out', () -> Session.get('logging_out')



Template.registerHelper 'current_doc', () ->
    found_doc_by_id = Docs.findOne Router.current().params.doc_id
    found_doc_by_slug = Docs.findOne Router.current().params.doc_slug
    if found_doc_by_id
        found_doc_by_id
    else if found_doc_by_slug
        found_doc_by_slug
    else
        Meteor.users.findOne Router.current().params.doc_id

Template.registerHelper 'lowered_title', ()-> @title.toLowerCase()


Template.registerHelper 'field_value', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)


    if @direct
        parent = Template.parentData()
    else if parent5
        if parent5._id
            parent = Template.parentData(5)
    else if parent6
        if parent6._id
            parent = Template.parentData(6)
    # console.log 'parent', parent
    if parent
        parent["#{@key}"]



Template.registerHelper 'lowered', (input)-> input.toLowerCase()
Template.registerHelper 'money_format', (input)-> (input/100).toFixed(2)

Template.registerHelper 'session_key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    Session.equals key,value

Template.registerHelper 'key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    @["#{key}"] is value


Template.registerHelper 'template_subs_ready', () ->
    Template.instance().subscriptionsReady()

Template.registerHelper 'global_subs_ready', () ->
    Session.get('global_subs_ready')



Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)


Template.registerHelper 'author', ->
    Meteor.users.findOne(@_author_id)


Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'fixed', (number)->
    # console.log number
    number.toFixed(2)
    # (number*100).toFixed()
Template.registerHelper 'to_percent', (number)->
    # console.log number
    (number*100).toFixed()

Template.registerHelper 'upvote_class', () ->
    if Meteor.userId()
        if @upvoter_ids and Meteor.userId() in @upvoter_ids then '' else 'outline'
    else ''
Template.registerHelper 'downvote_class', () ->
    if Meteor.userId()
        if @downvoter_ids and Meteor.userId() in @downvoter_ids then '' else 'outline'
    else ''

Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")

Template.registerHelper 'can_buy', ()->
    Meteor.userId() isnt @_author_id


Template.registerHelper 'is_image', ()->
    if @domain is 'i.redd.it'
        true
    else 
        false

Template.registerHelper 'is_youtube', ()->
    if @domain is 'youtube.com'
        true
    else 
        false


Template.registerHelper 'session_is', (key)->
    Session.get(key)

Template.registerHelper 'is_loading', -> Session.get 'loading'
Template.registerHelper 'long_time', (input)-> 
        console.log 'long time', input
        moment(input).format("h:mm a")
Template.registerHelper 'long_date', (input)-> moment(input).format("dddd, MMMM Do h:mm a")
Template.registerHelper 'home_long_date', (input)-> moment(input).format("dd MMM D h:mma")
Template.registerHelper 'short_date', (input)-> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'med_date', (input)-> moment(input).format("MMM D 'YY")
# Template.registerHelper 'medium_date', (input)-> moment(input).format("MMMM Do YYYY")
Template.registerHelper 'medium_date', (input)-> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'today', -> moment(Date.now()).format("dddd, MMMM Do a")
Template.registerHelper 'int', (input)-> input.toFixed(0)
Template.registerHelper 'made_when', ()-> moment(@_timestamp).fromNow()
Template.registerHelper 'from_now', (input)-> moment(input).fromNow()
Template.registerHelper 'cal_time', (input)-> moment(input).calendar()

Template.registerHelper 'current_month', ()-> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', ()-> moment(Date.now()).format("DD")


Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''

# Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()

Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment

Template.registerHelper 'is_eric', ()-> if Meteor.userId() and Meteor.userId() in ['vwCi2GTJgvBJN5F6c'] then true else false
Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()


Template.registerHelper 'is_one', ()-> 
    if Meteor.userId() and Meteor.userId() in ['YFPxjXCgjhMYEPADS'] then true else false



Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'from_now', (input)-> moment(input).fromNow()

Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment
Template.registerHelper 'is_loading', -> Session.get 'loading'
# Template.registerHelper 'long_time', (input)-> 
#     moment(input).format("h:mm a")
Template.registerHelper 'long_date', (input)-> moment(input).format("dddd, MMMM Do h:mm a")
Template.registerHelper 'when', ()-> moment(@_timestamp).fromNow()
# Template.registerHelper 'cal_time', (input)-> moment(input).calendar()

# Template.registerHelper 'current_month', ()-> moment(Date.now()).format("MMMM")
# Template.registerHelper 'current_day', ()-> moment(Date.now()).format("DD")



Template.registerHelper 'kve', (key, value) ->
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


Template.registerHelper 'session_key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    Session.equals key,value

Template.registerHelper 'key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    @["#{key}"] is value



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