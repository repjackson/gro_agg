Router.route '/g/:group', (->
    @layout 'layout'
    @render 'group'
    ), name:'group'
Router.route '/:group', (->
    @layout 'layout'
    @render 'group'
    ), name:'group_short'

@selected_tags = new ReactiveArray []
@selected_time_tags = new ReactiveArray []
@selected_location_tags = new ReactiveArray []


    

Template.group.onCreated ->
    if Router.current().params.group
        @autorun => Meteor.subscribe 'doc', Router.current().params.group
    if Router.current().params.group
        @autorun => Meteor.subscribe 'doc_from_group', Router.current().params.group
    # @autorun => Meteor.subscribe 'shop_from_group', Router.current().params.group
    @autorun => Meteor.subscribe 'group_tags',
        Router.current().params.group
        selected_tags.array()
        selected_time_tags.array()
        selected_location_tags.array()
        # selected_group_authors.array()
        Session.get('toggle')
    @autorun => Meteor.subscribe 'group_count', 
        Router.current().params.group
        selected_tags.array()
        selected_time_tags.array()
        selected_location_tags.array()
    
    @autorun => Meteor.subscribe 'group_posts', 
        Router.current().params.group
        selected_tags.array()
        selected_time_tags.array()
        selected_location_tags.array()
        Session.get('group_sort_key')
        Session.get('group_sort_direction')
        Session.get('group_skip_value')

Template.group.helpers
    posts: ->
        if Router.current().params.group is 'all'
            Docs.find 
                model:'post'
                group:$exists:false
        else
            Docs.find 
                model:'post'
                group:Router.current().params.group
                
    # group_posts: ->
    #     Docs.find 
    #         model:'post'
    #         course_id:Router.current().params.group
    selected_tags: -> selected_tags.array()
    selected_time_tags: -> selected_time_tags.array()
    selected_location_tags: -> selected_location_tags.array()
    selected_people_tags: -> selected_people_tags.array()
    counter: -> Counts.get 'counter'
    result_tags: -> results.find(model:'group_tag')
    time_tags: -> results.find(model:'time_tag')
    location_tags: -> results.find(model:'location_tag')
    current_group: ->
        Router.current().params.group
        
Template.group.events
    # 'click .unselect_group_tag': -> 
    #     Session.set('skip',0)
    #     # console.log @
    #     selected_tags.remove @valueOf()
    #     # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()

    # 'click .select_tag': -> 
    #     # results.update
    #     # console.log @
    #     # window.speechSynthesis.cancel()
    #     window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    #     # if @model is 'group_emotion'
    #     #     selected_emotions.push @name
    #     # else
    #     # if @model is 'group_tag'
    #     selected_tags.push @name
    #     $('.search_subgroup').val('')
    #     Session.set('group_skip_value',0)

    'click .unselect_time_tag': ->
        selected_time_tags.remove @valueOf()
    'click .select_time_tag': ->
        selected_time_tags.push @name
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
    'click .unselect_location_tag': ->
        selected_location_tags.remove @valueOf()
    'click .select_location_tag': ->
        selected_location_tags.push @name
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name

    'click .add_post': ->
        new_id = 
            Docs.insert 
                model:'post'
                group:Router.current().params.group
        Router.go "/g/#{Router.current().params.group}/p/#{new_id}/edit"
    'keyup .search_group_tag': (e,t)->
         if e.which is 13
            val = t.$('.search_group_tag').val().trim().toLowerCase()
            window.speechSynthesis.speak new SpeechSynthesisUtterance val
            selected_tags.push val   
            t.$('.search_group_tag').val('')
        
        
        
        
Template.tag_selector.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
Template.tag_selector.helpers
    selector_class: ()->
        term = 
            Docs.findOne 
                title:@name.toLowerCase()
        if term
            if term.max_emotion_name
                switch term.max_emotion_name
                    when 'joy' then " basic green"
                    when "anger" then " basic red"
                    when "sadness" then " basic blue"
                    when "disgust" then " basic orange"
                    when "fear" then " basic grey"
                    else "basic grey"
    term: ->
        res = 
            Docs.findOne 
                title:@name.toLowerCase()
        if res and res.metadata
            console.log res.metadata.image
            res
            
Template.tag_selector.events
    'click .select_tag': -> 
        # results.update
        # console.log @
        # window.speechSynthesis.cancel()
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # if @model is 'group_emotion'
        #     selected_emotions.push @name
        # else
        # if @model is 'group_tag'
        selected_tags.push @name
        $('.search_subgroup').val('')
        Session.set('group_skip_value',0)

        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        # Session.set('group_loading',true)
        # Meteor.call 'search_group', @name, ->
        #     Session.set('group_loading',false)
        # Meteor.setTimeout( ->
        #     Session.set('toggle',!Session.get('toggle'))
        # , 5000)
        
        
        

Template.unselect_tag.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title_small', @data.toLowerCase())
    
Template.unselect_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
Template.unselect_tag.events
    'click .unselect_tag': -> 
        Session.set('skip',0)
        # console.log @
        selected_tags.remove @valueOf()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
    

Template.flat_tag_selector.onCreated ->
    # @autorun => Meteor.subscribe('doc_by_title_small', @data.valueOf().toLowerCase())
Template.flat_tag_selector.helpers
    selector_class: ()->
        term = 
            Docs.findOne 
                title:@valueOf().toLowerCase()
        if term
            if term.max_emotion_name
                switch term.max_emotion_name
                    when 'joy' then " basic green"
                    when "anger" then " basic red"
                    when "sadness" then " basic blue"
                    when "disgust" then " basic orange"
                    when "fear" then " basic grey"
                    else "basic grey"
    term: ->
        Docs.findOne 
            title:@valueOf().toLowerCase()
Template.flat_tag_selector.events
    'click .select_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        selected_tags.push @valueOf()
        $('.search_group').val('')




Router.route '/g/:group/p/:doc_id/edit', (->
    @layout 'layout'
    @render 'group_post_edit'
    ), name:'group_post_edit'
Router.route '/g/:group/p/:doc_id', (->
    @layout 'layout'
    @render 'group_post_view'
    ), name:'group_post_view'

Template.group_post_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
Template.group_post_view.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'comments', Router.current().params.doc_id

Template.group_post_view.onRendered ->
    Meteor.call 'log_view', Router.current().params.doc_id, ->
# Router.route '/posts', (->
#     @layout 'layout'
#     @render 'posts'
#     ), name:'posts'

Template.group_post_edit.events
    'click .delete_post': ->
        if confirm 'delete?'
            Docs.remove @_id
            Router.go "/"

    'click .publish': ->
        if confirm 'publish post?'
            Meteor.call 'publish_post', @_id, =>
