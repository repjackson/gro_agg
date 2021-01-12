@selected_trump_tags = new ReactiveArray []
@selected_trump_subtrumps = new ReactiveArray []
@selected_subtrump_tags = new ReactiveArray []
@selected_trump_domain = new ReactiveArray []
@selected_trump_time_tags = new ReactiveArray []
@selected_trump_authors = new ReactiveArray []



Router.route '/trump', (->
    @layout 'layout'
    @render 'trump'
    ), name:'trump'

Template.trump.onCreated ->
    Session.setDefault('trump_skip_value', 0)
    Session.setDefault('trump_view_layout', 'grid')
    Session.setDefault('sort_key', 'data.created')
    Session.setDefault('trump_sort_direction', -1)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'subrzeddit_user_count', Router.current().params.subtrump
    @autorun => Meteor.subscribe 'trump_docs', 
        selected_trump_tags.array()
        selected_trump_time_tags.array()
        Session.get('trump_sort_key')
        Session.get('trump_sort_direction')
        Session.get('trump_skip_value')
  
    @autorun => Meteor.subscribe 'trump_count', 
        selected_trump_tags.array()
        selected_trump_time_tags.array()

    @autorun => Meteor.subscribe 'trump_tags',
        selected_trump_tags.array()
        selected_trump_time_tags.array()
        selected_trump_subtrumps.array()
        selected_trump_authors.array()
        Session.get('toggle')
    Meteor.call 'get_trump_latest', Router.current().params.subtrump, ->

    Meteor.call 'log_trump_view', Router.current().params.subtrump, ->
    @autorun => Meteor.subscribe 'agg_sentiment_subtrump',
        Router.current().params.subtrump
        selected_trump_tags.array()
        ()->Session.set('ready',true)


Template.trump_card.onRendered ->
    # console.log @
    unless @data.watson
        Meteor.call 'call_watson',@data._id,'','trump','',=>
    unless @time_tags
        Meteor.call 'tagify_trump',@data._id,=>
Template.trump_card.events
    'click .set_time_tag': ->
        selected_trump_time_tags.push @valueOf()
    'click .vote_up': ->
        Docs.update @_id,
            $inc:points:1
    'click .vote_down': ->
        Docs.update @_id,
            $inc:points:-1
    'keyup .tag_tweet': (e,t)->
        if e.which is 13 
            val = $(e.currentTarget).closest('.tag_tweet').val()
            console.log val
            Docs.update @_id,
                $addToSet:
                    tags:val
                    public_tags:val
            $('.tag_tweet').val('')
            # Session.set('trump_skip_value', val)
Template.trump.events
    'click .sort_down': (e,t)-> Session.set('trump_sort_direction',-1)
    # 'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
    'click .sort_up': (e,t)-> Session.set('trump_sort_direction',1)
    'click .limit_10': (e,t)-> Session.set('limit',10)
    'click .limit_1': (e,t)-> Session.set('limit',1)
   
    # 'click .selected_trump_domain': ->
    #     selected_trump_domains.push @name
    # 'click .selected_trump_domain': ->
    #     selected_trump_domains.remove @valueOf()
   
    # 'click .selected_trump_author': ->
    #     selected_trump_authors.push @name
    # 'click .selected_trump_author': ->
    #     selected_trump_authors.remove @valueOf()
   
    # 'click .selected_trump_time_tag': ->
    #     selected_trump_time_tags.push @name
    'click .unselect_trump_time_tag': ->
        selected_trump_time_tags.remove @valueOf()
   
    # 'click .select_trump_tag': ->
    #     selected_trump_tags.push @valueOf()
    'click .select_trump_time_tag': ->
        Session.set('trump_skip_value',0)
        selected_trump_time_tags.push @name
    # 'click .selected_trump_time_tag': ->
    #     selected_trump_time_tags.remove @valueOf()
   
    'click .sort_date': (e,t)-> 
        Session.set('trump_sort_key', 'date')
    'click .sort_favorite': (e,t)-> 
        Session.set('trump_sort_key', 'favorites')
    'click .sort_retweet': (e,t)->
        Session.set('trump_sort_key','retweets')
        

    'click .skip_left': (e,t)-> Session.set('trump_skip_value', Session.get('trump_skip_value')-1)
    'click .skip_right': (e,t)-> Session.set('trump_skip_value', Session.get('trump_skip_value')+1)


    'keyup .search_trump': (e,t)->
        val = $('.search_trump').val()

        Session.set('trump_query', val)
        if e.which is 13 
            Session.set('trump_skip_value',0)
            selected_trump_tags.push val
            # window.speechSynthesis.speak new SpeechSynthesisUtterance val

            $('.search_trump').val('')
    'keyup .skip_number': (e,t)->
        if e.which is 13 
            val = parseInt($('.skip_number').val())
            Session.set('trump_skip_value', val)
            
Template.trump.helpers
    trump_query: -> Session.get('trump_query')

    domain_selector_class: ->
        if @name in selected_trump_domain.array() then 'blue' else 'basic'
    sort_date_class: -> if Session.equals('trump_sort_key','date') then 'active' else 'tertiary'
    sort_fav_class: -> if Session.equals('trump_sort_key','favorites') then 'active' else 'tertiary'
  
    trump_result_tags: -> results.find(model:'trump_tag')
    trump_domain_tags: -> results.find(model:'trump_domain_tag')
    trump_time_tags: -> results.find(model:'trump_time_tag')
    trump_subtrumps: -> results.find(model:'trump_subtrump')

    skip_value: -> Session.get('trump_skip_value')
    
    retweet_class: ->
        if Session.equals('trump_view_key','retweets')
            'black'
        else 
            'basic'
    fav_class: ->
        if Session.equals('trump_view_key','favorites')
            'black'
        else 
            'basic'

    date_class: ->
        if Session.equals('trump_view_key','date')
            'black'
        else 
            'basic'

    selected_trump_tags: -> selected_trump_tags.array()
    selected_trump_time_tags: -> selected_trump_time_tags.array()
    
    # trump_doc: ->
    #     Docs.findOne
    #         model:'subtrump'
    #         "data.display_name":Router.current().params.subtrump
    trump_docs: ->
        Docs.find({
            model:'trump'
            # subtrump:Router.current().params.subtrump
        },
            sort:"#{Session.get('trump_sort_key')}":parseInt(Session.get('trump_sort_direction'))
            limit:20)
    emotion_avg: -> results.findOne(model:'emotion_avg')

    sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
    sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
    emotion_avg: -> results.findOne(model:'emotion_avg')

    post_count: -> Counts.get('trump_counter')


            


Template.trump_tag_selector.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
Template.trump_tag_selector.helpers
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
        Docs.findOne 
            title:@name.toLowerCase()
            
            
Template.trump_tag_selector.events
    'click .select_tag': -> 
        # results.update
        # console.log @
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # if @model is 'trump_emotion'
        #     selected_emotions.push @name
        # else
        # if @model is 'trump_tag'
        selected_trump_tags.push @name
        $('.search_subtrump').val('')
        Session.set('trump_skip_value',0)

        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        # Session.set('trump_loading',true)
        # Meteor.call 'search_trump', @name, ->
        #     Session.set('trump_loading',false)
        # Meteor.setTimeout( ->
        #     Session.set('toggle',!Session.get('toggle'))
        # , 5000)
        
        
        

Template.trump_unselect_tag.onCreated ->
    
    @autorun => Meteor.subscribe('doc_by_title_small', @data.toLowerCase())
    
Template.trump_unselect_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
Template.trump_unselect_tag.events
    'click .unselect_trump_tag': -> 
        Session.set('skip',0)
        # console.log @
        selected_trump_tags.remove @valueOf()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
    

Template.flat_trump_tag_selector.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title_small', @data.valueOf().toLowerCase())
Template.flat_trump_tag_selector.helpers
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
Template.flat_trump_tag_selector.events
    'click .select_flat_tag': -> 
        # results.update
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        selected_trump_tags.push @valueOf()
        $('.search_trump').val('')
        # Session.set('trump_loading',true)
        # Meteor.call 'search_subtrump', Router.current().params.subtrump, @valueOf(), ->
        #     Session.set('loading',false)
        # Meteor.setTimeout( ->
        #     Session.set('toggle',!Session.get('toggle'))
        # , 3000)
