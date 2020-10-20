
@selected_tags = new ReactiveArray []

# Template.body.events
#     'click a:not(.select_term)': ->
#         $('.global_container')
#         .transition('fade out', 200)
#         .transition('fade in', 200)
#         # unless Meteor.user().invert_class is 'invert'

Router.route '/', (->
    @layout 'layout'
    @render 'questions'
    ), name:'questions'



    
    # many_tags: -> selected_tags.array().length > 1
    # one_post: ->
    #     match = {model:$in:['post','wikipedia','reddit']}
    #     # match = {model:$in:['post','wikipedia','reddit','porn']}
        
    #     # match = {model:'post'}
    #     if selected_tags.array().length>0
    #         match.tags = $in:selected_tags.array()

    #     Docs.find(match).count() is 1

    # two_posts: -> 
    #     match = {model:$in:['post','wikipedia','reddit']}
    #     # match = {model:$in:['post','wikipedia','reddit','porn']}
        
    #     # match = {model:'post'}
    #     if selected_tags.array().length>0
    #         match.tags = $in:selected_tags.array()
    #     Docs.find(match).count() is 2
    # three_posts: -> Docs.find().count() is 3


    # docs: ->
    #     # match = {model:$in:['porn']}
    #     # match = {model:$in:['post','wikipedia','reddit','porn']}
    #     match = {model:$in:['post','wikipedia','reddit']}
        
    #     # match = {model:'post'}
    #     if selected_tags.array().length>0
    #         match.tags = $all:selected_tags.array()
    #     # cur = Docs.find match
    #     Docs.find match,
    #         sort:
    #             # points:-1
    #             ups:-1
    #             views:-1
    #             _timestamp:-1
    #             # "#{Session.get('sort_key')}": Session.get('sort_direction')
    #         limit:5
    #     # if cur.count() is 1
    #     # Docs.find match
    # home_button_class: ->
    #     if Template.instance().subscriptionsReady()
    #         ''
    #     else
    #         'disabled loading'

        
    # term: ->
    #     # console.log @
    #     Docs.find 
    #         model:$in:['wikipedia']
    #         lower_title:@name
    
    # selected_tags: -> selected_tags.array()
    # tag_results: ->
    #     # doc_count = Docs.find({model:$in:['post','wikipedia','reddit','porn']}).count()
    #     doc_count = Docs.find({model:$in:['porn']}).count()
    #     if 0 < doc_count < 3 
    #         Tag_results.find({ 
    #             count:$lt:doc_count 
    #         })
    #     else 
    #         Tag_results.find()

            
Template.session_key_value_edit.events
    'click .set_session_var': ->
        Session.set("#{@key}",@value)
        
        
Template.questions.events
    # 'click .delete': -> 
    #     console.log @
    #     Docs.remove @_id
    'click .post': ->
        new_post_id =
            Docs.insert
                model:'post'
                source:'self'
                # buyer_id:Meteor.userId()
                # buyer_username:Meteor.user().username
                
        Router.go "/post/#{new_post_id}/edit"

    'keydown .search_questions': (e,t)->
        search = $('.search_questions').val().toLowerCase().trim()
        Session.set('query',search)
        if e.which is 13
            console.log search
            # selected_tags.push search
            # if Meteor.user()
            Session.set('query','')
            search = $('.search_questions').val('')
        if e.which is 27
            Session.set('query','')
            search = $('.search_questions').val('')
            
        # if e.which is 8
        #     if search.length is 0
        #         selected_tags.pop()

    'keydown .ask_question': (e,t)->
        search = $('.ask_question').val().toLowerCase().trim()
        Session.set('query',search)
        if e.which is 13
            console.log search
            # selected_tags.push search
            # if Meteor.user()
            Session.set('query','')
            search = $('.ask_question').val('')
            Docs.insert 
                model:'question'
                title:search
        if e.which is 27
            Session.set('query','')
            search = $('.ask_question').val('')
            
        # if e.which is 8
        #     if search.length is 0
        #         selected_tags.pop()


    'click #clear_tags': -> selected_tags.clear()


    'keydown .search_title': (e,t)->
        search = $('.search_title').val().toLowerCase().trim()
        Session.set('query',search)
        if e.which is 13
            console.log search
            selected_tags.push search
            # if Meteor.user()
            # Meteor.call 'search_ph', selected_tags.array(), ->
            Meteor.call 'call_wiki', search, ->
            Meteor.call 'search_reddit', selected_tags.array(), ->
            Session.set('query','')
            search = $('.search_title').val('')
        # if e.which is 8
        #     if search.length is 0
        #         selected_tags.pop()
