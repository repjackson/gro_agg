@picked_tags = new ReactiveArray []
@picked_times = new ReactiveArray []
@picked_locations = new ReactiveArray []
@picked_authors = new ReactiveArray []

Router.route '/p/:doc_id/edit', (->
    @layout 'layout'
    @render 'post_edit'
    ), name:'post_edit'

Router.route '/p/:doc_id/view', (->
    @layout 'layout'
    @render 'post_view'
    ), name:'post_view'

Template.post_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
Template.post_view.onCreated ->
    Meteor.call 'log_view', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

Template.post_view.helpers
    reflections: ->
        Docs.find
            model:'reflection'
            parent_id:Router.current().params.doc_id


Template.post_view.events
    'click .search_dao': ->
        picked_tags.clear()
        Router.go '/'

Template.home.onCreated ->
    # Session.setDefault('subreddit_view_layout', 'grid')
    Session.setDefault('sort_key', '_timestamp')
    Session.setDefault('sort_direction', -1)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'dao_tags',
        picked_tags.array()
        picked_times.array()
        picked_locations.array()
        picked_authors.array()
    @autorun => Meteor.subscribe 'post_count', 
        picked_tags.array()
        picked_times.array()
        picked_locations.array()
        picked_authors.array()
    @autorun => Meteor.subscribe 'posts', 
        picked_tags.array()
        picked_times.array()
        picked_locations.array()
        picked_authors.array()
        Session.get('sort_key')
        Session.get('sort_direction')
        Session.get('skip_value')





Template.home.helpers
    card_class: ->
        if Meteor.userId()
            if @read_ids 
                if Meteor.userId() in @read_ids
                    'link'
                else
                    'raised link'
            else
                'raised link'
        else
            'raised link'
    posts: ->
        Docs.find {
            model:'post'
        }, sort: _timestamp:-1
       
    picked_tags: -> picked_tags.array()
    picked_locations: -> picked_locations.array()
    picked_authors: -> picked_authors.array()
    picked_times: -> picked_times.array()
    post_counter: -> Counts.get 'post_counter'
    
    result_tags: -> results.find(model:'tag')
    author_results: -> results.find(model:'author')
    location_results: -> results.find(model:'location_tag')
    time_results: -> results.find(model:'time_tag')
        
        
Template.user_post_small.events
    'click .mark_read': (e,t)->
        console.log 'hi'
        if Meteor.userId()
            Docs.update @_id,
                $addToSet:read_ids:Meteor.userId()
Template.home.events
    'click .mark_read': (e,t)->
        console.log 'hi'
        if Meteor.userId()
            Docs.update @_id,
                $addToSet:read_ids:Meteor.userId()
            Meteor.users.update Meteor.userId(),
                $inc:points:1
    'keyup .search_tag': (e,t)->
         if e.which is 13
            val = t.$('.search_tag').val().trim().toLowerCase()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance val
            picked_tags.push val   
            t.$('.search_tag').val('')
            # Session.set('sub_doc_query', val)



    'click .make_private': ->
        # if confirm 'make private?'
        Docs.update @_id,
            $set:is_private:true

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


    'keyup .search_love_tag': (e,t)->
         if e.which is 13
            val = t.$('.search_love_tag').val().trim().toLowerCase()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance val
            picked_tags.push val   
            t.$('.search_love_tag').val('')
            
            
    Template.tag_picker.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
    Template.tag_picker.helpers
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
                
    Template.tag_picker.events
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
            Session.set('skip_value',0)
    
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
            # Session.set('love_loading',true)
            # Meteor.call 'search_love', @name, ->
            #     Session.set('love_loading',false)
            # Meteor.setTimeout( ->
            #     Session.set('toggle',!Session.get('toggle'))
            # , 5000)
            
            
            
    
    Template.unpick_tag.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
        
    Template.unpick_tag.helpers
        term: ->
            found = 
                Docs.findOne 
                    # model:'wikipedia'
                    title:@valueOf().toLowerCase()
            found
    Template.unpick_tag.events
        'click .unpick_tag': -> 
            Session.set('skip',0)
            # console.log @
            picked_tags.remove @valueOf()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        
    
    Template.flat_tag_picker.onCreated ->
        # @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
    Template.flat_tag_picker.helpers
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
    Template.flat_tag_picker.events
        'click .pick_flat_tag': -> 
            # results.update
            # window.speechSynthesis.cancel()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
            picked_tags.push @valueOf()
            $('.search_tags').val('')

