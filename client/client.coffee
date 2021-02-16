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
    