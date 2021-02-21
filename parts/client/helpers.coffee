Template.registerHelper 'is_positive', () ->
    # console.log @doc_sentiment_score
    if @doc_sentiment_score
        @doc_sentiment_score > 0
    
Template.registerHelper 'sentiment_class', () ->
    if @sentiment_avg > 0 then 'green' else 'red'
Template.registerHelper 'sv', (key) -> Session.get(key)
Template.registerHelper 'sentence_color', () ->
    switch @tones[0].tone_id
        when 'sadness' then 'blue'
        when 'joy' then 'green'
        when 'confident' then 'teal'
        when 'analytical' then 'orange'
        when 'tentative' then 'yellow'
        
Template.registerHelper 'abs_percent', (num) -> 
    # console.l/og Math.abs(num*100)
    parseInt(Math.abs(num*100))
Template.registerHelper 'selected_tags', () -> selected_tags.array()
Template.registerHelper 'selected_models', () -> selected_models.array()
Template.registerHelper 'selected_groups', () -> selected_groups.array()
Template.registerHelper 'selected_emotions', () -> selected_emotions.array()
    
Template.registerHelper 'commafy', (num)-> if num then num.toLocaleString()

    
Template.registerHelper 'trunc', (input) ->
    input[0..350]
        
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
    
    
Template.registerHelper 'connection', () -> Meteor.status()
Template.registerHelper 'connected', () -> Meteor.status().connected
    
    
  
Template.registerHelper 'tag_term', () ->
    Docs.findOne 
        model:'wikipedia'
        title:@valueOf()



Template.registerHelper 'skip_is_zero', ()-> Session.equals('skip', 0)
Template.registerHelper 'one_post', ()-> Counts.get('result_counter') is 1
Template.registerHelper 'two_posts', ()-> Counts.get('result_counter') is 2
Template.registerHelper 'key_value', (key,value)-> @["#{key}"] is value



Template.registerHelper 'lowered', (input)-> input.toLowerCase()
Template.registerHelper 'money_format', (input)-> (input/100).toFixed()

Template.registerHelper 'template_subs_ready', () ->
    Template.instance().subscriptionsReady()

Template.registerHelper 'global_subs_ready', () ->
    Session.get('global_subs_ready')

Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)

Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'fixed', (number)->
    # console.log number
    number.toFixed(2)
    # (number*100).toFixed()


Template.registerHelper 'session_is', (key)->
    Session.get(key)

Template.registerHelper 'is_loading', -> Session.get 'loading'
Template.registerHelper 'long_time', (input)-> 
    moment(input).format("h:mm a")
Template.registerHelper 'long_date', (input)-> moment(input).format("dddd, MMMM Do h:mm a")
Template.registerHelper 'home_long_date', (input)-> moment(input).format("dd, MMM Do h:mm a")
Template.registerHelper 'short_date', (input)-> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'med_date', (input)-> moment(input).format("MMM D 'YY")
# Template.registerHelper 'medium_date', (input)-> moment(input).format("MMMM Do YYYY")
Template.registerHelper 'medium_date', (input)-> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'today', -> moment(Date.now()).format("dddd, MMMM Do a")
Template.registerHelper 'int', (input)-> input.toFixed(0)
Template.registerHelper 'when', ()-> moment(@_timestamp).fromNow()
Template.registerHelper 'cal_time', (input)-> moment(input).calendar()

Template.registerHelper 'current_month', ()-> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', ()-> moment(Date.now()).format("DD")


Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment
Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()
Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment



Template.registerHelper 'lowered', (input)-> input.toLowerCase()
Template.registerHelper 'money_format', (input)-> (input/100).toFixed(2)

Template.registerHelper 'skv_is', (key, value) ->
    Session.equals key,value

Template.registerHelper 'kv_is', (key, value) ->
    @["#{key}"] is value


Template.registerHelper 'template_subs_ready', () ->
    Template.instance().subscriptionsReady()

Template.registerHelper 'global_subs_ready', () ->
    Session.get('global_subs_ready')



Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)

Template.registerHelper 'fixed0', (number)-> if number then number.toFixed().toLocaleString()
Template.registerHelper 'fixed', (number)-> if number then number.toFixed(2)

    
    
    
Template.registerHelper 'comments', ()->
    Docs.find
        model:'comment'
        parent_id:@_id
        


Template.registerHelper 'user_class', () ->
    if @online then 'user_online'

Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")



Template.registerHelper 'is_logging_out', () -> Session.get('logging_out')


Template.registerHelper 'current_doc', () ->
    found_doc_by_id = Docs.findOne Router.current().params.doc_id
    found_doc_by_slug = 
        Docs.findOne 
            slug:Router.current().params.slug
    if found_doc_by_id
        found_doc_by_id
    else if found_doc_by_slug
        found_doc_by_slug

Template.registerHelper 'lowered_title', ()-> 
    if @data
        if @data.title
            @data.title.toLowerCase()


Template.registerHelper 'template_parent', () ->
    # console.log Template.parentData()
    Template.parentData()
    
Template.registerHelper 'field_value', () ->
    # console.log @
    parent = Template.parentData()

    # if @direct
    parent = Template.parentData()
    if parent
        parent["#{@key}"]

Template.registerHelper 'ufrom', (input)-> moment.unix(input).fromNow()


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

        
Template.registerHelper 'is_in_admin', () ->
    Meteor.user() and Meteor.userId() in ['vwCi2GTJgvBJN5F6c','EYGz4bDSAdWF3W4wi']
Template.registerHelper 'is_this_user', () ->
    Meteor.userId() is @_id
Template.registerHelper 'current_user', () ->
    Meteor.users.findOne username:Router.current().params.username

Template.registerHelper 'user_from_id', (user_id) ->
    # console.log @
    Meteor.users.findOne _id:user_id

Template.registerHelper 'is_current_user', () ->
    if Meteor.user()
        Meteor.user().username is Router.current().params.username


Template.registerHelper 'user_class', () ->
    if @online then 'user_online'

Template.registerHelper 'recipient', () ->
    Meteor.users.findOne @recipient_id
Template.registerHelper 'target', () ->
    Meteor.users.findOne @target_user_id
Template.registerHelper 'to', () ->
    Meteor.users.findOne @to_user_id
    
Template.registerHelper 'upvote_class', () ->
    if Meteor.userId()
        if @upvoter_ids and Meteor.userId() in @upvoter_ids then 'green' else 'outline'
    else ''
Template.registerHelper 'downvote_class', () ->
    if Meteor.userId()
        if @downvoter_ids and Meteor.userId() in @downvoter_ids then 'red' else 'outline'
    else ''
        
        
        
Template.registerHelper 'in_role', (role)->
    if Meteor.user() and Meteor.user().roles
        if role in Meteor.user().roles
            true
        else
            false
    else
        false

Template.registerHelper 'is_admin', () ->
    # Meteor.users.findOne username:Router.current().params.username
    if Meteor.user() and Meteor.user().roles
        if 'admin' in Meteor.user().roles then true else false

Template.registerHelper 'is_dev', () ->
    # Meteor.users.findOne username:Router.current().params.username
    if Meteor.user() and Meteor.user().roles
        if 'dev' in Meteor.user().roles then true else false


Template.registerHelper 'is_author', () ->
    # if @_author_id and Meteor.userId()
    @_author_id is Meteor.userId()

Template.registerHelper '_author', () ->
    # if @_author_id and Meteor.userId()
    Meteor.users.findOne @_author_id


Template.registerHelper 'can_edit', () ->
    # if @_author_id and Meteor.userId()
    # @_author_id is Meteor.userId()
    # if Meteor.user().roles
    # if Meteor.user()
    #     if Meteor.user().roles and 'dev' in Meteor.user().roles or @_author_id is Meteor.userId() then true else false
    Meteor.user()