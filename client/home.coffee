Template.nav.events
    # 'click .clear': ->
    #     picked_tags.clear()
Template.unpick_tag.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
  
  
Template.home.onCreated ->
    @autorun -> Meteor.subscribe('alpha_combo',picked_tags.array())

    # Meteor.call 'call_watson', @data._id, ->
    # @autorun => Meteor.subscribe 'try', ->
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'rposts', 
        picked_tags.array()
        # picked_domains.array()
        # picked_authors.array()
        # picked_time_tags.array()
        # picked_Locations.array()
        # picked_persons.array()
        # Session.get('sort_key')
        # Session.get('sort_direction')
        # Session.get('limit')
    @autorun => Meteor.subscribe 'reddit_post_count', 
        picked_tags.array()
        # picked_reddit_domain.array()
        # picked_rtime_tags.array()
        # picked_subreddits.array()
    params = new URLSearchParams(window.location.search);
    
    tags = params.get("tags");
    if tags
        split = tags.split(',')
        if tags.length > 0
            for tag in split 
                unless tag in picked_tags.array()
                    picked_tags.push tag
            Session.set('loading',true)
            Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('loading',false)
            Meteor.setTimeout ->
                Session.set('toggle', !Session.get('toggle'))
            , 10000    
            
    # console.log(name)
    
    # @autorun => Meteor.subscribe 'wiki_doc', 
    #     picked_tags.array()
    @autorun => Meteor.subscribe 'post_count', 
        picked_tags.array()


    @autorun => Meteor.subscribe 'tags',
        picked_tags.array()
        Session.get('toggle')
        # picked_domains.array()
        # picked_authors.array()
        # picked_time_tags.array()
        # picked_Locations.array()
        # picked_persons.array()
        
        
  
  
Template.home.events
    'keyup .search_input': (e,t)->
        val = $('.search_input').val().toLowerCase()
        Session.set('reddit_query', val)
        
        if e.which is 13 
            is_url = new RegExp(/((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-_]*)?\??(?:[\-\+=&;%@\.\w_]*)#?(?:[\.\!\/\\\w]*))?)/);
            if is_url.test(val)
                # alert 'url'
                Meteor.call 'import_url', val, (err,res)->
                    $('.search_input').val('')
                    Router.go("/post/#{res}")
            else
                picked_tags.push val
                # window.speechSynthesis.speak new SpeechSynthesisUtterance val
                Meteor.call 'call_alpha', picked_tags.array().toString(), ->
    
                $('.search_input').val('')
                Session.set('loading',true)
                Meteor.call 'search_reddit', picked_tags.array(), ->
                    Session.set('loading',false)
                #     Session.set('reddit_query', null)
    'click .search': (e,t)->
        Session.set('toggle', !Session.get('toggle'))

    # 'keyup .search': (e,t)->
    #      if e.which is 13
    #         val = t.$('.search').val().trim().toLowerCase()
    #         Session.set('loading',true)
    #         picked_tags.push val   
    #         # Meteor.call 'search', picked_tags.array(), ->
    #         #     Session.set('loading',false)
    #         # Meteor.setTimeout ->
    #         #     Session.set('toggle', !Session.get('toggle'))
    #         # , 10000    
    #         # url = new URL(window.location);
    #         # url.searchParams.set('tags', picked_tags.array());
    #         # window.history.pushState({}, '', url);
    #         # document.title = picked_tags.array()
    #         # Meteor.call 'call_alpha', picked_tags.array().toString(), ->
            
    #         t.$('.search').val('')
    #         t.$('.search').focus()
    #         # Session.set('sub_doc_query', val)



Template.home.helpers
    # wikis: ->
    #     if picked_tags.array().length > 0
    #         Docs.find({
    #             model:'wikipedia'
    #             # subreddit:Router.current().params.subreddit
    #         },
    #             sort:title:-1
    #             limit:21)
    rposts: ->
        if picked_tags.array().length > 0
            Docs.find({
                model:'rpost'
                # subreddit:Router.current().params.subreddit
            },
                sort:"ups":-1
                limit:21)
    post_count: -> Counts.get 'post_count'
    
    # nightmode_class: -> if Session.get('nightmode') then 'invert'
    
    

  
    
Template.card.helpers
    sub: ->
        @data.subreddit
    
    
Template.unpick_tag.helpers
    term: ->
        found = 
            Docs.findOne 
                model:'wikipedia'
                title:@valueOf().toLowerCase()
        found
Template.unpick_tag.events
    'click .unpick':-> 
        picked_tags.remove @valueOf()
        url = new URL(window.location);
        url.searchParams.set('tags', picked_tags.array());
        window.history.pushState({}, '', url);
        document.title = picked_tags.array()
        Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        Meteor.call 'search_reddit', picked_tags.array(), ->
        Meteor.setTimeout ->
            Session.set('toggle',!Session.get('toggle'))
        , 10000
        # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()


    
        
Template.search_shortcut.events
    'click .click_shortcut': ->
        picked_tags.push @tag.toLowerCase()
        url = new URL(window.location);
        url.searchParams.set('tags', picked_tags.array());
        window.history.pushState({}, '', url);
        document.title = picked_tags.array()
        # Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
        Meteor.setTimeout ->
            Session.set('toggle', !Session.get('toggle'))
        , 10000    


Template.card.onCreated ->
    unless @data.domain in ['i.redd.it','v.redd.it','i.imgur.com','redd.it','reddit.com']
        console.log @data
        unless @watson
            Meteor.call 'call_watson', @data._id,'url','url', ->
        



Template.card.events
    'click .goto_post': ->
        # l @
        Router.go "/post/#{@_id}"
        Meteor.call 'call_watson',@_id,'url','url',(err,res)=>
        
    'click .flat_tag_pick': -> 
        picked_tags.push @valueOf()
        Meteor.call 'search_reddit', picked_tags.array(), ->
        url = new URL(window.location);
        url.searchParams.set('tags', picked_tags.array());
        window.history.pushState({}, '', url);
        document.title = picked_tags.array()
        # Meteor.call 'call_alpha', picked_tags.array().toString(), ->
        Meteor.setTimeout ->
            Session.set('toggle',!Session.get('toggle'))
        , 10000
