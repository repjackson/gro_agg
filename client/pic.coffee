Router.route '/pic/:doc_id', (->
    @layout 'layout'
    @render 'pic_page'
    ), name:'pic_page'
    
    
Router.route '/pics', (->
    @layout 'layout'
    @render 'pics'
    ), name:'pics'

    
    
# Template.pic_page.onCreated ->
#     @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)

# Template.pic_page.events
#     'click .get_post': ->
#         Meteor.call 'get_pic_post', Router.current().params.doc_id, @pic_id, ->

Template.pics.onCreated ->
    Session.setDefault('pic_query',null)
    @autorun -> Meteor.subscribe('pics',
        Session.get('pic_query')
        selected_tags.array())

Template.pics.events
    'click .goto_article': (e,t)->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
    'keyup .search_pic': (e,t)->
        val = $('.search_pic').val()
        Session.set('pic_query', val)
        if e.which is 13 
            Meteor.call 'search_pic', val, ->
                $('.search_pic').val('')
                Session.set('pic_query', null)

# Template.pic.helpers
#     pic_docs: ->
#         Docs.find
#             model:'picpedia'

# Template.pic.onCreated ->
    # Session.setDefault('user_query', null)
    # Session.setDefault('location_query', null)
    # @autorun => Meteor.subscribe 'sub_docs_by_name', Router.current().params.name

# Template.pic_doc_item.events
#     'click .view_post': (e,t)-> 
#         window.speechSynthesis.speak new SpeechSynthesisUtterance @title
#         # Router.go "/pic/#{@pic}/post/#{@_id}"

Template.pics.helpers
    pic_doc: ->
        Docs.findOne
            model:'pic'
            "data.display_name":Router.current().params.name
            