Meteor.methods
    ruser_omega: (username)->
        console.log 'calling', username
        # @unblock()
        # agg_res = Meteor.call 'agg_omega2', (err, res)->
        # site_doc =
        #     Docs.findOne(
        #         model:'stack_site'
        #         api_site_parameter:site
        #     )
        user_doc =
            Docs.findOne(
                model:'ruser'
                username:username
            )
        
        if user_doc
            # ruser_sent_avg = Meteor.call 'ruser_sent_avg', username
            # if ruser_sent_avg[0]
            #     sentiment_avg = ruser_sent_avg[0].avg_sent_score
            # else
            #     sentiment_avg = 0

            
            user_top_emotions = Meteor.call 'calc_ruser_top_emotions', username
            if user_top_emotions[0]
                user_top_emotion = user_top_emotions[0].title
            
            
            agg_res = Meteor.call 'ruser_utags', username
            user_tag_res = Meteor.call 'user_question_tags', username
            if user_tag_res
                added_tags = []
                for tag in user_tag_res
                    added_tags.push tag.title
                    
                console.log 'top emotion', user_top_emotions[0]
                    
                rep_joy = user_doc.data.total_karma*user_top_emotions[0].avg_joy_score
                rep_sadness = user_doc.data.total_karma*user_top_emotions[0].avg_sadness_score
                rep_anger = user_doc.data.total_karma*user_top_emotions[0].avg_anger_score
                rep_disgust = user_doc.data.total_karma*user_top_emotions[0].avg_disgust_score
                rep_fear = user_doc.data.total_karma*user_top_emotions[0].avg_fear_score
                
                    
                Docs.update user_doc._id,
                    $set:
                        user_tag_agg: user_tag_res
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

                        # sentiment_positive_avg: ruser_sent_avg[0].avg_sent_score
                        # sentiment_negative_avg: ruser_sent_avg[1].avg_sent_score
                        tags:added_tags
            # omega = Docs.findOne model:'omega_session'
            # doc_count = omega.total_doc_result_count
            # doc_count = omega.doc_result_ids.length
            # unless omega.selected_doc_id in omega.doc_result_ids
            #     Docs.update omega._id,
            #         $set:selected_doc_id:omega.doc_result_ids[0]
            filtered_agg_res = []

            for agg_tag in agg_res
                # if agg_tag.count < doc_count
                    # filtered_agg_res.push agg_tag
                    if agg_tag.title
                        if agg_tag.title.length > 0
                            filtered_agg_res.push agg_tag
            term_emotion = _.max(filtered_agg_res, (tag)->tag.count).title
            if term_emotion
                Docs.update user_doc._id,
                    $set:
                        max_emotion_name:term_emotion

            # Docs.update omega._id,
            #     $set:
            #         # agg:agg_res
            #         filtered_agg_res:filtered_agg_res
    
    
    ruser_utags: (username)->
        # site_doc =
        #     Docs.findOne(
        #         model:'stack_site'
        #         api_site_parameter:site
        #     )
        user_doc =
            Docs.findOne(
                model:'ruser'
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
            allowDiskUse:true
        }

        # if omega.selected_tags.length > 0
        #     limit = 42
        # else
        limit = 33
        # { $match: tags:$all: omega.selected_tags }
        pipe =  [
            { $match: match }
            { $project: max_emotion_name: 1 }
            # { $unwind: "$max_emotion_name" }
            { $group: _id: "$max_emotion_name", count: $sum: 1 }
            # { $group: _id: "$max_emotion_name", count: $sum: 1 }
            # { $match: _id: $nin: omega.selected_tags }
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
            
            
    ruser_sent_avg: (username)->
        user_doc =
            Docs.findOne(
                model:'ruser'
                username:username
            )
        
        options = {
            explain:false
            allowDiskUse:true
        }
        match = {}
        # if omega.selected_tags.length > 0
        #     match.tags =
        #         $all: omega.selected_tags
        match.model = $in:['rpost','rcomment']
        match["data.author"] = username
        
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

    calc_ruser_top_emotions: (username)->
        user_doc =
            Docs.findOne(
                model:'ruser'
                username:username
            )
        
        # omega =
        #     Docs.findOne
        #         model:'omega_session'

        # match = {tags:$in:[term]}
        match = {}
        # if omega.selected_tags.length > 0
        #     match.tags =
        #         $all: omega.selected_tags
        # else
        #     match.tags =
        #         $all: ['dao']
        
        match.model = $in:['rpost','rcomment']
        match["data.author"] = username
        total_doc_result_count =
            Docs.find( match,
                {
                    fields:
                        _id:1
                }
            ).count()
        options = {
            explain:false
            allowDiskUse:true
        }

        # if omega.selected_tags.length > 0
        #     limit = 42
        # else
        limit = 33
        # { $match: tags:$all: omega.selected_tags }
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
