
Meteor.publish 'site_user_count', (
    site
    )->
        
    match = {model:'stackuser'}
    match.site = site
    Counts.publish this, 'user_counter', Docs.find(match)
    return undefined    # otherwise coffeescript returns a Counts.publish
                      # handle when Meteor expects a Mongo.Cursor object.

Meteor.publish 'doc_count', (
    selected_tags
    view_mode
    emotion_mode
    # selected_models
    # selected_subreddits
    selected_emotions
    )->
    match = {}
    # match.model = $in:['wikipedia']
    # match.model = 'wikipedia'
    if selected_tags.length > 0 
        match.tags = $all: selected_tags
    else
        match.tags = $in:['daoism']
    
    if emotion_mode
        match.max_emotion_name = emotion_mode
        
    if selected_emotions.length > 0 then match.max_emotion_name = $all:selected_emotions
    # if selected_subreddits.length > 0 then match.subreddit = selected_subreddits.toString()
    # if selected_models.length > 0 then match.model = $all:selected_models
    # switch view_mode
    #     when 
    switch view_mode 
        when 'image'
            # match.model = 'reddit'
            match.domain = $in:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']
        when 'video'
            # match.model = 'reddit'
            match.domain = $in:['youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'wikipedia'
            match.model = 'wikipedia'
            # match.domain = $in:['youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'twitter'
            match.model = 'reddit'
            match.domain = $in:['twitter.com','mobile.twitter.com']
        when 'posts'
            match.model = 'reddit'
            match.domain = $nin:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com','youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'porn'
            match.model = 'porn'
        when 'stack'
            match.model = 'stack'
        else 
            match.model = $in:['wikipedia','reddit','stack']

    Counts.publish this, 'result_counter', Docs.find(match)
    return undefined


Meteor.methods
    zero: ->
        cur = Docs.find({
            model:'reddit'
            points:$ne:0
        }, limit:10)
        # Docs.update
    convert_img: ->
        cur = 
            Docs.find({
                model:'reddit'
                domain: $in:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']
            }, {
                limit:10
                fields:
                    _id:1
                })
        # domain: $in:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']
        Docs.update({
            model:'reddit'
            domain: 'i.imgur.com'
        }, {
            $set:
                model:'image'
                source:'reddit'
        },{multi:true})
        # for image in cur.fetch()
        #     Docs.update image._id,
        # Docs.update

    lookup_url: (url)->
        found = Docs.findOne url:url 
        if found
            return found
        else
            new_id = 
                Docs.insert
                    model:'page'
                    url:url
            Meteor.call 'call_watson', 'url', 'url'
            Docs.findOne new_id


Meteor.publish 'docs', (
    selected_tags
    view_mode
    emotion_mode
    toggle
    selected_models
    selected_subreddits
    selected_emotions
    # query=''
    skip
    )->
    match = {}
    if emotion_mode
        match.max_emotion_name = emotion_mode

    if selected_tags.length > 0
        match.tags = $all:selected_tags
    # match.model = 'wikipedia'
    if selected_emotions.length > 0 then match.max_emotion_name = $all:selected_emotions
    if selected_subreddits.length > 0 then match.subreddit = selected_subreddits.toString()
    if selected_models.length > 0 then match.model = $all:selected_models
    
    switch view_mode 
        when 'image'
            # match.model = 'image'
            match.domain = $in:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']
        when 'video'
            # match.model = 'video'
            match.domain = $in:['youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'wikipedia'
            match.model = 'wikipedia'
            # match.domain = $in:['youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'posts'
            match.model = 'reddit'
            # match.domain = $nin:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com','youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'stack'
            match.model = 'stack'
        else 
            match.model = $in:['wikipedia','reddit','stack']
    Docs.find match,
        limit:7
        skip:skip
        sort:
            points: -1
            ups:-1
            # views: -1
                    
                    
Meteor.publish 'dtags', (
    selected_tags
    view_mode
    emotion_mode
    toggle
    selected_models
    selected_subreddits
    selected_emotions
    # query=''
    )->
    # @unblock()
    self = @
    match = {}
    if emotion_mode
        match.max_emotion_name = emotion_mode
    if selected_emotions.length > 0 then match.max_emotion_name = $all:selected_emotions
    if selected_subreddits.length > 0 then match.subreddit = selected_subreddits.toString()
    if selected_models.length > 0 then match.model = $all:selected_models

    # if selected_tags.length > 0
    
    switch view_mode 
        when 'posts'
            match.model = 'reddit'
            # match.domain = $nin:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com','youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'image'
            # match.model = 'image'
            # match.source = 'reddit'
            match.domain = $in:['i.imgur.com','i.reddit.com','i.redd.it','imgur.com']
        when 'video'
            # match.model = 'video'
            match.domain = $in:['youtube.com','youtu.be','m.youtube.com','v.redd.it','vimeo.com']
        when 'wikipedia'
            match.model = 'wikipedia'
        when 'stack'
            match.model = 'stack'
        else
            match.model = $in:['wikipedia','reddit','stack']
            # match.model = $in:['wikipedia']
    unless selected_tags.length > 0 then self.ready()

    if selected_tags.length > 0 
        match.tags = $all: selected_tags
                
            # unless selected_subreddits.length>0
        # else if view_mode in ['reddit',null]
        doc_count = Docs.find(match).count()
        # if query.length > 3
        #     match.title = {$regex:"#{query}"}
        #     model:'wikipedia'
        # if query.length > 4
        #     # match.tags = {$regex:"#{query}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
        
        #     terms = Docs.find({
        #         model:'wikipedia'            
        #         title: {$regex:"#{query}", $options: 'i'}
        #         title: {$regex:"#{query}"}
        #     },
        #         # sort:
        #         #     count: -1
        #         limit: 10
        #     )
        #     terms.forEach (term, i) ->
        #         self.added 'results', Random.id(),
        #             name: term.title
        #             # count: term.count
        #             model:'tag'
        #     # self.ready()
        # else
        # model_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "model": 1 }
        #     # { $unwind: "$models" }
        #     { $group: _id: "$model", count: $sum: 1 }
        #     { $match: _id: $nin: selected_models }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:20 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # model_cloud.forEach (model, i) ->
        #     self.added 'results', Random.id(),
        #         name: model.name
        #         count: model.count
        #         model:'model'
      
      
        # unless selected_subreddits.length > 0
        #     subreddit_cloud = Docs.aggregate [
        #         { $match: match }
        #         { $project: "subreddit": 1 }
        #         # { $unwind: "$subreddits" }
        #         { $group: _id: "$subreddit", count: $sum: 1 }
        #         # { $match: _id: $nin: selected_subreddits }
        #         { $sort: count: -1, _id: 1 }
        #         { $match: count: $lt: doc_count }
        #         { $limit:10 }
        #         { $project: _id: 0, name: '$_id', count: 1 }
        #         ]
        #     subreddit_cloud.forEach (subreddit, i) ->
        #         self.added 'results', Random.id(),
        #             name: subreddit.name
        #             count: subreddit.count
        #             model:'subreddit'
          
      
      
        location_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Location": 1 }
            { $unwind: "$Location" }
            { $group: _id: "$Location", count: $sum: 1 }
            # { $match: _id: $nin: selected_locations }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        location_cloud.forEach (location, i) ->
            self.added 'results', Random.id(),
                name: location.name
                count: location.count
                model:'location'
        
          
        if view_mode is 'stack'
            site_cloud = Docs.aggregate [
                { $match: match }
                { $project: "site": 1 }
                { $unwind: "$site" }
                { $group: _id: "$site", count: $sum: 1 }
                # { $match: _id: $nin: selected_sites }
                { $sort: count: -1, _id: 1 }
                { $match: count: $lt: doc_count }
                { $limit:7 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            site_cloud.forEach (site, i) ->
                self.added 'results', Random.id(),
                    name: site.name
                    count: site.count
                    model:'site'
        
          
      
        # subreddit_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "subreddit": 1 }
        #     { $group: _id: "$subreddit", count: $sum: 1 }
        #     # { $match: _id: $nin: selected_subreddits }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:7 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # subreddit_cloud.forEach (subreddit, i) ->
        #     self.added 'results', Random.id(),
        #         name: subreddit.name
        #         count: subreddit.count
        #         model:'subreddit'
        
        
        facility_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Facility": 1 }
            { $unwind: "$Facility" }
            { $group: _id: "$Facility", count: $sum: 1 }
            # { $match: _id: $nin: selected_facilitys }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        facility_cloud.forEach (facility, i) ->
            self.added 'results', Random.id(),
                name: facility.name
                count: facility.count
                model:'facility'
        
        
        
      
        organization_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Organization": 1 }
            { $unwind: "$Organization" }
            { $group: _id: "$Organization", count: $sum: 1 }
            # { $match: _id: $nin: selected_organizations }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        organization_cloud.forEach (organization, i) ->
            self.added 'results', Random.id(),
                name: organization.name
                count: organization.count
                model:'organization'
        
        
        
        
      
        movie_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Movie": 1 }
            { $unwind: "$Movie" }
            { $group: _id: "$Movie", count: $sum: 1 }
            # { $match: _id: $nin: selected_movies }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        movie_cloud.forEach (movie, i) ->
            self.added 'results', Random.id(),
                name: movie.name
                count: movie.count
                model:'movie'
        
        
        
      
        sport_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Sport": 1 }
            { $unwind: "$Sport" }
            { $group: _id: "$Sport", count: $sum: 1 }
            # { $match: _id: $nin: selected_sports }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        sport_cloud.forEach (sport, i) ->
            self.added 'results', Random.id(),
                name: sport.name
                count: sport.count
                model:'sport'
        
        
        
      
        award_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Award": 1 }
            { $unwind: "$Award" }
            { $group: _id: "$Award", count: $sum: 1 }
            # { $match: _id: $nin: selected_awards }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        award_cloud.forEach (award, i) ->
            self.added 'results', Random.id(),
                name: award.name
                count: award.count
                model:'award'
        
        
        PrintMedia_cloud = Docs.aggregate [
            { $match: match }
            { $project: "PrintMedia": 1 }
            # { $unwind: "$PrintMedia" }
            { $group: _id: "$PrintMedia", count: $sum: 1 }
            # { $match: _id: $nin: selected_PrintMedias }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        PrintMedia_cloud.forEach (PrintMedia, i) ->
            self.added 'results', Random.id(),
                name: PrintMedia.name
                count: PrintMedia.count
                model:'print'
        
        
        
        person_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Person": 1 }
            { $unwind: "$Person" }
            { $group: _id: "$Person", count: $sum: 1 }
            # { $match: _id: $nin: selected_persons }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        person_cloud.forEach (person, i) ->
            self.added 'results', Random.id(),
                name: person.name
                count: person.count
                model:'person'
        
        
        company_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Company": 1 }
            { $unwind: "$Company" }
            { $group: _id: "$Company", count: $sum: 1 }
            # { $match: _id: $nin: selected_companys }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        company_cloud.forEach (company, i) ->
            self.added 'results', Random.id(),
                name: company.name
                count: company.count
                model:'company'
        
        
        
        emotion_cloud = Docs.aggregate [
            { $match: match }
            { $project: "max_emotion_name": 1 }
            # { $unwind: "$emotions" }
            { $group: _id: "$max_emotion_name", count: $sum: 1 }
            # { $match: _id: $nin: selected_emotions }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:5 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        emotion_cloud.forEach (emotion, i) ->
            self.added 'results', Random.id(),
                name: emotion.name
                count: emotion.count
                model:'emotion'
        
        # switch view_mode
        #     when 'stack'
        #         tag_limit = 20
        #     else
        #         tag_limit = 11
      
        tag_cloud = Docs.aggregate [
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
        tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tag'
        self.ready()
        
