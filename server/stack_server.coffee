request = require('request')
rp = require('request-promise');

Meteor.publish 'question_from_id', (qid)->
    Docs.find 
        # model:'stack_question'
        question_id:qid

Meteor.publish 'suser_badges', (site,user_id)->
    Docs.find { 
        model:'stack_badge'
        "user.user_id":parseInt(user_id)
    }, limit:10
Meteor.publish 'suser_comments', (site,user_id)->
    Docs.find { 
        model:'stack_comment'
        "owner.user_id":parseInt(user_id)
    }, limit:100
Meteor.publish 'suser_questions', (site,user_id)->
    Docs.find { 
        model:'stack_question'
        "owner.user_id":parseInt(user_id)
    }, limit:10
Meteor.publish 'suser_answers', (site,user_id)->
    Docs.find { 
        model:'stack_answer'
        "owner.user_id":parseInt(user_id)
    }, limit:10
Meteor.publish 'suser_tags', (site,user_id)->
    Docs.find { 
        model:'stack_tag'
        "owner.user_id":parseInt(user_id)
    }, limit:10
    
Meteor.publish 'question_comments', (question_doc_id)->
    doc = Docs.findOne question_doc_id
    Docs.find 
        model:'stack_comment'
        post_id:doc.question_id
        site:doc.site
Meteor.publish 'question_linked_to', (question_doc_id)->
    doc = Docs.findOne question_doc_id
    Docs.find 
        model:'stack_question'
        linked_to_ids:$in:[question_doc_id]
        site:question.site

Meteor.publish 'related_questions', (question_doc_id)->
    question = Docs.findOne question_doc_id
    Docs.find 
        model:'stack_question'
        _id:$in:question.related_question_ids
        site:question.site

Meteor.publish 'linked_questions', (question_doc_id)->
    question = Docs.findOne question_doc_id
    Docs.find 
        model:'stack_question'
        _id:$in:question.linked_question_ids
        site:question.site

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




Meteor.methods 
    get_question: (site, question_doc_id)->
        question = Docs.findOne question_doc_id
        url = "https://api.stackexchange.com/2.2/questions/#{question.question_id}?order=desc&sort=activity&site=#{site}&filter=!9_bDDxJY5&key=lPplyGlNUs)cIMOajW03aw(("
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


        
    get_question_answers: (site, question_doc_id)->
        question = Docs.findOne question_doc_id
        url = "https://api.stackexchange.com/2.2/questions/#{question.question_id}/answers?order=desc&sort=activity&site=#{site}&filter=!9_bDE(fI5&key=lPplyGlNUs)cIMOajW03aw(("
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


        
    get_question_comments: (site, question_doc_id)->
        question = Docs.findOne question_doc_id
        url = "https://api.stackexchange.com/2.2/questions/#{question.question_id}/comments?order=desc&sort=creation&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
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
                            "item.post_id":item.post_id
                            site:site
                    if found
                        console.log 'found'
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


        
    get_linked_questions: (site, question_doc_id)->
        question = Docs.findOne question_doc_id
        url = "https://api.stackexchange.com/2.2/questions/#{question.question_id}/linked?order=desc&sort=activity&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
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


        
    get_related_questions: (site, question_doc_id)->
        console.log 'getting related', site, question_doc_id
        question = Docs.findOne question_doc_id
        url = "https://api.stackexchange.com/2.2/questions/#{question.question_id}/related?order=desc&sort=activity&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                for item in parsed.items
                    console.log 'related item', item
                    Docs.update question_doc_id,
                        $addToSet:related_question_ids:item._id
                    found = 
                        Docs.findOne
                            model:'stack_question'
                            post_id:item.post_id
                    if found
                        Docs.update found._id,
                            $addToSet: linked_to_ids: question_doc_id
                            # $set:body:item.body
                    unless found
                        item.site = site
                        item.model = 'stack_question'
                        # item.tags.push query
                        item.linked_to_ids = [question_doc_id]
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
                    Meteor.call 'omega', site, item.owner.user_id, ->
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

    get_suser_questions: (site, user_id) ->
        console.log 'site', site, 'user id', user_id
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
                    # console.log item
                    found = 
                        Docs.findOne
                            model:'stack_question'
                            question_id:item.question_id
                            site:site
                            "owner.user_id":parseInt(user_id)
                    # if found
                    #     console.log 'question', found.title
                    unless found
                        item.model = 'stack_question'
                        item.site = site
                        # item.user_id = parseInt(user_id)
                        new_id = 
                            Docs.insert item
            )).catch((err)->
            )
   
    get_suser_answers: (site, user_id) ->
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
                        # console.log 'found answer', found.title
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

    get_suser_comments: (site, user_id) ->
        console.log 'comm', site, user_id
        cl = console.log
        cl 'hi'

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
                    if found
                        cl 'found COMMENT', found
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
        
    # test: ->
    #     options = {
    #         url: "https://api.stackexchange.com/2.2/users/237231/tags?order=desc&site=stats",
    #         headers: 'accept-encoding': 'gzip'
    #         gzip: true
    #         # json: true
    #     };
    #     rp(options)
    #         .then(Meteor.bindEnvironment((data)->
    #             parsed = JSON.parse(data)
    #             for item in parsed.items
    #                 found = Docs.findOne
    #                     model:'stack_tag'
    #                 if found
    #                 else
    #         )).catch((err)->
    #         )
        