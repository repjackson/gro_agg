if Meteor.isClient   
    Router.route '/subs', (->
        @layout 'layout'
        @render 'subs'
        ), name:'subs'
    
    @picked_subtags = new ReactiveArray []
    
    Template.subs.onCreated ->
        params = new URLSearchParams(window.location.search);
        
        nsfw = params.get("nsfw");
        if nsfw
            console.log nsfw
            # if nsfw is 1
            Session.set('nsfw',true)
    
        
        tags = params.get("tags");
        if tags
            split = tags.split(',')
            if tags.length > 0
                for tag in split 
                    unless tag in picked_subtags.array()
                        picked_subtags.push tag
                Session.set('loading',true)
                Meteor.call 'search_subreddits', picked_subtags.array(), ->
                    Session.set('loading',false)
                # Meteor.setTimeout ->
                #     Session.set('toggle', !Session.get('toggle'))
                # , 5000    
                Meteor.setTimeout ->
                    Session.set('toggle', !Session.get('toggle'))
                , 10000    
        
        Session.setDefault('subreddit_query',null)
        Session.setDefault('sort_key','data.created')
        Session.setDefault('subs_limit',20)
        Session.setDefault('toggle',false)
        Session.setDefault('nsfw',false)
        
        @autorun -> Meteor.subscribe('subreddits',
            Session.get('subreddit_query')
            picked_subtags.array()
            Session.get('sort_subs')
            Session.get('subs_sort_direction')
            Session.get('subs_limit')
            Session.get('toggle')
            Session.get('nsfw')
        )
        @autorun -> Meteor.subscribe('sub_count',
            Session.get('subreddit_query')
            picked_subtags.array()
            Session.get('nsfw')
        )
        @autorun => Meteor.subscribe 'subreddit_tags',
            picked_subtags.array()
            Session.get('toggle')
            Session.get('nsfw')
    
    Template.subreddit_doc.events
        # 'click .goto_sub': (e,t)->
        #     Meteor.call 'get_sub_latest', @data.display_name, ->
        #     Meteor.call 'get_sub_info', @data.display_name, ->
        #     Meteor.call 'calc_sub_tags', @data.display_name, ->
        #     Session.set('view_section', 'main')
    Template.subs.events
        'click .search_subreddits': (e,t)->
            Session.set('toggle',!Session.get('toggle'))
        'keyup .search_subreddits': (e,t)->
            val = $('.search_subreddits').val().toLowerCase().trim()
            Session.set('subreddit_query', val)
            if e.which is 13 
                $('.search_subreddits').val('')
                unless val in picked_subtags.array()
                    picked_subtags.push val 
                    Meteor.call 'search_subreddits', picked_subtags.array(), ->
                Session.set('subreddit_query', null)
                url = new URL(window.location);
                url.searchParams.set('tags', picked_subtags.array());
                window.history.pushState({}, '', url);
                document.title = picked_subtags.array()
                
                Meteor.setTimeout ->
                    Session.set('toggle',!Session.get('toggle'))
                , 7000
                # Session.set('subreddit_query', null)
        # 'click .search_subs': ->
        #     Meteor.call 'search_subreddits', 'news', ->
   
    Template.subtag_picker.events
        'click .pick_tag':-> 
            picked_subtags.push @name
            Meteor.call 'search_subreddits', picked_subtags.array(), ->
            url = new URL(window.location);
            url.searchParams.set('tags', picked_subtags.array());
            window.history.pushState({}, '', url);
            document.title = picked_subtags.array()
            Meteor.setTimeout ->
                Session.set('toggle',!Session.get('toggle'))
            , 7000
            Meteor.call 'call_wiki', @name, ->
    
    
    Template.subtag_picker.onCreated ->
        if @data.name
            @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
    Template.subtag_picker.helpers
        selector_class: ()->
            term = 
                Docs.findOne 
                    title:@name.toLowerCase()
            if term
                if term.max_emotion_name
                    switch term.max_emotion_name
                        when 'joy' then ' basic green'
                        when 'anger' then ' basic red'
                        when 'sadness' then ' basic blue'
                        when 'disgust' then ' basic orange'
                        when 'fear' then ' basic grey'
                        else ' basic'
                else ' basic'
            else ' basic'
        term: ->
            Docs.findOne 
                title:@name.toLowerCase()
   
                 
    Template.subs.helpers
        subreddit_docs: ->
            Docs.find(
                model:'subreddit'
            , {limit:100,sort:"#{Session.get('sort_subs')}":-1})
        subreddit_tags: -> results.find(model:'subreddit_tag')
    
        picked_subtags: -> picked_subtags.array()
    
        sub_count: -> Counts.get('sub_counter')
        multiple_results: -> Counts.get('sub_counter')>1
        
    Template.subreddit_doc.events 
        'click .pick_tag': ->
            picked_subtags.push @valueOf()
            Meteor.call 'search_subreddits', picked_subtags.array(), ->
            url = new URL(window.location);
            url.searchParams.set('tags', picked_subtags.array());
            window.history.pushState({}, '', url);
            document.title = picked_subtags.array()
            Meteor.setTimeout ->
                Session.set('toggle',!Session.get('toggle'))
            , 7000
            Meteor.call 'call_wiki', @valueOf(), ->

    Template.subreddit_doc.helpers    
        seven_tags: ->
            @tags[..7]
        
    Template.unpick_subtag.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
        
    Template.unpick_subtag.helpers
        term: ->
            found = 
                Docs.findOne 
                    # model:'wikipedia'
                    title:@valueOf().toLowerCase()
            found
            
    Template.unpick_subtag.events
        'click .unpick':-> 
            picked_subtags.remove @valueOf()
            Meteor.call 'search_subreddits', picked_subtags.array(), ->
            url = new URL(window.location);
            url.searchParams.set('tags', picked_subtags.array());
            window.history.pushState({}, '', url);
            document.title = picked_subtags.array()
            Meteor.setTimeout ->
                Session.set('toggle',!Session.get('toggle'))
            , 7000
            Meteor.call 'call_wiki', @valueOf(), ->

        
        

            


