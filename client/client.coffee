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

Router.route '/:search', (->
    @layout 'layout'
    @render 'home'
    ), name:'search'



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

        
        
Template.home.onCreated ->
    Session.setDefault('toggle',false)
    @autorun => Meteor.subscribe 'tags',
        picked_tags.array()
        Session.get('toggle')
    @autorun => Meteor.subscribe 'count', 
        picked_tags.array()
        Session.get('toggle')
    @autorun => Meteor.subscribe 'posts', 
        picked_tags.array()
        Session.get('toggle')

Template.home.helpers
    posts: ->
        Docs.find({
            model: 'rpost'
        },
            sort: ups:-1
            limit:10
        )
  
    counter: -> Counts.get 'counter'

    picked_tags: -> picked_tags.array()
  
    result_tags: -> results.find(model:'tag')
   
        
Template.home.events
    'click .search_tag': (e,t)->
        Session.set('toggle',!Session.get('toggle'))
        $('.seg .pick_tag').transition({
            animation : 'pulse',
            duration  : 800,
            interval  : 300
        })
        $('.black').transition('pulse')
        # $('.pick_tag').transition('pulse')
        # $('.card_small').transition('shake')
            
    'keyup .search_tag': (e,t)->
        $('.search_tag').transition('pulse', 200)
        if e.which is 13
            val = t.$('.search_tag').val().trim().toLowerCase()
            if val.length > 0
                picked_tags.push val   
                t.$('.search_tag').val('')
                # Session.set('sub_doc_query', val)
                Session.set('loading',true)
                window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array()
                $('.search_tag').transition('pulse')
                $('.black').transition('pulse')
                $('.seg .pick_tag').transition({
                    animation : 'pulse',
                    duration  : 800,
                    interval  : 300
                })
                $('.seg .black').transition({
                    animation : 'pulse',
                    duration  : 800,
                    interval  : 300
                })
                # $('.pick_tag').transition('pulse')
                # $('.card_small').transition('shake')
                $('.pushed .card_small').transition({
                    animation : 'pulse',
                    duration  : 800,
                    interval  : 300
                })

                Meteor.call 'search_reddit', picked_tags.array(), ->
                    Session.set('loading',false)
                Meteor.setTimeout ->
                    Session.set('toggle',!Session.get('toggle'))
                , 5000
        

    'click .title': (e,t)-> 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
 
 
 
 
Template.post_card_small.events
    'click .view_post': (e,t)-> 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
     'keyup .add_tag': (e,t)->
        $('.add_tag').transition('pulse', 100)
        if e.which is 13
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            
            val = $(e.currentTarget).closest('.add_tag').val().trim().toLowerCase()
            if val.length > 0
                Session.set('loading',true)
                Docs.update @_id, 
                    $addToSet: tags: val
                # window.speechSynthesis.speak new SpeechSynthesisUtterance val
                picked_tags.push val   
                Meteor.call 'search_reddit', picked_tags.array(), ->
                    Session.set('loading',false)
                Meteor.setTimeout ->
                    Session.set('toggle',!Session.get('toggle'))
                , 5000
                t.$('.add_tag').val('')

Template.post_card_small.helpers
    five_tags: -> @tags[..5]
 
Template.tag_picker.events
    'click .pick_tag': -> 
        picked_tags.push @name.toLowerCase()
        $('.search_tag').val('')
        Session.set('skip_value',0)
        $('.search_tag').transition('pulse')
        $('.seg .pick_tag').transition({
            animation : 'pulse',
            duration  : 800,
            interval  : 300
        })
        $('.seg .black').transition({
            animation : 'pulse',
            duration  : 800,
            interval  : 300
        })
        # $('.pick_tag').transition('pulse')
        # $('.card_small').transition('shake')
        $('.pushed .card_small').transition({
            animation : 'pulse',
            duration  : 800,
            interval  : 300
        })

        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array()
        Meteor.setTimeout ->
            Session.set('toggle',!Session.get('toggle'))
        , 5000
        
        

Template.unpick_tag.events
    'click .unpick_tag': -> 
        Session.set('skip',0)
        # console.log @
        picked_tags.remove @valueOf()
        $('.search_tag').transition('pulse')
        $('.seg .black').transition({
            animation : 'pulse',
            duration  : 800,
            interval  : 300
        })
        # $('.pick_tag').transition('pulse')
        # $('.card_small').transition('shake')
        $('.seg .pick_tag').transition({
            animation : 'pulse',
            duration  : 800,
            interval  : 300
        })
        $('.pushed .card_small').transition({
            animation : 'pulse',
            duration  : 800,
            interval  : 300
        })

        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
        Meteor.setTimeout ->
            Session.set('toggle',!Session.get('toggle'))
        , 5000


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
    