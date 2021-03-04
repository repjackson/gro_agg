if Meteor.isClient            
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
            picked_tags.push @name
            Meteor.call 'search_subreddits', picked_tags.array(), ->
            url = new URL(window.location);
            url.searchParams.set('tags', picked_tags.array());
            window.history.pushState({}, '', url);
            document.title = picked_tags.array()
            Meteor.setTimeout ->
                Session.set('toggle',!Session.get('toggle'))
            , 7000
            # Meteor.call 'call_wiki', @name, ->
    
    
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
        
        
        

            


if Meteor.isServer
    Meteor.publish 'sub_count', (
        query=''
        picked_subtags
        nsfw
        )->
            
        match = {model:'subreddit'}
        
        if nsfw
            match["data.over18"] = true
        else 
            match["data.over18"] = false
        
        if picked_subtags.length > 0 then match.tags = $all:picked_subtags
        if query.length > 0
            match["data.display_name"] = {$regex:"#{query}", $options:'i'}
        Counts.publish this, 'sub_counter', Docs.find(match)
        return undefined
    
    
    Meteor.publish 'subreddits', (
        query=''
        picked_subtags
        sort_key='data.subscribers'
        sort_direction=-1
        limit=20
        toggle
        nsfw
        )->
        # console.log limit
        match = {model:'subreddit'}
        
        if nsfw
            match["data.over18"] = true
        else 
            match["data.over18"] = false
        if picked_subtags.length > 0 then match.tags = $all:picked_subtags
        if query.length > 0
            match["data.display_name"] = {$regex:"#{query}", $options:'i'}
        # console.log 'match', match
        Docs.find match,
            limit:42
            sort: "#{sort_key}":sort_direction
            fields:
                model:1
                tags:1
                "data.display_name":1
                "data.title":1
                "data.primary_color":1
                "data.over18":1
                "data.header_title":1
                # "data.created":1
                "data.header_img":1
                "data.public_description":1
                "data.advertiser_category":1
                "data.accounts_active":1
                "data.subscribers":1
                "data.banner_img":1
                "data.icon_img":1
            
            
        
    Meteor.publish 'subreddit_tags', (
        picked_subtags
        toggle
        nsfw=false
        )->
        # @unblock()
        self = @
        match = {
            model:'subreddit'
        }
        if nsfw
            match["data.over18"] = true
        else 
            match["data.over18"] = false
    
    
        if picked_subtags.length > 0 then match.tags = $all:picked_subtags
        if picked_subtags.length > 0
            limit=10
        else 
            limit=50
        doc_count = Docs.find(match).count()
        # console.log 'doc_count', doc_count
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_subtags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:limit }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        tag_cloud.forEach (tag, i) ->
            # console.log tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'subreddit_tag'
        self.ready()

    
    Meteor.publish 'subs_tags', (
        picked_sub_tags
        picked_subreddit_domain
        picked_subreddit_authors
        # view_bounties
        # view_unanswered
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'subreddit'
            # subreddit:subreddit
        }
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if picked_sub_tags.length > 0 then match.tags = $all:picked_sub_tags
        if picked_subreddit_authors.length > 0 then match.author = $all:picked_subreddit_authors
        # if picked_emotion.length > 0 then match.max_emotion_name = picked_emotion
        doc_count = Docs.find(match).count()
        sus_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_sub_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:42 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        sus_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'subs_tag'
        
        
        subreddit_author_cloud = Docs.aggregate [
            { $match: match }
            { $project: "author": 1 }
            # { $unwind: "$author" }
            { $group: _id: "$author", count: $sum: 1 }
            # { $match: _id: $nin: picked_authors }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        subreddit_author_cloud.forEach (author, i) ->
            self.added 'results', Random.id(),
                name: author.name
                count: author.count
                model:'subreddit_author_tag'
      
        self.ready()
    
    
    Meteor.methods    
        # search_subreddits: (search)->
        #     @unblock()
        #     HTTP.get "http://reddit.com/subreddits/search.json?q=#{search}&raw_json=1&nsfw=1", (err,res)->
        #         if res.data.data.dist > 1
        #             _.each(res.data.data.children[0..200], (item)=>
        #                 found = 
        #                     Docs.findOne    
        #                         model:'subreddit'
        #                         "data.display_name":item.data.display_name
        #                 # if found
        #                 unless found
        #                     item.model = 'subreddit'
        #                     Docs.insert item
        #             )
        search_subreddits: (search)->
            # console.log 'searching subs', search
            @unblock()
            HTTP.get "http://reddit.com/subreddits/search.json?q=#{search}&raw_json=1&nsfw=1&include_over_18=on&limit=100", (err,res)->
                if res.data.data.dist > 1
                    _.each(res.data.data.children[0..100], (item)=>
                        # console.log item.data.display_name
                        added_tags = [search]
                        added_tags = _.flatten(added_tags)
                        # console.log 'added tags', added_tags
                        found = 
                            Docs.findOne    
                                model:'subreddit'
                                "data.display_name":item.data.display_name
                        if found
                            # console.log 'found', search, item.data.display_name
                            Docs.update found._id, 
                                $addToSet: tags: $each: added_tags
                        unless found
                            # console.log 'not found', item.data.display_name
                            item.model = 'subreddit'
                            item.tags = added_tags
                            Docs.insert item
                            
                    )
            
    
            
