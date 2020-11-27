Router.route '/v/:name/p/:doc_id', (->
    @layout 'layout'
    @render 'vid_page'
    ), name:'vid_page'
    
    
Router.route '/vids', (->
    @layout 'layout'
    @render 'vids'
    ), name:'vids'

    
    
Template.vid_page.onCreated ->
    @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)

Template.vid_page.events
    'click .get_post': ->
        Meteor.call 'get_vid_post', Router.current().params.doc_id, @vid_id, ->

Template.vid.onCreated ->
    Session.setDefault('vid_query',null)
    @autorun -> Meteor.subscribe('vids',
        Session.get('vid_query')
        selected_tags.array())

Template.vid.events
    'click .goto_article': (e,t)->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
    'keyup .search_vid': (e,t)->
        val = $('.search_vid').val()
        Session.set('vid_query', val)
        if e.which is 13 
            Meteor.call 'search_vid', val, ->
                $('.search_vid').val('')
                Session.set('vid_query', null)

Template.vid.helpers
    vid_docs: ->
        Docs.find
            model:'vidpedia'

Template.vid.onCreated ->
    # Session.setDefault('user_query', null)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'sub_docs_by_name', Router.current().params.name

# Template.vid_doc_item.events
#     'click .view_post': (e,t)-> 
#         window.speechSynthesis.speak new SpeechSynthesisUtterance @title
#         # Router.go "/vid/#{@vid}/post/#{@_id}"

Template.vid.helpers
    vid_doc: ->
        Docs.findOne
            model:'vid'
            "data.display_name":Router.current().params.name
            