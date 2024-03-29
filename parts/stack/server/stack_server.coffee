request = require('request')
rp = require('request-promise');
Meteor.publish 'qid', (site,qid)->
    Docs.find
        model:'stack_question'
        site:site
        question_id:parseInt(qid)


    
Meteor.publish 'q_a', (site,qid)->
    # q = Docs.findOne 
    #     model:'stack_question'
    #     question_id:qid
    #     site:site
    Docs.find 
        model:'stack_answer'
        site:site
        question_id:parseInt(qid)

Meteor.publish 'stackuser_doc', (site,uid)->
    Docs.find 
        model:'stackuser'
        user_id:parseInt(uid)
        site:site

Meteor.publish 'site_by_param', (site)->
    Docs.find 
        model:'stack_site'
        api_site_parameter:site

# Meteor.publish 'stack_docs', ->
#     Docs.find {
#         model:'stack'
#     },
#         limit:20
            
    

Meteor.publish 'stack_docs', (
    selected_tags
    view_mode
    emotion_mode
    # query=''
    skip
    )->
    match = {model:'stack_question'}
    # if emotion_mode
    #     match.max_emotion_name = emotion_mode

    if selected_tags.length > 0
        match.tags = $all:selected_tags
    # match.model = 'wikipedia'
    # if selected_emotions.length > 0 then match.max_emotion_name = $all:selected_emotions
    
    Docs.find match,
        limit:7
        skip:skip
        sort:
            points: -1
            ups:-1
            # views: -1


# Meteor.publish 'selected_susers', (
#     selected_user_tags
#     username_query
#     limit=1
#     sort_key
#     sort_direction=-1
#     )->
#     console.log sort_key
#     sort_key_final = switch sort_key
#         when 'total' then 'data.total_karma'
#         when 'link' then 'data.link_karma'
#         when 'comment' then 'data.comment_karma'
#         when 'joy' then 'rep_joy'
#         when 'fear' then 'rep_fear'
#         when 'sadness' then 'rep_sadness'
#         when 'disgust' then 'rep_disgust'
#     match = {model:'stackuser'}
#     if username_query
#         match.username = {$regex:"#{username_query}", $options: 'i'}
#     if selected_user_tags.length > 0 then match.tags = $all: selected_user_tags
    
#     console.log sort_key_final
#     Docs.find match,
#         limit:20
#         sort:
#             "#{sort_key_final}":sort_direction

Meteor.publish 'selected_susers', (
    selected_user_tags
    selected_user_site
    selected_user_location
    username_query
    location_query
    )->
    match = {model:'stackuser'}
    if username_query
        match.display_name = {$regex:"#{username_query}", $options: 'i'}
    if location_query
        match.location = {$regex:"#{location_query}", $options: 'i'}

    if selected_user_tags.length > 0 then match.tags = $all: selected_user_tags
    if selected_user_site then match.site = selected_user_site
    if selected_user_location then match.location = selected_user_location
    Docs.find match,
        limit:20
        sort:
            reputation:-1





Meteor.methods 
    get_question: (site, qid)->
        question = Docs.findOne 
            model:'stack_question'
            question_id:parseInt(qid)
            site:site
        url = "https://api.stackexchange.com/2.2/questions/#{qid}?order=desc&sort=activity&site=#{site}&filter=!9_bDDxJY5&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_question'
                            question_id:item.question_id
                            site:site
                    if found
                        Docs.update found._id,
                            $set:body:item.body
                    unless found
                        item.site = site
                        item.model = 'stack_question'
                        # item.tags.push query
                        new_id = 
                            Docs.insert item
                        Meteor.call 'call_watson', new_id,'link','stack',->
            )).catch((err)->
            )

    get_q_a: (site, qid)->
        question = Docs.findOne 
            model:'stack_question'
            question_id:parseInt(qid)
            site:site
        url = "https://api.stackexchange.com/2.2/questions/#{qid}/answers?order=desc&sort=activity&site=#{site}&filter=!9_bDE(fI5&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_answer'
                            # question_id:item.question_id
                            answer_id:item.answer_id
                    # if found
                    #     Docs.update found._id,
                    #         $set:body:item.body
                    unless found
                        item.site = site
                        item.model = 'stack_answer'
                        # item.answer_id = item.answer_id
                        # item.tags.push query
                        new_id = 
                            Docs.insert item
            )).catch((err)->
            )

    get_q_c: (site, qid)->
        url = "https://api.stackexchange.com/2.2/questions/#{qid}/comments?order=desc&sort=creation&site=#{site}&filter=!--1nZxautsE.&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_comment'
                            post_id:parseInt(qid)
                            site:site
                    if found
                        Docs.update found._id,
                            $set:body:item.body
                    unless found
                        item.site = site
                        item.model = 'stack_comment'
                        # item.tags.push query
                        new_id = 
                            Docs.insert item
            )).catch((err)->
            )

    get_linked_questions: (site, qid)->
        question = Docs.findOne 
            model:'stack_question'
            question_id:parseInt(qid)
            site:site
        url = "https://api.stackexchange.com/2.2/questions/#{qid}/linked?order=desc&sort=activity&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_question'
                            post_id:item.post_id
                    if found
                        Docs.update found._id,
                            $addToSet: linked_to_ids: question_doc_id
                            # $set:body:item.body
                        Docs.update question_doc_id,
                            $addToSet:linked_question_ids:found._id
                    unless found
                        item.site = site
                        item.model = 'stack_question'
                        # item.tags.push query
                        item.linked_to_ids = [question_doc_id]
                        new_id = 
                            Docs.insert item
                        Docs.update question_doc_id,
                            $addToSet:linked_question_ids:new_id
            )).catch((err)->
            )

    get_related_questions: (site, qid)->
        question = Docs.findOne 
            model:'stack_question'
            question_id:parseInt(qid)
            site:site
        url = "https://api.stackexchange.com/2.2/questions/#{qid}/related?order=desc&sort=activity&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                for item in parsed.items
                    Docs.update question._id,
                        $addToSet:related_question_ids:item._id
                    found = 
                        Docs.findOne
                            model:'stack_question'
                            post_id:item.post_id
                    if found
                        Docs.update found._id,
                            $addToSet: linked_to_ids: qid
                            # $set:body:item.body
                    unless found
                        item.site = site
                        item.model = 'stack_question'
                        # item.tags.push query
                        item.linked_to_ids = [qid]
                        new_id = 
                            Docs.insert item
            )).catch((err)->
            )

    search_stack: (site, query, selected_tags) ->
        url = "https://api.stackexchange.com/2.2/search?order=desc&sort=activity&intitle=#{query}&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_question'
                            site:site
                            question_id:item.question_id
                    if found
                        Docs.update found._id,
                            $addToSet:tags:query
                        unless found.watson
                            Meteor.call 'call_watson', found._id,'link','stack',->
                    unless found
                        item.site = site
                        item.model = 'stack_question'
                        item.tags.push query
                        new_id = 
                            Docs.insert item
                        # unless found.watson
                        Meteor.call 'call_watson', new_id,'link','stack',->
                    # Meteor.call 'get_suser_questions', site, item.owner.user_id, ->
                    # Meteor.call 'stackuser_tags', site, item.owner.user_id, ->
                    Meteor.call 'suser_omega', site, item.owner.user_id, ->
            )).catch((err)->
            )
   
    search_stackuser: (site, user_id) ->
        @unblock()
        url = "https://api.stackexchange.com/2.2/users/#{user_id}?order=desc&sort=reputation&site=#{site}&filter=!--1nZv)deGu1&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stackuser'
                            site:site
                            user_id:parseInt(user_id)
                    if found
                        Docs.update found._id,
                            $set:
                                about_me:item.about_me
                                badge_counts: item.badge_counts
                                view_count: item.view_count
                                down_vote_count: item.down_vote_count
                                up_vote_count: item.up_vote_count
                                answer_count: item.answer_count
                                question_count: item.question_count
                                account_id: item.account_id
                                is_employee: item.is_employee
                                last_modified_date: item.last_modified_date
                                last_access_date: item.last_access_date
                                reputation_change_year: item.reputation_change_year
                                reputation_change_quarter: item.reputation_change_quarter
                                reputation_change_month: item.reputation_change_month
                                reputation_change_week: item.reputation_change_week
                                reputation_change_day: item.reputation_change_day
                                reputation: item.reputation
                                creation_date: item.creation_date
                                user_type: item.user_type
                                user_id: item.user_id
                                link: item.link
                                profile_image: item.profile_image
                                display_name: item.display_name

                    unless found
                        item.site = site
                        item.model = 'stackuser'
                        new_id = 
                            Docs.insert item
            )).catch((err)->
            )
   
    get_site_users: (site) ->
        for num in [1..100]
            url = "https://api.stackexchange.com/2.2/users?order=desc&sort=reputation&page=#{num}&pagesize=100&site=#{site}&filter=!--1nZv)deGu1&key=lPplyGlNUs)cIMOajW03aw(("
            options = {
                url: url
                headers: 'accept-encoding': 'gzip'
                gzip: true
            }
            rp(options)
                .then(Meteor.bindEnvironment((data)->
                    parsed = JSON.parse(data)
                    for item in parsed.items
                        found = 
                            Docs.findOne
                                model:'stackuser'
                                site:site
                                user_id:item.user_id
                        unless found
                            item.site = site
                            item.model = 'stackuser'
                            new_id = 
                                Docs.insert item
                )).catch((err)->
                )
    get_user_favs: (site) ->
        for num in [1..100]
            url = "https://api.stackexchange.com/2.2/privileges?order=desc&sort=reputation&page=#{num}&pagesize=100&site=#{site}&filter=!--1nZv)deGu1&key=lPplyGlNUs)cIMOajW03aw(("
            options = {
                url: url
                headers: 'accept-encoding': 'gzip'
                gzip: true
            }
            rp(options)
                .then(Meteor.bindEnvironment((data)->
                    parsed = JSON.parse(data)
                    for item in parsed.items
                        found = 
                            Docs.findOne
                                model:'stackuser'
                                site:site
                                user_id:item.user_id
                        unless found
                            item.site = site
                            item.model = 'stackuser'
                            new_id = 
                                Docs.insert item
                )).catch((err)->
                )

    get_suser_q: (site, user_id) ->
        url = "https://api.stackexchange.com/2.2/users/#{user_id}/questions?order=desc&sort=activity&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_question'
                            question_id:item.question_id
                            site:site
                            "owner.user_id":parseInt(user_id)
                    # if found
                    unless found
                        item.model = 'stack_question'
                        item.site = site
                        # item.user_id = parseInt(user_id)
                        new_id = 
                            Docs.insert item
            )).catch((err)->
            )
      get_priv: (site, user_id) ->
        url = "https://api.stackexchange.com/2.2/privileges?&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                # for item in parsed.items
                    # console.log item.
                    # found = 
                    #     Docs.findOne
                    #         model:'stack_question'
                    #         question_id:item.question_id
                    #         site:site
                    #         "owner.user_id":parseInt(user_id)
                    # # if found
                    # unless found
                    #     item.model = 'stack_question'
                    #     item.site = site
                    #     # item.user_id = parseInt(user_id)
                    #     new_id = 
                    #         Docs.insert item
            )).catch((err)->
            )
   
    get_suser_a: (site, user_id) ->
        url = "https://api.stackexchange.com/2.2/users/#{user_id}/answers?order=desc&sort=activity&site=#{site}&key=lPplyGlNUs)cIMOajW03aw((&filter=!3zl2.F7X(uyskMHHP"
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_answer'
                            site:site
                            "owner.user_id":parseInt(user_id)
                            answer_id:item.answer_id
                    if found
                        Docs.update found._id,
                            $set:body:item.body
                        continue
                    unless found
                        item.model = 'stack_answer'
                        item.site = site
                        new_id = 
                            Docs.insert item
                        continue
            )).catch((err)->
            )

    get_suser_c: (site, user_id) ->
        url = "https://api.stackexchange.com/2.2/users/#{user_id}/comments?order=desc&sort=creation&site=#{site}&filter=!--1nZxautsE.&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_comment'
                            site:site
                            "owner.user_id":parseInt(user_id)
                            comment_id:item.comment_id
                    # if found
                    #     cl 'found COMMENT', found
                        # Docs.update found._id, 
                        #     $set:
                        #         # owner:item.owner
                        #         # post_type:item.post_type
                        #         body:item.body
                    unless found
                        item.site = site
                        item.model = 'stack_comment'
                        # item.user_id = parseInt(user_id)
                        new_id = 
                            Docs.insert item
                        # cl 'new COMM', Docs.findOne(new_id)
            )).catch((err)->
            )
        
    # stackuser_badges: (site, user_id) ->
    #     user = Docs.findOne
    #         model:'stackuser'
    #         user_id:parseInt(user_id)
    #         site:site
    #     url = "https://api.stackexchange.com/2.2/users/#{user_id}/badges?order=desc&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
    #     options = {
    #         url: url
    #         headers: 'accept-encoding': 'gzip'
    #         gzip: true
    #     }
    #     rp(options)
    #         .then(Meteor.bindEnvironment((data)=>
    #             parsed = JSON.parse(data)
    #             # adding_tags = []
    #             for item in parsed.items
    #                 # adding_tags.push item.name
    #             # Docs.update user._id,
    #             #     $addToSet:
    #             #         tags:$each:adding_tags
    #             #     found = 
    #             #         Docs.findOne
    #             #             model:'stack_badge'
    #             #             site:site
    #             #             user_id:parseInt(user_id)
    #             #     # if found
    #             #     unless found
    #             #         item.site = site
    #             #         item.model = 'stack_badge'
    #             #         new_id = 
    #             #             Docs.insert item
    #             return
    #         )).catch((err)->
    #         )
        
    # stackuser_tags: (site, user_id) ->
    #     user = Docs.findOne
    #         model:'stackuser'
    #         user_id:parseInt(user_id)
    #         site:site
    #     url = "https://api.stackexchange.com/2.2/users/#{user_id}/tags?order=desc&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
    #     options = {
    #         url: url
    #         headers: 'accept-encoding': 'gzip'
    #         gzip: true
    #     }
    #     rp(options)
    #         .then(Meteor.bindEnvironment((data)=>
    #             parsed = JSON.parse(data)
    #             adding_tags = []
    #             for item in parsed.items
    #                 adding_tags.push item.name
    #             Docs.update user._id,
    #                 $addToSet:
    #                     tags:$each:adding_tags
    #                 # found = 
    #                 #     Docs.findOne
    #                 #         model:'stack_tag'
    #                 #         site:site
    #                 #         user_id:parseInt(user_id)
    #                 # if found
    #                 # unless found
    #                 #     item.site = site
    #                 #     item.model = 'stack_tag'
    #                 #     new_id = 
    #                 #         Docs.insert item
    #             return
    #         )).catch((err)->
    #         )

    sites: () ->
        for num in [1..40]
            url = "https://api.stackexchange.com/2.2/sites?pagesize=100&page=#{num}&key=lPplyGlNUs)cIMOajW03aw(("
            options = {
                url: url
                headers: 'accept-encoding': 'gzip'
                gzip: true
            }
            rp(options)
                .then(Meteor.bindEnvironment((data)->
                    parsed = JSON.parse(data)
                    for item in parsed.items
                        found = 
                            Docs.findOne
                                model:'stack_site'
                                name:item.name
                                # question_id:item.question_id
                        # if found
                            # Docs.update found._id,
                            #     $addToSet:tags:query
                        unless found
                            # item.site = 'money'
                            item.model = 'stack_site'
                            # item.tags.push query
                            new_id = 
                                Docs.insert item
                )).catch((err)->
                )
        
    get_site_info: (site) ->
        # var url = 'https://api.stackexchange.com/2.2/sites';
        # url = 'http://api.stackexchange.com/2.1/questions?pagesize=1&fromdate=1356998400&todate=1359676800&order=desc&min=0&sort=votes&tagged=javascript&site=stackoverflow'
        # url = "http://api.stackexchange.com/2.1/questions?pagesize=10&order=desc&min=0&sort=votes&tagged=#{selected_tags}&intitle=#{query}&site=stackoverflow"
        # url = "http://api.stackexchange.com/2.1/questions?pagesize=10&order=desc&min=0&sort=votes&intitle=#{query}&site=stackoverflow"
        url = "https://api.stackexchange.com/2.2/info?site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_site'
                            api_site_parameter:site
                            # question_id:item.question_id
                    if found
                        Docs.update found._id,
                            $set:
                                new_active_users: item.new_active_users
                                total_users: item.total_users
                                badges_per_minute: item.badges_per_minute
                                total_badges: item.total_badges
                                total_votes: item.total_votes
                                total_comments: item.total_comments
                                answers_per_minute: item.answers_per_minute
                                questions_per_minute: item.questions_per_minute
                                total_answers: item.total_answers
                                total_accepted: item.total_accepted
                                total_unanswered: item.total_unanswered
                                total_questions: item.total_questions
                                api_revision: item.api_revision
            )).catch((err)->
            )
        
        
Meteor.publish 'site_q_count', (
    site
    selected_tags
    )->
        
    match = {model:'stack_question'}
    match.site = site
    if selected_tags.length > 0 then match.tags = $all:selected_tags
    Counts.publish this, 'site_q_counter', Docs.find(match)
    return undefined

Meteor.publish 's_q', (
    site
    selected_tags
    selected_emotion
    sort_key
    sort_direction
    limit
    toggle
    view_bounties
    view_unanswered
    )->
    # site = Docs.findOne
    #     model:'stack_site'
    #     api_site_parameter:site
    match = {
        model:'stack_question'
        site:site
        }
        
    if view_unanswered
        match.is_answered = false
    if view_bounties 
        match.bounty = true
    if selected_tags.length > 0 then match.tags = $all:selected_tags
    if selected_emotion.length > 0 
        match.max_emotion_name = selected_emotion[0]
    if site
        Docs.find match, 
            limit:42
            sort:
                score:sort_direction
                # "#{sort_key}":sort_direction


Meteor.publish 'site_tags', (
    site
    selected_tags
    selected_emotion
    toggle
    view_bounties
    view_unanswered
    # query=''
    )->
    # @unblock()
    self = @
    match = {
        model:'stack_question'
        site:site
        }
    if view_bounties
        match.bounty = true
    if view_unanswered
        match.is_answered = false
    if selected_tags.length > 0 then match.tags = $all:selected_tags
    # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
    doc_count = Docs.find(match).count()
    console.log 'doc_count', doc_count
    site_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:20 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    site_tag_cloud.forEach (tag, i) ->
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'site_tag'
    
    
    site_Location_cloud = Docs.aggregate [
        { $match: match }
        { $project: "Location": 1 }
        { $unwind: "$Location" }
        { $group: _id: "$Location", count: $sum: 1 }
        # { $match: _id: $nin: selected_Locations }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:7 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    site_Location_cloud.forEach (Location, i) ->
        self.added 'results', Random.id(),
            name: Location.name
            count: Location.count
            model:'site_Location'
  
  
    site_Organization_cloud = Docs.aggregate [
        { $match: match }
        { $project: "Organization": 1 }
        { $unwind: "$Organization" }
        { $group: _id: "$Organization", count: $sum: 1 }
        # { $match: _id: $nin: selected_Organizations }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:5 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    site_Organization_cloud.forEach (Organization, i) ->
        self.added 'results', Random.id(),
            name: Organization.name
            count: Organization.count
            model:'site_Organization'
  
  
    site_Person_cloud = Docs.aggregate [
        { $match: match }
        { $project: "Person": 1 }
        { $unwind: "$Person" }
        { $group: _id: "$Person", count: $sum: 1 }
        # { $match: _id: $nin: selected_Persons }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:5 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    site_Person_cloud.forEach (Person, i) ->
        self.added 'results', Random.id(),
            name: Person.name
            count: Person.count
            model:'site_Person'
  
  
    site_Company_cloud = Docs.aggregate [
        { $match: match }
        { $project: "Company": 1 }
        { $unwind: "$Company" }
        { $group: _id: "$Company", count: $sum: 1 }
        # { $match: _id: $nin: selected_Companys }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:5 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    site_Company_cloud.forEach (Company, i) ->
        self.added 'results', Random.id(),
            name: Company.name
            count: Company.count
            model:'site_Company'
  
  
    site_emotion_cloud = Docs.aggregate [
        { $match: match }
        { $project: "max_emotion_name": 1 }
        { $group: _id: "$max_emotion_name", count: $sum: 1 }
        # { $match: _id: $nin: selected_emotions }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:5 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    site_emotion_cloud.forEach (emotion, i) ->
        self.added 'results', Random.id(),
            name: emotion.name
            count: emotion.count
            model:'site_emotion'
  
  
    self.ready()



Meteor.publish 'site_user_tags', (
    selected_tags
    site
    user_query
    location_query
    toggle
    view_bounties
    view_unanswered
    # query=''
    )->
    # @unblock()
    self = @
    match = {
        model:'stackuser'
        site:site
        }
    doc_count = Docs.find(match).count()
    if selected_tags.length > 0 then match.tags = $all:selected_tags
    site_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:20 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    site_tag_cloud.forEach (tag, i) ->
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'site_user_tag'
    
    
    site_Location_cloud = Docs.aggregate [
        { $match: match }
        { $project: "Location": 1 }
        { $unwind: "$Location" }
        { $group: _id: "$Location", count: $sum: 1 }
        # { $match: _id: $nin: selected_Locations }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:7 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    site_Location_cloud.forEach (Location, i) ->
        self.added 'results', Random.id(),
            name: Location.name
            count: Location.count
            model:'site_Location'
  
  
    site_Organization_cloud = Docs.aggregate [
        { $match: match }
        { $project: "Organization": 1 }
        { $unwind: "$Organization" }
        { $group: _id: "$Organization", count: $sum: 1 }
        # { $match: _id: $nin: selected_Organizations }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:7 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    site_Organization_cloud.forEach (Organization, i) ->
        self.added 'results', Random.id(),
            name: Organization.name
            count: Organization.count
            model:'site_Organization'
  
  
    site_Person_cloud = Docs.aggregate [
        { $match: match }
        { $project: "Person": 1 }
        { $unwind: "$Person" }
        { $group: _id: "$Person", count: $sum: 1 }
        # { $match: _id: $nin: selected_Persons }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:7 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    site_Person_cloud.forEach (Person, i) ->
        self.added 'results', Random.id(),
            name: Person.name
            count: Person.count
            model:'site_Person'
  
  
    site_Company_cloud = Docs.aggregate [
        { $match: match }
        { $project: "Company": 1 }
        { $unwind: "$Company" }
        { $group: _id: "$Company", count: $sum: 1 }
        # { $match: _id: $nin: selected_Companys }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:7 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    site_Company_cloud.forEach (Company, i) ->
        self.added 'results', Random.id(),
            name: Company.name
            count: Company.count
            model:'site_Company'
  
  
    self.ready()


Meteor.publish 'stackusers_by_site', (
    site
    user_query
    location_query
    selected_tags
    sort_key
    sort_direction
    limit
)->
    # site = Docs.findOne
    #     model:'stack_site'
    #     api_site_parameter:site
    match = {
        model:'stackuser'
        site:site
        }
    if user_query
        match.display_name = {$regex:"#{user_query}", $options:'i'}
    if location_query
        match.location = {$regex:"#{location_query}", $options:'i'}
    if selected_tags.length > 0 then match.tags = $all:selected_tags
    if site
        Docs.find match, 
            limit:20
            sort:
                reputation:-1
            #     "#{sort_key}":sort_direction
            # limit:limit
                    
                        
                        
                
Meteor.publish 'stack_sites', (selected_tags=[], name_filter='')->
    match = {model:'stack_site'}
    match.site_type = 'main_site'
    if selected_tags.length > 0
        match.tags = $all: selected_tags
    if name_filter.length > 0
        match.name = {$regex:"#{name_filter}", $options:'i'}
    Docs.find match,
        limit:30
        
Meteor.publish 'stack_sites_small', (selected_tags=[], name_filter='')->
    match = {model:'stack_site'}
    match.site_type = 'main_site'
    if selected_tags.length > 0
        match.tags = $all: selected_tags
    if name_filter.length > 0
        match.name = {$regex:"#{name_filter}", $options:'i'}
    Docs.find match,
        {
            limit:100
            fields:
                audience:1
                logo_url:1
                name:1
                model:1
                api_site_parameter:1
                styling:1
                total_answers:1
                total_questions:1
        }


                        
                        
                        
                        
Meteor.publish 'suser_tags', (
    selected_tags
    # site
    # user_id
    # user_query
    # query=''
    )->
    # @unblock()
    self = @
    match = {
        model:'stackuser'
        # site:site
        # "owner.user_id":parseInt(user_id)
        }
    doc_count = Docs.find(match).count()
    if selected_tags.length > 0 then match.tags = $in:selected_tags
    site_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:20 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    site_tag_cloud.forEach (tag, i) ->
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'suser_tag'
    self.ready()
    
    
    
Meteor.publish 'agg_sentiment_site', (
    site
    selected_tags
    )->
    # @unblock()
    self = @
    match = {
        model:$in:['stack_question','stack_answer','stack_comment']
        site:site
    }
        
    doc_count = Docs.find(match).count()
    if selected_tags.length > 0 then match.tags = $all:selected_tags
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