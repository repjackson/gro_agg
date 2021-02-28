Session.setDefault('loading', false)
Template.body.events
    'click .set_main': -> Session.set('view_section','main')

    'click .say_body': ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @innerText
        # Meteor.call 'add_global_karma', ->
        # Session.set('session_clicks', Session.get('session_clicks')+2)

    'click .shutup': ->
        window.speechSynthesis.cancel()

    'click .say': ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @innerText
        
    'click a': ->
        $('.global_container')
            .transition('fade out', 500)
            .transition('fade in', 500)


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
Template.registerHelper 'has_thumbnail', ()->
    # console.log @data.thumbnail
    @thumbnail not in ['default', 'self']
        # @data.thumbnail.length > 0 

Template.registerHelper 'is_youtube', ()->
    @data and @data.domain in ['youtube.com','youtu.be','m.youtube.com','vimeo.com']


    
        
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




@picked_tags = new ReactiveArray []


    
Router.route '/p/:doc_id', (->
    @layout 'layout'
    @render 'post_view'
    ), name:'post_view_short'


Template.post_view.onCreated ->
    # Session.set('session_clicks', Session.get('session_clicks')+2)
    # Meteor.call 'log_view', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

Template.post_view.helpers


Template.post_view.events
    'click .search_dao': ->
        picked_tags.clear()
        Router.go '/'





Template.print_this.events
    'click .print_this': ->
        console.log @