request = require('request')
Meteor.publish 'stack_docs', (
    selected_tags
    view_mode
    emotion_mode
    # query=''
    skip
    )->
    match = {model:'stack'}
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
    get_question: (site, question_id)->
        # console.log 'searching question', site, question_id
       
        url = "https://api.stackexchange.com/2.2/questions/#{question_id}?order=desc&sort=activity&site=#{site}&filter=!9_bDDxJY5&key=lPplyGlNUs)cIMOajW03aw(("
        console.log url
        request.get {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }, Meteor.bindEnvironment((error, response, body) =>
            parsed = JSON.parse(body)
            # console.log 'body',JSON.parse(body), typeof(body)
            for item in parsed.items
                found = 
                    Docs.findOne
                        model:'stack'
                        question_id:item.question_id
                if found
                    # console.log 'found', found.title, 'adding body'
                    Docs.update found._id,
                        $set:body:item.body
                unless found
                    item.site = site
                    item.model = 'stack'
                    # item.tags.push query
                    new_id = 
                        Docs.insert item
                    console.log 'new stack doc', Docs.findOne(new_id).title
            return
        )

        
    question_answers: (site, question_id)->
        # console.log 'searching question', site, question_id
        url = "https://api.stackexchange.com/2.2/questions/#{question_id}/answers?order=desc&sort=activity&site=#{site}&filter=!9_bDE(fI5&key=lPplyGlNUs)cIMOajW03aw(("
        console.log url
        request.get {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }, Meteor.bindEnvironment((error, response, body) =>
            parsed = JSON.parse(body)
            # console.log 'body',JSON.parse(body), typeof(body)
            for item in parsed.items
                found = 
                    Docs.findOne
                        model:'stack'
                        question_id:item.question_id
                        answer_id:item.answer_id
                if found
                    console.log 'found', found.body
                #     Docs.update found._id,
                #         $set:body:item.body
                unless found
                    item.site = site
                    item.model = 'stack_answer'
                    # item.tags.push query
                    new_id = 
                        Docs.insert item
                    console.log 'new answer doc', Docs.findOne(new_id).title
            return
        )

        
    search_stack: (site, query, selected_tags) ->
        # console.log('searching stack for', typeof(query), query);
        # var url = 'https://api.stackexchange.com/2.2/sites';
        # url = 'http://api.stackexchange.com/2.1/questions?pagesize=1&fromdate=1356998400&todate=1359676800&order=desc&min=0&sort=votes&tagged=javascript&site=stackoverflow'
        # url = "http://api.stackexchange.com/2.1/questions?pagesize=10&order=desc&min=0&sort=votes&tagged=#{selected_tags}&intitle=#{query}&site=stackoverflow"
        # url = "http://api.stackexchange.com/2.1/questions?pagesize=10&order=desc&min=0&sort=votes&intitle=#{query}&site=stackoverflow"
        # url = "https://api.stackexchange.com/2.2/search?order=desc&sort=activity&intitle=#{query}&site=#{site}&key=lPplyGlNUs)cIMOajW03aw((&filter=!b6Aub*F.YBcq0h"
        url = "https://api.stackexchange.com/2.2/search?order=desc&sort=activity&intitle=#{query}&site=#{site}&key=lPplyGlNUs)cIMOajW03aw(("
        request.get {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }, Meteor.bindEnvironment((error, response, body) =>
            parsed = JSON.parse(body)
            # console.log 'body',JSON.parse(body), typeof(body)
            for item in parsed.items
                found = 
                    Docs.findOne
                        model:'stack'
                        question_id:item.question_id
                if found
                    # console.log 'found', found.title
                    Docs.update found._id,
                        $addToSet:tags:query
                unless found
                    item.site = site
                    item.model = 'stack'
                    item.tags.push query
                    new_id = 
                        Docs.insert item
                    console.log 'new stack doc', Docs.findOne(new_id).title
            return
        )


Meteor.methods 
    sites: () ->
        console.log 'getting sites'
        # var url = 'https://api.stackexchange.com/2.2/sites';
        # url = 'http://api.stackexchange.com/2.1/questions?pagesize=1&fromdate=1356998400&todate=1359676800&order=desc&min=0&sort=votes&tagged=javascript&site=stackoverflow'
        # url = "http://api.stackexchange.com/2.1/questions?pagesize=10&order=desc&min=0&sort=votes&tagged=#{selected_tags}&intitle=#{query}&site=stackoverflow"
        # url = "http://api.stackexchange.com/2.1/questions?pagesize=10&order=desc&min=0&sort=votes&intitle=#{query}&site=stackoverflow"
        url = "https://api.stackexchange.com/2.2/sites?pagesize=100&page=2"
        request.get {
            url: url
            headers: 'accept-encoding': 'gzip'
            gzip: true
        }, Meteor.bindEnvironment((error, response, body) =>
            parsed = JSON.parse(body)
            # console.log 'body',JSON.parse(body), typeof(body)
            for item in parsed.items
                found = 
                    Docs.findOne
                        model:'stack_site'
                        name:item.name
                        # question_id:item.question_id
                if found
                    console.log 'found site', found.name
                    # Docs.update found._id,
                    #     $addToSet:tags:query
                unless found
                    # item.site = 'money'
                    item.model = 'stack_site'
                    # item.tags.push query
                    new_id = 
                        Docs.insert item
                    console.log 'new stack doc', Docs.findOne(new_id)
            return
        )
        return