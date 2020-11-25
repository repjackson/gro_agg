Meteor.methods
    hi: ->
    # stringify_tags: ->
    #     docs = Docs.find({
    #         tags: $exists: true
    #         tags_string: $exists: false
    #     },{limit:1000})
    #     for doc in docs.fetch()
    #         # doc = Docs.findOne id
    #         tags_string = doc.tags.toString()
    #         Docs.update doc._id,
    #             $set: tags_string:tags_string
    #



    log_doc_terms: (doc_id)->
        doc = Docs.findOne doc_id
        if doc.tags
            for tag in doc.tags
                Meteor.call 'log_term', tag, ->


    # log_term: (term_title)->
    #     found_term =
    #         Terms.findOne
    #             title:term_title
    #     unless found_term
    #         Terms.insert
    #             title:term_title
    #         # if Meteor.user()
    #         #     Meteor.users.update({_id:Meteor.userId()},{$inc: karma: 1}, -> )
    #     else
    #         Terms.update({_id:found_term._id},{$inc: count: 1}, -> )
    #         Meteor.call 'call_wiki', @term_title, =>
    #             Meteor.call 'calc_term', @term_title, ->

    # calc_term: (term_title)->
    #     found_term =
    #         Terms.findOne
    #             title:term_title
    #     unless found_term
    #         Terms.insert
    #             title:term_title
    #     if found_term
    #         found_term_docs =
    #             Docs.find {
    #                 model:'reddit'
    #                 tags:$in:[term_title]
    #             }, {
    #                 sort:
    #                     points:-1
    #                     ups:-1
    #                 limit:10
    #             }



    #         unless found_term.image
    #             found_wiki_doc =
    #                 Docs.findOne
    #                     model:$in:['wikipedia']
    #                     # model:$in:['wikipedia','reddit']
    #                     title:term_title
    #             found_reddit_doc =
    #                 Docs.findOne
    #                     model:$in:['reddit']
    #                     "watson.metadata.image": $exists:true
    #                     # model:$in:['wikipedia','reddit']
    #                     title:term_title
    #             if found_wiki_doc
    #                 if found_wiki_doc.watson.metadata.image
    #                     Terms.update term._id,
    #                         $set:image:found_wiki_doc.watson.metadata.image


    # lookup: =>
    #     selection = @words[4000..4500]
    #     for word in selection
    #         # Meteor.setTimeout ->
    #         Meteor.call 'search_reddit', ([word])
    #         # , 5000

    rename_key:(old_key,new_key,parent)->
        Docs.update parent._id,
            $pull:_keys:old_key
        Docs.update parent._id,
            $addToSet:_keys:new_key
        Docs.update parent._id,
            $rename:
                "#{old_key}": new_key
                "_#{old_key}": "_#{new_key}"

    remove_tag: (tag)->
        results =
            Docs.find {
                tags: $in: [tag]
            }
        # Docs.remove(
        #     tags: $in: [tag]
        # )
        for doc in results.fetch()
            res = Docs.update doc._id,
                $pull: tags: tag

    # agg_omega: (query, key, collection)->
    rank_user: (site,user_id)->
        @unblock()
        # agg_res = Meteor.call 'agg_omega2', (err, res)->
        site_doc =
            Docs.findOne(
                model:'stack_site'
                api_site_parameter:site
            )
        user_doc =
            Docs.findOne(
                model:'stackuser'
                user_id:parseInt(user_id)
                site:site
            )
        
        if user_doc
            site_rank = 
                Docs.find(
                    model:'stackuser'
                    site:site
                    reputation:$gt:user_doc.reputation
                ).count()
            global_rank = 
                Docs.find(
                    model:'stackuser'
                    reputation:$gt:user_doc.reputation
                ).count()
            
            Docs.update user_doc._id,
                $set:
                    site_rank:site_rank+1
                    global_rank:global_rank+1
    
    omega: (site,user_id)->
        # @unblock()
        # agg_res = Meteor.call 'agg_omega2', (err, res)->
        site_doc =
            Docs.findOne(
                model:'stack_site'
                api_site_parameter:site
            )
        user_doc =
            Docs.findOne(
                model:'stackuser'
                user_id:parseInt(user_id)
                site:site
            )
        
        if user_doc
            sent_avg = Meteor.call 'sent_avg', site, user_id
            console.log 'sent-avg', sent_avg
            user_top_emotions = Meteor.call 'calc_user_top_emotions', site, user_id
            user_top_emotion = user_top_emotions[0].title
            # console.log user_top_emotion,'top emotion'
            
            agg_res = Meteor.call 'utags', site, user_id
            user_tag_res = Meteor.call 'user_question_tags', site, user_id
            if user_tag_res
                added_tags = []
                for tag in user_tag_res
                    added_tags.push tag.title
                Docs.update user_doc._id,
                    $set:
                        user_tag_agg: user_tag_res
                        user_top_emotions:user_top_emotions
                        user_top_emotion:user_top_emotion
                        sentiment_positive_avg: sent_avg[0].avg_sent_score
                        sentiment_negative_avg: sent_avg[1].avg_sent_score
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
    
    
    utags: (site,user_id)->
        site_doc =
            Docs.findOne(
                model:'stack_site'
                api_site_parameter:site
            )
        user_doc =
            Docs.findOne(
                model:'stackuser'
                site:site
                user_id:user_id
            )
        
        match = {}

        match.model = ['stack_question','stack_question','stack_answer']
        match["owner.user_id"] = parseInt(user_id)
        match.site = site
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
            
            
    sent_avg: (site,user_id)->
        l = console.log
        user_doc =
            Docs.findOne(
                model:'stackuser'
                site:site
                user_id:user_id
            )
        
        options = {
            explain:false
            allowDiskUse:true
        }
        match = {}
        # if omega.selected_tags.length > 0
        #     match.tags =
        #         $all: omega.selected_tags
        match.model = 'stack_question'
        # match.site = site
        match["owner.user_id"] = parseInt(user_id)
        match.site = site
        
        pipe =  [
            { $match: match }
            # { $group:
            #     _id: "$doc_sentiment_score",
            #     # avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
            #     avg_sent_score: { $avg: "$doc_sentiment_score" }
            # }
            { $group: 
                _id:'$doc_sentiment_label'
                avg_sent_score: { $avg: "$doc_sentiment_score" }
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

    calc_user_top_emotions: (site,user_id)->
        l = console.log
        site_doc =
            Docs.findOne(
                model:'stack_site'
                api_site_parameter:site
            )
        user_doc =
            Docs.findOne(
                model:'stackuser'
                site:site
                user_id:user_id
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
        
        match.model = 'stack_question'
        # match.site = site
        match["owner.user_id"] = parseInt(user_id)
        match.site = site
        total_doc_result_count =
            Docs.find( match,
                {
                    fields:
                        _id:1
                }
            ).count()
        l total_doc_result_count,'count'
        options = {
            explain:false
            allowDiskUse:true
        }

        # if omega.selected_tags.length > 0
        #     limit = 42
        # else
        limit = 33
        # { $match: tags:$all: omega.selected_tags }
        l match
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


    user_question_tags: (site,user_id)->
        site_doc =
            Docs.findOne(
                model:'stack_site'
                api_site_parameter:site
            )
        user_doc =
            Docs.findOne(
                model:'stackuser'
                site:site
                user_id:user_id
            )
        
        match = {model:'stack_question'}
        match.site = site
        total_doc_result_count =
            Docs.find( match,
                {
                    fields:
                        _id:1
                }
            ).count()
        match["owner.user_id"] = parseInt(user_id)
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
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            # { $group: _id: "$max_emotion_name", count: $sum: 1 }
            # { $match: _id: $nin: omega.selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 42 }
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
