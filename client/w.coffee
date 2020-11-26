Router.route '/w/:name/p/:doc_id', (->
    @layout 'layout'
    @render 'wiki_page'
    ), name:'wiki_page'
    
    
Router.route '/wiki', (->
    @layout 'layout'
    @render 'wiki'
    ), name:'wiki'

    
    
Template.wiki_page.onCreated ->
    @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)

Template.wiki_page.events
    'click .get_post': ->
        Meteor.call 'get_wiki_post', Router.current().params.doc_id, @wiki_id, ->

Template.wiki.onCreated ->
    Session.setDefault('wiki_query',null)
    @autorun -> Meteor.subscribe('wikis',
        Session.get('wiki_query')
        selected_tags.array())

Template.wiki.events
    'click .goto_article': (e,t)->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
    'keyup .search_wiki': (e,t)->
        val = $('.search_wiki').val()
        Session.set('wiki_query', val)
        if e.which is 13 
            Meteor.call 'search_wiki', val, ->
                $('.search_wiki').val('')
                Session.set('wiki_query', null)

Template.wiki.helpers
    wiki_docs: ->
        Docs.find
            model:'wikipedia'

Template.wiki.onCreated ->
    # Session.setDefault('user_query', null)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'sub_docs_by_name', Router.current().params.name

# Template.wiki_doc_item.events
#     'click .view_post': (e,t)-> 
#         window.speechSynthesis.speak new SpeechSynthesisUtterance @title
#         # Router.go "/wiki/#{@wiki}/post/#{@_id}"

Template.wiki.helpers
    wiki_doc: ->
        Docs.findOne
            model:'wiki'
            "data.display_name":Router.current().params.name
            