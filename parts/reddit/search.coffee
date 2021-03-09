if Meteor.isClient
    Template.nav.events
        # 'click .clear': ->
        #     picked_tags.clear()
    Template.unpick_tag.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
      
      
    Template.home.events
        'click .make_nsfw': (e,t)-> Session.set('nsfw', true)
        'click .make_safe': (e,t)-> Session.set('nsfw', false)
            
        'keyup .search_reddit': (e,t)->
            val = $('.search_reddit').val()
            Session.set('reddit_query', val)
            if e.which is 13 
                picked_tags.push val
                # window.speechSynthesis.speak new SpeechSynthesisUtterance val
                Meteor.call 'call_alpha', picked_tags.array().toString(), ->
    
                $('.search_reddit').val('')
                Session.set('reddit_loading',true)
                Meteor.call 'search_reddit', val, ->
                    Session.set('reddit_loading',false)
                    Session.set('reddit_query', null)
        'click .search_tag': (e,t)->
            Session.set('toggle', !Session.get('toggle'))
    
        'keyup .search_tag': (e,t)->
             if e.which is 13
                val = t.$('.search_tag').val().trim().toLowerCase()
                Session.set('loading',true)
                picked_tags.push val   
                Meteor.call 'search_reddit', picked_tags.array(), ->
                    Session.set('loading',false)
                Meteor.setTimeout ->
                    Session.set('toggle', !Session.get('toggle'))
                , 10000    
                url = new URL(window.location);
                url.searchParams.set('tags', picked_tags.array());
                window.history.pushState({}, '', url);
                document.title = picked_tags.array()
                Meteor.call 'call_alpha', picked_tags.array().toString(), ->
                
                t.$('.search_tag').val('')
                t.$('.search_tag').focus()
                # Session.set('sub_doc_query', val)


    
    Template.home.helpers
        picked_tags: -> picked_tags.array()
        
        wikis: ->
            if picked_tags.array().length > 0
                Docs.find({
                    model:'wikipedia'
                    # subreddit:Router.current().params.subreddit
                },
                    sort:title:-1
                    limit:21)
        rposts: ->
            if picked_tags.array().length > 0
                Docs.find({
                    model:'rpost'
                    # subreddit:Router.current().params.subreddit
                },
                    sort:"data.ups":-1
                    limit:21)
        post_count: -> Counts.get 'post_count'
        
        # nightmode_class: -> if Session.get('nightmode') then 'invert'
        
        
        result_tags: -> results.find(model:'tag')
    
      
        
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
            Meteor.call 'search_reddit', picked_tags.array(), ->
            url = new URL(window.location);
            url.searchParams.set('tags', picked_tags.array());
            window.history.pushState({}, '', url);
            document.title = picked_tags.array()
            Meteor.call 'call_alpha', picked_tags.array().toString(), ->
            Meteor.setTimeout ->
                Session.set('toggle',!Session.get('toggle'))
            , 7000
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
    

        
    Template.home.onCreated ->
        Session.setDefault('nsfw', false)
        @autorun -> Meteor.subscribe('alpha_combo',picked_tags.array())
    
        # Meteor.call 'call_watson', @data._id, ->
        
        # Session.setDefault('location_query', null)
        @autorun => Meteor.subscribe 'rposts', 
            picked_tags.array()
            Session.get('nsfw')
            Session.get('toggle')
      
        # @autorun => Meteor.subscribe 'reddit_post_count', 
        #     picked_tags.array()
        #     picked_reddit_domain.array()
        #     picked_rtime_tags.array()
        #     picked_subreddits.array()
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
                , 7000    
                
        # console.log(name)
        
        @autorun => Meteor.subscribe 'wiki_doc', 
            picked_tags.array()
        @autorun => Meteor.subscribe 'post_count', 
            picked_tags.array()
    
    
        @autorun => Meteor.subscribe 'tags',
            picked_tags.array()
            Session.get('nsfw')
            Session.get('toggle')
            
    Template.search_shortcut.events
        'click .search_tag': ->
            picked_tags.push @tag.toLowerCase()
            url = new URL(window.location);
            url.searchParams.set('tags', picked_tags.array());
            window.history.pushState({}, '', url);
            document.title = picked_tags.array()
            Session.set('loading',true)
            Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('loading',false)
            Meteor.setTimeout ->
                Session.set('toggle', !Session.get('toggle'))
            , 7000    
