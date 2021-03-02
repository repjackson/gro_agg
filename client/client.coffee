@picked_tags = new ReactiveArray []
@picked_times = new ReactiveArray []
@picked_locations = new ReactiveArray []
@picked_authors = new ReactiveArray []

Router.route '/', (->
    @layout 'layout'
    @render 'subs'
    ), name:'home'






            
            
Template.tag_picker.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
Template.tag_picker.helpers
    # picker_class: ()->
    #     term = 
    #         Docs.findOne 
    #             title:@name.toLowerCase()
    #     if term
    #         if term.max_emotion_name
    #             switch term.max_emotion_name
    #                 when 'joy' then " basic green"
    #                 when "anger" then " basic red"
    #                 when "sadness" then " basic blue"
    #                 when "disgust" then " basic orange"
    #                 when "fear" then " basic grey"
    #                 else "basic grey"
    term: ->
        res = 
            Docs.findOne 
                title:@name.toLowerCase()
        # console.log res
        res
            
Template.search_shortcut.events
    'click .search_tag': ->
        picked_tags.push @tag.toLowerCase()
        url = new URL(window.location);
        url.searchParams.set('tags', picked_tags.array());
        window.history.pushState({}, '', url);
        document.title = picked_tags.array()
        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
        Meteor.setTimeout ->
            Session.set('toggle', !Session.get('toggle'))
        , 7000    

Template.tag_picker.events
    'click .pick_tag': -> 
        # results.update
        # console.log @
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # if @model is 'love_emotion'
        #     picked_emotions.push @name
        # else
        # if @model is 'love_tag'
        lowered_name = @name.toLowerCase()
        unless lowered_name in picked_tags.array()
            picked_tags.push lowered_name
        # $('.search_sublove').val('')
        # Session.set('skip_value',0)

        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
        Meteor.setTimeout ->
            Session.set('toggle', !Session.get('toggle'))
        , 7000    
        url = new URL(window.location);
        url.searchParams.set('tags', picked_tags.array());
        window.history.pushState({}, '', url);
        document.title = picked_tags.array()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        # Session.set('love_loading',true)
    
    
Template.registerHelper 'skv_is', (key, value) ->
    Session.equals key,value


Template.skve.events
    'click .set_session_v': ->
        # if Session.equals(@k,@v)
        #     Session.set(@k, null)
        # else
        Session.set(@k, @v)

Template.skve.helpers
    calculated_class: ->
        res = ''
        if @classes
            res += @classes
        if Session.get(@k)
            if Session.equals(@k,@v)
                res += ' large compact black'
            else
                # res += ' compact displaynone'
                res += ' compact basic '
            res
        else
            'basic '
    selected: -> Session.equals(@k,@v)
        

Template.unpick_tag.onCreated ->
    # @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
    
Template.unpick_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
Template.unpick_tag.events
    'click .unpick_tag': -> 
        Session.set('skip',0)
        # console.log @
        picked_tags.remove @valueOf()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()

        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
        Meteor.setTimeout ->
            Session.set('toggle', !Session.get('toggle'))
        , 7000    
        url = new URL(window.location);
        url.searchParams.set('tags', picked_tags.array());
        window.history.pushState({}, '', url);
        document.title = picked_tags.array()


Template.flat_tag_picker.onCreated ->
    # @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
Template.flat_tag_picker.helpers
    # picker_class: ()->
    #     term = 
    #         Docs.findOne 
    #             title:@valueOf().toLowerCase()
    #     if term
    #         if term.max_emotion_name
    #             switch term.max_emotion_name
    #                 when 'joy' then " basic green"
    #                 when "anger" then " basic red"
    #                 when "sadness" then " basic blue"
    #                 when "disgust" then " basic orange"
    #                 when "fear" then " basic grey"
    #                 else "basic grey"
    term: ->
        Docs.findOne 
            title:@valueOf().toLowerCase()
Template.flat_tag_picker.events
    'click .pick_flat_tag': -> 
        console.log 'click', @valueOf()
        # results.update
        # window.speechSynthesis.cancel()
        lowered = @valueOf().toLowerCase()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        unless lowered in picked_tags.array()
            picked_tags.push lowered
        # picked_tags.clear()

        $('.search_tags').val('')
        url = new URL(window.location);
        url.searchParams.set('tags', picked_tags.array());
        window.history.pushState({}, '', url);
        document.title = picked_tags.array()
        Router.go '/'



Session.setDefault('loading', false)
Template.body.events
    # 'click .set_main': -> Session.set('view_section','main')

    # 'click .say_body': ->
    #     window.speechSynthesis.speak new SpeechSynthesisUtterance @innerText
    'click .shutup': ->
        window.speechSynthesis.cancel()

    'click .say': ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @innerText
        
    # 'click a': ->
    #     $('.global_container')
    #         .transition('fade out', 200)
    #         .transition('fade in', 200)


Template.registerHelper 'embed', ()->
    if @data and @data.media and @data.media.oembed and @data.media.oembed.html
        dom = document.createElement('textarea')
        # dom.innerHTML = doc.body
        dom.innerHTML = @data.media.oembed.html
        return dom.value
        # Docs.update @_id,
        #     $set:
        #         parsed_selftext_html:dom.value




    
        
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


@picked_tags = new ReactiveArray []


    




Template.print_this.events
    'click .print_this': ->
        console.log @