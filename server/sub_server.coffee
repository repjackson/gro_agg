Meteor.publish 'avg_emotions', (
    picked_tags
    subreddit
    )->
    @unblock()
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
    picked_domains
    picked_time_tags
    )->
    @unblock()

    match = {model:'rpost'}
    match.subreddit = subreddit
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if picked_domains.length > 0 then match.domain = $all:picked_domains
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
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
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        # url = "https://www.reddit.com/r/#{subreddit}/about.json?&raw_json=1&include_over_18=on"
        url = "https://www.reddit.com/r/#{subreddit}/about.json?&raw_json=1"
        HTTP.get url,(err,res)=>
            if res.data.data
                existing = Docs.findOne 
                    model:'subreddit'
                    name:subreddit
                    # "data.display_name":subreddit
                if existing
                    # if Meteor.isDevelopment
                    # if typeof(existing.tags) is 'string'
                    #     Doc.update
                    #         $unset: tags: 1
                    Docs.update existing._id,
                        $set: data:res.data.data
                unless existing
                    sub = {}
                    sub.model = 'subreddit'
                    sub.name = subreddit
                    sub.data = res.data.data
                    new_reddit_post_id = Docs.insert sub
    
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
            
    # get_sub_info: (subreddit)->
    #     @unblock()
    #     # if subreddit 
    #     #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
    #     # else
    #     url = "https://www.reddit.com/r/#{subreddit}/about.json?&raw_json=1"
    #     HTTP.get url,(err,res)=>
    #         # console.log res.data.data
    #         if res.data.data
    #             existing = Docs.findOne 
    #                 model:'subreddit'
    #                 "data.display_name":subreddit
    #             if existing
    #                 # console.log 'existing', existing
    #                 # if Meteor.isDevelopment
    #                 # if typeof(existing.tags) is 'string'
    #                 #     Doc.update
    #                 #         $unset: tags: 1
    #                 Docs.update existing._id,
    #                     $set: data:res.data.data
    #             unless existing
    #                 # console.log 'new sub', subreddit
    #                 sub = {}
    #                 sub.model = 'subreddit'
    #                 sub.name = subreddit
    #                 sub.data = res.data.data
    #                 new_reddit_post_id = Docs.insert sub
              
    search_subreddit: (subreddit,search)->
        @unblock()
        HTTP.get "http://reddit.com/r/#{subreddit}/search.json?q=#{search}&limit=10&restrict_sr=1&raw_json=1&include_over_18=off&nsfw=0", (err,res)->
            if res.data.data.dist > 1
                _.each(res.data.data.children[0..100], (item)=>
                    # for item in res.data.data.children[0..3]
                    id = item.data.id
                    # Docs.insert d
                    # found = 
                    added_tags = [search]
                    found = Docs.findOne({
                        model:'rpost',
                        "data.subreddit":item.data.subreddit
                        reddit_id:id
                    })
                    #     # continue
                    if found
                        console.log 'updating', found.data.title
                        Docs.update({_id:found._id},{ 
                            $addToSet: tags: $each:added_tags
                            $set:
                                subreddit:item.data.subreddit
                        }, ->)
                    unless found
                        added_tags = _.flatten(search)
                        item.model = 'rpost'
                        item.reddit_id = item.data.id
                        item.author = item.data.author
                        item.subreddit = item.data.subreddit
                        item.tags = [search]
                        # item.rdata = item.data
                        Docs.insert item, ->
                )
                
                
Meteor.publish 'subreddit_result_tags', (
    subreddit
    picked_domains
    picked_time_tags
    # view_bounties
    # view_unanswered
    # query=''
    )->
    @unblock()
    self = @
    match = {
        model:'rpost'
        subreddit:subreddit
    }
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if picked_domains.length > 0 then match.domain = $all:picked_domains
    if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
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
    
    
    domain_cloud = Docs.aggregate [
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
    domain_cloud.forEach (domain, i) ->
        self.added 'results', Random.id(),
            name: domain.name
            count: domain.count
            model:'domain'
  
  
    
    time_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "time_tags": 1 }
        { $unwind: "$time_tags" }
        { $group: _id: "$time_tags", count: $sum: 1 }
        # { $match: _id: $nin: picked_time_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    time_tag_cloud.forEach (time_tag, i) ->
        self.added 'results', Random.id(),
            name: time_tag.name
            count: time_tag.count
            model:'time_tag'
  
  
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
    
    
    
    
Meteor.publish 'subreddit_by_param', (subreddit)->
    Docs.find
        model:'subreddit'
        "data.display_name":subreddit

Meteor.publish 'sub_docs', (
    subreddit
    picked_sub_tags
    picked_domains
    picked_time_tags
    picked_authors
    sort_key='data.created'
    sort_direction
    )->
    @unblock()

    self = @
    match = {
        model:'rpost'
        subreddit:subreddit
    }
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    # if picked_domains.length > 0 then match.domain = $all:picked_domains
    if picked_sub_tags.length > 0 then match.tags = $all:picked_sub_tags
    # if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    # if picked_authors.length > 0 then match.authors = $all:picked_authors
    Docs.find match,
        limit:20
        sort: "#{sort_key}":parseInt(sort_direction)
        fields:
            title:1
            tags:1
            url:1
            model:1
            # data:1    
            "watson.metadata.image":1
            "data.domain":1
            "data.permalink":1
            "permalink":1
            "data.title":1
            "data.created":1
            "data.subreddit":1
            "data.url":1
            time_tags:1
            'data.num_comments':1
            'data.author':1
            'data.ups':1
            "data.thumbnail":1
            "data.media.oembed":1
            analyzed_text:1
            "data.url":1
            permalink:1
            "data.media":1
            doc_sentiment_score:1
            doc_sentiment_label:1
            joy_percent:1
            sadness_percent:1
            fear_percent:1
            disgust_percent:1
            anger_percent:1
            "watson.metadata":1
            "data.thumbnail":1
            "data.url":1
            max_emotion_name:1
            max_emotion_percent:1
            

