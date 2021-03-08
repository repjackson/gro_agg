if Meteor.isClient
    @picked_sub_tags = new ReactiveArray []
    @picked_subreddit_domain = new ReactiveArray []
    @picked_subreddit_time_tags = new ReactiveArray []
    @picked_subreddit_authors = new ReactiveArray []
    
    
    Router.route '/r/:subreddit', (->
        @layout 'layout'
        @render 'subreddit'
        ), name:'subreddit'
    
    Router.route '/r/:subreddit/post/:doc_id', (->
        @layout 'layout'
        @render 'rpage'
        ), name:'rpage'
    
    
    Template.subreddit_best.onCreated ->
        @autorun => Meteor.subscribe 'subreddit_best', Router.current().params.subreddit
    Template.subreddit_newest.onCreated ->
        @autorun => Meteor.subscribe 'subreddit_newest', Router.current().params.subreddit
    
    Template.subreddit_best.helpers
        sub_best_docs: ->
            Docs.find {
                model:'rpost'
                subreddit:Router.current().params.subreddit
            }, 
                sort:"data.ups":-1
                limit:7
       
    Template.subreddit_newest.helpers
        sub_newest_docs: ->
            Docs.find {
                model:'rpost'
                subreddit:Router.current().params.subreddit
            }, 
                sort:"data.created":-1
                limit:7
                
                
    Template.subreddit.onCreated ->
        Session.setDefault('subreddit_view_layout', 'grid')
        Session.setDefault('sort_key', 'data.created')
        Session.setDefault('sort_direction', -1)
        Session.setDefault('location_query', null)
        # @autorun => Meteor.subscribe 'subrzeddit_user_count', Router.current().params.subreddit
        @autorun => Meteor.subscribe 'subreddit_by_param', Router.current().params.subreddit
        @autorun => Meteor.subscribe 'sub_docs_by_name', 
            Router.current().params.subreddit
            picked_sub_tags.array()
            # picked_subreddit_domain.array()
            # picked_subreddit_time_tags.array()
            # picked_subreddit_authors.array()
            # Session.get('sort_key')
            # Session.get('sort_direction')
      
        # @autorun => Meteor.subscribe 'sub_doc_count', 
        #     Router.current().params.subreddit
        #     picked_sub_tags.array()
        #     picked_subreddit_domain.array()
        #     picked_subreddit_time_tags.array()
        #     picked_subreddit_authors.array()
    
        @autorun => Meteor.subscribe 'subreddit_result_tags',
            Router.current().params.subreddit
            picked_sub_tags.array()
            picked_subreddit_domain.array()
            picked_subreddit_time_tags.array()
            picked_subreddit_authors.array()
            Session.get('toggle')
        # Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->
    
        # Meteor.call 'log_subreddit_view', Router.current().params.subreddit, ->
        @autorun => Meteor.subscribe 'agg_sentiment_subreddit',
            Router.current().params.subreddit
            picked_sub_tags.array()
            ()->Session.set('ready',true)
 
    Template.sub_post_card.events
        'click .view_post': (e,t)-> 
            Session.set('view_section','main')
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
            Router.go "/r/#{@subreddit}/post/#{@_id}"
    
    Template.subreddit_doc_item.onRendered ->
        # console.log @
        # unless @data.watson
        #     Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
    
    Template.sub_post_card.onRendered ->
        # console.log @
        # unless @data.watson
        #     Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
        # unless @data.time_tags
        #     Meteor.call 'tagify_time_rpost',@data._id,=>
    
    
    Template.subreddit.events
        'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
        'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
        'click .sort_up': (e,t)-> Session.set('sort_direction',1)
        'click .limit_10': (e,t)-> Session.set('limit',10)
        'click .limit_1': (e,t)-> Session.set('limit',1)
    
        'click .sort_created': -> 
            Session.set('sort_key', 'data.created')
            Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->
        'click .sort_ups': -> 
            Session.set('sort_key', 'data.ups')
            Meteor.call 'get_sub_best', Router.current().params.subreddit, ->
        'click .download': ->
            console.log 'get info'
            Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
        
        'click .pull_latest': ->
            # console.log 'latest'
            Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->
        'click .get_info': ->
            cl 'dl'
            Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
        'click .set_grid': (e,t)-> Session.set('subreddit_view_layout', 'grid')
        'click .set_list': (e,t)-> Session.set('subreddit_view_layout', 'list')
    
        'keyup .search_subreddit': (e,t)->
            val = $('.search_subreddit').val()
            Session.set('sub_doc_query', val)
            if e.which is 13 
                picked_sub_tags.push val
                # window.speechSynthesis.speak new SpeechSynthesisUtterance val
    
                $('.search_subreddit').val('')
                Session.set('loading',true)
                Meteor.call 'search_subreddit', Router.current().params.subreddit, val, ->
                    Session.set('loading',false)
                    Session.set('sub_doc_query', null)
                
    Template.subreddit.helpers
    
        domain_selector_class: ->
            if @name in picked_subreddit_domain.array() then 'blue' else 'basic'
        sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
        sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
        subreddit_result_tags: -> results.find(model:'subreddit_result_tag')
        subreddit_domain_tags: -> results.find(model:'subreddit_domain_tag')
        subreddit_time_tags: -> results.find(model:'subreddit_time_tag')
    
        picked_sub_tags: -> picked_sub_tags.array()
        
        subreddit_doc: ->
            Docs.findOne
                model:'subreddit'
                "data.display_name":Router.current().params.subreddit
                # name:Router.current().params.subreddit
        sub_docs: ->
            Docs.find({
                model:'rpost'
                subreddit:Router.current().params.subreddit
            },
                sort:"#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:20)
        emotion_avg: -> results.findOne(model:'emotion_avg')
    
        sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
        sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
        emotion_avg: -> results.findOne(model:'emotion_avg')
    
        post_count: -> Counts.get('sub_doc_counter')
    
    
                
    
    
    # Template.sub_tag_selector.onCreated ->
    #     # @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
    # Template.sub_tag_selector.helpers
    #     selector_class: ()->
    #         term = 
    #             Docs.findOne 
    #                 title:@name.toLowerCase()
    #         if term
    #             if term.max_emotion_name
    #                 switch term.max_emotion_name
    #                     when 'joy' then " basic green"
    #                     when "anger" then " basic red"
    #                     when "sadness" then " basic blue"
    #                     when "disgust" then " basic orange"
    #                     when "fear" then " basic grey"
    #                     else "basic grey"
    #     term: ->
    #         Docs.findOne 
    #             title:@name.toLowerCase()
                
                
    # Template.sub_tag_selector.events
    #     'click .select_sub_tag': -> 
    #         # results.update
    #         # console.log @
    #         # window.speechSynthesis.cancel()
    #         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    #         # if @model is 'subreddit_emotion'
    #         #     picked_emotions.push @name
    #         # else
    #         # if @model is 'subreddit_tag'
    #         picked_sub_tags.push @name
    #         $('.search_subreddit').val('')
            
    #         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    #         # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
    #         Session.set('subs_loading',true)
    #         Meteor.call 'search_subs', @name, ->
    #             Session.set('subs_loading',false)
    #         Meteor.setTimeout( ->
    #             Session.set('toggle',!Session.get('toggle'))
    #         , 5000)
            
            
            
    
    # Template.sub_unpick_tag.onCreated ->
    #     # @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
        
    # Template.sub_unpick_tag.helpers
    #     term: ->
    #         found = 
    #             Docs.findOne 
    #                 # model:'wikipedia'
    #                 title:@valueOf().toLowerCase()
    #         found
    # Template.sub_unpick_tag.events
    #     'click .unselect_sub_tag': -> 
    #         Session.set('skip',0)
    #         console.log @
    #         picked_sub_tags.remove @valueOf()
    #         # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        
    
    # Template.flat_sub_tag_selector.onCreated ->
    #     # @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
    # Template.flat_sub_tag_selector.helpers
    #     selector_class: ()->
    #         term = 
    #             Docs.findOne 
    #                 title:@valueOf().toLowerCase()
    #         if term
    #             if term.max_emotion_name
    #                 switch term.max_emotion_name
    #                     when 'joy' then " basic green"
    #                     when "anger" then " basic red"
    #                     when "sadness" then " basic blue"
    #                     when "disgust" then " basic orange"
    #                     when "fear" then " basic grey"
    #                     else "basic grey"
    #     term: ->
    #         Docs.findOne 
    #             title:@valueOf().toLowerCase()
    # Template.flat_sub_tag_selector.events
    #     'click .select_flat_tag': -> 
    #         # results.update
    #         # window.speechSynthesis.cancel()
    #         # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
    #         picked_sub_tags.push @valueOf()
    #         Router.go "/r/#{Router.current().params.subreddit}/"
    #         $('.search_subreddit').val('')
    #         Session.set('loading',true)
    #         Meteor.call 'search_subreddit', Router.current().params.subreddit, @valueOf(), ->
    #             Session.set('loading',false)
    #         Meteor.setTimeout( ->
    #             Session.set('toggle',!Session.get('toggle'))
    #         , 3000)
    # Template.flat_sub_ruser_tag_selector.events
    #     'click .select_flat_tag': -> 
    #         # results.update
    #         # window.speechSynthesis.cancel()
    #         # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
    #         picked_sub_tags.push @valueOf()
    #         parent = Template.parentData()
    #         Router.go "/r/#{parent.subreddit}/"
    #         $('.search_subreddit').val('')
    #         Session.set('loading',true)
    #         Meteor.call 'search_subreddit', parent.subreddit, @valueOf(), ->
    #             Session.set('loading',false)
    #         Meteor.setTimeout( ->
    #             Session.set('toggle',!Session.get('toggle'))
    #         , 3000)
    
if Meteor.isServer
    Meteor.publish 'subreddit_by_param', (subreddit)->
        Docs.find
            model:'subreddit'
            "data.display_name":subreddit
    
    Meteor.publish 'sub_docs_by_name', (
        subreddit
        picked_subreddit_domains
        picked_subreddit_time_tags
        picked_subreddit_authors
        sort_key
        )->
        self = @
        match = {
            model:'rpost'
            subreddit:subreddit
        }
        if sort_key
            sk = sort_key
        else
            sk = 'data.created'
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        # if picked_subreddit_domains.length > 0 then match.domain = $all:picked_subreddit_domains
        # if picked_subreddit_time_tags.length > 0 then match.time_tags = $all:picked_subreddit_time_tags
        # if picked_subreddit_authors.length > 0 then match.authors = $all:picked_subreddit_authors
        Docs.find match,
            limit:20
            sort: "#{sk}":-1



    Meteor.publish 'agg_sentiment_subreddit', (
        subreddit
        picked_tags
        )->
        # @unblock()
        self = @
        match = {
            model:'rpost'
            subreddit:subreddit
        }
            
        doc_count = Docs.find(match).count()
        if picked_tags.length > 0 then match.tags = $all:picked_tags
        emotion_avgs = Docs.aggregate [
            { $match: match }
            #     # avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
            { $group: 
                _id:null
                avg_sent_score: { $avg: "$doc_sentiment_score" }
                avg_joy_score: { $avg: "$joy_percent" }
                avg_anger_score: { $avg: "$anger_percent" }
                avg_sadness_score: { $avg: "$sadness_percent" }
                avg_disgust_score: { $avg: "$disgust_percent" }
                avg_fear_score: { $avg: "$fear_percent" }
            }
        ]
        emotion_avgs.forEach (res, i) ->
            self.added 'results', Random.id(),
                model:'emotion_avg'
                avg_sent_score: res.avg_sent_score
                avg_joy_score: res.avg_joy_score
                avg_anger_score: res.avg_anger_score
                avg_sadness_score: res.avg_sadness_score
                avg_disgust_score: res.avg_disgust_score
                avg_fear_score: res.avg_fear_score
        self.ready()
        
    
    Meteor.publish 'sub_doc_count', (
        subreddit
        picked_tags
        picked_subreddit_domains
        picked_subreddit_time_tags
        )->
            
        match = {model:'rpost'}
        match.subreddit = subreddit
        if picked_tags.length > 0 then match.tags = $all:picked_tags
        if picked_subreddit_domains.length > 0 then match.domain = $all:picked_subreddit_domains
        if picked_subreddit_time_tags.length > 0 then match.time_tags = $all:picked_subreddit_time_tags
        Counts.publish this, 'sub_doc_counter', Docs.find(match)
        return undefined
    Meteor.methods
        calc_sub_tags: (subreddit)->
            found = 
                Docs.findOne(
                    model:'subreddit'
                    "data.display_name": subreddit
                )
            sub_tags = Meteor.call 'agg_sub_tags', subreddit
            titles = _.pluck(sub_tags, 'title')
            if found
                Docs.update found._id, 
                    $set:tags:titles
            Meteor.call 'clear_blocklist_doc', found._id, ->
    
        agg_sub_tags: (subreddit)->
            match = {model:'rpost', subreddit:subreddit}
            total_doc_result_count =
                Docs.find( match,
                    {
                        fields:
                            _id:1
                    }
                ).count()
            # limit=20
            options = {
                explain:false
                allowDiskUse:true
            }
    
            pipe =  [
                { $match: match }
                { $project: tags: 1 }
                { $unwind: "$tags" }
                { $group: _id: "$tags", count: $sum: 1 }
                { $sort: count: -1, _id: 1 }
                { $limit: 20 }
                { $project: _id: 0, title: '$_id', count: 1 }
            ]
    
            if pipe
                agg = global['Docs'].rawCollection().aggregate(pipe,options)
                # else
                res = {}
                if agg
                    agg.toArray()
                    # omega = Docs.findOne model:'omega_session'
                    # Docs.update omega._id,
                    #     $set:
                    #         agg:agg.toArray()
            else
                return null
    
            
            
            
        get_sub_info: (subreddit)->
            @unblock()
            console.log 'getting', subreddit
            # if subreddit 
            #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
            # else
            # url = "https://www.reddit.com/r/#{subreddit}/about.json?&raw_json=1&include_over_18=on"
            url = "https://www.reddit.com/r/#{subreddit}/about.json?&raw_json=1"
            HTTP.get url,(err,res)=>
                if res.data.data
                    console.log res.data.data
                    existing = Docs.findOne 
                        model:'subreddit'
                        name:subreddit
                        # "data.display_name":subreddit
                    if existing
                        console.log existing
                        # if Meteor.isDevelopment
                        # if typeof(existing.tags) is 'string'
                        #     Doc.update
                        #         $unset: tags: 1
                        Docs.update existing._id,
                            $set: data:res.data.data
                    unless existing
                        console.log 'not existing'
                        sub = {}
                        sub.model = 'subreddit'
                        sub.name = subreddit
                        sub.data = res.data.data
                        new_reddit_post_id = Docs.insert sub
                        # console.log existing
        
        get_sub_latest: (subreddit)->
            @unblock()
            # if subreddit 
            #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
            # else
            url = "https://www.reddit.com/r/#{subreddit}.json?&raw_json=1&include_over_18=on&search_include_over_18=on&limit=100"
            HTTP.get url,(err,res)=>
                # if err
                # if res 
                # if res.data.data.dist > 1
                _.each(res.data.data.children[0..100], (item)=>
                    found = 
                        Docs.findOne    
                            model:'rpost'
                            reddit_id:item.data.id
                            # subreddit:item.data.id
                    if found
                        Docs.update found._id,
                            $set:subreddit:item.data.subreddit
                    unless found
                        item.model = 'rpost'
                        item.reddit_id = item.data.id
                        item.author = item.data.author
                        item.subreddit = item.data.subreddit
                        # item.rdata = item.data
                        Docs.insert item
                )
                
        get_sub_info: (subreddit)->
            @unblock()
            console.log 'getting info', subreddit
            # if subreddit 
            #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
            # else
            url = "https://www.reddit.com/r/#{subreddit}/about.json?&raw_json=1"
            HTTP.get url,(err,res)=>
                # console.log res.data.data
                if res.data.data
                    existing = Docs.findOne 
                        model:'subreddit'
                        "data.display_name":subreddit
                    if existing
                        # console.log 'existing', existing
                        # if Meteor.isDevelopment
                        # if typeof(existing.tags) is 'string'
                        #     Doc.update
                        #         $unset: tags: 1
                        Docs.update existing._id,
                            $set: data:res.data.data
                    unless existing
                        # console.log 'new sub', subreddit
                        sub = {}
                        sub.model = 'subreddit'
                        sub.name = subreddit
                        sub.data = res.data.data
                        new_reddit_post_id = Docs.insert sub
                  
        search_subreddit: (subreddit,search)->
            @unblock()
            HTTP.get "http://reddit.com/r/#{subreddit}/search.json?q=#{search}&restrict_sr=1&raw_json=1&include_over_18=on&nsfw=1", (err,res)->
                if res.data.data.dist > 1
                    for item in res.data.data.children[0..3]
                        id = item.data.id
                        # Docs.insert d
                        # found = 
                        found = Docs.findOne({
                            model:'rpost',
                            "data.subreddit":item.data.subreddit
                            # reddit_id:id
                        })
                        # continue
                    # _.each(res.data.data.children[0..100], (item)=>
                    #     id = item.data.id
                    #     # if found
                    #     #     Docs.update found._id, 
                    #     #         $addToSet: tags: search
                    #     #         $set:
                    #     #             subreddit:item.data.subreddit
                    #     # unless found
                    #     #     item.model = 'rpost'
                    #     #     item.reddit_id = item.data.id
                    #     #     item.author = item.data.author
                    #     #     item.subreddit = item.data.subreddit
                    #     #     item.tags = [search]
                    #     #     # item.rdata = item.data
                    #     #     Docs.insert item
                    # )
    Meteor.publish 'subreddit_result_tags', (
        subreddit
        picked_subreddit_domain
        picked_subreddit_time_tags
        # view_bounties
        # view_unanswered
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'rpost'
            subreddit:subreddit
        }
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if picked_subreddit_domain.length > 0 then match.domain = $all:picked_subreddit_domain
        if picked_subreddit_time_tags.length > 0 then match.time_tags = $all:picked_subreddit_time_tags
        # if picked_emotion.length > 0 then match.max_emotion_name = picked_emotion
        doc_count = Docs.find(match).count()
        subreddit_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:11 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        subreddit_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'subreddit_result_tag'
        
        
        subreddit_domain_cloud = Docs.aggregate [
            { $match: match }
            { $project: "data.domain": 1 }
            # { $unwind: "$domain" }
            { $group: _id: "$data.domain", count: $sum: 1 }
            # { $match: _id: $nin: picked_domains }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        subreddit_domain_cloud.forEach (domain, i) ->
            self.added 'results', Random.id(),
                name: domain.name
                count: domain.count
                model:'subreddit_domain_tag'
      
      
        
        subreddit_time_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "time_tags": 1 }
            { $unwind: "$time_tags" }
            { $group: _id: "$time_tags", count: $sum: 1 }
            # { $match: _id: $nin: picked_subreddit_time_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        subreddit_time_tag_cloud.forEach (time_tag, i) ->
            self.added 'results', Random.id(),
                name: time_tag.name
                count: time_tag.count
                model:'subreddit_time_tag'
      
      
        # subreddit_Organization_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "Organization": 1 }
        #     { $unwind: "$Organization" }
        #     { $group: _id: "$Organization", count: $sum: 1 }
        #     # { $match: _id: $nin: picked_Organizations }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:5 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # subreddit_Organization_cloud.forEach (Organization, i) ->
        #     self.added 'results', Random.id(),
        #         name: Organization.name
        #         count: Organization.count
        #         model:'subreddit_Organization'
      
      
        # subreddit_Person_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "Person": 1 }
        #     { $unwind: "$Person" }
        #     { $group: _id: "$Person", count: $sum: 1 }
        #     # { $match: _id: $nin: picked_Persons }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:5 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # subreddit_Person_cloud.forEach (Person, i) ->
        #     self.added 'results', Random.id(),
        #         name: Person.name
        #         count: Person.count
        #         model:'subreddit_Person'
      
      
        # subreddit_Company_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "Company": 1 }
        #     { $unwind: "$Company" }
        #     { $group: _id: "$Company", count: $sum: 1 }
        #     # { $match: _id: $nin: picked_Companys }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:5 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # subreddit_Company_cloud.forEach (Company, i) ->
        #     self.added 'results', Random.id(),
        #         name: Company.name
        #         count: Company.count
        #         model:'subreddit_Company'
      
      
        # subreddit_emotion_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "max_emotion_name": 1 }
        #     { $group: _id: "$max_emotion_name", count: $sum: 1 }
        #     # { $match: _id: $nin: picked_emotions }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:5 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # subreddit_emotion_cloud.forEach (emotion, i) ->
        #     self.added 'results', Random.id(),
        #         name: emotion.name
        #         count: emotion.count
        #         model:'subreddit_emotion'
      
      
        self.ready()