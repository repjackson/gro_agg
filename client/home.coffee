Template.home.onCreated ->
    @autorun -> Meteor.subscribe('alpha_combo',picked_tags.array())
    Session.setDefault('simple',true)
    Session.setDefault('toggle',false)
    Session.setDefault('nsfw_mode',false)
    @autorun => Meteor.subscribe 'tags',
        picked_tags.array()
        Session.get('toggle')
        Session.get('nsfw_mode')
    @autorun => Meteor.subscribe 'count', 
        picked_tags.array()
        Session.get('toggle')
        Session.get('nsfw_mode')
    @autorun => Meteor.subscribe 'posts', 
        picked_tags.array()
        Session.get('toggle')
        Session.get('nsfw_mode')

Template.home.helpers
    posts: ->
        Docs.find({
            model: 'rpost'
        },
            sort: ups:-1
            limit:20
        )
    alphas: ->
        Docs.find 
            model:'alpha'
            # query: $in: picked_tags.array()
            # query: picked_tags.array().toString()

    counter: -> Counts.get 'counter'

    picked_tags: -> picked_tags.array()
    many_tags: -> picked_tags.array().length>1
  
    result_tags: -> results.find(model:'tag')
    nsfw_mode: -> Session.get('nsfw_mode')
    simple: -> Session.get('simple')
        
Template.tag_select.events
    'click .select_tag': ->
        picked_tags.push @tag
    
    
    
Template.home.events
    'click .simple_off': (e,t)-> Session.set('simple',false)
        
    'click .simple_on': (e,t)-> Session.set('simple',true)
        
    'click .search_tag': (e,t)->
        Session.set('toggle',!Session.get('toggle'))
        $('.seg .pick_tag').transition({
            animation : 'pulse',
            duration  : 500,
            interval  : 300
        })
        $('.black').transition('pulse')
        # $('.pick_tag').transition('pulse')
        # $('.card_small').transition('shake')
            
    'keyup .search_tag': (e,t)->
        $('.search_tag').transition('glow', 100)
        if e.which is 13
            val = t.$('.search_tag').val().trim().toLowerCase()
            if val.length > 0
                if val is 'nsfw'
                    Session.set('nsfw_mode', true)
                    # window.speechSynthesis.speak new SpeechSynthesisUtterance '
                    t.$('.search_tag').val('')
                else
                    if picked_tags.array().length is 0
                        $('.big_search').transition('zoom', 500)
                    picked_tags.push val   
                    # Session.set('sub_doc_query', val)
                    Session.set('loading',true)
                    Meteor.call 'call_alpha', picked_tags.array().toString(), ->

                    # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array()
                    $('.search_tag').transition('pulse')
                    $('.black').transition('pulse')
                    $('.seg .pick_tag').transition({
                        animation : 'pulse',
                        duration  : 500,
                        interval  : 300
                    })
                    $('.seg .black').transition({
                        animation : 'pulse',
                        duration  : 500,
                        interval  : 300
                    })
                    # $('.pick_tag').transition('pulse')
                    # $('.card_small').transition('shake')
                    $('.pushed .card_small').transition({
                        animation : 'pulse',
                        duration  : 500,
                        interval  : 300
                    })
    
                    t.$('.search_tag').val('')
                    Meteor.call 'search_reddit', picked_tags.array(), ->
                        Session.set('loading',false)
                    Meteor.setTimeout ->
                        Session.set('toggle',!Session.get('toggle'))
                    , 5000
                    Meteor.setTimeout ->
                        Session.set('toggle',!Session.get('toggle'))
                    , 2000
            

    'click .title': (e,t)-> 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
 
 
 
 
Template.post_card_small.events
    'click .view_post': (e,t)-> 
    'click .dl': (e,t)-> 
        Meteor.call 'get_reddit_post', @_id, ->
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
    'keyup .add_tag': (e,t)->
        $('.add_tag').transition('glow', 100)
        if e.which is 13
            # $(e.currentTarget).closest('.button').transition('pulse',200)
            val = $(e.currentTarget).closest('.add_tag').val().trim().toLowerCase()
            # console.log val
            if val.length > 0
                Session.set('loading',true)
                Docs.update @_id, 
                    $addToSet: tags: val
                # window.speechSynthesis.speak new SpeechSynthesisUtterance val
                picked_tags.push val   
                Meteor.call 'search_reddit', picked_tags.array(), ->
                    Session.set('loading',false)
                Meteor.setTimeout ->
                    Session.set('toggle',!Session.get('toggle'))
                , 5000
                # t.$('.add_tag').val('')
                $(e.currentTarget).closest('.add_tag').val('')

Template.post_card_small.helpers
    five_tags: -> @tags[..5]
    simple: -> Session.get('simple')


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
        picked_tags.push @name.toLowerCase()
        $('.search_tag').val('')
        Session.set('skip_value',0)
        $('.search_tag').transition('pulse')
        $('.seg .pick_tag').transition({
            animation : 'pulse',
            duration  : 500,
            interval  : 300
        })
        $('.seg .black').transition({
            animation : 'pulse',
            duration  : 500,
            interval  : 300
        })
        # $('.pick_tag').transition('pulse')
        # $('.card_small').transition('shake')
        # $('.pushed .card_small').transition({
        #     animation : 'pulse',
        #     duration  : 500,
        #     interval  : 300
        # })
        Meteor.call 'call_alpha', picked_tags.array().toString(), ->

        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array()
        Meteor.setTimeout ->
            Session.set('toggle',!Session.get('toggle'))
        , 5000
        
        

Template.unpick_tag.events
    'click .unpick_tag': -> 
        Session.set('skip',0)
        # console.log @
        picked_tags.remove @valueOf()
        $('.search_tag').transition('pulse')
        $('.seg .black').transition({
            animation : 'pulse',
            duration  : 500,
            interval  : 300
        })
        # $('.pick_tag').transition('pulse')
        # $('.card_small').transition('shake')
        $('.seg .pick_tag').transition({
            animation : 'pulse',
            duration  : 500,
            interval  : 300
        })
        Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        
        # $('.pushed .card_small').transition({
        #     animation : 'pulse',
        #     duration  : 500,
        #     interval  : 300
        # })
        if picked_tags.array().length is 0
            $('.search_tag').focus()
        else
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
            Session.set('loading',true)
            Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('loading',false)
            Meteor.setTimeout ->
                Session.set('toggle',!Session.get('toggle'))
            , 5000
