Template.love.onCreated ->
    # Session.setDefault('subreddit_view_layout', 'grid')
    Session.setDefault('sort_key', 'data.created')
    Session.setDefault('sort_direction', -1)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'love_tags',
        selected_love_tags.array()
        selected_time_tags.array()
        selected_love_location_tags.array()
        # selected_love_authors.array()
    @autorun => Meteor.subscribe 'love_count', 
        selected_love_tags.array()
        selected_time_tags.array()
        selected_love_location_tags.array()
    
    @autorun => Meteor.subscribe 'expressions', 
        selected_love_tags.array()
        selected_time_tags.array()
        selected_love_location_tags.array()
        Session.get('love_sort_key')
        Session.get('love_sort_direction')
        Session.get('love_skip_value')



@selected_love_tags = new ReactiveArray []
@selected_love_time_tags = new ReactiveArray []
@selected_love_location_tags = new ReactiveArray []


Template.love.helpers
    expressions: ->
        Docs.find
            model:'love'
       
       
    selected_love_tags: -> selected_love_tags.array()
    # selected_time_tags: -> selected_time_tags.array()
    selected_love_location_tags: -> selected_love_location_tags.array()
    selected_love_author_tags: -> selected_love_author_tags.array()
    counter: -> Counts.get 'counter'
    love_result_tags: -> results.find(model:'love_tag')
    love_author_tags: -> results.find(model:'love_author_tag')
    love_location_tags: -> results.find(model:'love_location_tag')
        
        
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
            
            
    'click .unselect_time_tag': ->
        selected_time_tags.remove @valueOf()
    'click .select_time_tag': ->
        selected_time_tags.push @name
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
    'click .unselect_location_tag': ->
        selected_love_location_tags.remove @valueOf()
    'click .select_location_tag': ->
        selected_love_location_tags.push @name
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name

    'keyup .search_love_tag': (e,t)->
         if e.which is 13
            val = t.$('.search_love_tag').val().trim().toLowerCase()
            window.speechSynthesis.speak new SpeechSynthesisUtterance val
            selected_love_tags.push val   
            t.$('.search_love_tag').val('')
            
            
    'click .submit': ->
        l = $('.add_l').val().toLowerCase().trim()
        o = $('.add_o').val().toLowerCase().trim()
        v = $('.add_v').val().toLowerCase().trim()
        e = $('.add_e').val().toLowerCase().trim()
        console.log l,o,v,e
        if confirm 'submit expression?'
            $('.add_l').val('')
            $('.add_o').val('')
            $('.add_v').val('')
            $('.add_e').val('')
            
            Docs.insert 
                model:'love'
                l_value:l
                o_value:o
                v_value:v
                e_value:e
                
                
            
    Template.love_tag_selector.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
    Template.love_tag_selector.helpers
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
            # console.log res
            res
                
    Template.love_tag_selector.events
        'click .select_tag': -> 
            # results.update
            # console.log @
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # if @model is 'love_emotion'
            #     selected_emotions.push @name
            # else
            # if @model is 'love_tag'
            selected_love_tags.push @name
            $('.search_sublove').val('')
            Session.set('love_skip_value',0)
    
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
            # Session.set('love_loading',true)
            # Meteor.call 'search_love', @name, ->
            #     Session.set('love_loading',false)
            # Meteor.setTimeout( ->
            #     Session.set('toggle',!Session.get('toggle'))
            # , 5000)
            
            
            
    
    Template.love_unselect_tag.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title_small', @data.toLowerCase())
        
    Template.love_unselect_tag.helpers
        term: ->
            found = 
                Docs.findOne 
                    # model:'wikipedia'
                    title:@valueOf().toLowerCase()
            found
    Template.love_unselect_tag.events
        'click .unselect_tag': -> 
            Session.set('skip',0)
            # console.log @
            selected_love_tags.remove @valueOf()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        
    
    Template.love_flat_tag_selector.onCreated ->
        # @autorun => Meteor.subscribe('doc_by_title_small', @data.valueOf().toLowerCase())
    Template.love_flat_tag_selector.helpers
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
    Template.love_flat_tag_selector.events
        'click .select_flat_tag': -> 
            # results.update
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
            selected_love_tags.push @valueOf()
            $('.search_love').val('')

                