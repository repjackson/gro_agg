request = require('request')
rp = require('request-promise');


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
    # console.log 'skip', skip
    # match.model = 'wikipedia'
    # if selected_emotions.length > 0 then match.max_emotion_name = $all:selected_emotions
    
    # console.log 'doc match', match
    Docs.find match,
        limit:7
        skip:skip
        sort:
            points: -1
            ups:-1
            # views: -1



# Meteor.publish 'stack_tags', (
#     selected_tags
#     # view_mode
#     # emotion_mode
#     # toggle
#     # selected_models
#     # query=''
#     )->
#     # @unblock()
#     self = @
#     match = {}
#     # console.log 'tags', selected_tags
#     # if emotion_mode
#     #     match.max_emotion_name = emotion_mode
#     if selected_models.length > 0 then match.model = $all:selected_models

#     # console.log 'emotion mode', emotion_mode
#     # if selected_tags.length > 0
#         # console.log 'view_mode', view_mode
#         # console.log 'query', query
#     match.model = 'stack'
#     # switch view_mode 
#     #     when 'stack'
#     #         match.model = 'stack'
#     #     # when 'porn'
#     #     #     match.model = 'porn'
#     if selected_tags.length > 0 
#         match.tags = $all: selected_tags
#     else
#         unless view_mode is 'stack'
#             match.tags = $in:['daoism']
#         # unless selected_subreddits.length>0
#     # else if view_mode in ['reddit',null]
#     doc_count = Docs.find(match).count()
#     # console.log 'count',doc_count
#     # if query.length > 3
#     #     match.title = {$regex:"#{query}"}
#     #     model:'wikipedia'
#     # if query.length > 4
#     #     console.log 'searching query', query
#     #     # match.tags = {$regex:"#{query}", $options: 'i'}
#     #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    
#     #     terms = Docs.find({
#     #         model:'wikipedia'            
#     #         title: {$regex:"#{query}", $options: 'i'}
#     #         title: {$regex:"#{query}"}
#     #     },
#     #         # sort:
#     #         #     count: -1
#     #         limit: 10
#     #     )
#     #     terms.forEach (term, i) ->
#     #         self.added 'results', Random.id(),
#     #             name: term.title
#     #             # count: term.count
#     #             model:'tag'
#     #     # self.ready()
#     # else
#     # model_cloud = Docs.aggregate [
#     #     { $match: match }
#     #     { $project: "model": 1 }
#     #     # { $unwind: "$models" }
#     #     { $group: _id: "$model", count: $sum: 1 }
#     #     { $match: _id: $nin: selected_models }
#     #     { $sort: count: -1, _id: 1 }
#     #     { $match: count: $lt: doc_count }
#     #     { $limit:20 }
#     #     { $project: _id: 0, name: '$_id', count: 1 }
#     #     ]
#     # # # console.log 'cloud: ', model_cloud
#     # # console.log 'model match', match
#     # model_cloud.forEach (model, i) ->
#     #     self.added 'results', Random.id(),
#     #         name: model.name
#     #         count: model.count
#     #         model:'model'
  
  
  
#     location_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "Location": 1 }
#         { $unwind: "$Location" }
#         { $group: _id: "$Location", count: $sum: 1 }
#         # { $match: _id: $nin: selected_locations }
#         { $sort: count: -1, _id: 1 }
#         { $match: count: $lt: doc_count }
#         { $limit:7 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     # console.log 'cloud: ', location_cloud
#     # console.log 'location match', match
#     location_cloud.forEach (location, i) ->
#         # console.log 'location',location
#         self.added 'results', Random.id(),
#             name: location.name
#             count: location.count
#             model:'location'
    
      
#     site_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "site": 1 }
#         { $unwind: "$site" }
#         { $group: _id: "$site", count: $sum: 1 }
#         # { $match: _id: $nin: selected_sites }
#         { $sort: count: -1, _id: 1 }
#         { $match: count: $lt: doc_count }
#         { $limit:7 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     # console.log 'cloud: ', site_cloud
#     # console.log 'site match', match
#     site_cloud.forEach (site, i) ->
#         # console.log 'site',site
#         self.added 'results', Random.id(),
#             name: site.name
#             count: site.count
#             model:'site'

      
    
#     facility_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "Facility": 1 }
#         { $unwind: "$Facility" }
#         { $group: _id: "$Facility", count: $sum: 1 }
#         # { $match: _id: $nin: selected_facilitys }
#         { $sort: count: -1, _id: 1 }
#         { $match: count: $lt: doc_count }
#         { $limit:7 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     # console.log 'cloud: ', facility_cloud
#     # console.log 'facility match', match
#     facility_cloud.forEach (facility, i) ->
#         # console.log 'facility',facility
#         self.added 'results', Random.id(),
#             name: facility.name
#             count: facility.count
#             model:'facility'
    
    
    
  
#     organization_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "Organization": 1 }
#         { $unwind: "$Organization" }
#         { $group: _id: "$Organization", count: $sum: 1 }
#         # { $match: _id: $nin: selected_organizations }
#         { $sort: count: -1, _id: 1 }
#         { $match: count: $lt: doc_count }
#         { $limit:7 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     # console.log 'cloud: ', organization_cloud
#     # console.log 'organization match', match
#     organization_cloud.forEach (organization, i) ->
#         # console.log 'organization',organization
#         self.added 'results', Random.id(),
#             name: organization.name
#             count: organization.count
#             model:'organization'
    
    
    
    
  
#     movie_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "Movie": 1 }
#         { $unwind: "$Movie" }
#         { $group: _id: "$Movie", count: $sum: 1 }
#         # { $match: _id: $nin: selected_movies }
#         { $sort: count: -1, _id: 1 }
#         { $match: count: $lt: doc_count }
#         { $limit:7 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     # console.log 'cloud: ', movie_cloud
#     # console.log 'movie match', match
#     movie_cloud.forEach (movie, i) ->
#         # console.log 'movie',movie
#         self.added 'results', Random.id(),
#             name: movie.name
#             count: movie.count
#             model:'movie'
    
    
    
  
#     sport_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "Sport": 1 }
#         { $unwind: "$Sport" }
#         { $group: _id: "$Sport", count: $sum: 1 }
#         # { $match: _id: $nin: selected_sports }
#         { $sort: count: -1, _id: 1 }
#         { $match: count: $lt: doc_count }
#         { $limit:7 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     # console.log 'cloud: ', sport_cloud
#     # console.log 'sport match', match
#     sport_cloud.forEach (sport, i) ->
#         # console.log 'sport',sport
#         self.added 'results', Random.id(),
#             name: sport.name
#             count: sport.count
#             model:'sport'
    
    
    
  
#     award_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "Award": 1 }
#         { $unwind: "$Award" }
#         { $group: _id: "$Award", count: $sum: 1 }
#         # { $match: _id: $nin: selected_awards }
#         { $sort: count: -1, _id: 1 }
#         { $match: count: $lt: doc_count }
#         { $limit:7 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     # console.log 'cloud: ', award_cloud
#     # console.log 'award match', match
#     award_cloud.forEach (award, i) ->
#         # console.log 'award',award
#         self.added 'results', Random.id(),
#             name: award.name
#             count: award.count
#             model:'award'
    
    
#     PrintMedia_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "PrintMedia": 1 }
#         # { $unwind: "$PrintMedia" }
#         { $group: _id: "$PrintMedia", count: $sum: 1 }
#         # { $match: _id: $nin: selected_PrintMedias }
#         { $sort: count: -1, _id: 1 }
#         { $match: count: $lt: doc_count }
#         { $limit:7 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     # console.log 'cloud: ', PrintMedia_cloud
#     # console.log 'PrintMedia match', match
#     PrintMedia_cloud.forEach (PrintMedia, i) ->
#         # console.log 'PrintMedia',PrintMedia
#         self.added 'results', Random.id(),
#             name: PrintMedia.name
#             count: PrintMedia.count
#             model:'print'
    
    
    
#     person_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "Person": 1 }
#         { $unwind: "$Person" }
#         { $group: _id: "$Person", count: $sum: 1 }
#         # { $match: _id: $nin: selected_persons }
#         { $sort: count: -1, _id: 1 }
#         { $match: count: $lt: doc_count }
#         { $limit:7 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     # console.log 'cloud: ', person_cloud
#     # console.log 'person match', match
#     person_cloud.forEach (person, i) ->
#         # console.log 'person',person
#         self.added 'results', Random.id(),
#             name: person.name
#             count: person.count
#             model:'person'
    
    
#     company_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "Company": 1 }
#         { $unwind: "$Company" }
#         { $group: _id: "$Company", count: $sum: 1 }
#         # { $match: _id: $nin: selected_companys }
#         { $sort: count: -1, _id: 1 }
#         { $match: count: $lt: doc_count }
#         { $limit:7 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     # console.log 'cloud: ', company_cloud
#     # console.log 'company match', match
#     company_cloud.forEach (company, i) ->
#         # console.log 'company',company
#         self.added 'results', Random.id(),
#             name: company.name
#             count: company.count
#             model:'company'
    
    
    
#     emotion_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "max_emotion_name": 1 }
#         # { $unwind: "$emotions" }
#         { $group: _id: "$max_emotion_name", count: $sum: 1 }
#         # { $match: _id: $nin: selected_emotions }
#         { $sort: count: -1, _id: 1 }
#         { $match: count: $lt: doc_count }
#         { $limit:5 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     # console.log 'cloud: ', emotion_cloud
#     # console.log 'emotion match', match
#     emotion_cloud.forEach (emotion, i) ->
#         # console.log 'emotion',emotion
#         self.added 'results', Random.id(),
#             name: emotion.name
#             count: emotion.count
#             model:'emotion'
    
#     switch view_mode
#         when 'stack'
#             tag_limit = 20
#         else
#             tag_limit = 11
  
#     tag_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "tags": 1 }
#         { $unwind: "$tags" }
#         { $group: _id: "$tags", count: $sum: 1 }
#         { $match: _id: $nin: selected_tags }
#         { $sort: count: -1, _id: 1 }
#         { $match: count: $lt: doc_count }
#         { $limit:tag_limit }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     # console.log 'cloud: ', tag_cloud
#     console.log 'tag match', match
#     tag_cloud.forEach (tag, i) ->
#         self.added 'results', Random.id(),
#             name: tag.name
#             count: tag.count
#             model:'tag'
#     self.ready()



Meteor.methods 
    get_question: (site, question_doc_id)->
        question = Docs.findOne question_doc_id
        # console.log 'searching question', site, question_id
        url = "https://api.stackexchange.com/2.2/questions/#{question.question_id}?order=desc&sort=activity&site=#{site}&filter=!9_bDDxJY5&key=lPplyGlNUs)cIMOajW03aw(("
        console.log url
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                # console.log 'body',JSON.parse(body), typeof(body)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_question'
                            question_id:item.question_id
                    if found
                        # console.log 'found', found.title, 'adding body'
                        Docs.update found._id,
                            $set:body:item.body
                    unless found
                        item.site = site
                        item.model = 'stack_question'
                        # item.tags.push query
                        new_id = 
                            Docs.insert item
                        console.log 'new stack doc', Docs.findOne(new_id).title
                        Meteor.call 'call_watson', new_id,'link','stack',->

                return
            )).catch((err)->
                console.log 'fail', err
            )


        
    get_question_answers: (site, question_doc_id)->
        question = Docs.findOne question_doc_id
        # console.log 'searching question', site, question_id
        url = "https://api.stackexchange.com/2.2/questions/#{question.question_id}/answers?order=desc&sort=activity&site=#{site}&filter=!9_bDE(fI5&key=lPplyGlNUs)cIMOajW03aw(("
        # console.log url
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                # console.log 'body',JSON.parse(body), typeof(body)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_answer'
                            # question_id:item.question_id
                            answer_id:item.answer_id
                    # if found
                    #     console.log 'found', found.body
                    #     Docs.update found._id,
                    #         $set:body:item.body
                    unless found
                        item.site = site
                        item.model = 'stack_answer'
                        # item.answer_id = item.answer_id
                        # item.tags.push query
                        new_id = 
                            Docs.insert item
                        console.log 'new answer doc', Docs.findOne(new_id).title
                return
            )).catch((err)->
                console.log 'fail', err
            )


        
    get_question_comments: (site, question_doc_id)->
        question = Docs.findOne question_doc_id
        # console.log 'searching question', site, question_id
        url = "https://api.stackexchange.com/2.2/questions/#{question.question_id}/comments?order=desc&sort=creation&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        # console.log url
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                # console.log 'body',JSON.parse(body), typeof(body)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_comment'
                            post_id:item.post_id
                    # if found
                    #     console.log 'found', found.body
                    #     Docs.update found._id,
                    #         $set:body:item.body
                    unless found
                        item.site = site
                        item.model = 'stack_comment'
                        # item.tags.push query
                        new_id = 
                            Docs.insert item
                        console.log 'new comment doc', Docs.findOne(new_id).title
                return
            )).catch((err)->
                console.log 'fail', err
            )


        
    get_linked_questions: (site, question_doc_id)->
        question = Docs.findOne question_doc_id
        # console.log 'searching linked questions', site, question._id
        url = "https://api.stackexchange.com/2.2/questions/#{question.question_id}/linked?order=desc&sort=activity&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        # console.log url
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                console.log 'body',JSON.parse(data), typeof(data)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_question'
                            post_id:item.post_id
                    if found
                        console.log 'found', found.body
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
                        console.log 'new question doc', Docs.findOne(new_id).title
                return
            )).catch((err)->
                console.log 'fail', err
            )


        
    get_related_questions: (site, question_doc_id)->
        question = Docs.findOne question_doc_id
        # console.log 'searching related questions', site, question._id
        url = "https://api.stackexchange.com/2.2/questions/#{question.question_id}/related?order=desc&sort=activity&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        # console.log url
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                console.log 'body',JSON.parse(data), typeof(data)
                for item in parsed.items
                    Docs.update question_doc_id,
                        $addToSet:related_question_ids:item._id
                    found = 
                        Docs.findOne
                            model:'stack_question'
                            post_id:item.post_id
                    if found
                        console.log 'found related', found.title
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
                        console.log 'new question doc', Docs.findOne(new_id).title
                return
            )).catch((err)->
                console.log 'fail', err
            )


        
    search_stack: (site, query, selected_tags) ->
        # console.log('searching stack for', typeof(query), query);
        url = "https://api.stackexchange.com/2.2/search?order=desc&sort=activity&intitle=#{query}&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                # console.log 'body',JSON.parse(body), typeof(body)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_question'
                            question_id:item.question_id
                    if found
                        # console.log 'found', found.title
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
                        console.log 'new stack doc', Docs.findOne(new_id).title
                        # unless found.watson
                        Meteor.call 'call_watson', new_id,'link','stack',->
                    Meteor.call 'stackuser_questions', site, item.owner.user_id, ->
                    Meteor.call 'stackuser_tags', site, item.owner.user_id, ->
                    Meteor.call 'omega', site, item.owner.user_id, ->
                return
            )).catch((err)->
                console.log 'fail', err
            )

   
   
    search_stackuser: (site, user_id) ->
        @unblock()
        # console.log('searching stack user for', site, user_id);
        url = "https://api.stackexchange.com/2.2/users/#{user_id}?order=desc&sort=reputation&site=#{site}&filter=!--1nZv)deGu1&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                # console.log 'body',JSON.parse(body), typeof(body)
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

                        # console.log 'found', found.display_name
                    unless found
                        item.site = site
                        item.model = 'stackuser'
                        new_id = 
                            Docs.insert item
                        # console.log 'new stack user', Docs.findOne(new_id).display_name
                return
            )).catch((err)->
                console.log 'fail', err
            )
   
    get_site_users: (site) ->
        # console.log('searching stack user for', site, user_id);
        for num in [1..100]
            console.log 'searching ', site, 'round ', num
            url = "https://api.stackexchange.com/2.2/users?order=desc&sort=reputation&page=#{num}&pagesize=100&site=#{site}&filter=!--1nZv)deGu1&key=lPplyGlNUs)cIMOajW03aw(("
            options = {
                url: url
                headers: 'accept-encoding': 'gzip'
                gzip: true
            }
            rp(options)
                .then(Meteor.bindEnvironment((data)->
                    parsed = JSON.parse(data)
                    # console.log 'body',JSON.parse(body), typeof(body)
                    for item in parsed.items
                        found = 
                            Docs.findOne
                                model:'stackuser'
                                site:site
                                user_id:item.user_id
                        if found
                            console.log 'found', found.display_name
                        unless found
                            item.site = site
                            item.model = 'stackuser'
                            new_id = 
                                Docs.insert item
                            console.log 'new stack user', Docs.findOne(new_id).display_name
                    return
                )).catch((err)->
                    console.log 'fail', err
                )

    stackuser_questions: (site, user_id) ->
        # console.log('searching stack user questions for', site, user_id);
        url = "https://api.stackexchange.com/2.2/users/#{user_id}/questions?order=desc&sort=activity&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                # console.log 'body',JSON.parse(body), typeof(body)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_question'
                            site:site
                            "owner.user_id":parseInt(user_id)
                    # if found
                    #     console.log 'found', found.title
                    unless found
                        item.site = site
                        item.model = 'stack_question'
                        new_id = 
                            Docs.insert item
                        console.log 'new stack question', Docs.findOne(new_id).title
            )).catch((err)->
                console.log 'fail', err
            )
   
    stackuser_answers: (site, user_id) ->
        # console.log('searching stack user answers for', site, user_id);
        url = "https://api.stackexchange.com/2.2/users/#{user_id}/answers?order=desc&sort=activity&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                # console.log 'body',JSON.parse(body), typeof(body)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_answer'
                            site:site
                            user_id:parseInt(user_id)
                    # if found
                    #     console.log 'found', found.body
                    unless found
                        item.site = site
                        item.model = 'stack_answer'
                        item.user_id = parseInt(user_id)
                        new_id = 
                            Docs.insert item
                        console.log 'new stack answer', Docs.findOne(new_id).body
                return
            )).catch((err)->
                console.log 'fail', err
            )

    stackuser_comments: (site, user_id) ->
        # console.log('searching stack user comments for', site, user_id);
        url = "https://api.stackexchange.com/2.2/users/#{user_id}/comments?order=desc&site=#{site}&filter=!--1nZxautsE.&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                # console.log 'body',JSON.parse(body), typeof(body)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_comment'
                            site:site
                            user_id:parseInt(user_id)
                    if found
                        # console.log 'found', found.body
                        Docs.update found._id, 
                            $set:
                                owner:item.owner
                                post_type:item.post_type
                                body:item.body
                    unless found
                        item.site = site
                        item.model = 'stack_comment'
                        item.user_id = parseInt(user_id)
                        new_id = 
                            Docs.insert item
                        # console.log 'new stack comment', Docs.findOne(new_id).body
                return
            )).catch((err)->
                console.log 'fail', err
            )
        # }).then(Meteor.bindEnvironment((error, response, body) =>
        # )).catch(() => {
        #     console.log('error')
        # })
        
    stackuser_badges: (site, user_id) ->
        user = Docs.findOne
            model:'stackuser'
            user_id:parseInt(user_id)
            site:site
        # console.log 'found user updating badges', user
        # console.log('searching stack user badges for', site, user_id);
        url = "https://api.stackexchange.com/2.2/users/#{user_id}/badges?order=desc&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)=>
                parsed = JSON.parse(data)
                # console.log 'body',JSON.parse(body), typeof(body)
                # adding_tags = []
                for item in parsed.items
                    # adding_tags.push item.name
                    console.log item.name
                # Docs.update user._id,
                #     $addToSet:
                #         tags:$each:adding_tags
                #     found = 
                #         Docs.findOne
                #             model:'stack_badge'
                #             site:site
                #             user_id:parseInt(user_id)
                #     # if found
                #     #     console.log 'found', found.title
                #     unless found
                #         item.site = site
                #         item.model = 'stack_badge'
                #         new_id = 
                #             Docs.insert item
                #         console.log 'new stack badge', Docs.findOne(new_id).title
                return
            )).catch((err)->
                console.log 'fail', err
            )
        
    stackuser_tags: (site, user_id) ->
        user = Docs.findOne
            model:'stackuser'
            user_id:parseInt(user_id)
            site:site

        # console.log('searching stack user tags for', site, user_id);
        url = "https://api.stackexchange.com/2.2/users/#{user_id}/tags?order=desc&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        options = {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                # console.log 'body',JSON.parse(body), typeof(body)
                adding_tags = []
                for item in parsed.items
                    adding_tags.push item.name
                Docs.update user._id,
                    $addToSet:
                        tags:$each:adding_tags
                    # found = 
                    #     Docs.findOne
                    #         model:'stack_tag'
                    #         site:site
                    #         user_id:parseInt(user_id)
                    # if found
                    #     console.log 'found', found
                    # unless found
                    #     item.site = site
                    #     item.model = 'stack_tag'
                    #     new_id = 
                    #         Docs.insert item
                    #     console.log 'new stack tag', Docs.findOne(new_id)
                return
            )).catch((err)->
                console.log 'fail', err
            )

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
                    # console.log 'body',JSON.parse(body), typeof(body)
                    for item in parsed.items
                        found = 
                            Docs.findOne
                                model:'stack_site'
                                name:item.name
                                # question_id:item.question_id
                        # if found
                        #     console.log 'found site', found.name
                            # Docs.update found._id,
                            #     $addToSet:tags:query
                        unless found
                            # item.site = 'money'
                            item.model = 'stack_site'
                            # item.tags.push query
                            new_id = 
                                Docs.insert item
                            console.log 'new stack site', Docs.findOne(new_id).name
                    return
                )).catch((err)->
                    console.log 'fail', err
                )
        
    get_site_info: (site) ->
        # console.log 'getting sites'
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
                # console.log 'body',JSON.parse(body), typeof(body)
                for item in parsed.items
                    found = 
                        Docs.findOne
                            model:'stack_site'
                            api_site_parameter:site
                            # question_id:item.question_id
                    if found
                        # console.log 'found site', found.name
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

                return
            )).catch((err)->
                console.log 'fail', err
            )
        
    test: ->
        options = {
            url: "https://api.stackexchange.com/2.2/users/237231/tags?order=desc&site=stats",
            headers: 'accept-encoding': 'gzip'
            gzip: true
            # json: true
        };
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                # console.log('User has repos', data)
                parsed = JSON.parse(data)
                for item in parsed.items
                    console.log item
                    found = Docs.findOne
                        model:'stack_tag'
                    if found
                        console.log found
                    else
                        console.log 'not found'
            )).catch((err)->
                console.log 'fail', err
            )
        