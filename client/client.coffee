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
        
    'click .say_body': ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @innerText
        
    'click .say': ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @innerText
        
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

Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'


Router.route '/s/:search', (->
    @layout 'layout'
    @render 'home'
    ), name:'search'

Router.route '/love', (->
    @layout 'layout'
    @render 'love'
    ), name:'love'


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
    
    
# Template.registerHelper 'connection', () -> Meteor.status()
# Template.registerHelper 'connected', () -> Meteor.status().connected
    
    
  
Template.registerHelper 'tag_term', () ->
    Docs.findOne 
        model:'wikipedia'
        title:@valueOf()



Template.registerHelper 'session_is', (input) -> Session.get(input)


# Template.registerHelper 'skip_is_zero', ()-> Session.equals('skip', 0)
# Template.registerHelper 'one_post', ()-> Counts.get('result_counter') is 1
# Template.registerHelper 'two_posts', ()-> Counts.get('result_counter') is 2
# Template.registerHelper 'key_value', (key,value)-> @["#{key}"] is value

# Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
# Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")
Template.registerHelper 'lowered_title', ()-> @data.title.toLowerCase()


Template.registerHelper 'field_value', () ->
    parent = Template.parentData()
    # console.log 'parent', parent
    if parent
        parent["#{@key}"]

# Template.registerHelper 'lowered', (input)-> input.toLowerCase()
# Template.registerHelper 'money_format', (input)-> (input/100).toFixed()

Template.registerHelper 'template_subs_ready', () ->
    Template.instance().subscriptionsReady()


Template.registerHelper 'doc_by_id', -> Docs.findOne Router.current().params.doc_id

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
# Template.registerHelper 'made_when', ()-> moment(@_timestamp).fromNow()
# Template.registerHelper 'cal_time', (input)-> moment(input).calendar()


Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment

Template.registerHelper 'embed', ()->
    if @data and @data.media and @data.media.oembed and @data.media.oembed.html
        dom = document.createElement('textarea')
        # dom.innerHTML = doc.body
        dom.innerHTML = @data.media.oembed.html
        return dom.value
        # Docs.update @_id,
        #     $set:
        #         parsed_selftext_html:dom.value



Template.registerHelper 'skv_is', (key, value) ->
    Session.equals key,value

Template.registerHelper 'kv_is', (key, value) ->
    @["#{key}"] is value


# Template.registerHelper 'template_subs_ready', () ->
#     Template.instance().subscriptionsReady()

# Template.registerHelper 'global_subs_ready', () ->
#     Session.get('global_subs_ready')



# Template.registerHelper 'fixed0', (number)-> if number then number.toFixed().toLocaleString()
# Template.registerHelper 'fixed', (number)-> if number then number.toFixed(2)

    
    
    
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


Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)


@picked_tags = new ReactiveArray []

Template.home.onRendered ->
    if Router.current().params.search
        search = Router.current().params.search
        picked_tags.push search
        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)

Template.alpha.onRendered ->
    # unless @data.watson
    #     Meteor.call 'call_watson', @data._id, 'url','url',->
    # if @data.response
    # window.speechSynthesis.cancel()
    # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.response.queryresult.pods[1].subpods[1].plaintext
    if @data 
        if @data.voice
            window.speechSynthesis.speak new SpeechSynthesisUtterance @data.voice
        else if @data.response.queryresult.pods
            window.speechSynthesis.speak new SpeechSynthesisUtterance @data.response.queryresult.pods[1].subpods[0].plaintext
    # Meteor.setTimeout( =>
    # , 7000)

Template.alpha.helpers
    alphas: ->
        Docs.find
            model:'alpha'
    
    split_datatypes: ->
        split = @datatypes.split ','
        split

Template.alpha.events
    'click .select_datatype': ->
        picked_tags.push @valueOf().toLowerCase()
    'click .alphatemp': ->
        window.speechSynthesis.cancel()
        window.speechSynthesis.speak new SpeechSynthesisUtterance @plaintext
        

        


Template.flat_tag_picker.events
    'click .pick_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        picked_tags.push @valueOf().toLowerCase()
        $('.search_home').val('')
        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array()
    