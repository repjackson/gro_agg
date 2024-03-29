Meteor.methods
    calc_user_tags_method: (username)->
        @unblock()
        # agg_res = Meteor.call 'agg_omega2', (err, res)->
        # site_doc =
        #     Docs.findOne(
        #         model:'stack_site'
        #         api_site_parameter:site
        #     )
        user_doc =
            Docs.findOne(
                model:'user'
                username:username
            )
        
        if user_doc
            user_tag_res = Meteor.call 'calc_user_tags', username
            if user_tag_res
                added_tags = []
                for tag in user_tag_res
                    added_tags.push tag.title
                Docs.update user_doc._id,
                    $set:
                        user_tag_agg: user_tag_res
                        tags:added_tags
        
                        # user_top_emotions:user_top_emotions
                    
            # user_sent_avg = Meteor.call 'user_sent_avg', username
    ruser_omega: (username)->
        # @unblock()
        # agg_res = Meteor.call 'agg_omega2', (err, res)->
        # site_doc =
        #     Docs.findOne(
        #         model:'stack_site'
        #         api_site_parameter:site
        #     )
        user_doc =
            Docs.findOne(
                model:'user'
                username:username
            )
        
        if user_doc
            # user_sent_avg = Meteor.call 'user_sent_avg', username
            # if user_sent_avg[0]
            #     sentiment_avg = user_sent_avg[0].avg_sent_score
            # else
            #     sentiment_avg = 0
            if user_doc.data
                if user_doc.data.total_karma
                    user_top_emotions = Meteor.call 'calc_user_top_emotions', username
                    if user_top_emotions[0]
                        user_top_emotion = user_top_emotions[0].title
                        # agg_res = Meteor.call 'user_emotions', username
                            
                        rep_joy = user_doc.data.total_karma*user_top_emotions[0].avg_joy_score
                        rep_sadness = user_doc.data.total_karma*user_top_emotions[0].avg_sadness_score
                        rep_anger = user_doc.data.total_karma*user_top_emotions[0].avg_anger_score
                        rep_disgust = user_doc.data.total_karma*user_top_emotions[0].avg_disgust_score
                        rep_fear = user_doc.data.total_karma*user_top_emotions[0].avg_fear_score
                        
                            
                        Docs.update user_doc._id,
                            $set:
                                # user_top_emotions:user_top_emotions
                                # user_top_emotion:user_top_emotion
                                # sentiment_avg: sentiment_avg
                                rep_joy:rep_joy
                                rep_sadness:rep_sadness
                                rep_anger:rep_anger
                                rep_disgust:rep_disgust
                                rep_fear:rep_fear
                                avg_sent_score: user_top_emotions[0].avg_sent_score
                                avg_joy_score: user_top_emotions[0].avg_joy_score
                                avg_anger_score: user_top_emotions[0].avg_anger_score
                                avg_sadness_score: user_top_emotions[0].avg_sadness_score
                                avg_disgust_score: user_top_emotions[0].avg_disgust_score
                                avg_fear_score: user_top_emotions[0].avg_fear_score
        
                                # sentiment_positive_avg: user_sent_avg[0].avg_sent_score
                                # sentiment_negative_avg: user_sent_avg[1].avg_sent_score
                        # omega = Docs.findOne model:'omega_session'
                        # doc_count = omega.total_doc_result_count
                        # doc_count = omega.doc_result_ids.length
                        # unless omega.selected_doc_id in omega.doc_result_ids
                        #     Docs.update omega._id,
                        #         $set:selected_doc_id:omega.doc_result_ids[0]
                        # filtered_agg_res = []
            
                        # for agg_tag in agg_res
                        #     # if agg_tag.count < doc_count
                        #         # filtered_agg_res.push agg_tag
                        #         if agg_tag.title
                        #             if agg_tag.title.length > 0
                        #                 filtered_agg_res.push agg_tag
                        # term_emotion = _.max(filtered_agg_res, (tag)->tag.count).title
                        # if term_emotion
                        #     Docs.update user_doc._id,
                        #         $set:
                        #             max_emotion_name:term_emotion
            
                        # Docs.update omega._id,
                        #     $set:
                        #         # agg:agg_res
                        #         filtered_agg_res:filtered_agg_res
            
    
    ruser_emotions: (username)->
        # @unblock()
        # site_doc =
        #     Docs.findOne(
        #         model:'stack_site'
        #         api_site_parameter:site
        #     )
        user_doc =
            Docs.findOne(
                model:'user'
                username:username
            )
        
        match = {}

        match.model = $in:['rpost','rcomment']
        match["data.author"] = username
        match.max_emotion_name = $exists:true
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
            # allowDiskUse:true
        }

        # if omega.picked_stags.length > 0
        #     limit = 42
        # else
        limit = 20
        # { $match: tags:$all: omega.picked_stags }
        pipe =  [
            { $match: match }
            { $project: max_emotion_name: 1 }
            # { $unwind: "$max_emotion_name" }
            { $group: _id: "$max_emotion_name", count: $sum: 1 }
            # { $group: _id: "$max_emotion_name", count: $sum: 1 }
            # { $match: _id: $nin: omega.picked_stags }
            { $sort: count: -1, _id: 1 }
            { $limit: 5 }
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
            
    calc_ruser_tags: (username)->
        # @unblock()
        user_doc =
            Docs.findOne(
                model:'user'
                username:username
            )
        
        match = {}

        match.model = $in:['rpost','rcomment']
        match["data.author"] = username
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
            # allowDiskUse:true
        }

        # if omega.picked_stags.length > 0
        #     limit = 42
        # else
        limit = 20
        # { $match: tags:$all: omega.picked_stags }
        pipe =  [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            # { $group: _id: "$max_emotion_name", count: $sum: 1 }
            # { $match: _id: $nin: omega.picked_stags }
            { $sort: count: -1, _id: 1 }
            { $limit:20 }
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

            
    user_sent_avg: (username)->
        # @unblock()
        user_doc =
            Docs.findOne(
                model:'user'
                username:username
            )
        
        options = {
            explain:false
            # allowDiskUse:true
        }
        match = {}
        # if omega.picked_stags.length > 0
        #     match.tags =
        #         $all: omega.picked_stags
        match.model = $in:['rpost','rcomment']
        match["data.author"] = username
        match.doc_sentiment_score = $exists:true
        pipe =  [
            { $match: match }
            # { $group:
            #     _id: "$doc_sentiment_score",
            #     # avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
            #     avg_sent_score: { $avg: "$doc_sentiment_score" }
            # }
            { $group: 
                # _id:'$doc_sentiment_label'
                _id:null
                avg_sent_score: { $avg: "$doc_sentiment_score" }
                avg_joy_score: { $avg: "$joy_percent" }
                avg_anger_score: { $avg: "$anger_percent" }
                avg_sadness_score: { $avg: "$sadness_percent" }
                avg_disgust_score: { $avg: "$disgust_percent" }
                avg_fear_score: { $avg: "$fear_percent" }
            }
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

    calc_user_top_emotions: (username)->
        # @unblock()
        user_doc =
            Docs.findOne(
                model:'user'
                username:username
            )
        
        # omega =
        #     Docs.findOne
        #         model:'omega_session'

        # match = {tags:$in:[term]}
        match = {}
        # if omega.picked_stags.length > 0
        #     match.tags =
        #         $all: omega.picked_stags
        # else
        #     match.tags =
        #         $all: ['dao']
        
        match.model = $in:['rpost','rcomment']
        match["data.author"] = username
        match.doc_sentiment_score = $exists:true
        total_doc_result_count =
            Docs.find( match,
                {
                    fields:
                        _id:1
                }
            ).count()
        options = {
            explain:false
            # allowDiskUse:true
        }

        # if omega.picked_stags.length > 0
        #     limit = 42
        # else
        limit = 20
        # { $match: tags:$all: omega.picked_stags }
        pipe =  [
            { $match: match }
            # { $project: max_emotion_name: 1 }
            # { $unwind: "$max_emotion_name" }
            { $group: 
                # _id: "$max_emotion_name", count: $sum: 1 
                _id: null 
                avg_sent_score: { $avg: "$doc_sentiment_score" }
                avg_joy_score: { $avg: "$joy_percent" }
                avg_anger_score: { $avg: "$anger_percent" }
                avg_sadness_score: { $avg: "$sadness_percent" }
                avg_disgust_score: { $avg: "$disgust_percent" }
                avg_fear_score: { $avg: "$fear_percent" }
            }
            # { $sort: count: -1, _id: 1 }
            # { $limit: 5 }
            # { $project: _id: 0, title: '$_id', count: 1 }
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


    rank_user: (username)->
        @unblock()
        # agg_res = Meteor.call 'agg_omega2', (err, res)->
        # site_doc =
        #     Docs.findOne(
        #         model:'stack_site'
        #         api_site_parameter:site
        #     )
        user_doc =
            Docs.findOne(
                model:'user'
                username:username
            )
        
        if user_doc
            # site_rank = 
            #     Docs.find(
            #         model:'user'
            #         site:site
            #         data.total_karma:$gt:user_doc.data.total_karma
            #     ).count()
            global_rank = 
                Docs.find(
                    model:'user'
                    "data.total_karma":$gt:user_doc.data.total_karma
                ).count()
            Docs.update user_doc._id,
                $set:
                    # site_rank:site_rank+1
                    global_rank:global_rank+1
            
            for emotion in ['joy','sadness','disgust','fear','anger']
                # site_emo_rep_rank = 
                #     Docs.find(
                #         model:'user'
                #         site:site
                #         "rep_#{emotion}":$gt:user_doc["rep_#{emotion}"]
                #     ).count()
                global_emo_rep_rank = 
                    Docs.find(
                        model:'user'
                        "rep_#{emotion}":$gt:user_doc["rep_#{emotion}"]
                    ).count()
                Docs.update({_id:user_doc._id},
                    {
                        $set:
                            # "site_#{emotion}_rep_rank":site_emo_rep_rank+1
                            "global_#{emotion}_rep_rank":global_emo_rep_rank+1
                    }, -> )



Meteor.publish 'selected_users', (
    picked_user_tags
    username_query
    limit=1
    sort_key
    sort_direction=-1
    )->
    @unblock()

    match = {model:'user'}
    if username_query
        match.username = {$regex:"#{username_query}", $options: 'i'}
    if picked_user_tags.length > 0 then match.tags = $all: picked_user_tags
    # unless Meteor.isDevelopment
    # match["data.subreddit.over_18"] = $ne:true 

    Docs.find match,
        limit:42
        sort:
            "#{sort_key}":sort_direction
        fields:
            "data.total_karma":1
            "data.comment_karma":1
            "data.link_karma":1
            "data.created":1
            username:1
            global_rank:1
            avg_anger_score:1
            avg_sadness_score:1
            avg_disgust_score:1
            avg_fear_score:1
            avg_joy_score:1
            user_top_emotion:1
            avg_sent_score:1
            tags:1
            'data.snoovatar_img':1
            rep_joy:1
            rep_sadness:1
            rep_fear:1
            rep_disgust:1
            global_anger_rep_rank:1
            global_disgust_rep_rank:1
            global_joy_rep_rank:1
            global_sadness_rep_rank:1
            global_fear_rep_rank:1
            model:1



Meteor.publish 'user_tags', (
    picked_user_tags
    username_query
    # view_mode
    # limit
)->
    @unblock()
    
    self = @
    match = {model:'user'}
    if picked_user_tags.length > 0 then match.tags = $all: picked_user_tags
    if username_query    
        match.username = {$regex:"#{username_query}", $options: 'i'}
    # match["data.subreddit.over_18"] = $ne:true 
    # if location_query.length > 1 
    #     match.location = {$regex:"#{location_query}", $options: 'i'}
    # if selected_user_location then match.location = selected_user_location
    # match.model = 'item'
    # if view_mode is 'users'
    #     match.bought = $ne:true
    #     match._author_id = $ne: Meteor.userId()
    # if view_mode is 'sold'
    #     match.bought = true
    #     match._author_id = Meteor.userId()
    doc_count = Docs.find(match).count()
    cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_user_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    cloud.forEach (user_tag, i) ->
        self.added 'results', Random.id(),
            name: user_tag.name
            count: user_tag.count
            model:'user_tag'
            index: i


    self.ready()



Meteor.publish 'user_result_tags', (
    model='rpost'
    username
    picked_stags
    # selected_subreddit_domain
    # view_bounties
    # view_unanswered
    # query=''
    )->
    @unblock()
    self = @
    match = {
        model:model
        author:username
    }
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if picked_stags.length > 0 then match.tags = $all:picked_stags
    # if selected_subreddit_domain.length > 0 then match.domain = $all:selected_subreddit_domain
    # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
    doc_count = Docs.find(match).count()
    rpost_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_stags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:20 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    rpost_tag_cloud.forEach (tag, i) ->
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:"#{model}_result_tag"
    
    
    # subreddit_domain_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "data.domain": 1 }
    #     # { $unwind: "$domain" }
    #     { $group: _id: "$data.domain", count: $sum: 1 }
    #     # { $match: _id: $nin: selected_domains }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:7 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # subreddit_domain_cloud.forEach (domain, i) ->
    #     self.added 'results', Random.id(),
    #         name: domain.name
    #         count: domain.count
    #         model:'subreddit_domain_tag'
  
  
    # subreddit_Organization_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "Organization": 1 }
    #     { $unwind: "$Organization" }
    #     { $group: _id: "$Organization", count: $sum: 1 }
    #     # { $match: _id: $nin: selected_Organizations }
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
    #     # { $match: _id: $nin: selected_Persons }
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
    #     # { $match: _id: $nin: selected_Companys }
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
    #     # { $match: _id: $nin: selected_emotions }
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
