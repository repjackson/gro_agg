if Meteor.isClient
    Template.nav.events
        'click .clear': ->
            picked_tags.clear()
    Template.unpick_tag.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
        
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
            
