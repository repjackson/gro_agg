Template.registerHelper 'youtube_parse', (url) ->
    regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    match = @data.url.match(regExp)
    if match && match[2].length == 11
        match[2]
    else
        null
   
Session.setDefault('loading', false)
Template.body.events
    # 'click a': ->
        
    # 'click .say_title': ->
    #     window.speechSynthesis.speak new SpeechSynthesisUtterance @title
        
    # 'click .say_body': ->
    #     window.speechSynthesis.speak new SpeechSynthesisUtterance @innerText
        
    # 'click .say': ->
    #     window.speechSynthesis.speak new SpeechSynthesisUtterance @innerText
        
Template.say.events
    'click .quiet': (e,t)->
        Session.set('talking',false)
        window.speechSynthesis.cancel()
    'click .say_this': (e,t)->
        Session.set('talking',true)
        dom = document.createElement('textarea')
        # dom.innerHTML = doc.body
        dom.innerHTML = Template.parentData()["#{@k}"]
        text1 = $("<textarea/>").html(dom.innerHTML).text();
        text2 = $("<textarea/>").html(text1).text();
        # window.speechSynthesis.speak new SpeechSynthesisUtterance text2
# Meteor.startup ->
#     if Meteor.isDevelopment
#         window.speechSynthesis.speak new SpeechSynthesisUtterance 'dao'
Template.nav.events
    # 'click .goto_stack': -> window.speechSynthesis.speak new SpeechSynthesisUtterance 'stack'
    'click .goto_reddit': ->
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'reddit'
    'click .goto_people': ->
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'people'
    'click .goto_dao': ->
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'dao'
    'click .goto_ea': ->
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'environment'
    'click .clear_tags': -> 
        selected_tags.clear()
    'click .silence': ->
        window.speechSynthesis.cancel()
        $('body').toast(
            showIcon: 'volume mute big'
            message: 'muted'
            # showProgress: 'bottom'
            class: 'info'
            displayTime: 'auto',
            position: "bottom center"
        )

    'click .home2': -> 
        Session.set('site_name_filter',null)
        selected_tags.clear()
        window.speechSynthesis.cancel()

        # window.speechSynthesis.speak new SpeechSynthesisUtterance @innerHTML()

   
# Deps.autorun ()->
#     document.title = Session.get('doc_title')
        
Template.registerHelper 'is_positive', () ->
    console.log @doc_sentiment_score
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
Template.registerHelper 'selected_subreddits', () -> selected_subreddits.array()
Template.registerHelper 'selected_emotions', () -> selected_emotions.array()
    
Template.registerHelper 'commafy', (num)-> if num then num.toLocaleString()

    
    
Template.registerHelper 'ruser_doc', ()->
    Docs.findOne 
        model:'ruser'
        username:Router.current().params.username

Template.registerHelper 'ruser_posts', ()->
    Docs.find
        model:'rpost'
        # user_id:parseInt(Router.current().params.username)
        # subreddit:Router.current().params.subreddit
Template.registerHelper 'rcomments', ()->
    Docs.find
        model:'rcomment'
        # user_id:parseInt(Router.current().params.username)
        # subreddit:Router.current().params.subreddit

Template.registerHelper 'editing_mode', ()->
    # Meteor.user().edit_mode and 
    if Meteor.user().edit_mode
        if Router.current().params.username is Meteor.user().username
            true
Template.registerHelper 'user_id_in', (key)->
    if Meteor.user()
        if Meteor.userId() in @["#{key}"]
            true
        else
            false
    else
        false

    
Template.registerHelper 'stackuser_doc', (input) ->
    Docs.findOne 
        model:'stackuser'
        site:Router.current().params.site
        user_id:parseInt(Router.current().params.user_id)

Template.registerHelper 'trunc', (input) ->
    input[0..350]
        
Template.registerHelper 'post_header_class', (metric) ->
    if @max_emotion_name
        if @max_emotion_name is 'joy' then 'ui green text'
        else if @max_emotion_name is 'anger' then 'red'
        else if @max_emotion_name is 'sadness' then 'blue'
        else if @max_emotion_name is 'disgust' then 'orange'
    
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
    
    
Template.registerHelper 'tone_size', () ->
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
    else
        'f11'
  
Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")

Template.registerHelper 'tag_term', () ->
    Docs.findOne 
        model:'wikipedia'
        title:@valueOf()



Template.registerHelper 'session', () -> Session.get(@key)

Template.registerHelper 'lowered_title', ()-> @title.toLowerCase()

Template.registerHelper 'skip_is_zero', ()-> Session.equals('skip', 0)
Template.registerHelper 'one_post', ()-> Counts.get('result_counter') is 1
Template.registerHelper 'two_posts', ()-> Counts.get('result_counter') is 2
Template.registerHelper 'key_value', (key,value)-> @["#{key}"] is value



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
        true
    else 
        false
Template.registerHelper 'is_youtube', ()->
    @data.domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']
Template.registerHelper 'is_twitter', ()->
    @data.domain in ['twitter.com','mobile.twitter.com','vimeo.com']


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
Template.registerHelper 'to_percent', (number)-> (number*100).toFixed()

Template.registerHelper 'current_subreddit', ()->
    found = Docs.findOne 
        model:'subreddit'
        "data.display_name":Router.current().params.subreddit
    # console.log 'found', found
    if found
        found
    
Template.registerHelper 'current_doc', ()->
    Docs.findOne Router.current().params.doc_id
Template.registerHelper 'current_q', ()->
    Docs.findOne 
        question_id:parseInt(Router.current().params.qid)
        model:'stack_question'
        site:Router.current().params.site




Template.registerHelper 'session_is', (key)-> Session.get(key)

Template.registerHelper 'long_time', (input)-> moment(input).format("h:mm a")
Template.registerHelper 'long_date', (input)-> moment(input).format("dddd, MMMM Do h:mm a")
Template.registerHelper 'home_long_date', (input)-> moment(input).format("dd MMM D h:mma")
Template.registerHelper 'short_date', (input)-> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'med_date', (input)-> moment(input).format("MMM D 'YY")
# Template.registerHelper 'medium_date', (input)-> moment(input).format("MMMM Do YYYY")
Template.registerHelper 'medium_date', (input)-> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'today', -> moment(Date.now()).format("dddd, MMMM Do a")
Template.registerHelper 'int', (input)-> input.toFixed(0)
Template.registerHelper '_when', ()-> moment(@_timestamp).fromNow()
Template.registerHelper '_when_long', ()-> moment(@_timestamp).format("dddd, MMMM Do h:mm a")

Template.registerHelper 'from_now', (input)-> moment(input).fromNow()
Template.registerHelper 'ufrom', (input)-> moment.unix(input).fromNow()

Template.registerHelper 'cal_time', (input)-> moment(input).calendar()

Template.registerHelper 'current_month', ()-> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', ()-> moment(Date.now()).format("DD")


Template.registerHelper 'publish_when', ()-> moment(@publish_date).fromNow()

Template.registerHelper 'thinking_class', ()->
    if Session.get('thinking') then 'disabled' else ''

Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment
