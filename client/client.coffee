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
        
    'click .blink': ->
        $('.global_container')
            .transition('fade out', 150)
            .transition('fade in', 150)
        
        
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

Template.post_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

Template.post_view.onCreated ->
    # Session.set('session_clicks', Session.get('session_clicks')+2)
    Meteor.call 'log_view', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

Template.post_view.helpers


Template.post_edit.events
    'click .delete_post': ->
        if confirm 'delete post? cannot be undone'
            Docs.remove @_id
            # if @group
            #     Router.go "/g/#{@group}"
            # else 
            Router.go "/"
Template.post_view.events
    'click .search_dao': ->
        picked_tags.clear()
        Router.go '/'



