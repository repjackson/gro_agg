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





Template.print_this.events
    'click .print_this': ->
        console.log @
#
#     Template.session_toggle_button.helpers
#         session_toggle_button_class: ->
#             if Template.instance().subscriptionsReady()
#                 if Session.get(@key) then 'grey' else 'basic'
#             else
#                 'disabled loading'
#     Template.session_toggle_button.events
#         'click .toggle': -> Session.set(@key, !Session.get(@key))
#
#     Template.comments.onRendered ->
#         Meteor.setTimeout ->
#             $('.accordion').accordion()
#         , 1000
Template.comments.onCreated ->
    # if Router.current().params.doc_id
    #     parent = Docs.findOne Router.current().params.doc_id
    # else
    #     parent = Docs.findOne Template.parentData()._id
    # if parent
    @autorun => Meteor.subscribe 'children', 'comment', @data._id
Template.comments.helpers
    doc_comments: ->
        # console.log Template.parentData()
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.currentData()
        if Router.current().params.doc_id
            parent = Docs.findOne Router.current().params.doc_id
        else
            parent = Docs.findOne Template.currentData()._id
        # if Meteor.user()
        Docs.find
            parent_id:parent._id
            model:'comment'
        # else
        #     Docs.find
        #         model:'comment'
        #         parent_id:parent._id
        #         _author_id:$exists:false
                
Template.comments.events
    'keyup .add_comment': (e,t)->
        if e.which is 13
            if Router.current().params.doc_id
                parent = Docs.findOne Router.current().params.doc_id
            else
                parent = Docs.findOne Template.currentData()._id
            # parent = Docs.findOne Router.current().params.doc_id
            comment = t.$('.add_comment').val()
            Docs.insert
                parent_id: parent._id
                model:'comment'
                # parent_model:parent.model
                body:comment
            t.$('.add_comment').val('')

    'click .remove_comment': ->
        if confirm 'Confirm remove comment'
            Docs.remove @_id

Template.session_key_value.events
    'click .set_session_value': ->
        # console.log @
        if Session.equals(@key,@value)
            Session.set(@key, null)
        else
            Session.set(@key, @value)

Template.session_key_value.helpers
    button_class: ->
        # console.log @
        if Session.equals(@key, @value) then 'active' else 'basic'


#
Template.registerHelper 'is_editing_this', () ->
    Session.equals('is_editing_id', @_id)
    
    
Template.session_edit_toggle.events
    'click .toggle_edit': ->
        # console.log @
        if Session.equals('is_editing_id', @_id)
            Session.set('is_editing_id', null)
        else
            Session.set('is_editing_id', @_id)

Template.session_edit_toggle.helpers
    toggle_button_class: ->
        # console.log @
        if Session.equals('is_editing_id', @_id) then 'black' else 'basic'


#
#
#
Template.voting.events
    'click .upvote': (e,t)->
        # $(e.currentTarget).closest('.button').transition('pulse',200)
        Meteor.call 'upvote', @, ->
    'click .downvote': (e,t)->
        # $(e.currentTarget).closest('.button').transition('pulse',200)
        Meteor.call 'downvote', @, ->
#
#
#
Template.remove_button.events
    'click .remove_doc': (e,t)->
        if confirm "remove #{@model}?"
            # if $(e.currentTarget).closest('.card')
            #     $(e.currentTarget).closest('.card').transition('fly right', 1000)
            # else
            #     $(e.currentTarget).closest('.segment').transition('fly right', 1000)
            #     $(e.currentTarget).closest('.item').transition('fly right', 1000)
            #     $(e.currentTarget).closest('.content').transition('fly right', 1000)
            #     $(e.currentTarget).closest('tr').transition('fly right', 1000)
            #     $(e.currentTarget).closest('.event').transition('fly right', 1000)
            # Meteor.setTimeout =>
            Docs.remove @_id
            # , 1000


Template.remove_icon.events
    'click .remove_doc': (e,t)->
        if confirm "remove #{@model}?"
            if $(e.currentTarget).closest('.card')
                $(e.currentTarget).closest('.card').transition('fly right', 1000)
            else
                $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                $(e.currentTarget).closest('.item').transition('fly right', 1000)
                $(e.currentTarget).closest('.content').transition('fly right', 1000)
                $(e.currentTarget).closest('tr').transition('fly right', 1000)
                $(e.currentTarget).closest('.event').transition('fly right', 1000)
            Meteor.setTimeout =>
                Docs.remove @_id
            , 1000

#
Template.key_value_edit.events
    'click .set_key_value': ->
        parent = Template.parentData()
        # console.log 'hi'
        # parent = Docs.findOne Router.current().params.doc_id
        Docs.update parent._id,
            $set: "#{@k}": @v

Template.key_value_edit.helpers
    set_key_value_class: ->
        # parent = Docs.findOne Router.current().params.doc_id
        parent = Template.parentData()
        # console.log parent
        if parent["#{@k}"] is @v then 'active' else 'basic'


Template.session_edit_value_button.events
    'click .set_session_value': ->
        # console.log @key
        # console.log @value
        Session.set(@key, @value)

Template.session_edit_value_button.helpers
    calculated_class: ->
        res = ''
        # console.log @
        if @classes
            res += @classes
        if Session.equals(@key,@value)
            res += ' active'
        # console.log res
        res



Template.session_boolean_toggle.events
    'click .toggle_session_key': ->
        console.log @key
        Session.set(@key, !Session.get(@key))

Template.session_boolean_toggle.helpers
    calculated_class: ->
        res = ''
        # console.log @
        if @classes
            res += @classes
        if Session.get(@key)
            res += ' blue'
        else
            res += ' basic'

        # console.log res
        res
