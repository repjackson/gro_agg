# Router.route '/g/:name/p/:doc_id', (->
#     @layout 'layout'
#     @render 'git_page'
#     ), name:'git_page'
    
    
Router.route '/github', (->
    @layout 'layout'
    @render 'github'
    ), name:'github'

    
    
# Template.git_page.onCreated ->
#     @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)

# Template.git_page.events
#     'click .get_post': ->
#         Meteor.call 'get_gh_post', Router.current().params.doc_id, @gh_id, ->

Template.github.onCreated ->
    Session.setDefault('gh_query',null)
    @autorun -> Meteor.subscribe('github',
        Session.get('gh_query')
        selected_tags.array())

Template.github.events
    'click .goto_article': (e,t)->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
    'keyup .search_gh': (e,t)->
        val = $('.search_gh').val()
        Session.set('gh_query', val)
        if e.which is 13 
            Meteor.call 'search_gh', val, ->
                $('.search_gh').val('')
                Session.set('gh_query', null)

Template.github.helpers
    gh_docs: ->
        Docs.find
            model:'ghpedia'

Template.github.onCreated ->
    # Session.setDefault('user_query', null)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'sub_docs_by_name', Router.current().params.name

# Template.gh_doc_item.events
#     'click .view_post': (e,t)-> 
#         window.speechSynthesis.speak new SpeechSynthesisUtterance @title
#         # Router.go "/gh/#{@gh}/post/#{@_id}"

Template.github.helpers
    gh_doc: ->
        Docs.findOne
            model:'gh'
            "data.display_name":Router.current().params.name
            