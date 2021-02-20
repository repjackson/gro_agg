@picked_tags = new ReactiveArray []
@picked_times = new ReactiveArray []
@picked_locations = new ReactiveArray []
@picked_authors = new ReactiveArray []
@picked_l = new ReactiveArray []
@picked_o = new ReactiveArray []
@picked_v = new ReactiveArray []
@picked_e = new ReactiveArray []

Router.route '/love/:doc_id/view', (->
    @layout 'layout'
    @render 'love_view'
    ), name:'love_view'

Router.route '/love/:doc_id/edit', (->
    @layout 'layout'
    @render 'love_edit'
    ), name:'love_edit'

Router.route '/reflection/:doc_id/edit', (->
    @layout 'layout'
    @render 'reflection_edit'
    ), name:'reflection_edit'

Router.route '/reflection/:doc_id/view', (->
    @layout 'layout'
    @render 'reflection_view'
    ), name:'reflection_view'

Template.reflection_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
Template.reflection_view.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

Template.love_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
Template.love_view.onCreated ->
    Meteor.call 'log_view', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'love_reflections', Router.current().params.doc_id

Template.love_view.helpers
    reflections: ->
        Docs.find
            model:'reflection'
            parent_id:Router.current().params.doc_id


Template.love_view.events
    'click .search_dao': ->
        picked_tags.clear()
        picked_tags.push @l_value
        picked_tags.push @o_value
        picked_tags.push @v_value
        picked_tags.push @e_value
        Meteor.call 'search_reddit', picked_tags.array(), ->
        Router.go '/'

Template.love.onCreated ->
    # Session.setDefault('subreddit_view_layout', 'grid')
    Session.setDefault('sort_key', '_timestamp')
    Session.setDefault('sort_direction', -1)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'love_tags',
        picked_tags.array()
        picked_times.array()
        picked_locations.array()
        picked_authors.array()
        picked_l.array()
        picked_o.array()
        picked_v.array()
        picked_e.array()
    @autorun => Meteor.subscribe 'love_count', 
        picked_tags.array()
        picked_times.array()
        picked_locations.array()
        picked_authors.array()
        picked_l.array()
        picked_o.array()
        picked_v.array()
        picked_e.array()
    
    @autorun => Meteor.subscribe 'expressions', 
        picked_tags.array()
        picked_times.array()
        picked_locations.array()
        picked_authors.array()
        picked_l.array()
        picked_o.array()
        picked_v.array()
        picked_e.array()
        Session.get('love_sort_key')
        Session.get('love_sort_direction')
        Session.get('love_skip_value')





Template.love.helpers
    expressions: ->
        Docs.find {
            model:'love'
        }, sort: _timestamp:-1
       
    picked_tags: -> picked_tags.array()
    picked_l: -> picked_l.array()
    picked_o: -> picked_o.array()
    picked_v: -> picked_v.array()
    picked_e: -> picked_e.array()

    picked_locations: -> picked_locations.array()
    picked_authors: -> picked_authors.array()
    picked_times: -> picked_times.array()
    love_counter: -> Counts.get 'love_counter'
    
    result_tags: -> results.find(model:'love_tag')
    author_results: -> results.find(model:'author')
    location_results: -> results.find(model:'location_tag')
    time_results: -> results.find(model:'time_tag')
    l_results: -> results.find(model:'l_tag')
    o_results: -> results.find(model:'o_tag')
    v_results: -> results.find(model:'v_tag')
    e_results: -> results.find(model:'e_tag')
        
        
Template.love_view.events
    'click .add_reflection': ->
        new_id = 
            Docs.insert 
                model:'reflection'
                parent_id:Router.current().params.doc_id
        Router.go "/reflection/#{new_id}/edit"
Template.love.events
    'click .upvote': ->
        Docs.update @_id,
            $inc:points:1
    'click .downvote': ->
        Docs.update @_id,
            $inc:points:-1
    'keyup .add_tag': (e,t)->
        if e.which is 13
            new_tag = $(e.currentTarget).closest('.add_tag').val().toLowerCase().trim()
            Docs.update @_id,
                $addToSet: tags:new_tag
            $(e.currentTarget).closest('.add_tag').val('')
            
            
    'click .unpick_time': ->
        picked_times.remove @valueOf()
    'click .pick_time': ->
        picked_times.push @name
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
    'click .pick_flat_time': ->
        picked_times.push @valueOf()
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
    'click .unpick_location': ->
        picked_locations.remove @valueOf()
    'click .pick_location': ->
        picked_locations.push @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
    'click .unpick_author': ->
        picked_authors.remove @valueOf()
    'click .pick_author': ->
        picked_authors.push @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name

    'click .pick_l': -> 
        if @name
            picked_l.push @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        else 
            picked_l.push @l_value
            window.speechSynthesis.speak new SpeechSynthesisUtterance @l_value
            
    'click .unpick_l': -> picked_l.remove @valueOf()

    'click .pick_o': -> 
        if @name
            picked_o.push @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        else 
            picked_o.push @o_value
            window.speechSynthesis.speak new SpeechSynthesisUtterance @o_value
    'click .unpick_o': -> picked_o.remove @valueOf()

    'click .pick_v': -> 
        if @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            picked_v.push @name
        else
            picked_v.push @v_value
            window.speechSynthesis.speak new SpeechSynthesisUtterance @v_value
    'click .unpick_v': -> picked_v.remove @valueOf()

    'click .pick_e': -> 
        if @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            picked_e.push @name
        else
            picked_e.push @e_value
            window.speechSynthesis.speak new SpeechSynthesisUtterance @e_value
    'click .unpick_e': -> picked_e.remove @valueOf()

    'keyup .search_love_tag': (e,t)->
         if e.which is 13
            val = t.$('.search_love_tag').val().trim().toLowerCase()
            window.speechSynthesis.speak new SpeechSynthesisUtterance val
            picked_tags.push val   
            t.$('.search_love_tag').val('')
            
            
    'click .submit': ->
        l = $('.add_l').val().toLowerCase().trim()
        o = $('.add_o').val().toLowerCase().trim()
        v = $('.add_v').val().toLowerCase().trim()
        e = $('.add_e').val().toLowerCase().trim()
        location = $('.add_location').val().toLowerCase().trim()
        author = $('.add_author').val().toLowerCase().trim()
        if confirm 'submit expression?'
            $('.add_l').val('')
            $('.add_o').val('')
            $('.add_v').val('')
            $('.add_e').val('')
            $('.add_location').val('')
            $('.add_author').val('')
            
            Docs.insert 
                model:'love'
                l_value:l
                o_value:o
                v_value:v
                e_value:e
                location:location
                author:author
                
            
    Template.love_tag_picker.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
    Template.love_tag_picker.helpers
        picker_class: ()->
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
            # console.log res
            res
                
    Template.love_tag_picker.events
        'click .pick_tag': -> 
            # results.update
            # console.log @
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # if @model is 'love_emotion'
            #     picked_emotions.push @name
            # else
            # if @model is 'love_tag'
            picked_tags.push @name
            $('.search_sublove').val('')
            Session.set('love_skip_value',0)
    
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
            # Session.set('love_loading',true)
            # Meteor.call 'search_love', @name, ->
            #     Session.set('love_loading',false)
            # Meteor.setTimeout( ->
            #     Session.set('toggle',!Session.get('toggle'))
            # , 5000)
            
            
            
    
    Template.love_unpick_tag.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
        
    Template.love_unpick_tag.helpers
        term: ->
            found = 
                Docs.findOne 
                    # model:'wikipedia'
                    title:@valueOf().toLowerCase()
            found
    Template.love_unpick_tag.events
        'click .love_unpick_tag': -> 
            Session.set('skip',0)
            # console.log @
            picked_tags.remove @valueOf()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        
    
    Template.flat_love_tag_picker.onCreated ->
        # @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
    Template.flat_love_tag_picker.helpers
        picker_class: ()->
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
    Template.flat_love_tag_picker.events
        'click .pick_flat_tag': -> 
            # results.update
            # window.speechSynthesis.cancel()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
            picked_tags.push @valueOf()
            $('.search_love').val('')

