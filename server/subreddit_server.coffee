Meteor.publish 'subreddit_by_param', (subreddit)->
    console.log 'looking for', subreddit
    Docs.find
        model:'subreddit'
        "data.display_name":subreddit
        



Meteor.methods
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
    
    get_sub_latest: (subreddit)->
        @unblock()
        # console.log 'getting latest', subreddit
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "https://www.reddit.com/r/#{subreddit}.json?&raw_json=1&nsfw=1"
        HTTP.get url,(err,res)=>
            # console.log res.data.data.children.length
            # if res.data.data.dist > 1
            _.each(res.data.data.children[0..100], (item)=>
                # console.log item.data.id
                found = 
                    Docs.findOne    
                        model:'rpost'
                        reddit_id:item.data.id
                        # subreddit:item.data.id
                if found
                    # console.log found, 'found'
                    Docs.update found._id,
                        $set:subreddit:item.data.subreddit
                unless found
                    # console.log found, 'not found'
                    item.model = 'rpost'
                    item.reddit_id = item.data.id
                    item.author = item.data.author
                    item.subreddit = item.data.subreddit
                    # item.rdata = item.data
                    Docs.insert item
            )




Meteor.publish 'sub_count', (
    query=''
    picked_tags
    )->
        
    match = {model:'subreddit'}
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if query.length > 0
        match["data.display_name"] = {$regex:"#{query}", $options:'i'}
    Counts.publish this, 'sub_counter', Docs.find(match)
    return undefined


Meteor.publish 'subreddits', (
    query=''
    picked_tags
    sort_key='data.subscribers'
    sort_direction=-1
    )->
    match = {model:'subreddit'}
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    if query.length > 0
        match["data.display_name"] = {$regex:"#{query}", $options:'i'}
    Docs.find match,
        limit:100
        sort: "#{sort_key}":sort_direction
        fields:
            model:1
            tags:1
            "data.display_name":1
            "data.title":1
            "data.header_title":1
            "data.header_img":1
            "data.public_description":1
            "data.advertiser_category":1
            "data.accounts_active":1
            "data.subscribers":1
            "data.banner_img":1
            "data.icon_img":1
        
        
Meteor.publish 'sub_docs_by_name', (
    subreddit
    picked_subreddit_tags
    picked_subreddit_domains
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
    console.log 'sub match', match
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if picked_subreddit_tags.length > 0 then match.tags = $all:picked_subreddit_tags
    if picked_subreddit_domains.length > 0 then match.domain = $all:picked_subreddit_domains
    # console.log sk
    Docs.find match,
        limit:20
        sort: "#{sk}":-1
        fields:
            _id:1
            # data:1
            "data.thumbnail":1
            "data.domain":1
            "data.media":1
            "data.link_url":1
            "data.is_reddit_media_domain":1
            "data.created":1
            "data.url":1
            "data.preview.images[0].source.url":1
            doc_sentiment_label:1
            doc_sentiment_score:1
            max_emotion_name:1
            # "data.selftext":1
            "watson.metadata":1
            subreddit:1
            joy_percent:1
            fear_percent:1
            sadness_percent:1
            disgust_percent:1
            anger_percent:1
            "data.selftext_html":1
            comment_count:1
            title:1
            domain:1
            reddit_id:1
            ups:1
            tags:1
            thumbnail:1
            url:1
            _timestamp:1
            _timestamp_tags:1
            views:1
            points:1
            model:1
    
    
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
    )->
        
    match = {model:'rpost'}
    match.subreddit = subreddit
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    Counts.publish this, 'sub_doc_counter', Docs.find(match)
    return undefined
