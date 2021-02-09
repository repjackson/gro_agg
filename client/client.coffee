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


Router.route '/tarot', (->
    @layout 'layout'
    @render 'tarot'
    ), name:'tarot'

Router.route '/food_nav', (->
    @layout 'layout'
    @render 'food_nav'
    ), name:'food_nav'



