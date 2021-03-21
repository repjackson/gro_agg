@picked_tags = new ReactiveArray []
Router.route '/', (->
    @layout 'layout'
    @render 'wiki'
    ), name:'wiki'


Template.registerHelper 'picked_tags', () -> picked_tags.array()
Template.registerHelper 'result_tags', () -> results.find(model:'wtag')


Template.wiki.onCreated ->
    @autorun -> Meteor.subscribe('alpha_combo',picked_tags.array())

    # Meteor.call 'call_watson', @data._id, ->
    # @autorun => Meteor.subscribe 'try', ->
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'wposts', 
        picked_tags.array()
        Session.get('toggle')
        picked_Locations.array()
        picked_Persons.array()
        picked_Companys.array()
        picked_Organizations.array()
  
    @autorun => Meteor.subscribe 'wiki_post_count', 
        picked_tags.array()
        # picked_wiki_domain.array()
        # picked_rtime_wtags.array()
        # picked_subwikis.array()
    params = new URLSearchParams(window.location.search);
    
    tags = params.get("tags");
    if tags
        split = tags.split(',')
        if tags.length > 0
            for tag in split 
                unless tag in picked_tags.array()
                    picked_tags.push tag
            Session.set('loading',true)
            Meteor.call 'search_wiki', picked_tags.array(), ->
                Session.set('loading',false)
            Meteor.setTimeout ->
                Session.set('toggle', !Session.get('toggle'))
            , 10000    
            
    # console.log(name)
    
    # @autorun => Meteor.subscribe 'wiki_doc', 
    #     picked_tags.array()
    @autorun => Meteor.subscribe 'post_count', 
        picked_tags.array()


    @autorun => Meteor.subscribe 'wtags',
        picked_tags.array()
        Session.get('toggle')
        picked_Locations.array()
        picked_Persons.array()
        picked_Companys.array()
        picked_Organizations.array()
        
        
  
  
Template.wiki.events
    'keyup .search_input': (e,t)->
        val = $('.search_input').val()
        Session.set('wiki_query', val)
        
        if e.which is 13 
            is_url = new RegExp(/^(ftp|http|https):\/\/[^ "]+$/)
            val = val.toLowerCase()
            picked_tags.push val
            # window.speechSynthesis.speak new SpeechSynthesisUtterance val
            Meteor.call 'call_alpha', picked_tags.array().toString(), ->

            $('.search_input').val('')
            Session.set('loading',true)
            # Meteor.call 'search_wiki', picked_tags.array(), ->
            Meteor.call 'search_wiki', val, ->
                Session.set('loading',false)
            #     Session.set('wiki_query', null)
  
  
    'click .search': (e,t)->
        Session.set('toggle', !Session.get('toggle'))

    # 'keyup .search': (e,t)->
    #      if e.which is 13
    #         val = t.$('.search').val().trim().toLowerCase()
    #         Session.set('loading',true)
    #         picked_tags.push val   
    #         Meteor.call 'search', picked_tags.array(), ->
    #             Session.set('loading',false)
    #         Meteor.setTimeout ->
    #             Session.set('toggle', !Session.get('toggle'))
    #         , 10000    
    #         url = new URL(window.location);
    #         url.searchParams.set('tags', picked_tags.array());
    #         window.history.pushState({}, '', url);
    #         document.title = picked_tags.array()
    #         Meteor.call 'call_alpha', picked_tags.array().toString(), ->
            
    #         t.$('.search').val('')
    #         t.$('.search').focus()
    #         # Session.set('sub_doc_query', val)



Template.wiki.helpers
    # wikis: ->
    #     if picked_tags.array().length > 0
    #         Docs.find({
    #             model:'wikipedia'
    #             # subwiki:Router.current().params.subwiki
    #         },
    #             sort:title:-1
    #             limit:21)
    wposts: ->
        if picked_tags.array().length > 0
            Docs.find({
                model:'wikipedia'
                # subwiki:Router.current().params.subwiki
            },
                sort:"ups":-1
                limit:25)
                
    Locations: -> results.find({model:'Location'})               
    Persons: -> results.find({model:'Person'})               
    Companys: -> results.find({model:'Company'})               
    Organizations: -> results.find({model:'Organization'})               
                
    post_count: -> Counts.get 'post_count'
    
    alpha_doc: -> 
        Docs.findOne 
            model:'alpha'
    

  
    
# Template.wcard.helpers
#     sub: ->
#         @data.subwiki
    
    


    
        
Template.wiki_search_shortcut.events
    'click .click_shortcut': ->
        picked_tags.push @tag.toLowerCase()
        url = new URL(window.location);
        url.searchParams.set('tags', picked_tags.array());
        window.history.pushState({}, '', url);
        document.title = picked_tags.array()
        Session.set('loading',true)
        # Meteor.call 'search_wiki', picked_tags.array(), ->
        Meteor.call 'search_wiki', @tag.toLowerCase(), ->
            Session.set('loading',false)
        Meteor.setTimeout ->
            Session.set('toggle', !Session.get('toggle'))
        , 10000    


Template.wcard.onCreated ->
    unless @watson
        Meteor.call 'call_watson', @data._id,'url','url', ->
        



Template.wcard.events
    'click .goto_post': ->
        # l @
        Router.go "/wpost/#{@_id}"
        # Meteor.call 'call_watson',@_id,'url','url',(err,res)=>
        
    'click .flat_wtag_pick': -> 
        picked_tags.push @valueOf()
        # Meteor.call 'search_wiki', picked_tags.array(), ->
        Meteor.call 'search_wiki',@valueOf(), ->
        url = new URL(window.location);
        url.searchParams.set('tags', picked_tags.array());
        window.history.pushState({}, '', url);
        document.title = picked_tags.array()
        # Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        Meteor.setTimeout ->
            Session.set('toggle',!Session.get('toggle'))
        , 10000





Template.tag_picker.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
Template.tag_picker.helpers
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
      
Template.tag_picker.events
    'click .pick_wtag': -> 
        # results.update
        # console.log @
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # if @model is 'reddit_emotion'
        #     picked_emotions.push @name
        # else
        # if @model is 'reddit_tag'
        picked_tags.push @name
        $('.search').val('')
        url = new URL(window.location)
        url.searchParams.set('tags', picked_tags.array())
        window.history.pushState({}, '', url)
        document.title = picked_tags.array()

        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        # Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        Session.set('loading',true)
        Meteor.call 'search_wiki', @name, ->        
        # Meteor.call 'search_wiki', picked_tags.array(), ->        
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 10000)
      
            
           
Template.unpick_tag.onCreated ->
    console.log @data
    @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
            

Template.unpick_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                model:'wikipedia'
                title:@valueOf().toLowerCase()
                
        # console.log found
        found
Template.unpick_tag.events
    'click .unpick':-> 
        picked_tags.remove @valueOf()
        url = new URL(window.location);
        url.searchParams.set('tags', picked_tags.array());
        window.history.pushState({}, '', url);
        document.title = picked_tags.array()
        Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        Meteor.call 'search_wiki', picked_tags.array(), ->
        Meteor.setTimeout ->
            Session.set('toggle',!Session.get('toggle'))
        , 10000
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()

            
            
            
Template.flat_tag_picker.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
Template.flat_tag_picker.helpers
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
Template.flat_tag_picker.events
    'click .flat_tag_picker': -> 
        # results.update
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        picked_tags.push @valueOf()
        Router.go "/"
        $('.search').val('')
        url = new URL(window.location)
        url.searchParams.set('tags', picked_tags.array())
        window.history.pushState({}, '', url)
        document.title = picked_tags.array()

        Session.set('loading',true)
        Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        # Meteor.call 'search_wiki', picked_tags.array(), ->
        Meteor.call 'search_wiki', @valueOf(), ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 10000)
        
        
