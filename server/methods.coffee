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
            user_top_emotions = Meteor.call 'calc_user_top_emotions', site, user_id
            user_top_emotion = user_top_emotions[0].title
            console.log user_top_emotion,'top emotion'
            
            
            
            agg_res = Meteor.call 'omega2', site, user_id
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
                    $addToSet:
                        tags:$each:added_tags
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
    omega2: (site,user_id)->
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
        match.site = site
        total_doc_result_count =
            Docs.find( match,
                {
                    fields:
                        _id:1
                }
            ).count()
        # doc_results =
        #     Docs.find( match,
        #         {
        #             limit:20
        #             sort:
        #                 points:-1
        #                 ups:-1
        #             fields:
        #                 _id:1
        #         }
        #     ).fetch()
        # if doc_results[0]
        #     unless doc_results[0].rd
        #         if doc_results[0].reddit_id
        #             Meteor.call 'get_reddit_post', doc_results[0]._id, doc_results[0].reddit_id, =>
        # doc_result_ids = []
        # for result in doc_results
        #     doc_result_ids.push result._id
        # Docs.update omega._id,
        #     $set:
        #         doc_result_ids:doc_result_ids
        #         total_doc_result_count:total_doc_result_count
        # if doc_re
        # found_wiki_doc =
        #     Docs.findOne
        #         model:'wikipedia'
        #         title:$in:omega.selected_tags
        # if found_wiki_doc
        #     Docs.update omega._id,
        #         $addToSet:
        #             doc_result_ids:found_wiki_doc._id

        # Docs.update omega._id,
        #     $set:
        #         match:match
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




    # get_top_emotion: ->
    #     emotion_list = ['joy', 'sadness', 'fear', 'disgust', 'anger']
    #     #
    #     current_most_emotion = ''
    #     current_max_emotion_count = 0
    #     current_max_emotion_percent = 0
    #     omega = Docs.findOne model:'omega_session'
    #     # doc_results =
    #         # Docs.find
    #
    #     match = {_id:$in:omega.doc_result_ids}
    #     for doc_id in omega.doc_result_ids
    #         doc = Docs.findOne(doc_id)
    #         if doc.max_emotion_percent
    #             if doc.max_emotion_percent > current_max_emotion_percent
    #                 current_max_emotion_percent = doc.max_emotion_percent
    #                 if doc.max_emotion_name is 'anger'
    #                     emotion_color = 'green'
    #                 else if doc.max_emotion_name is 'disgust'
    #                     emotion_color = 'teal'
    #                 else if doc.max_emotion_name is 'sadness'
    #                     emotion_color = 'orange'
    #                 else if doc.max_emotion_name is 'fear'
    #                     emotion_color = 'grey'
    #                 else if doc.max_emotion_name is 'joy'
    #                     emotion_color = 'red'
    #
    #                 Docs.update omega._id,
    #                     $set:
    #                         current_most_emotion:doc.max_emotion_name
    #                         current_max_emotion_percent: current_max_emotion_percent
    #                         emotion_color:emotion_color
    #     # for emotion in emotion_list
    #     #     emotion_match = match
    #     #     emotion_match.max_emotion_name = emotion
    #     #     found_emotions =
    #     #         Docs.find(emotion_match)
    #     #
    #     #     # Docs.update omega._id,
    #     #     #     $set:
    #     #     #         "current_#{emotion}_count":found_emotions.count()
    #     #     if omega.current_most_emotion < found_emotions.count()
    #     #         current_most_emotion = emotion
    #     #         current_max_emotion_count = found_emotions.count()
    #     emotion_match = match
    #     emotion_match.max_emotion_name = $exists:true
    #     # main_emotion = Docs.findOne(emotion_match)
    #
    #     # for doc_id in omega.doc_result_ids
    #     #     doc = Docs.findOne(doc_id)
    #     # if main_emotion
    #     #     Docs.update omega._id,
    #     #         $set:
    #     #             emotion_color:emotion_color
    #     #             max_emotion_name:main_emotion.max_emotion_name